function [trop,tzd,tzw]=cal_trop(ele,pos,sat,model)
%-------------------------------------------------------------------------------
% Function : Troposphere model
%
% [argin]
% ele  : elevation angle
% pos  : Receiver position
% sat  : Satelite position
% model: Tropospheric model selection
%        1: simple model
%            J. B-Y. Tsui: Fundamentals of Global Positioning System Receivers, 
%            Jhon Wiley & Sons, New York, pp104-105, 2000.
%        2: Magnavox model
%        3: Colins model
%        4: Saastamoinen model
%
% [argout]
% trop : total tropospheric delay
% tzd  : zenith dry tropospheric delay
% tzw  : zenith wet tropospheric delay
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

pos = xyz2llh(pos);												% llhに変換[rad rad m]

trop=0; tzd=0; tzw=0;
if model==0
	trop=0;
elseif model==1
	% Simple model
	%--------------------------------------------
	trop = 2.47/(sin(ele)+0.0121);
elseif model==2
	% Magnavox model
	%--------------------------------------------
	hr = pos(3);
	satllh = xyz2llh(sat);
	hs = satllh(3);
	trop = 2.208/sin(ele)*(exp(-hr/6900) - exp(-hs/6900));
elseif model==3
	% Colins model
	%--------------------------------------------
	hr = pos(3);
	trop = 2.4225/(0.026+sin(ele))*(exp(-hr/7492.8));
elseif model==4
	% Saastamoinen model
	%--------------------------------------------
	[trop,tzd,tzw]=saast(ele,pos);
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

% Saastamoinen model
%--------------------------------------------
function [trop,tzd,tzw]=saast(ele,pos)

z=pi/2-ele;																	% zenith angle[rad]
met_prm=[1013.25*(1-2.2557E-5*pos(3))^5.2568, 15.0-6.5E-3*pos(3), 50];		% standard atmosphere(1013.25[hPa], 15[deg], 50[%])
P=met_prm(1);																% pressure[hPa]
T=met_prm(2)+273.16; 														% temperture[K]
% e=(met_prm(3)/100)*6.11*10^(7.5*met_prm(2)/(met_prm(2)+237.3));			% partial press. of water[hPa] --- 水蒸気分圧=(相対湿度[%]*飽和水蒸気圧[hPa])/100 [hPa] (WIKI参照)
e=6.108*met_prm(3)/100*exp((17.15*T-4684)/(T-38.45)); 						% partial press. of water[hPa]

tzd=0.002277*(1+0.0026*cos(2*pos(1))+0.00028*pos(3)/1e3)*P;					% zenith dry tropospheric delay[m]
tzw=0.002277*((1255/T)+0.05)*e;												% zenith wet tropospheric delay[m]
trop=(tzd+tzw)/cos(z);														% total tropospheric delay[m]
