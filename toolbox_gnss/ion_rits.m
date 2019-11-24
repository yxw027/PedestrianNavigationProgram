function ion=ion_rits(ion_prm, time, pos, azi, ele)
%-------------------------------------------------------------------------------
% Function : Ionosphere model(Rits)
% 
% [argin]
% ion_prm : 電離層パラメータ(iona,ionb,gim,dcbG,dcbR,rits)
% time    : 時刻(year month day hour minute sec),time の時刻情報 (ToD, Week, ToW, JD)
% pos     : XYZ(ECEF)[m]
% azi     : 方位角[rad]
% ele     : 仰角[rad]
% 
% [argout]
% ion     : 電離層遅延[m]
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

model=ion_prm.model;										% tec model(1:local, 2:global)
nmax=ion_prm.nmax;											% max degree of tec model
ENM=ion_prm.Enm;											% coeficients
tod=ion_prm.tod;											% tod
posp0=ion_prm.posp0;										% origin latitude/longitude of local tec model [rad]

t=time.day;
tt=time.tod;

no_sat=length(ele);

% ionospheric pierce point position
%--------------------------------------------
posp=zeros(no_sat,2); zr=zeros(no_sat,1); z=zeros(no_sat,1);
lat = atan2(pos(3),sqrt(pos(1)^2+pos(2)^2));								% geocentric lat[rad]
lon = atan2(pos(2), pos(1));												% geocentric lon[rad]
for k = 1:no_sat
	Re = 6371000;															% earth radius
	Hr  = 450000;															% ionospheric height
	zr(k) = pi/2-ele(k);													% zenith angle
	z(k) = asin(Re.*sin(zr(k))/(Re + Hr));									% zenith angle (IPP)
	posp(k,1) = asin(cos(zr(k)-z(k)).*sin(lat)+...
					sin(zr(k)-z(k)).*cos(lat).*cos(azi(k)));				% IPP lat[rad]
	posp(k,2) = lon+asin(sin(zr(k)-z(k)).*sin(azi(k))/cos(lat));			% IPP lon[rad]
end

[i,j]=min(abs(tod-tt));
if tod<=tt, k=j+1;, else, j=j-1; k=j+1;, end
if j==0, j=1; k=2;, end
Enm1=ENM(j,:)';
Enm2=ENM(k,:)';
tr1=tod(j);
tr2=tod(k);
ne=(nmax+1)*(nmax+1); 														% number of coeficients

% local model
%--------------------------------------------
tec1=zeros(no_sat,1); dtde1=zeros(no_sat,ne);
tec2=zeros(no_sat,1); dtde2=zeros(no_sat,ne);
for k = 1:no_sat
	[tec1(k), dtde1(k,:)]=tec_model(posp(k,:),posp0,Enm1',nmax,model,tt);	% tec model
	[tec2(k), dtde2(k,:)]=tec_model(posp(k,:),posp0,Enm2',nmax,model,tt);	% tec model
end

% 時間内挿
%--------------------------------------------
vtec = (tr2-tt)/(tr2-tr1).*tec1 + (tt-tr1)/(tr2-tr1).*tec2;

% Ionospheric delay
%--------------------------------------------
for k = 1:no_sat
	ion(k,1)=(1/f1^2)*40.34e16/cos(z(k))*vtec(k);							% Ionospheric delay[m]
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function [tec, dtde]=tec_model(posp,posp0,Enm,nmax,model,time)
% 
% TEC MODEL
% 
% [argin]
% posp  : lat, lon [rad]
% posp0 : lat, lon(origin) [rad]
% Enm   : coefficients
% nmax  : max degree of tec model
% model : tec model(1:local or 2:global)
% time  : time(global modelで使うかも)
% 
% [argout]
% tec  : total electron content [TECU]
% dtde : partial derivative
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: July 10, 2007

% local model
%--------------------------------------------
if model == 1
	tec = []; s=10*pi/180;
	dtde=zeros(1,(nmax+1)*(nmax+1)); i=1;
	for n=0:nmax
		for m=0:nmax
			dtde(i)=((posp(1)-posp0(1))/s)^n*((posp(2)-posp0(2))/s)^m;
			i=i+1;
		end
	end
	tec=Enm*dtde';

elseif model == 2
	posp(2)=pi*time/43200+posp(2)-pi;

	tec = []; 
	
	dtde = zeros(1,(nmax+1)*(nmax+2)-(nmax+1)); 
	i=1;
	k=1;

	A=[];
	B=[];
	for n=0:nmax
		for m=0:n
% 			Pnm = legendre(n,sin(posp(1)));
			Pnm = legendre(n,sin(posp(1)),'norm');
			am=Pnm(m+1)*cos(m*posp(2)); 		% a_mに関する球関数
			A=[A am];
			dtde(i)=A(i);
			i=i+1;
		end
	end
	for n=1:nmax
		for m=1:n
% 			Pnm = legendre(n,sin(posp(1)));
			Pnm = legendre(n,sin(posp(1)),'norm');
			bm=Pnm(m)*sin(m*posp(2));			% b_mに関する球関数
			B =[B bm];
			dtde(k+((nmax+1)*(nmax+2)/2))=B(k);
			k=k+1;
		end
	end
	tec=Enm*(dtde)';
end
