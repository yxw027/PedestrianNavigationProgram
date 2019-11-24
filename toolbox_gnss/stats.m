function [m,s,r]=stats(x)
%-------------------------------------------------------------------------------
% Function : 統計量(mean, std, rms)の計算
% 
% [argin]
% x : 推定結果
% 
% [argout]
% m : mean
% s : std
% r : rms
% 
% NaNがある場合でも計算できるようにしています
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 24, 2008
%-------------------------------------------------------------------------------

m = mean(x(find(~isnan(x(:,1))),1));							% 平均
s = std(x(find(~isnan(x(:,1))),1));								% 標準偏差
r = sqrt(mean(x(find(~isnan(x(:,1))),1).^2));					% RMS
