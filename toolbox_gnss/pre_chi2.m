function [sigma,Vb,Gb] = pre_chi2(A,b)
%-------------------------------------------------------------------------------
% Function : ���`�����̃J�C��挟��(�A���G�|�b�N)��臒l, �����։��s��v�Z
% 
% [argin]
% A     : �L�Ӑ���(�댯��)�̍\����(*.a_mp1, *.a_mp2, *.a_mw, *.a_lgl, *.b_mp1, *.b_mp2, *.b_mw, *.b_lgl)
% b     : �ő厩�R�x
%
% [argout]
% sigma : 臒l(�㑤�m���_)�̍\����(*.a_mp1, *.a_mp2, *.a_mw, *.a_lgl, *.b_mp1, *.b_mp2, *.b_mw, *.b_lgl)
% Vb    : �ϑ��G���ϊ��s��
% Gb    : �����։��s��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Feb. 23, 2009
%-------------------------------------------------------------------------------
% sigma�Ɗ댯�����\���̂ɕύX
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------

sigma.mp1(1:b) = NaN;, sigma.mp2(1:b) = NaN;, sigma.mw(1:b) = NaN;, sigma.lgl(1:b) = NaN;
sigma.a_mp1(1:b) = NaN;, sigma.a_mp2(1:b) = NaN;, sigma.a_mw(1:b) = NaN;, sigma.a_lgl(1:b) = NaN;
sigma.b_mp1(1:b) = NaN;, sigma.b_mp2(1:b) = NaN;, sigma.b_mw(1:b) = NaN;, sigma.b_lgl(1:b) = NaN;

for i=1:b
	Vb(i,i) = (b-i+2)/(b-i+1)./2;
	for k=1:b
		Gb(i,k) = (b-k+1)/(b-i+1);
	end
	sigma.mp1(i) = chi2a(i,A.a_mp1);
	sigma.mp2(i) = chi2a(i,A.a_mp2);
	sigma.mw(i) = chi2a(i,A.a_mw);
	sigma.lgl(i) = chi2a(i,A.a_lgl);

	sigma.a_mp1(i) = chi2a(i,A.a_mp1);
	sigma.a_mp2(i) = chi2a(i,A.a_mp2);
	sigma.a_mw(i) = chi2a(i,A.a_mw);
	sigma.a_lgl(i) = chi2a(i,A.a_lgl);

	sigma.b_mp1(i) = chi2a(i,A.b_mp1);
	sigma.b_mp2(i) = chi2a(i,A.b_mp2);
	sigma.b_mw(i) = chi2a(i,A.b_mw);
	sigma.b_lgl(i) = chi2a(i,A.b_lgl);
end
Gb = triu(Gb);


