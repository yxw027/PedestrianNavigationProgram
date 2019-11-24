function [data,dtr,ttime,clk_jump,dtr_o,jump_width_all]=clkjump_repair2(ttime,data,dtr,dtr_o,jump_width_all,Rec_type)
%-------------------------------------------------------------------------------
% Function : clock jump の検出・修正
%--------------------------------------------
% |dtrのエポック間差| > 0.5ms → 飛びと判定
% dtrのエポック間差を飛び幅としms単位に丸める
% 時刻, 観測データ, dtr から飛び幅を減算
%--------------------------------------------
% 
% [argin]
% ttime          : 補正前時刻(year month day hour minute sec)
% data           : 補正前観測データ
% dtr            : 単独測位で求めた受信機時計誤差(今エポック)
% dtr_o          : 単独測位で求めた受信機時計誤差(前エポック)
% jump_width_all : ジャンプ幅の累積値[sec]
% Rec_type       : 受信機タイプ
% 
% [argout]
% data           : 補正済み観測データ
% dtr            : 補正済み受信機時計誤差
% ttime          : 補正済み時刻(year month day hour minute sec)
% clk_jump       : ジャンプフラグ
% dtr_o          : 単独測位で求めた受信機時計誤差(今エポック) --- 次のエポック用
% jump_width_all : ジャンプ幅の累積値[sec]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 03, 2008
%-------------------------------------------------------------------------------

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

% clock jump の検出
%--------------------------------------------
clk_jump = 0;											% jump flag
if isempty(dtr_o)										% 1エポック目
	jump_width_all = 0;									% ジャンプ幅の累積値の初期値
else													% 2エポック以降
	dtr_td = (dtr - dtr_o)*(1e+3);						% 受信機時計誤差のエポック間差(msec)
	if abs(dtr_td) > 0.5								% ジャンプ検出(エポック間差絶対値が0.5msec以上)
		clk_jump = 1;									% ジャンプフラグ
		jump_width = round(dtr_td(end,1))*(1e-3);		% ジャンプ幅(sec)
		jump_width_all = jump_width_all + jump_width;	% ジャンプ幅の累積値(sec)
	end
end
dtr_o = dtr;											% 次のエポックのため


% clock jump の修正
%--------------------------------------------
if ~isempty(findstr(char(Rec_type),'TRIMBLE 5700'))
	% TRIMBLE 5700仕様(NETRS は修正不要)
	% Timetag offset & 擬似距離に飛びがある
	%--------------------------------------------
	data(:,2) = data(:,2) - C*jump_width_all;			% CA
	data(:,6) = data(:,6) - C*jump_width_all;			% PY
	data(:,1) = data(:,1);								% L1
	data(:,5) = data(:,5);								% L2
	ttime(6) = ttime(6) - jump_width_all;				% 時刻情報を修正
	dtr = dtr - jump_width_all;							% 受信機時計誤差を修正
end
if ~isempty(findstr(char(Rec_type),'TPS LEGACY'))
	% Topcon TPS LEGACY仕様
	% Timetag offset & 擬似距離 & 搬送波位相に飛びがある
	%--------------------------------------------
	data(:,2) = data(:,2) - C*jump_width_all;			% CA
	data(:,6) = data(:,6) - C*jump_width_all;			% PY
	data(:,1) = data(:,1) - f1*jump_width_all;			% L1
	data(:,5) = data(:,5) - f2*jump_width_all;			% L2
	ttime(6) = ttime(6) - jump_width_all;				% 時刻情報を修正
	dtr = dtr - jump_width_all;							% 受信機時計誤差を修正
end
if ~isempty(findstr(char(Rec_type),'U-BLOX'))
	% U-BLOX仕様
	% Timetag offset & 擬似距離に飛びがある
	%--------------------------------------------
	data(:,2) = data(:,2) - C*jump_width_all;			% CA
	data(:,6) = data(:,6) - C*jump_width_all;			% PY
	data(:,1) = data(:,1);								% L1
	data(:,5) = data(:,5);								% L2
	ttime(6) = ttime(6) - jump_width_all;				% 時刻情報を修正
	dtr = dtr - jump_width_all;							% 受信機時計誤差を修正
end
