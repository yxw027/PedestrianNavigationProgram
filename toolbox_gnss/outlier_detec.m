function [lim,chi2,rej,lcbb]=outlier_detec(est_prm,timetag,LC,LC_r,sigma,REJ,prn,Vb,Gb)
%-------------------------------------------------------------------------------
% Function : 線形結合による異常値検定
%
% [argin]
% est_prm : 設定パラメータ
% timetag : タイムタグ
% LC      : 線形結合(構造体)
% LC_r    : 除外衛星を考慮した線形結合(構造体)
% sigma   : 閾値(上側確率点)
% REJ     : 除外衛星関連の構造体(*.rov, *.rej)
% prn     : 可視衛星(prn.rov.v)
% Vb      : 観測雑音変換行列
% Gb      : 無相関化行列
%
% [argout]
% lim    : 閾値
% chi2   : カイ二乗値
% rej    : 除外衛星
% lcbb   : 自由度
%
% cycle_slipのプログラムをサブ関数化
% 各種線形結合を構造体で格納
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru, T.Yanase : Jan. 20, 2010
%-------------------------------------------------------------------------------

rej.mp1  = [];
rej.mp2  = [];
rej.mw   = [];
rej.lgl  = [];

lim=[];
chi2=[];
lcbb=[];

switch est_prm.cs_mode
case 2,			% 線形結合利用(閾値は標準偏差)
	lim.mp1  = [];
	lim.mp2  = [];
	lim.mw   = [];
	lim.lgl  = [];
	lim.lgp  = [];
	lim.lg1  = [];
	lim.lg2  = [];
	lim.ionp = [];
	lim.ionl = [];

	%--- 閾値計算
	%------------------------------------------
	if timetag>est_prm.cycle_slip.lc_int+1
		lim = lc_lim(est_prm,timetag,LC,REJ);		% lc_lim(est_prm,timetag,線形結合格納配列,スリップ検出衛星格納配列)
	end

case 3,			% 線形結合利用(χ2検定)
	chi2.lgl = [];
	chi2.mw  = [];
	chi2.mp1 = [];
	chi2.mp2 = [];

	%--- χ2検定
	%------------------------------------------
	[chi2,rej] = lc_chi2(timetag,LC,sigma);

case 4,			% 線形結合利用(χ2検定)
	chi2.lgl = [];
	chi2.mw  = [];
	chi2.mp1 = [];
	chi2.mp2 = [];

	%--- χ2検定
	%------------------------------------------
	[chi2,rej,lcbb] = lc_chi2r(timetag,LC,LC_r,sigma,est_prm.cycle_slip.lc_b,Vb,Gb,prn);
end


