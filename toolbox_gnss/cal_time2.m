function [times] = cal_time(time);
%-------------------------------------------------------------------------------
% Function : �����v�Z------���͎�����mjuliday,week,tow,tod�̌v�Z
% 
% [argin]
% time  : ����(������'year/month/day/hour/min/sec' ��F'2006/06/01/01/01/01')
%
% [argout]
% times : �������̍\����(*.tod, *.week, *.tow, *.mjd, *.day)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

time=strrep(time,'/',' ');								% '/'���󔒂ɒu��
times.day=str2num(time);
times.tod = round(times.day(4:6)*[3600;60;1]);			% time �� TOD
times.mjd = mjuliday(times.day);						% time �� Modified Julian day
[times.week,times.tow] = weekf(times.mjd);				% time �� WEEK, TOW
