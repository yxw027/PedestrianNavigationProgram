function [ion_prm] = read_ionex(ionex_file)
%-------------------------------------------------------------------------------
% Function : ionex ファイルから TEC データ全取得
% 
% [argin]
% ionex_file : ionex ファイル名
% 
% [argout]
% ion_prm : TECデータ(t,tec,deg : 3dim)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

% ionex ファイルオープン
%--------------------------------------------
fpo = fopen(ionex_file,'rt');

% ionex ヘッダー解析
%--------------------------------------------
[tofi,toei,s_timei,e_timei,interval,maps,lats,lons,hgts,baseRe,nexp,dcbG,dcbR] = ionex_h(fpo);


% TECデータ全取得
%--------------------------------------------
j = 0;
e_o_h  = 1;
tt     = 1;
tof    = [];
toe    = [];
s_time = [];
e_time = [];
time=[];
while 1
	temp  = fgetl(fpo);													% 1行読み込み
	if (temp == -1)														% END OF FILE 以前に EOF の時
		fprintf('"ionex" ファイルが正常に読み込まれませんでした\n')
		break;
	elseif findstr(temp,'START OF TEC MAP')								% START OF TEC MAP
		j = 0;
		smap = str2num(temp(1:60));
	elseif findstr(temp,'EPOCH OF CURRENT MAP')							% EPOCH OF CURRENT MAP
		tof = str2num(temp(1:60));
		if tof(1) < 80
			tof(1) = tof(1) + 2000;
		end
		tod_s = round(tof(4)*3600 + tof(5)*60 + tof(6));				% stime の TOD
		mjd_s = mjuliday(tof);											% stime の Modified Julian day
		[week_s,tow_s] = weekf(mjd_s);									% stime の WEEK, TOW
		s_time = [tod_s; week_s; tow_s; mjd_s];							% stime の 時刻情報を格納
		time=[time; mjd_s];
	elseif findstr(temp,'LAT/LON1/LON2/DLON/H')							% LAT/LON1/LON2/DLON/H
		lat    = str2num(temp(3:8));
		lon1   = str2num(temp(9:14));
		lon2   = str2num(temp(15:20));
		dlon   = str2num(temp(21:26));
		height = str2num(temp(27:32));
		j = j + 1;														% TEC 取得
		tec_map = [];
		for k = 1:5
			temp  = fgetl(fpo);
			tec_m = str2num(temp);
			tec_map = [tec_map tec_m];
		end
		TEC(smap,:,j) = tec_map*10^nexp;
	elseif findstr(temp,'END OF TEC MAP')								% END OF TEC MAP
		j = 0;
		emap = str2num(temp(1:60));
		if emap == maps
			break;
		end
	elseif findstr(temp,'END OF FILE')									% END OF FILEなら終了
		break;
	end
	temp = [];
end
ion_prm.time=time;
ion_prm.map=TEC;
ion_prm.dcbG=dcbG;
ion_prm.dcbR=dcbR;
ion_prm.lats=lats;
ion_prm.lons=lons;
ion_prm.hgts=hgts;
ion_prm.baseRe=baseRe;



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function [tof,toe,s_time,e_time,interval,maps,lats,lons,hgts,baseRe,nexp,dcbG,dcbR] = ionex_h(fpo)
%-------------------------------------------------------------------------------
% ionex ファイルのヘッダー解析
% 
% [argin]
% ionex : ionex ファイルポインタ
% 
% [argout]
% tof      : TIME OF FIRST OBS
% toe      : TIME OF LAST OBS
% s_time   : stime の時刻情報 (ToD, Week, ToW, JD)
% e_time   : etime の時刻情報 (ToD, Week, ToW, JD)
% interval : 更新間隔
% maps     : MAP の数
% lats     : 緯度の範囲, 間隔
% lons     : 経度の範囲, 間隔
% hgts     : 高度の範囲, 間隔
% nexp     : TEC MAPのスケール
% dcbG     : DIFFERENTIAL CODE BIASES(G)
% dcbR     : DIFFERENTIAL CODE BIASES(R)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 16, 2007
%-------------------------------------------------------------------------------

tof    = [];
toe    = [];
s_time = [];
e_time = [];
dcbG   = [];
dcbR   = [];
while 1
	temp  = fgetl(fpo);															% 1行読み込み
	if (temp == -1)																% END OF HEADER 以前に EOF の時
		fprintf('"ionex" ファイルのヘッダが正常に読み込まれませんでした\n')
		break;
	elseif findstr(temp,'EPOCH OF FIRST MAP')									% EPOCH OF FIRST MAP
		tof = str2num(temp(1:60));
		if tof(1)<80, tof(1)=tof(1)+2000;, end
		tod_s = round(tof(4)*3600 + tof(5)*60 + tof(6));						% stime の TOD
		mjd_s = mjuliday(tof);													% stime の Modified Julian day
		[week_s,tow_s] = weekf(mjd_s);											% stime の WEEK, TOW
		s_time = [tod_s; week_s; tow_s; mjd_s];									% stime の 時刻情報を格納
	elseif findstr(temp,'EPOCH OF LAST MAP')									% EPOCH OF LAST MAP
		toe = str2num(temp(1:60));
		if toe(1)<80, toe(1)=toe(1)+2000;, end
		tod_e = round(toe(4)*3600 + toe(5)*60 + toe(6));						% etime の TOD
		mjd_e = mjuliday(toe);													% etime の Modified Julian day
		[week_e,tow_e] = weekf(mjd_e);											% etime の WEEK, TOW
		e_time = [tod_e; week_e; tow_e; mjd_e];									% etime の 時刻情報を格納
	elseif findstr(temp,'INTERVAL')												% INTERVAL
		interval = str2num(temp(1:60));
	elseif findstr(temp,'# OF MAPS IN FILE')									% # OF MAPS IN FILE 行の格納
		maps = str2num(temp(1:60));
	elseif findstr(temp,'BASE RADIUS')											% BASE RADIUS 行の格納
		baseRe = str2num(temp(1:60));
	elseif findstr(temp,'HGT1 / HGT2 / DHGT')									% HGT1 / HGT2 / DHGT 行の格納
		hgts = str2num(temp(1:60));
	elseif findstr(temp,'LAT1 / LAT2 / DLAT')									% LAT1 / LAT2 / DLAT 行の格納
		lats = str2num(temp(1:60));
	elseif findstr(temp,'LON1 / LON2 / DLON')									% LON1 / LON2 / DLON 行の格納
		lons = str2num(temp(1:60));
	elseif findstr(temp,'EXPONENT')												% EXPONENT 行の格納
		nexp = str2num(temp(1:60));
	elseif findstr(temp,'START OF AUX DATA')									% START OF AUX DATA
		while 1
			temp  = fgetl(fpo);													% 1行読み込み
			if findstr(temp,'PRN / BIAS / RMS');								% PRN / BIAS / RMS
				if temp(4)=='G' | temp(4)==' '
					dcbG=[dcbG; str2num(temp(5:26))];
				elseif temp(4)=='R'
					dcbR=[dcbR; str2num(temp(5:26))];
				end
			elseif findstr(temp,'STATION / BIAS / RMS')							% STATION / BIAS / RMS

			elseif findstr(temp,'END OF AUX DATA')								% END OF AUX DATA
				break;
			end
		end
	elseif findstr(temp,'END OF HEADER')										% END OF HEADERなら終了
		break;
	end
	temp = [];
end
