function [mp1,mp2,lgl,lgp,lg1,lg2,mw,ionp,ionl,lgl_ion,...
			mp1_va,mp2_va,lgl_va,lgp_va,lg1_va,lg2_va,mw_va,ionp_va,ionl_va] = obs_comb(est_prm,freq,wave,data,LC_variance,prn,ion,ele)
%-------------------------------------------------------------------------------
% Function : ���`����------L1,L2�т̊ϑ��ʂ̊e����`�����ƕ��U���v�Z
% 
% [argin]
% est_prm : �ݒ�p�����[�^
% freq    : ���g���̍\����(*.g1, *.g2, *.r1, *.r2)
% wave    : �g���̍\����(*.g1, *.g2, *.r1, *.r2)
% data    : �ϑ��f�[�^
% LC      : ���`����(�\����)
% prn     : �q��PRN�ԍ�(�\����)(rov or ref)
% ion     : �d���w�x���f�[�^
% ele     : �p
% 
% [argout]
% mp1     : Multipath ���`����(L1)
% mp2     : Multipath ���`����(L2)
% lgl     : �􉽊w�t���[���`����(�����g)
% lgp     : �􉽊w�t���[���`����(�R�[�h)
% lg1     : �􉽊w�t���[���`����(1���g)
% lg2     : �􉽊w�t���[���`����(2���g)
% mw      : Melbourne-Wubbena ���`����
% ionp    : �d���w(lgp����Z�o)
% ionl    : �d���w(lgl����Z�o,N���܂�)
% lgl_ion : �􉽊w�t���[���`����(�����g)-�d���w�x����
% mp1_va     : Multipath ���`����(L1)�̕��U
% mp2_va     : Multipath ���`����(L2)�̕��U
% lgl_va     : �􉽊w�t���[���`����(�����g)�̕��U
% lgp_va     : �􉽊w�t���[���`����(�R�[�h)�̕��U
% lg1_va     : �􉽊w�t���[���`����(1���g)�̕��U
% lg2_va     : �􉽊w�t���[���`����(2���g)�̕��U
% mw_va      : Melbourne-Wubbena ���`�����̕��U
% ionp_va    : �d���w(lgp����Z�o)�̕��U
% ionl_va    : �d���w(lgl����Z�o,N���܂�)�̕��U
% lgl_ion_va : �􉽊w�t���[���`����(�����g)-�d���w�x�����̕��U
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: August 1, 2007
%-------------------------------------------------------------------------------
% �􉽊w�t���[���`����(�����g)-�d���w�x�����ǉ�
% May 15, 2009, Y.Ishimaru
%-------------------------------------------------------------------------------
% GLONASS�̎��g��, �g���̕ω��ɑΉ�
% January 18, 2010, T.Yanase
%-------------------------------------------------------------------------------
% ���U�������ɓ��o
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------


% �萔(�O���[�o���ϐ�)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- �萔
%--------------------------------------------
C=299792458;							% ����
% f1=1.57542e9;  lam1=C/f1;				% L1 ���g�� & �g��
% f2=1.22760e9;  lam2=C/f2;				% L2 ���g�� & �g��
% 
% OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
% MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
% FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

pr=data(:,2);							% CA
pr_g=data(1:length(prn.vg),2);			% CA(GPS)
pr_r=data(length(prn.vg)+1:length(prn.vg)+length(prn.vr),2);		% CA(GLONASS)
pr2=data(:,6);							% PY
pr2_g=data(1:length(prn.vg),6);			% PY(GPS)
pr2_r=data(length(prn.vg)+1:length(prn.vg)+length(prn.vr),6);		% PY(GLONASS)
adr1=data(:,1);							% L1
adr1_g=data(1:length(prn.vg),1);		% L1(GPS)
adr1_r=data(length(prn.vg)+1:length(prn.vg)+length(prn.vr),1);		% L1(GLONASS)
adr2=data(:,5);							% L2
adr2_g=data(1:length(prn.vg),5);		% L2(GPS)
adr2_r=data(length(prn.vg)+1:length(prn.vg)+length(prn.vr),5);		% L2(GLONASS)

ion_g=ion(1:length(prn.vg));			% ion(GPS)
ion_r=ion(length(prn.vg)+1:length(prn.vg)+length(prn.vr));			% ion(GLONASS)

pr_va=LC_variance(:,1);							% CA���U
pr_g_va=LC_variance(1:length(prn.vg),1);		% CA���U(GPS)
pr_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),2);		% CA���U(GLONASS)
pr2_va=LC_variance(:,2);						% PY���U
pr2_g_va=LC_variance(1:length(prn.vg),2);		% PY���U(GPS)
pr2_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),2);		% PY���U(GLONASS)
adr1_va=LC_variance(:,3);						% L1���U
adr1_g_va=LC_variance(1:length(prn.vg),3);		% L1���U(GPS)
adr1_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),3);	% L1���U(GLONASS)
adr2_va=LC_variance(:,4);						% L2���U
adr2_g_va=LC_variance(1:length(prn.vg),4);		% L2���U(GPS)
adr2_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),4);	% L2���U(GLONASS)

ion_g_va=ion(1:length(prn.vg));					% ion���U(GPS)
ion_r_va=ion(length(prn.vg)+1:length(prn.vg)+length(prn.vr));				% ion���U(GLONASS)


% Multipath ���`����
%--------------------------------------------
mp1_g=[];, mp1_r=[];
mp2_g=[];, mp2_r=[];
mp1_g_va=[];, mp1_r_va=[];
mp2_g_va=[];, mp2_r_va=[];

% �􉽊w�t���[���`����
%--------------------------------------------
lgl_g=[];, lgl_r=[];
lgp_g=[];, lgp_r=[];
lg1_g=[];, lg1_r=[];
lg2_g=[];, lg2_r=[];
ionp_g=[];, ionp_r=[];
ionl_g=[];, ionl_r=[];
lgl_ion_g=[];, lgl_ion_r=[];
lgl_g_va=[];, lgl_r_va=[];
lgp_g_va=[];, lgp_r_va=[];
lg1_g_va=[];, lg1_r_va=[];
lg2_g_va=[];, lg2_r_va=[];
ionp_g_va=[];, ionp_r_va=[];
ionl_g_va=[];, ionl_r_va=[];
lgl_ion_g_va=[];, lgl_ion_r_va=[];

% ���C�h���[�����`����
%--------------------------------------------
wl_g=[];, wl_r=[];
wl_g_va=[];, wl_r_va=[];

% �i���[���[�����`����
%--------------------------------------------
nl_g=[];, nl_r=[];
nl_g_va=[];, nl_r_va=[];

% Melbourne-Wubbena ���`����
%--------------------------------------------
np_g=[];, np_r=[];
mw_g=[];, mw_r=[];
np_g_va=[];, np_r_va=[];
mw_g_va=[];, mw_r_va=[];

if est_prm.n_nav ==1
	mp1_g = pr_g - (2*(freq.g2^2/(freq.g1^2-freq.g2^2))+1)*wave.g1*adr1_g...
			 + 2*(freq.g2^2/(freq.g1^2-freq.g2^2))*wave.g2*adr2_g;
	mp2_g = pr2_g - 2*(freq.g1^2/(freq.g1^2-freq.g2^2))*wave.g1*adr1_g...
			 + (2*(freq.g1^2/(freq.g1^2-freq.g2^2))-1)*wave.g2*adr2_g;
	mp1_g_va = pr_g_va - (2*(freq.g2^2/(freq.g1^2-freq.g2^2))+1)*wave.g1*adr1_g_va...
			 + 2*(freq.g2^2/(freq.g1^2-freq.g2^2))*wave.g2*adr2_g_va;
	mp2_g_va = pr2_g_va - 2*(freq.g1^2/(freq.g1^2-freq.g2^2))*wave.g1*adr1_g_va...
			 + (2*(freq.g1^2/(freq.g1^2-freq.g2^2))-1)*wave.g2*adr2_g_va;

	lgl_g = wave.g1*adr1_g - wave.g2*adr2_g;
	lgp_g = pr_g - pr2_g;
	lg1_g = pr_g-wave.g1*adr1_g;
	lg2_g = pr2_g-wave.g2*adr2_g;
	ionp_g = lgp_g/(1-freq.g1^2/freq.g2^2);
	ionl_g = -lgl_g/(1-freq.g1^2/freq.g2^2);
	lgl_ion_g = lgl_g+(1-freq.g1^2/freq.g2^2)*ion_g;
	lgl_g_va = adr1_g_va + adr2_g_va;
	lgp_g_va = pr_g_va + pr2_g_va;
	lg1_g_va = pr_g_va + adr1_g_va;
	lg2_g_va = pr2_g_va + adr2_g_va;
	ionp_g_va = lgp_g_va/(1-freq.g1^2/freq.g2^2);
	ionl_g_va = lgl_g_va/(1-freq.g1^2/freq.g2^2);
	lgl_ion_g_va = lgl_g_va+(1-freq.g1^2/freq.g2^2)*ion_g;

	wl_g = (1/(1/wave.g1-1/wave.g2))*(adr1_g-adr2_g);
	wl_g_va = (1/(1/wave.g1-1/wave.g2))*(adr1_g_va/wave.g1 - adr2_g_va/wave.g2);

	nl_g = (1/(1/wave.g1+1/wave.g2))*(adr1_g+adr2_g);
	nl_g_va = (1/(1/wave.g1+1/wave.g2))*(adr1_g_va/wave.g1 + adr2_g_va/wave.g2);

	np_g = (1/(1/wave.g1+1/wave.g2))*(pr_g/wave.g1+pr2_g/wave.g2);
	mw_g = wl_g - np_g;
	np_g_va = (1/(1/wave.g1+1/wave.g2))*(pr_g_va/wave.g1 + pr2_g_va/wave.g2);
	mw_g_va = wl_g_va + np_g_va;
end
if est_prm.g_nav ==1 & ~isempty(freq.r1./freq.r2)
	mp1_r = pr_r - (2*(freq.r2.^2./(freq.r1.^2-freq.r2.^2))+1).*wave.r1.*adr1_r...
		 + 2*(freq.r2.^2./(freq.r1.^2-freq.r2.^2)).*wave.r2.*adr2_r;
	mp2_r = pr2_r - 2*(freq.r1.^2./(freq.r1.^2-freq.r2.^2)).*wave.r1.*adr1_r...
			 + (2*(freq.r1.^2./(freq.r1.^2-freq.r2.^2))-1).*wave.r2.*adr2_r;
	mp1_r_va = pr_r_va - (2*(freq.r2.^2./(freq.r1.^2-freq.r2.^2))+1).*wave.r1.*adr1_r_va...
		 + 2*(freq.r2.^2./(freq.r1.^2-freq.r2.^2)).*wave.r2.*adr2_r_va;
	mp2_r_va = pr2_r_va - 2*(freq.r1.^2./(freq.r1.^2-freq.r2.^2)).*wave.r1.*adr1_r_va...
			 + (2*(freq.r1.^2./(freq.r1.^2-freq.r2.^2))-1).*wave.r2.*adr2_r_va;

	lgl_r = wave.r1.*adr1_r - wave.r2.*adr2_r;
	lgp_r = pr_r - pr2_r;
	lg1_r = pr_r-wave.r1.*adr1_r;
	lg2_r = pr2_r-wave.r2.*adr2_r;
	ionp_r = lgp_r./(1-freq.r1.^2./freq.r2.^2);
	ionl_r = -lgl_r./(1-freq.r1.^2./freq.r2.^2);
	lgl_ion_r = lgl_r+(1-freq.r1.^2./freq.r2.^2).*ion_r;
	lgl_r_va = adr1_r_va + adr2_r_va;
	lgp_r_va = pr_r_va + pr2_r_va;
	lg1_r_va = pr_r_va + adr1_r_va;
	lg2_r_va = pr2_r_va + adr2_r_va;
	ionp_r_va = lgp_r_va./(1-freq.r1.^2./freq.r2.^2);
	ionl_r_va = lgl_r_va./(1-freq.r1.^2./freq.r2.^2);
	lgl_ion_r_va = lgl_r_va+(1-freq.r1.^2./freq.r2.^2).*ion_r;

	wl_r = (1./(1./wave.r1-1./wave.r2)).*(adr1_r-adr2_r);
	wl_r_va = (1./(1./wave.r1-1./wave.r2)).*(adr1_r_va./wave.r1 - adr2_r_va./wave.r2);

	nl_r = (1./(1./wave.r1+1./wave.r2)).*(adr1_r+adr2_r);
	nl_r_va = (1./(1./wave.r1+1./wave.r2)).*(adr1_r_va./wave.r1 + adr2_r_va./wave.r2);

	np_r = (1./(1./wave.r1+1./wave.r2)).*(pr_r./wave.r1+pr2_r./wave.r2);
	mw_r = wl_r - np_r;
	np_r_va = (1./(1./wave.r1+1./wave.r2)).*(pr_r_va./wave.r1 + pr2_r_va./wave.r2);
	mw_r_va = wl_r_va + np_r_va;
end

% Multipath ���`����
%--------------------------------------------
mp1=[mp1_g;mp1_r];
mp2=[mp2_g;mp2_r];
mp1_va=[mp1_g_va;mp1_r_va];
mp2_va=[mp2_g_va;mp2_r_va];

% �􉽊w�t���[���`����
%--------------------------------------------
lgl=[lgl_g;lgl_r];
lgp=[lgp_g;lgp_r];
lg1=[lg1_g;lg1_r];
lg2=[lg2_g;lg2_r];
ionp=[ionp_g;ionp_r];
ionl=[ionl_g;ionl_r];
lgl_ion=[lgl_ion_g;lgl_ion_r];
lgl_va=[lgl_g_va;lgl_r_va];
lgp_va=[lgp_g_va;lgp_r_va];
lg1_va=[lg1_g_va;lg1_r_va];
lg2_va=[lg2_g_va;lg2_r_va];
ionp_va=[ionp_g_va;ionp_r_va];
ionl_va=[ionl_g_va;ionl_r_va];
lgl_ion_va=[lgl_ion_g_va;lgl_ion_r_va];

% ���C�h���[�����`����
%--------------------------------------------
wl=[wl_g;wl_r];
wl_va=[wl_g_va;wl_r_va];

% �i���[���[�����`����
%--------------------------------------------
nl=[nl_g;nl_r];
nl_va=[nl_g_va;nl_r_va];

% Melbourne-Wubbena ���`����
%--------------------------------------------
np=[np_g;np_r];
mw=[mw_g;mw_r];
np_va=[np_g_va;np_r_va];
mw_va=[mw_g_va;mw_r_va];




