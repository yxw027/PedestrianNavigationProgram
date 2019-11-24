function [lim,chi2,rej,lcbb]=outlier_detec(est_prm,timetag,LC,LC_r,sigma,REJ,prn,Vb,Gb)
%-------------------------------------------------------------------------------
% Function : ���`�����ɂ��ُ�l����
%
% [argin]
% est_prm : �ݒ�p�����[�^
% timetag : �^�C���^�O
% LC      : ���`����(�\����)
% LC_r    : ���O�q�����l���������`����(�\����)
% sigma   : 臒l(�㑤�m���_)
% REJ     : ���O�q���֘A�̍\����(*.rov, *.rej)
% prn     : ���q��(prn.rov.v)
% Vb      : �ϑ��G���ϊ��s��
% Gb      : �����։��s��
%
% [argout]
% lim    : 臒l
% chi2   : �J�C���l
% rej    : ���O�q��
% lcbb   : ���R�x
%
% cycle_slip�̃v���O�������T�u�֐���
% �e����`�������\���̂Ŋi�[
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru, T.Yanase : Jan. 20, 2010
%-------------------------------------------------------------------------------

rej.mp1  = [];
rej.mp2  = [];
rej.mw   = [];
rej.lgl  = [];

lim=[];
chi2=[];
lcbb=[];

switch est_prm.cs_mode
case 2,			% ���`�������p(臒l�͕W���΍�)
	lim.mp1  = [];
	lim.mp2  = [];
	lim.mw   = [];
	lim.lgl  = [];
	lim.lgp  = [];
	lim.lg1  = [];
	lim.lg2  = [];
	lim.ionp = [];
	lim.ionl = [];

	%--- 臒l�v�Z
	%------------------------------------------
	if timetag>est_prm.cycle_slip.lc_int+1
		lim = lc_lim(est_prm,timetag,LC,REJ);		% lc_lim(est_prm,timetag,���`�����i�[�z��,�X���b�v���o�q���i�[�z��)
	end

case 3,			% ���`�������p(��2����)
	chi2.lgl = [];
	chi2.mw  = [];
	chi2.mp1 = [];
	chi2.mp2 = [];

	%--- ��2����
	%------------------------------------------
	[chi2,rej] = lc_chi2(timetag,LC,sigma);

case 4,			% ���`�������p(��2����)
	chi2.lgl = [];
	chi2.mw  = [];
	chi2.mp1 = [];
	chi2.mp2 = [];

	%--- ��2����
	%------------------------------------------
	[chi2,rej,lcbb] = lc_chi2r(timetag,LC,LC_r,sigma,est_prm.cycle_slip.lc_b,Vb,Gb,prn);
end


