function [x_p, P_p] = filtekf_pre(x_f,P_f, F, Q, gam)
%-------------------------------------------------------------------------------
% H_infinity filter update calculation
% Y. Kubo (Ritsumeikan Univ., Dept of EEE, Sugimoto Lab.)
% Last modified on November 18, 1999
%
%
% Function : 拡張カルマンフィルタ演算(時間更新)
%
% [argin]
% x_f   : nx1 濾波推定値
% P_f   : nxn 濾波推定値の推定誤差共分散行列
% F     : nxn 状態推移行列
% Q     : nxn システム雑音共分散行列
% gamma : 1x1 フィルタ設計パラメータ >0
%
% [argout]
% x_p   : nx1 一段予測値
% P_p   : nxn 一段予測値の推定誤差共分散行列
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

% 一段予測値の次元
%--------------------------------------------
size_of_state = size(x_f,1);

% 一段予測値の計算
%--------------------------------------------
x_p = F*x_f;

% 推定誤差共分散行列の更新
%--------------------------------------------
P_p = F*P_f*F' + Q + F*P_f*(gam^2*eye(size_of_state)-P_f)^(-1)*P_f*F';
