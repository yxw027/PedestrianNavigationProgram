function [Y,H,h,R,x_p,P_p,prn_u]=select_prn(Y,H,h,R,x_p,P_p,prn,est_prm,ele,rej,nx,~)
%-------------------------------------------------------------------------------
% Function : �g�p�q�����̒��o
% 
% [argin]
% Y       : �ϑ���
% H       : �ϑ��s��
% h       : �ϑ����f���x�N�g��
% R       : �ϑ��G��
% x_p     : ��ԕϐ�
% P_p     : �����U
% prn     : �q��PRN
% est_prm : �ݒ�p�����[�^
% ele     : �p
% rej     : ���O�q��
% nx      : ��ԕϐ��̎���
% 
% [argout]
% Y       : �ϑ���
% H       : �ϑ��s��
% h       : �ϑ����f���x�N�g��
% R       : �ϑ��G��
% x_p     : ��ԕϐ�
% P_p     : �����U
% prn_u   : �g�p�q��PRN
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%--------------------------------------------------------------------------
%----- 
%INSNOISE  = repmat(est_prm.obsnoise.INS,3,1);
num=length(prn);		% �q����
nx.p=nx.u+nx.t+nx.b+nx.T+nx.i;

if find([0,1,2,10]==est_prm.obsmodel)
	ii = find(~isnan(Y+h) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
    if (length(ii) < 30 && est_prm.sensormixmode == 2)
        %ii = find(~isnan(Y+h) & ele*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X���đI��
        H  = H(ii,:);
        Y  = Y(ii);
        h  = h(ii);
        %�ϑ��s��̊g��
        %Hsize = size(H);
        %H = [H;
        %1,0,0,zeros(1,Hsize(2) - 3);
        %0,1,0,zeros(1,Hsize(2) - 3);
        %0,0,1,zeros(1,Hsize(2) - 3)];
        %Y = [Y;INS(1:3)'];
		R  = R(ii,ii);					% observation noise(ii��)
        %Rsize = size(R);
        %EE=(1./sin(ele).^2);
        %R = [R,zeros(Rsize(1),3);zeros(3,Rsize(2)),[est_prm.obsnoise.SENSOR_E,0,0;0,est_prm.obsnoise.SENSOR_N,0;0,0,est_prm.obsnoise.SENSOR_U]];
    else
        H  = H(ii,:);																				% observation matrix(ii ��)
        Y  = Y(ii);																					% observation(ii��)
        h  = h(ii);																					% observation model(ii��)
        R  = R(ii,ii);																				% observation noise(ii��)
    end
	prn_u = prn(ii);																			% PRN(ii��)
end
if est_prm.obsmodel == 3
	Y1 = Y(1:num);  Y2 = Y(num+1:end);
	H1 = H(1:num,:);  H2 = H(num+1:end,:);
	h1 = h(1:num);  h2 = h(num+1:end);
	ii = find(~isnan(Y1+Y2+h1+h2) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);			% ���p�\�ȉq���̃C���f�b�N�X
	H = [H1(ii,[1:nx.p,nx.p+ii']); H2(ii,[1:nx.p,nx.p+ii'])];									% observation matrix(ii ��)
	Y = [Y1(ii,:); Y2(ii,:)];																	% observation(ii��)
	h = [h1(ii,:); h2(ii,:)];																	% observation model(ii��)
	R  = R([ii',num+ii'],[ii',num+ii']);														% observation noise(ii��)
	prn_u = prn(ii);
end
if est_prm.obsmodel == 4
	ii = find(~isnan(Y+h) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
	H  = H(ii,[1:nx.p,nx.p+ii']);																% observation matrix(ii ��)
	Y  = Y(ii);																					% observation(ii��)
	h  = h(ii);																					% observation model(ii��)
	R  = R(ii,ii);																				% observation noise(ii��)
	prn_u = prn(ii);																			% PRN(ii��)
end
if est_prm.obsmodel == 5
	ii = find(~isnan(Y+h) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
	H  = H(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']);													% observation matrix(ii ��)
	Y  = Y(ii);																					% observation(ii��)
	h  = h(ii);																					% observation model(ii��)
	R  = R(ii,ii);																				% observation noise(ii��)
	prn_u = prn(ii);																			% PRN(ii��)
end
if est_prm.obsmodel == 6
	Y1 = Y(1:num);  Y2 = Y(num+1:2*num);  Y3 = Y(2*num+1:3*num);  Y4 = Y(3*num+1:end);
	H1 = H(1:num,:);  H2 = H(num+1:2*num,:);  H3 = H(2*num+1:3*num,:);  H4 = H(3*num+1:end,:);
	h1 = h(1:num);  h2 = h(num+1:2*num);  h3 = h(2*num+1:3*num);  h4 = h(3*num+1:end);
	ii = find(~isnan(Y1+Y2+Y3+Y4+h1+h2+h3+h4) & ...
					ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);							% ���p�\�ȉq���̃C���f�b�N�X
	Y = [Y1(ii,:); Y2(ii,:); Y3(ii,:); Y4(ii,:)];												% observation(ii��)
	h = [h1(ii,:); h2(ii,:); h3(ii,:); h4(ii,:)];												% observation model(ii��)
    if length(ii) < 4
        H = [H1(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H2(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']);
	     H3(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H4(ii,[1:nx.p,nx.p+ii',nx.p+num+ii'])];			% observation matrix(ii ��)
        %�ϑ��s��̊g��
        Hsize = size(H);
        H = [H;
        1,0,0,zeros(1,Hsize(2) - 3);
        0,1,0,zeros(1,Hsize(2) - 3);
        0,0,1,zeros(1,Hsize(2) - 3)];
        Y = [Y;INS(1:3)'];
		R = R([ii',num+ii',2*num+ii',3*num+ii'],[ii',num+ii',2*num+ii',3*num+ii']);					% observation noise(ii��)
        Rsize = size(R);
        %EE=(1./sin(ele).^2);
        R = [R,zeros(Rsize(1),3);zeros(3,Rsize(2)),[est_prm.obsnoise.SENSOR_X,0,0;0,est_prm.obsnoise.SENSOR_Y,0;0,0,est_prm.obsnoise.SENSOR_Z]];
    else
        H = [H1(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H2(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']);
             H3(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H4(ii,[1:nx.p,nx.p+ii',nx.p+num+ii'])];			% observation matrix(ii ��)
        R = R([ii',num+ii',2*num+ii',3*num+ii'],[ii',num+ii',2*num+ii',3*num+ii']);					% observation noise(ii��)
    end
	prn_u = prn(ii);
end
if est_prm.obsmodel == 7
	Y1 = Y(1:num);  Y2 = Y(num+1:2*num);
	H1 = H(1:num,:);  H2 = H(num+1:2*num,:);
	h1 = h(1:num);  h2 = h(num+1:2*num);
	ii = find(~isnan(Y1+Y2+h1+h2) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);			% ���p�\�ȉq���̃C���f�b�N�X
	H = [H1(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H2(ii,[1:nx.p,nx.p+ii',nx.p+num+ii'])];			% observation matrix(ii ��)
	Y = [Y1(ii,:); Y2(ii,:)];																	% observation(ii��)
	h = [h1(ii,:); h2(ii,:)];																	% observation model(ii��)
	R = R([ii',num+ii'],[ii',num+ii']);															% observation noise(ii��)
	prn_u = prn(ii);																			% PRN(ii��)
end
if est_prm.obsmodel == 8
	Y1 = Y(1:num);  Y2 = Y(num+1:2*num);
	H1 = H(1:num,:);  H2 = H(num+1:2*num,:);
	h1 = h(1:num);  h2 = h(num+1:2*num);
	ii = find(~isnan(Y1+Y2+h1+h2) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);			% ���p�\�ȉq���̃C���f�b�N�X
	H = [H1(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H2(ii,[1:nx.p,nx.p+ii',nx.p+num+ii'])];			% observation matrix(ii ��)
	Y = [Y1(ii,:); Y2(ii,:)];																	% observation(ii��)
	h = [h1(ii,:); h2(ii,:)];																	% observation model(ii��)
	R = R([ii',num+ii'],[ii',num+ii']);															% observation noise(ii��)
	prn_u = prn(ii);																			% PRN(ii��)
end
if est_prm.obsmodel == 9
	Y1 = Y(1:num);  Y2 = Y(num+1:2*num);  Y3 = Y(2*num+1:3*num);
	H1 = H(1:num,:);  H2 = H(num+1:2*num,:);  H3 = H(2*num+1:3*num,:);
	h1 = h(1:num);  h2 = h(num+1:2*num);  h3 = h(2*num+1:3*num);
	ii = find(~isnan(Y1+Y2+Y3+h1+h2+h3) & ...
					ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);							% ���p�\�ȉq���̃C���f�b�N�X
	H = [H1(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']); H2(ii,[1:nx.p,nx.p+ii',nx.p+num+ii']);
	     H3(ii,[1:nx.p,nx.p+ii',nx.p+num+ii'])];												% observation matrix(ii ��)
	Y = [Y1(ii,:); Y2(ii,:); Y3(ii,:)];															% observation(ii��)
	h = [h1(ii,:); h2(ii,:); h3(ii,:)];															% observation model(ii��)
	R = R([ii',num+ii',2*num+ii'],[ii',num+ii',2*num+ii']);										% observation noise(ii��)
	prn_u = prn(ii);
end

if find([3:9]==est_prm.obsmodel)
	index=[1:nx.p];
	for k=1:est_prm.freq, index=[index nx.p+ii'+num*(k-1)];, end								% �C���f�b�N�X����
	x_p=x_p(index);																				% ��������
	P_p=P_p(index,index);																		% ��������
end
