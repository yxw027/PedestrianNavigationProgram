function [sat_xyz, sat_xyz_dot, dtsv] = sat_pos(time, eph, rho, dtrec, est_prm)
%-------------------------------------------------------------------------------
% Function : pos_sat2: 時刻 t での eph に対応する衛星座標を求める(衛星速度も)
%
% [argin]
% time    : observatoin の [year month day hour min sec]
% eph     : Eph_mat から取り出した最適なエフェメリスデータ列
% rho     : 幾何学的距離
% dtrec   : 受信機時計誤差
% est_prm : 初期設定パラメータ
%
% [argout]
% sat_xyz     : 衛星座標
% sat_xyz_dot : 衛星速度
% dtsv        : 衛星時計誤差
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Bokukubo: April 25, 2001
%-------------------------------------------------------------------------------
% 伝搬時間分の回転角計算部分を修正
% June 29, 2004, Y.Kubo
%
% 衛星の速度計算を追加
% November 20, 2006, S.Fujita
%
% 時間差計算, ケプラー方程式を改造
% Jan. 07, 2008, S.Fujita
%-------------------------------------------------------------------------------
% GLONASS対応
% July 10, 2009, T.Yanase
%-------------------------------------------------------------------------------


if est_prm.n_nav==1 & eph(1)<=32

	%--- 定数
	%--------------------------------------------
	C=299792458;							% 光速
	f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
	f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

	OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
	MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
	FF=-4.442807633e-10;					% 相対論に関する誤差補正係数


	%--- GPS 航法メッセージの軌道暦パラメータ
	%--------------------------------------------
	prn      = eph(1);						% 衛星 PRN 番号
	year     = eph(2);						% 年 
	month    = eph(3);						% 月 
	day      = eph(4);						% 日 
	hour     = eph(5);						% 時 
	min      = eph(6);						% 分 
	sec      = eph(7);						% 秒 
	a0       = eph(8);						% 衛星時計バイアス [s]
	a1       = eph(9);						% 衛星時計ドリフト [s/s]
	a2       = eph(10);						% 衛星時計ドリフト率 [s/s^2]
	iode     = eph(11);						% 軌道情報番号
	crs      = eph(12);						% 軌道半径の正弦補正係数 [m]
	del_n    = eph(13);						% 平均運動補正値 [rad/s]
	m0       = eph(14);						% 元期の平均近点角 [rad]
	cuc      = eph(15);						% 緯度引数の余弦補正係数 [rad]
	eee      = eph(16);						% ※離心率
	cus      = eph(17);						% 緯度引数の正弦補正係数 [rad]
	sqrt_a   = eph(18);						% ※軌道長半径の平方根
	toe      = eph(19);						% 軌道の元期 [sec of GPS week]
	cic      = eph(20);						% 軌道傾斜角の余弦補正係数 [rad]
	omega0   = eph(21);						% 元期の昇交点緯度 [rad]
	cis      = eph(22);						% 緯度引数の余弦補正係数 [rad]
	i0       = eph(23);						% 元期の軌道傾斜角 [rad]
	crc      = eph(24);						% 軌道半径の余弦補正係数 [m]
	omega    = eph(25);						% 近地点引数 [rad]
	omegadot = eph(26);						% 昇交点緯度の変化率 [rad/s]
	idot     = eph(27);						% 軌道傾斜角変化率 [rad/s]
	L2code   = eph(28);						% フラグ情報
	week     = eph(29);						% 週番号
	L2data   = eph(30);						% フラグ情報
	accu     = eph(31);						% 測距精度 [m]
	% health   = eph(32);					% 衛星健康状態
	% tgd      = eph(33);					% 群遅延 [s]
	iodc     = eph(34);						% クロック情報番号
	ttm      = eph(35);						% 送信時刻
	fit      = eph(36);						% フィット間隔
	% spare    = eph(37);					% 予備
	% spare    = eph(38);					% 予備

	if year < 80												% 2079年まで対応
		year = year + 2000;
	elseif year >= 80
		year = year + 1900;
	end

	a  = sqrt_a^2;
	n0 = sqrt(MUe/a^3);
	n  = n0+del_n;
	ek = m0;
	% dd = 1.0;

	tod = (time(4)*3600+time(5)*60+time(6))-(rho/C)-dtrec;							% ToD(伝播時間, 受信機時計誤差を考慮)
	mjdt=mjuliday(time(1:3));														% エポック時刻の修正ユリウス日
	tk=(mjdt-44244-week*7)*86400+tod - toe;											% 時間差(t-toe) mjuliday([1980,1,6])=44244


	% ケプラー方程式より離心近点角を求める
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


	% 衛星時計誤差
	%--------------------------------------------
	tkc=(mjdt-mjuliday([year,month,day]))*86400 + tod-(hour*3600+min*60+sec);		% 時間差(t-toc)
	dtsv=a0+a1*tkc+a2*tkc^2 - 2*sqrt(MUe*a)*eee*sin(ek)/C^2;						% 衛星時計誤差 + 相対論効果補正
	% dtsv=a0+a1*tkc+a2*tkc^2 - FF*eee*sqrt_a*sin(ek);								% 衛星時計誤差 + 相対論効果補正


	% 衛星位置関連
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


	% 衛星速度関連
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

	%--- 定数
	%--------------------------------------------
	C=299792458;							% 光速
	% f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
	% f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

	OMGE=7.292115e-5;						% PZ-90 採用地球回転角速度 [rad/s]
	MUe=398600.44e9;						% PZ-90 の地心重力定数 [m^3s^{-2}]
	% FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

	% u = 398600.44e9			% [m^3/s^2] Gravitational constant
	a = 6378136;				% [m] Semi-major axis of Earth軌道長半径
	J0 = 1082625.7e-9;			% Second zonal harmonic of the geopotential地球重力ポテンシャル係数
	% w = 7.292115e-5			% [radian/s] Earth rotation rate地球自転角速度


	%--- GLONASS 航法メッセージの軌道暦パラメータ
	%--------------------------------------------
	prn      = eph(1);						% 衛星 PRN 番号
	year     = eph(2);						% 年 
	month    = eph(3);						% 月 
	day      = eph(4);						% 日 
	hour     = eph(5);						% 時 
	min      = eph(6);						% 分 
	sec      = eph(7);						% 秒 
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

	ttm = eph(23);												% 軌道元期の代用としてエフェメリス送信時刻(tow)
	week = eph(24);


	%--- 時刻の差分算出
	%--------------------------------------------
	tod = (time(4)*3600+time(5)*60+time(6))-(rho/C)-dtrec;							% ToD(伝播時間, 受信機時計誤差を考慮)
	mjdt=mjuliday(time(1:3));														% エポック時刻の修正ユリウス日
	tk=(mjdt-44244-week*7)*86400+tod - ttm;											% 時間差(t-toe) mjuliday([1980,1,6])=44244
	tkc=(mjdt-mjuliday([year,month,day]))*86400 + tod-(hour*3600+min*60+sec);		% 時間差(t-toc)
	% dtsv=a0+a1*tkc+a2*tkc^2 - 2*sqrt(MUe*a)*eee*sin(ek)/C^2;						% 衛星時計誤差 + 相対論効果補正


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


