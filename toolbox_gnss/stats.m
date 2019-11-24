function [m,s,r]=stats(x)
%-------------------------------------------------------------------------------
% Function : ���v��(mean, std, rms)�̌v�Z
% 
% [argin]
% x : ���茋��
% 
% [argout]
% m : mean
% s : std
% r : rms
% 
% NaN������ꍇ�ł��v�Z�ł���悤�ɂ��Ă��܂�
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 24, 2008
%-------------------------------------------------------------------------------

m = mean(x(find(~isnan(x(:,1))),1));							% ����
s = std(x(find(~isnan(x(:,1))),1));								% �W���΍�
r = sqrt(mean(x(find(~isnan(x(:,1))),1).^2));					% RMS
