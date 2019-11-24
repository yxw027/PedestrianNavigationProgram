function [Data] = read_sp3(sp3_file)
%-------------------------------------------------------------------------------
% Function : 精密暦(SP3)データ読み込みプログラム
%
% [argin]
% sp3_file : sp3ファイル名
%
% [argout]
% Data     : 衛星座標・衛星時計誤差など
%            [week,tow,tod,X,Y,Z,clk]を衛星ごとに多次元で格納(page=PRNで)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

% sp3ファイルのオープン
%--------------------------------------------
fporb = fopen(sp3_file);											% データファイルのオープン(精密暦)

% sp3ファイル読み込み(ヘッダー情報取得)
%--------------------------------------------
temp = fgetl(fporb);												% 1行目読み飛ばし

temp = fgetl(fporb);												% 2行目取得
sp3_dt = str2num(temp(25:38));										% sp3データの更新間隔読み取り

temp = fgetl(fporb);												% 3行目取得
prn_num = str2num(temp(4:6));										% 衛星数

%	要らないヘッダ部分の読み飛ばし(4～22行目)
for i=4:22
	temp = fgetl(fporb);
end


% sp3ファイル読み込み(X,Y,Z,clkの取得)
%    軌道[km]→[m]に変換
%    衛星時計誤差[μs]→[s]に変換
%--------------------------------------------
timetag = 0;														% タイムタグ初期値

while 1

	timetag = timetag + 1;											% タイムタグ

	temp = fgetl(fporb);											% 1行読み込み

	e_o_h = findstr(temp,'EOF');									% EOFの検索
	if ~isempty(e_o_h)												% 終了判定
		break;
	end

	[tt temp] = strtok(temp);										% 時刻と'*'の分離(文字列)
	date = str2num(temp);											% 時刻の数字化
	ToD = round(date(4)*3600 + date(5)*60 + date(6));				% Time of Day

	mjd = mjuliday(date);											% ユリウス暦

	[WEEK,ToW] = weekf(mjd);										% WEEK, Time of Week

	Data(timetag,1:7,1:32)=NaN;
	for ii = 1 : prn_num											% 全衛星のデータ取得
		temp = fgetl(fporb);
		data = str2num(temp(3:60))';								% PRN, X, Y, Z, CLK
		if data(5) == 999999.999999
			data(5)=NaN;
		end
		Data(timetag,:,data(1)) = ...
				[WEEK ToW ToD data(2:4)'*(10^3) data(5)*(10^(-6))];	% データ格納(多次元配列)
	end

end
