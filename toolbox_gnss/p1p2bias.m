function bias = p1p2bias(time,PRN)
%-------------------------------------------------------------------------------
% Function : P1-P2バイアス
%
% [argin]
% PRN  : 衛星PRN番号
% time : 時刻
%
% [argout]
% bias : P1-P2バイアス[m](data_biasの要素は[ns])
% 
% ※ 解析したい日に応じて使い分けること.
%    ftp://ftp.unibe.ch/aiub/CODE/ にDCBのファイルはあります.
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

persistent data_bias

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

%--- P1P2DCB取得
%--------------------------------------------
if isempty(data_bias)
	% ファイルオープン
	%--------------------------------------------
	dirs=[fileparts(which('p1p2bias')),'/P1P2DCB/'];					% ディレクトリ
	filen=sprintf('%sP1P2%02d%02d.DCB',dirs,mod(time(1),100),time(2));	% ファイル名
	fpo=fopen(filen,'rt');												% ファイルオープン

	if fpo~=-1
		% ヘッダー部(読み飛ばし)
		%--------------------------------------------
		for i=1:7
			temp = fgetl(fpo);											% 1行取得
		end

		% データ部
		%--------------------------------------------
		data_bias(1:32,1:3)=0;											% 配列の準備(初期値は0)
		while 1
			temp = fgetl(fpo);											% 1行取得

			% 終了処理(tempが空の場合)
			%--------------------------------------------
			if isempty(temp), break;, end

			% 終了処理(EOFの場合)
			%--------------------------------------------
			if feof(fpo), break;, end

			% データ取得
			%--------------------------------------------
			if temp(1)=='G'												% GPSのみ
				data=str2num(temp(2:end));
				data_bias(data(1),:)=data;								% データ格納
			end
		end
	else
		data_bias(1:32,1:3)=0;
	end
end

bias = C*(data_bias(PRN,2))*1e-9;										% 距離に変換
