function mjd = mjuliday(time)
%-------------------------------------------------------------------------------
% Function : Modified Julian day ÇÃåvéZ
%
% [argin]
% time : éûçè [Y,M,D,H,M,S]
%
% [argout]
% mjd : Modified JUlian day
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 21, 2008
%-------------------------------------------------------------------------------

if time(2) <= 2
   time(1) = time(1)-1; 
   time(2) = time(2)+12;
end
mjd = floor(365.25*time(1))+floor(30.6001*(time(2)+1))+time(3)+1720981.5 - 2400000.5;
if length(time)>3,mjd=mjd+time(4)/24+time(5)/1440+time(6)/86400;,end
