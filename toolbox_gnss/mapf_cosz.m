function [md,mw]=mapf_cosz(ele)
%-------------------------------------------------------------------------------
% Function : �Η����x�� �}�b�s���O�֐� cosz
% 
% [argin]
% ele  : �p[rad]
% 
% [argout]
% md : dry �}�b�s���O�֐�
% mw : wet �}�b�s���O�֐�
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

% md=1./cos(pi/2-ele);
% mw=1./cos(pi/2-ele);
md=1./sin(ele);
mw=1./sin(ele);
