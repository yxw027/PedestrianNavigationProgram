function output_nmea(file,data)
%-------------------------------------------------------------------------------
% Function : NMEAフォーマット出力
% 
% [argin]
% file : ファイル名
% data : n×9 エポック時刻 (Y,M,D,H,M,S, lat,lon,Ell.H, num_sat, dop)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: July 3, 2008
%-------------------------------------------------------------------------------

% NaNを除外
%--------------------------------------------
i=find(~isnan(data.pos(:,1)));

% TIME
%--------------------------------------------
time=data.time(i,5:10);

% POSITION
%--------------------------------------------
pos=data.pos(i,4:6);
h=geoidh(pos(1,1:2));

% No. of Sat
%--------------------------------------------
num=data.prn{3}(i,3);

% DOP
%--------------------------------------------
dop=data.prn{3}(i,4);

% POSITION NMEA用に変換
%--------------------------------------------
dd=floor(pos(:,1:2));																% 度 
ss=((pos(:,1:2)-dd))*60;															% 分 
mm=floor(ss);																		% 分(整数部分)
ss=ss-mm;																			% 分(小数点以下の部分)

% ローカルタイム
%--------------------------------------------
ltime(:,1) = time(:,4)+9;
ltime(:,2) = time(:,5);
ltime(find(ltime(:,1)>24),1) = ltime(find(ltime(:,1)>24),1)-24;


% ファイル出力
%--------------------------------------------

% $GPGGA,m1,m2,N,m3,E,d1,d2,f1,f2,M,f3,M,f4,d3*cc
%--------------------------------------------
% m1: hh:mm:ss 観測時刻(UTC)
% m2: NN nn.nnnnnn[N] 北緯NN度nn.nnnnnn分
% m3: EE ee.eeeeee[E] 東経EE度ee.eeeeee分
% d1: 測位状況　0：測位利用不可　1:SPS, 2:DGPS, 3:PPS, 4:RTK, 5:Float RTK, ...
% d2: 使用衛星数
% f1: 水平測位誤差(HDOP)
% f2: 水平測位誤差[m]
% f3: ジオイド高[m] 

% $GPZDA,f1,d1,d2,d3,d4,d5*cc
%--------------------------------------------
% f1: 測位時刻(UTC)　12:35:19.00 → 123519.00
% d1: 日(UTC)
% d2: 月(UTC)
% d3: 年(UTC)
% d4: 時(ローカル時間)
% d5: 分(ローカル時間)
% cc: checksum

% ファイルオープン
%--------------------------------------------
fp=fopen(file,'w');

for n=1:size(pos,1)

	% $GPGGA,m1,m2,N,m3,E,d1,d2,f1,f2,M,f3,M,f4,d3*cc
	%--------------------------------------------
	m1=sprintf('%02d%02d%05.2f',time(n,4),time(n,5),time(n,6));								% 時刻の出力フォーマット
	m2=sprintf('%02d%02d.%06.0f',dd(n,1),mm(n,1),ss(n,1)*1e6);								% 緯度の出力フォーマット
	m3=sprintf('%03d%02d.%06.0f',dd(n,2),mm(n,2),ss(n,2)*1e6);								% 経度の出力フォーマット
	d1=sprintf('%1d',1);																	% 測位状況の出力フォーマット
	d2=sprintf('%02d',num(n,1));															% 使用衛星数の出力フォーマット
	f1=sprintf('%2.1f',dop(n,1));															% 水平測位誤差の出力フォーマット
	f2=sprintf('%07.2f',pos(n,3));															% 水平測位誤差の出力フォーマット
	f3=sprintf('%04.1f',pos(n,3));															% ジオイド高の出力フォーマット

	gpgga=sprintf('$GPGGA,%s,%s,N,%s,E,%s,%s,%s,%s,M,%s,M,,',m1,m2,m3,d1,d2,f1,f2,f3);		% GPGGAの出力フォーマット
	checksum=nmeachecksum(gpgga);															% GPGGAのchecksum
	fprintf(fp,'%s*%s\n',gpgga,checksum);													% GPGGAをファイルに出力

	% $GPZDA,f1,d1,d2,d3,d4,d5*cc
	%--------------------------------------------
	f1=sprintf('%02d%02d%05.2f',time(n,4),time(n,5),time(n,6));								% 時刻の出力フォーマット
	d1=sprintf('%02d',time(n,3));															% 日の出力フォーマット
	d2=sprintf('%02d',time(n,2));															% 月の出力フォーマット
	d3=sprintf('%4d',time(n,1));															% 年の出力フォーマット
	d4=sprintf('%02d',ltime(n,1));															% 時(ローカル時間)の出力フォーマット
	d5=sprintf('%02d',ltime(n,2));															% 分(ローカル時間)の出力フォーマット

	gpzda=sprintf('$GPZDA,%s,%s,%s,%s,%s,%s',f1,d1,d2,d3,d4,d5);							% GPZDAの出力フォーマット
	checksum=nmeachecksum(gpzda);															% GPZDAのchecksum
	fprintf(fp,'%s*%s\n',gpzda,checksum);													% GPZDAをファイルに出力

end
fclose('all');



%-------------------------------------------------------------------------------
% 以下, サブルーチン

% checksumを求める関数
%--------------------------------------------
function checksum = nmeachecksum(NMEA_String)

checksum = 0;

% see if string contains the * which starts the checksum and keep string
% upto * for generating checksum
NMEA_String = strtok(NMEA_String,'*');

NMEA_String_d = double(NMEA_String);													% convert characters in string to double values
for count = 2:length(NMEA_String)														% checksum calculation ignores $ at start
	checksum = bitxor(checksum,NMEA_String_d(count));									% checksum calculation
	checksum = uint16(checksum);														% make sure that checksum is unsigned int16
end

% convert checksum to hex value
checksum = double(checksum);
checksum = dec2hex(checksum);

% add leading zero to checksum if it is a single digit, e.g. 4 has a 0
% added so that the checksum is 04
if length(checksum) == 1
	checksum = strcat('0',checksum);
end
