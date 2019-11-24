function [sat_xyz, sat_xyz_dot, dtsv] = sat_pos(time, eph, rho, dtrec, est_prm)
%-------------------------------------------------------------------------------
% Function : pos_sat2: ���� t �ł� eph �ɑΉ�����q�����W�����߂�(�q�����x��)
%
% [argin]
% time    : observatoin �� [year month day hour min sec]
% eph     : Eph_mat ������o�����œK�ȃG�t�F�����X�f�[�^��
% rho     : �􉽊w�I����
% dtrec   : ��M�@���v�덷
% est_prm : �����ݒ�p�����[�^
%
% [argout]
% sat_xyz     : �q�����W
% sat_xyz_dot : �q�����x
% dtsv        : �q�����v�덷
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Bokukubo: April 25, 2001
%-------------------------------------------------------------------------------
% �`�����ԕ��̉�]�p�v�Z�������C��
% June 29, 2004, Y.Kubo
%
% �q���̑��x�v�Z��ǉ�
% November 20, 2006, S.Fujita
%
% ���ԍ��v�Z, �P�v���[������������
% Jan. 07, 2008, S.Fujita
%-------------------------------------------------------------------------------
% GLONASS�Ή�
% July 10, 2009, T.Yanase
%-------------------------------------------------------------------------------


if est_prm.n_nav==1 & eph(1)<=32

	%--- �萔
	%--------------------------------------------
	C=299792458;							% ����
	f1=1.57542e9;  lam1=C/f1;				% L1 ���g�� & �g��
	f2=1.22760e9;  lam2=C/f2;				% L2 ���g�� & �g��

	OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
	MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
	FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��


	%--- GPS �q�@���b�Z�[�W�̋O����p�����[�^
	%--------------------------------------------
	prn      = eph(1);						% �q�� PRN �ԍ�
	year     = eph(2);						% �N 
	month    = eph(3);						% �� 
	day      = eph(4);						% �� 
	hour     = eph(5);						% �� 
	min      = eph(6);						% �� 
	sec      = eph(7);						% �b 
	a0       = eph(8);						% �q�����v�o�C�A�X [s]
	a1       = eph(9);						% �q�����v�h���t�g [s/s]
	a2       = eph(10);						% �q�����v�h���t�g�� [s/s^2]
	iode     = eph(11);						% �O�����ԍ�
	crs      = eph(12);						% �O�����a�̐����␳�W�� [m]
	del_n    = eph(13);						% ���ω^���␳�l [rad/s]
	m0       = eph(14);						% �����̕��ϋߓ_�p [rad]
	cuc      = eph(15);						% �ܓx�����̗]���␳�W�� [rad]
	eee      = eph(16);						% �����S��
	cus      = eph(17);						% �ܓx�����̐����␳�W�� [rad]
	sqrt_a   = eph(18);						% ���O�������a�̕�����
	toe      = eph(19);						% �O���̌��� [sec of GPS week]
	cic      = eph(20);						% �O���X�Ίp�̗]���␳�W�� [rad]
	omega0   = eph(21);						% �����̏���_�ܓx [rad]
	cis      = eph(22);						% �ܓx�����̗]���␳�W�� [rad]
	i0       = eph(23);						% �����̋O���X�Ίp [rad]
	crc      = eph(24);						% �O�����a�̗]���␳�W�� [m]
	omega    = eph(25);						% �ߒn�_���� [rad]
	omegadot = eph(26);						% ����_�ܓx�̕ω��� [rad/s]
	idot     = eph(27);						% �O���X�Ίp�ω��� [rad/s]
	L2code   = eph(28);						% �t���O���
	week     = eph(29);						% �T�ԍ�
	L2data   = eph(30);						% �t���O���
	accu     = eph(31);						% �������x [m]
	% health   = eph(32);					% �q�����N���
	% tgd      = eph(33);					% �Q�x�� [s]
	iodc     = eph(34);						% �N���b�N���ԍ�
	ttm      = eph(35);						% ���M����
	fit      = eph(36);						% �t�B�b�g�Ԋu
	% spare    = eph(37);					% �\��
	% spare    = eph(38);					% �\��

	if year < 80												% 2079�N�܂őΉ�
		year = year + 2000;
	elseif year >= 80
		year = year + 1900;
	end

	a  = sqrt_a^2;
	n0 = sqrt(MUe/a^3);
	n  = n0+del_n;
	ek = m0;
	% dd = 1.0;

	tod = (time(4)*3600+time(5)*60+time(6))-(rho/C)-dtrec;							% ToD(�`�d����, ��M�@���v�덷���l��)
	mjdt=mjuliday(time(1:3));														% �G�|�b�N�����̏C�������E�X��
	tk=(mjdt-44244-week*7)*86400+tod - toe;											% ���ԍ�(t-toe) mjuliday([1980,1,6])=44244


	% �P�v���[��������藣�S�ߓ_�p�����߂�
	%--------------------------------------------
	mk=m0+n*tk;
	e=0; ek=mk;
	% while abs(e-ek)>1e-14
	% 	e=ek;
	% 	ek=mk+eee*sin(e);
	% end

	for i=1:20
		e=ek;
		ek=mk+eee*sin(e);
		if abs(e-ek)<1e-14, break;, end
	end


	% �q�����v�덷
	%--------------------------------------------
	tkc=(mjdt-mjuliday([year,month,day]))*86400 + tod-(hour*3600+min*60+sec);		% ���ԍ�(t-toc)
	dtsv=a0+a1*tkc+a2*tkc^2 - 2*sqrt(MUe*a)*eee*sin(ek)/C^2;						% �q�����v�덷 + ���Θ_���ʕ␳
	% dtsv=a0+a1*tkc+a2*tkc^2 - FF*eee*sqrt_a*sin(ek);								% �q�����v�덷 + ���Θ_���ʕ␳


	% �q���ʒu�֘A
	%--------------------------------------------
	vk = atan2((sqrt(1-eee*eee)*sin(ek)), ((cos(ek)-eee)));
	pk = vk + omega;
	uk = pk + cus*sin(2*pk) + cuc*cos(2*pk);
	rk = a*(1-eee*cos(ek))  + crs*sin(2*pk) + crc*cos(2*pk);
	ik = i0 + cis*sin(2*pk) + cic*cos(2*pk) + idot*tk;

	xdk = rk*cos(uk);
	ydk = rk*sin(uk);

	omegak = omega0+(omegadot-OMGE)*tk-OMGE*toe;
	% omegak = rem(omegak+2*pi,2*pi);

	sat_xyz(1) = xdk*cos(omegak) - ydk*cos(ik)*sin(omegak);
	sat_xyz(2) = xdk*sin(omegak) + ydk*cos(ik)*cos(omegak);
	sat_xyz(3) = ydk*sin(ik);


	% �q�����x�֘A
	%--------------------------------------------
	mkdot = n;
	ekdot = mkdot/(1-eee*cos(ek));
	vkdot = sin(ek)*ekdot*(1+eee*cos(vk))/(sin(vk)*(1-eee*cos(ek)));

	ukdot = vkdot +2.0*(cus*cos(2*uk)-cuc*sin(2*uk))*vkdot;
	rkdot = a*eee*sin(ek)*n/(1-eee*cos(ek)) + 2*(crs*cos(2*uk)-crc*sin(2*uk))*vkdot;
	ikdot = idot + (cis*cos(2*uk)-cic*sin(2*uk))*2*vkdot;

	xdkdot = rkdot*cos(uk) - ydk*ukdot;
	ydkdot = rkdot*sin(uk) + xdk*ukdot;

	omegakdot = (omegadot-OMGE);

	sat_xyz_dot(1) = (xdkdot-ydk*cos(ik)*omegakdot)*cos(omegak)...
						 - (xdk*omegakdot+ydkdot*cos(ik)-ydk*sin(ik)*ikdot)*sin(omegak);
	sat_xyz_dot(2) = (xdkdot-ydk*cos(ik)*omegakdot)*sin(omegak)...
						 + (xdk*omegakdot+ydkdot*cos(ik)-ydk*sin(ik)*ikdot)*cos(omegak);
	sat_xyz_dot(3) = ydkdot*sin(ik) + ydk*cos(ik)*ikdot;
end



if est_prm.g_nav==1 & 37<=eph(1)

	%--- �萔
	%--------------------------------------------
	C=299792458;							% ����
	% f1=1.57542e9;  lam1=C/f1;				% L1 ���g�� & �g��
	% f2=1.22760e9;  lam2=C/f2;				% L2 ���g�� & �g��

	OMGE=7.292115e-5;						% PZ-90 �̗p�n����]�p���x [rad/s]
	MUe=398600.44e9;						% PZ-90 �̒n�S�d�͒萔 [m^3s^{-2}]
	% FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

	% u = 398600.44e9			% [m^3/s^2] Gravitational constant
	a = 6378136;				% [m] Semi-major axis of Earth�O�������a
	J0 = 1082625.7e-9;			% Second zonal harmonic of the geopotential�n���d�̓|�e���V�����W��
	% w = 7.292115e-5			% [radian/s] Earth rotation rate�n�����]�p���x


	%--- GLONASS �q�@���b�Z�[�W�̋O����p�����[�^
	%--------------------------------------------
	prn      = eph(1);						% �q�� PRN �ԍ�
	year     = eph(2);						% �N 
	month    = eph(3);						% �� 
	day      = eph(4);						% �� 
	hour     = eph(5);						% �� 
	min      = eph(6);						% �� 
	sec      = eph(7);						% �b 
	dtsv = eph(8);
	sat_xyz(1) = eph(11)*10^3;
	sat_xyz(2) = eph(15)*10^3;
	sat_xyz(3) = eph(19)*10^3;
	sat_xyz_dot(1) = eph(12)*10^3;
	sat_xyz_dot(2) = eph(16)*10^3;
	sat_xyz_dot(3) = eph(20)*10^3;
	sat_xyz_acc(1) = eph(13)*10^3;
	sat_xyz_acc(2) = eph(17)*10^3;
	sat_xyz_acc(3) = eph(21)*10^3;

	ttm = eph(23);												% �O�������̑�p�Ƃ��ăG�t�F�����X���M����(tow)
	week = eph(24);


	%--- �����̍����Z�o
	%--------------------------------------------
	tod = (time(4)*3600+time(5)*60+time(6))-(rho/C)-dtrec;							% ToD(�`�d����, ��M�@���v�덷���l��)
	mjdt=mjuliday(time(1:3));														% �G�|�b�N�����̏C�������E�X��
	tk=(mjdt-44244-week*7)*86400+tod - ttm;											% ���ԍ�(t-toe) mjuliday([1980,1,6])=44244
	tkc=(mjdt-mjuliday([year,month,day]))*86400 + tod-(hour*3600+min*60+sec);		% ���ԍ�(t-toc)
	% dtsv=a0+a1*tkc+a2*tkc^2 - 2*sqrt(MUe*a)*eee*sin(ek)/C^2;						% �q�����v�덷 + ���Θ_���ʕ␳


	%--- Simplify algorithm for re-calculation of ephemeris to current time
	%--------------------------------------------
	sat_xyz(4:6) = sat_xyz_dot(1:3);

	X = sat_xyz;
	X_glo = X;

	while 1
		for n=1:4
			r = sqrt(sat_xyz(1)^2 + sat_xyz(2)^2 + sat_xyz(3)^2);

			sat_xyz_dot(4) = -MUe*r^-3*sat_xyz(1)...
					- 3/2*J0*MUe*a^2*r^-5*sat_xyz(1)*(1 - 5*sat_xyz(3)^2*r^-2)...
					+ OMGE^2*sat_xyz(1) + 2*OMGE*sat_xyz_dot(2) + sat_xyz_acc(1);
			sat_xyz_dot(5) = -MUe*r^-3*sat_xyz(2)...
					- 3/2*J0*MUe*a^2*r^-5*sat_xyz(2)*(1 - 5*sat_xyz(3)^2*r^-2)...
					+ OMGE^2*sat_xyz(2) - 2*OMGE*sat_xyz_dot(1) + sat_xyz_acc(2);
			sat_xyz_dot(6) = -MUe*r^-3*sat_xyz(3)...
					- 3/2*J0*MUe*a^2*r^-5*sat_xyz(3)*(3 - 5*sat_xyz(3)^2*r^-2)...
					+ sat_xyz_acc(3);
			
			if abs(tk) < 30
				temp = X_glo + sat_xyz_dot*(tk/2);
				if n==3
				temp = X_glo + sat_xyz_dot*tk;
				end
			else
				temp = X_glo + sat_xyz_dot*(30/2);
				if n==3
				temp = X_glo + sat_xyz_dot*30;
				end
			end
			
			Xa(n,1:3) = sat_xyz_dot(4:6);

			sat_xyz = [];
			sat_xyz_dot = [];

			sat_xyz = temp;
			sat_xyz_dot(1:3) = temp(4:6);
		end
		if abs(tk) < 30
		X_glo(1:3) = X_glo(1:3) + X_glo(4:6)*tk + (Xa(1,:) + Xa(2,:) + Xa(3,:))*tk^2/6;
		break
		else
		X_glo(1:3) = X_glo(1:3) + X_glo(4:6)*30 + (Xa(1,:) + Xa(2,:) + Xa(3,:))*30^2/6;
		X_glo(4:6) = X_glo(4:6) + (Xa(1,:) + 2*Xa(2,:) + 2*Xa(3,:) + Xa(4,:))*30/6;
		tk = abs(tk) - 30;
		sat_xyz = X_glo;
		sat_xyz_dot = X_glo(4:6);
		end
	end

	sat_xyz = X_glo(1:3);
	sat_xyz_dot_g = [];
	Vx = sat_xyz_dot(1)*tk;
	Vy = sat_xyz_dot(2)*tk;
	Vz = sat_xyz_dot(3)*tk;
	sat_xyz_dot_g = [Vx,Vy,Vz];
end


