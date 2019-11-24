clear all;
close('all');
fclose all;

data_fn  = '1日目_insgps_純慣性.csv';      %CSVファイル名設定
file = '1日目_insgps_純慣性.kml';               %書き出しKMLファイル名設定
mode = 'hyb';                    %書き出すデータ種別を指定．hyb:複合航法結果，GPS:GPSデータ
point_color = 'M';               %マーカの色指定'Y','M','C','R','G','B','W','K'
track_color = 'M';               %取り敢えず指定する（いじらなくてOK）
col_offset = 2;                  %読み飛ばす列の数(左から2列目に文字列データがあるので2列分を読み飛ばす，いじらなくてOK)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpd = fopen(data_fn,'rt');       %1行目，ヘッダ文字列の解析
tmp = fgetl(fpd);                %1行取ってくる
n=length(tmp);
j=1;
k=1;
for i = 1 : n                    %カンマ区切りでヘッダ文字列をセル配列に代入
    if tmp(i)~=','
        continue;
    else
        head{k} = tmp(j:i-1);
        j=i+1;
        k=k+1;
    end
end
head(1:col_offset) = [];         %読み飛ばし列数だけ削除
if strcmp(mode,'hyb')            %書き出す緯度，経度，高度の列番号を探す
    lat = strmatch('Lat',head);
    lon = strmatch('Lon',head);
    alt = strmatch('Alt',head);
elseif strcmp(mode, 'GPS')
    lat = strmatch('GPS lat',head);
    lon = strmatch('GPS lon',head);
    alt = strmatch('GPS alt',head);
end      

sat = strmatch('GPS sat',head);
pdop = strmatch('GPS PDOP',head);
gpstime = strmatch('GPS UTC',head);
gps_vel = strmatch('GPS vel',head);

fclose(fpd);
DATA = csvread(data_fn,1,col_offset);   %csvデータの読み込み
data.pos = [DATA(5:end,lat) DATA(5:end,lon) DATA(5:end,alt)];
data.sat = [DATA(5:end,sat) DATA(5:end,pdop) DATA(5:end,gpstime) DATA(5:end,gps_vel)];
no_data = length(data.pos(:,1));
for i = 1 : no_data
    data.time(i,:) = weeksow2dtime([1858,i]);   %取り敢えずweekを1858に固定して2015年8月16日0時0分1秒からの連番を振ってる
end


output_kml(file,data,track_color,point_color);
