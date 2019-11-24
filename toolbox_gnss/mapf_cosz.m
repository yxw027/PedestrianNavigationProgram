function [md,mw]=mapf_cosz(ele)
%-------------------------------------------------------------------------------
% Function : 対流圏遅延 マッピング関数 cosz
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

% md=1./cos(pi/2-ele);
% mw=1./cos(pi/2-ele);
md=1./sin(ele);
mw=1./sin(ele);
