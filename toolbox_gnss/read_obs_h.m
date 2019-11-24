function [tof, toe, s_time, e_time, app_xyz, no_obs, TYPES, dt, Rec_type] = read_obs_h(fpo)
%-------------------------------------------------------------------------------
% Function : observation ファイルのヘッダー解析
% 
% [argin]
% fpo     : obs ファイルポインタ
% 
% [argout]
% tof     : TIME OF FIRST OBS
% toe     : TIME OF LAST OBS
% s_time  : stime の時刻情報 (ToD, Week, ToW, JD)
% e_time  : etime の時刻情報 (ToD, Week, ToW, JD)
% app_xyz : APPROX POSITION (X, Y, Z)
% no_obs  : 観測ﾃﾞｰﾀ数
% TYPES   : 観測ﾃﾞｰﾀの種類 (文字列)
% dt      : 更新間隔
% Rec_type: 受信機タイプ
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

dt=1;
ant_delta=[];
app_xyz=[];
TYPES=[];
tof=[];
toe=[];
s_time=[];
e_time=[];
while 1
	temp  = fgetl(fpo);														% 1行読み込み
	if (temp == -1)															% END OF HEADER 以前に EOF の時
		fprintf('"o" ファイルのヘッダが正常に読み込まれませんでした\n')
		break;
	elseif findstr(temp,'MARKER NAME')										% MARKER NAME
	elseif findstr(temp,'REC # / TYPE / VERS')								% REC # / TYPE / VERS
		Rec_type = temp(20:40);
	elseif findstr(temp,'ANT # / TYPE');									% ANT # / TYPE
	elseif findstr(temp,'APPROX POSITION XYZ')								% APPROX POSITION XYZ
		app_xyz=str2num(temp(1:60));										% X Y Z で
		if isempty(app_xyz), app_xyz=[0,0,0];, end
	elseif findstr(temp,'ANTENNA: DELTA H/E/N')								% ANTENNA: DELTA H/E/N
		ant_delta=str2num(temp(1:60));										% X Y Z で
	elseif findstr(temp,'# / TYPES OF OBSERV')								% # / TYPES OF OBSERV
		no_obs = str2num(temp(1:6));										% 観測ﾃﾞｰﾀ数の取り出し
		TYPES=temp(7:60); TYPES=TYPES(find(TYPES~=' '));					% 観測ﾃﾞｰﾀの種類を格納
	elseif findstr(temp,'INTERVAL')											% INTERVAL
		dt=str2num(temp(1:60));												% 更新間隔の取り出し
	elseif findstr(temp,'TIME OF FIRST OBS')								% TIME OF FIRST OBS
		tof=str2num(temp(1:43));
		if tof(1)<80, tof(1)=tof(1)+2000;, end
		tod_s = round(tof(4)*3600 + tof(5)*60 + tof(6));					% stime の TOD
		mjd_s = mjuliday(tof);												% stime の Modified Julian day
		[week_s,tow_s] = weekf(mjd_s);										% stime の WEEK, TOW
		s_time = [tod_s; week_s; tow_s; mjd_s];								% stime の 時刻情報を格納
	elseif findstr(temp,'TIME OF LAST OBS')									% TIME OF LAST OBS
		toe=str2num(temp(1:43));
		if toe(1)<80, toe(1)=toe(1)+2000;, end
		tod_e = round(toe(4)*3600 + toe(5)*60 + toe(6));					% etime の TOD
		mjd_e = mjuliday(toe);												% etime の Modified Julian day
		[week_e,tow_e] = weekf(mjd_e);										% etime の WEEK, TOW
		e_time = [tod_e; week_e; tow_e; mjd_e];								% etime の 時刻情報を格納
	elseif findstr(temp,'END OF HEADER')									% END OF HEADERなら終了
		break;
	end;
	temp = [];
end
