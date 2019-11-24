%-------------------------------------------------------------------------------%
%                 ���{�E�v�ی��� GPS���ʉ��Z��۸��с@Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS���ʉ��Z�v���O����(DGPS��)
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
%     3. DGPS(�[�������̑��Α���) (�J���}���t�B���^)
%  9. ���ʊi�[
% 10. ���ʃO���t�\��
% 
% 
%-------------------------------------------------------------------------------
% �K�v�ȊO���t�@�C���E�֐�
%-------------------------------------------------------------------------------
% phisic_const.m      : �����ϐ���`
%-------------------------------------------------------------------------------
% FQ_state_all6.m     : ��ԃ��f���̐���
%-------------------------------------------------------------------------------
% prn_check.m         : �q���ω��̌��o
% sat_order.m         : �q��PRN�̏��Ԃ̌���
% select_prn.m        : �g�p�q���̑I��
% state_adjust_dd5.m  : �q���ω����̎�������(DD�p)
%-------------------------------------------------------------------------------
% cal_time2.m         : �w�莞����GPS�T�ԍ��EToW�EToD�̌v�Z
% clkjump_repair2.m   : ��M�@���v�̔�т̌��o/�C��
% mjuliday.m          : MJD�̌v�Z
% weekf.m             : WEEK, TOW �̌v�Z
%-------------------------------------------------------------------------------
% fileget2.m          : �t�@�C���������ƃ_�E�����[�h(wget.exe, gzip.exe)
%-------------------------------------------------------------------------------
% read_eph.m          : �G�t�F�����X�̎擾
% read_ionex2.m       : IONEX�f�[�^�擾
% read_obs_epo_data.m : OBS�G�|�b�N����� & OBS�ϑ��f�[�^�擾
% read_obs_h.m        : OBS�w�b�_�[���
% read_sp3.m          : ������f�[�^�擾
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
% measuremodel.m      : �ϑ����f���쐬(h,H,R) + �􉽊w����
% obs_comb.m          : �e����`�����̌v�Z
% obs_vec.m           : �ϑ��ʃx�N�g���쐬
%-------------------------------------------------------------------------------
% filtekf_pre.m       : �J���}���t�B���^�̎��ԍX�V
% filtekf_upd.m       : �J���}���t�B���^�̊ϑ��X�V
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
% DGPS�ł�, �ϑ��f�[�^�����Ȃ�(�[�������̂�)�̂���, �d���w�E�Η������肪���ʓI�ɋ@�\���Ȃ�.
% ����������, �d���w�E�Η�����������Ȃ���������Ƃ��Ă͐��x���悢.
% 
% <�ۑ�>
% �E�T�C�N���X���b�v, �ُ�l���o(���`����, ���O�c���E����c������)
% �E�f�[�^�X�V�Ԋu�� 1[sec]�ȉ��̏ꍇ�~ �� �ǂݔ�΂�, �����������C��
% 
% �c���`�F�b�N�̂��߂Ɋϑ����f�����֐�������K�v������
% ���O�Ǝ���̊ϑ����f���ŗ��p�����ԕϐ��݈̂قȂ邾��������֐��ŗ��p�ł��������֗�
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov     : ���q��(rov)
%  prn.rovu    : �g�p�q��(rov)
%  prn.ref.v.v     : ���q��(ref)
%  prn.refu    : �g�p�q��(ref)
%  prn.c       : ���ʉ��q��(rov,ref)
%  prn.u       : ���ʎg�p�q��(rov,ref)
%  prn.o       : �O�G�|�b�N�̎g�p�q��(rov,ref)
% 
% ���������̕���������(MJD�݂̂Ŕ�r����悤�ɂ��Ă݂�+0.1�b�܂Ō���悤�ɕύX)
% �� �X�V�Ԋu��1[Hz]�ȏ�ł��ł���悤�ɏC��
% �� ����ɔ���, ���ɂ��C�����Ă��镔������
% 
%-------------------------------------------------------------------------------
% latest update : 2009/02/25 by Fujita
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
fpo1=fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');
fpn1=fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');
fpo2=fopen([est_prm.dirs.obs,est_prm.file.ref_o],'rt');
fpn2=fopen([est_prm.dirs.obs,est_prm.file.ref_n],'rt');

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
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- ������̓Ǎ���
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);
else
	eph_prm.sp3.data=[];
end

%--- �ݒ���̏o��(DGPS�p)
%--------------------------------------------
datname1=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol1  = fopen([est_prm.dirs.result,datname1],'w');							% ���ʏ����o���t�@�C���̃I�[�v��
output_log(f_sol1,time_s,time_e,est_prm,2);

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

%--- DGPS�p
%--------------------------------------------
Result.dgps.time(1:tt,1:10)=NaN; Result.dgps.time(:,1)=1:tt;					% ����
Result.dgps.pos(1:tt,1:6)=NaN;													% �ʒu
Result.dgps.dion(1:tt,1:32)=NaN;												% �d���w�x��
Result.dgps.dtrop(1:tt,1:2)=NaN;												% �Η����x��
for j=1:2, for k=1:32, Result.dgps.amb{j,k}(1:tt,1:32)=NaN;, end, end			% �����l�o�C�A�X
Result.dgps.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.dgps.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.dgps.prn{3}(1:tt,1:3)=NaN;												% �q����
Result.dgps.prn{4}(1:tt,1:32)=NaN;												% �g�p�q��(�)

%--- �c���p
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% ����
for j=1:2, for k=1:32, Res.pre{j,k}(1:tt,1:32)=NaN;, end, end					% �c��(pre-fit)
for j=1:2, for k=1:32, Res.post{j,k}(1:tt,1:32)=NaN;, end, end					% �c��(post-fit)

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
LC.rov.mp1(1:tt,1:32)=NaN; LC.rov.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.rov.mw(1:tt,1:32)=NaN;														% MW
LC.rov.lgl(1:tt,1:32)=NaN; LC.rov.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.rov.lg1(1:tt,1:32)=NaN; LC.rov.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.rov.ionp(1:tt,1:32)=NaN; LC.rov.ionl(1:tt,1:32)=NaN;							% IONP, IONL

LC.ref.time(1:tt,1:10)=NaN; LC.ref.time(:,1)=1:tt;								% ����
LC.ref.mp1(1:tt,1:32)=NaN; LC.ref.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.ref.mw(1:tt,1:32)=NaN;														% MW
LC.ref.lgl(1:tt,1:32)=NaN; LC.ref.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.ref.lg1(1:tt,1:32)=NaN; LC.ref.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.ref.ionp(1:tt,1:32)=NaN; LC.ref.ionl(1:tt,1:32)=NaN;							% IONP, IONL

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
		while time_s.mjd > time1.mjd+0.1/86400														% �� 0.1 �b��ڂ܂ŔF�߂�
			%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
			%--------------------------------------------
			[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
					read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);

			if time_s.mjd <= time1.mjd+0.1/86400, sf=1; break;, end
		end
		while time_s.mjd > time2.mjd+0.1/86400														% �� 0.1 �b��ڂ܂ŔF�߂�
			%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
			%--------------------------------------------
			[time2,no_sat2,prn.ref.v.v,dtrec2,ephi2,data2]=...
					read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);

			if time_s.mjd <= time2.mjd+0.1/86400, sf=1; break;, end
		end
	else
		%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
		%--------------------------------------------
		[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
				read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
		[time2,no_sat2,prn.ref.v.v,dtrec2,ephi2,data2]=...
				read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
	end
	if sf==1
		%--- ��������
		%--------------------------------------------
		while 1
			if abs(time1.mjd-time2.mjd)<=0.1/86400
				break;
			else
				if time1.mjd < time2.mjd
					while time1.mjd < time2.mjd
						%--- �G�|�b�N���擾(����, PRN �Ȃ�)
						%--------------------------------------------
						[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
								read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time1.mjd-0.1/86400, break;, end							% �� 0.1 �b��ڂ܂ŔF�߂�
					end
				elseif time1.mjd > time2.mjd
					while time1.mjd > time2.mjd
						%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
						%--------------------------------------------
						[time2,no_sat2,prn.ref.v.v,dtrec2,ephi2,data2]=...
								read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time2.mjd-0.1/86400, break;, end							% �� 0.1 �b��ڂ܂ŔF�߂�
					end
				end
			end
			if abs(time1.mjd-time2.mjd)<=0.1/86400 | feof(fpo1) | feof(fpo2), break;, end
		end

		%--- end ����
		%--------------------------------------------
		if time_e.mjd <= time1.mjd-0.1/86400 | time_e.mjd <= time2.mjd-0.1/86400, break;, end		% �� 0.1 �b��ڂ܂ŔF�߂�

		%--- �^�C���^�O
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
		else
			timetag = timetag + round((time1.mjd-time_o.mjd)*86400/dt);
		end

		%--- �ǂݎ�蒆�̃G�|�b�N�̎��ԕ\��
		%--------------------------------------------
		fprintf('%7d: %2d:%2d %5.2f"  ',timetag,time1.day(4),time1.day(5),time1.day(6));

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@)
		%------------------------------------------------------------------------------------------------------

		%--- �P�Ƒ���
		%--------------------------------------------
		[x1,dtr1,dtsv1,ion1,trop1,prn.rovu,rho1,dop1,ele1,azi1]=...
				pointpos2(time1,prn.rov.v,app_xyz1,data1,eph_prm,ephi1,est_prm,ion_prm,rej);
		[x2,dtr2,dtsv2,ion2,trop2,prn.refu,rho2,dop2,ele2,azi2]=...
				pointpos2(time2,prn.ref.v.v,app_xyz2,data2,eph_prm,ephi2,est_prm,ion_prm,rej);
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
		OBS.rov.ca(timetag,prn.rov.v)   = data1(:,2);													% CA
		OBS.rov.py(timetag,prn.rov.v)   = data1(:,6);													% PY
		OBS.rov.ph1(timetag,prn.rov.v)  = data1(:,1);													% L1
		OBS.rov.ph2(timetag,prn.rov.v)  = data1(:,5);													% L2
		OBS.rov.ion(timetag,prn.rov.v)  = ion1(:,1);													% Ionosphere
		OBS.rov.trop(timetag,prn.rov.v) = trop1(:,1);													% Troposphere

		OBS.ref.ca(timetag,prn.ref.v.v)   = data2(:,2);													% CA
		OBS.ref.py(timetag,prn.ref.v.v)   = data2(:,6);													% PY
		OBS.ref.ph1(timetag,prn.ref.v.v)  = data2(:,1);													% L1
		OBS.ref.ph2(timetag,prn.ref.v.v)  = data2(:,5);													% L2
		OBS.ref.ion(timetag,prn.ref.v.v)  = ion2(:,1);													% Ionosphere
		OBS.ref.trop(timetag,prn.ref.v.v) = trop2(:,1);													% Troposphere

		OBS.rov.ele(timetag,prn.rov.v) = ele1(:,1);													% elevation
		OBS.rov.azi(timetag,prn.rov.v) = azi1(:,1);													% azimuth
		OBS.ref.ele(timetag,prn.ref.v.v) = ele2(:,1);													% elevation
		OBS.ref.azi(timetag,prn.ref.v.v) = azi2(:,1);													% azimuth

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
		OBS.rov.ca_cor(timetag,prn.rov.v)  = data1(:,2);												% CA
		OBS.rov.py_cor(timetag,prn.rov.v)  = data1(:,6);												% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v) = data1(:,1);												% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v) = data1(:,5);												% L2

		OBS.ref.ca_cor(timetag,prn.ref.v.v)  = data2(:,2);												% CA
		OBS.ref.py_cor(timetag,prn.ref.v.v)  = data2(:,6);												% PY
		OBS.ref.ph1_cor(timetag,prn.ref.v.v) = data2(:,1);												% L1
		OBS.ref.ph2_cor(timetag,prn.ref.v.v) = data2(:,5);												% L2

		%--- �e����`����(�␳�ς݊ϑ��ʂ��g�p)
		%--------------------------------------------
		[mp11,mp21,lgl1,lgp1,lg11,lg21,mw1,ionp1,ionl1] = obs_comb(data1);
		[mp12,mp22,lgl2,lgp2,lg12,lg22,mw2,ionp2,ionl2] = obs_comb(data2);

		%--- �e����`�������i�[
		%--------------------------------------------
		ii=find(ele1*180/pi>est_prm.mask);
		LC.rov.mp1(timetag,prn.rov.v(ii))  = mp11(ii);												% Multipath ���`����(L1)
		LC.rov.mp2(timetag,prn.rov.v(ii))  = mp21(ii);												% Multipath ���`����(L2)
		LC.rov.mw(timetag,prn.rov.v(ii))   = mw1(ii);													% Melbourne-Wubbena ���`����
		LC.rov.lgl(timetag,prn.rov.v(ii))  = lgl1(ii);												% �􉽊w�t���[���`����(�����g)
		LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp1(ii);												% �􉽊w�t���[���`����(�R�[�h)
		LC.rov.lg1(timetag,prn.rov.v(ii))  = lg11(ii);												% �􉽊w�t���[���`����(1���g)
		LC.rov.lg2(timetag,prn.rov.v(ii))  = lg21(ii);												% �􉽊w�t���[���`����(2���g)
		LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp1(ii);												% �d���w(lgp����Z�o)
		LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl1(ii);												% �d���w(lgl����Z�o,N���܂�)

		ii=find(ele2*180/pi>est_prm.mask);
		LC.ref.mp1(timetag,prn.ref.v.v(ii))  = mp12(ii);												% Multipath ���`����(L1)
		LC.ref.mp2(timetag,prn.ref.v.v(ii))  = mp22(ii);												% Multipath ���`����(L2)
		LC.ref.mw(timetag,prn.ref.v.v(ii))   = mw2(ii);													% Melbourne-Wubbena ���`����
		LC.ref.lgl(timetag,prn.ref.v.v(ii))  = lgl2(ii);												% �􉽊w�t���[���`����(�����g)
		LC.ref.lgp(timetag,prn.ref.v.v(ii))  = lgp2(ii);												% �􉽊w�t���[���`����(�R�[�h)
		LC.ref.lg1(timetag,prn.ref.v.v(ii))  = lg12(ii);												% �􉽊w�t���[���`����(1���g)
		LC.ref.lg2(timetag,prn.ref.v.v(ii))  = lg22(ii);												% �􉽊w�t���[���`����(2���g)
		LC.ref.ionp(timetag,prn.ref.v.v(ii)) = ionp2(ii);												% �d���w(lgp����Z�o)
		LC.ref.ionl(timetag,prn.ref.v.v(ii)) = ionl2(ii);												% �d���w(lgl����Z�o,N���܂�)

		%--- ���`�����ɂ��ُ�l����
		%--------------------------------------------
		% �������Ȃ̂őg�ݍ���ŉ�����

		%------------------------------------------------------------------------------------------------------
		%----- ���Α���(�J���}���t�B���^)
		%------------------------------------------------------------------------------------------------------

		%--- ���ʉq���̒��o
		%--------------------------------------------
		[prn.c,a,b]=intersect(prn.rov.v,prn.ref.v.v);														% ���ʉq��
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
			[F,Q]=FQ_state_all6(nxo,round((time1.mjd-time_o.mjd)*86400),est_prm,7);

			%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
			%--------------------------------------------
			Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),est_prm.refpos);

			%--- �J���}���t�B���^(���ԍX�V)
			%--------------------------------------------
			[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);

			%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
			%--------------------------------------------
			Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),est_prm.refpos);
		end

		if est_prm.statemodel.pos==4, Kalx_p(1:3)=x1(1:3);, end

		%--- �ϑ��X�V�̌v�Z(�����\)
		%--------------------------------------------
		if ~isnan(x1(1))
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
					tgd1(k,:)=eph_prm.brd.data(33,ephi1(prn.c(k)));									% TGD
					tgd2(k,:)=eph_prm.brd.data(33,ephi2(prn.c(k)));									% TGD

					%--- �p, ���ʊp, �Δ����W���̌v�Z
					%--------------------------------------------
					[ele1(k,1),azi1(k,1),ee1(k,:)]=azel(Kalx_p, sat_xyz1(k,:));
					[ele2(k,1),azi2(k,1),ee2(k,:)]=azel(est_prm.refpos, sat_xyz2(k,:));

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

				%--- ���p�\�ȉq���̃C���f�b�N�X
				%--------------------------------------------
				if est_prm.freq==1
					ii=find(~isnan(Ysdp1+rho1+rho2) & ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
				else
					ii=find(~isnan(Ysdp1+Ysdp2+rho1+rho2) & ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% ���p�\�ȉq���̃C���f�b�N�X
				end

				%--- �q������4�����̏ꍇ
				%--------------------------------------------
				if length(ii)<4, z=[]; Kalx_f(1:nx.u+nx.T)=NaN; break;, end

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

					KalP_p=[est_prm.P0.std_dev_p,est_prm.P0.std_dev_v,...
							est_prm.P0.std_dev_a,est_prm.P0.std_dev_j];
					KalP_p=blkdiag(diag(KalP_p(1:nx.u)),eye(nx.T)*est_prm.P0.std_dev_T,...
							eye(nx.i)*est_prm.P0.std_dev_i).^2;										% ���������U�s��
				else																				% 2�G�|�b�N�ڈȍ~(��������)
					%--- �������ߌ�̏�ԕϐ��Ƌ����U
					%--------------------------------------------
					[Kalx_p,KalP_p]=...
							state_adjust_dd5(prn,Kalx_p,KalP_p,nxo,est_prm,ion12p,[],[],[]);		% ��i�\���l / �����U�s��
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
				if est_prm.freq==1																	% 1���g(CA)
					%--- DD�ϑ����f��(CA)
					%--------------------------------------------
					Y=[TD*Ysdp1(ii(b))];															% DD obs(CA)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu  MI];												% DD obs matrix(CA)
					else
						H=[TD*ee1(ii(b),:) Mwu];													% DD obs matrix(CA)
					end
					h=[TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12];									% DD obs model(CA)
				else																				% 2���g(CA, PY)
					%--- DD�ϑ����f��(CA,PY)
					%--------------------------------------------
					Y=[TD*Ysdp1(ii(b)); TD*Ysdp2(ii(b))];											% DD obs(CA, PY)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu            MI;										% DD obs matrix(CA)
						   TD*ee1(ii(b),:) Mwu  (f1/f2)^2*MI];										% DD obs matrix(PY)
					else
						H=[TD*ee1(ii(b),:) Mwu;														% DD obs matrix(CA)
						   TD*ee1(ii(b),:) Mwu];													% DD obs matrix(PY)
					end
					h=[TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12;									% DD obs model(CA)
					   TD*(rho1(ii(b))-rho2(ii(b)))+trop12+(f1/f2)^2*ion12];						% DD obs model(PY)
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
				else
					PR1a=(est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					PR2a=(est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					PR1b=(est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
					PR2b=(est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);								% �R�[�h�̕��U(�d�ݍl��)
% 					PR1a=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					PR2a=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					PR1b=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
% 					PR2b=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);			% �R�[�h�̕��U(�d�ݍl��)
				end
				PR1 = diag(PR1a+PR1b); PR2 = diag(PR2a+PR2b);										% �R�[�h�̕��U(1�d��)
				if est_prm.freq==1
					R=TD*PR1*TD';																	% DD obs noise(CA)
				else
					R=blkdiag(TD*PR1*TD',TD*PR2*TD');												% DD obs noise(CA,PY)
				end

				%--- �C�m�x�[�V����
				%--------------------------------------------
				zz = Y - h;

				%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
				%--------------------------------------------
				Kalx_p(1:3)=xyz2enu(Kalx_p(1:3),est_prm.refpos);

				%--- �J���}���t�B���^(�ϑ��X�V)
				%--------------------------------------------
				[Kalx_f, KalP_f, V] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);
% 				[Kalx_f, KalP_f] = filtsrcf_upd(zz, H, R, Kalx_p, KalP_p);

				%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),est_prm.refpos);

				Kalx_p=Kalx_f;  KalP_p=KalP_f;

				%--- DGPS���̎���
				%--------------------------------------------
				% �d���w�x���ɂ��Ă�, ���ԍX�V�̂��߂ɗ��p����K�v�����邩��
				nxo.u=nx.u;
				nxo.T=nx.T;
				nxo.i=nx.i;
				nxo.x=nxo.u+nxo.T+nxo.i;

				prn.o = prn.u;																		% �ϑ��X�V�̂��߂ɕK�v
			end
		else
			zz=[];
			prn.u=[];
			Kalx_f(1:nx.u+nx.T) = NaN;
		end

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos3 = xyz2enu(Kalx_f(1:3),est_prm.rovpos)';											% ENU�ɕϊ�(dgps)

		%--- ���ʊi�[(DGPS��)
		%--------------------------------------------
		Result.dgps.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% ����
		Res.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];						% ����
		if ~isempty(zz)
			%--- �c��
			%--------------------------------------------
			Res.pre{1,prn.u(1)}(timetag,prn.u(2:end))=zz(1:(length(prn.u)-1),1)';					% CA(pre-fit)
			Res.post{1,prn.u(1)}(timetag,prn.u(2:end))=V(1:(length(prn.u)-1),1)';					% CA(post-fit)
			if est_prm.freq==2
				Res.pre{2,prn.u(1)}(timetag,prn.u(2:end))=...
						zz(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';								% PY(pre-fit)
				Res.post{2,prn.u(1)}(timetag,prn.u(2:end))=...
						V(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';								% PY(post-fit)
			end

			%--- ���ʊi�[(DGPS��)
			%--------------------------------------------
			Result.dgps.pos(timetag,:)=[Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1]];		% �ʒu
			switch est_prm.statemodel.ion
			case 1,
				Result.dgps.dion(timetag,prn.u(2:end))=Kalx_f(ix.i);								% �d���w�x��
			case {2,3}
				Result.dgps.dion(timetag,prn.u)=Kalx_f(ix.i);										% �d���w�x��
			case 4
				Result.dgps.dion(timetag,1:2)=Kalx_f(ix.i);											% �d���w�x��
			case 5
				Result.dgps.dion(timetag,1:4)=Kalx_f(ix.i);											% �d���w�x��
			end
			if est_prm.statemodel.trop~=0
				Result.dgps.dtrop(timetag,:)=Kalx_f(ix.T);											% �Η����x��
			end
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
		fprintf('%10.4f %10.4f %10.4f  %3d   PRN:',est_pos3(1:3),length(prn.u));
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		if ~isempty(rej), fprintf(' , AHO');, end
		fprintf('\n')

		%--- �q���i�[
		%--------------------------------------------
		Result.dgps.prn{3}(timetag,1:4)=[time1.tod,length(prn.c),length(prn.u),dop1];
		Result.dgps.prn{1}(timetag,prn.c)=prn.c;
		if ~isempty(prn.u)
			Result.dgps.prn{2}(timetag,prn.u)=prn.u;
			Result.dgps.prn{4}(timetag,prn.u(1))=prn.u(1);
		end

		%--- ���ʏ����o��
		%--------------------------------------------
		fprintf(f_sol1,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',...
				timetag,time1.week,time1.tow,time1.tod,Kalx_f(1:3),est_pos3);

		prn.o = prn.u;
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
matname=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.mat',...
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
% kmlname2=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp);
% output_kml([est_prm.dirs.result,kmlname2],Result.dgps);
% 
% %--- NMEA�o��
% %--------------------------------------------
% nmeaname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname2=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname1],Result.spp);
% output_nmea([est_prm.dirs.result,nmeaname2],Result.dgps);
% 
% %--- INS�p
% %--------------------------------------------
% insname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% insname2=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname1],Result.spp,est_prm);
% output_ins([est_prm.dirs.result,insname2],Result.dgps,est_prm);

fclose('all');
