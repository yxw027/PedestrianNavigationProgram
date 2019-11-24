function [mp1,mp2,lgl,lgp,lg1,lg2,mw,ionp,ionl,lgl_ion,...
			mp1_va,mp2_va,lgl_va,lgp_va,lg1_va,lg2_va,mw_va,ionp_va,ionl_va] = obs_comb(est_prm,freq,wave,data,LC_variance,prn,ion,ele)
%-------------------------------------------------------------------------------
% Function : 線形結合------L1,L2帯の観測量の各種線形結合と分散を計算
% 
% [argin]
% est_prm : 設定パラメータ
% freq    : 周波数の構造体(*.g1, *.g2, *.r1, *.r2)
% wave    : 波長の構造体(*.g1, *.g2, *.r1, *.r2)
% data    : 観測データ
% LC      : 線形結合(構造体)
% prn     : 衛星PRN番号(構造体)(rov or ref)
% ion     : 電離層遅延データ
% ele     : 仰角
% 
% [argout]
% mp1     : Multipath 線形結合(L1)
% mp2     : Multipath 線形結合(L2)
% lgl     : 幾何学フリー線形結合(搬送波)
% lgp     : 幾何学フリー線形結合(コード)
% lg1     : 幾何学フリー線形結合(1周波)
% lg2     : 幾何学フリー線形結合(2周波)
% mw      : Melbourne-Wubbena 線形結合
% ionp    : 電離層(lgpから算出)
% ionl    : 電離層(lglから算出,Nを含む)
% lgl_ion : 幾何学フリー線形結合(搬送波)-電離層遅延分
% mp1_va     : Multipath 線形結合(L1)の分散
% mp2_va     : Multipath 線形結合(L2)の分散
% lgl_va     : 幾何学フリー線形結合(搬送波)の分散
% lgp_va     : 幾何学フリー線形結合(コード)の分散
% lg1_va     : 幾何学フリー線形結合(1周波)の分散
% lg2_va     : 幾何学フリー線形結合(2周波)の分散
% mw_va      : Melbourne-Wubbena 線形結合の分散
% ionp_va    : 電離層(lgpから算出)の分散
% ionl_va    : 電離層(lglから算出,Nを含む)の分散
% lgl_ion_va : 幾何学フリー線形結合(搬送波)-電離層遅延分の分散
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: August 1, 2007
%-------------------------------------------------------------------------------
% 幾何学フリー線形結合(搬送波)-電離層遅延分追加
% May 15, 2009, Y.Ishimaru
%-------------------------------------------------------------------------------
% GLONASSの周波数, 波長の変化に対応
% January 18, 2010, T.Yanase
%-------------------------------------------------------------------------------
% 分散も同時に導出
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------


% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
% f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
% f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長
% 
% OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
% MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
% FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

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

pr_va=LC_variance(:,1);							% CA分散
pr_g_va=LC_variance(1:length(prn.vg),1);		% CA分散(GPS)
pr_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),2);		% CA分散(GLONASS)
pr2_va=LC_variance(:,2);						% PY分散
pr2_g_va=LC_variance(1:length(prn.vg),2);		% PY分散(GPS)
pr2_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),2);		% PY分散(GLONASS)
adr1_va=LC_variance(:,3);						% L1分散
adr1_g_va=LC_variance(1:length(prn.vg),3);		% L1分散(GPS)
adr1_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),3);	% L1分散(GLONASS)
adr2_va=LC_variance(:,4);						% L2分散
adr2_g_va=LC_variance(1:length(prn.vg),4);		% L2分散(GPS)
adr2_r_va=LC_variance(length(prn.vg)+1:length(prn.vg)+length(prn.vr),4);	% L2分散(GLONASS)

ion_g_va=ion(1:length(prn.vg));					% ion分散(GPS)
ion_r_va=ion(length(prn.vg)+1:length(prn.vg)+length(prn.vr));				% ion分散(GLONASS)


% Multipath 線形結合
%--------------------------------------------
mp1_g=[];, mp1_r=[];
mp2_g=[];, mp2_r=[];
mp1_g_va=[];, mp1_r_va=[];
mp2_g_va=[];, mp2_r_va=[];

% 幾何学フリー線形結合
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

% ワイドレーン線形結合
%--------------------------------------------
wl_g=[];, wl_r=[];
wl_g_va=[];, wl_r_va=[];

% ナローレーン線形結合
%--------------------------------------------
nl_g=[];, nl_r=[];
nl_g_va=[];, nl_r_va=[];

% Melbourne-Wubbena 線形結合
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

% Multipath 線形結合
%--------------------------------------------
mp1=[mp1_g;mp1_r];
mp2=[mp2_g;mp2_r];
mp1_va=[mp1_g_va;mp1_r_va];
mp2_va=[mp2_g_va;mp2_r_va];

% 幾何学フリー線形結合
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

% ワイドレーン線形結合
%--------------------------------------------
wl=[wl_g;wl_r];
wl_va=[wl_g_va;wl_r_va];

% ナローレーン線形結合
%--------------------------------------------
nl=[nl_g;nl_r];
nl_va=[nl_g_va;nl_r_va];

% Melbourne-Wubbena 線形結合
%--------------------------------------------
np=[np_g;np_r];
mw=[mw_g;mw_r];
np_va=[np_g_va;np_r_va];
mw_va=[mw_g_va;mw_r_va];




