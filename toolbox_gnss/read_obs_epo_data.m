function [time, no_sat, prn, dtrec, ephi, data] = read_obs_epo_data(fpo, Eph_mat, no_obs, TYPES)
%-------------------------------------------------------------------------------
% Function : �G�|�b�N��� & �ϑ��f�[�^�擾
% 
% [argin]
% fpo     : obs �t�@�C���|�C���^
% Eph_mat : �G�t�F�����X
% no_obs  : �ϑ��f�[�^��
% TYPES   : �f�[�^�̕���
% 
% [argout]
% time    : �������̍\����(*.tod, *.week, *.tow, *.mjd, *.day)
% no_sat  : �ϑ��q����
% prn     : �q���ԍ�
% dtrec   : ��M�@���v�덷
% ephi    : �e�q���̍œK�ȃG�t�F�����X�̃C���f�b�N�X
% data    : �ϑ��f�[�^(PRN��, L1, C1, P1, D1, L2, P2, D2, S1, S2)
% 
% �q���V�X�e���̎�ʂ��o�͂���悤�ɕύX(20070904 Fujita)
% 
% �q������ "0" �̂Ƃ�, �ēx�G�|�b�N��͂�����悤�ɕύX���f�[�^��������Α��ʂł��Ȃ�����
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 06, 2008
%-------------------------------------------------------------------------------

% �����l
%--------------------------------------------
time=[];, no_sat=[];, neg_sat=[];, neg_sat_num=[];, prn=[];, dtrec=[];, ef=[];, sys=[];, ephi=[];, data=[];

while 1
	temp = fgetl(fpo);														% 1�s�擾

	% �I������(temp����̏ꍇ)
	%--------------------------------------------
	if isempty(temp), break;, end

	% �I������(EOF�̏ꍇ)
	%--------------------------------------------
	if feof(fpo), break;, end

	% 1 �s�� 80 �����̃x�N�g���ɕύX
	%--------------------------------------------
	for i=1:(80-size(temp,2)), temp=[temp ' '];, end

	%--------------------------------------------
	% �C�x���g�t���O�̊m�F
	%
	%	Event flag (Epoch flag > 1)
	%			== 2: start moving anntenna
	%			== 3: new site occupation
	%			== 4: header information follows
	%			== 5: external event
	%			== 6: cycle slip records
	%
	%			�����_�ł� 4 �ɂ̂ݑΉ�
	%
	%	�Q�l���� Liner Algebra Geodesy, and GPS
	%				G. Strang, K. Borre
	%--------------------------------------------
	ef = str2num(temp(27:29));
	if ef == 4
		c_line = str2num(temp(30:32));										% �R�����g�s�̐�
		for i=1:c_line
			temp = fgetl(fpo);
			fprintf('%s \n',temp)											% �ǂݔ�΂����R�����g�s�̕\��
		end
		temp = fgetl(fpo);													% �R�����g�s�̎��̍s�̓ǂݏo��
		for i=1:(80 - size(temp,2))
			temp = [temp ' '];
		end
	end

	% �������
	%--------------------------------------------
	time.day = str2num(temp(1:26));											% �N, ��, ��, ��, ��, �b
	if time.day(1) < 80														% 2079�N�܂őΉ�
		time.day(1) = time.day(1) + 2000;
	elseif time.day(1) >= 80
		time.day(1) = time.day(1) + 1900;
	end

	time.mjd = mjuliday(time.day);											% �����E�X��v�Z
	[time.week, time.tow] = weekf(time.mjd);								% �T�ԍ�,�T�b�̌v�Z
	time.tod = round(time.day(4)*3600 + time.day(5)*60 + time.day(6));		% ToD

	no_sat = str2num(temp(30:32));											% �q����	I3

	% �q������ "0" �łȂ��ꍇ�̓f�[�^���i�[���� Break
	% �G�|�b�N���݂̂ŉq������ "0" �̂Ƃ��͍ēx�Ǎ�
	%--------------------------------------------
	if no_sat ~= 0
		% PRN
		%--------------------------------------------
		neg_sat = [];
		ephi = repmat(NaN,1,32);
		neg_sat_num = 0;

		dtrec  = str2num(temp(69:80));										% ��M�@���v�덷
		if isempty(dtrec), dtrec=NaN;, end

		prn = zeros(1,no_sat);
		sys = zeros(1,no_sat);
		p=33;
		for k=1:no_sat
			if k==13
				temp=fgetl(fpo); p=33;										% �G�|�b�N��񐔂�2�s�ɂ܂�����Ƃ�
			end
			prn(k)=sscanf(temp(p+1:min(p+1+2-1,length(temp))),'%f');		% �q���ԍ����擾(�����񁨐����ɕϊ�)
			SYS=temp(p);													% �q���V�X�e�����擾
			if ~isempty(findstr(SYS,'G')), SYS=1;, end
			if ~isempty(findstr(SYS,'R')), SYS=2;, end
			if ~isempty(findstr(SYS,'S')), SYS=3;, end
			sys(k) = SYS;
			ephi(prn(k)) = eph_search(Eph_mat, prn(k), time);
			if ephi(prn(k)) == 0											% �G�t�F�����X�̖����q�����J�E���g
				neg_sat_num = neg_sat_num + 1;
				neg_sat = [neg_sat; k];										% �G�t�F�����X�̖����q���̈ʒu�i�[
				ephi(prn(k))=NaN;
			end
			p=p+3;															% ���̉q���̂���
		end

		% �ϑ��f�[�^�ǂݍ���
		%--------------------------------------------
		data = read_obs(fpo, no_obs, no_sat, neg_sat, TYPES);

		% �œK�ȃG�t�F�����X�̖����q�������O
		%--------------------------------------------
		if ~isempty(neg_sat)
			data(neg_sat,:)=[]; prn(neg_sat)=[]; sys(neg_sat)=[];
		end

		%--- GPS�̂ݗ��p(SBAS�͏��O)
		%--------------------------------------------
		data(find(sys==3),:)=[]; prn(find(sys==3))=[]; 
		data(find(prn>32),:)=[]; prn(find(prn>32))=[]; no_sat=length(prn);
		data(:,2) = data(:,2) + p1c1bias(time.day,prn);						% P1C1 DCB �␳

		if no_sat~=0, break;, end
	end
end



%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

function column = eph_search(Eph_mat,prn,tt)
%-------------------------------------------------------------------------------
% eph_search: eph_read �ō쐬���ꂽ Eph_mat �s�񂩂�K�؂ȗ��I������
%
% [argin]
% Eph_mat : �G�t�F�����X�f�[�^
% prn     : �w��q���ԍ�
% tt      : �������(day,tod,week,tow,mjd)
% 
% [argout]
% column: �^����ꂽ�q���ԍ��Ǝ����ōœK�� Eph_mat �̗�ԍ�
%
% �G�t�F�����X�L�����Ԃ̐ݒ肪�K�v(�G�t�F�����X�X�V�������q��������ƌ덷�����傷�邽��)
%
% �w���X�̃`�F�b�N�����̊֐����ł���悤�ɕύX
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 12, 2008
%-------------------------------------------------------------------------------

% New version
column = 0;															% �C���f�b�N�X�̏����l
index = find(Eph_mat(1,:)==prn);									% �q��PRN �ɑ΂���G�t�F�����X�̗�C���f�b�N�X
if isempty(index), return;, end										% �œK�ȃG�t�F�����X�������ꍇ�͏I��
ttm=Eph_mat(35,index);												% �G�t�F�����X���M����(tow)
index=index(find(ttm<=tt.tow));										% �G�t�F�����X���M�������G�|�b�N�������ȑO�̃C���f�b�N�X
if isempty(index), return;, end										% �œK�ȃG�t�F�����X�������ꍇ�͏I��
toe=Eph_mat(19,index);												% �O������(tow)
week=Eph_mat(29,index);												% �T�ԍ�
dt=abs((week-tt.week)*7*86400+(toe-tt.tow));						% �O�������Ƃ̎��ԍ��̐�Βl(tow�𗘗p, week���l��)
[mm,imin]=min(dt);													% �ŋߓ_�̃C���f�b�N�X(index�̒���)

fit=Eph_mat(36,index(imin))/2;										% �G�t�F�����X�L�����ԁ}[h]
if isnan(fit), fit=2;, end											% �G�t�F�����X�L�����ԁ}2[h](�L�ڂ���Ă��Ȃ��ꍇ)

if mm<=fit*3600														% �L�����Ԉȓ��ɂ��邩�ǂ����̔���
	column=index(imin);												% �ŋߓ_�̃C���f�b�N�X(�G�t�F�����X�̒���)
end
if column~=0
	if Eph_mat(32,column)~=0										% �q���̃w���X���`�F�b�N
		column=0;													% �œK�ȃG�t�F�����X�������Ƃ���
	end
end



function data = read_obs(fpo, no_obs, no_sat, neg_sat, TYPES)
%-------------------------------------------------------------------------------
% obsrvation �t�@�C������ϑ��f�[�^�擾
% 
% [argin]
% fpo     : obs �t�@�C���|�C���^
% no_obs  : �ϑ��f�[�^��
% no_sat  : �ϑ��q����
% neg_sat : �G�t�F�����X�̂Ȃ��q���̈ʒu
% TYPES   : �f�[�^�̕���
% 
% [argout]
% data : �ϑ��f�[�^(PRN��, L1, C1, P1, D1, L2, P2, D2, S1, S2)
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 16, 2007
%-------------------------------------------------------------------------------

% �ϑ��f�[�^�ǂݍ���
%--------------------------------------------
Data = repmat(NaN,no_sat,no_obs);									% �z��̏���(NaN�Ŗ��߂�)
for i = 1 : no_sat
	if find(i==neg_sat)												% �G�t�F�����X�̖����q���̊ϑ��f�[�^�ǂݔ�΂�
		if no_obs <= 5
			temp = fgetl(fpo);
		elseif no_obs > 5
			temp=fgetl(fpo);
			temp=fgetl(fpo);
		end
	else															% �G�t�F�����X�̂���q���̊ϑ��f�[�^
		temp = fgetl(fpo); k=1;
		for j=1:no_obs
			if j==6
				temp=fgetl(fpo); k=1;								% �ϑ��f�[�^����2�s�ɂ܂�����Ƃ�
			end
			s=sscanf(temp(k:min(k+14-1,length(temp))),'%f');		% �ϑ��f�[�^���擾(�����񁨐����ɕϊ�)
			if ~isempty(s)
				Data(i,j)=s; k=k+16;								% �ϑ��f�[�^�i�[
			end
		end
	end
end

% "o" �̃f�[�^�� "dat" ̫�ϯĂ̂ǂ��ɓ��邩�H
%--------------------------------------------
for k = 1 : 2 : size(TYPES,2)
	t = findstr('L1C1P1D1L2P2D2S1S2T1T2', TYPES(k:k+1));
	t = (t+1)/2;
	map((k+1)/2) = t;
end

% data �̕��� --> L1, C1, P1, D1, L2, P2, D2, S1, S2
%--------------------------------------------
data = [];
for i = 1:9
	dat_ind = find(map==i);
	if ~isempty(dat_ind)
		data(:,i) = Data(:,dat_ind);
	else
		data(:,i) = NaN;
	end
end
