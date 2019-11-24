function llh = xyz2llh(xyz)
%-------------------------------------------------------------------------------
% Function : WGS-84 直交座標系から LLH (緯度, 経度, 楕円体高) 座標系への座標変換
% ・近似による計算
% ・繰返し計算
%
% [argin]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% [argout]
% llh(1:3) : 緯度[rad], 経度[rad], 楕円体高[m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat=NaN; lon=NaN; h=NaN;

x = xyz(1);														% X(ECEF)
y = xyz(2);														% Y(ECEF)
z = xyz(3);														% Z(ECEF)

a = 6378137.0000;												% 赤道半径
b = 6356752.3142;												% 極半径

% 近似による計算
%-----------------------------------
e=sqrt(a^2-b^2)/a;
p=sqrt(x^2+y^2);
myu=sqrt(a^2-b^2)/b;
theta=atan((z*a)/(p*b));

lat=atan((z+myu^2*b*sin(theta)^3)/(p-e^2*a*cos(theta)^3));		% 緯度[rad]
if p^2<1E-12, lat=pi/2;, end
lon=atan2(y,x);													% 経度[rad]
N=a/sqrt(1-e^2*sin(lat)^2);
h=p/cos(lat)-N;													% 楕円体高[m]

llh=[lat,lon,h];												% 緯度[rad], 経度[rad], 楕円体高[m]


% % 繰返し計算
% %-----------------------------------
% e=sqrt(a^2-b^2)/a;
% p=sqrt(x^2+y^2);
% 
% lat=atan(z/(p*(1-e^2))); latk=0;
% while abs(lat-latk)>1e-4
% 	latk=lat;
% 	N=a/sqrt(1-e^2*sin(lat)^2);
% 	h=p/cos(lat)-N;												% 楕円体高[m]
% 	lat=atan(z/(p*(1-e^2*(N)/(N+h))));							% 緯度[rad]
% end
% if p^2<1E-12, lat=pi/2;, end
% lon=atan2(y,x);													% 経度[rad]
% 
% llh=[lat,lon,h];												% 緯度[rad], 経度[rad], 楕円体高[m]
