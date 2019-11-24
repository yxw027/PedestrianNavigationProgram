function [sigma,Vb,Gb] = pre_chi2(A,b)
%-------------------------------------------------------------------------------
% Function : 線形結合のカイ二乗検定(連続エポック)の閾値, 無相関化行列計算
% 
% [argin]
% A     : 有意水準(危険率)の構造体(*.a_mp1, *.a_mp2, *.a_mw, *.a_lgl, *.b_mp1, *.b_mp2, *.b_mw, *.b_lgl)
% b     : 最大自由度
%
% [argout]
% sigma : 閾値(上側確率点)の構造体(*.a_mp1, *.a_mp2, *.a_mw, *.a_lgl, *.b_mp1, *.b_mp2, *.b_mw, *.b_lgl)
% Vb    : 観測雑音変換行列
% Gb    : 無相関化行列
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Feb. 23, 2009
%-------------------------------------------------------------------------------
% sigmaと危険率を構造体に変更
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------

sigma.mp1(1:b) = NaN;, sigma.mp2(1:b) = NaN;, sigma.mw(1:b) = NaN;, sigma.lgl(1:b) = NaN;
sigma.a_mp1(1:b) = NaN;, sigma.a_mp2(1:b) = NaN;, sigma.a_mw(1:b) = NaN;, sigma.a_lgl(1:b) = NaN;
sigma.b_mp1(1:b) = NaN;, sigma.b_mp2(1:b) = NaN;, sigma.b_mw(1:b) = NaN;, sigma.b_lgl(1:b) = NaN;

for i=1:b
	Vb(i,i) = (b-i+2)/(b-i+1)./2;
	for k=1:b
		Gb(i,k) = (b-k+1)/(b-i+1);
	end
	sigma.mp1(i) = chi2a(i,A.a_mp1);
	sigma.mp2(i) = chi2a(i,A.a_mp2);
	sigma.mw(i) = chi2a(i,A.a_mw);
	sigma.lgl(i) = chi2a(i,A.a_lgl);

	sigma.a_mp1(i) = chi2a(i,A.a_mp1);
	sigma.a_mp2(i) = chi2a(i,A.a_mp2);
	sigma.a_mw(i) = chi2a(i,A.a_mw);
	sigma.a_lgl(i) = chi2a(i,A.a_lgl);

	sigma.b_mp1(i) = chi2a(i,A.b_mp1);
	sigma.b_mp2(i) = chi2a(i,A.b_mp2);
	sigma.b_mw(i) = chi2a(i,A.b_mw);
	sigma.b_lgl(i) = chi2a(i,A.b_lgl);
end
Gb = triu(Gb);


