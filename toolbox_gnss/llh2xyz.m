function xyz = llh2xyz(llh)
%-------------------------------------------------------------------------------
% Function : LLH (Üx, ox, È~Ì) ÀWn©ç WGS-84 ¼ðÀWnÖÌÀWÏ·
% EßÉæévZ
% EJÔµvZ
%
% [argin]
% llh(1:3) : Üx[rad], ox[rad], È~Ì[m]
%
% [argout]
% xyz(1:3) : ECEFÀW X, Y, Z [m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat = llh(1);							% Üx[rad]
lon = llh(2);							% ox[rad]
h   = llh(3);							% È~Ì[m]

a = 6378137.0000;						% Ô¹¼a
b = 6356752.3142;						% É¼a

e=sqrt(a^2-b^2)/a;
N=a/sqrt(1-e^2*sin(lat)^2);

x=(N+h)*cos(lat)*cos(lon);				% X(ECEF)
y=(N+h)*cos(lat)*sin(lon);				% Y(ECEF)
z=(N*(1-e^2)+h)*sin(lat);				% Z(ECEF)

xyz = [x,y,z];							% ECEFÀW X, Y, Z [m]
