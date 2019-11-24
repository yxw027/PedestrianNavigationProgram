function llh = xyz2llh(xyz)
%-------------------------------------------------------------------------------
% Function : WGS-84 �������W�n���� LLH (�ܓx, �o�x, �ȉ~�̍�) ���W�n�ւ̍��W�ϊ�
% �E�ߎ��ɂ��v�Z
% �E�J�Ԃ��v�Z
%
% [argin]
% xyz(1:3) : ECEF���W X, Y, Z [m]
%
% [argout]
% llh(1:3) : �ܓx[rad], �o�x[rad], �ȉ~�̍�[m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat=NaN; lon=NaN; h=NaN;

x = xyz(1);														% X(ECEF)
y = xyz(2);														% Y(ECEF)
z = xyz(3);														% Z(ECEF)

a = 6378137.0000;												% �ԓ����a
b = 6356752.3142;												% �ɔ��a

% �ߎ��ɂ��v�Z
%-----------------------------------
e=sqrt(a^2-b^2)/a;
p=sqrt(x^2+y^2);
myu=sqrt(a^2-b^2)/b;
theta=atan((z*a)/(p*b));

lat=atan((z+myu^2*b*sin(theta)^3)/(p-e^2*a*cos(theta)^3));		% �ܓx[rad]
if p^2<1E-12, lat=pi/2;, end
lon=atan2(y,x);													% �o�x[rad]
N=a/sqrt(1-e^2*sin(lat)^2);
h=p/cos(lat)-N;													% �ȉ~�̍�[m]

llh=[lat,lon,h];												% �ܓx[rad], �o�x[rad], �ȉ~�̍�[m]


% % �J�Ԃ��v�Z
% %-----------------------------------
% e=sqrt(a^2-b^2)/a;
% p=sqrt(x^2+y^2);
% 
% lat=atan(z/(p*(1-e^2))); latk=0;
% while abs(lat-latk)>1e-4
% 	latk=lat;
% 	N=a/sqrt(1-e^2*sin(lat)^2);
% 	h=p/cos(lat)-N;												% �ȉ~�̍�[m]
% 	lat=atan(z/(p*(1-e^2*(N)/(N+h))));							% �ܓx[rad]
% end
% if p^2<1E-12, lat=pi/2;, end
% lon=atan2(y,x);													% �o�x[rad]
% 
% llh=[lat,lon,h];												% �ܓx[rad], �o�x[rad], �ȉ~�̍�[m]
