function [chi2,rej] = lc_chi2(timetag,LC,sigma)
%-------------------------------------------------------------------------------
% Function : ���`�����̃J�C��挟��
% 
% [argin]
% timetag : timetag
% LC      : ���`�����i�[�z��
% sigma   : 臒l(�㑤�m���_)
%
% [argout]
% chi2  : �J�C���l
% rej   : ���O�q��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Feb. 23, 2009
%-------------------------------------------------------------------------------
% �\���̂ŏ���, ���͈����̍팸
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------

chi2.mp1 = (diff(LC.mp1(timetag-1:timetag,:))).^2./(2*LC.mp1_va(timetag,:));	% �J�C���l
chi2.mp2 = (diff(LC.mp2(timetag-1:timetag,:))).^2./(2*LC.mp2_va(timetag,:));	% �J�C���l
chi2.mw = (diff(LC.mw(timetag-1:timetag,:))).^2./(2*LC.mw_va(timetag,:));		% �J�C���l
chi2.lgl = (diff(LC.lgl(timetag-1:timetag,:))).^2./(2*LC.lgl_va(timetag,:));	% �J�C���l

rej.mp1 = find(chi2.mp1>=sigma.a_mp1);											% �J�C��挟��
rej.mp2 = find(chi2.mp2>=sigma.a_mp2);											% �J�C��挟��
rej.mw = find(chi2.mw>=sigma.a_mw);												% �J�C��挟��
rej.lgl = find(chi2.lgl>=sigma.a_lgl);											% �J�C��挟��

