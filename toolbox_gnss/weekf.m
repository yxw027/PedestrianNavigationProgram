function [week,sec_of_week] = weekf(mjd);
%-------------------------------------------------------------------------------
% Function : WEEK, TOW ‚ÌŒvŽZ
%
% [argin]
% mjd : Modified JUlian day
%
% [argout]
% week        : WEEK
% sec_of_week : TOW
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 21, 2008
%-------------------------------------------------------------------------------

jd = mjd+2400000.5;
a = floor(jd+.5);
b = a+1537;
c = floor((b-122.1)/365.25);
d = floor(365.25*c);
e = floor((b-d)/30.6001);
f = b-d-floor(30.6001*e)+rem(jd+.5,1);
day_of_week = rem(floor(jd+1.5),7);
week = floor((jd-2444244.5)/7);
sec_of_week = (rem(f,1)+day_of_week)*86400;

%sec_of_week ‚ÌŠÛ‚ß‚±‚Ý
sec_of_week = round(sec_of_week);
