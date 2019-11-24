function ion=ion_klob(ion_prm,tod,pos,azi,ele)
%-------------------------------------------------------------------------------
% Function : Klobuchar model
% 
% [argin]
% ion_prm : �d���w�p�����[�^��,��
% tod     : ToD
% pos     : XYZ(ECEF)[m]
% azi     : ���ʊp[rad]
% ele     : �p[rad]
% 
% [argout]
% ion     : �d���w�x��
% 
% ���FKlobuchar ���f�����ł̓Z�~�T�[�N��(SC)�P�ʂŌv�Z���邪, 
%     �O�p�֐��ɂ��Ă͕K��rad�P�ʂɂ��邱��
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% (Y. Kubo: June 29, 2004)
%-------------------------------------------------------------------------------

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

a=ion_prm.ionab(:,1);					% ION ALPHA
b=ion_prm.ionab(:,2);					% ION BETA
if isnan(a(1))
	ion=0;
	return;
end

Xul = xyz2llh(pos);													% llh�ɕϊ�[rad,rad,m]
phi = Xul(1);
lam = Xul(2);

Psi=0.0137/(ele/pi+0.11)-0.022;										% [SC]
phii=phi/pi+Psi*cos(azi);											% [SC]
if phii>0.416, phii=0.416;, elseif phii<-0.416, phii=-0.416;, end

lami = lam/pi+Psi*sin(azi)/cos(phii*pi);							% [SC]
phim = phii+0.064*cos((lami-1.617)*pi);								% [SC]

t=43200*lami+tod;													% local time �̌v�Z
if t>=86400, t=t-86400;, elseif t<0, t=t+86400;, end

F=1.0+16.0*(0.53-ele/pi)^3;											% Mapping Function

PER=b(1)+(b(2)+(b(3)+b(4)*phim)*phim)*phim;							% cos�̎���
if PER<72000, PER=72000;, end

x=2*pi*(t-50400)/PER;
while x>pi, x=x-2*pi; end
while x<-pi, x=x+2*pi; end

AMP=a(1)+(a(2)+(a(3)+a(4)*phim)*phim)*phim;							% cos�̐U��
if AMP < 0, AMP=0;, end

if abs(x)<1.57
	ion=C*F*(5.0e-9+AMP*(1-(x^2)/2+(x^4)/24));						% ����
else
	ion=C*F*5.0e-9;													% ���
end
