function [sat_xyz, sat_xyz_dot, dtsv] = sat_pos(time, eph, rho, dtrec);
%-------------------------------------------------------------------------------
% Function : pos_sat2: 時刻 t での eph に対応する衛星座標を求める(衛星速度も)
%
% [argin]
% time  : observatoin の [year month day hour min sec]
% eph   : Eph_mat から取り出した最適なエフェメリスデータ列
% rho   : 幾何学的距離
% dtrec : 受信機時計誤差
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

% sat_xyz(1:3)=NaN; sat_xyz_dot(1:3)=NaN;

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

prn      = eph(1);
year     = eph(2);
month    = eph(3);
day      = eph(4);
hour     = eph(5);
min      = eph(6);
sec      = eph(7);
a0       = eph(8);
a1       = eph(9);
a2       = eph(10);
iode     = eph(11);
crs      = eph(12);
del_n    = eph(13);
m0       = eph(14);
cuc      = eph(15);
eee      = eph(16);
cus      = eph(17);
sqrt_a   = eph(18);
toe      = eph(19);
cic      = eph(20);
omega0   = eph(21);
cis      = eph(22);
i0       = eph(23);
crc      = eph(24);
omega    = eph(25);
omegadot = eph(26);
idot     = eph(27);
L2code   = eph(28);
week     = eph(29);
L2data   = eph(30);
accu     = eph(31);
% health   = eph(32);
% tgd      = eph(33);
iodc     = eph(34);
ttm      = eph(35);
fit      = eph(36);
% spare    = eph(37);
% spare    = eph(38);

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
