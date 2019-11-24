function [Data] = read_sp3(sp3_file)
%-------------------------------------------------------------------------------
% Function : ������(SP3)�f�[�^�ǂݍ��݃v���O����
%
% [argin]
% sp3_file : sp3�t�@�C����
%
% [argout]
% Data     : �q�����W�E�q�����v�덷�Ȃ�
%            [week,tow,tod,X,Y,Z,clk]���q�����Ƃɑ������Ŋi�[(page=PRN��)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

% sp3�t�@�C���̃I�[�v��
%--------------------------------------------
fporb = fopen(sp3_file);											% �f�[�^�t�@�C���̃I�[�v��(������)

% sp3�t�@�C���ǂݍ���(�w�b�_�[���擾)
%--------------------------------------------
temp = fgetl(fporb);												% 1�s�ړǂݔ�΂�

temp = fgetl(fporb);												% 2�s�ڎ擾
sp3_dt = str2num(temp(25:38));										% sp3�f�[�^�̍X�V�Ԋu�ǂݎ��

temp = fgetl(fporb);												% 3�s�ڎ擾
prn_num = str2num(temp(4:6));										% �q����

%	�v��Ȃ��w�b�_�����̓ǂݔ�΂�(4�`22�s��)
for i=4:22
	temp = fgetl(fporb);
end


% sp3�t�@�C���ǂݍ���(X,Y,Z,clk�̎擾)
%    �O��[km]��[m]�ɕϊ�
%    �q�����v�덷[��s]��[s]�ɕϊ�
%--------------------------------------------
timetag = 0;														% �^�C���^�O�����l

while 1

	timetag = timetag + 1;											% �^�C���^�O

	temp = fgetl(fporb);											% 1�s�ǂݍ���

	e_o_h = findstr(temp,'EOF');									% EOF�̌���
	if ~isempty(e_o_h)												% �I������
		break;
	end

	[tt temp] = strtok(temp);										% ������'*'�̕���(������)
	date = str2num(temp);											% �����̐�����
	ToD = round(date(4)*3600 + date(5)*60 + date(6));				% Time of Day

	mjd = mjuliday(date);											% �����E�X��

	[WEEK,ToW] = weekf(mjd);										% WEEK, Time of Week

	Data(timetag,1:7,1:32)=NaN;
	for ii = 1 : prn_num											% �S�q���̃f�[�^�擾
		temp = fgetl(fporb);
		data = str2num(temp(3:60))';								% PRN, X, Y, Z, CLK
		if data(5) == 999999.999999
			data(5)=NaN;
		end
		Data(timetag,:,data(1)) = ...
				[WEEK ToW ToD data(2:4)'*(10^3) data(5)*(10^(-6))];	% �f�[�^�i�[(�������z��)
	end

end
