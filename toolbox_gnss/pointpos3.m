function [x,dtr,dtsv,ion,trop,prn_u,rho,dop,ele,azi]=pointpos(freq,time,prn,app_xyz,data,eph_prm,ephi,est_prm,ion_prm,rej)
%-------------------------------------------------------------------------------
% Function : �P�Ƒ��ʉ��Z
% 
% [argin]
% freq     : ���g���̍\����(*.g1, *.g2, *.r1, *.r2)
% time     : �������̍\����(*.tod, *.week, *.tow, *.mjd, *.day)
% prn      : �q��PRN�ԍ�
% app_xyz  : �T���ʒu
% data     : �ϑ��f�[�^
% eph_prm  : �G�t�F�����X(*.brd, *.sp3)
% ephi     : �e�q���̍œK�ȃG�t�F�����X�̃C���f�b�N�X
% est_prm  : �����ݒ�p�����[�^
% ion_prm  : �d���w�p�����[�^(iona,ionb,gim,dcbG,dcbR)
% rej      : ���O�q��
% 
% [argout]
% x        : ��ԕϐ�
% dtr      : ��M�@���v�덷
% dtsv     : �q�����v�덷
% ion      : �d���w�x��
% trop     : �Η����x��
% prn_u    : �q��PRN�ԍ�(used)
% dop      : DOP
% ele      : �p
% azi      : ���ʊp
% 
% �T���ʒu���Ȃ��ꍇ�ɏ����l�ɓK���Ȉʒu[-4000000;3300000;3700000]��ݒ�(08/11)
% 
% �c�����ɒ[�ɑ傫���q�������O��ǉ�(01/21)
% 
% 
% �� geodist3, geodist_sp33, azel, cal_ion2, cal_trop�̊֐����K�v(measuremodel_pp����)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 12, 2008
%-------------------------------------------------------------------------------
% GLONASS�Ή�
% July 10, 2009, T.Yanase
%-------------------------------------------------------------------------------
%--- �萔
%--------------------------------------------
C=299792458;							% ����

% OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
% MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
% FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

x  = zeros(4,1);
xk = ones(4,1);
x(1:3) = app_xyz';
if norm(x(1:3))==0
	x(1:3) = [-4000000;3300000;3700000];
end
dtr=0;
no_sat=length(prn);
loop=0;
rejd=rej;
while norm(x-xk) > 0.1
	loop=loop+1;

	% ������
	%--------------------------------------------
% 	sat_xyz=[]; sat_xyz_dot=[]; dtsv=[]; health=[]; ion=[]; trop=[]; azi=[]; ele=[]; rho=[]; ee=[]; tgd=[]; dop=[];

	% �ϑ���
	%--------------------------------------------
	switch est_prm.obsmodel
	case {0,3,4,5,6,7,8,9,10},		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���)
		Y = data(:,2);
	case 1,						% PY �R�[�h�[������
		Y = data(:,6);
	case 2,						% ionfree �[������(2���g)
		Y1=[]; Y2=[];
		if est_prm.n_nav ==1
			Y1 = [data(1:length(find(prn<=32)),2) data(1:length(find(prn<=32)),6)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
		end
		if est_prm.g_nav ==1
			Y2 = [freq.r1.*data(length(prn(find(prn<=32)))+1:end,2)-freq.r2.*data(length(prn(find(prn<=32)))+1:end,6)]./(freq.r1.^2-freq.r2.^2);
		end
		Y = [Y1; Y2];
	end

	% �ϑ����f��(�ϑ��ʁE���f���E�ϑ��G��etc)
	%--------------------------------------------
	[h,H,R,ele,azi,rho,dtsv,ion,trop]=...
			measuremodel_pp(freq,time,prn,eph_prm,ephi,ion_prm,est_prm,x);

	% �c�����ɒ[�ɑ傫���q�������O
	%--------------------------------------------
% 	if loop>2, rej=prn(find(Y-h>20));, rej=union(rejd,rej);, end

	% �g�p�q�����̒��o
	%--------------------------------------------
	ii = find(~isnan(Y+h) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);		% Y, h �� NaN �̂Ȃ���� index & �p�}�X�N�J�b�g
  
     if Y+h==4.078879943981164
         ii=1;
     end
    H  = H(ii,:);																% observation matrix(ii ��)
	Y  = Y(ii);																		% observation(ii��)
	h  = h(ii);																		% observation model(ii��)
	R  = R(ii,ii);																	% observation noise(ii��)
	prn_u = prn(ii);																% PRN(ii��)

	% �q������4�����̏ꍇ
	%--------------------------------------------
	if length(prn_u) < 4
		 x(:) = NaN; dtr=NaN; dop=NaN;
		break
	end

	% (�d�ݕt)�ŏ����@
	%--------------------------------------------
	xk = x;
	x  = x + inv(H'*inv(R)*H)*H'*inv(R)*(Y-h);										% ���K������+�t�s��(LU?)
% 	x  = x + (H'*inv(R)*H)\(H'*inv(R)*(Y-h));										% ���K������+�K�E�X�����@
% 	B=chol(H'*inv(R)*H); x=x+B\(B'\(H'*inv(R)*(Y-h)));								% ���K������+�R���X�L����
	dtr = x(4)/C;																	% receiver clock error [sec.]

	dop=sqrt(trace(inv(H(:,1:3)'*H(:,1:3))));

	if loop>10, break, end

% 	h=measuremodel_pp(time,prn,eph_prm,ephi,ion_prm,est_prm,x);		% ����c��
% 	if sqrt(mean((Y-h(ii)).^2))<0.5, break, end										% ��������(�c����RMS�𗘗p)
end



%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

function [h,H,R,ele,azi,rho,dtsv,ion,trop]=measuremodel_pp(freq,time,prn,eph_prm,ephi,ion_prm,est_prm,x)
%-------------------------------------------------------------------------------
% �ϑ����f���̐���(h,H,R)
%
% [argin]
% freq     : ���g���̍\����(*.g1, *.g2, *.r1, *.r2)
% time     : �������̍\����(*.tod, *.week, *.tow, *.mjd, *.day)
% prn      : �q��PRN�ԍ�
% eph_prm  : �G�t�F�����X(*.brd, *.sp3)
% ephi     : �e�q���̍œK�ȃG�t�F�����X�̃C���f�b�N�X
% ion_prm  : �d���w�p�����[�^
% est_prm  : �ݒ�p�����[�^
% x        : ��ԕϐ�
% 
% [argout]
% h        : �ϑ����f���x�N�g��
% H        : �ϑ��s��
% R        : �ϑ��G��
% ele      : �p(select_prn�ɕK�v���v����)
% azi      : ���ʊp
% rho      : �􉽊w�I����
% dtsv     : �q�����v�덷
% ion      : �d���w�x��
% trop     : �Η����x��
% 
% �� geodist3, geodist_sp33, azel, cal_ion2, cal_trop�̊֐����K�v
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------
% GLONASS�Ή�
% August 6, 2009, T.Yanase
%-------------------------------------------------------------------------------

% �萔(�O���[�o���ϐ�)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- �萔
%--------------------------------------------
C=299792458;							% ����

OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

dtr=x(4)/C;																	% ��M�@���v�덷

num=length(prn);															% �q����
num_g=length(find(prn<=32));												% �q����(GPS)
num_r=length(find(38<=prn));												% �q����(GLONASS)
I=ones(num,1);																% 1 �x�N�g��
O=zeros(num,1);																% 0 �x�N�g��
OO=zeros(num);																% 0 �s��
II=eye(num);																% �P�ʍs��
II_g=eye(num_g);
II_r=eye(num_r);

% ������
%--------------------------------------------
rho=repmat(NaN,num,1); sat_xyz=repmat(NaN,num,3);
sat_xyz_dot=repmat(NaN,num,3); dtsv=repmat(NaN,num,1); 
tgd=repmat(NaN,num,1); ion=repmat(NaN,num,1); trop=repmat(NaN,num,1);
azi=repmat(NaN,num,1); ele=repmat(NaN,num,1); ee=repmat(NaN,num,3); 
HHs=zeros(num,3*num);

% �􉽊w�I����, �p, ���ʊp, �d���w, �Η����̌v�Z
%--------------------------------------------
for k = 1:num
	% �􉽊w�I����(������/������)
	%--------------------------------------------
	[rho(k,1),sat_xyz(k,:),sat_xyz_dot(k,:),dtsv(k,:)]=...
			geodist_mix2(time,eph_prm,ephi,prn(k),x,dtr,est_prm);

	tgd(k,:) = eph_prm.brd.data(33,ephi(prn(k)));
	
	% �p, ���ʊp, �Δ����W���̌v�Z
	%--------------------------------------------
	[ele(k,1), azi(k,1), ee(k,:)]=azel(x, sat_xyz(k,:));

	% �d���w�x�� & �Η����x��
	%--------------------------------------------
	ion(k,1)  = cal_ion2(time,ion_prm,azi(k),ele(k),x,est_prm.i_mode);		% ionospheric model
	trop(k,1) = cal_trop(ele(k),x,sat_xyz(k,:)',est_prm.t_mode);			% tropospheric model
end

% �ϑ��G���p
%--------------------------------------------
for k=1:num, HHs(k,3*k-2:3*k)=ee(k,:);, end									% �Δ����W��

EE = I;
if est_prm.ww==1, EE=(1./sin(ele).^2);, end									% �p�ɂ��d��

PR1  = repmat(est_prm.obsnoise.PR1,num,1).*EE;								% CA�̕��U
PR2  = repmat(est_prm.obsnoise.PR2,num,1).*EE;								% PY�̕��U
CLK  = repmat(est_prm.obsnoise.CLK,num,1).*EE;								% �q�����v�̕��U
ION1 = repmat(est_prm.obsnoise.ION,num,1).*EE;								% �d���w�̕��U
TRP  = repmat(est_prm.obsnoise.TRP,num,1).*EE;								% �Η����̕��U
ORB  = repmat(est_prm.obsnoise.ORB,num,1).*EE;								% �q���O���̕��U

% �ϑ����f���쐬(h,H,R)
%--------------------------------------------
switch est_prm.obsmodel
case {0,3,4,5,6,7,8,9,10},
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
				+trop(1:num_g)+ion(1:num_g);								% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
				+C*(dtr-dtsv(num_g+1:num_g+num_r))...
				+trop(num_g+1:num_g+num_r)+ion(num_g+1:num_g+num_r);		% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																% observation matrix
	TT = [II HHs II -II -II];												% �G���̌W���s��쐬
	RR = diag([PR1; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';														% �G���̋����U�s��쐬
case 1,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)...
				+C*(dtr-(dtsv(1:num_g)-(freq.g1/freq.g2)^2*tgd(1:num_g)))...
				+trop(1:num_g)+(freq.g1/freq.g2)^2*ion(1:num_g);			% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
				+C*(dtr-dtsv(num_g+1:num_g+num_r))...
				+trop(num_g+1:num_g+num_r)...
				+(freq.r1./freq.r2).^2.*ion(num_g+1:num_g+num_r);			% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																% observation matrix
	TT = [II HHs II blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2)) -II];							% �G���̌W���s��쐬
	RR = diag([PR2; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';														% �G���̋����U�s��쐬
case 2,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g);				% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
				+C*(dtr-dtsv(num_g+1:num_g+num_r))...
				+trop(num_g+1:num_g+num_r);									% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																% observation matrix
	TT = [blkdiag(freq.g1^2/(freq.g1^2-freq.g2^2)*II_g, diag(freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-freq.g2^2/(freq.g1^2-freq.g2^2)*II_g, diag(-freq.r2.^2./(freq.r1.^2-freq.r2.^2))) HHs II -II];	% �G���̌W���s��쐬
	RR = diag([PR1; PR2; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';														% �G���̋����U�s��쐬
end
