function [chi2,rej] = lc_chi2(timetag,LC,sigma)
%-------------------------------------------------------------------------------
% Function : 線形結合のカイ二乗検定
% 
% [argin]
% timetag : timetag
% LC      : 線形結合格納配列
% sigma   : 閾値(上側確率点)
%
% [argout]
% chi2  : カイ二乗値
% rej   : 除外衛星
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Feb. 23, 2009
%-------------------------------------------------------------------------------
% 構造体で処理, 入力引数の削減
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------

chi2.mp1 = (diff(LC.mp1(timetag-1:timetag,:))).^2./(2*LC.mp1_va(timetag,:));	% カイ二乗値
chi2.mp2 = (diff(LC.mp2(timetag-1:timetag,:))).^2./(2*LC.mp2_va(timetag,:));	% カイ二乗値
chi2.mw = (diff(LC.mw(timetag-1:timetag,:))).^2./(2*LC.mw_va(timetag,:));		% カイ二乗値
chi2.lgl = (diff(LC.lgl(timetag-1:timetag,:))).^2./(2*LC.lgl_va(timetag,:));	% カイ二乗値

rej.mp1 = find(chi2.mp1>=sigma.a_mp1);											% カイ二乗検定
rej.mp2 = find(chi2.mp2>=sigma.a_mp2);											% カイ二乗検定
rej.mw = find(chi2.mw>=sigma.a_mw);												% カイ二乗検定
rej.lgl = find(chi2.lgl>=sigma.a_lgl);											% カイ二乗検定

