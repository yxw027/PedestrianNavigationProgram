function [lost,rise,i_lost,i_rise,change_flag] = prn_check(prn_old,prn_used)
%-------------------------------------------------------------------------------
% Function : 衛星の変化検出
% 
% [argin]
% prn_old  : 前エポックで使用した衛星のPRN
% prn_used : 今エポックで使用する衛星のPRN
%
% [argout]
% lost        : 消えた衛星のPRN
% rise        : 増えた衛星のPRN
% i_lost      : 消えた衛星のインデックス
% i_rise      : 増えた衛星のインデックス
% change_flag : 衛星変化のフラグ(0:なし, 1:あり)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 5, 2006
%-------------------------------------------------------------------------------

[lost,i_lost] = setdiff(prn_old,prn_used);				% 消えた衛星とインデックス
[rise,i_rise] = setdiff(prn_used,prn_old);				% 増えた衛星とインデックス
if isempty(lost) ~= 1
	change_flag = 1;
else
	change_flag = 0;
	if isempty(rise) ~= 1
		change_flag = 1;
	else
		change_flag = 0;
	end
end
