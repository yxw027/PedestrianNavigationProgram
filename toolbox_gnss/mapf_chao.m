function [md,mw]=mapf_chao(ele)
%-------------------------------------------------------------------------------
% Function : �Η����x�� �}�b�s���O�֐� chao
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

md=1./(sin(ele)+(0.00143./(tan(ele)+0.0445)));			% ZHD �}�b�s���O�֐�
mw=1./(sin(ele)+(0.00035./(tan(ele)+0.017)));			% ZWD �}�b�s���O�֐�
