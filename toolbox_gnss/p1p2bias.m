function bias = p1p2bias(time,PRN)
%-------------------------------------------------------------------------------
% Function : P1-P2�o�C�A�X
%
% [argin]
% PRN  : �q��PRN�ԍ�
% time : ����
%
% [argout]
% bias : P1-P2�o�C�A�X[m](data_bias�̗v�f��[ns])
% 
% �� ��͂��������ɉ����Ďg�������邱��.
%    ftp://ftp.unibe.ch/aiub/CODE/ ��DCB�̃t�@�C���͂���܂�.
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

persistent data_bias

% �萔(�O���[�o���ϐ�)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- �萔
%--------------------------------------------
C=299792458;							% ����
f1=1.57542e9;  lam1=C/f1;				% L1 ���g�� & �g��
f2=1.22760e9;  lam2=C/f2;				% L2 ���g�� & �g��

OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

%--- P1P2DCB�擾
%--------------------------------------------
if isempty(data_bias)
	% �t�@�C���I�[�v��
	%--------------------------------------------
	dirs=[fileparts(which('p1p2bias')),'/P1P2DCB/'];					% �f�B���N�g��
	filen=sprintf('%sP1P2%02d%02d.DCB',dirs,mod(time(1),100),time(2));	% �t�@�C����
	fpo=fopen(filen,'rt');												% �t�@�C���I�[�v��

	if fpo~=-1
		% �w�b�_�[��(�ǂݔ�΂�)
		%--------------------------------------------
		for i=1:7
			temp = fgetl(fpo);											% 1�s�擾
		end

		% �f�[�^��
		%--------------------------------------------
		data_bias(1:32,1:3)=0;											% �z��̏���(�����l��0)
		while 1
			temp = fgetl(fpo);											% 1�s�擾

			% �I������(temp����̏ꍇ)
			%--------------------------------------------
			if isempty(temp), break;, end

			% �I������(EOF�̏ꍇ)
			%--------------------------------------------
			if feof(fpo), break;, end

			% �f�[�^�擾
			%--------------------------------------------
			if temp(1)=='G'												% GPS�̂�
				data=str2num(temp(2:end));
				data_bias(data(1),:)=data;								% �f�[�^�i�[
			end
		end
	else
		data_bias(1:32,1:3)=0;
	end
end

bias = C*(data_bias(PRN,2))*1e-9;										% �����ɕϊ�
