function [kekka] = lc_kekka(REJ)
%-------------------------------------------------------------------------------
% Function : 線形結合によるサイクルスリップ検出閾値の計算
% 
% [argin]
% REJ   : 除外衛星リスト
%
% [argout]
% kekka : 正常除外and異常除外数リスト(行 : mp1 mp2 mw lgl, 列 : 正 誤)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Oct. 25, 2008

a = [82:40:700];																			% スリップ発生時刻設定
ss_prn = 16;																				% スリップ発生衛星

[row1,col1] = find(REJ.rov.mp1==ss_prn);
[row2,col2] = find(REJ.rov.mp2==ss_prn);
[row3,col3] = find(REJ.rov.mw==ss_prn);
[row4,col4] = find(REJ.rov.lgl==ss_prn);
[row5,col5] = find(REJ.rej==ss_prn);
true1 = length(intersect(a,row1));
true2 = length(intersect(a,row2));
true3 = length(intersect(a,row3));
true4 = length(intersect(a,row4));
true5 = length(intersect(a,row5));
fault1 = length(find(~isnan(REJ.rov.mp1))) - true1;
fault2 = length(find(~isnan(REJ.rov.mp2))) - true2;
fault3 = length(find(~isnan(REJ.rov.mw))) - true3;
fault4 = length(find(~isnan(REJ.rov.lgl))) - true4;
fault5 = length(find(~isnan(REJ.rej))) - true5;


kekka = [true1 fault1; true2 fault2; true3 fault3; true4 fault4; true5 fault5];

