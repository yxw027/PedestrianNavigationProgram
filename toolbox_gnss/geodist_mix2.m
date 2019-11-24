function [rho,sat_xyz,sat_xyz_dot,dtsv] = geodist_mix(time, eph_prm, ephi, prn, x, dtr, est_prm)
%-------------------------------------------------------------------------------
% Function : �q���O���v�Z & �􉽊w�����v�Z(���H�����������)
%
% [argin]
% time        : �������̍\����(*.tod, *.week, *.tow, *.mjd, *.day)
% eph_prm     : �G�t�F�����X(*.brd, *.sp3)
% ephi        : �e�q���̍œK�ȃG�t�F�����X�̃C���f�b�N�X
% prn         : �q��PRN�ԍ�
% x           : ��ԕϐ�
% dtr         : ��M�@���v�덷
% est_prm     : �����ݒ�p�����[�^
% 
% [argout]
% rho         : �􉽊w����
% sat_xyz     : �q�����W
% sat_xyz_dot : �q�����x
% dtsv        : �q�����v�덷
% 
% ������/������̂ǂ���ɂ��Ή�
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% GLONASS�Ή�
% July 10, 2009, T.Yanase
%-------------------------------------------------------------------------------

% argout�̒l�̏����l��NaN��ݒ�
%--------------------------------------------
rho=NaN;,sat_xyz(1:3)=NaN;,sat_xyz_dot(1:3)=NaN;,dtsv=NaN;

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

% �q���O��, �􉽊w�����v�Z
%--------------------------------------------
rho  = 2e7;
rhok = 0;
Eph_mat=eph_prm.brd.data(:,ephi(prn));
Data_sp3=eph_prm.sp3.data;
degree=9;
while abs(rho-rhok) > 1e-4
	if est_prm.sp3==0
		[sat_xyz,sat_xyz_dot,dtsv]=...
				sat_pos2(time.day,Eph_mat,rho,dtr,est_prm);				% �q���O��, �q�����v�v�Z
	elseif est_prm.sp3 == 1
		[sat_xyz,sat_xyz_dot,dtsv]=...
				interp_lag(time.day,Data_sp3,prn,rho,dtr,degree);		% IGS(sp3) �f�[�^���(�V�o�[�W����)
	end
	Rz = [ cos(OMGE*rho/C),sin(OMGE*rho/C),0;
		  -sin(OMGE*rho/C),cos(OMGE*rho/C),0;
		                 0,              0,1];							% ��]�␳
% 	if est_prm.simu == 0;												% �V�~�����[�V���� [0:OFF, 1:ON]
% 		[sat_xyz, sat_xyz_dot, dtsv]=...
% 				sat_pos(time.day, Eph_mat, rho*0, dtr*0);				% �V�~�����[�V�����p
% 		Rz=eye(3);														% �V�~�����[�V�����p(��]�␳����)
% 	end
	rrs  = x(1:3) - Rz*sat_xyz';
	rhok = rho;															% �􉽊w����(1�O�̃��[�v)
	rho = norm(rrs);													% �􉽊w����(�����[�v)
end
if est_prm.sp3 == 1
% 	dtsv = dtsv - 2*sat_xyz*sat_xyz_dot'/C^2;										% ���ꑊ�Θ_�␳
% 	dtsv = dtsv - 2*dot(sat_xyz',sat_xyz_dot')/C^2;									% ���ꑊ�Θ_�␳
% 	dtsv = dtsv - 2*sat_xyz*(sat_xyz_dot+cross([0,0,OMGE],sat_xyz))'/C^2;			% ���ꑊ�Θ_�␳
	dtsv = dtsv - 2*dot(sat_xyz',(sat_xyz_dot'+cross([0,0,OMGE]',sat_xyz')))'/C^2;	% ���ꑊ�Θ_�␳
end

if 37<prn
	sat_xyz=pz2xyz((Rz*sat_xyz')');										% �q���O��(GLONASS)(��]�␳��)
else
	sat_xyz=(Rz*sat_xyz')';												% �q���O��(GPS)(��]�␳��)
end
