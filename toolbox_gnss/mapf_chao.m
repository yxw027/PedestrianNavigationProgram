function [md,mw]=mapf_chao(ele)
%-------------------------------------------------------------------------------
% Function : 対流圏遅延 マッピング関数 chao
% 
% [argin]
% ele  : 仰角[rad]
% 
% [argout]
% md : dry マッピング関数
% mw : wet マッピング関数
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

md=1./(sin(ele)+(0.00143./(tan(ele)+0.0445)));			% ZHD マッピング関数
mw=1./(sin(ele)+(0.00035./(tan(ele)+0.017)));			% ZWD マッピング関数
