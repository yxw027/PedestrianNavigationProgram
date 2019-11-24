function ion = ion_gim(ion_prm, t, pos, azi, ele)
%-------------------------------------------------------------------------------
% Function : TECデータから電離層遅延を計算
% 
% [argin]
% ion_prm : 電離層パラメータ TECデータ(t,tec,deg : 3dim) etc
% t       : 時刻(Y,M,D,H,M,S) → MJD
% pos     : XYZ(ECEF)[m]
% azi     : 方位角[rad]
% ele     : 仰角[rad]
% 
% [argout]
% ion : 電離層遅延[m]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

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

time=ion_prm.time;						% MJD(ionex)
TEC=ion_prm.map;						% VTEC MAP(ionex)
lats=ion_prm.lats(1:2);					% 緯度の範囲
lons=ion_prm.lons(1:2);					% 経度の範囲
dlat=ion_prm.lats(3);					% 緯度の間隔
dlon=ion_prm.lons(3);					% 経度の間隔
H=ion_prm.hgts(1);						% 高度
Re=ion_prm.baseRe;						% Base Radius

% ionospheric pierce point position(SLM)
%--------------------------------------------
lat = atan2(pos(3),sqrt(pos(1)^2+pos(2)^2));				% 地心(geocentric)緯度[rad]
lon = atan2(pos(2), pos(1));								% 経度[rad]
[lat,lon,z]=postoipp(lat,lon,azi,ele,Re,H);

% 入力時刻からTi, Ti+1を設定
%--------------------------------------------
index_T1 = max(find(time<=t));
index_T2 = index_T1+1;
T1=time(index_T1);
T2=time(index_T2);

% インデックス(緯度方向)
%--------------------------------------------
glat = floor(lat/abs(dlat))*abs(dlat);
glat1 = [glat, glat+abs(dlat)];
glat2 = [glat, glat+abs(dlat)];

index1 = find([lats(1):dlat:lats(2)]==glat1(1));
index2 = find([lats(1):dlat:lats(2)]==glat1(2));

% TEC(時刻・緯度から抽出, 経度は全部)
%--------------------------------------------
all_lon_b1_T1 = TEC(index_T1,:,index1);
all_lon_b2_T1 = TEC(index_T1,:,index2);
all_lon_b1_T2 = TEC(index_T2,:,index1);
all_lon_b2_T2 = TEC(index_T2,:,index2);

% 使用するIPPの緯度・経度(回転考慮)
%--------------------------------------------
lonA1 = lon+(t-T1)*360;  latA1 = lat;
lonA2 = lon+(t-T2)*360;  latA2 = lat;

% インデックス(経度方向)
%--------------------------------------------
glon = floor(lonA1/abs(dlon))*abs(dlon);  glon1 = [glon, glon+abs(dlon)];
glon = floor(lonA2/abs(dlon))*abs(dlon);  glon2 = [glon, glon+abs(dlon)];

if glon1(1)>180,  glon1(1) = 360-glon1(1);, end
if glon1(1)<-180, glon1(1) = glon1(1)+360;, end
if glon2(1)>180,  glon2(1) = 360-glon2(1);, end
if glon2(1)<-180, glon2(1) = glon2(1)+360;, end

index_lonA1 = find([lons(1):dlon:lons(2)]==glon1(1));
index_lonA2 = find([lons(1):dlon:lons(2)]==glon2(1));

if index_lonA1==73, index_lonA12 = 1;, else, index_lonA12 = index_lonA1 +1;, end
if index_lonA2==73, index_lonA22 = 1;, else, index_lonA22 = index_lonA2 +1;, end

% 空間内挿の準備
%--------------------------------------------
p1=(lonA1-glon1(1))/abs(dlon); q1=(latA1-glat1(1))/abs(dlat);
p2=(lonA2-glon2(1))/abs(dlon); q2=(latA2-glat2(1))/abs(dlat);

% 空間内挿
%--------------------------------------------
ET1A =   (1-p1) * (1-q1) * all_lon_b1_T1(index_lonA1) ...
       +    p1  * (1-q1) * all_lon_b1_T1(index_lonA12) ...
       + (1-p1) *    q1  * all_lon_b2_T1(index_lonA1) ...
       +    p1  *    q1  * all_lon_b2_T1(index_lonA12);

ET2A =   (1-p2) * (1-q2) * all_lon_b1_T2(index_lonA2) ...
       +    p2  * (1-q2) * all_lon_b1_T2(index_lonA22) ...
       + (1-p2) *    q2  * all_lon_b2_T2(index_lonA2) ...
       +    p2  *    q2  * all_lon_b2_T2(index_lonA22);

% 時間内挿
%--------------------------------------------
VTEC = (T2-t)/(T2-T1)*ET1A + (t-T1)/(T2-T1)*ET2A;

% Mapping Function
%--------------------------------------------
F = 1./cos(z);

% 電離層遅延
%--------------------------------------------
ion = F.*40.3e16 * VTEC / f1^2;

if isempty(ion), ion=NaN;, end


%-------------------------------------------------------------------------------
% 以下, サブルーチン

% ionospheric pierce point position
%--------------------------------------------
function [lat,lon,z]=postoipp(lat,lon,azi,ele,Re,H)

zr = pi/2-ele;

% SLM model
%--------------------------------------------
z = asin(Re.*sin(zr)/(Re + H));

% MSLM model
%--------------------------------------------
% Re = 6371000; H = 506700;
% z = asin(Re.*sin(0.9782*zr)/(Re + H));

lat = asin(cos(zr-z).*sin(lat)+sin(zr-z).*cos(lat).*cos(azi));
lon = lon+asin(sin(zr-z).*sin(azi)/cos(lat));
lat = lat*(180/pi);
lon = lon*(180/pi);
