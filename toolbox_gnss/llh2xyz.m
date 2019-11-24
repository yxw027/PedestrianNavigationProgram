function xyz = llh2xyz(llh)
%-------------------------------------------------------------------------------
% Function : LLH (緯度, 経度, 楕円体高) 座標系から WGS-84 直交座標系への座標変換
% ・近似による計算
% ・繰返し計算
%
% [argin]
% llh(1:3) : 緯度[rad], 経度[rad], 楕円体高[m]
%
% [argout]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat = llh(1);							% 緯度[rad]
lon = llh(2);							% 経度[rad]
h   = llh(3);							% 楕円体高[m]

a = 6378137.0000;						% 赤道半径
b = 6356752.3142;						% 極半径

e=sqrt(a^2-b^2)/a;
N=a/sqrt(1-e^2*sin(lat)^2);

x=(N+h)*cos(lat)*cos(lon);				% X(ECEF)
y=(N+h)*cos(lat)*sin(lon);				% Y(ECEF)
z=(N*(1-e^2)+h)*sin(lat);				% Z(ECEF)

xyz = [x,y,z];							% ECEF座標 X, Y, Z [m]
