function [lost,rise,i_lost,i_rise,change_flag] = prn_check(prn_old,prn_used)
%-------------------------------------------------------------------------------
% Function : �q���̕ω����o
% 
% [argin]
% prn_old  : �O�G�|�b�N�Ŏg�p�����q����PRN
% prn_used : ���G�|�b�N�Ŏg�p����q����PRN
%
% [argout]
% lost        : �������q����PRN
% rise        : �������q����PRN
% i_lost      : �������q���̃C���f�b�N�X
% i_rise      : �������q���̃C���f�b�N�X
% change_flag : �q���ω��̃t���O(0:�Ȃ�, 1:����)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 5, 2006
%-------------------------------------------------------------------------------

[lost,i_lost] = setdiff(prn_old,prn_used);				% �������q���ƃC���f�b�N�X
[rise,i_rise] = setdiff(prn_used,prn_old);				% �������q���ƃC���f�b�N�X
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
