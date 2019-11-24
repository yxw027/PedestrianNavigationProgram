function ion=ion_klob(ion_prm,tod,pos,azi,ele)
%-------------------------------------------------------------------------------
% Function : Klobuchar model
% 
% [argin]
% ion_prm : “d—£‘wƒpƒ‰ƒ[ƒ^ƒ¿,ƒÀ
% tod     : ToD
% pos     : XYZ(ECEF)[m]
% azi     : •ûˆÊŠp[rad]
% ele     : ‹ÂŠp[rad]
% 
% [argout]
% ion     : “d—£‘w’x‰„
% 
% ’FKlobuchar ƒ‚ƒfƒ‹“à‚Å‚ÍƒZƒ~ƒT[ƒNƒ‹(SC)’PˆÊ‚ÅŒvŽZ‚·‚é‚ª, 
%     ŽOŠpŠÖ”‚É‚Â‚¢‚Ä‚Í•K‚¸rad’PˆÊ‚É‚·‚é‚±‚Æ
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% (Y. Kubo: June 29, 2004)
%-------------------------------------------------------------------------------

% ’è”(ƒOƒ[ƒoƒ‹•Ï”)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- ’è”
%--------------------------------------------
C=299792458;							% Œõ‘¬
f1=1.57542e9;  lam1=C/f1;				% L1 Žü”g” & ”g’·
f2=1.22760e9;  lam2=C/f2;				% L2 Žü”g” & ”g’·

OMGE=7.2921151467e-5;					% WGS-84 Ì—p’n‹…‰ñ“]Šp‘¬“x [rad/s]
MUe=3.986005e14;						% WGS-84 ‚Ì’nSd—Í’è” [m^3s^{-2}]
FF=-4.442807633e-10;					% ‘Š‘Î˜_‚ÉŠÖ‚·‚éŒë·•â³ŒW”

a=ion_prm.ionab(:,1);					% ION ALPHA
b=ion_prm.ionab(:,2);					% ION BETA
if isnan(a(1))
	ion=0;
	return;
end

Xul = xyz2llh(pos);													% llh‚É•ÏŠ·[rad,rad,m]
phi = Xul(1);
lam = Xul(2);

Psi=0.0137/(ele/pi+0.11)-0.022;										% [SC]
phii=phi/pi+Psi*cos(azi);											% [SC]
if phii>0.416, phii=0.416;, elseif phii<-0.416, phii=-0.416;, end

lami = lam/pi+Psi*sin(azi)/cos(phii*pi);							% [SC]
phim = phii+0.064*cos((lami-1.617)*pi);								% [SC]

t=43200*lami+tod;													% local time ‚ÌŒvŽZ
if t>=86400, t=t-86400;, elseif t<0, t=t+86400;, end

F=1.0+16.0*(0.53-ele/pi)^3;											% Mapping Function

PER=b(1)+(b(2)+(b(3)+b(4)*phim)*phim)*phim;							% cos‚ÌŽüŠú
if PER<72000, PER=72000;, end

x=2*pi*(t-50400)/PER;
while x>pi, x=x-2*pi; end
while x<-pi, x=x+2*pi; end

AMP=a(1)+(a(2)+(a(3)+a(4)*phim)*phim)*phim;							% cos‚ÌU•
if AMP < 0, AMP=0;, end

if abs(x)<1.57
	ion=C*F*(5.0e-9+AMP*(1-(x^2)/2+(x^4)/24));						% ’‹ŠÔ
else
	ion=C*F*5.0e-9;													% –éŠÔ
end
