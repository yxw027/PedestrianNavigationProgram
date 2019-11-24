function [times] = cal_time(time);
%-------------------------------------------------------------------------------
% Function : 時刻計算------入力時刻のmjuliday,week,tow,todの計算
% 
% [argin]
% time  : 時間(文字列'year/month/day/hour/min/sec' 例：'2006/06/01/01/01/01')
%
% [argout]
% times : 時刻情報の構造体(*.tod, *.week, *.tow, *.mjd, *.day)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

time=strrep(time,'/',' ');								% '/'を空白に置換
times.day=str2num(time);
times.tod = round(times.day(4:6)*[3600;60;1]);			% time の TOD
times.mjd = mjuliday(times.day);						% time の Modified Julian day
[times.week,times.tow] = weekf(times.mjd);				% time の WEEK, TOW
