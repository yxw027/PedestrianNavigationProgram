function xyz = llh2xyz(llh)
%-------------------------------------------------------------------------------
% Function : LLH (�ܓx, �o�x, �ȉ~�̍�) ���W�n���� WGS-84 �������W�n�ւ̍��W�ϊ�
% �E�ߎ��ɂ��v�Z
% �E�J�Ԃ��v�Z
%
% [argin]
% llh(1:3) : �ܓx[rad], �o�x[rad], �ȉ~�̍�[m]
%
% [argout]
% xyz(1:3) : ECEF���W X, Y, Z [m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat = llh(1);							% �ܓx[rad]
lon = llh(2);							% �o�x[rad]
h   = llh(3);							% �ȉ~�̍�[m]

a = 6378137.0000;						% �ԓ����a
b = 6356752.3142;						% �ɔ��a

e=sqrt(a^2-b^2)/a;
N=a/sqrt(1-e^2*sin(lat)^2);

x=(N+h)*cos(lat)*cos(lon);				% X(ECEF)
y=(N+h)*cos(lat)*sin(lon);				% Y(ECEF)
z=(N*(1-e^2)+h)*sin(lat);				% Z(ECEF)

xyz = [x,y,z];							% ECEF���W X, Y, Z [m]
