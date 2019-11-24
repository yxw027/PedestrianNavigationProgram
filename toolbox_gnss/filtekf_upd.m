function [x_f, P_f, V] = filtekf_upd(Z, H, R, x, P)
%-------------------------------------------------------------------------------
% extended Kalman filter update calculation
% Y. Kubo (Ritsumeikan Univ., Dept of EEE, Sugimoto Lab.)
% Last modified on November 18, 1999
%
%
% Function : 拡張カルマンフィルタ演算(観測更新)
%
% [argin]
% Z   : mx1 イノベーションベクトル: y-h(x^)
% H   : mxn 観測行列: 線形化した際の偏微分係数
% R   : mxm 観測雑音共分散行列
% x   : nx1 一段予測値
% P   : nxn 一段予測値の推定誤差共分散行列
%
% [argout]
% x_f : nx1 濾波推定値
% P_f : nxn 濾波推定値の推定誤差共分散行列
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

% カルマンゲインの計算
%--------------------------------------------
   
K = P*H'*inv(H*P*H'+R);
%size(K)

% 濾波推定値の計算
%--------------------------------------------
x_f = x + K*Z;

%
%--------------------------------------------
P_f = P - K*H*P;

I=eye(length(Z));
V=(I-H*K)*Z;
Pv=H*P_f*H'+R;
