function Y=obs_vec(data,prn,obsmodel)
%-------------------------------------------------------------------------------
% Function : �ϑ��ʂ̍쐬
% 
% [argin]
% data      : �ϑ��f�[�^
% prn       : �q��PRN�ԍ�
% obs_model : �ϑ����f��
% 
% [argout]
% Y         : �ϑ��ʃx�N�g��
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

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

switch obsmodel
case 0,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���)
	Y = data(:,2);
case 1,		% PY �R�[�h�[������
	Y = data(:,6);
case 2,		% ionfree �ϑ���(2���g�[������)
	Y = [data(:,2) data(:,6)]*[f1^2; -f2^2]/(f1^2-f2^2);
case 3,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1 �����g�ʑ�
	Y1 = data(:,2);
	Y2 = lam1*data(:,1);
	Y = [Y1; Y2];
case 4,		% ionfree �ϑ���(1���g�[������ & �����g)
	Y = 0.5*(data(:,2) + lam1*data(:,1));
case 5,		% ionfree �ϑ���(2���g�����g)
	Y = [lam1*data(:,1) lam2*data(:,5)]*[f1^2; -f2^2]/(f1^2-f2^2);
case 6,		% CA,PY �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1,L2 �����g�ʑ�
	Y1 = data(:,2);
	Y2 = lam1*data(:,1);
	Y3 = data(:,6);
	Y4 = lam2*data(:,5);
	Y = [Y1; Y3; Y2; Y4];
case 7,		% ionfree �ϑ���(1���g�[������ & �����g)
	Y1 = 0.5*(data(:,2) + lam1*data(:,1));
	Y2 = 0.5*(data(:,6) + lam2*data(:,5));
	Y = [Y1; Y2];
case 8,		% ionfree �ϑ���(2���g�[������ & �����g)
	Y1 = [data(:,2) data(:,6)]*[f1^2; -f2^2]/(f1^2-f2^2);
	Y2 = [lam1*data(:,1) lam2*data(:,5)]*[f1^2; -f2^2]/(f1^2-f2^2);
	Y = [Y1; Y2];
case 9,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1,L2 �����g�ʑ�
	Y1 = data(:,2);
	Y2 = lam1*data(:,1);
	Y3 = lam2*data(:,5);
	Y = [Y1; Y2; Y3];
end
