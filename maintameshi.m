%-------------------------------------------------------------------------------%
%                 ���{�E�v�ی��� GPS���ʉ��Z��۸��с@Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS���ʉ��Z�v���O����(PPP��)
% 
% < Program�̗��� >
% 
%  1. �����ݒ�̎擾
%  2. obs �w�b�_�[���
%  3. nav ����G�t�F�����X�擾
%  4. start, end ��ݒ�
%  5. nav ����d���w�p�����[�^���擾
%  6. ionex ����STEC�f�[�^�擾
%  7. ������Ǎ���
%  8. ���C������
%     1. �P�Ƒ��� (�ŏ����@)
%     2. �N���b�N�W�����v�␳���␳�ς݊ϑ��ʂ��쐬
%     3. �ُ�l���o
%     4. �P�Ƒ��� or PPP (�J���}���t�B���^)
%  9. ���ʊi�[
% 10. ���ʃO���t�\��
% 
% 
%-------------------------------------------------------------------------------
% �K�v�ȊO���t�@�C���E�֐�
%-------------------------------------------------------------------------------
% phisic_const.m      : �����ϐ���`
%-------------------------------------------------------------------------------
% fileget2.m          : �t�@�C���������ƃ_�E�����[�h(wget.exe, gzip.exe)
% read_obs_h.m        : OBS�w�b�_�[���
% read_eph2.m         : �G�t�F�����X�̎擾
% read_ionex2.m       : IONEX�f�[�^�擾
% read_sp3.m          : ������f�[�^�擾
% read_obs_epo_data2.m: OBS�G�|�b�N����� & OBS�ϑ��f�[�^�擾
%-------------------------------------------------------------------------------
% cal_time2.m         : �w�莞����GPS�T�ԍ��EToW�EToD�̌v�Z
% clkjump_repair2.m   : ��M�@���v�̔�т̌��o/�C��
% mjuliday.m          : MJD�̌v�Z
% weekf.m             : WEEK, TOW �̌v�Z
%-------------------------------------------------------------------------------
% azel.m              : �p, ���ʊp, �Δ����W���̌v�Z
% geodist_mix2.m      : �􉽊w�I�������̌v�Z(������,������)
% interp_lag.m        : ���O�����W�����
% pointpos3.m         : �P�Ƒ��ʉ��Z
% sat_pos2.m          : �q���O���v�Z(�ʒu�E���x�E���v�덷)
%-------------------------------------------------------------------------------
% cal_ion2.m          : �d���w���f��
% cal_trop.m          : �Η������f��
% ion_gim.m           : GIM���f��
% ion_klob.m          : Klobuchar���f��
% ion_rits.m          : ���������f��
% mapf_cosz.m         : �}�b�s���O�֐�(cosz)
% mapf_chao.m         : �}�b�s���O�֐�(chao)
% mapf_gmf.m          : �}�b�s���O�֐�(gmf)
% mapf_marini.m       : �}�b�s���O�֐�(marini)
%-------------------------------------------------------------------------------
% chi2test            : ���O�c���̌���(��2����)
% lc_lim              : ���`�����ɂ��T�C�N���X���b�v���o臒l�̌v�Z
% lc_chi2             : ���`�����̃J�C��挟��
% lc_chi2r            : ���`�����̃J�C��挟��(�A���G�|�b�N)
% outlier_detec.m     : ���`�����ɂ��ُ�l����
% pre_chi2.m          : ���`�����̃J�C��挟���臒l, �����։��s��v�Z
%-------------------------------------------------------------------------------
% measuremodel2.m     : �ϑ����f���쐬(h,H,R) + �􉽊w����
% obs_comb2.m         : �e����`�����̌v�Z
% obs_vec2.m          : �ϑ��ʃx�N�g���쐬
%-------------------------------------------------------------------------------
% FQ_state_all6.m     : ��ԃ��f���̐���
%-------------------------------------------------------------------------------
% filtekf_pre.m       : �J���}���t�B���^�̎��ԍX�V
% filtekf_upd.m       : �J���}���t�B���^�̊ϑ��X�V
%-------------------------------------------------------------------------------
% prn_check.m         : �q���ω��̌��o
% select_prn.m        : �g�p�q���̑I��
% state_adjust2.m     : �q���ω����̎�������
%-------------------------------------------------------------------------------
% geoidh.m            : �W�I�C�h���v�Z(EGM96:geoid_egm96.mat)
% enu2xyz.m           : ENU��XYZ ���W�ϊ�
% llh2xyz.m           : LLH��XYZ ���W�ϊ�
% xyz2enu.m           : XYZ��ENU ���W�ϊ�
% xyz2llh.m           : XYZ��LLH ���W�ϊ�
%-------------------------------------------------------------------------------
% output_fig.m        : figure�̃t�@�C���o�͊֐�
% output_ins.m        : INS�p�t�H�[�}�b�g�o��
% output_kml.m        : KML�t�H�[�}�b�g�o��
% output_log.m        : �o�̓t�@�C���̃w�b�_�[�����̏�������
% output_nmea.m       : NMEA�t�H�[�}�b�g�o��
% output_statis.m     : ���v�ʂ̏o��
% output_zenrin.m     : ZENRIN�p�t�H�[�}�b�g�o��
%-------------------------------------------------------------------------------
% plot_data2.m        : ���ʃO���t�o��
% plot_ion.m          : �O���t�o��(�d���w�x��)
% plot_ionv2.m        : �O���t�o��(�d���w�x���ϓ�)
% plot_pos.m          : �O���t�o��(E-N-U, Bias,STD,RMS)
% plot_pos2.m         : �O���t�o��(E-N-U, Bias,STD,RMS) ���Α��ʗp
% plot_pos22.m        : �O���t�o��(E-N-U, Bias,STD,RMS) ���Α��ʗp
% plot_pos23.m        : �O���t�o��(E-N-U, Bias,STD,RMS) ���Α��ʗp
% plot_res.m          : �O���t�o��(�c��)
% plot_sat.m          : �O���t�o��(PRN)
% plot_sky.m          : �O���t�o��(�q���z�u)
% plot_trop.m         : �O���t�o��(�Η����x��)
%-------------------------------------------------------------------------------
% p1c1bias.m          : P1-C1�o�C�A�X
% p1p2bias.m          : P1-P2�o�C�A�X
% tide.m              : �����ɂ��ϓ�
%-------------------------------------------------------------------------------
% recpos3.m           : �d�q��_�̋ǔԍ�����
%-------------------------------------------------------------------------------
% 
% �E2���g�Ή�
% �E�L�l�}�e�B�b�N�Ή�
% �EGR, UoC, Traditional �e�탂�f���ɑΉ�
% �E�Η�������ɑΉ�
% �E�d���w����ɑΉ�
% 
% <�ۑ�>
% �E�f�[�^�X�V�Ԋu�� 1[sec]�ȉ��̏ꍇ�~ �� �ǂݔ�΂����C��
% �E�ُ�l���o(���`����, ���O�c���E����c������)
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov     : ���q��(rov)
%  prn.rovu    : �g�p�q��(rov)
%  prn.v       : ���q��(rov) prn.rov�Ɠ���
%  prn.u       : �g�p�q��(rov)
%  prn.o       : �O�G�|�b�N�̎g�p�q��(rov)
% 
% �X�V�Ԋu��1[Hz]�ȏ�ł��ł���悤�ɏC��
% �� ����ɔ���, ���ɂ��C�����Ă��镔������
% 
%-------------------------------------------------------------------------------
% latest update : 2009/02/25 by Fujita
%-------------------------------------------------------------------------------
% 
% �EGLONASS�Ή�
% 
% <�ۑ�>
% �E�q�������x�E��]�␳�̍l�@
% �E�e��G��, �p�����[�^�ݒ�̌�����(GLONASS���ʂɌ���)
% �E�d���w���̐����@
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov.v   : ���q��(rov)
%  prn.rov.vg  : GPS�̉��q��(rov)
%  prn.rov.vr  : GLONASS�̉��q��(rov)
%  prn.u       : �g�p�q��
%  prn.ug      : GPS�̎g�p�q��
%  prn.ur      : GLONASS�̎g�p�q��
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/12 by Yanase, Tanaka
%-------------------------------------------------------------------------------
% 
% �E�ُ�l����Ή�
% 
% <�ۑ�>
% �E���`������2���肪�쐬�r��
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/ by Ishimaru
%-------------------------------------------------------------------------------
% 
% �E�n���ő̒����␳�Ή�
%
% <�ۑ�>
% �E���ԕω��ɑΉ������^�l�Ƃ̔�r, ���Ԃ𒷂����Ď���
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/26 by Nishikawa, Nagano
%-------------------------------------------------------------------------------

clear all
clc

%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z
%-----------------------------------------------------------------------------------------
addpath ./toolbox_gnss/

%--- �����ݒ�擾
%--------------------------------------------
cd('./INI/');
inifile=input('�����ݒ�t�@�C�������g���q�Ȃ��œ��͂��ĉ�����>> \n','s');
eval(inifile);
cd ..

%--- �t�@�C���������ƃt�@�C���擾
%--------------------------------------------
est_prm.rovpos=est_prm.rovpos;
est_prm=fileget2(est_prm);

if ~exist(est_prm.dirs.result)
	mkdir(est_prm.dirs.result);			% ���ʂ̃f�B���N�g������
end

tic
timetag=0;
timetag_o=0;
% change_flag=0;
dtr_o=[];
jump_width_all=[];
rej=[];
refl=[];

%--- �萔(�O���[�o���ϐ�)
%--------------------------------------------
% phisic_const;

%--- �萔
%--------------------------------------------
C=299792458;							% ����
freq.g1=1.57542e9;						% L1 ���g��(GPS)
wave.g1=C/1.57542e9;					% L1 �g��(GPS)
freq.g2=1.22760e9;						% L2 ���g��(GPS)
wave.g2=C/1.22760e9;					% L2 �g��(GPS)

OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

%--- start time �̐ݒ�
%--------------------------------------------
if ~isempty(est_prm.stime)
	time_s=cal_time2(est_prm.stime);										% Start time �� Juliday, WEEK, TOW, TOD
end

%--- end time �̐ݒ�
%--------------------------------------------
if ~isempty(est_prm.etime)
	time_e=cal_time2(est_prm.etime);										% End time �� Juliday, WEEK, TOW, TOD
else
	time_e.day = [];
	time_e.mjd = 1e50;														% End time(mjd) �ɑ傫�Ȓl������
end

%--- �t�@�C���I�[�v��
%--------------------------------------------
fpo = fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');
fpn = fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');
fpcsv = csvread([est_prm.dirs.obs,est_prm.file.csv]);
if est_prm.g_nav==1
	fpg = fopen([est_prm.dirs.obs,est_prm.file.rov_g],'rt');
else
	fpg = [];
end

if fpo==-1
	fprintf('o�t�@�C��%s���J���܂���.\n',est_prm.file.rov_o);				% Rov obs(�G���[����)
	exit
end
if est_prm.n_nav==1
	if fpn==-1
	fprintf('n�t�@�C��%s���J���܂���.\n',est_prm.file.rov_n);				% Rov nav(GPS)(�G���[����)
	exit
	end
end
if est_prm.g_nav==1
	if fpg==-1
	fprintf('g�t�@�C��%s���J���܂���.\n',est_prm.file.rov_g);				% Rov nav(GLONASS)(�G���[����)
	exit
	end
end

%--- obs �w�b�_�[���
%--------------------------------------------
[tofh,toeh,s_time,e_time,app_xyz,no_obs,TYPES,dt,Rec_type]=read_obs_h(fpo);

% �G�t�F�����X�Ǎ���(Klobuchar model �p�����[�^�̒��o��)
%--------------------------------------------
[eph_prm.brd.data, ion_prm.klob.ionab]=read_eph2(est_prm,fpn,fpg);

%--- IONEX�f�[�^�擾
%--------------------------------------------
if est_prm.i_mode==2
	[ion_prm.gim]=read_ionex2([est_prm.dirs.ionex,est_prm.file.ionex]);
else
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end
if est_prm.i_mode==3
	load('ENMdata20080922_1.mat');
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- ������̓Ǎ���
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);

	if strcmp(est_prm.ephsrc,'igu')
        Data_sp3=eph_prm.sp3.data;
		eph_prm.sp3.data=eph_prm.sp3.data(size(Data_sp3,1)/2+1:end,:,:);
% % 		eph_prm.sp3.data=eph_prm.sp3.data(1:size(Data_sp3,1)/2,:,:);
	end
else
	eph_prm.sp3.data=[];
end

%--- �ݒ���̏o��
%--------------------------------------------
datname=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol  = fopen([est_prm.dirs.result,datname],'w');								% ���ʏ����o���t�@�C���̃I�[�v��
output_log2(f_sol,time_s,time_e,est_prm,1);

%--- �����̐ݒ�(��ԃ��f������)
%--------------------------------------------
switch est_prm.statemodel.pos
case 0, nx.u=3*1;
case 1, nx.u=3*2;
case 2, nx.u=3*3;
case 3, nx.u=3*4;
case 4, nx.u=3*1;
case 5, nx.u=3*2+2;
end
switch est_prm.statemodel.dt
case 0, nx.t=1*1;
case 1, nx.t=1*2;
end
switch est_prm.statemodel.hw
case 0, nx.b=0;
case 1, nx.b=est_prm.freq*2; if est_prm.obsmodel==9, nx.b=3; end
end
switch est_prm.statemodel.trop
case 0, nx.T=0;
case 1, nx.T=1;
case 2, nx.T=1;
case 3, nx.T=1+2;
case 4, nx.T=1+2;
end
switch est_prm.statemodel.ion
case 0, nx.i=0;
case 1, nx.i=1;
case 2, nx.i=1+1;
case 3, nx.i=1+2;
end

%--- �z��̏���
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;
less_frag=0;
%--- SPP�p
%--------------------------------------------
Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% ����
Result.spp.pos(1:tt,1:6)=NaN;													% �ʒu
Result.spp.dtr(1:tt,1:1)=NaN;													% ��M�@���v�덷
Result.spp.prn{1}(1:tt,1:61)=NaN;												% ���q��
Result.spp.prn{2}(1:tt,1:61)=NaN;												% �g�p�q��
Result.spp.prn{3}(1:tt,1:3)=NaN;												% �q����

%--- PPP�p
%--------------------------------------------
Result.ppp.time(1:tt,1:10)=NaN; Result.ppp.time(:,1)=1:tt;						% ����
Result.ppp.pos(1:tt,1:6)=NaN;													% �ʒu
Result.ppp.lostsat(1:tt)=NaN;                                                   % 3�ȉ��̉q������timetag
%Result.ppp.error(1:tt)=NaN;
Result.ppp.dtr(1:tt,1:2)=NaN;													% ��M�@���v�덷
Result.ppp.hwb(1:tt,1:4)=NaN;													% HWB
Result.ppp.dion(1:tt,1:3)=NaN;													% �d���w�x��
Result.ppp.dtrop(1:tt,1:3)=NaN;													% �Η����x��
for j=1:2, Result.ppp.amb{j,1}(1:tt,1:61)=NaN;, end								% �����l�o�C�A�X
Result.ppp.prn{1}(1:tt,1:61)=NaN;												% ���q��
Result.ppp.prn{2}(1:tt,1:61)=NaN;												% �g�p�q��
Result.ppp.prn{3}(1:tt,1:8)=NaN;												% �q����


%--- �c���p
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% ����
for j=1:4, Res.pre{j,1}(1:tt,1:61)=NaN; end									% �c��(pre-fit)
for j=1:4, Res.post{j,1}(1:tt,1:61)=NaN; end									% �c��(post-fit)

%--- clock jump�p
%--------------------------------------------
dtr_all(1:tt,1:2)=NaN;

%--- �ϑ��f�[�^�p
%--------------------------------------------
OBS.rov.time(1:tt,1:10)=NaN; OBS.rov.time(:,1)=1:tt;							% ����
OBS.rov.ca(1:tt,1:61)=NaN; OBS.rov.py(1:tt,1:61)=NaN;							% CA, PY
OBS.rov.ph1(1:tt,1:61)=NaN; OBS.rov.ph2(1:tt,1:61)=NaN;							% L1, L2
OBS.rov.ion(1:tt,1:61)=NaN; OBS.rov.trop(1:tt,1:61)=NaN;						% Ionosphere, Troposphere
OBS.rov.ele(1:tt,1:61)=NaN; OBS.rov.azi(1:tt,1:61)=NaN;							% Elevation, Azimuth
OBS.rov.ca_cor(1:tt,1:61)=NaN; OBS.rov.py_cor(1:tt,1:61)=NaN;					% CA, PY(Corrected)
OBS.rov.ph1_cor(1:tt,1:61)=NaN; OBS.rov.ph2_cor(1:tt,1:61)=NaN;					% L1, L2(Corrected)

%--- LC�p
%--------------------------------------------
LC.rov.time(1:tt,1:10)=NaN; LC.rov.time(:,1)=1:tt;								% ����
LC.rov.mp1(1:tt,1:61)=NaN; LC.rov.mp2(1:tt,1:61)=NaN;							% MP1, MP2
LC.rov.mw(1:tt,1:61)=NaN;														% MW
LC.rov.lgl(1:tt,1:61)=NaN; LC.rov.lgp(1:tt,1:61)=NaN;							% LGL, LGP
LC.rov.lg1(1:tt,1:61)=NaN; LC.rov.lg2(1:tt,1:61)=NaN;							% LG1, LG2
LC.rov.ionp(1:tt,1:61)=NaN; LC.rov.ionl(1:tt,1:61)=NaN;							% IONP, IONL

%--- �ُ�l���o�p
%--------------------------------------------
LC.rov.mp1_va(1:tt,1:61)=NaN; LC.rov.mp2_va(1:tt,1:61)=NaN;						% ���`�����̕��U
LC.rov.mw_va(1:tt,1:61)=NaN;
LC.rov.lgl_va(1:tt,1:61)=NaN; LC.rov.lgp_va(1:tt,1:61)=NaN;
LC.rov.lg1_va(1:tt,1:61)=NaN; LC.rov.lg2_va(1:tt,1:61)=NaN;
LC.rov.ionp_va(1:tt,1:61)=NaN; LC.rov.ionl_va(1:tt,1:61)=NaN;
LC.rov.mp1_lim(1:tt,1:61)=NaN; LC.rov.mp2_lim(1:tt,1:61)=NaN;					% ���`�����T�C�N���X���b�v�W���΍�臒l
LC.rov.mw_lim(1:tt,1:61)=NaN; LC.rov.lgl_lim(1:tt,1:61)=NaN;
% LC.rov.lgp_lim(1:tt,1:61)=NaN;LC.rov.lg1_lim(1:tt,1:61)=NaN;
% LC.rov.lg2_lim(1:tt,1:61)=NaN; LC.rov.ionp_lim(1:tt,1:61)=NaN;
% LC.rov.ionl_lim(1:tt,1:61)=NaN;

LC.rov.cs1(1:tt,1:61)=NaN;														% �X���b�v�ʐ���l
LC.rov.cs2(1:tt,1:61)=NaN;
LC.rov.lgl_cs(1:tt,1:61) = NaN; LC.rov.mw_cs(1:tt,1:61) = NaN;
LC.rov.mp1_cs(1:tt,1:61) = NaN; LC.rov.mp2_cs(1:tt,1:61) = NaN;

LC_r.rov.mp1(1:tt,1:61)=NaN; LC_r.rov.mp2(1:tt,1:61)=NaN;						% ���O�q����r���������`����
LC_r.rov.mw(1:tt,1:61)=NaN;
LC_r.rov.lgl(1:tt,1:61)=NaN; LC_r.rov.lgp(1:tt,1:61)=NaN;
LC_r.rov.lg1(1:tt,1:61)=NaN; LC_r.rov.lg2(1:tt,1:61)=NaN;
LC_r.rov.ionp(1:tt,1:61)=NaN; LC_r.rov.ionl(1:tt,1:61)=NaN;

CHI2.rov.mp1(1:tt,1:61)=NaN; CHI2.rov.mp2(1:tt,1:61)=NaN;						% ���`�����T�C�N���X���b�v�J�C2�挟�蓝�v��
CHI2.rov.mw(1:tt,1:61)=NaN; CHI2.rov.lgl(1:tt,1:61)=NaN;
CHI2.rov.lgp(1:tt,1:61)=NaN; CHI2.rov.lg1(1:tt,1:61)=NaN;
CHI2.rov.lg2(1:tt,1:61)=NaN; CHI2.rov.ionp(1:tt,1:61)=NaN;
CHI2.rov.ionl(1:tt,1:61)=NaN;
[CHI2.sigma, Vb, Gb] = pre_chi2(est_prm.cycle_slip.A,est_prm.cycle_slip.lc_b);	% �J�C��挟��̃J�C2��㑤�m���_, �����։��s��

REJ.rov.mp1(1:tt,1:61)=NaN; REJ.rov.mp2(1:tt,1:61)=NaN;							% ���`�����T�C�N���X���b�v���O�q��
REJ.rov.mw(1:tt,1:61)=NaN; REJ.rov.lgl(1:tt,1:61)=NaN;
% REJ.rov.lgp(1:tt,1:61)=NaN; REJ.rov.lg1(1:tt,1:61)=NaN;
% REJ.rov.lg2(1:tt,1:61)=NaN; REJ.rov.ionp(1:tt,1:61)=NaN;
% REJ.rov.ionl(1:tt,1:61)=NaN;
REJ.rej(1:tt,1:61)=NaN;


%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z ---->> �J�n
%-----------------------------------------------------------------------------------------
while 1

	%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
	%--------------------------------------------
	[time,no_sat,prn.rov.v,dtrec,ephi,data]=...
			read_obs_epo_data2(fpo,est_prm,eph_prm.brd.data,no_obs,TYPES);

	% end ����
	%--------------------------------------------
	if time_e.mjd <= time.mjd-0.1/86400, break; end							% �� 0.1 �b��ڂ܂ŔF�߂�

	%--- start ����
	%--------------------------------------------
	if time_s.mjd <= time.mjd+0.1/86400											% �� 0.1 �b��ڂ܂ŔF�߂�
		%--- �^�C���^�O
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
        else
			%timetag = timetag + round((time.mjd-time_o.mjd)*86400/dt);
            timetag = timetag + 1;
		end

		%--- �ǂݎ�蒆�̃G�|�b�N�̎��ԕ\��
		%--------------------------------------------
		fprintf('%7d:  %2d:%2d %5.2f"  ',timetag,time.day(4),time.day(5),time.day(6));

		%--- �A���e�ia,b��PRN��index���i�[(���ʉq���̂�)
		%------------------------------------------------
% 		ind_p1 = [];
% 		ind_p2 = [];
% 		for k = 1 : (length(prn.rov.v)-1)
% 			if prn.rov.v(k) == prn.rov.v(k+1)
% 				ind_p1 = [ind_p1 k];
% 				ind_p2 = [ind_p2 k+1];
% 			end
% 		end
% % 		data=data(ind_p1,:);
% 		data=data(ind_p2,:);
% 		prn.rov.v=prn.rov.v(ind_p1); no_sat=length(prn.rov.v);

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@)
		%------------------------------------------------------------------------------------------------------

		%--- �T�C�N���X���b�v�ݒ�
		%--------------------------------------------
		if length(est_prm.cycle_slip.prn)>=1
			stl = [1:est_prm.cycle_slip.timel];											% �X���b�v�������� [epoch]
			sti = est_prm.cycle_slip.timei;												% �X���b�v�����Ԋu [epoch]
			sliptime = [];
			for st=est_prm.cycle_slip.stime*dt:sti*dt:est_prm.cycle_slip.etime*dt		% �X���b�v�J�n&�I������ [epoch*�ϑ��Ԋu]
				sliptime = [sliptime st+stl*dt];
			end
			if ismember(time.tod,sliptime)
				for cs_i=1:length(est_prm.cycle_slip.prn)
					is = find(prn.rov.v==est_prm.cycle_slip.prn(cs_i));
					if ~isempty(is)
						data(is,1) = data(is,1) + est_prm.cycle_slip.slip_l1;
						data(is,5) = data(is,5) + est_prm.cycle_slip.slip_l2;
					end
				end
			end
		end

		%--- GLONASS�̎��g���E�g������
		%--------------------------------------------
		if est_prm.g_nav==1															% GLONASS���g��, �g��
			freq.r1=eph_prm.brd.data(25,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L1 ���g��(GLONASS)
			wave.r1=C ./ freq.r1;													% L2 �g��(GLONASS)
			freq.r2=eph_prm.brd.data(26,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L2 ���g��(GLONASS)
			wave.r2=C ./ freq.r2;													% L2 �g��(GLONASS)
			else
			freq.r1=[]; wave.r1=[];
			freq.r2=[]; wave.r2=[];
		end

		%--- �P�Ƒ���
		%--------------------------------------------
        %�����ɏ����l�Ԃ�����
        
		[x,dtr,dtsv,ion,trop,prn.rovu,rho,dop,ele,azi]=...
				pointpos3(freq,time,prn.rov.v,app_xyz,data,eph_prm,ephi,est_prm,ion_prm,rej);
        
            
		if ~isnan(x(1)), app_xyz(1:3)=x(1:3);, end

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos = xyz2enu(x(1:3),est_prm.rovpos )';													% ENU�ɕϊ�

		%--- ���ʊi�[(SPP)
		%--------------------------------------------
		Result.spp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];					% ����
		Result.spp.pos(timetag,:)=[x(1:3)', xyz2llh(x(1:3)).*[180/pi 180/pi 1]];					% �ʒu
		Result.spp.dtr(timetag,:)=C*dtr;															% ��M�@���v�덷

		%--- �q���i�[
		%--------------------------------------------
		Result.spp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rovu),dop];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
        
        
		if ~isempty(prn.rovu), Result.spp.prn{2}(timetag,prn.rovu)=prn.rovu;, end

		%--- OBS�f�[�^,�d���w�x��(�\����)
		%--------------------------------------------
		OBS.rov.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];						% ����
		OBS.rov.ca(timetag,prn.rov.v)   = data(:,2);
		OBS.rov.py(timetag,prn.rov.v)   = data(:,6);
		OBS.rov.ph1(timetag,prn.rov.v)  = data(:,1);
		OBS.rov.ph2(timetag,prn.rov.v)  = data(:,5);
		OBS.rov.ion(timetag,prn.rov.v)  = ion(:,1);
		OBS.rov.trop(timetag,prn.rov.v) = trop(:,1);

		OBS.rov.ele(timetag,prn.rov.v)  = ele(:,1);				% elevation
		OBS.rov.azi(timetag,prn.rov.v)  = azi(:,1);				% azimuth
       
		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@) ---->> �I�� ---->> �N���b�N�W�����v�␳
		%------------------------------------------------------------------------------------------------------

		%--- clock jump �̌��o & �␳
		%--------------------------------------------
		if est_prm.clk_flag == 1
			dtr_all(timetag,1) = dtr;																% ��M�@���v�덷���i�[
			[data,dtr,time.day,clk_jump,dtr_o,jump_width_all]=...
					clkjump_repair2(time.day,data,dtr,dtr_o,jump_width_all,Rec_type);				% clock jump ���o/�␳
			clk_check(timetag,1) = clk_jump;														% �W�����v�t���O���i�[
		end
		dtr_all(timetag,2) = dtr;																	% �␳�ςݎ�M�@���v�덷���i�[

		%--- �␳�ς݊ϑ��ʂ��i�[
		%--------------------------------------------
		OBS.rov.ca_cor(timetag,prn.rov.v)   = data(:,2);						% CA
		OBS.rov.py_cor(timetag,prn.rov.v)   = data(:,6);						% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v)  = data(:,1);						% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v)  = data(:,5);						% L2

		%--- GPS�EGLONASS�̉q������
		%--------------------------------------------
		prn.rov.vg=prn.rov.v(find(prn.rov.v<=32));							% ���q��(GPS)
		prn.rov.vr=prn.rov.v(find(38<=prn.rov.v));							% ���q��(GLONASS)

		LC.rov.variance(1:61,1:4)=NaN; 														% ���U�i�[�z��(rov)
		if est_prm.ww == 0																					% �d�݂Ȃ�
			LC.rov.variance(1:length(prn.rov.v),1)=repmat(est_prm.obsnoise.PR1,length(prn.rov.v),1);		% CA�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),2)=repmat(est_prm.obsnoise.PR2,length(prn.rov.v),1);		% PY�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),3)=repmat(est_prm.obsnoise.Ph1,length(prn.rov.v),1);		% L1�����g�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),4)=repmat(est_prm.obsnoise.Ph2,length(prn.rov.v),1);		% L2�����g�̕��U(rov)
		else																								% �d�ݍl��
			LC.rov.variance(1:length(prn.rov.v),1)= (est_prm.obsnoise.PR1./sin(ele).^2);					% CA�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),2)= (est_prm.obsnoise.PR2./sin(ele).^2);					% PY�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),3)= (est_prm.obsnoise.Ph1./sin(ele).^2);					% L1�����g�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),4)= (est_prm.obsnoise.Ph2./sin(ele).^2);					% L2�����g�̕��U(rov)
% 			LC.rov.variance(1,prn.rov.v)= (est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele(ii(b))).^2);	% CA�R�[�h�̕��U(rov)
% 			LC.rov.variance(2,prn.rov.v)= (est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele(ii(b))).^2);	% PY�R�[�h�̕��U(rov)
% 			LC.rov.variance(3,prn.rov.v)= (est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele(ii(b))).^2);	% L1�����g�̕��U(rov)
% 			LC.rov.variance(4,prn.rov.v)= (est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele(ii(b))).^2);	% L2�����g�̕��U(rov)
        end
        
		%--- �e����`�����ƕ��U(�␳�ς݊ϑ��ʂ��g�p)
		%--------------------------------------------
		[mp1,mp2,lgl,lgp,lg1,lg2,mw,ionp,ionl,lgl_ion,...
			mp1_va,mp2_va,lgl_va,lgp_va,lg1_va,lg2_va,mw_va,ionp_va,ionl_va]=...
					obs_comb2(est_prm,freq,wave,data,LC.rov.variance,prn.rov,ion,ele);

		%--- �e����`�����ƕ��U���i�[
		%--------------------------------------------
		ii=find(ele*180/pi>est_prm.mask);
		if ~isempty(ii)
			LC.rov.mp1(timetag,prn.rov.v(ii)) = mp1(ii);										% Multipath ���`����(L1)
			LC.rov.mp2(timetag,prn.rov.v(ii)) = mp2(ii);										% Multipath ���`����(L2)
			LC.rov.mw(timetag,prn.rov.v(ii))  = mw(ii);											% Melbourne-Wubbena ���`����
			LC.rov.mp1_va(timetag,prn.rov.v(ii)) = mp1_va(ii);									% Multipath ���`����(L1)�̕��U
			LC.rov.mp2_va(timetag,prn.rov.v(ii)) = mp2_va(ii);									% Multipath ���`����(L2)�̕��U
			LC.rov.mw_va(timetag,prn.rov.v(ii))  = mw_va(ii);									% Melbourne-Wubbena ���`�����̕��U
			LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_va(ii);									% �􉽊w�t���[���`����(�����g)
			if est_prm.cycle_slip.lgl_ion == 0
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_va(ii);								% �􉽊w�t���[���`����(�����g)
			else
				LC.rov.lgl(timetag,prn.rov.v(ii)) = lgl_ion(ii);								% �􉽊w�t���[���`����(�����g)-�d���w�x����
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_ion_va(ii);							% �􉽊w�t���[���`����(�����g)-�d���w�x�����̕��U
			end
			LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp(ii);										% �􉽊w�t���[���`����(�R�[�h)
			LC.rov.lg1(timetag,prn.rov.v(ii))  = lg1(ii);										% �􉽊w�t���[���`����(1���g)
			LC.rov.lg2(timetag,prn.rov.v(ii))  = lg2(ii);										% �􉽊w�t���[���`����(2���g)
			LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp(ii);										% �d���w(lgp����Z�o)
			LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl(ii);										% �d���w(lgl����Z�o,N���܂�)
			LC.rov.lgp_va(timetag,prn.rov.v(ii))  = lgp_va(ii);									% �􉽊w�t���[���`����(�R�[�h)�̕��U
			LC.rov.lg1_va(timetag,prn.rov.v(ii))  = lg1_va(ii);									% �􉽊w�t���[���`����(1���g)�̕��U
			LC.rov.lg2_va(timetag,prn.rov.v(ii))  = lg2_va(ii);									% �􉽊w�t���[���`����(2���g)�̕��U
			LC.rov.ionp_va(timetag,prn.rov.v(ii)) = ionp_va(ii);								% �d���w(lgp����Z�o)�̕��U
			LC.rov.ionl_va(timetag,prn.rov.v(ii)) = ionl_va(ii);								% �d���w(lgl����Z�o,N���܂�)�̕��U
		end

		%--- ���`�����ɂ��ُ�l����
		%--------------------------------------------
		rej_rov.mp1  = [];
		rej_rov.mp2  = [];
		rej_rov.mw   = [];
		rej_rov.lgl  = [];

		rej_lc  = [];
% 		rej_lgl = [];
% 		rej_mw  = [];
% 		rej_mp1 = [];
% 		rej_mp2 = [];
		rej_uni = [];

		%--- ���O�q�����l���������`�����i�[�z��
		%--------------------------------------
		LC_r.rov.mp1(timetag,:)=LC.rov.mp1(timetag,:); LC_r.rov.mp2(timetag,:)=LC.rov.mp2(timetag,:);		% MP1, MP2
		LC_r.rov.mw(timetag,:)=LC.rov.mw(timetag,:);														% MW
		LC_r.rov.lgl(timetag,:)=LC.rov.lgl(timetag,:); LC_r.rov.lgp(timetag,:)=LC.rov.lgp(timetag,:);		% LGL, LGP
		LC_r.rov.lg1(timetag,:)=LC.rov.lg1(timetag,:); LC_r.rov.lg2(timetag,:)=LC.rov.lg2(timetag,:);		% LG1, LG2
		LC_r.rov.ionp(timetag,:)=LC.rov.ionp(timetag,:); LC_r.rov.ionl(timetag,:)=LC.rov.ionl(timetag,:);	% IONP, IONL

		if timetag>1
	
			%--- ���`�����ɂ��ُ�l����
			%--------------------------------------------
			[lim_rov,chi2_rov,rej_rov,lcbb_rov]=outlier_detec(est_prm,timetag,LC.rov,LC_r.rov,CHI2.sigma,REJ.rov,prn.rov.v,Vb,Gb);

			switch est_prm.cs_mode
			case 0
				rej_uni=rej;
			case 2
				if timetag>est_prm.cycle_slip.lc_int+1

					%--- 臒l�̊i�[
					%------------------------------------------
					LC.rov.mp1_lim(timetag,:)  = lim_rov.mp1;						% Multipath ���`����(L1)
					LC.rov.mp2_lim(timetag,:)  = lim_rov.mp2;						% Multipath ���`����(L2)
					LC.rov.mw_lim(timetag,:)   = lim_rov.mw;						% Melbourne-Wubbena ���`����
					LC.rov.lgl_lim(timetag,:)  = lim_rov.lgl;						% �􉽊w�t���[���`����(�����g)

% 					LC.rov.lgp_lim(timetag,:)  = lim_rov.lgp;						% �􉽊w�t���[���`����(�R�[�h)
% 					LC.rov.lg1_lim(timetag,:)  = lim_rov.lg1;						% �􉽊w�t���[���`����(1���g)
% 					LC.rov.lg2_lim(timetag,:)  = lim_rov.lg2;						% �􉽊w�t���[���`����(2���g)
% 					LC.rov.ionp_lim(timetag,:) = lim_rov.ionp;						% �d���w(lgp����Z�o)
% 					LC.rov.ionl_lim(timetag,:) = lim_rov.ionl;						% �d���w(lgl����Z�o,N���܂�)

					%--- �ُ�l���o
					%------------------------------------------
					rej_rov.mp1=find(abs(diff(LC.rov.mp1(timetag-1:timetag,:)))>lim_rov.mp1);
					rej_rov.mp2=find(abs(diff(LC.rov.mp2(timetag-1:timetag,:)))>lim_rov.mp2);
					rej_rov.mw=find(abs(diff(LC.rov.mw(timetag-1:timetag,:)))>lim_rov.mw);
					rej_rov.lgl=find(abs(diff(LC.rov.lgl(timetag-1:timetag,:)))>lim_rov.lgl);

					if ismember(0,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.lgl);
					end
					if ismember(1,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mw);
					end
					if ismember(2,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp1);
					end
					if ismember(3,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp2);
					end

					REJ.rej(timetag,rej_lc)=rej_lc;
					rej_uni = union(rej, rej_lc);

					%--- �ُ�l���o���ꂽ�q���ԍ��̊i�[
					%------------------------------------------
					REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
					REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
					REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
					REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;
				end

			case 3
				%--- �ُ�l���o���ꂽ�q���ԍ��̊i�[
				%------------------------------------------
				REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
				REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
				REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
				REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;

				%--- �J�C���l�̊i�[
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;						% Multipath ���`����(L1)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;						% Multipath ���`����(L2)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;							% Melbourne-Wubbena ���`����
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;						% �􉽊w�t���[���`����(�����g)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov_lgp;						% �􉽊w�t���[���`����(�R�[�h)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov_lg1;						% �􉽊w�t���[���`����(1���g)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov_lg2;						% �􉽊w�t���[���`����(2���g)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov_ionp;						% �d���w(lgp����Z�o)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov_ionl;						% �d���w(lgl����Z�o,N���܂�)

				%--- �ُ�l���o�q���̏��O
				%------------------------------------------
				if est_prm.cycle_slip.rej_flag==0
					if ismember(0,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.lgl);
					end
					if ismember(1,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mw);
					end
					if ismember(2,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp1);
					end
					if ismember(3,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp2);
					end
					
					REJ.rej(timetag,rej_lc)=rej_lc;
					rej_uni = union(rej, rej_lc);
				end

				%--- �ُ�l�C��(�T�C�N���X���b�v)
				%------------------------------------------
				if est_prm.cycle_slip.rej_flag==1
					rej_rov_1   = [];
					rej_rov_2   = [];
					rej_rov_sum = [];
					
					rej_rov_1 = union(rej_rov.lgl,rej_rov.mw);
					rej_rov_2 = union(rej_rov.mp1,rej_rov.mp2);
					rej_rov_sum = union(rej_rov_1,rej_rov_2);							% ���m�Ǒ����o�q��

					%--- �C���\�Ȋϑ��ʂ̏C��
					%--------------------------------------
					if ~isnan(rej_rov_sum)
						VA.rov=[];
						[s1_rov,s2_rov,rov_lgl_cs,rov_mw_cs,rov_mp1_cs,rov_mp2_cs] = lc_slip(LC.rov,CHI2.rov,timetag,rej_rov_sum);
						LC.rov.cs1(timetag,rej_rov_sum) = s1_rov(rej_rov_sum);				% ���m�ǃX���b�v����ʊi�[(L1)
						LC.rov.cs2(timetag,rej_rov_sum) = s2_rov(rej_rov_sum);				% ���m�ǃX���b�v����ʊi�[(L2)
						LC.rov.lgl_cs(timetag,rej_rov_sum) = rov_lgl_cs(rej_rov_sum);
						LC.rov.mw_cs(timetag,rej_rov_sum) = rov_mw_cs(rej_rov_sum);
						LC.rov.mp1_cs(timetag,rej_rov_sum) = rov_mp1_cs(rej_rov_sum);
						LC.rov.mp2_cs(timetag,rej_rov_sum) = rov_mp2_cs(rej_rov_sum);
						poss_rov = find(~isnan(s1_rov));
						prn_poss_rov = intersect(rej_rov_sum,poss_rov);
						if ~isempty(poss_rov)
							for rov_i=1:length(poss_rov)
								rov_ii = find(prn.rov.v==prn_poss_rov(rov_i));
								data(rov_ii,1) = data(rov_ii,1) + s1_rov(rov_i);
								data(rov_ii,5) = data(rov_ii,5) + s2_rov(rov_i);
							end
						end
                    end
       
					%--- �C���s�\�ȉq���̏��O
					%--------------------------------------
					if ~isnan(rej_rov_sum)
						imposs_rov = find(isnan(s1_rov));
						prn_imposs_rov = intersect(rej_rov_sum,imposs_rov);
						rej_lc = union(rej_lc,prn_imposs_rov);
					end
					if ~isnan(rej_ref_sum)
						imposs_ref = find(isnan(s1_ref));
						prn_imposs_ref = intersect(rej_ref_sum,imposs_ref);
						rej_lc = union(rej_lc,prn_imposs_ref);
					end

%					REJ.rej(timetag,rej_lc)=rej_lc;
					rej_uni = union(rej, rej_lc);
				end

			case 4
				%--- �J�C���l�̊i�[
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;					% Multipath ���`����(L1)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;					% Multipath ���`����(L2)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;						% Melbourne-Wubbena ���`����
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;					% �􉽊w�t���[���`����(�����g)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov.lgp;					% �􉽊w�t���[���`����(�R�[�h)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov.lg1;					% �􉽊w�t���[���`����(1���g)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov.lg2;					% �􉽊w�t���[���`����(2���g)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov.ionp;					% �d���w(lgp����Z�o)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov.ionl;					% �d���w(lgl����Z�o,N���܂�)

				%--- �ُ�l���o���ꂽ�q���ԍ��̊i�[
				%------------------------------------------
				REJ.rov.mp1(timetag,:)=rej_rov.mp1;
				REJ.rov.mp2(timetag,:)=rej_rov.mp2;
				REJ.rov.mw(timetag,:)=rej_rov.mw;
				REJ.rov.lgl(timetag,:)=rej_rov.lgl;

				%--- �ُ�l���o�q���̏��O
				%------------------------------------------
				if ismember(0,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.lgl);
				end
				if ismember(1,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.mw);
				end
				if ismember(2,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.mp1);
				end
				if ismember(3,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.mp2);
				end
				rej_i = find(rej_lc>0);
				REJ.rej(timetag,rej_lc(rej_i))=rej_lc(rej_i);
				rej_uni = union(rej, rej_lc(rej_i));

				%--- ���`�����i�[�z��̏��O�q����NaN��
				%------------------------------------------
				LC_r.rov.mp1(timetag-1,rej_lc(rej_i))=NaN; LC_r.rov.mp2(timetag-1,rej_lc(rej_i))=NaN;			% MP1, MP2
				LC_r.rov.mw(timetag-1,rej_lc(rej_i))=NaN;														% MW
				LC_r.rov.lgl(timetag-1,rej_lc(rej_i))=NaN; LC_r.rov.lgp(timetag-1,rej_lc(rej_i))=NaN;			% LGL, LGP
				LC_r.rov.lg1(timetag-1,rej_lc(rej_i))=NaN; LC_r.rov.lg2(timetag-1,rej_lc(rej_i))=NaN;			% LG1, LG2
				LC_r.rov.ionp(timetag-1,rej_lc(rej_i))=NaN; LC_r.rov.ionl(timetag-1,rej_lc(rej_i))=NaN;			% IONP, IONL
			end
        end
        %�M�����x�ɂ��g�p����q�������O
        
        if(find(data(:,8)<20) ~= 0)
            rej_uni = prn.rov.v(find(data(:,8)<20));
        end
        
          if(timetag > 22 && timetag < 52)
              %est_prm.mask = 35;
              rej_uni = [rej_uni,18];
          else
              rej_uni = [];
          end
%         if(timetag > 92)
%             rej_uni = [rej_uni,21];
%         end

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ��� & PPP (�J���}���t�B���^)
		%------------------------------------------------------------------------------------------------------
 else
       
		%--- �J���}���t�B���^�̐ݒ�(�q���ω������Ȃ�)
		%--------------------------------------------
		if find([0,1,2,10]==est_prm.obsmodel)

			%--- �����ƃC���f�b�N�X�̐ݒ�(���q��)
			%--------------------------------------------
			ns=length(prn.rov.v);																% ���q����
			ns_g=length(prn.rov.vg);															% ���q����(GPS)
			ns_r=length(prn.rov.vr);															% ���q����(GLONASS)
			ix.u=1:nx.u; nx.x=nx.u;																% ��M�@�ʒu
			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;													% ��M�@���v�덷

			est_prm.statemodel.hw=0;
			N1ls=[];  N2ls=[];  N12ls=[];

			if timetag==1 || isnan(Kalx_f(1)) || timetag-timetag_o > 5
				Kalx_p=[x(1:3); zeros(nx.u-3,1); x(4); zeros(nx.t-1,1); est_prm.steplength];						% �����l
				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j];
				KalP_p=diag([KalP_p(1:nx.u), est_prm.P0.std_dev_t(1:nx.t),est_prm.P0.std_walking]).^2;
              
                if isempty(refl), refl=est_prm.rovpos; end
			else
				%--- ��ԑJ�ڍs��E�V�X�e���G���s�񐶐�
				%--------------------------------------------
                %%�Z���T�[����̒l���擾����.
                INS(1:3) = getSensor(fpcsv,time,timetag);
				[F,Q]=FQ_state_all6(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,1,INS);
                [m,n]=size(Kalx_p);
                CI = zeros(m,1);
                CI(3,1) = INS(3);  
                
				%--- ECEF(WGS84)����Local�ɕϊ�
				%--------------------------------------------
 				%refl=Kalx_f(1:3);
                
				Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),refl);
            % if timetag<=1
                   % Kalx_f(1:3)=[1.0e+06 * 3.7343,1.0e+06 *1.6868,1.0e+06*-4.8716]
              % end
              
				%--- �J���}���t�B���^(���ԍX�V)
				%--------------------------------------------
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q, CI);
                %�q�������s�����Ă������Ȃ�␳����
                if(stepslip == 1)
                    if(isempty(x))
                        x = Kalx_f;
                        p = KalP_f;
                    end
                    [Kalx_p, KalP_p] = humanstateadjust(Kalx_f, KalP_f, Kalx_p, KalP_p, INS, truestep);
                end
                fprintf(',INS(E:%1.1f N:%1.1f)',Kalx_p(1),Kalx_p(2));
                %if(timetag > 2)
                    %%�����̃J���}���t�B���^(���ԍX�V)
                    %[Kalx_w, KalP_w] = filtekf_pre(Kalx_wf, KalP_wf, wF, wQ);
                %end

				%--- Local����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),refl);
			end
        end
     
		%--- �J���}���t�B���^�̐ݒ�(�q���ω���������)
		%--------------------------------------------
		if find([3,4,5,6,7,8,9]==est_prm.obsmodel)
			%--- Ambiguity �̎Z�o
			%--------------------------------------------
			N1ls=[];  N2ls=[];  N12ls=[];
			N1ls_g=[];  N2ls_g=[];  N12ls_g=[];
			N1ls_r=[];  N2ls_r=[];  N12ls_r=[];
			if est_prm.n_nav==1
				N1ls_g=(wave.g1*data(1:length(prn.rov.vg),1)-data(1:length(prn.rov.vg),2)...
					+2*ion(1:length(prn.rov.vg),1)+C*eph_prm.brd.data(33,ephi(prn.rov.vg))')/wave.g1;			% L1 �����l�o�C�A�X(�t�Z)+TGD��
				if est_prm.freq==2
					N2ls_g=(wave.g2*data(1:length(prn.rov.vg),5)-data(1:length(prn.rov.vg),6)...
						+2*(freq.g1/freq.g2)^2*ion(1:length(prn.rov.vg),1)+C*(freq.g1/freq.g2)^2*eph_prm.brd.data(33,ephi(prn.rov.vg))')/wave.g2;	% L2 �����l�o�C�A�X(�t�Z)+TGD��
					N12ls_g=[wave.g1*N1ls_g wave.g2*N2ls_g]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);					% LC �����l�o�C�A�X(�t�Z)
				end
			end

			if est_prm.g_nav==1 & ~isempty(wave.r2)
				N1ls_r=(wave.r1.*data(length(prn.rov.vg)+1:end,1)-data(length(prn.rov.vg)+1:end,2)...
					+2*ion(length(prn.rov.vg)+1:end,1))./wave.r1;											% L1 �����l�o�C�A�X(�t�Z)
				if est_prm.freq==2
					N2ls_r=(wave.r2.*data(length(prn.rov.vg)+1:end,5)-data(length(prn.rov.vg)+1:end,6)...
						+2*(freq.r1./freq.r2).^2.*ion(length(prn.rov.vg)+1:end,1))./wave.r2;													% L2 �����l�o�C�A�X(�t�Z)
					if ~isempty(wave.r2)
						N12ls_r=[wave.r1.*N1ls_r.*freq.r1.^2 - wave.r2.*N2ls_r.*freq.r2.^2]./(freq.r1.^2-freq.r2.^2);		% LC �����l�o�C�A�X(�t�Z)
					end
				end
			end
			N1ls=[N1ls_g; N1ls_r];
			N2ls=[N2ls_g; N2ls_r];
			N12ls=[N12ls_g; N12ls_r];

			%--- �����ƃC���f�b�N�X�̐ݒ�(���q��)
			%--------------------------------------------
			ns=length(prn.rov.v);																	% ���q����
			ns_g=length(prn.rov.vg);																% ���q����(GPS)
			ns_r=length(prn.rov.vr);																% ���q����(GLONASS)
			ix.u=1:nx.u; nx.x=nx.u;																	% ��M�@�ʒu
			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;														% ��M�@���v�덷
			if est_prm.statemodel.hw==1
				ix.b=nx.x+(1:nx.b); nx.x=nx.x+nx.b;													% ��M�@HWB(ON)
			else
				ix.b=[]; nx.x=nx.x+nx.b;															% ��M�@HWB(OFF)
			end
			if est_prm.statemodel.trop~=0
				ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;													% �Η����x��(ON)
			else
				ix.T=[]; nx.x=nx.x+nx.T;															% �Η����x��(OFF)
			end
			if est_prm.statemodel.ion~=0
				ix.i=nx.x+(1:nx.i); nx.x=nx.x+nx.i;													% �d���w�x��(ON)
			else
				ix.i=[]; nx.x=nx.x+nx.i;															% �d���w�x��(OFF)
			end
			ix.n=nx.x+(1:est_prm.freq*ns); nx.n=length(ix.n); nx.x=nx.x+nx.n;						% �����l�o�C�A�X
			ix.g=ix.n(1:ns_g); nx.g=length(ix.g);													% �����l�o�C�A�X(GPS)
			ix.r=ix.n(ns_g+1:ns); nx.r=length(ix.r);												% �����l�o�C�A�X(GLONASS)
			if est_prm.freq==2
				ix.g=[ix.g ix.n(ns+ns_g+1:end)];
				ix.r=[ix.r ix.n(ns+1:ns+ns_g)];
			end

			%--- �q�����ω������ꍇ�Ɏ����𒲐߂���
			%--------------------------------------------
			if timetag == 1 | isnan(Kalx_f(1)) | timetag-timetag_o > 5								% 1�G�|�b�N��
				Kalx_p=[x(1:3); repmat(0,nx.u-3,1); x(4); repmat(0,nx.t-1,1)];						% �����l
				if est_prm.statemodel.hw==1,   Kalx_p=[Kalx_p; repmat(0,nx.b,1)];, end
				switch est_prm.statemodel.trop
				case 1, Kalx_p=[Kalx_p; 0.4];														% ZWD����
				case 2, Kalx_p=[Kalx_p; 2.4];														% ZTD����
				case 3, Kalx_p=[Kalx_p; 0.4; 0; 0];													% ZWD+Grad����
				case 4, Kalx_p=[Kalx_p; 2.4; 0; 0];													% ZTD+Grad����
				end
				switch est_prm.statemodel.ion
				case 1, Kalx_p=[Kalx_p; 1.0];														% ZID����
				case 2, Kalx_p=[Kalx_p; 1.0; 0];													% ZID+dZID����
				case 3, Kalx_p=[Kalx_p; 1.0; 0; 0];													% ZID+Grad����
				end
				if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; N1ls; N2ls];, end
				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j];
				KalP_p=diag([KalP_p(1:nx.u), est_prm.P0.std_dev_t(1:nx.t),...
							est_prm.P0.std_dev_b(1:nx.b), est_prm.P0.std_dev_T(1:nx.T),...
							est_prm.P0.std_dev_i(1:nx.i), ones(1,nx.n)*est_prm.P0.std_dev_n]).^2;

				%--- dt_dot�̏����l��(dtr-dtr_o)�ŏ�������
				%--------------------------------------------
				if timetag~=1&est_prm.statemodel.dt==1
					idtr=max(find(diff(find(~isnan(dtr_all(:,2))))==1));
					if ~isempty(idtr)
						Kalx_p(nx.u+nx.t) = C*(diff(dtr_all(idtr:idtr+1,2)));
					end
				end
				if isempty(refl), refl=est_prm.rovpos;, end
			else																					% 2�G�|�b�N�ȍ~
				%--- dt_dot�̏����l��(dtr-dtr_o)�ŏ�������
				%--------------------------------------------
				if timetag==2&est_prm.statemodel.dt==1
					idtr=max(find(diff(find(~isnan(dtr_all(:,2))))==1));
					if ~isempty(idtr)
						Kalx_f(nx.u+nx.t) = C*(diff(dtr_all(idtr:idtr+1,2)));
					end
				end

				%--- ��ԑJ�ڍs��E�V�X�e���G���s�񐶐�
				%--------------------------------------------
				[F,Q]=FQ_state_all6(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,1);

				%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
				%--------------------------------------------
				Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),refl);

				%--- �J���}���t�B���^(���ԍX�V)
				%--------------------------------------------
                    
                %�������m�F
                if(length(prn.u) < 5)
                    temp_step = Kalx_f(9);
                   
                    temp_stepcov = KalP_f(9,9);
                end
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);
               
                if(length(prn.u) < 5)
                    Kalx_p(9) = temp_step;
                    KalP_p(9,9) = temp_stepcov;
                end
				% H�� Filter
% 				[Kalx_p, KalP_p] = filthif_pre(Kalx_f, KalP_f, F, Q, gam);

				%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),refl);
               
             
                   est_pos = xyz2enu(Kalx_f(1:3),refl)';
               
				%--- �������ߌ�̏�ԕϐ��Ƌ����U
				%--------------------------------------------
				[Kalx_p,KalP_p]=state_adjust2(prn.rov.v,prn.o,Kalx_p,KalP_p,N1ls,N2ls,[]);			% ��i�\���l / ��i�\���l�̋����U�s��
				N1ls=Kalx_p(ix.n(1:ns));															% �����l�o�C�A�X
				if est_prm.freq==2
					N2ls=Kalx_p(ix.n(ns+1:end));													% �����l�o�C�A�X
				end
			end
		end

		%--- ��M�@���v�덷�̒u��
		%--------------------------------------------
		dtr=Kalx_p(nx.u+1)/C; if isnan(dtr), dtr=x(4)/C;, Kalx_p(nx.u+1)=dtr;, end

		if est_prm.statemodel.pos==4, Kalx_p(1:3)=x(1:3);, end
     
		%--- �ϑ��X�V�̌v�Z(�����\)
		%--------------------------------------------
        
       if (length(prn.rov.vg)) >= 4
		if ~isnan(x(1))
            
			for nn=1:est_prm.iteration
				if nn~=1
					%--- �������ߌ�̏�ԕϐ��Ƌ����U
					% �Eprn.rov.v��Nls�̏��Ԃ�Ή������邱��
					% �Eprn.u��Kal�̏��Ԃ�Ή������邱��
					%--------------------------------------------
					[Kalx_p,KalP_p]=state_adjust2(prn.rov.v,prn.u,Kalx_p,KalP_p,N1ls,N2ls,[]);		% ��i�\���l / ��i�\���l�̋����U�s��
					dtr=Kalx_p(nx.u+1)/C;
				end
                
            
           
				%--- ������
				%--------------------------------------------
				sat_xyz=[]; sat_xyz_dot=[]; dtsv=[]; ion=[];
				trop=[]; azi=[]; ele=[]; rho=[]; ee=[]; tgd=[];

				%--- �ϑ���
				%--------------------------------------------
				Y=obs_vec2(freq,wave,data,prn,est_prm.obsmodel,est_prm);
 
				% �ϑ����f��(�ϑ��ʁE���f���E�ϑ��G��etc)
				%--------------------------------------------
                ref_L=xyz2llh(refl);
				lat=ref_L(1); lon=ref_L(2);
				LL = [         -sin(lon),           cos(lon),        0;
					  -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
					   cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
				[h,H,R,ele,rho,dtsv,ion,trop]=...
						measuremodel2(freq,wave,time,prn.rov.v,eph_prm,ephi,ion_prm,est_prm,Kalx_p,nx);
				%--- �Δ�����Local(ENU)�p�ɕϊ�(�L�l�}�e�B�b�N�p)
				%--------------------------------------------
                    [Y,H,h,R,Kalx_p,KalP_p,prn.u]=...
						select_prn(Y,H,h,R,Kalx_p,KalP_p,prn.rov.v,est_prm,ele,rej_uni,nx,LL);
                H(:,1:3)=(LL*H(:,1:3)')';
                %�q������
                eiseisuu(1,timetag)=length(prn.u);
                
                %h = H*Kalx_p;
                %--- �q������4�����̏ꍇ
				%--------------------------------------------
%                 if (length(prn.u) < 4 && est_prm.sensormixmode == 1)
% 					est_prm.statemodel.sensorbias = 1.5;
%                 else
%                     est_prm.statemodel.sensorbias = 1;
%                 end
				%--- �C�m�x�[�V����
				%--------------------------------------------
				zz = Y - h;
                
%                 if length(prn.u) < 4
% 					zz
%                     H
%                 end

				%--- ���O�c���̌���(��2����)
				%--------------------------------------------
				if timetag>10
					if est_prm.cs_mode==1
					[zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=...
							chi2test(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,0.99);
					REJ.rej(timetag,prn_rej)=prn_rej;
					end
				end

				prn.ug=prn.u(find(prn.u<=32));							% �g�p�q��(GPS)
				prn.ur=prn.u(find(38<=prn.u));							% �g�p�q��(GLONASS)


				%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
				%--------------------------------------------
				Kalx_p(1:3)=xyz2enu(Kalx_p(1:3),refl);

				%--- �J���}���t�B���^(�ϑ��X�V)
				%--------------------------------------------

				[Kalx_f, KalP_f, V] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);
              
            
                %�X�e�b�v�X���b�v�̌��o
                if(length(prn.u) < 5)
                    stepslip = 1;
                    %temp_step = Kalx_p(9);
                    %temp_stepcov = KalP_p(9,9);
                else
                    truestep = Kalx_f(9);
                    stepslip = 0;
                end
                %if(length(prn.u) < 5)
                    %Kalx_f(9) = temp_step;
                    %KalP_f(9,9) = temp_stepcov;
                %end
% 				[Kalx_f, KalP_f] = filtsrcf_upd(zz, H, R, Kalx_p, KalP_p);
% 				[Kalx_f, KalP_f, gam] = filthif_upd(zz, H, R, Kalx_p, KalP_p, 5);

				%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------                      
				Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),refl);   
				Kalx_p=Kalx_f;  KalP_p=KalP_f;                 
				%--- �����̕␳
				%--------------------------------------------
				if est_prm.tide==1
					if timetag==1
						tidexyz(timetag,1:3)=tide2(Kalx_f(1:3)',time.mjd);
						Kalx_f(1:3)=Kalx_f(1:3)-tidexyz(timetag,1:3)';
					else
						tidexyz(timetag,1:3)=tide2(Kalx_f(1:3)',time.mjd);
						Kalx_f(1:3)=Kalx_f(1:3)-(tidexyz(timetag,1:3)-tidexyz(timetag_o,1:3))';
					end
				end

            end  
            
		else
			zz=[];
			prn.u=[]; prn.ug=[]; prn.ur=[];
			Kalx_f(1:nx.u+nx.t+nx.b+nx.T+nx.i,1) = NaN;
        end
       

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
        
		est_pos = xyz2enu(Kalx_f(1:3),refl)';  % ENU�ɕϊ�
        
       else 
           less_frag = 1;
       end
        
		%--- ���ʊi�[(PPP��)
		%--------------------------------------------
             % syoki=[135.9632729264,0034.9817953687,0195.8691933509];
       % syoki2=llh2xyz(syoki)         
 %syoki=[135.9632729264,0034.9817953687,0195.8691933509];
        %syoki2=llh2xyz(syoki)./[180/pi 180/pi 1]
        
		Result.ppp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];	% ����
        if less_frag == 1
		Result.ppp.pos(timetag,:)=[Kalx_p(1:3)', xyz2llh(Kalx_p(1:3)).*[180/pi 180/pi 1]];	
        else
        Result.ppp.pos(timetag,:)=[Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1]];	% �ʒu
        end
         
        
        if less_frag == 1
		Result.ppp.walk(1,timetag)=Kalx_p(9);
        else
        Result.ppp.walk(1,timetag)=Kalx_f(9);
        end
        
        if less_frag == 1
        if est_prm.statemodel.dt==1
			Result.ppp.dtr(timetag,1:nx.t)=Kalx_p(ix.t);											% ��M�@���v�덷
		end
		if est_prm.statemodel.hw==1
			Result.ppp.hwb(timetag,1:nx.b)=Kalx_p(ix.b);											% ��M�@HWB
		end
		if est_prm.statemodel.trop~=0
			Result.ppp.dtrop(timetag,1:nx.T)=Kalx_p(ix.T);											% �Η����x��
		end
		if est_prm.statemodel.ion~=0
			Result.ppp.dion(timetag,1:nx.i)=Kalx_p(ix.i);											% �d���w�x��
		end
        else
            
            if est_prm.statemodel.dt==1
			Result.ppp.dtr(timetag,1:nx.t)=Kalx_f(ix.t);											% ��M�@���v�덷
		end
		if est_prm.statemodel.hw==1
			Result.ppp.hwb(timetag,1:nx.b)=Kalx_f(ix.b);											% ��M�@HWB
		end
		if est_prm.statemodel.trop~=0
			Result.ppp.dtrop(timetag,1:nx.T)=Kalx_f(ix.T);											% �Η����x��
		end
		if est_prm.statemodel.ion~=0
			Result.ppp.dion(timetag,1:nx.i)=Kalx_f(ix.i);											% �d���w�x��
        end
        
        end
            
            
            less_frag =0;
            
		Res.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];							% ����
		if ~isempty(zz)
			if find([0,1,2,4,5]==est_prm.obsmodel)
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
			end
			if find([3,7,8]==est_prm.obsmodel)
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.post{2,1}(timetag,prn.u) = V(1+length(prn.u):2*length(prn.u),1)';
			end
			if est_prm.obsmodel==6
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.post{2,1}(timetag,prn.u) = V(1+length(prn.u):2*length(prn.u),1)';
				Res.pre{3,1}(timetag,prn.u) = zz(1+2*length(prn.u):3*length(prn.u),1)';
				Res.post{3,1}(timetag,prn.u) = V(1+2*length(prn.u):3*length(prn.u),1)';
				Res.pre{4,1}(timetag,prn.u) = zz(1+3*length(prn.u):4*length(prn.u),1)';
				Res.post{4,1}(timetag,prn.u) = V(1+3*length(prn.u):4*length(prn.u),1)';
			end
			if est_prm.obsmodel==9
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.post{2,1}(timetag,prn.u) = V(1+length(prn.u):2*length(prn.u),1)';
				Res.pre{3,1}(timetag,prn.u) = zz(1+2*length(prn.u):3*length(prn.u),1)';
				Res.post{3,1}(timetag,prn.u) = V(1+2*length(prn.u):3*length(prn.u),1)';
			end
			if est_prm.obsmodel==3 | est_prm.obsmodel==4
				Result.ppp.amb{1,1}(timetag,prn.u) = ...
						Kalx_f(nx.u+nx.t+nx.b+nx.T+nx.i+1:nx.u+nx.t+nx.b+nx.T+nx.i+length(prn.u),1)';
			end
			if find([5,6,7,8,9]==est_prm.obsmodel)
				Result.ppp.amb{1,1}(timetag,prn.u) = ...
						Kalx_f(nx.u+nx.t+nx.b+nx.T+nx.i+1:nx.u+nx.t+nx.b+nx.T+nx.i+length(prn.u),1)';
				Result.ppp.amb{2,1}(timetag,prn.u) = ...
						Kalx_f(nx.u+nx.t+nx.b+nx.T+nx.i+length(prn.u)+1:nx.u+nx.t+nx.b+nx.T+nx.i+2*length(prn.u),1);
            
                
 
                        
                         
                    
			end
        end

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ��� & PPP (�J���}���t�B���^) ---->> �I��
		%------------------------------------------------------------------------------------------------------

		%--- �q���ω��`�F�b�N
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.u);							% �q���ω��̃`�F�b�N
% 		end

		%--- ��ʕ\��
		%--------------------------------------------
       
		fprintf('%10.4f %10.4f %10.4f  %3d   PRN:',est_pos(1:3),length(prn.u));
        Result.ppp.error(timetag,1:3)=est_pos(1:3);
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
        if length(prn.u) < 4
            fprintf('�F�q�����̕s���ɂ�茋�ʂ��������������鋰�ꂪ����܂�')
            Result.ppp.lostsat(timetag,1)=1;
        end
        fprintf('(STEP:%1.1f)',Kalx_p(9));
% 		if change_flag==1, fprintf(' , Change');, end
		fprintf('\n')
        %Result.ppp.pos(timetag,1:3)=est_pos(1:3);

		%--- �q���i�[
		%--------------------------------------------
       
		Result.ppp.prn{3}(timetag,1:8)=[time.tod,length(prn.rov.v),length(prn.rov.v(find(prn.rov.vg))),length(prn.rov.v(find(prn.rov.vr))),...
										length(prn.u),length(prn.u(find(prn.ug))),length(prn.u(find(prn.ur))),dop];
                                    
		Result.ppp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.u), Result.ppp.prn{2}(timetag,prn.u)=prn.u;, end

		%--- ���ʏ����o��
		%--------------------------------------------
		fprintf(f_sol,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',...
				timetag,time.week,time.tow,time.tod,Kalx_f(1:3),est_pos);

		%--- �����̐ݒ�
		%--------------------------------------------
		nxo.u=nx.u; nxo.t=nx.t; nxo.b=nx.b; nxo.T=nx.T; nxo.i=nx.i;
		nxo.n=est_prm.freq*length(prn.u);
		nxo.x=nxo.u+nxo.t+nxo.b+nxo.T+nxo.i+nxo.n;

		prn.o = prn.u;
		time_o=time;
		timetag_o=timetag;

	end
	% end ����
	%--------------------------------------------
	if feof(fpo), break;, end
end
fclose('all');

        
toc
%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z ---->> �I��
%-----------------------------------------------------------------------------------------

%--- MAT�ɕۑ�
%--------------------------------------------
matname=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','Res','OBS','LC');

%--- ���ʌ��ʃv���b�g
%--------------------------------------------
%plot_data2([est_prm.dirs.result,matname]);
plot_data([est_prm.dirs.result,matname]);


fn_kml = 'result.kml';
point_color = 'B';                                                          %�}�[�J�̐F�w��'Y','M','C','R','G','B','W','K'
track_color = 'B';                                                          %��芸�����w�肷��i������Ȃ���OK�j
%data.time = Result.ppp.time(:,1:4);                      %Y M D H M S lat lon alt
%data.pos =  Result.ppp.inserror(:,4:6);
%output_kml(fn_kml,data,track_color,point_color);
% %--- KML�o��
% %--------------------------------------------
% kmlname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
%		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
 % kmlname2=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.kml',...
%		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp,'B','G');
%output_kml([est_prm.dirs.result,kmlname2],Result.ppp,'Y','R');
 kmlname=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.kml',...
 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod])/3600);
 output_kml([est_prm.dirs.result,kmlname],Result.ppp,'G','G');
% %--- NMEA�o��
% %--------------------------------------------
% nmeaname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname2=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname1],Result.spp);
% output_nmea([est_prm.dirs.result,nmeaname2],Result.ppp);
% 
% %--- INS�p
% %--------------------------------------------
% insname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% insname2=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname1],Result.spp,est_prm);
% output_ins([est_prm.dirs.result,insname2],Result.ppp,est_prm);

fclose('all');
