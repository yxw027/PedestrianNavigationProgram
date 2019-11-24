%-------------------------------------------------------------------------------%
%                 ���{�E�v�ی��� GPS���ʉ��Z��۸��с@Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS���ʉ��Z�v���O����(Relative DD Fix��)
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
%     0. ��������
%     1. �P�Ƒ��� (�ŏ����@)
%     2. �N���b�N�W�����v�␳���␳�ς݊ϑ��ʂ��쐬
%     3. ���Α��� (�J���}���t�B���^)
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
% read_eph.m          : �G�t�F�����X�̎擾
% read_ionex2.m       : IONEX�f�[�^�擾
% read_sp3.m          : ������f�[�^�擾
% read_obs_epo_data.m : OBS�G�|�b�N����� & OBS�ϑ��f�[�^�擾
%-------------------------------------------------------------------------------
% cal_time2.m         : �w�莞����GPS�T�ԍ��EToW�EToD�̌v�Z
% clkjump_repair2.m   : ��M�@���v�̔�т̌��o/�C��
% mjuliday.m          : MJD�̌v�Z
% weekf.m             : WEEK, TOW �̌v�Z
%-------------------------------------------------------------------------------
% azel.m              : �p, ���ʊp, �Δ����W���̌v�Z
% geodist_mix.m       : �􉽊w�I�������̌v�Z(������,������)
% interp_lag.m        : ���O�����W�����
% pointpos2.m         : �P�Ƒ��ʉ��Z
% sat_pos.m           : �q���O���v�Z(�ʒu�E���x�E���v�덷)
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
% chi2test_dd         : ���O�c���̌���(��2����)(DD�p)
% lc_lim              : ���`�����ɂ��T�C�N���X���b�v���o臒l�̌v�Z
% lc_chi2             : ���`�����̃J�C��挟��
% lc_chi2r            : ���`�����̃J�C��挟��(�A���G�|�b�N)
% outlier_detec.m     : ���`�����ɂ��ُ�l����
% pre_chi2.m          : ���`�����̃J�C��挟���臒l, �����։��s��v�Z
%-------------------------------------------------------------------------------
% prn_check.m         : �q���ω��̌��o
% sat_order.m         : �q��PRN�̏��Ԃ̌���
% select_prn.m        : �g�p�q���̑I��
% state_adjust_dd5.m  : �q���ω����̎�������(DD�p)
%-------------------------------------------------------------------------------
% obs_comb.m          : �e����`�����̌v�Z
% obs_vec.m           : �ϑ��ʃx�N�g���쐬
%-------------------------------------------------------------------------------
% FQ_state_all6.m     : ��ԃ��f���̐���
%-------------------------------------------------------------------------------
% filtekf_pre.m       : �J���}���t�B���^�̎��ԍX�V
% filtekf_upd.m       : �J���}���t�B���^�̊ϑ��X�V
%-------------------------------------------------------------------------------
% ambfix3             : Ambiguity Resolution & Validation(amb_scn���T�u��)
% lambda2.m           : LAMBDA�@(by Kubo, �e�֐����T�u��)
% mlambda.m           : MLAMBDA�@(by Takasu)
% selfixed            : �����l�o�C�A�X�̌Œ蔻��
% likelihood          : �ޓx�䌟��
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
%-------------------------------------------------------------------------------
% recpos3.m           : �d�q��_�̋ǔԍ�����
%-------------------------------------------------------------------------------
% 
% �E2���g�R�[�h����є����g�̑��Α���(�J���}���t�B���^)�ɑΉ�
% �E�d���w�E�Η������f��2�d�����l��(��������ł͕K�{)
% �E�ϑ��X�V�̃��[�v�ɑΉ�?
% �E�L�l�}�e�B�b�N�Ή�
% �E�d���w�x���̐���ɑΉ�(SD�d���w)
% �E�Η�������ɑΉ�(�ϑ��ǂ��Ƃɐݒ聨ref:1, rov:1)
% �E�����l�o�C�A�X�Œ�o�[�W�����ɉ���(�Œ肠��E�Ȃ��̑I�����\)
% 
% �EDD���Α��� + �d���w����(Slant SD) + �Η�������(�ǖ�ZWD) �� Best + �������OK
% 
% <�ۑ�>
% �E�T�C�N���X���b�v, �ُ�l���o(���`����, ���O�c���E����c������)
% �EAR�̕��@(�u��, �A���Ȃ�)�E�E�E�A����OK
% �E�f�[�^�X�V�Ԋu�� 1[sec]�ȉ��̏ꍇ�~ �� �ǂݔ�΂�, �����������C��
% 
% �c���`�F�b�N�̂��߂Ɋϑ����f�����֐�������K�v������
% ���O�Ǝ���̊ϑ����f���ŗ��p�����ԕϐ��݈̂قȂ邾��������֐��ŗ��p�ł��������֗�
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov     : ���q��(rov)
%  prn.rovu    : �g�p�q��(rov)
%  prn.ref.v     : ���q��(ref)
%  prn.refu    : �g�p�q��(ref)
%  prn.c       : ���ʉ��q��(rov,ref)
%  prn.u       : ���ʎg�p�q��(rov,ref)
%  prn.float   : Float�Ƃ��ė��p����q��(rov,ref)
%  prn.fix     : Fix�Ƃ��ė��p����q��(rov,ref)
%  prn.ar      : AR�ŗ��p����q��(rov,ref)
%  prn.o       : �O�G�|�b�N�̎g�p�q��(rov,ref)
%  prn.float_o : �O�G�|�b�N��Float�Ƃ��ė��p�����q��(rov,ref)
% 
% ���������̕���������(MJD�݂̂Ŕ�r����悤�ɂ��Ă݂�+0.1�b�܂Ō���悤�ɕύX)
% �� �X�V�Ԋu��1[Hz]�ȏ�ł��ł���悤�ɏC��
% �� ����ɔ���, ���ɂ��C�����Ă��镔������
% 
% LAMBDA�Ō��肳�ꂽ���������S�������Ƃ��ė��p����΁C�]���̎�@(�Œ�Ȃ�)�ł�
% Fix�������P����̂ł́E�E�E�H
% 
% WL+NL���S�������ŗ��p���邱�Ƃł�Fix�������P����͂�
% 
%-------------------------------------------------------------------------------
% latest update : 2009/02/25 by Fujita
%-------------------------------------------------------------------------------
% 
% �E�d���w����(DD)�Ή�
% �E�ޓx�䌟��Ή�
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov.v   : ���q��(rov)
%  prn.rov.vg  : GPS�̉��q��(rov)
%  prn.rov.vr  : GLONASS�̉��q��(rov)
%  prn.ref.v   : ���q��(ref)
%  prn.ref.vg  : GPS�̉��q��(ref)
%  prn.ref.vr  : GLONASS�̉��q��(ref)
%  prn.ug      : GPS�̎g�p�q��
%  prn.ur      : GLONASS�̎g�p�q��
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/25 by Yanase, Ohashi, Tomita
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

clear all
clc

%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z
%-----------------------------------------------------------------------------------------
addpath ./toolbox_gnss/
addpath ./LAMBDA_KUBO/

%--- �����ݒ�擾
%--------------------------------------------
cd('./INI/');
inifile=input('�����ݒ�t�@�C�������g���q�Ȃ��œ��͂��ĉ�����>> \n','s');
eval(inifile);
cd ..

%--- �t�@�C���������ƃt�@�C���擾
%--------------------------------------------
est_prm=fileget2(est_prm);

if ~exist(est_prm.dirs.result)
	mkdir(est_prm.dirs.result);			% ���ʂ̃f�B���N�g������
end

tic

sf=0;
timetag=0;
timetag_o=0;
% change_flag=0;
dtr_o1=[];
dtr_o2=[];
jump_width_all1=[];
jump_width_all2=[];
rej=[];
prn.o=[];

%--- �萔(�O���[�o���ϐ�)
%--------------------------------------------
% phisic_const;

%--- �萔
%--------------------------------------------
C=299792458;							% ����
f1=1.57542e9;  lam1=C/f1;				% L1 ���g�� & �g��
f2=1.22760e9;  lam2=C/f2;				% L2 ���g�� & �g��

OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

freq.g1=1.57542e9;						% L1 ���g��(GPS)
wave.g1=C/1.57542e9;					% L1 �g��(GPS)
freq.g2=1.22760e9;						% L2 ���g��(GPS)
wave.g2=C/1.22760e9;					% L2 �g��(GPS)


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
fpo1=fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');						% Rov obs
fpn1=fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');						% Rov nav
fpo2=fopen([est_prm.dirs.obs,est_prm.file.ref_o],'rt');						% Ref obs
fpn2=fopen([est_prm.dirs.obs,est_prm.file.ref_n],'rt');						% Ref nav

f_lam = fopen([est_prm.dirs.result,est_prm.file.lambda], 'w');				% LAMBDA �@�̃��O

if fpo1==-1 | fpn1==-1 | fpo2==-1 | fpo2==-1
	if fpo1==-1, fprintf('%s���J���܂���.\n',est_prm.file.rov_o);, end		% Rov obs(�G���[����)
	if fpn1==-1, fprintf('%s���J���܂���.\n',est_prm.file.rov_n);, end		% Rov nav(�G���[����)
	if fpo2==-1, fprintf('%s���J���܂���.\n',est_prm.file.ref_o);, end		% Ref obs(�G���[����)
	if fpn2==-1, fprintf('%s���J���܂���.\n',est_prm.file.ref_n);, end		% Ref nav(�G���[����)
	break;
end

%--- obs �w�b�_�[���
%--------------------------------------------
[tofh1,toeh1,s_time1,e_time1,app_xyz1,no_obs1,TYPES1,dt,Rec_type1]=read_obs_h(fpo1);		% Rov
[tofh2,toeh2,s_time2,e_time2,app_xyz2,no_obs2,TYPES2,dt,Rec_type2]=read_obs_h(fpo2);		% Ref

%--- �G�t�F�����X�Ǎ���(Klobuchar model �p�����[�^�̒��o��)
%--------------------------------------------
[eph_prm.brd.data1,ion_prm.klob.ionab]=read_eph(fpn1);										% Rov
[eph_prm.brd.data2,ion_prm.klob.ionab]=read_eph(fpn2);										% Ref
eph_prm.brd.data=[eph_prm.brd.data1,eph_prm.brd.data2];
[n,i]=unique(eph_prm.brd.data(1:34,:)','rows'); eph_prm.brd.data=eph_prm.brd.data(:,i);		% Rov��Ref�̌���

%--- IONEX�f�[�^�擾
%--------------------------------------------
if est_prm.i_mode==2
	[ion_prm.gim]=read_ionex2([est_prm.dirs.ionex,est_prm.file.ionex]);
else
	ion_prm.gim.time=[]; ion_prm.gim.map=[]; ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- ������̓Ǎ���
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);
else
	eph_prm.sp3.data=[];
end

%--- �ݒ���̏o��(Float�p)
%--------------------------------------------
datname1=sprintf('Float_%s_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol1  = fopen([est_prm.dirs.result,datname1],'w');							% ���ʏ����o���t�@�C���̃I�[�v��
output_log(f_sol1,time_s,time_e,est_prm,2);

%--- �ݒ���̏o��(Fix�p)
%--------------------------------------------
datname2=sprintf('Fix_%s_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol2  = fopen([est_prm.dirs.result,datname2],'w');							% ���ʏ����o���t�@�C���̃I�[�v��
output_log(f_sol2,time_s,time_e,est_prm,3);

%--- �����ƃC���f�b�N�X�̐ݒ�(��ԃ��f������)
%--------------------------------------------
switch est_prm.statemodel.pos
case 0, nx.u=3*1;
case 1, nx.u=3*2;
case 2, nx.u=3*3;
case 3, nx.u=3*4;
case 4, nx.u=3*1;
case 5, nx.u=3*2+2;
end

switch est_prm.statemodel.trop
case 0, nx.T=0;
case 1, nx.T=1*2;
case 2, nx.T=1*2;
end

%--- �z��̏���
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;

%--- SPP�p
%--------------------------------------------
Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% ����
Result.spp.pos(1:tt,1:6)=NaN;													% �ʒu
Result.spp.dtr(1:tt,1:1)=NaN;													% ��M�@���v�덷
Result.spp.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.spp.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.spp.prn{3}(1:tt,1:3)=NaN;												% �q����

%--- Float�p
%--------------------------------------------
Result.float.time(1:tt,1:10)=NaN; Result.float.time(:,1)=1:tt;					% ����
Result.float.pos(1:tt,1:6)=NaN;													% �ʒu
Result.float.dion(1:tt,1:32)=NaN;												% �d���w�x��
Result.float.dtrop(1:tt,1:2)=NaN;												% �Η����x��
for j=1:2, for k=1:32, Result.float.amb{j,k}(1:tt,1:32)=NaN;, end, end			% �����l�o�C�A�X
Result.float.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.float.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.float.prn{3}(1:tt,1:3)=NaN;												% �q����
Result.float.prn{4}(1:tt,1:32)=NaN;												% �g�p�q��(�)

%--- Fix�p
%--------------------------------------------
Result.fix.time(1:tt,1:10)=NaN; Result.fix.time(:,1)=1:tt;						% ����
Result.fix.pos(1:tt,1:6)=NaN;													% �ʒu
Result.fix.dion(1:tt,1:32)=NaN;													% �d���w�x��
Result.fix.dtrop(1:tt,1:2)=NaN;													% �Η����x��
for j=1:2, for k=1:32, Result.fix.amb{j,k}(1:tt,1:32)=NaN;, end, end			% �����l�o�C�A�X
Result.fix.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.fix.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.fix.prn{3}(1:tt,1:4)=NaN;												% �q����
Result.fix.prn{4}(1:tt,1:32)=NaN;												% �g�p�q��(�)

Result.float.ps(1:tt,1:3)=NaN;													% �ʒu
Result.fix.ps(1:tt,1:3)=NaN;													% �ʒu

%--- �c���p
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% ����
for j=1:4, for k=1:32, Res.pre{j,k}(1:tt,1:32)=NaN;, end, end					% �c��(pre-fit)
for j=1:4, for k=1:32, Res.post{j,k}(1:tt,1:32)=NaN;, end, end					% �c��(post-fit)

%--- clock jump�p
%--------------------------------------------
dtr_all1(1:tt,1:2)=NaN; dtr_all2(1:tt,1:2)=NaN;

%--- �ϑ��f�[�^�p
%--------------------------------------------
OBS.rov.time(1:tt,1:10)=NaN; OBS.rov.time(:,1)=1:tt;							% ����
OBS.rov.ca(1:tt,1:32)=NaN; OBS.rov.py(1:tt,1:32)=NaN;							% CA, PY
OBS.rov.ph1(1:tt,1:32)=NaN; OBS.rov.ph2(1:tt,1:32)=NaN;							% L1, L2
OBS.rov.ion(1:tt,1:32)=NaN; OBS.rov.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.rov.ele(1:tt,1:32)=NaN; OBS.rov.azi(1:tt,1:32)=NaN;							% Elevation, Azimuth
OBS.rov.ca_cor(1:tt,1:32)=NaN; OBS.rov.py_cor(1:tt,1:32)=NaN;					% CA, PY(Corrected)
OBS.rov.ph1_cor(1:tt,1:32)=NaN; OBS.rov.ph2_cor(1:tt,1:32)=NaN;					% L1, L2(Corrected)

OBS.ref.time(1:tt,1:10)=NaN; OBS.ref.time(:,1)=1:tt;							% ����
OBS.ref.ca(1:tt,1:32)=NaN; OBS.ref.py(1:tt,1:32)=NaN;							% CA, PY
OBS.ref.ph1(1:tt,1:32)=NaN; OBS.ref.ph2(1:tt,1:32)=NaN;							% L1, L2
OBS.ref.ion(1:tt,1:32)=NaN; OBS.ref.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.ref.ele(1:tt,1:32)=NaN; OBS.ref.azi(1:tt,1:32)=NaN;							% Elevation, Azimuth
OBS.ref.ca_cor(1:tt,1:32)=NaN; OBS.ref.py_cor(1:tt,1:32)=NaN;					% CA, PY(Corrected)
OBS.ref.ph1_cor(1:tt,1:32)=NaN; OBS.ref.ph2_cor(1:tt,1:32)=NaN;					% L1, L2(Corrected)

%--- LC�p
%--------------------------------------------
LC.rov.time(1:tt,1:10)=NaN; LC.rov.time(:,1)=1:tt;								% ����
LC.rov.mp1(1:tt,1:61)=NaN; LC.rov.mp2(1:tt,1:61)=NaN;							% MP1, MP2
LC.rov.mw(1:tt,1:61)=NaN;														% MW
LC.rov.lgl(1:tt,1:61)=NaN; LC.rov.lgp(1:tt,1:61)=NaN;							% LGL, LGP
LC.rov.lg1(1:tt,1:61)=NaN; LC.rov.lg2(1:tt,1:61)=NaN;							% LG1, LG2
LC.rov.ionp(1:tt,1:61)=NaN; LC.rov.ionl(1:tt,1:61)=NaN;							% IONP, IONL

LC.ref.time(1:tt,1:10)=NaN; LC.ref.time(:,1)=1:tt;								% ����
LC.ref.mp1(1:tt,1:61)=NaN; LC.ref.mp2(1:tt,1:61)=NaN;							% MP1, MP2
LC.ref.mw(1:tt,1:61)=NaN;														% MW
LC.ref.lgl(1:tt,1:61)=NaN; LC.ref.lgp(1:tt,1:61)=NaN;							% LGL, LGP
LC.ref.lg1(1:tt,1:61)=NaN; LC.ref.lg2(1:tt,1:61)=NaN;							% LG1, LG2
LC.ref.ionp(1:tt,1:61)=NaN; LC.ref.ionl(1:tt,1:61)=NaN;							% IONP, IONL

%--- �ُ�l���o�p
%--------------------------------------------
LC.rov.mp1_va(1:tt,1:61)=NaN; LC.rov.mp2_va(1:tt,1:61)=NaN;						% ���`�����̕��U(rov)
LC.rov.mw_va(1:tt,1:61)=NaN;
LC.rov.lgl_va(1:tt,1:61)=NaN; LC.rov.lgp_va(1:tt,1:61)=NaN;
LC.rov.lg1_va(1:tt,1:61)=NaN; LC.rov.lg2_va(1:tt,1:61)=NaN;
LC.rov.ionp_va(1:tt,1:61)=NaN; LC.rov.ionl_va(1:tt,1:61)=NaN;
LC.rov.mp1_lim(1:tt,1:61)=NaN; LC.rov.mp2_lim(1:tt,1:61)=NaN;					% ���`�����T�C�N���X���b�v�W���΍�臒l(rov)
LC.rov.mw_lim(1:tt,1:61)=NaN; LC.rov.lgl_lim(1:tt,1:61)=NaN;
% LC.rov.lgp_lim(1:tt,1:61)=NaN;LC.rov.lg1_lim(1:tt,1:61)=NaN;
% LC.rov.lg2_lim(1:tt,1:61)=NaN; LC.rov.ionp_lim(1:tt,1:61)=NaN;
% LC.rov.ionl_lim(1:tt,1:61)=NaN;
LC.ref.mp1_va(1:tt,1:61)=NaN; LC.ref.mp2_va(1:tt,1:61)=NaN;						% ���`�����̕��U(ref)
LC.ref.mw_va(1:tt,1:61)=NaN;
LC.ref.lgl_va(1:tt,1:61)=NaN; LC.ref.lgp_va(1:tt,1:61)=NaN;
LC.ref.lg1_va(1:tt,1:61)=NaN; LC.ref.lg2_va(1:tt,1:61)=NaN;
LC.ref.ionp_va(1:tt,1:61)=NaN; LC.ref.ionl_va(1:tt,1:61)=NaN;
LC.ref.mp1_lim(1:tt,1:61)=NaN; LC.ref.mp2_lim(1:tt,1:61)=NaN;					% ���`�����T�C�N���X���b�v�W���΍�臒l(ref)
LC.ref.mw_lim(1:tt,1:61)=NaN; LC.ref.lgl_lim(1:tt,1:61)=NaN;
% LC.ref.lgp_lim(1:tt,1:61)=NaN;LC.ref.lg1_lim(1:tt,1:61)=NaN;
% LC.ref.lg2_lim(1:tt,1:61)=NaN; LC.ref.ionp_lim(1:tt,1:61)=NaN;
% LC.ref.ionl_lim(1:tt,1:61)=NaN;

LC.rov.cs1(1:tt,1:61)=NaN;														% �X���b�v�ʐ���l(rov)
LC.rov.cs2(1:tt,1:61)=NaN;
LC.rov.lgl_cs(1:tt,1:61) = NaN; LC.rov.mw_cs(1:tt,1:61) = NaN;
LC.rov.mp1_cs(1:tt,1:61) = NaN; LC.rov.mp2_cs(1:tt,1:61) = NaN;
LC.ref.cs1(1:tt,1:61)=NaN;														% �X���b�v�ʐ���l(ref)
LC.ref.cs2(1:tt,1:61)=NaN;
LC.ref.lgl_cs(1:tt,1:61) = NaN; LC.ref.mw_cs(1:tt,1:61) = NaN;
LC.ref.mp1_cs(1:tt,1:61) = NaN; LC.ref.mp2_cs(1:tt,1:61) = NaN;

LC_r.rov.mp1(1:tt,1:61)=NaN; LC_r.rov.mp2(1:tt,1:61)=NaN;						% ���O�q����r���������`����(rov)
LC_r.rov.mw(1:tt,1:61)=NaN;
LC_r.rov.lgl(1:tt,1:61)=NaN; LC_r.rov.lgp(1:tt,1:61)=NaN;
LC_r.rov.lg1(1:tt,1:61)=NaN; LC_r.rov.lg2(1:tt,1:61)=NaN;
LC_r.rov.ionp(1:tt,1:61)=NaN; LC_r.rov.ionl(1:tt,1:61)=NaN;
LC_r.ref.mp1(1:tt,1:61)=NaN; LC_r.ref.mp2(1:tt,1:61)=NaN;						% ���O�q����r���������`����(ref)
LC_r.ref.mw(1:tt,1:61)=NaN;
LC_r.ref.lgl(1:tt,1:61)=NaN; LC_r.ref.lgp(1:tt,1:61)=NaN;
LC_r.ref.lg1(1:tt,1:61)=NaN; LC_r.ref.lg2(1:tt,1:61)=NaN;
LC_r.ref.ionp(1:tt,1:61)=NaN; LC_r.ref.ionl(1:tt,1:61)=NaN;

CHI2.kal.l1(1:tt,1:61)=NaN; CHI2.kal.l2(1:tt,1:61)=NaN;							% �J���}���t�B���^�̃C�m�x�[�V�����ɂ�錟��̃J�C2�挟�蓝�v��

CHI2.rov.mp1(1:tt,1:61)=NaN; CHI2.rov.mp2(1:tt,1:61)=NaN;						% ���`�����T�C�N���X���b�v�J�C2�挟�蓝�v��(rov)
CHI2.rov.mw(1:tt,1:61)=NaN; CHI2.rov.lgl(1:tt,1:61)=NaN;
CHI2.rov.lgp(1:tt,1:61)=NaN; CHI2.rov.lg1(1:tt,1:61)=NaN;
CHI2.rov.lg2(1:tt,1:61)=NaN; CHI2.rov.ionp(1:tt,1:61)=NaN;
CHI2.rov.ionl(1:tt,1:61)=NaN;
CHI2.ref.mp1(1:tt,1:61)=NaN; CHI2.ref.mp2(1:tt,1:61)=NaN;						% ���`�����T�C�N���X���b�v�J�C2�挟�蓝�v��(ref)
CHI2.ref.mw(1:tt,1:61)=NaN; CHI2.ref.lgl(1:tt,1:61)=NaN;
CHI2.ref.lgp(1:tt,1:61)=NaN; CHI2.ref.lg1(1:tt,1:61)=NaN;
CHI2.ref.lg2(1:tt,1:61)=NaN; CHI2.ref.ionp(1:tt,1:61)=NaN;
CHI2.ref.ionl(1:tt,1:61)=NaN;
[CHI2.sigma, Vb, Gb] = pre_chi2(est_prm.cycle_slip.A,est_prm.cycle_slip.lc_b);	% �J�C��挟��̃J�C2��㑤�m���_, �����։��s��

REJ.rov.mp1(1:tt,1:61)=NaN; REJ.rov.mp2(1:tt,1:61)=NaN;							% ���`�����T�C�N���X���b�v���O�q��(rov)
REJ.rov.mw(1:tt,1:61)=NaN; REJ.rov.lgl(1:tt,1:61)=NaN;
% REJ.rov.lgp(1:tt,1:61)=NaN; REJ.rov.lg1(1:tt,1:61)=NaN;
% REJ.rov.lg2(1:tt,1:61)=NaN; REJ.rov.ionp(1:tt,1:61)=NaN;
% REJ.rov.ionl(1:tt,1:61)=NaN;
REJ.ref.mp1(1:tt,1:61)=NaN; REJ.ref.mp2(1:tt,1:61)=NaN;							% ���`�����T�C�N���X���b�v���O�q��(ref)
REJ.ref.mw(1:tt,1:61)=NaN; REJ.ref.lgl(1:tt,1:61)=NaN;
% REJ.ref.lgp(1:tt,1:61)=NaN; REJ.ref.lg1(1:tt,1:61)=NaN;
% REJ.ref.lg2(1:tt,1:61)=NaN; REJ.ref.ionp(1:tt,1:61)=NaN;
% REJ.ref.ionl(1:tt,1:61)=NaN;
REJ.rej(1:tt,1:61)=NaN;

%--- �����l�o�C�A�X�̌Œ�p
%--------------------------------------------
Fixed_N{1}(1:32,1)=NaN; Fixed_N{1}(1:32,2)=0;
if est_prm.freq==2
	Fixed_N{2}(1:32,1)=NaN; Fixed_N{2}(1:32,2)=0;
end

%--- �����l�o�C�A�X�̖ޓx�䌟��p
%--------------------------------------------
ratio_l=0;


%--- Local(ENU)�p�̕ϊ��s��(�L�l�}�e�B�b�N�p)
%--------------------------------------------
ref_L=xyz2llh(est_prm.refpos);
lat=ref_L(1); lon=ref_L(2);
LL = [         -sin(lon),           cos(lon),        0;
      -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
       cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z ---->> �J�n
%-----------------------------------------------------------------------------------------
while 1

	%--- start ����
	%--------------------------------------------
	if sf == 0
		time1.mjd = -1e10;
		time2.mjd = -1e10;
		while time_s.mjd > time1.mjd+0.1/86400													% �� 0.1 �b��ڂ܂ŔF�߂�
			%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
			%--------------------------------------------
			[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
					read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);

			if time_s.mjd <= time1.mjd+0.1/86400, sf=1; break;, end
		end
		while time_s.mjd > time2.mjd+0.1/86400		%10�b���炷										% �� 0.1 �b��ڂ܂ŔF�߂�
			%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
			%--------------------------------------------
			[time2,no_sat2,prn.ref.v,dtrec2,ephi2,data2]=...
					read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);

			if time_s.mjd <= time2.mjd+0.1/86400, sf=1; break;, end
        end
	else
		%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
		%--------------------------------------------
		[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
				read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
		[time2,no_sat2,prn.ref.v,dtrec2,ephi2,data2]=...
				read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
    end
    if sf==1
		%--- ��������
		%--------------------------------------------
		while 1
			%if abs(time1.mjd-time2.mjd)<=0.1/86400
				%break;
			%else
				if time1.mjd < time2.mjd
					while time1.mjd < time2.mjd
						%--- �G�|�b�N���擾(����, PRN �Ȃ�)
						%--------------------------------------------
						[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
								read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time1.mjd-0.1/86400, break;, end						% �� 0.1 �b��ڂ܂ŔF�߂�
					end
				elseif time1.mjd > time2.mjd
					while time1.mjd > time2.mjd
						%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
						%--------------------------------------------
						[time2,no_sat2,prn.ref.v,dtrec2,ephi2,data2]=...
								read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time2.mjd-0.1/86400, break;, end						% �� 0.1 �b��ڂ܂ŔF�߂�
					end
				end
			%end
			if abs(time1.mjd-time2.mjd)<=0.1/86400 | feof(fpo1) | feof(fpo2), break;, end
		end

		%--- end ����
		%--------------------------------------------
		if time_e.mjd <= time1.mjd-0.1/86400 | time_e.mjd <= time2.mjd-0.1/86400, break;, end	% �� 0.1 �b��ڂ܂ŔF�߂�

		%--- �^�C���^�O
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
		else
			timetag = timetag + round((time1.mjd-time_o.mjd)*86400/dt);
		end

		%--- �ǂݎ�蒆�̃G�|�b�N�̎��ԕ\��
		%--------------------------------------------
		fprintf('%7d: �ړ���-%2d:%2d %5.2f , ���-%2d:%2d %5.2f"  ',timetag,time1.day(4),time1.day(5),time1.day(6),time2.day(4),time2.day(5),time2.day(6));

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
			if ismember(time1.tod,sliptime)
				for cs_i=1:length(est_prm.cycle_slip.prn)
					is = find(prn.rov.v==est_prm.cycle_slip.prn(cs_i));
					if ~isempty(is)
						data1(is,1) = data1(is,1) + est_prm.cycle_slip.slip_l1;
						data1(is,5) = data1(is,5) + est_prm.cycle_slip.slip_l2;
					end
				end
			end
		end

		%--- �P�Ƒ���
		%--------------------------------------------
		[x1,dtr1,dtsv1,ion1,trop1,prn.rovu,rho1,dop1,ele1,azi1]=...
				pointpos2(time1,prn.rov.v,app_xyz1,data1,eph_prm,ephi1,est_prm,ion_prm,rej);
		[x2,dtr2,dtsv2,ion2,trop2,prn.refu,rho2,dop2,ele2,azi2]=...
				pointpos2(time2,prn.ref.v,app_xyz2,data2,eph_prm,ephi2,est_prm,ion_prm,rej);
		if ~isnan(x1(1)), app_xyz1(1:3)=x1(1:3);, end
		if ~isnan(x2(1)), app_xyz2(1:3)=x2(1:3);, end

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos1 = xyz2enu(x1(1:3),est_prm.rovpos)';												% ENU�ɕϊ�
		est_pos2 = xyz2enu(x2(1:3),est_prm.refpos)';												% ENU�ɕϊ�

		%--- ���ʊi�[(SPP)
		%--------------------------------------------
		Result.spp.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% ����
		Result.spp.pos(timetag,:)=[x1(1:3)', xyz2llh(x1(1:3)).*[180/pi 180/pi 1]];					% �ʒu
		Result.spp.dtr(timetag,:)=C*dtr1;															% ��M�@���v�덷

		%--- �q���i�[
		%--------------------------------------------
		Result.spp.prn{3}(timetag,1:4)=[time1.tod,length(prn.rov.v),length(prn.rovu),dop1];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rovu), Result.spp.prn{2}(timetag,prn.rovu)=prn.rovu;, end

		%--- OBS�f�[�^,�d���w�x��(�\����)
		%--------------------------------------------
		OBS.rov.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];					% ����
		OBS.ref.time(timetag,2:10)=[time2.week, time2.tow, time2.tod, time2.day];					% ����
		OBS.rov.ca(timetag,prn.rov.v)   = data1(:,2);												% CA
		OBS.rov.py(timetag,prn.rov.v)   = data1(:,6);												% PY
		OBS.rov.ph1(timetag,prn.rov.v)  = data1(:,1);												% L1
		OBS.rov.ph2(timetag,prn.rov.v)  = data1(:,5);												% L2
		OBS.rov.ion(timetag,prn.rov.v)  = ion1(:,1);												% Ionosphere
		OBS.rov.trop(timetag,prn.rov.v) = trop1(:,1);												% Troposphere

		OBS.ref.ca(timetag,prn.ref.v)   = data2(:,2);												% CA
		OBS.ref.py(timetag,prn.ref.v)   = data2(:,6);												% PY
		OBS.ref.ph1(timetag,prn.ref.v)  = data2(:,1);												% L1
		OBS.ref.ph2(timetag,prn.ref.v)  = data2(:,5);												% L2
		OBS.ref.ion(timetag,prn.ref.v)  = ion2(:,1);												% Ionosphere
		OBS.ref.trop(timetag,prn.ref.v) = trop2(:,1);												% Troposphere

		OBS.rov.ele(timetag,prn.rov.v) = ele1(:,1);													% elevation
		OBS.rov.azi(timetag,prn.rov.v) = azi1(:,1);													% azimuth
		OBS.ref.ele(timetag,prn.ref.v) = ele2(:,1);													% elevation
		OBS.ref.azi(timetag,prn.ref.v) = azi2(:,1);													% azimuth

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@) ---->> �I�� ---->> �N���b�N�W�����v�␳
		%------------------------------------------------------------------------------------------------------

		%--- clock jump �̌��o & �␳
		%--------------------------------------------
		if est_prm.clk_flag == 1
			dtr_all1(timetag,1) = dtr1;																% ��M�@���v�덷���i�[
			[data1,dtr1,time1.day,clk_jump1,dtr_o1,jump_width_all1]=...
						clkjump_repair2(time1.day,data1,dtr1,dtr_o1,jump_width_all1,Rec_type1);		% clock jump ���o/�␳
			clk_check1(timetag,1) = clk_jump1;														% �W�����v�t���O���i�[

			dtr_all2(timetag,1) = dtr2;																% ��M�@���v�덷���i�[
			[data2,dtr2,time2.day,clk_jump2,dtr_o2,jump_width_all2]=...
						clkjump_repair2(time2.day,data2,dtr2,dtr_o2,jump_width_all2,Rec_type2);		% clock jump ���o/�␳
			clk_check2(timetag,1) = clk_jump2;														% �W�����v�t���O���i�[
		end
		dtr_all1(timetag,2) = dtr1;																	% �␳�ςݎ�M�@���v�덷���i�[
		dtr_all2(timetag,2) = dtr2;																	% �␳�ςݎ�M�@���v�덷���i�[

		%--- �␳�ς݊ϑ��ʂ��i�[
		%--------------------------------------------
		OBS.rov.ca_cor(timetag,prn.rov.v)  = data1(:,2);											% CA
		OBS.rov.py_cor(timetag,prn.rov.v)  = data1(:,6);											% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v) = data1(:,1);											% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v) = data1(:,5);											% L2

		OBS.ref.ca_cor(timetag,prn.ref.v)  = data2(:,2);											% CA
		OBS.ref.py_cor(timetag,prn.ref.v)  = data2(:,6);											% PY
		OBS.ref.ph1_cor(timetag,prn.ref.v) = data2(:,1);											% L1
		OBS.ref.ph2_cor(timetag,prn.ref.v) = data2(:,5);											% L2

		%------------------------------------------------------------------------------------------------------
		%----- �ُ�l���o
		%------------------------------------------------------------------------------------------------------

		%--- GPS�EGLONASS�̉q������
		%--------------------------------------------
		prn.rov.vg=prn.rov.v(find(prn.rov.v<=32));							% ���q��(GPS)(rov)
		prn.rov.vr=prn.rov.v(find(38<=prn.rov.v));							% ���q��(GLONASS)(rov)
		prn.ref.vg=prn.ref.v(find(prn.ref.v<=32));							% ���q��(GPS)(ref)
		prn.ref.vr=prn.ref.v(find(38<=prn.ref.v));							% ���q��(GLONASS)(ref)

		LC.rov.variance(1:length(prn.rov.v),1:4)=NaN; 														% ���U�i�[�z��(rov)
		LC.ref.variance(1:length(prn.ref.v),1:4)=NaN; 														% ���U�i�[�z��(ref)
		if est_prm.ww == 0																					% �d�݂Ȃ�
			LC.rov.variance(1:length(prn.rov.v),1)=repmat(est_prm.obsnoise.PR1,length(prn.rov.v),1);		% CA�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),2)=repmat(est_prm.obsnoise.PR2,length(prn.rov.v),1);		% PY�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),3)=repmat(est_prm.obsnoise.Ph1,length(prn.rov.v),1);		% L1�����g�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),4)=repmat(est_prm.obsnoise.Ph2,length(prn.rov.v),1);		% L2�����g�̕��U(rov)
			LC.ref.variance(1:length(prn.ref.v),1)=repmat(est_prm.obsnoise.PR1,length(prn.ref.v),1);		% CA�R�[�h�̕��U(ref)
			LC.ref.variance(1:length(prn.ref.v),2)=repmat(est_prm.obsnoise.PR2,length(prn.ref.v),1);		% PY�R�[�h�̕��U(ref)
			LC.ref.variance(1:length(prn.ref.v),3)=repmat(est_prm.obsnoise.Ph1,length(prn.ref.v),1);		% L1�����g�̕��U(ref)
			LC.ref.variance(1:length(prn.ref.v),4)=repmat(est_prm.obsnoise.Ph2,length(prn.ref.v),1);		% L2�����g�̕��U(ref)
		else																								% �d�ݍl��
			LC.rov.variance(1:length(prn.rov.v),1)= (est_prm.obsnoise.PR1./sin(ele1).^2);					% CA�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),2)= (est_prm.obsnoise.PR2./sin(ele1).^2);					% PY�R�[�h�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),3)= (est_prm.obsnoise.Ph1./sin(ele1).^2);					% L1�����g�̕��U(rov)
			LC.rov.variance(1:length(prn.rov.v),4)= (est_prm.obsnoise.Ph2./sin(ele1).^2);					% L2�����g�̕��U(rov)
% 			LC.rov.variance(1,prn.rov.v)= (est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);	% CA�R�[�h�̕��U(rov)
% 			LC.rov.variance(2,prn.rov.v)= (est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);	% PY�R�[�h�̕��U(rov)
% 			LC.rov.variance(3,prn.rov.v)= (est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele1(ii(b))).^2);	% L1�����g�̕��U(rov)
% 			LC.rov.variance(4,prn.rov.v)= (est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele1(ii(b))).^2);	% L2�����g�̕��U(rov)
			LC.ref.variance(1:length(prn.ref.v),1)= (est_prm.obsnoise.PR1./sin(ele2).^2);					% CA�R�[�h�̕��U(ref)
			LC.ref.variance(1:length(prn.ref.v),2)= (est_prm.obsnoise.PR2./sin(ele2).^2);					% PY�R�[�h�̕��U(ref)
			LC.ref.variance(1:length(prn.ref.v),3)= (est_prm.obsnoise.Ph1./sin(ele2).^2);					% L1�����g�̕��U(ref)
			LC.ref.variance(1:length(prn.ref.v),4)= (est_prm.obsnoise.Ph2./sin(ele2).^2);					% L2�����g�̕��U(ref)
% 			LC.ref.variance(1,prn.ref.v)= (est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele(ii(b))).^2);	% CA�R�[�h�̕��U(ref)
% 			LC.ref.variance(2,prn.ref.v)= (est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele(ii(b))).^2);	% PY�R�[�h�̕��U(ref)
% 			LC.ref.variance(3,prn.ref.v)= (est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele(ii(b))).^2);	% L1�����g�̕��U(ref)
% 			LC.ref.variance(4,prn.ref.v)= (est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele(ii(b))).^2);	% L2�����g�̕��U(ref)
		end

		%--- �e����`�����ƕ��U(�␳�ς݊ϑ��ʂ��g�p)
		%--------------------------------------------
		[mp11,mp21,lgl1,lgp1,lg11,lg21,mw1,ionp1,ionl1,lgl_ion1,...
			mp11_va,mp21_va,lgl1_va,lgp1_va,lg11_va,lg21_va,mw1_va,ionp1_va,ionl1_va]=...
					obs_comb2(est_prm,freq,wave,data1,LC.rov.variance,prn.rov,ion1,ele1);
		[mp12,mp22,lgl2,lgp2,lg12,lg22,mw2,ionp2,ionl2,lgl_ion2,...
			mp12_va,mp22_va,lgl2_va,lgp2_va,lg12_va,lg22_va,mw2_va,ionp2_va,ionl2_va]=...
					obs_comb2(est_prm,freq,wave,data2,LC.ref.variance,prn.ref,ion2,ele2);

		%--- �e����`�����ƕ��U���i�[
		%--------------------------------------------
		ii=find(ele1*180/pi>est_prm.mask);
		if ~isempty(ii)
			if est_prm.cycle_slip.lgl_ion == 0
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl1_va(ii);								% �􉽊w�t���[���`����(�����g)(rov)
			else
				LC.rov.lgl(timetag,prn.rov.v(ii)) = lgl_ion1(ii);								% �􉽊w�t���[���`����(�����g)-�d���w�x����(rov)
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_ion1_va(ii);							% �􉽊w�t���[���`����(�����g)-�d���w�x�����̕��U(rov)
			end

			LC.rov.mp1(timetag,prn.rov.v(ii)) = mp11(ii);										% Multipath ���`����(L1)(rov)
			LC.rov.mp2(timetag,prn.rov.v(ii)) = mp21(ii);										% Multipath ���`����(L2)(rov)
			LC.rov.mw(timetag,prn.rov.v(ii))  = mw1(ii);										% Melbourne-Wubbena ���`����(rov)
			LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp1(ii);										% �􉽊w�t���[���`����(�R�[�h)(rov)
			LC.rov.lg1(timetag,prn.rov.v(ii))  = lg11(ii);										% �􉽊w�t���[���`����(1���g)(rov)
			LC.rov.lg2(timetag,prn.rov.v(ii))  = lg21(ii);										% �􉽊w�t���[���`����(2���g)(rov)
			LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp1(ii);										% �d���w(lgp����Z�o)(rov)
			LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl1(ii);										% �d���w(lgl����Z�o,N���܂�)(rov)

			LC.rov.mp1_va(timetag,prn.rov.v(ii)) = mp11_va(ii);									% Multipath ���`����(L1)�̕��U(rov)
			LC.rov.mp2_va(timetag,prn.rov.v(ii)) = mp21_va(ii);									% Multipath ���`����(L2)�̕��U(rov)
			LC.rov.mw_va(timetag,prn.rov.v(ii))  = mw1_va(ii);									% Melbourne-Wubbena ���`�����̕��U(rov)
			LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl1_va(ii);									% �􉽊w�t���[���`����(�����g)(rov)
			LC.rov.lgp_va(timetag,prn.rov.v(ii))  = lgp1_va(ii);								% �􉽊w�t���[���`����(�R�[�h)�̕��U(rov)
			LC.rov.lg1_va(timetag,prn.rov.v(ii))  = lg11_va(ii);								% �􉽊w�t���[���`����(1���g)�̕��U(rov)
			LC.rov.lg2_va(timetag,prn.rov.v(ii))  = lg21_va(ii);								% �􉽊w�t���[���`����(2���g)�̕��U(rov)
			LC.rov.ionp_va(timetag,prn.rov.v(ii)) = ionp1_va(ii);								% �d���w(lgp����Z�o)�̕��U(rov)
			LC.rov.ionl_va(timetag,prn.rov.v(ii)) = ionl1_va(ii);								% �d���w(lgl����Z�o,N���܂�)�̕��U(rov)
		end

		ii=find(ele2*180/pi>est_prm.mask);
		if ~isempty(ii)
			if est_prm.cycle_slip.lgl_ion == 0
% 				LC.ref.lgl_va(timetag,prn.ref.v(ii)) = lgl2_va(ii);								% �􉽊w�t���[���`����(�����g)(ref)
			else
				LC.ref.lgl(timetag,prn.ref.v(ii)) = lgl_ion2(ii);								% �􉽊w�t���[���`����(�����g)-�d���w�x����(ref)
% 				LC.ref.lgl_va(timetag,prn.ref.v(ii)) = lgl_ion2_va(ii);							% �􉽊w�t���[���`����(�����g)-�d���w�x�����̕��U(ref)
			end

			LC.ref.mp1(timetag,prn.ref.v(ii)) = mp12(ii);										% Multipath ���`����(L1)(ref)
			LC.ref.mp2(timetag,prn.ref.v(ii)) = mp22(ii);										% Multipath ���`����(L2)(ref)
			LC.ref.mw(timetag,prn.ref.v(ii))  = mw2(ii);										% Melbourne-Wubbena ���`����(ref)
			LC.ref.lgp(timetag,prn.ref.v(ii))  = lgp2(ii);										% �􉽊w�t���[���`����(�R�[�h)(ref)
			LC.ref.lg1(timetag,prn.ref.v(ii))  = lg12(ii);										% �􉽊w�t���[���`����(1���g)(ref)
			LC.ref.lg2(timetag,prn.ref.v(ii))  = lg22(ii);										% �􉽊w�t���[���`����(2���g)(ref)
			LC.ref.ionp(timetag,prn.ref.v(ii)) = ionp2(ii);										% �d���w(lgp����Z�o)(ref)
			LC.ref.ionl(timetag,prn.ref.v(ii)) = ionl2(ii);										% �d���w(lgl����Z�o,N���܂�)(ref)

			LC.ref.mp1_va(timetag,prn.ref.v(ii)) = mp12_va(ii);									% Multipath ���`����(L1)�̕��U(ref)
			LC.ref.mp2_va(timetag,prn.ref.v(ii)) = mp22_va(ii);									% Multipath ���`����(L2)�̕��U(ref)
			LC.ref.mw_va(timetag,prn.ref.v(ii))  = mw2_va(ii);									% Melbourne-Wubbena ���`�����̕��U(ref)
			LC.ref.lgl_va(timetag,prn.ref.v(ii)) = lgl2_va(ii);									% �􉽊w�t���[���`����(�����g)(ref)
			LC.ref.lgp_va(timetag,prn.ref.v(ii))  = lgp2_va(ii);								% �􉽊w�t���[���`����(�R�[�h)�̕��U(ref)
			LC.ref.lg1_va(timetag,prn.ref.v(ii))  = lg12_va(ii);								% �􉽊w�t���[���`����(1���g)�̕��U(ref)
			LC.ref.lg2_va(timetag,prn.ref.v(ii))  = lg22_va(ii);								% �􉽊w�t���[���`����(2���g)�̕��U(ref)
			LC.ref.ionp_va(timetag,prn.ref.v(ii)) = ionp2_va(ii);								% �d���w(lgp����Z�o)�̕��U(ref)
			LC.ref.ionl_va(timetag,prn.ref.v(ii)) = ionl2_va(ii);								% �d���w(lgl����Z�o,N���܂�)�̕��U(ref)
		end

		%--- ���`�����ɂ��ُ�l����
		%--------------------------------------------
		rej_rov.mp1  = []; rej_ref.mp1  = [];
		rej_rov.mp2  = []; rej_ref.mp2  = [];
		rej_rov.mw   = []; rej_ref.mw   = [];
		rej_rov.lgl  = []; rej_ref.lgl  = [];

		rej_lc  = [];
		rej_lgl = [];
		rej_mw  = [];
		rej_mp1 = [];
		rej_mp2 = [];
		rej_uni = [];

		%--- ���O�q�����l���������`�����i�[�z��
		%--------------------------------------
		LC_r.rov.mp1(timetag,:)=LC.rov.mp1(timetag,:); LC_r.rov.mp2(timetag,:)=LC.rov.mp2(timetag,:);		% MP1, MP2
		LC_r.rov.mw(timetag,:)=LC.rov.mw(timetag,:);														% MW
		LC_r.rov.lgl(timetag,:)=LC.rov.lgl(timetag,:); LC_r.rov.lgp(timetag,:)=LC.rov.lgp(timetag,:);		% LGL, LGP
		LC_r.rov.lg1(timetag,:)=LC.rov.lg1(timetag,:); LC_r.rov.lg2(timetag,:)=LC.rov.lg2(timetag,:);		% LG1, LG2
		LC_r.rov.ionp(timetag,:)=LC.rov.ionp(timetag,:); LC_r.rov.ionl(timetag,:)=LC.rov.ionl(timetag,:);	% IONP, IONL

		LC_r.ref.mp1(timetag,:)=LC.ref.mp1(timetag,:); LC_r.ref.mp2(timetag,:)=LC.ref.mp2(timetag,:);		% MP1, MP2
		LC_r.ref.mw(timetag,:)=LC.ref.mw(timetag,:);														% MW
		LC_r.ref.lgl(timetag,:)=LC.ref.lgl(timetag,:); LC_r.ref.lgp(timetag,:)=LC.ref.lgp(timetag,:);		% LGL, LGP
		LC_r.ref.lg1(timetag,:)=LC.ref.lg1(timetag,:); LC_r.ref.lg2(timetag,:)=LC.ref.lg2(timetag,:);		% LG1, LG2
		LC_r.ref.ionp(timetag,:)=LC.ref.ionp(timetag,:); LC_r.ref.ionl(timetag,:)=LC.ref.ionl(timetag,:);	% IONP, IONL


		if timetag>1
	
			%--- ���`�����ɂ��ُ�l����
			%--------------------------------------------
			[lim_rov,chi2_rov,rej_rov,lcbb_rov]=outlier_detec(est_prm,timetag,LC.rov,LC_r.rov,CHI2.sigma,REJ.rov,prn.rov.v,Vb,Gb);
			[lim_ref,chi2_ref,rej_ref,lcbb_ref]=outlier_detec(est_prm,timetag,LC.ref,LC_r.ref,CHI2.sigma,REJ.ref,prn.ref.v,Vb,Gb);

			switch est_prm.cs_mode
			case 0,
				rej_uni=rej;
			case 2,
				if timetag>est_prm.cycle_slip.lc_int+1

					%--- 臒l�̊i�[
					%------------------------------------------
					LC.rov.mp1_lim(timetag,:)  = lim_rov.mp1;						% Multipath ���`����(L1)(rov)
					LC.rov.mp2_lim(timetag,:)  = lim_rov.mp2;						% Multipath ���`����(L2)(rov)
					LC.rov.mw_lim(timetag,:)   = lim_rov.mw;						% Melbourne-Wubbena ���`����(rov)
					LC.rov.lgl_lim(timetag,:)  = lim_rov.lgl;						% �􉽊w�t���[���`����(�����g)(rov)
% 					LC.rov.lgp_lim(timetag,:)  = lim_rov.lgp;						% �􉽊w�t���[���`����(�R�[�h)(rov)
% 					LC.rov.lg1_lim(timetag,:)  = lim_rov.lg1;						% �􉽊w�t���[���`����(1���g)(rov)
% 					LC.rov.lg2_lim(timetag,:)  = lim_rov.lg2;						% �􉽊w�t���[���`����(2���g)(rov)
% 					LC.rov.ionp_lim(timetag,:) = lim_rov.ionp;						% �d���w(lgp����Z�o)(rov)
% 					LC.rov.ionl_lim(timetag,:) = lim_rov.ionl;						% �d���w(lgl����Z�o,N���܂�)(rov)

					LC.ref.mp1_lim(timetag,:)  = lim_ref.mp1;						% Multipath ���`����(L1)(ref)
					LC.ref.mp2_lim(timetag,:)  = lim_ref.mp2;						% Multipath ���`����(L2)(ref)
					LC.ref.mw_lim(timetag,:)   = lim_ref.mw;						% Melbourne-Wubbena ���`����(ref)
					LC.ref.lgl_lim(timetag,:)  = lim_ref.lgl;						% �􉽊w�t���[���`����(�����g)(ref)
% 					LC.ref.lgp_lim(timetag,:)  = lim_ref.lgp;						% �􉽊w�t���[���`����(�R�[�h)(ref)
% 					LC.ref.lg1_lim(timetag,:)  = lim_ref.lg1;						% �􉽊w�t���[���`����(1���g)(ref)
% 					LC.ref.lg2_lim(timetag,:)  = lim_ref.lg2;						% �􉽊w�t���[���`����(2���g)(ref)
% 					LC.ref.ionp_lim(timetag,:) = lim_ref.ionp;						% �d���w(lgp����Z�o)(ref)
% 					LC.ref.ionl_lim(timetag,:) = lim_ref.ionl;						% �d���w(lgl����Z�o,N���܂�)(ref)

					%--- �ُ�l���o
					%------------------------------------------
					rej_rov.mp1=find(abs(diff(LC.rov.mp1(timetag-1:timetag,:)))>lim_rov.mp1);
					rej_rov.mp2=find(abs(diff(LC.rov.mp2(timetag-1:timetag,:)))>lim_rov.mp2);
					rej_rov.mw=find(abs(diff(LC.rov.mw(timetag-1:timetag,:)))>lim_rov.mw);
					rej_rov.lgl=find(abs(diff(LC.rov.lgl(timetag-1:timetag,:)))>lim_rov.lgl);
					rej_ref.mp1=find(abs(diff(LC.ref.mp1(timetag-1:timetag,:)))>lim_ref.mp1);
					rej_ref.mp2=find(abs(diff(LC.ref.mp2(timetag-1:timetag,:)))>lim_ref.mp2);
					rej_ref.mw=find(abs(diff(LC.ref.mw(timetag-1:timetag,:)))>lim_ref.mw);
					rej_ref.lgl=find(abs(diff(LC.ref.lgl(timetag-1:timetag,:)))>lim_ref.lgl);

					rej_mp1=union(rej_rov.mp1,rej_ref.mp1);
					rej_mp2=union(rej_rov.mp2,rej_ref.mp2);
					rej_mw=union(rej_rov.mw,rej_ref.mw);
					rej_lgl=union(rej_rov.lgl,rej_ref.lgl);

					if ismember(0,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_lgl);
					end
					if ismember(1,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_mw);
					end
					if ismember(2,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_mp1);
					end
					if ismember(3,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_mp2);
					end

					REJ.rej(timetag,rej_lc)=rej_lc;
					rej_uni = union(rej, rej_lc);

					%--- �ُ�l���o���ꂽ�q���ԍ��̊i�[
					%------------------------------------------
					REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
					REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
					REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
					REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;
					REJ.ref.mp1(timetag,rej_ref.mp1)=rej_ref.mp1;
					REJ.ref.mp2(timetag,rej_ref.mp2)=rej_ref.mp2;
					REJ.ref.mw(timetag,rej_ref.mw)=rej_ref.mw;
					REJ.ref.lgl(timetag,rej_ref.lgl)=rej_ref.lgl;
				end

			case 3,
				%--- �ُ�l���o���ꂽ�q���ԍ��̊i�[
				%------------------------------------------
				REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
				REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
				REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
				REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;
				REJ.ref.mp1(timetag,rej_ref.mp1)=rej_ref.mp1;
				REJ.ref.mp2(timetag,rej_ref.mp2)=rej_ref.mp2;
				REJ.ref.mw(timetag,rej_ref.mw)=rej_ref.mw;
				REJ.ref.lgl(timetag,rej_ref.lgl)=rej_ref.lgl;

				%--- �J�C���l�̊i�[
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;						% Multipath ���`����(L1)(rov)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;						% Multipath ���`����(L2)(rov)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;							% Melbourne-Wubbena ���`����(rov)
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;						% �􉽊w�t���[���`����(�����g)(rov)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov_lgp;						% �􉽊w�t���[���`����(�R�[�h)(rov)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov_lg1;						% �􉽊w�t���[���`����(1���g)(rov)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov_lg2;						% �􉽊w�t���[���`����(2���g)(rov)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov_ionp;						% �d���w(lgp����Z�o)(rov)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov_ionl;						% �d���w(lgl����Z�o,N���܂�)(rov)

				CHI2.ref.mp1(timetag,:)  = chi2_ref.mp1;						% Multipath ���`����(L1)(ref)
				CHI2.ref.mp2(timetag,:)  = chi2_ref.mp2;						% Multipath ���`����(L2)(ref)
				CHI2.ref.mw(timetag,:)   = chi2_ref.mw;							% Melbourne-Wubbena ���`����(ref)
				CHI2.ref.lgl(timetag,:)  = chi2_ref.lgl;						% �􉽊w�t���[���`����(�����g)(ref)
% 				CHI2.ref.lgp(timetag,:)  = chi2_ref_lgp;						% �􉽊w�t���[���`����(�R�[�h)(ref)
% 				CHI2.ref.lg1(timetag,:)  = chi2_ref_lg1;						% �􉽊w�t���[���`����(1���g)(ref)
% 				CHI2.ref.lg2(timetag,:)  = chi2_ref_lg2;						% �􉽊w�t���[���`����(2���g)(ref)
% 				CHI2.ref.ionp(timetag,:) = chi2_ref_ionp;						% �d���w(lgp����Z�o)(ref)
% 				CHI2.ref.ionl(timetag,:) = chi2_ref_ionl;						% �d���w(lgl����Z�o,N���܂�)(ref)

				%--- �ُ�l���o�q���̏��O
				%------------------------------------------
				if est_prm.cycle_slip.rej_flag==0

					rej_lgl=union(rej_rov.lgl,rej_ref.lgl);
					rej_mw=union(rej_rov.mw,rej_ref.mw);
					rej_mp1=union(rej_rov.mp1,rej_ref.mp1);
					rej_mp2=union(rej_rov.mp2,rej_ref.mp2);

					if ismember(0,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_lgl);
					end
					if ismember(1,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_mw);
					end
					if ismember(2,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_mp1);
					end
					if ismember(3,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_mp2);
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
					rej_ref_1   = [];
					rej_ref_2   = [];
					rej_ref_sum = [];

					rej_rov_1 = union(rej_rov.lgl,rej_rov.mw);
					rej_rov_2 = union(rej_rov.mp1,rej_rov.mp2);
					rej_rov_sum = union(rej_rov_1,rej_rov_2);							% ���m�Ǒ����o�q��
					rej_ref_1 = union(rej_ref.lgl,rej_ref.mw);
					rej_ref_2 = union(rej_ref.mp1,rej_ref.mp2);
					rej_ref_sum = union(rej_ref_1,rej_ref_2);							% ���m�Ǒ����o�q��

					%--- �C���\�Ȋϑ��ʂ̏C��
					%--------------------------------------
					if ~isnan(rej_rov_sum)
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
								data1(rov_ii,1) = data1(rov_ii,1) + s1_rov(rov_i);
								data1(rov_ii,5) = data1(rov_ii,5) + s2_rov(rov_i);
							end
						end
					end
					if ~isnan(rej_ref_sum)
						[s1_ref, s2_ref,ref_lgl_cs,ref_mw_cs,ref_mp1_cs,ref_mp2_cs] = lc_slip(LC.ref,CHI2.rov,timetag,rej_ref_sum);
						LC.ref.cs1(timetag,rej_ref_sum) = s1_ref(rej_ref_sum);				% ���m�ǃX���b�v����ʊi�[(L1)
						LC.ref.cs2(timetag,rej_ref_sum) = s2_ref(rej_ref_sum);				% ���m�ǃX���b�v����ʊi�[(L2)
						LC.ref.lgl_cs(timetag,rej_ref_sum) = ref_lgl_cs(rej_ref_sum);
						LC.ref.mw_cs(timetag,rej_ref_sum) = ref_mw_cs(rej_ref_sum);
						LC.ref.mp1_cs(timetag,rej_ref_sum) = ref_mp1_cs(rej_ref_sum);
						LC.ref.mp2_cs(timetag,rej_ref_sum) = ref_mp2_cs(rej_ref_sum);
						poss_ref = find(~isnan(s1_ref));
						prn_poss_ref = intersect(rej_ref_sum,poss_ref);
						if ~isempty(poss_ref)
							for ref_i=1:length(poss_ref)
								ref_ii = find(prn.ref.v==prn_poss_ref(ref_i));
								data2(ref_ii,1) = data2(ref_ii,1) + s1_ref(ref_i);
								data2(ref_ii,5) = data2(ref_ii,5) + s2_ref(ref_i);
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

			case 4,
				%--- �J�C���l�̊i�[
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;					% Multipath ���`����(L1)(rov)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;					% Multipath ���`����(L2)(rov)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;						% Melbourne-Wubbena ���`����(rov)
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;					% �􉽊w�t���[���`����(�����g)(rov)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov.lgp;					% �􉽊w�t���[���`����(�R�[�h)(rov)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov.lg1;					% �􉽊w�t���[���`����(1���g)(rov)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov.lg2;					% �􉽊w�t���[���`����(2���g)(rov)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov.ionp;					% �d���w(lgp����Z�o)(rov)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov.ionl;					% �d���w(lgl����Z�o,N���܂�)(rov)

				CHI2.ref.mp1(timetag,:)  = chi2_ref.mp1;					% Multipath ���`����(L1)(ref)
				CHI2.ref.mp2(timetag,:)  = chi2_ref.mp2;					% Multipath ���`����(L2)(ref)
				CHI2.ref.mw(timetag,:)   = chi2_ref.mw;						% Melbourne-Wubbena ���`����(ref)
				CHI2.ref.lgl(timetag,:)  = chi2_ref.lgl;					% �􉽊w�t���[���`����(�����g)(ref)
% 				CHI2.ref.lgp(timetag,:)  = chi2_ref.lgp;					% �􉽊w�t���[���`����(�R�[�h)(ref)
% 				CHI2.ref.lg1(timetag,:)  = chi2_ref.lg1;					% �􉽊w�t���[���`����(1���g)(ref)
% 				CHI2.ref.lg2(timetag,:)  = chi2_ref.lg2;					% �􉽊w�t���[���`����(2���g)(ref)
% 				CHI2.ref.ionp(timetag,:) = chi2_ref.ionp;					% �d���w(lgp����Z�o)(ref)
% 				CHI2.ref.ionl(timetag,:) = chi2_ref.ionl;					% �d���w(lgl����Z�o,N���܂�)(ref)

				%--- �ُ�l���o���ꂽ�q���ԍ��̊i�[
				%------------------------------------------
				REJ.rov.mp1(timetag,:)=rej_rov.mp1;
				REJ.rov.mp2(timetag,:)=rej_rov.mp2;
				REJ.rov.mw(timetag,:)=rej_rov.mw;
				REJ.rov.lgl(timetag,:)=rej_rov.lgl;

				REJ.ref.mp1(timetag,:)=rej_ref.mp1;
				REJ.ref.mp2(timetag,:)=rej_ref.mp2;
				REJ.ref.mw(timetag,:)=rej_ref.mw;
				REJ.ref.lgl(timetag,:)=rej_ref.lgl;

				%--- �ُ�l���o�q���̏��O
				%------------------------------------------
				rej_lgl=union(rej_rov.lgl,rej_ref.lgl);
				rej_mw=union(rej_rov.mw,rej_ref.mw);
				rej_mp1=union(rej_rov.mp1,rej_ref.mp1);
				rej_mp2=union(rej_rov.mp2,rej_ref.mp2);

				if ismember(0,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_lgl);
				end
				if ismember(1,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_mw);
				end
				if ismember(2,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_mp1);
				end
				if ismember(3,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_mp2);
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

				LC_r.ref.mp1(timetag-1,rej_lc(rej_i))=NaN; LC_r.ref.mp2(timetag-1,rej_lc(rej_i))=NaN;			% MP1, MP2
				LC_r.ref.mw(timetag-1,rej_lc(rej_i))=NaN;														% MW
				LC_r.ref.lgl(timetag-1,rej_lc(rej_i))=NaN; LC_r.ref.lgp(timetag-1,rej_lc(rej_i))=NaN;			% LGL, LGP
				LC_r.ref.lg1(timetag-1,rej_lc(rej_i))=NaN; LC_r.ref.lg2(timetag-1,rej_lc(rej_i))=NaN;			% LG1, LG2
				LC_r.ref.ionp(timetag-1,rej_lc(rej_i))=NaN; LC_r.ref.ionl(timetag-1,rej_lc(rej_i))=NaN;			% IONP, IONL
			end
		end

		%------------------------------------------------------------------------------------------------------
		%----- ���Α���(�J���}���t�B���^)
		%------------------------------------------------------------------------------------------------------

		%--- ���ʉq���̒��o
		%--------------------------------------------
		[prn.c,a,b]=intersect(prn.rov.v,prn.ref.v);													% ���ʉq��
		data1=data1(a,:);																			% �ϑ��f�[�^(���ʉq��, rov)
		data2=data2(b,:);																			% �ϑ��f�[�^(���ʉq��, ref)
		no_sat=length(prn.c);																		% �q����(���ʉq��)

		%--- �J���}���t�B���^�̐ݒ�(1/2)
		% �������߂͊�q�������ɍs��
		%--------------------------------------------
		if timetag == 1 | isnan(Kalx_f(1)) % | timetag-timetag_o > 5								% 1�G�|�b�N��
			Kalx_p=[x1(1:3); repmat(0,nx.u-3,1)];													% �����l
		else																						% 2�G�|�b�N�ȍ~
			%--- ��ԑJ�ڍs��E�V�X�e���G���s�񐶐�
			%--------------------------------------------
			[F,Q]=FQ_state_all6(nxo,round((time1.mjd-time_o.mjd)*86400),est_prm,6);

			%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
			%--------------------------------------------
			Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),est_prm.refpos);

			%--- �J���}���t�B���^(���ԍX�V)
			%--------------------------------------------
			[Kalx_p, KalP_p] = filtekf_pre(Kalx_f,KalP_f,F,Q);

			%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
			%--------------------------------------------
			Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),est_prm.refpos);
		end

		if est_prm.statemodel.pos==4, Kalx_p(1:3)=x1(1:3);, end										% SPP�̉��Œu��

		%--- �ϑ��X�V�̌v�Z(�����\)
		%--------------------------------------------
		if ~isnan(x1(1)) & length(prn.c)>3
			for nn=1:est_prm.iteration

				%--- ������
				%--------------------------------------------
				sat_xyz1=[];  sat_xyz_dot1=[];  dtsv1=[];  ion1=[];  trop1=[];
				sat_xyz2=[];  sat_xyz_dot2=[];  dtsv2=[];  ion2=[];  trop2=[];
				azi1=[];  ele1=[];  rho1=[];  ee1=[];  tgd1=[];  tzd1=[];  tzw1=[];
				azi2=[];  ele2=[];  rho2=[];  ee2=[];  tgd2=[];  tzd2=[];  tzw2=[];

				%--- �􉽊w�I����, �p, ���ʊp, �d���w, �Η����̌v�Z
				%--------------------------------------------
				for k = 1:length(prn.c)
					% �􉽊w�I����(������/������)
					%--------------------------------------------
					[rho1(k,1),sat_xyz1(k,:),sat_xyz_dot1(k,:),dtsv1(k,:)]=...
							geodist_mix(time1,eph_prm,ephi1,prn.c(k),Kalx_p,dtr1,est_prm);
					[rho2(k,1),sat_xyz2(k,:),sat_xyz_dot2(k,:),dtsv2(k,:)]=...
							geodist_mix(time2,eph_prm,ephi2,prn.c(k),est_prm.refpos,dtr2,est_prm);
					tgd1(k,:)=eph_prm.brd.data(33,ephi1(prn.c(k)));									% TGD(���Α��ʂł͕s�v)
					tgd2(k,:)=eph_prm.brd.data(33,ephi2(prn.c(k)));									% TGD(���Α��ʂł͕s�v)

					%--- �p, ���ʊp, �Δ����W���̌v�Z
					%--------------------------------------------
					[ele1(k,1),azi1(k,1),ee1(k,:)]=azel(Kalx_p,sat_xyz1(k,:));
					[ele2(k,1),azi2(k,1),ee2(k,:)]=azel(est_prm.refpos,sat_xyz2(k,:));

					%--- �d���w�x�� & �Η����x��
					%--------------------------------------------
					ion1(k,1)=...
							cal_ion2(time1,ion_prm,azi1(k),ele1(k),Kalx_p(1:3),est_prm.i_mode);		% ionospheric model
					ion2(k,1)=...
							cal_ion2(time2,ion_prm,azi2(k),ele2(k),est_prm.refpos,est_prm.i_mode);	% ionospheric model
					[trop1(k,1),tzd1,tzw1]=...
							cal_trop(ele1(k),Kalx_p(1:3),sat_xyz1(k,:)',est_prm.t_mode);			% tropospheric model
					[trop2(k,1),tzd2,tzw2]=...
							cal_trop(ele2(k),est_prm.refpos,sat_xyz2(k,:)',est_prm.t_mode);			% tropospheric model
				end

				%--- �Η����x���̃}�b�s���O�֐�
				%--------------------------------------------
				switch est_prm.mapf_trop
				case 1, [Md1,Mw1]=mapf_cosz(ele1);													% cosz(Md,Mw)
						[Md2,Mw2]=mapf_cosz(ele2);													% cosz(Md,Mw)
				case 2, [Md1,Mw1]=mapf_chao(ele1);													% Chao(Md,Mw)
						[Md2,Mw2]=mapf_chao(ele2);													% Chao(Md,Mw)
				case 3, [Md1,Mw1]=mapf_gmf(time1.day,Kalx_p,ele1);									% GMF(Md,Mw)
						[Md2,Mw2]=mapf_gmf(time2.day,est_prm.refpos,ele2);							% GMF(Md,Mw)
				case 4, [Md1,Mw1]=mapf_marini(time1.day,Kalx_p,ele1);								% Marini(Md,Mw)
						[Md2,Mw2]=mapf_marini(time2.day,est_prm.refpos,ele2);						% Marini(Md,Mw)
				end

				%--- �d���w�x���̃}�b�s���O�֐�
				%--------------------------------------------
				Mi1=1./sqrt(1-(6371000.*cos(ele1)/(6371000+450000)).^2);							% mapping function
				Mi2=1./sqrt(1-(6371000.*cos(ele2)/(6371000+450000)).^2);							% mapping function

				%--- Single Difference
				%--------------------------------------------
				Ysdp1 = data1(:,2) - data2(:,2);													% CA
				Ysdp2 = data1(:,6) - data2(:,6);													% PY
				Ysdl1 = data1(:,1) - data2(:,1);													% L1
				Ysdl2 = data1(:,5) - data2(:,5);													% L2

				%--- ���p�\�ȉq���̃C���f�b�N�X
				%--------------------------------------------
				if est_prm.freq==1
					ii=find(~isnan(Ysdp1+Ysdl1+rho1+rho2) & ...
							ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
				else
					ii=find(~isnan(Ysdp1+Ysdp2+Ysdl1+Ysdl2+rho1+rho2) & ...
							ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
				end

				%--- �q������4�����̏ꍇ
				%--------------------------------------------
				if length(ii)<4
					zz=[];
					prn.u=[];
					prn.float=[];
					prn.fix=[];
					prn.ar=[];
					Kalx_f(1:nx.u+nx.T) = NaN; KalP_f(1:nx.u+nx.T,1:nx.u+nx.T) = NaN;
					Fix_X(1:nx.u+nx.T) = NaN; KalP_f_fix(1:nx.u+nx.T,1:nx.u+nx.T) = NaN;
					Fix_N=[];
					break;
				end

				% �q��PRN�̏��Ԃ�����(��q����1�Ԗڂɔz�u)
				%--------------------------------------------
				b=sat_order(prn.c,prn.o,ele1,ii,50);

				%--- SD��DD�ϊ��s��Ƌp���Ƀ\�[�g(������)
				%--------------------------------------------
				prn.u=prn.c(ii(b));																	% �g�p�q��PRN
				TD=[-ones((length(prn.u)-1),1) eye((length(prn.u)-1))];								% �ϊ��s��
				OO=zeros((length(prn.u)-1)); II=eye((length(prn.u)-1));								% �[���s��,�P�ʍs��

				%--- �����ƃC���f�b�N�X�̐ݒ�(�g�p�q��)
				%--------------------------------------------
				ns=length(prn.u);																	% �g�p�q����
				ix.u=1:nx.u; nx.x=nx.u;																% ��M�@�ʒu

				switch est_prm.statemodel.trop														% �Η����x��
				case 0, ix.T=[]; nx.x=nx.x+nx.T;													% ����Ȃ�
				case 1, ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;											% ZWD����
				case 2, ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;											% ZTD����
				end

				switch est_prm.statemodel.ion														% �d���w�x��
				case 0, ix.i=[]; nx.i=0; nx.x=nx.x+nx.i;											% ����Ȃ�
				case 1, ix.i=nx.x+(1:ns-1); nx.i=length(ix.i); nx.x=nx.x+nx.i;						% DDID����
				case 2, ix.i=nx.x+(1:ns); nx.i=length(ix.i); nx.x=nx.x+nx.i;						% SDID����
				case 3, ix.i=nx.x+(1:ns); nx.i=length(ix.i); nx.x=nx.x+nx.i;						% SDZID����
				case 4, ix.i=nx.x+(1:2);  nx.i=length(ix.i); nx.x=nx.x+nx.i;						% ZID����
				case 5, ix.i=nx.x+(1:4);  nx.i=length(ix.i); nx.x=nx.x+nx.i;						% ZID+dZID����
				end

				ix.n=nx.x+(1:est_prm.freq*(ns-1)); nx.n=length(ix.n); nx.x=nx.x+nx.n;				% �����l�o�C�A�X

				%--- �����l�p(DD)
				%--------------------------------------------
				Ndd1=[];Ndd2=[];
				Nsd1=(lam1*Ysdl1-Ysdp1-2*(ion1-ion2)*0)/lam1;										% L1�����l�o�C�A�X(SD)
				Ndd1=TD*Nsd1(ii(b));																% L1�����l�o�C�A�X(DD)
				if est_prm.freq==2
					Nsd2=(lam2*Ysdl2-Ysdp2-2*(f1/f2)^2*(ion1-ion2)*0)/lam2;							% L2�����l�o�C�A�X(SD)
					Ndd2=TD*Nsd2(ii(b));															% L2�����l�o�C�A�X(DD)
				end

				%--- Fix���Ƃ��ė��p�ł������(�ϊ��ς�)
				%--------------------------------------------
				[prn,Ndd1,Ndd2,N_ref,Fixed_N]=selfixed(prn,Ndd1,Ndd2,Fixed_N,est_prm);				% prn.fix:�Œ��, prn.float:�Œ�s��

				%--- �Η����x������p(�����l)
				%--------------------------------------------
				switch est_prm.statemodel.trop
				case 0, trop12p=[];																	% ����Ȃ�
				case 1, trop12p=[tzw1; tzw2];														% ZWD����
				case 2, trop12p=[tzd1+tzw1; tzd2+tzw2];												% ZTD����
				end

				%--- �d���w�x������p(�����l)
				%--------------------------------------------
				switch est_prm.statemodel.ion
				case 0, ion12p=[];																	% ����Ȃ�
				case 1, ion12p=TD*(ion1(ii(b))-ion2(ii(b)));										% DDID����
				case 2, ion12p=(ion1(ii(b))-ion2(ii(b)));											% SDID����
				case 3, ion12p=(ion1(ii(b))./Mi1(ii(b))-ion2(ii(b))./Mi2(ii(b)));					% SDZID����
				case 4, ion12p=[1.0; 1.0];															% ZID����
				case 5, ion12p=[1.0; 0; 1.0; 0];													% ZID+dZID����
				end

				%--- �J���}���t�B���^�̐ݒ�(2/2)�Ǝ�������
				%--------------------------------------------
				if timetag == 1 | isnan(Kalx_f(1)) % | timetag-timetag_o > 5						% 1�G�|�b�N��(�����l�ݒ�)
					Kalx_p=[Kalx_p(1:3); repmat(0,nx.u-3,1)];										% ��M�@�ʒu
					switch est_prm.statemodel.trop
					case {1,2}, Kalx_p=[Kalx_p; trop12p];											% �Η����x��(�e��)
					end
					switch est_prm.statemodel.ion
					case {1,2,3,4,5}, Kalx_p=[Kalx_p; ion12p];										% �d���w�x��(DD or SD)
					end
					if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; Ndd1; Ndd2];, end				% �����l�o�C�A�X(DD)

					KalP_p=[est_prm.P0.std_dev_p,est_prm.P0.std_dev_v,...
							est_prm.P0.std_dev_a,est_prm.P0.std_dev_j];
					KalP_p=blkdiag(diag(KalP_p(ix.u)),eye(nx.T)*est_prm.P0.std_dev_T,...
							eye(nx.i)*est_prm.P0.std_dev_i,eye(nx.n)*est_prm.P0.std_dev_n).^2;		% ���������U�s��
				else																				% 2�G�|�b�N�ڈȍ~(��������)
					%--- �������ߌ�̏�ԕϐ��Ƌ����U
					%--------------------------------------------
					[Kalx_p,KalP_p]=...
							state_adjust_dd5(prn,Kalx_p,KalP_p,nxo,est_prm,ion12p,Ndd1,Ndd2,N_ref);	% ��i�\���l / �����U�s��
				end
				Ndd1=Kalx_p(ix.n(1:ns-1));															% L1�����l�o�C�A�X(DD)
				if est_prm.freq==2
					Ndd2=Kalx_p(ix.n(ns:end));														% L2�����l�o�C�A�X(DD)
				end

				%--- �Η����x������p
				%--------------------------------------------
				switch est_prm.statemodel.trop
				case 0, 
					trop12=trop1(ii(b))-trop2(ii(b)); Mwu=[];										% Troposphere(SD)
					trop12=TD*trop12;																% Troposphere(DD)
				case 1, 
					trop1=Md1.*tzd1+Mw1.*Kalx_p(ix.T(1));											% ZWD����p
					trop2=Md2.*tzd2+Mw2.*Kalx_p(ix.T(2));											% ZWD����p
					trop12=trop1(ii(b))-trop2(ii(b));												% Troposphere(SD)
					Mwu=[TD*Mw1(ii(b)) -TD*Mw2(ii(b))];												% �}�b�s���O�֐�(�s��)
					trop12=TD*trop12;																% Troposphere(DD)
				case 2, 
					trop1=Md1.*tzd1+Mw1.*(Kalx_p(ix.T(1))-tzd1);									% ZTD����p
					trop2=Md2.*tzd2+Mw2.*(Kalx_p(ix.T(2))-tzd2);									% ZTD����p
					trop12=trop1(ii(b))-trop2(ii(b));												% Troposphere(SD)
					Mwu=[TD*Mw1(ii(b)) -TD*Mw2(ii(b))];												% �}�b�s���O�֐�(�s��)
					trop12=TD*trop12;																% Troposphere(DD)
				end

				%--- �d���w�x������p
				%--------------------------------------------
				switch est_prm.statemodel.ion
				case 0, 
					ion12=ion1(ii(b))-ion2(ii(b));													% Ionosphere(SD,model)
					MI=TD;																			% �W���s��
					ion12=MI*ion12;																	% Ionosphere(DD)
				case 1, 
					ion12=Kalx_p(ix.i);																% Ionosphere(DD,estimate)
					MI=II;
				case 2, 
					ion12=Kalx_p(ix.i);																% Ionosphere(SD,estimate)
					MI=TD;																			% �W���s��
					ion12=MI*ion12;																	% Ionosphere(DD)
				case 3, 
					ion12=Kalx_p(ix.i);																% Ionosphere(SD,estimate)
% 					Miu=(Mi1(ii(b))+Mi2(ii(b)))/2;
					Miu=Mi1(ii(b));
					MI=[-Miu(1)*ones(length(Miu)-1,1) diag(Miu(2:end))];							% �W���s��
					ion12=MI*ion12;																	% Ionosphere(DD)
				case 4, 
					ion1=Mi1.*Kalx_p(ix.i(1));														% ZID����p
					ion2=Mi2.*Kalx_p(ix.i(2));														% ZID����p
					ion12=ion1(ii(b))-ion2(ii(b));													% Ionosphere(SD)
					MI=[TD*Mi1(ii(b)) -TD*Mi2(ii(b))];												% �}�b�s���O�֐�(�s��)
					ion12=TD*ion12;																	% Ionosphere(DD)
				case 5, 
					ion1=Mi1.*Kalx_p(ix.i(1));														% ZID����p
					ion2=Mi2.*Kalx_p(ix.i(3));														% ZID����p
					ion12=ion1(ii(b))-ion2(ii(b));													% Ionosphere(SD)
					MI=[TD*Mi1(ii(b)) repmat(0,ns-1,1) -TD*Mi2(ii(b)) repmat(0,ns-1,1)];			% �}�b�s���O�֐�(�s��)
					ion12=TD*ion12;																	% Ionosphere(DD)
				end

				%--- DD�ϑ����f��(Y,H,h)
				%--------------------------------------------
				if est_prm.freq==1																	% 1���g(L1, CA)
					%--- DD�ϑ����f��(L1)
					%--------------------------------------------
					Y=TD*lam1*Ysdl1(ii(b));															% DD obs(L1)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu -MI lam1*II];										% DD obs matrix(L1)
					else
						H=[TD*ee1(ii(b),:) Mwu     lam1*II];										% DD obs matrix(L1)
					end
					h=TD*(rho1(ii(b))-rho2(ii(b)))+trop12-ion12+lam1*Ndd1;							% DD obs model(L1)

					%--- DD�ϑ����f��(L1,CA)
					%--------------------------------------------
					if est_prm.pr_flag==1															% �[�����������p
						Y=[Y; TD*Ysdp1(ii(b))];														% DD obs(L1, CA)
						if est_prm.statemodel.ion~=0
							H=[H; TD*ee1(ii(b),:) Mwu  MI  OO];										% DD obs matrix(L1,CA)
						else
							H=[H; TD*ee1(ii(b),:) Mwu      OO];										% DD obs matrix(L1,CA)
						end
						h=[h; TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12];							% DD obs model(L1,CA)
					end
				else																				% 2���g(L1, L2, CA, PY)
					%--- DD�ϑ����f��(L1,L2)
					%--------------------------------------------
					Y=[TD*lam1*Ysdl1(ii(b)); TD*lam2*Ysdl2(ii(b))];									% DD obs(L1, L2)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu           -MI lam1*II      OO;						% DD obs matrix(L1)
						   TD*ee1(ii(b),:) Mwu -(f1/f2)^2*MI      OO lam2*II];						% DD obs matrix(L2)
					else
						H=[TD*ee1(ii(b),:) Mwu lam1*II      OO;										% DD obs matrix(L1)
						   TD*ee1(ii(b),:) Mwu      OO lam2*II];									% DD obs matrix(L2)
					end
					h=[TD*(rho1(ii(b))-rho2(ii(b)))+trop12-ion12+lam1*Ndd1;							% DD obs model(L1)
					   TD*(rho1(ii(b))-rho2(ii(b)))+trop12-(f1/f2)^2*ion12+lam2*Ndd2];				% DD obs model(L2)

					%--- DD�ϑ����f��(L1,L2,CA,PY)
					%--------------------------------------------
					if est_prm.pr_flag==1															% �[�����������p
						Y=[Y; TD*Ysdp1(ii(b)); TD*Ysdp2(ii(b))];									% DD obs(L1, L2, CA, PY)
						if est_prm.statemodel.ion~=0
							H=[H;																	% DD obs matrix(L1,L2)
							   TD*ee1(ii(b),:) Mwu            MI      OO      OO;					% DD obs matrix(CA)
							   TD*ee1(ii(b),:) Mwu  (f1/f2)^2*MI      OO      OO];					% DD obs matrix(PY)
						else
							H=[H;																	% DD obs matrix(L1,L2)
							   TD*ee1(ii(b),:) Mwu      OO      OO;									% DD obs matrix(CA)
							   TD*ee1(ii(b),:) Mwu      OO      OO];								% DD obs matrix(PY)
						end
						h=[h;																		% DD obs model(L1,L2)
						   TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12;								% DD obs model(CA)
						   TD*(rho1(ii(b))-rho2(ii(b)))+trop12+(f1/f2)^2*ion12];					% DD obs model(PY)
					end
				end
				H=[H(:,1:3) repmat(0,size(H,1),nx.u-3) H(:,4:end)];									% �L�l�}�e�B�b�N�̂���

				%--- �Δ�����Local(ENU)�p�ɕϊ�(�L�l�}�e�B�b�N�p)
				%--------------------------------------------
				H(:,1:3)=(LL*H(:,1:3)')';

				%--- �ϑ��G������
				%--------------------------------------------
				if est_prm.ww == 0
					PR1a=repmat(est_prm.obsnoise.PR1,length(prn.u),1);								% �R�[�h�̕��U
					PR2a=repmat(est_prm.obsnoise.PR2,length(prn.u),1);								% �R�[�h�̕��U
					PR1b=repmat(est_prm.obsnoise.PR1,length(prn.u),1);								% �R�[�h�̕��U
					PR2b=repmat(est_prm.obsnoise.PR2,length(prn.u),1);								% �R�[�h�̕��U
					Ph1a=repmat(est_prm.obsnoise.Ph1,length(prn.u),1);								% �����g�̕��U
					Ph2a=repmat(est_prm.obsnoise.Ph2,length(prn.u),1);								% �����g�̕��U
					Ph1b=repmat(est_prm.obsnoise.Ph1,length(prn.u),1);								% �����g�̕��U
					Ph2b=repmat(est_prm.obsnoise.Ph2,length(prn.u),1);								% �����g�̕��U
				else
					PR1a=(est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					PR2a=(est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					PR1b=(est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					PR2b=(est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					Ph1a=(est_prm.obsnoise.Ph1./sin(ele1(ii(b))).^2);								% �����g�̕��U(�d�ݍl��)
					Ph2a=(est_prm.obsnoise.Ph2./sin(ele1(ii(b))).^2);								% �����g�̕��U(�d�ݍl��)
					Ph1b=(est_prm.obsnoise.Ph1./sin(ele2(ii(b))).^2);								% �����g�̕��U(�d�ݍl��)
					Ph2b=(est_prm.obsnoise.Ph2./sin(ele2(ii(b))).^2);								% �����g�̕��U(�d�ݍl��)
% 					PR1a=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					PR2a=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					PR1b=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					PR2b=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					Ph1a=(est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele1(ii(b))).^2);			% �����g�̕��U(�d�ݍl��)
% 					Ph2a=(est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele1(ii(b))).^2);			% �����g�̕��U(�d�ݍl��)
% 					Ph1b=(est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele2(ii(b))).^2);			% �����g�̕��U(�d�ݍl��)
% 					Ph2b=(est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele2(ii(b))).^2);			% �����g�̕��U(�d�ݍl��)
				end
				PR1 = diag(PR1a+PR1b); PR2 = diag(PR2a+PR2b);										% �R�[�h�̕��U(1�d��)
				Ph1 = diag(Ph1a+Ph1b); Ph2 = diag(Ph2a+Ph2b);										% �����g�̕��U(1�d��)
				if est_prm.freq==1
					R=TD*Ph1*TD';																	% DD obs noise(L1)
					if est_prm.pr_flag==1
						R=blkdiag(R,TD*PR1*TD');													% DD obs noise(L1,CA)
					end
				else
					R=blkdiag(TD*Ph1*TD',TD*Ph2*TD');												% DD obs noise(L1,L2)
					if est_prm.pr_flag==1
						R=blkdiag(R,TD*PR1*TD',TD*PR2*TD');											% DD obs noise(L1,L2,CA,PY)
					end
				end

				%--- �C�m�x�[�V����
				%--------------------------------------------
				zz = Y - h;

				% ���O�c���̌���(��2����)
				%--------------------------------------------
				[zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=...
						chi2test_dd(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,0.000001);

				%--- �ϑ��X�V�̏���(Float�Ŏ戵�����̂���)
				%--------------------------------------------
				if est_prm.ambf==1
					if length(prn.float)>1															% Float�������߂�K�v������ꍇ
						ind=[]; for i=prn.float(2:end), ind=[ind,find(prn.u(2:end)==i)];, end		% �����l�o�C�A�X�̕���(prn.float)
						if est_prm.freq==1
							indkk=[ix.u,ix.T,ix.i,ix.n(ind)];										% ���肷�镔���̃C���f�b�N�X(���G�|�b�N)
						else
							indkk=[ix.u,ix.T,ix.i,ix.n([ind,length(prn.u)-1+ind])];					% ���肷�镔���̃C���f�b�N�X(���G�|�b�N)
						end
						H=H(:,indkk);																% �C���f�b�N�X�Œ��o
						Kalx_p=Kalx_p(indkk);														% �C���f�b�N�X�Œ��o
						KalP_p=KalP_p(indkk,indkk);													% �C���f�b�N�X�Œ��o
					else																			% Float�������߂�K�v���Ȃ��ꍇ(�S��Fix��)
						H=H(:,[ix.u,ix.T,ix.i]);													% �C���f�b�N�X�Œ��o
						Kalx_p=Kalx_p([ix.u,ix.T,ix.i]);											% �C���f�b�N�X�Œ��o
						KalP_p=KalP_p([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i]);							% �C���f�b�N�X�Œ��o
					end
				end

				%--- �����l�o�C�A�X(Fix)���S�������Ƃ��ė��p
				%--------------------------------------------
				if est_prm.ambf==2
					if est_prm.freq==1
						iref=find(prn.o==prn.u(1));													% ��q���̕ω��̃`�F�b�N
						Nc1=Fixed_N{1}(prn.u(2:end),1);												% �S�������ŗ��p�\�Ȑ����l�o�C�A�X(L1)
						CC1=eye(nx.n/2);															% �ϑ��s��ŗ��p����P�ʍs��
						if ~isempty(find(~isnan(Nc1))) & iref==1									% �S�����������p�ł��邩�ǂ����̔���
							Nc1=Nc1-Kalx_p(ix.n(1:nx.n/2));											% �c��
							ic1=find(isnan(Nc1));													% NaN�����O���邽�߂̃C���f�b�N�X
							if ~isempty(ic1), Nc1(ic1)=[]; CC1(ic1,:)=[];, end						% NaN�̕��������O
							zz=[zz;Nc1];															% �S��������ǉ�
							H=[H; zeros(length(Nc1),nx.u+nx.T+nx.i) CC1];							% �S��������ǉ�
							RN=2*(ones(length(Nc1))+eye(length(Nc1)))*1e-4;							% �S�����������̊ϑ��G��
							R=blkdiag(R,RN);														% �S��������ǉ�
						end
					else
						iref=find(prn.o==prn.u(1));													% ��q���̕ω��̃`�F�b�N
						Nc1=Fixed_N{1}(prn.u(2:end),1); Nc2=Fixed_N{2}(prn.u(2:end),1);				% �S�������ŗ��p�\�Ȑ����l�o�C�A�X(L1)
						CC1=eye(nx.n/2); CC2=eye(nx.n/2);											% �ϑ��s��ŗ��p����P�ʍs��
						if ~isempty(find(~isnan(Nc1))) & ~isempty(find(~isnan(Nc2))) & iref==1		% �S�����������p�ł��邩�ǂ����̔���
							Nc1=Nc1-Kalx_p(ix.n(1:nx.n/2)); Nc2=Nc2-Kalx_p(ix.n(nx.n/2+1:end));		% �c��
							ic1=find(isnan(Nc1));													% NaN�����O���邽�߂̃C���f�b�N�X
							if ~isempty(ic1), Nc1(ic1)=[]; CC1(ic1,:)=[];, end						% NaN�̕��������O
							ic2=find(isnan(Nc2));													% NaN�����O���邽�߂̃C���f�b�N�X
							if ~isempty(ic2), Nc2(ic2)=[]; CC2(ic2,:)=[];, end						% NaN�̕��������O
							zz=[zz;Nc1;Nc2];														% �S��������ǉ�
							H=[H; zeros(length(Nc1)+length(Nc2),nx.u+nx.T+nx.i) blkdiag(CC1,CC2)];	% �S��������ǉ�
							RN=2*(ones(length(Nc1)+length(Nc2))+eye(length(Nc1)+length(Nc2)))*1e-4;	% �S�����������̊ϑ��G��
							R=blkdiag(R,RN);														% �S��������ǉ�
						end
					end
				end

				%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
				%--------------------------------------------
				Kalx_p(1:3)=xyz2enu(Kalx_p(1:3),est_prm.refpos);

				%--- �J���}���t�B���^(�ϑ��X�V)
				%--------------------------------------------
				[Kalx_f, KalP_f,V] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);
% 				[Kalx_f, KalP_f] = filtsrcf_upd(zz, H, R, Kalx_p, KalP_p);

				%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),est_prm.refpos);

				%--- Float���̎���
				%--------------------------------------------
				% �d���w�x���Ɛ����l�o�C�A�X�ɂ��Ă�, ���ԍX�V�̂��߂ɗ��p����K�v�����邩��
				nxo.u=nx.u;
				nxo.T=nx.T;
				nxo.i=nx.i;
				nxo.n=est_prm.freq*(length(prn.float)-1);
				nxo.x=nxo.u+nxo.T+nxo.i+nxo.n;

				prn.o=prn.u;					% �ϑ��X�V�̂��߂ɕK�v
				prn.float_o=prn.float;			% �ϑ��X�V�̂��߂ɕK�v
			end

			%--- ECEF(WGS84)����Local�ɕϊ�
			%--------------------------------------------
			Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),est_prm.refpos);

			%--- Ambiguity Resolution & Validation
			%--------------------------------------------
			[prn,Fix_X,Fix_N,Fixed_N,s,KalP_f_fix,ratio]=...
					ambfix3(prn,ele1,ele2,Kalx_p,Kalx_f,KalP_f,Fixed_N,ix,nx,est_prm,H,ratio_l);

			%--- Local����ECEF(WGS84)�ɕϊ�
			%--------------------------------------------
			Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),est_prm.refpos);
			Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),est_prm.refpos);
			Fix_X(1:3)=enu2xyz(Fix_X(1:3),est_prm.refpos);

			Kalx_p=Kalx_f;  KalP_p=KalP_f; ratio_l=ratio;

		else
			zz=[];
			prn.u=[];
			prn.float=[];
			prn.fix=[];
			prn.ar=[];
			Kalx_f(1:nx.u+nx.T) = NaN; KalP_f(1:nx.u+nx.T,1:nx.u+nx.T) = NaN;
			Fix_X(1:nx.u+nx.T) = NaN; KalP_f_fix(1:nx.u+nx.T,1:nx.u+nx.T) = NaN;
			Fix_N=[];
		end

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos3 = xyz2enu(Kalx_f(1:3),est_prm.rovpos)';											% ENU�ɕϊ�(float)
		est_pos4 = xyz2enu(Fix_X(1:3),est_prm.rovpos)';												% ENU�ɕϊ�(fix)

		%--- ���ʊi�[(Float��)
		%--------------------------------------------
		Result.float.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% ����
		Res.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];						% ����
		if ~isempty(zz)
			%--- �c��
			%--------------------------------------------
			if est_prm.freq==1
				Res.pre{1,prn.u(1)}(timetag,prn.u(2:end))=zz(1:(length(prn.u)-1),1)';				% L1(pre-fit)
				Res.post{1,prn.u(1)}(timetag,prn.u(2:end))=V(1:(length(prn.u)-1),1)';				% L1(post-fit)
				if est_prm.pr_flag==1
					Res.pre{3,prn.u(1)}(timetag,prn.u(2:end))=...
							zz(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';							% CA(pre-fit)
					Res.post{3,prn.u(1)}(timetag,prn.u(2:end))=...
							V(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';							% CA(post-fit)
				end
			elseif est_prm.freq==2
				Res.pre{1,prn.u(1)}(timetag,prn.u(2:end))=zz(1:(length(prn.u)-1),1)';				% L1(pre-fit)
				Res.post{1,prn.u(1)}(timetag,prn.u(2:end))=V(1:(length(prn.u)-1),1)';				% L1(post-fit)
				Res.pre{2,prn.u(1)}(timetag,prn.u(2:end))=...
						zz(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';								% L2(pre-fit)
				Res.post{2,prn.u(1)}(timetag,prn.u(2:end))=...
						V(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';								% L2(post-fit)
				if est_prm.pr_flag==1
					Res.pre{3,prn.u(1)}(timetag,prn.u(2:end))=...
							zz(1+2*(length(prn.u)-1):3*(length(prn.u)-1),1)';						% CA(pre-fit)
					Res.post{3,prn.u(1)}(timetag,prn.u(2:end))=...
							V(1+2*(length(prn.u)-1):3*(length(prn.u)-1),1)';						% CA(post-fit)
					Res.pre{4,prn.u(1)}(timetag,prn.u(2:end))=...
							zz(1+3*(length(prn.u)-1):4*(length(prn.u)-1),1)';						% PY(pre-fit)
					Res.post{4,prn.u(1)}(timetag,prn.u(2:end))=...
							V(1+3*(length(prn.u)-1):4*(length(prn.u)-1),1)';						% PY(post-fit)
				end
			end

			%--- ���ʊi�[(Float��)
			%--------------------------------------------
			Result.float.pos(timetag,:)=[Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1]];	% �ʒu
			switch est_prm.statemodel.ion
			case 1,
				Result.float.dion(timetag,prn.u(2:end))=Kalx_f(ix.i);								% �d���w�x��
			case {2,3}
				Result.float.dion(timetag,prn.u)=Kalx_f(ix.i);										% �d���w�x��
			case 4
				Result.float.dion(timetag,1:2)=Kalx_f(ix.i);										% �d���w�x��
			case 5
				Result.float.dion(timetag,1:4)=Kalx_f(ix.i);										% �d���w�x��
			end
			if est_prm.statemodel.trop~=0
				Result.float.dtrop(timetag,:)=Kalx_f(ix.T);											% �Η����x��
			end
			if length(prn.float)>1
				Float_N=Kalx_f(nx.u+nx.T+nx.i+1:end);												% Float��
				Result.float.amb{1,prn.u(1)}(timetag,prn.float(2:end))=...
						Float_N(1:length(Float_N)/est_prm.freq);									% �����l�o�C�A�X(L1)
				if est_prm.freq==2
					Result.float.amb{2,prn.u(1)}(timetag,prn.float(2:end))=...
							Float_N(1+length(Float_N)/est_prm.freq:end);							% �����l�o�C�A�X(L2)
				end
			end
			Result.float.ps(timetag,1:3)=diag(KalP_f(1:3,1:3));										% �ʒu
		end

		%--- ���ʊi�[(Fix��)
		%--------------------------------------------
		Result.fix.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% ����
		Result.fix.ratio(timetag,1)=ratio;															% �ޓx��
		if ~isempty(zz)
			if ~isnan(Fix_X(1))
				Result.fix.pos(timetag,:)=[Fix_X(1:3)', xyz2llh(Fix_X(1:3)).*[180/pi 180/pi 1]];	% �ʒu
				switch est_prm.statemodel.ion
				case 1,
					Result.fix.dion(timetag,prn.u(2:end))=Fix_X(ix.i);								% �d���w�x��
				case {2,3}
					Result.fix.dion(timetag,prn.u)=Fix_X(ix.i);										% �d���w�x��
				case 4
					Result.fix.dion(timetag,1:2)=Fix_X(ix.i);										% �d���w�x��
				case 5
					Result.fix.dion(timetag,1:4)=Fix_X(ix.i);										% �d���w�x��
				end
				if est_prm.statemodel.trop~=0
					Result.fix.dtrop(timetag,:)=Fix_X(ix.T);										% �Η����x��
				end
				Result.fix.amb{1,prn.u(1)}(timetag,:)=Fixed_N{1}(:,1)';								% �����l�o�C�A�X(L1)
				if est_prm.freq==2
					Result.fix.amb{2,prn.u(1)}(timetag,:)=Fixed_N{2}(:,1)';							% �����l�o�C�A�X(L2)
				end
			end
			Result.fix.ps(timetag,1:3)=diag(KalP_f_fix(1:3,1:3));									% �ʒu
		end

		%------------------------------------------------------------------------------------------------------
		%----- ���Α���(�J���}���t�B���^) ---->> �I��
		%------------------------------------------------------------------------------------------------------

		%--- �q���ω��`�F�b�N
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.u);							% �q���ω��̃`�F�b�N
% 		end

		%--- ��ʕ\��
		%--------------------------------------------
		if isnan(est_pos4(1))==1
			if isnan(est_pos3(1))==1
				fprintf('%10.4f %10.4f %10.4f    %1d %6.1f  %3d %3d   PRN:',...
						NaN,NaN,NaN,0,NaN,length(prn.u),length(prn.ar));
			else
				fprintf('%10.4f %10.4f %10.4f    %1d %6.1f  %3d %3d   PRN:',...
						est_pos3(1:3),2,s(2)/s(1),length(prn.u),length(prn.ar));
			end
		else
			fprintf('%10.4f %10.4f %10.4f    %1d %6.1f  %3d %3d   PRN:',...
					est_pos4(1:3),1,s(2)/s(1),length(prn.u),length(prn.ar));
		end
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		if ~isempty(rej), fprintf(' , AHO');, end
		fprintf('\n')

		%--- �q���i�[
		%--------------------------------------------
		Result.float.prn{3}(timetag,1:4)=[time1.tod,length(prn.c),length(prn.u),dop1];
		Result.float.prn{1}(timetag,prn.c)=prn.c;
		if ~isempty(prn.u)
			Result.float.prn{2}(timetag,prn.u)=prn.u;
			Result.float.prn{4}(timetag,prn.u(1))=prn.u(1);
		end

		Result.fix.prn{3}(timetag,1:4)=[time1.tod,length(prn.c),length(prn.u),dop1];
		Result.fix.prn{1}(timetag,prn.c)=prn.c;
		if ~isempty(prn.u)
			Result.fix.prn{2}(timetag,prn.u)=prn.u;
			Result.fix.prn{4}(timetag,prn.u(1))=prn.u(1);
		end

		%--- ���ʏ����o��
		%--------------------------------------------
		fprintf(f_sol1,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',...
				timetag,time1.week,time1.tow,time1.tod,Kalx_f(1:3),est_pos3);
		fprintf(f_sol2,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',...
				timetag,time1.week,time1.tow,time1.tod,Fix_X(1:3),est_pos4);

		prn.o = prn.u;
		prn.float_o = prn.float;
		time_o=time1;
		timetag_o=timetag;
	end
	%--- end ����
	%--------------------------------------------
	if  feof(fpo1) | feof(fpo2), break;, end
end
fclose('all');
toc
%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z ---->> �I��
%-----------------------------------------------------------------------------------------

%--- MAT�ɕۑ�
%--------------------------------------------
matname=sprintf('Relative_%s_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','Res','OBS','LC');

%--- ���ʌ��ʃv���b�g
%--------------------------------------------
plot_data([est_prm.dirs.result,matname]);

% %--- KML�o��
% %--------------------------------------------
% kmlname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
%kmlname2=sprintf('Float_%s_%s_%4d%02d%02d_%02d-%02d.kml',...
 		%est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% kmlname3=sprintf('Fix_%s_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp);
fn_kml = 'result.kml';
point_color = 'G';                                                          %�}�[�J�̐F�w��'Y','M','C','R','G','B','W','K'
track_color = 'G';                                                          %��芸�����w�肷��i������Ȃ���OK�j
data.time = Result.float.time(:,1:6);                      %Y M D H M S lat lon alt
data.pos =  Result.float.pos(:,4:6);
output_kml(fn_kml,data,track_color,point_color);
% output_kml([est_prm.dirs.result,kmlname3],Result.fix);
% 
% %--- NMEA�o��
% %--------------------------------------------
% nmeaname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname2=sprintf('Float_%s_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname3=sprintf('Fix_%s_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname1],Result.spp);
% output_nmea([est_prm.dirs.result,nmeaname2],Result.float);
% output_nmea([est_prm.dirs.result,nmeaname3],Result.fix);
% 
% %--- INS�p
% %--------------------------------------------
% insname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% insname2=sprintf('Float_%s_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% insname3=sprintf('Fix_%s_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname1],Result.spp,est_prm);
% output_ins([est_prm.dirs.result,insname2],Result.float,est_prm);
% output_ins([est_prm.dirs.result,insname3],Result.fix,est_prm);

fclose('all');
