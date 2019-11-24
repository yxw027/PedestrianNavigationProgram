%-------------------------------------------------------------------------------%
%                 ���{�E�v�ی��� GPS���ʉ��Z��۸��с@Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS���ʉ��Z�v���O����(VPPP��)
% 
% < Program�̗��� >
% 
%  1. �����ݒ�̎擾
%  2. obs �w�b�_�[���
%  3. nav ����G�t�F�����X�擾
%  4. start, end ��ݒ�
%  5. nav ����d���w�p�����[�^���擾
%  6. ionex �t�@�C���Ǎ���
%  7. ionex �w�b�_�[���
%  8. ionex ����STEC�f�[�^�擾
%  9. ������Ǎ���
% 10. ���C������
%     1. �P�Ƒ��� (�ŏ����@)
%     2. �N���b�N�W�����v�␳���␳�ς݊ϑ��ʂ��쐬
%     3. VPPP (�J���}���t�B���^)
% 11. ���ʊi�[
% 12. ���ʃO���t�\��
% 
% 
%-------------------------------------------------------------------------------
% �K�v�ȊO���t�@�C���E�֐�
%-------------------------------------------------------------------------------
% phisic_const.m      : �����ϐ���`
%-------------------------------------------------------------------------------
% FQ_state_all4.m     : ��ԃ��f���̐���
%-------------------------------------------------------------------------------
% prn_check.m         : �q���ω��̌��o
% sat_order.m         : �q��PRN�̏��Ԃ̌���
% select_prn.m        : �g�p�q���̑I��
% state_adjust.m      : �q���ω����̎�������
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
% geodist3.m          : �􉽊w�I�������̌v�Z(������)
% geodist_sp33.m      : �􉽊w�I�������̌v�Z(������)
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
% lambda2.m           : LAMBDA�@(by Kubo, �e�֐����T�u��)
% mlambda.m           : MLAMBDA�@(by Takasu)
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
% VPPP�ɕύX
% 
% 2��̃A���e�i�̃f�[�^���ꏏ�̏ꍇ�̂ݑΉ�(�ʁX�̃t�@�C���̏ꍇ�ɂ͕ύX���K�v)
% 
% ��M�@���ʁX�̏ꍇ, ��ԕϐ���Ή�����悤�ɕύX����K�v������(�Ö�̂���)
% 
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov.v     : ���q��(rov)
%  prn.rovu    : �g�p�q��(rov)
%  prn.rovu1   : �g�p�q��(rov)
%  prn.rovu2   : �g�p�q��(rov)
%  prn.rov.v       : ���q��(rov) prn.rov.v�Ɠ���
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
% ���ʌ��ʃv���b�g�Ɖq���̕ϐ����̕ύX
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov.v   : ���q��(rov)
% 
%-------------------------------------------------------------------------------
% latest update : 2010/02/22 by Yanase
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
est_prm=fileget2(est_prm);

if ~exist(est_prm.dirs.result)
	mkdir(est_prm.dirs.result);			% ���ʂ̃f�B���N�g������
end

tic

timetag=0;
timetag_o=0;
% change_flag=0;
dtr_o1=[];
dtr_o2=[];
jump_width_all1=[];
jump_width_all2=[];
rej=[];
refl=[];

%--- �萔(�O���[�o���ϐ�)
%--------------------------------------------
phisic_const;

%--- start time �̐ݒ�
%--------------------------------------------
if ~isempty(est_prm.stime)
	time_s = cal_time2(est_prm.stime);										% Start time �� Juliday, WEEK, TOW, TOD
end

%--- end time �̐ݒ�
%--------------------------------------------
if ~isempty(est_prm.etime)
	time_e = cal_time2(est_prm.etime);										% End time �� Juliday, WEEK, TOW, TOD
else
	time_e.day = [];
	time_e.mjd = 1e50;														% End time(mjd) �ɑ傫�Ȓl������
end

%--- �t�@�C���I�[�v��
%--------------------------------------------
fpo = fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');
fpn = fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');

if fpo==-1 | fpn==-1
	if fpo==-1, fprintf('%s���J���܂���.\n',est_prm.file.rov_o);, end		% Rov obs(�G���[����)
	if fpn==-1, fprintf('%s���J���܂���.\n',est_prm.file.rov_n);, end		% Rov nav(�G���[����)
	break;
end

%--- obs �w�b�_�[���
%--------------------------------------------
[tofh,toeh,s_time,e_time,app_xyz,no_obs,TYPES,dt,Rec_type]=read_obs_h(fpo);

%--- �G�t�F�����X�Ǎ���(Klobuchar model �p�����[�^�̒��o��)
%--------------------------------------------
[eph_prm.brd.data, ion_prm.klob.ionab]=read_eph(fpn);

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
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);			% IGS(sp3) �f�[�^��S�ēǍ���(1�񂾂�)
else
	eph_prm.sp3.data=[];
end

%--- �ݒ���̏o��
%--------------------------------------------
datname=sprintf('VPPP_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol  = fopen([est_prm.dirs.result,datname],'w');							% ���ʏ����o���t�@�C���̃I�[�v��
output_log(f_sol,time_s,time_e,est_prm,1);

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
if est_prm.mode==2, nx.t=0;, end
switch est_prm.statemodel.hw
case 0, nx.b=0;
case 1, nx.b=2;
end
switch est_prm.statemodel.trop
case 0, nx.T=0;,
case 1, nx.T=1;,
case 2, nx.T=1;,
end

%--- �z��̏���
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;

%--- SPP�p
%--------------------------------------------
Result.spp1.time(1:tt,1:10)=NaN; Result.spp1.time(:,1)=1:tt;					% ����
Result.spp1.pos(1:tt,1:6)=NaN;													% �ʒu
Result.spp1.dtr(1:tt,1:1)=NaN;													% ��M�@���v�덷
Result.spp1.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.spp1.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.spp1.prn{3}(1:tt,1:3)=NaN;												% �q����

Result.spp2.time(1:tt,1:10)=NaN; Result.spp2.time(:,1)=1:tt;					% ����
Result.spp2.pos(1:tt,1:6)=NaN;													% �ʒu
Result.spp2.dtr(1:tt,1:1)=NaN;													% ��M�@���v�덷
Result.spp2.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.spp2.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.spp2.prn{3}(1:tt,1:3)=NaN;												% �q����

Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% ����
Result.spp.pos(1:tt,1:6)=NaN;													% �ʒu
Result.spp.dtr(1:tt,1:1)=NaN;													% ��M�@���v�덷
Result.spp.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.spp.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.spp.prn{3}(1:tt,1:3)=NaN;												% �q����

%--- VPPP�p
%--------------------------------------------
Result.vppp.time(1:tt,1:10)=NaN; Result.vppp.time(:,1)=1:tt;					% ����
Result.vppp.pos(1:tt,1:6*3)=NaN;												% �ʒu
Result.vppp.dtr(1:tt,1:2)=NaN;													% ��M�@���v�덷
Result.vppp.hwb(1:tt,1:4)=NaN;													% HWB
Result.vppp.dion(1:tt,1:32)=NaN;												% �d���w�x��
Result.vppp.dtrop(1:tt,1:1)=NaN;												% �Η����x��
for j=1:2, Result.vppp.amb{j,1}(1:tt,1:32)=NaN;, end							% �����l�o�C�A�X
Result.vppp.prn{1}(1:tt,1:32)=NaN;												% ���q��
Result.vppp.prn{2}(1:tt,1:32)=NaN;												% �g�p�q��
Result.vppp.prn{3}(1:tt,1:3)=NaN;												% �q����

%--- �c���p
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% ����
for j=1:4, Res.pre{j,1}(1:tt,1:32)=NaN;, end									% �c��

%--- clock jump�p
%--------------------------------------------
dtr_all1(1:tt,1:2)=NaN; dtr_all2(1:tt,1:2)=NaN;

%--- �ϑ��f�[�^�p
%--------------------------------------------
OBS.rov1.time(1:tt,1:10)=NaN; OBS.rov1.time(:,1)=1:tt;							% ����
OBS.rov1.ca(1:tt,1:32)=NaN; OBS.rov1.py(1:tt,1:32)=NaN; 						% CA, PY
OBS.rov1.ph1(1:tt,1:32)=NaN; OBS.rov1.ph2(1:tt,1:32)=NaN;						% L1, L2
OBS.rov1.ion(1:tt,1:32)=NaN; OBS.rov1.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.rov1.ele(1:tt,1:32)=NaN; OBS.rov1.azi(1:tt,1:32)=NaN;						% Elevation, Azimuth
OBS.rov1.ca_cor(1:tt,1:32)=NaN; OBS.rov1.py_cor(1:tt,1:32)=NaN; 				% CA, PY(Corrected)
OBS.rov1.ph1_cor(1:tt,1:32)=NaN; OBS.rov1.ph2_cor(1:tt,1:32)=NaN;				% L1, L2(Corrected)

OBS.rov2.time(1:tt,1:10)=NaN; OBS.rov2.time(:,1)=1:tt;							% ����
OBS.rov2.ca(1:tt,1:32)=NaN; OBS.rov2.py(1:tt,1:32)=NaN;							% CA, PY
OBS.rov2.ph1(1:tt,1:32)=NaN; OBS.rov2.ph2(1:tt,1:32)=NaN;						% L1, L2
OBS.rov2.ion(1:tt,1:32)=NaN; OBS.rov2.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.rov2.ele(1:tt,1:32)=NaN; OBS.rov2.azi(1:tt,1:32)=NaN;						% Elevation, Azimuth
OBS.rov2.ca_cor(1:tt,1:32)=NaN; OBS.rov2.py_cor(1:tt,1:32)=NaN;					% CA, PY(Corrected)
OBS.rov2.ph1_cor(1:tt,1:32)=NaN; OBS.rov2.ph2_cor(1:tt,1:32)=NaN;				% L1, L2(Corrected)

%--- LC�p
%--------------------------------------------
LC.rov1.time(1:tt,1:10)=NaN; LC.rov1.time(:,1)=1:tt;							% ����
LC.rov1.mp1(1:tt,1:32)=NaN; LC.rov1.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.rov1.mw(1:tt,1:32)=NaN;														% MW
LC.rov1.lgl(1:tt,1:32)=NaN; LC.rov1.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.rov1.lg1(1:tt,1:32)=NaN; LC.rov1.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.rov1.ionp(1:tt,1:32)=NaN; LC.rov1.ionl(1:tt,1:32)=NaN;						% IONP, IONL

LC.rov2.time(1:tt,1:10)=NaN; LC.rov2.time(:,1)=1:tt;							% ����
LC.rov2.mp1(1:tt,1:32)=NaN; LC.rov2.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.rov2.mw(1:tt,1:32)=NaN;														% MW
LC.rov2.lgl(1:tt,1:32)=NaN; LC.rov2.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.rov2.lg1(1:tt,1:32)=NaN; LC.rov2.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.rov2.ionp(1:tt,1:32)=NaN; LC.rov2.ionl(1:tt,1:32)=NaN;						% IONP, IONL

%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z ---->> �J�n
%-----------------------------------------------------------------------------------------
while 1

	%--- �G�|�b�N���擾(����, PRN, Data�Ȃ�)
	%--------------------------------------------
	[time,no_sat,prn.rov.v,dtrec,ephi,data]=read_obs_epo_data(fpo,eph_prm.brd.data,no_obs,TYPES);

	% end ����
	%--------------------------------------------
	if time_e.mjd <= time.mjd-0.1/86400, break;, end							% �� 0.1 �b��ڂ܂ŔF�߂�

	%--- start ����
	%--------------------------------------------
	if time_s.mjd <= time.mjd+0.1/86400											% �� 0.1 �b��ڂ܂ŔF�߂�
		%--- �^�C���^�O
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
		else
			timetag = timetag + round((time.mjd-time_o.mjd)*86400/dt);
		end

		%--- �ǂݎ�蒆�̃G�|�b�N�̎��ԕ\��
		%--------------------------------------------
		fprintf('%7d:  %2d:%2d %5.2f"  ',timetag,time.day(4),time.day(5),time.day(6));

		%--- �A���e�ia,b��PRN��index���i�[(���ʉq���̂�)
		%------------------------------------------------
		ind_p1 = [];
		ind_p2 = [];
		for k = 1 : (length(prn.rov.v)-1)
			if prn.rov.v(k) == prn.rov.v(k+1)
				ind_p1 = [ind_p1 k];
				ind_p2 = [ind_p2 k+1];
			end
		end
		data1=data(ind_p1,:);
		data2=data(ind_p2,:);
		prn.rov.v=prn.rov.v(ind_p1); no_sat=length(prn.rov.v);

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@)
		%------------------------------------------------------------------------------------------------------

		%--- �P�Ƒ���
		%--------------------------------------------
		[x1,dtr1,dtsv1,ion1,trop1,prn.rov1,rho1,dop1,ele1,azi1]=...
				pointpos2(time,prn.rov.v,app_xyz,data1,eph_prm,ephi,est_prm,ion_prm,rej);
		[x2,dtr2,dtsv2,ion2,trop2,prn.rov2,rho2,dop2,ele2,azi2]=...
				pointpos2(time,prn.rov.v,app_xyz,data2,eph_prm,ephi,est_prm,ion_prm,rej);
		if ~isnan(x1(1)), app_xyz(1:3)=x1(1:3);, end
		if ~isnan(x2(1)), app_xyz(1:3)=x2(1:3);, end

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		x12=(x1(1:3)+x1(1:3))/2;															% mid position

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos1 = xyz2enu(x1(1:3),est_prm.rovpos)';										% ENU�ɕϊ�
		est_pos2 = xyz2enu(x2(1:3),est_prm.rovpos)';										% ENU�ɕϊ�
		est_pos12 = xyz2enu(x12,est_prm.rovpos)';											% ENU�ɕϊ�
		est_pos12(3)=est_pos12(3)+0.3;

		%--- ���ʊi�[(SPP)
		%--------------------------------------------
		Result.spp1.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% ����
		Result.spp1.pos(timetag,:)=[x1(1:3)', xyz2llh(x1(1:3)).*[180/pi 180/pi 1]];			% �ʒu
		Result.spp1.dtr(timetag,:)=C*dtr1;													% ��M�@���v�덷

		Result.spp2.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% ����
		Result.spp2.pos(timetag,:)=[x2(1:3)', xyz2llh(x2(1:3)).*[180/pi 180/pi 1]];			% �ʒu
		Result.spp2.dtr(timetag,:)=C*dtr2;													% ��M�@���v�덷

		Result.spp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% ����
		Result.spp.pos(timetag,:)=[x12', xyz2llh(x12).*[180/pi 180/pi 1]];					% �ʒu
		Result.spp1.dtr(timetag,:)=C*dtr1;													% ��M�@���v�덷

		%--- �q���i�[
		%--------------------------------------------
		Result.spp1.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rov1),dop1];
		Result.spp1.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rov1), Result.spp1.prn{2}(timetag,prn.rov1)=prn.rov1;, end

		Result.spp2.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rov2),dop2];
		Result.spp2.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rov2), Result.spp2.prn{2}(timetag,prn.rov2)=prn.rov2;, end

		Result.spp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rov1),dop1];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rov1), Result.spp.prn{2}(timetag,prn.rov1)=prn.rov1;, end

		%--- OBS�f�[�^,�d���w�x��(�\����)
		%--------------------------------------------
		OBS.rov1.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];		% ����
		OBS.rov2.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];		% ����
		OBS.rov1.ca(timetag,prn.rov.v)   = data1(:,2);
		OBS.rov1.py(timetag,prn.rov.v)   = data1(:,6);
		OBS.rov1.ph1(timetag,prn.rov.v)  = data1(:,1);
		OBS.rov1.ph2(timetag,prn.rov.v)  = data1(:,5);
		OBS.rov1.ion(timetag,prn.rov.v)  = ion1(:,1);
		OBS.rov1.trop(timetag,prn.rov.v) = trop1(:,1);

		OBS.rov2.ca(timetag,prn.rov.v)   = data2(:,2);
		OBS.rov2.py(timetag,prn.rov.v)   = data2(:,6);
		OBS.rov2.ph1(timetag,prn.rov.v)  = data2(:,1);
		OBS.rov2.ph2(timetag,prn.rov.v)  = data2(:,5);
		OBS.rov2.ion(timetag,prn.rov.v)  = ion2(:,1);
		OBS.rov2.trop(timetag,prn.rov.v) = trop2(:,1);

		OBS.rov1.ele(timetag,prn.rov.v)  = ele1(:,1);				% elevation
		OBS.rov1.azi(timetag,prn.rov.v)  = azi1(:,1);				% azimuth
		OBS.rov2.ele(timetag,prn.rov.v)  = ele2(:,1);				% elevation
		OBS.rov2.azi(timetag,prn.rov.v)  = azi2(:,1);				% azimuth

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@) ---->> �I�� ---->> �N���b�N�W�����v�␳
		%------------------------------------------------------------------------------------------------------

		%--- clock jump �̌��o & �␳
		%--------------------------------------------
		% |dtr�̃G�|�b�N�ԍ�| > 0.5ms �� ��тƔ���
		% dtr�̃G�|�b�N�ԍ����ѕ��Ƃ�ms�P�ʂɊۂ߂�
		% ����, �ϑ��f�[�^, dtr �����ѕ������Z
		%--------------------------------------------
		if est_prm.clk_flag == 1
			dtr_all1(timetag,1) = dtr1;																% ��M�@���v�덷���i�[
			[data1,dtr1,time.day,clk_jump1,dtr_o1,jump_width_all1]=...
						clkjump_repair2(time.day,data1,dtr1,dtr_o1,jump_width_all1,Rec_type1);		% clock jump ���o/�␳
			clk_check1(timetag,1) = clk_jump1;														% �W�����v�t���O���i�[

			dtr_all2(timetag,1) = dtr2;																% ��M�@���v�덷���i�[
			[data2,dtr2,time.day,clk_jump2,dtr_o2,jump_width_all2]=...
						clkjump_repair2(time.day,data2,dtr2,dtr_o2,jump_width_all2,Rec_type2);		% clock jump ���o/�␳
			clk_check2(timetag,1) = clk_jump2;														% �W�����v�t���O���i�[
		end
		dtr_all1(timetag,2) = dtr1;																	% �␳�ςݎ�M�@���v�덷���i�[
		dtr_all2(timetag,2) = dtr2;																	% �␳�ςݎ�M�@���v�덷���i�[

		%--- �␳�ς݊ϑ��ʂ��i�[
		%--------------------------------------------
		OBS.rov1.ca_cor(timetag,prn.rov.v)  = data1(:,2);				% CA
		OBS.rov1.py_cor(timetag,prn.rov.v)  = data1(:,6);				% PY
		OBS.rov1.ph1_cor(timetag,prn.rov.v) = data1(:,1);				% L1
		OBS.rov1.ph2_cor(timetag,prn.rov.v) = data1(:,5);				% L2

		OBS.rov2.ca_cor(timetag,prn.rov.v)  = data2(:,2);				% CA
		OBS.rov2.py_cor(timetag,prn.rov.v)  = data2(:,6);				% PY
		OBS.rov2.ph1_cor(timetag,prn.rov.v) = data2(:,1);				% L1
		OBS.rov2.ph2_cor(timetag,prn.rov.v) = data2(:,5);				% L2

		%--- �e����`����(�␳�ς݊ϑ��ʂ��g�p)
		%--------------------------------------------
		[mp11,mp21,lgl1,lgp1,lg11,lg21,mw1,ionp1,ionl1] = obs_comb(data1);
		[mp12,mp22,lgl2,lgp2,lg12,lg22,mw2,ionp2,ionl2] = obs_comb(data2);

		%--- �e����`�������i�[
		%--------------------------------------------
		LC.rov1.mp1(timetag,prn.rov.v)  = mp11;						% Multipath ���`����(L1)
		LC.rov1.mp2(timetag,prn.rov.v)  = mp21;						% Multipath ���`����(L2)
		LC.rov1.mw(timetag,prn.rov.v)   = mw1;						% Melbourne-Wubbena ���`����
		LC.rov1.lgl(timetag,prn.rov.v)  = lgl1;						% �􉽊w�t���[���`����(�����g)
		LC.rov1.lgp(timetag,prn.rov.v)  = lgp1;						% �􉽊w�t���[���`����(�R�[�h)
		LC.rov1.lg1(timetag,prn.rov.v)  = lg11;						% �􉽊w�t���[���`����(1���g)
		LC.rov1.lg2(timetag,prn.rov.v)  = lg21;						% �􉽊w�t���[���`����(2���g)
		LC.rov1.ionp(timetag,prn.rov.v) = ionp1;					% �d���w(lgp����Z�o)
		LC.rov1.ionl(timetag,prn.rov.v) = ionl1;					% �d���w(lgl����Z�o,N���܂�)

		LC.rov2.mp1(timetag,prn.rov.v)  = mp12;						% Multipath ���`����(L1)
		LC.rov2.mp2(timetag,prn.rov.v)  = mp22;						% Multipath ���`����(L2)
		LC.rov2.mw(timetag,prn.rov.v)   = mw2;						% Melbourne-Wubbena ���`����
		LC.rov2.lgl(timetag,prn.rov.v)  = lgl2;						% �􉽊w�t���[���`����(�����g)
		LC.rov2.lgp(timetag,prn.rov.v)  = lgp2;						% �􉽊w�t���[���`����(�R�[�h)
		LC.rov2.lg1(timetag,prn.rov.v)  = lg12;						% �􉽊w�t���[���`����(1���g)
		LC.rov2.lg2(timetag,prn.rov.v)  = lg22;						% �􉽊w�t���[���`����(2���g)
		LC.rov2.ionp(timetag,prn.rov.v) = ionp2;					% �d���w(lgp����Z�o)
		LC.rov2.ionl(timetag,prn.rov.v) = ionl2;					% �d���w(lgl����Z�o,N���܂�)

% 		if timetag>1
% 			rej1=find(abs(diff(LC.rov1.lg1(timetag-1:timetag,:)))>1.5);
% 			rej2=find(abs(diff(LC.rov2.lg1(timetag-1:timetag,:)))>1.5);
% 			rej=union(rej1,rej2);
% 		end


		%------------------------------------------------------------------------------------------------------
		%----- VPPP (�J���}���t�B���^)
		%------------------------------------------------------------------------------------------------------

		prn.rov.v=prn.rov.v;			% ���q��

		%--- �J���}���t�B���^�̐ݒ�(�q���ω���������)
		%--------------------------------------------

		%--- �����ƃC���f�b�N�X�̐ݒ�(���q��)
		%--------------------------------------------
		if est_prm.mode==1
			ns=length(prn.rov.v);																	% ���q����
			ix.u1=1:nx.u; nx.x=nx.u;																% ��M�@�ʒu
			ix.u2=nx.x+(1:nx.u); nx.x=nx.x+nx.u;													% ��M�@�ʒu
			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;														% ��M�@���v�덷
			if est_prm.statemodel.hw==1
				ix.b=nx.x+(1:2*nx.b); nx.x=nx.x+2*nx.b;												% ��M�@HWB(ON)
			else
				ix.b=[]; nx.x=nx.x+2*nx.b;															% ��M�@HWB(OFF)
			end
			if est_prm.statemodel.trop~=0
				ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;													% �Η����x��(ON)
			else
				ix.T=[]; nx.x=nx.x+nx.T;															% �Η����x��(OFF)
			end
% 			if est_prm.statemodel.ion~=0
% 				ix.i=nx.x+(1:nx.i); nx.x=nx.x+nx.i;													% �d���w�x��(ON)
% 			else
% 				ix.i=[]; nx.x=nx.x+nx.i;															% �d���w�x��(OFF)
% 			end
			nx.p=nx.x;
			ix.n=nx.x+(1:2*ns); nx.n=length(ix.n); nx.x=nx.x+nx.n;									% �����l�o�C�A�X
		elseif est_prm.mode==2
			ns=length(prn.rov.v);																		% ���q����
			ix.u1=1:nx.u; nx.x=nx.u;																% ��M�@�ʒu
			ix.u2=nx.x+(1:nx.u); nx.x=nx.x+nx.u;													% ��M�@�ʒu
% 			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;														% ��M�@���v�덷
			if est_prm.statemodel.hw==1
				ix.b=nx.x+(1:nx.b); nx.x=nx.x+nx.b;													% ��M�@HWB(ON)
			else
				ix.b=[]; nx.x=nx.x+nx.b;															% ��M�@HWB(OFF)
			end
% 			if est_prm.statemodel.trop~=0
% 				ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;													% �Η����x��(ON)
% 			else
% 				ix.T=[]; nx.x=nx.x+nx.T;															% �Η����x��(OFF)
% 			end
% 			if est_prm.statemodel.ion~=0
% 				ix.i=nx.x+(1:nx.i); nx.x=nx.x+nx.i;													% �d���w�x��(ON)
% 			else
% 				ix.i=[]; nx.x=nx.x+nx.i;															% �d���w�x��(OFF)
% 			end
			nx.p=nx.x;
			ix.n=nx.x+(1:ns); nx.n=length(ix.n); nx.x=nx.x+nx.n;									% �����l�o�C�A�X
		end

		%--- Ambiguity �̎Z�o
		%--------------------------------------------
		N1ls=[];  N2ls=[];  N12ls=[];
		N1ls=(lam1*data1(:,1)-(rho1+C*(dtr1-dtsv1)+trop1(:,1)-ion1(:,1)))/lam1;						% L1 �����l�o�C�A�X(�t�Z)
		N2ls=(lam1*data2(:,1)-(rho2+C*(dtr2-dtsv2)+trop2(:,1)-ion2(:,1)))/lam1;						% L1 �����l�o�C�A�X(�t�Z)
		N12ls=N1ls-N2ls;

		%--- �q�����ω������ꍇ�Ɏ����𒲐߂���
		%--------------------------------------------
		if est_prm.mode==1
			if timetag == 1 | isnan(Kalx_f(1)) %| timetag-timetag_o ~= 5							% 1�G�|�b�N��
				Kalx_p=[x1(1:3); repmat(0,nx.u-3,1); x2(1:3); repmat(0,nx.u-3,1);...
						(x1(4)+x2(4))/2; repmat(0,nx.t-1,1)];										% �����l
				if est_prm.statemodel.hw==1,   Kalx_p=[Kalx_p; repmat(0,2*nx.b,1)];, end
				switch est_prm.statemodel.trop
				case 1, Kalx_p=[Kalx_p; 0.4];														% ZWD����
				case 2, Kalx_p=[Kalx_p; 2.4];														% ZTD����
				end
				if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; N1ls; N2ls];, end

				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j].^2;
				KalP_p=diag([KalP_p(1:nx.u),KalP_p(1:nx.u),...
						est_prm.P0.std_dev_t(1:nx.t), ...
						est_prm.P0.std_dev_b(1:2*nx.b),...
						est_prm.P0.std_dev_T(1:nx.T),...
						ones(1,nx.n)*est_prm.P0.std_dev_n]).^2;

				if isempty(refl), refl=x1(1:3);, end
			else											% 2�G�|�b�N�ȍ~
				%--- ��ԑJ�ڍs��E�V�X�e���G���s�񐶐�
				%--------------------------------------------
				[F,Q]=FQ_state_all6(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,3);

				%--- ECEF(WGS84)����Local�ɕϊ�
				%--------------------------------------------
% 				refl=Kalx_f(1:3);
				Kalx_f(ix.u1)=xyz2enu(Kalx_f(ix.u1),refl);
				Kalx_f(ix.u2)=xyz2enu(Kalx_f(ix.u2),refl);

				%--- �J���}���t�B���^(���ԍX�V)
				%--------------------------------------------
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);

				%--- Local����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_p(ix.u1)=enu2xyz(Kalx_p(ix.u1),refl);
				Kalx_p(ix.u2)=enu2xyz(Kalx_p(ix.u2),refl);

				%--- �������ߌ�̏�ԕϐ��Ƌ����U
				%--------------------------------------------
				[Kalx_p,KalP_p]=state_adjust2(prn.rov.v,prn.o,Kalx_p,KalP_p,N1ls,N2ls,[]);					% ��i�\���l / ��i�\���l�̋����U�s��
				N1ls=Kalx_p(ix.n(1:ns));
				N2ls=Kalx_p(ix.n(ns+1:end));
			end
		elseif est_prm.mode==2
			if timetag == 1 | isnan(Kalx_f(1)) %| timetag-timetag_o ~= 5									% 1�G�|�b�N��
				Kalx_p=[x1(1:3); repmat(0,nx.u-3,1); x2(1:3); repmat(0,nx.u-3,1);];							% �����l
				if est_prm.statemodel.hw==1,   Kalx_p=[Kalx_p; repmat(0,nx.b,1)];, end
				if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; N1ls; N2ls];, end

				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j].^2;
				KalP_p=diag([KalP_p(1:nx.u),KalP_p(1:nx.u),...
							est_prm.P0.std_dev_b(1:nx.b),...
							ones(1,nx.n)*est_prm.P0.std_dev_n]).^2;

				if isempty(refl), refl=x1(1:3);, end
			else											% 2�G�|�b�N�ȍ~
				%--- ��ԑJ�ڍs��E�V�X�e���G���s�񐶐�
				%--------------------------------------------
				[F,Q]=FQ_state_all5(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,3);

				%--- ECEF(WGS84)����Local(ENU)�ɕϊ�
				%--------------------------------------------
% 				refl=Kalx_f(1:3);
				Kalx_f(ix.u1)=xyz2enu(Kalx_f(ix.u1),refl);
				Kalx_f(ix.u2)=xyz2enu(Kalx_f(ix.u2),refl);

				%--- �J���}���t�B���^(���ԍX�V)
				%--------------------------------------------
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);

				%--- Local(ENU)����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_p(ix.u1)=enu2xyz(Kalx_p(ix.u1),refl);
				Kalx_p(ix.u2)=enu2xyz(Kalx_p(ix.u2),refl);

				%--- �������ߌ�̏�ԕϐ��Ƌ����U
				%--------------------------------------------
				[Kalx_p,KalP_p]=state_adjust(prn.rov.v,prn.o,Kalx_p,KalP_p,N12ls,[],[]);						% ��i�\���l / ��i�\���l�̋����U�s��
				N12ls=Kalx_p(ix.n(1:ns));
			end
		end

		%--- ��M�@���v�덷�̒u��
		%--------------------------------------------
		if est_prm.mode==1
			dtr1=Kalx_p(ix.t(1))/C;
			dtr2=Kalx_p(ix.t(1))/C;
		end

		if est_prm.statemodel.pos==4, Kalx_p(1:6)=[x1(1:3); x2(1:3)];, end

		%--- �ϑ��X�V�̌v�Z(�����\)
		%--------------------------------------------
		if ~isnan(x1(1))
			for nn=1:est_prm.iteration
				if nn~=1
					if est_prm.mode==1
						%--- �������ߌ�̏�ԕϐ��Ƌ����U
						% �Eprn.rov.v��Nls�̏��Ԃ�Ή������邱��
						% �Eprn.u��Kal�̏��Ԃ�Ή������邱��
						%--------------------------------------------
						[Kalx_p,KalP_p]=state_adjust(prn.rov.v,prn.u,Kalx_p,KalP_p,N1ls,N2ls,[]);				% ��i�\���l / ��i�\���l�̋����U�s��
						dtr1=Kalx_p(ix.t)/C;
						dtr2=Kalx_p(ix.t)/C;
						N1ls=Kalx_p(ix.n(1:ns));
						N2ls=Kalx_p(ix.n(ns+1:end));
					elseif est_prm.mode==2
						%--- �������ߌ�̏�ԕϐ��Ƌ����U
						% �Eprn.rov.v��Nls�̏��Ԃ�Ή������邱��
						% �Eprn.u��Kal�̏��Ԃ�Ή������邱��
						%--------------------------------------------
						[Kalx_p,KalP_p]=state_adjust(prn.rov.v,prn.u,Kalx_p,KalP_p,N12ls,[],[]);				% ��i�\���l / ��i�\���l�̋����U�s��
						N12ls=Kalx_p(ix.n(1:ns));
					end
				end

				%--- ������
				%--------------------------------------------
				sat_xyz1=[];  sat_xyz_dot1=[];  dtsv1=[];  sat_enu1=[];  ion1=[];  trop1=[];
				sat_xyz2=[];  sat_xyz_dot2=[];  dtsv2=[];  sat_enu2=[];  ion2=[];  trop2=[];
				azi1=[];  ele1=[];  rho1=[];  ee1=[];  tgd1=[];  Y1=[];  H=[];  h=[];  tzd1=[];  tzw1=[];
				azi2=[];  ele2=[];  rho2=[];  ee2=[];  tgd2=[];  Y2=[];  H=[];  h=[];  tzd2=[];  tzw2=[];
				Y1=[];  H1=[];  h1=[];  Y2=[];  H2=[];  h2=[];
				Y3=[];  H3=[];  h3=[];  Y4=[];  H4=[];  h4=[];

				%--- �ϑ���
				%--------------------------------------------
				% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1 �����g�ʑ�
				Y1 = data1(:,2);
				Y2 = lam1*data1(:,1);
				Y3 = data2(:,2);
				Y4 = lam1*data2(:,1);

				%--- �􉽊w�I����, �p, ���ʊp, �d���w, �Η����̌v�Z
				%--------------------------------------------
				for k = 1:length(prn.rov.v)
					% �􉽊w�I����(������/������)
					%--------------------------------------------
					[rho1(k,1),sat_xyz1(k,:),sat_xyz_dot1(k,:),dtsv1(k,:)]=...
							geodist_mix(time,eph_prm,ephi,prn.rov.v(k),Kalx_p(ix.u1),dtr1,est_prm);
					[rho2(k,1),sat_xyz2(k,:),sat_xyz_dot2(k,:),dtsv2(k,:)]=...
							geodist_mix(time,eph_prm,ephi,prn.rov.v(k),Kalx_p(ix.u2),dtr2,est_prm);
					tgd1(k,:) = eph_prm.brd.data(33,ephi(prn.rov.v(k)));										% TGD
					tgd2(k,:) = eph_prm.brd.data(33,ephi(prn.rov.v(k)));										% TGD

					%--- �p, ���ʊp, �Δ����W���̌v�Z
					%--------------------------------------------
					[ele1(k,1), azi1(k,1), ee1(k,:)]=azel(Kalx_p(ix.u1), sat_xyz1(k,:));
					[ele2(k,1), azi2(k,1), ee2(k,:)]=azel(Kalx_p(ix.u2), sat_xyz2(k,:));

					%--- �d���w�x�� & �Η����x��
					%--------------------------------------------
					ion1(k,1) = ...
							cal_ion2(time,ion_prm,azi1(k),ele1(k),Kalx_p(ix.u1),est_prm.i_mode);			% ionospheric model
					ion2(k,1) = ...
							cal_ion2(time,ion_prm,azi2(k),ele2(k),Kalx_p(ix.u2),est_prm.i_mode);			% ionospheric model
					[trop1(k,1),tzd1,tzw1] = ...
							cal_trop(ele1(k),Kalx_p(ix.u1),sat_xyz1(k,:)',est_prm.t_mode);					% tropospheric model
					[trop2(k,1),tzd2,tzw2] = ...
							cal_trop(ele2(k),Kalx_p(ix.u2),sat_xyz2(k,:)',est_prm.t_mode);					% tropospheric model
				end

				if est_prm.mode==1
					if timetag == 1 | isnan(Kalx_f(1))
						switch est_prm.statemodel.trop
						case 1, Kalx_p(ix.T)=tzw1;
						case 2, Kalx_p(ix.T)=tzd1+tzw1;
						end
					end
				end

				%--- �Η����x���̃}�b�s���O�֐�
				%--------------------------------------------
				Mw1=[]; Mw2=[];
				if est_prm.statemodel.trop~=0
					switch est_prm.mapf_trop
					case 1, [Md1,Mw1]=mapf_cosz(ele1);														% cosz(Md,Mw)
							[Md2,Mw2]=mapf_cosz(ele2);														% cosz(Md,Mw)
					case 2, [Md1,Mw1]=mapf_chao(ele1);														% Chao(Md,Mw)
							[Md2,Mw2]=mapf_chao(ele2);														% Chao(Md,Mw)
					case 3, [Md1,Mw1]=mapf_gmf(time.day,Kalx_p(ix.u1),ele1);								% GMF(Md,Mw)
							[Md2,Mw2]=mapf_gmf(time.day,Kalx_p(ix.u2),ele2);								% GMF(Md,Mw)
					case 4, [Md1,Mw1]=mapf_marini(time.day,Kalx_p(ix.u1),ele1);								% Marini(Md,Mw)
							[Md2,Mw2]=mapf_marini(time.day,Kalx_p(ix.u2),ele2);								% Marini(Md,Mw)
					end
				end

				%--- �Η����x������p
				%--------------------------------------------
				if est_prm.mode==1
					switch est_prm.statemodel.trop
					case 1
						trop1=Md1.*tzd1+Mw1.*Kalx_p(ix.T);													% ZWD����p
						trop2=Md2.*tzd2+Mw2.*Kalx_p(ix.T);													% ZWD����p
					case 2
						trop1=Md1.*tzd1+Mw1.*(Kalx_p(ix.T)-tzd1);											% ZTD����p
						trop2=Md2.*tzd2+Mw2.*(Kalx_p(ix.T)-tzd2);											% ZTD����p
					end
				end

				% �n�[�h�E�F�A�o�C�A�X
				%--------------------------------------------
				hwb1=0; hwb2=0; hwb3=0; hwb4=0;
				if est_prm.statemodel.hw==1
					switch nx.b
					case 4,
						hwb1=Kalx_p(ix.b(1)); hwb2=Kalx_p(ix.b(2));
						hwb3=Kalx_p(ix.b(3)); hwb4=Kalx_p(ix.b(4));
					case 2,
						hwb1=Kalx_p(ix.b(1)); hwb2=Kalx_p(ix.b(2));
					end
				end

				%--- �ϑ����f��
				%--------------------------------------------
				num=length(prn.rov.v); I=ones(num,1); O=zeros(num,1); OO=zeros(num); II=eye(num);
				if est_prm.mode==1
					Ha=[]; Hb=[]; h1=[]; h2=[]; h3=[]; h4=[];
					for k = 1:length(prn.rov.v)
						if est_prm.statemodel.hw == 0
							h1(k,1)=rho1(k)+C*(dtr1-(dtsv1(k,:)-tgd1(k,:)))+trop1(k,1)+ion1(k,1);			% observation model
							h2(k,1)=rho1(k)+C*(dtr1-dtsv1(k,:))+trop1(k,1)-ion1(k,1)+lam1*N1ls(k);			% observation model
							h3(k,1)=rho2(k)+C*(dtr2-(dtsv2(k,:)-tgd2(k,:)))+trop2(k,1)+ion2(k,1);			% observation model
							h4(k,1)=rho2(k)+C*(dtr2-dtsv2(k,:))+trop2(k,1)-ion2(k,1)+lam1*N2ls(k);			% observation model
						else
							h1(k,1)=rho1(k)+C*(dtr1-(dtsv1(k,:)-tgd1(k,:)))...
									+trop1(k,1)+ion1(k,1)+hwb1;												% observation model
							h2(k,1)=rho1(k)+C*(dtr1-dtsv1(k,:))...
									+trop1(k,1)-ion1(k,1)+lam1*N1ls(k)+hwb3;								% observation model
							h3(k,1)=rho2(k)+C*(dtr2-(dtsv2(k,:)-tgd2(k,:)))...
									+trop2(k,1)+ion2(k,1)+hwb2;												% observation model
							h4(k,1)=rho2(k)+C*(dtr2-dtsv2(k,:))...
									+trop2(k,1)-ion2(k,1)+lam1*N2ls(k)+hwb4;								% observation model
						end
						Ha(k,:) = [ee1(k,:) zeros(1,3) 1];													% observation matrix
						Hb(k,:) = [zeros(1,3) ee2(k,:) 1];													% observation matrix
					end
					if est_prm.statemodel.hw == 0
						H1 = [Ha Mw1 OO OO];																% observation matrix
						H2 = [Ha Mw1 lam1*II OO];															% observation matrix
						H3 = [Hb Mw2 OO OO];																% observation matrix
						H4 = [Hb Mw2 OO lam1*II];															% observation matrix
					else
						H1 = [Ha I O O O Mw1 OO OO];														% observation matrix
						H2 = [Ha O O I O Mw1 lam1*II OO];													% observation matrix
						H3 = [Hb O I O O Mw2 OO OO];														% observation matrix
						H4 = [Hb O O O I Mw2 OO lam1*II];													% observation matrix
					end
				elseif est_prm.mode==2
					Ha=[]; Hb=[]; h1=[]; h2=[];
					for k = 1:length(prn.rov.v)
						if est_prm.statemodel.hw == 0
							h1(k,1)=rho1(k)-rho2(k)+(ion1(k,1)-ion2(k,1))...
									+(trop1(k,1)-trop2(k,1));												% observation model
							h2(k,1)=rho1(k)-rho2(k)-(ion1(k,1)-ion2(k,1))...
									+(trop1(k,1)-trop2(k,1))+lam1*(N12ls(k));								% observation model
						else
							h1(k,1)=rho1(k)-rho2(k)+(ion1(k,1)-ion2(k,1))...
									+(trop1(k,1)-trop2(k,1))+hwb1;											% observation model
							h2(k,1)=rho1(k)-rho2(k)-(ion1(k,1)-ion2(k,1))...
									+(trop1(k,1)-trop2(k,1))+lam1*(N12ls(k))+hwb2;							% observation model
						end
						Ha(k,:) = [ee1(k,:) -ee2(k,:)];														% observation matrix
						Hb(k,:) = [ee1(k,:) -ee2(k,:)];														% observation matrix
					end
					if est_prm.statemodel.hw == 0
						H1 = [Ha OO];																		% observation matrix
						H2 = [Ha lam1*II];																	% observation matrix
					else
						H1 = [Ha I O OO];																	% observation matrix
						H2 = [Ha O I lam1*II];																% observation matrix
					end
				end

				if est_prm.mode==1
					H1=[H1(:,1:3) repmat(0,size(H1,1),nx.u-3) ...
						H1(:,4:6) repmat(0,size(H1,1),nx.u-3) ...
						H1(:,7) repmat(0,size(H1,1),nx.t-1) H1(:,8:end)];									% observation matrix for kinematic
					H2=[H2(:,1:3) repmat(0,size(H2,1),nx.u-3) ...
						H2(:,4:6) repmat(0,size(H2,1),nx.u-3) ...
						H2(:,7) repmat(0,size(H2,1),nx.t-1) H2(:,8:end)];									% observation matrix for kinematic
					H3=[H3(:,1:3) repmat(0,size(H3,1),nx.u-3) ...
						H3(:,4:6) repmat(0,size(H3,1),nx.u-3) ...
						H3(:,7) repmat(0,size(H3,1),nx.t-1) H3(:,8:end)];									% observation matrix for kinematic
					H4=[H4(:,1:3) repmat(0,size(H4,1),nx.u-3) ...
						H4(:,4:6) repmat(0,size(H4,1),nx.u-3) ...
						H4(:,7) repmat(0,size(H4,1),nx.t-1) H4(:,8:end)];									% observation matrix for kinematic
				elseif est_prm.mode==2
					H1=[H1(:,1:3) repmat(0,size(H1,1),nx.u-3) ...
						H1(:,4:6) repmat(0,size(H1,1),nx.u-3) H1(:,7:end)];									% observation matrix for kinematic
					H2=[H2(:,1:3) repmat(0,size(H2,1),nx.u-3) ...
						H2(:,4:6) repmat(0,size(H2,1),nx.u-3) H2(:,7:end)];									% observation matrix for kinematic
				end

				%--- �ϑ��G��
				%--------------------------------------------
				HHs1 = []; HHs2 = [];
				for k = 1:length(prn.rov.v)
					HHs1(k,3*k-2:3*k) = ee1(k,:);															% �Δ����W��
					HHs2(k,3*k-2:3*k) = ee2(k,:);															% �Δ����W��
				end
				if est_prm.ww==1
					EE = (1./sin(ele1).^2);
				else
					EE = ones(length(prn.rov.v),1);
				end
				PR1  = repmat(est_prm.obsnoise.PR1,length(prn.rov.v),1).*EE;									% CA�̕��U
				PR2  = repmat(est_prm.obsnoise.PR2,length(prn.rov.v),1).*EE;									% PY�̕��U
				Ph1  = repmat(est_prm.obsnoise.Ph1,length(prn.rov.v),1).*EE;									% L1�̕��U
				Ph2  = repmat(est_prm.obsnoise.Ph2,length(prn.rov.v),1).*EE;									% L2�̕��U
				CLK  = repmat(est_prm.obsnoise.CLK,length(prn.rov.v),1).*EE;									% �q�����v�̕��U
				ION1 = repmat(est_prm.obsnoise.ION,length(prn.rov.v),1).*EE;									% �d���w�̕��U
				TRP  = repmat(est_prm.obsnoise.TRP,length(prn.rov.v),1).*EE;									% �Η����̕��U
				ORB  = repmat(est_prm.obsnoise.ORB,length(prn.rov.v),1).*EE;									% �q���O���̕��U

				if est_prm.mode==1
					TT = [II OO OO OO HHs1 II -II -II;														% �G���̌W���s��쐬
					      OO II OO OO HHs2 II  II -II;
					      OO OO II OO HHs1 II -II -II;
					      OO OO OO II HHs2 II  II -II];
					RR = diag([PR1; PR1; Ph1; Ph1; ORB; ORB; ORB; CLK; ION1; TRP]);
					R = TT * RR * TT';																		% �G���̋����U�s��쐬
				elseif est_prm.mode==2
					TT = [II OO (HHs1-HHs2);																% �G���̌W���s��쐬
					      OO II (HHs1-HHs2)];
					RR = diag([2*PR1; 2*Ph1; ORB; ORB; ORB;]);
					R = TT * RR * TT';																		% �G���̋����U�s��쐬
					R=[2*(eye(length(prn.rov.v)))*0.03^2 zeros(length(prn.rov.v));
					   zeros(length(prn.rov.v)) 2*(eye(length(prn.rov.v)))*0.3^2];									% observation noise
				end

				%--- �g�p�q�����̒��o
				%--------------------------------------------
				if est_prm.mode==1
					ii = find(~isnan(Y1+Y2+Y3+Y4+h1+h2+h3+h4) &...
							ismember(prn.rov.v',rej)==0 & ele1*180/pi>est_prm.mask);							% Y, h �� NaN �̂Ȃ���� index & �p�}�X�N�J�b�g
					H1 = H1(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H2 = H2(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H3 = H3(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H4 = H4(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H = [H1; H3; H2; H4];																	% observation matrix(ii ��)
					Y1 = Y1(ii,:);  Y2 = Y2(ii,:);  Y3 = Y3(ii,:);  Y4 = Y4(ii,:);
					Y = [Y1; Y3; Y2; Y4];																	% observation(ii��)
					h1 = h1(ii,:);  h2 = h2(ii,:);  h3 = h3(ii,:);  h4 = h4(ii,:);
					h = [h1; h3; h2; h4];																	% observation model(ii��)
					R  = R([ii',length(prn.rov.v)+ii',2*length(prn.rov.v)+ii',3*length(prn.rov.v)+ii'],...
						   [ii',length(prn.rov.v)+ii',2*length(prn.rov.v)+ii',3*length(prn.rov.v)+ii']);				% observation noise(ii��)
					prn.u = prn.rov.v(ii);

					Kalx_p=Kalx_p([1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);								% ��������
					KalP_p=KalP_p([1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii'],...
								  [1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);								% ��������
				elseif est_prm.mode==2
					ii = find(~isnan(Y1+Y2+h1+h2) &...
							ismember(prn.rov.v',rej)==0 & ele1*180/pi>est_prm.mask);							% Y, h �� NaN �̂Ȃ���� index & �p�}�X�N�J�b�g
					H1 = H1(ii,[1:nx.p,nx.p+ii']);
					H2 = H2(ii,[1:nx.p,nx.p+ii']);
					H = [H1; H2];																			% observation matrix(ii ��)
					Y1 = Y1(ii,:);  Y2 = Y2(ii,:);  Y3 = Y3(ii,:);  Y4 = Y4(ii,:);
					Y = [Y1-Y3; Y2-Y4];																		% observation(ii��)
					h1 = h1(ii,:);  h2 = h2(ii,:);
					h = [h1; h2];																			% observation model(ii��)
					R  = R([ii',length(prn.rov.v)+ii'],[ii',length(prn.rov.v)+ii']);								% observation noise(ii��)
					prn.u = prn.rov.v(ii);

					Kalx_p=Kalx_p([1:nx.p,nx.p+ii']);														% ��������
					KalP_p=KalP_p([1:nx.p,nx.p+ii'],[1:nx.p,nx.p+ii']);										% ��������
				end

				%--- �Δ�����Local(ENU)�p�ɕϊ�(�L�l�}�e�B�b�N�p)
				%--------------------------------------------
				ref_L=xyz2llh(refl);
				lat=ref_L(1); lon=ref_L(2);
				LL = [         -sin(lon),           cos(lon),        0;
					  -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
					   cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
				H(:,ix.u1)=(LL*H(:,ix.u1)')';
				H(:,ix.u2)=(LL*H(:,ix.u2)')';


				%--- �S������
				%--------------------------------------------
				if est_prm.const == 1
					rr = 1;																					% �S���̊ϑ���
					rho12 = norm(Kalx_p(ix.u1)-Kalx_p(ix.u2));												% �A���e�i�Ԃ̋���
					H_c = [(Kalx_p(ix.u1)-Kalx_p(ix.u2))/rho12]';											% ���z
					H_c = (LL*H_c')';
					H=[H; H_c repmat(0,1,nx.u-3) -H_c repmat(0,1,nx.u-3) repmat(0,1,size(H,2)-2*nx.u)];
					Y=[Y;rr];
					h=[h;rho12];
					R(length(Y),length(Y)) = 1e-6;
				end

				%--- �C�m�x�[�V����
				%--------------------------------------------
				zz = Y - h;

				%--- ECEF(WGS84)����Local�ɕϊ�
				%--------------------------------------------
				Kalx_p(ix.u1)=xyz2enu(Kalx_p(ix.u1),refl);
				Kalx_p(ix.u2)=xyz2enu(Kalx_p(ix.u2),refl);

				%--- �J���}���t�B���^(�ϑ��X�V)
				%--------------------------------------------
				[Kalx_f, KalP_f] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);

				%--- Local����ECEF(WGS84)�ɕϊ�
				%--------------------------------------------
				Kalx_f(ix.u1)=enu2xyz(Kalx_f(ix.u1),refl);
				Kalx_f(ix.u2)=enu2xyz(Kalx_f(ix.u2),refl);

				Kalx_p=Kalx_f;  KalP_p=KalP_f;
			end
		else
			zz=[];
			prn.u=[];
			Kalx_f(1:nx.p) = NaN;
		end

		%--- MAP ����(�S������)
		%-----------------------------------------------
		if est_prm.const == 2
			rr = 1;																						% �S���̊ϑ���
			rho12 = norm(Kalx_p(ix.u1)-Kalx_p(ix.u2));													% �A���e�i�Ԃ̋���
			H_c = [(Kalx_p(ix.u1)-Kalx_p(ix.u2))/rho12]';												% ���z
			HH = [H_c repmat(0,1,nx.u-3) -H_c repmat(0,1,nx.u-3)];
			sigma_d = 1e-3;
			Rx = KalP_f(1:2*nx.u,1:2*nx.u);
			x_map = inv(inv(Rx) + HH'*HH./sigma_d^2)*(inv(Rx)*Kalx_f(1:2*nx.u) + rr*HH'./sigma_d^2);
			Kalx_f(1:2*nx.u) = x_map;
		end

		Kalx_fm=(Kalx_f(ix.u1)+Kalx_f(ix.u2))/2;														% mid pos

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos3 = xyz2enu(Kalx_f(ix.u1),est_prm.rovpos)';												% ENU�ɕϊ�
		est_pos4 = xyz2enu(Kalx_f(ix.u2),est_prm.rovpos)';												% ENU�ɕϊ�
		est_pos = xyz2enu(Kalx_fm,est_prm.rovpos)';
		est_pos(3)=est_pos(3)+0.3;

		%--- ���ʊi�[
		%--------------------------------------------
% 		Result.vppp(timetag,1:2*nx.u+nx.t+2*nx.b+nx.T+1) = [time.tod Kalx_f(1:2*nx.u+nx.t+2*nx.b+nx.T)'];

		%--- ���ʊi�[(VPPP��)
		%--------------------------------------------
		Result.vppp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];									% ����
		Result.vppp.pos(timetag,:)=[Kalx_fm', xyz2llh(Kalx_fm).*[180/pi 180/pi 1],...
									Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1],...
									Kalx_f(nx.u+1:nx.u+3)', xyz2llh(Kalx_f(nx.u+1:nx.u+3)).*[180/pi 180/pi 1]];		% �ʒu
		if est_prm.statemodel.dt==0 | est_prm.statemodel.dt==1
			Result.vppp.dtr(timetag,1:nx.t)=Kalx_f(2*nx.u+1:2*nx.u+nx.t);											% ��M�@���v�덷
		end
		if est_prm.statemodel.hw==1
			Result.vppp.hwb(timetag,1:2*nx.b)=Kalx_f(2*nx.u+nx.t+1:2*nx.u+nx.t+2*nx.b);								% HWB
		end
		if est_prm.statemodel.trop~=0
			Result.vppp.dtrop(timetag,1:nx.T)=Kalx_f(2*nx.u+nx.t+2*nx.b+1:2*nx.u+nx.t+2*nx.b+nx.T);					% �Η����x��
		end

		%--- ���ʊi�[
		%--------------------------------------------
		Res.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];											% ����
		if ~isempty(zz)
			if est_prm.mode==1
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.pre{3,1}(timetag,prn.u) = zz(1+2*length(prn.u):3*length(prn.u),1)';
				Res.pre{4,1}(timetag,prn.u) = zz(1+3*length(prn.u):4*length(prn.u),1)';
				Result.vppp.amb{1,1}(timetag,prn.u) = Kalx_f(nx.p+1:nx.p+length(prn.u),1)';
				Result.vppp.amb{2,1}(timetag,prn.u) = Kalx_f(nx.p+length(prn.u)+1:nx.p+2*length(prn.u),1)';
			elseif est_prm.mode==2
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Result.vppp.amb{1,1}(timetag,prn.u) = Kalx_f(nx.p+1:nx.p+length(prn.u),1)';
			end
		end

		%------------------------------------------------------------------------------------------------------
		%----- VPPP (�J���}���t�B���^) ---->> �I��
		%------------------------------------------------------------------------------------------------------

		%--- �q���ω��`�F�b�N
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.u);			% �q���ω��̃`�F�b�N
% 		end

		%--- ��ʕ\��
		%--------------------------------------------
		fprintf('%10.5f %10.5f %10.5f   PRN:',est_pos(1),est_pos(2),est_pos(3));
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		fprintf('\n')

		%--- �q���i�[
		%--------------------------------------------
		Result.vppp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.u),dop1];
		Result.vppp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.u), Result.vppp.prn{2}(timetag,prn.u)=prn.u;, end

		%--- ���ʏ����o��
		%--------------------------------------------
		fprintf(f_sol,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',timetag,time.week,time.tow,time.tod,Kalx_fm,est_pos);

		%--- �����̐ݒ�
		%--------------------------------------------
% 		dimo.u=nx.u; dimo.t=nx.t; dimo.b=nx.b; dimo.T=nx.T;
% 		if est_prm.mode==1
% 			dimo.p=2*dimo.u+dimo.t+2*dimo.b+dimo.T;
% 			dimo.x=dimo.p+2*length(prn.u);
% 			dimo.n=2*length(prn.u);
% 		elseif est_prm.mode==2
% 			dimo.p=2*dimo.u+dimo.t+dimo.b;
% 			dimo.x=nx.p+length(prn.u);
% 			dimo.n=length(prn.u);
% 		end


		if est_prm.mode==1
			nxo.u=nx.u; nxo.t=nx.t; nxo.b=nx.b; nxo.T=nx.T;
			nxo.n=2*length(prn.u);
			nxo.p=2*nxo.u+nxo.t+2*nxo.b+nxo.T;
			nxo.x=nxo.u+nxo.t+nxo.b+nxo.T+2*nxo.n;
		elseif est_prm.mode==2
			nxo.u=nx.u; nxo.t=nx.t; nxo.b=nx.b; nxo.T=nx.T;
			nxo.n=length(prn.u);
			nxo.p=2*nxo.u+nxo.t+2*nxo.b;
			nxo.x=nxo.u+nxo.t+nxo.b+nxo.n;
		end


		prn.o = prn.u;
		time_o=time;
		timetag_o=timetag;
	end
end
fclose('all');
toc
%-----------------------------------------------------------------------------------------
%----- "���C������" ���ʉ��Z ---->> �I��
%-----------------------------------------------------------------------------------------

%--- MAT�ɕۑ�
%--------------------------------------------
matname=sprintf('VPPP_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','Res','OBS','LC');

%--- ���ʌ��ʃv���b�g
%--------------------------------------------
plot_data2([est_prm.dirs.result,matname]);

% %--- KML�o��
% %--------------------------------------------
% kmlname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% kmlname2=sprintf('SPP1_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% kmlname3=sprintf('SPP2_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% kmlname4=sprintf('VPPP_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp);
% output_kml([est_prm.dirs.result,kmlname2],Result.spp1);
% output_kml([est_prm.dirs.result,kmlname3],Result.spp2);
% output_kml([est_prm.dirs.result,kmlname4],Result.vppp);
% 
% %--- NMEA�o��
% %--------------------------------------------
% nmeaname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname2=sprintf('SPP1_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname3=sprintf('SPP2_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname4=sprintf('VPPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname1],Result.spp);
% output_nmea([est_prm.dirs.result,nmeaname2],Result.spp1);
% output_nmea([est_prm.dirs.result,nmeaname3],Result.spp2);
% output_nmea([est_prm.dirs.result,nmeaname4],Result.vppp);
