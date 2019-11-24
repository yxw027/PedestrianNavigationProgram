%-------------------------------------------------------------------------------%
%                 ���{�E�v�ی��� GPS���ʉ��Z��۸��с@Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS���ʉ��Z�v���O����(SPP��)
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
%  9. ���ʊi�[
% 10. ���ʃO���t�\��
% 
% 
%-------------------------------------------------------------------------------
% �K�v�ȊO���t�@�C���E�֐�
%-------------------------------------------------------------------------------
% phisic_const.m      : �����ϐ���`
%-------------------------------------------------------------------------------
% FQ_state_all5.m     : ��ԃ��f���̐���
%-------------------------------------------------------------------------------
% prn_check.m         : �q���ω��̌��o
%-------------------------------------------------------------------------------
% cal_time2.m         : �w�莞����GPS�T�ԍ��EToW�EToD�̌v�Z
% clkjump_repair2.m   : ��M�@���v�̔�т̌��o/�C��
% mjuliday.m          : MJD�̌v�Z
% weekf.m             : WEEK, TOW �̌v�Z
%-------------------------------------------------------------------------------
% fileget2.m          : �t�@�C���������ƃ_�E�����[�h(wget.exe, gzip.exe)
%-------------------------------------------------------------------------------
% read_eph2.m         : �G�t�F�����X�̎擾
% read_ionex2.m       : IONEX�f�[�^�擾
% read_obs_epo_data2.m: OBS�G�|�b�N����� & OBS�ϑ��f�[�^�擾
% read_obs_h.m        : OBS�w�b�_�[���
% read_sp3.m          : ������f�[�^�擾
%-------------------------------------------------------------------------------
% azel.m              : �p, ���ʊp, �Δ����W���̌v�Z
% geodist_mix.m       : �􉽊w�I�������̌v�Z(������E������)
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
% <�ۑ�>
% �E�f�[�^�X�V�Ԋu�� 1[sec]�ȉ��̏ꍇ�~ �� �ǂݔ�΂����C��
% �E�ُ�l���o(���`����, ���O�c���E����c������)
% 
% �q��PRN�\���̂ɂ���(�戵���ɒ���)
%  prn.rov.v     : ���q��(rov)
%  prn.rovu    : �g�p�q��(rov)
% 
% �X�V�Ԋu��1[Hz]�ȏ�ł��ł���悤�ɏC��
% �� ����ɔ���, ���ɂ��C�����Ă��镔������
% 
%-------------------------------------------------------------------------------
% latest update : 2008/11/17 by Fujita
%-------------------------------------------------------------------------------
% 
% �EGLONASS�Ή�
% 
% <�ۑ�>
% �E�q�������x�E��]�␳�̍l�@
% �E�e��G��, �p�����[�^�ݒ�̌�����(GLONASS���ʂɌ���)
% �E�d���w���̐����@
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/12 by Yanase
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
if est_prm.n_nav==1
	fpn = fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');
else
	fpn = [];
end
if est_prm.g_nav==1
	fpg = fopen([est_prm.dirs.obs,est_prm.file.rov_g],'rt');
else
	fpg = [];
end

if fpo==-1
	fprintf('o�t�@�C��%s���J���܂���.\n',est_prm.file.rov_o);				% Rov obs(�G���[����)
	break;
end
if est_prm.n_nav==1
	if fpn==-1
	fprintf('n�t�@�C��%s���J���܂���.\n',est_prm.file.rov_n);				% Rov nav(GPS)(�G���[����)
	break;
	end
end
if est_prm.g_nav==1
	if fpg==-1
	fprintf('g�t�@�C��%s���J���܂���.\n',est_prm.file.rov_g);				% Rov nav(GLONASS)(�G���[����)
	break;
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
	ion_prm.gim.time=[]; ion_prm.gim.map=[]; ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end
if est_prm.i_mode==3
	load('ENMdata20081201_2.mat');
	ion_prm.gim.time=[]; ion_prm.gim.map=[]; ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- ������̓Ǎ���
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);
else
	eph_prm.sp3.data=[];
end

%--- �ݒ���̏o��
%--------------------------------------------
datname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol  = fopen([est_prm.dirs.result,datname],'w');							% ���ʏ����o���t�@�C���̃I�[�v��
output_log2(f_sol,time_s,time_e,est_prm,1);

%--- �����̐ݒ�(��ԃ��f������)
%--------------------------------------------
% switch est_prm.statemodel.pos
% case 0, dim.u=3*1;
% case 1, dim.u=3*2;
% case 2, dim.u=3*3;
% case 3, dim.u=3*4;
% case 4, dim.u=3*1;
% case 5, dim.u=3*2+2;
% end
% switch est_prm.statemodel.dt
% case 0, dim.t=1*1;
% case 1, dim.t=1*2;
% end
% switch est_prm.statemodel.hw
% case 0, dim.b=0;
% case 1, dim.b=est_prm.freq*2; if est_prm.obsmodel==9, dim.b=3;, end
% end
% switch est_prm.statemodel.trop
% case 0, dim.T=0;,
% case 1, dim.T=1;,
% end

%--- �z��̏���
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;

%--- SPP�p
%--------------------------------------------
Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% ����
Result.spp.pos(1:tt,1:6)=NaN;													% �ʒu
Result.spp.dtr(1:tt,1:1)=NaN;													% ��M�@���v�덷
Result.spp.prn{1}(1:tt,1:61)=NaN;												% ���q��
Result.spp.prn{2}(1:tt,1:61)=NaN;												% �g�p�q��
Result.spp.prn{3}(1:tt,1:3)=NaN;												% �q����

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

		%------------------------------------------------------------------------------------------------------
		%----- �P�Ƒ���(�ŏ����@)
		%------------------------------------------------------------------------------------------------------

		%--- GLONASS�̉q���E���g������
		%--------------------------------------------
		if est_prm.g_nav==1														% GLONASS���g��, �g��
			freq.r1=eph_prm.brd.data(25,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L1 ���g��(GLONASS)
			wave.r1=C ./ freq.r1;												% L2 �g��(GLONASS)
			freq.r2=eph_prm.brd.data(26,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L2 ���g��(GLONASS)
			wave.r2=C ./ freq.r2;												% L2 �g��(GLONASS)
			else
			freq.r1=[]; wave.r1=[];
			freq.r2=[]; wave.r2=[];
		end

		%--- �P�Ƒ���
		%--------------------------------------------
		[x,dtr,dtsv,ion,trop,prn.rovu,rho,dop,ele,azi]=...
				pointpos3(freq,time,prn.rov.v,app_xyz,data,eph_prm,ephi,est_prm,ion_prm,rej);
		if ~isnan(x(1)), app_xyz(1:3)=x(1:3);, end

		%--- �����̕␳
		%--------------------------------------------
		if est_prm.tide==1
			if timetag==1
				tidexyz(timetag,1:3)=tide(x(1:3)',time.mjd);
				x(1:3)=x(1:3)-tidexyz(timetag,1:3)';
			else
				tidexyz(timetag,1:3)=tide(x(1:3)',time.mjd);
				x(1:3)=x(1:3)-(tidexyz(timetag,1:3)-tidexyz(timetag_o,1:3))';
			end
		end

		%--- �^�l����Ƃ����e�������̌덷
		%--------------------------------------------
		est_pos = xyz2enu(x(1:3),est_prm.rovpos)';											% ENU�ɕϊ�

		%--- ���ʊi�[(SPP)
		%--------------------------------------------
		Result.spp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% ����
		Result.spp.pos(timetag,:)=[x(1:3)', xyz2llh(x(1:3)).*[180/pi 180/pi 1]];			% �ʒu
		Result.spp.dtr(timetag,:)=C*dtr;													% ��M�@���v�덷

		%--- �q���i�[
		%--------------------------------------------
		Result.spp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rovu),dop];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rovu), Result.spp.prn{2}(timetag,prn.rovu)=prn.rovu;, end

		%--- OBS�f�[�^,�d���w�x��(�\����)
		%--------------------------------------------
		OBS.rov.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];				% ����
		OBS.rov.ca(timetag,prn.rov.v)   = data(:,2);				% CA
		OBS.rov.py(timetag,prn.rov.v)   = data(:,6);				% PY
		OBS.rov.ph1(timetag,prn.rov.v)  = data(:,1);				% L1
		OBS.rov.ph2(timetag,prn.rov.v)  = data(:,5);				% L2
		OBS.rov.ion(timetag,prn.rov.v)  = ion(:,1);				% Ionosphere
		OBS.rov.trop(timetag,prn.rov.v) = trop(:,1);				% Troposphere

		OBS.rov.ele(timetag,prn.rov.v)  = ele(:,1);				% elevation
		OBS.rov.azi(timetag,prn.rov.v)  = azi(:,1);				% azimuth

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
			dtr_all(timetag,1) = dtr;															% ��M�@���v�덷���i�[
			[data,dtr,time.day,clk_jump,dtr_o,jump_width_all]=...
					clkjump_repair2(time.day,data,dtr,dtr_o,jump_width_all,Rec_type);			% clock jump ���o/�␳
			clk_check(timetag,1) = clk_jump;													% �W�����v�t���O���i�[
		end
		dtr_all(timetag,2) = dtr;															% �␳�ςݎ�M�@���v�덷���i�[

		%--- �␳�ς݊ϑ��ʂ��i�[
		%--------------------------------------------
		OBS.rov.ca_cor(timetag,prn.rov.v)  = data(:,2);				% CA
		OBS.rov.py_cor(timetag,prn.rov.v)  = data(:,6);				% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v) = data(:,1);				% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v) = data(:,5);				% L2

		%--- �e����`����(�␳�ς݊ϑ��ʂ��g�p)
		%--------------------------------------------
		[mp1,mp2,lgl,lgp,lg1,lg2,mw,ionp,ionl] = obs_comb(data);

		%--- �e����`�������i�[
		%--------------------------------------------
% 		LC.rov.mp1(timetag,prn.rov.v)  = mp1;							% Multipath ���`����(L1)
% 		LC.rov.mp2(timetag,prn.rov.v)  = mp2;							% Multipath ���`����(L2)
% 		LC.rov.mw(timetag,prn.rov.v)   = mw;							% Melbourne-Wubbena ���`����
% 		LC.rov.lgl(timetag,prn.rov.v)  = lgl;							% �􉽊w�t���[���`����(�����g)
% 		LC.rov.lgp(timetag,prn.rov.v)  = lgp;							% �􉽊w�t���[���`����(�R�[�h)
% 		LC.rov.lg1(timetag,prn.rov.v)  = lg1;							% �􉽊w�t���[���`����(1���g)
% 		LC.rov.lg2(timetag,prn.rov.v)  = lg2;							% �􉽊w�t���[���`����(2���g)
% 		LC.rov.ionp(timetag,prn.rov.v) = ionp;						% �d���w(lgp����Z�o)
% 		LC.rov.ionl(timetag,prn.rov.v) = ionl;						% �d���w(lgl����Z�o,N���܂�)

		ii=find(ele*180/pi>est_prm.mask);
		LC.rov.mp1(timetag,prn.rov.v(ii))  = mp1(ii);							% Multipath ���`����(L1)
		LC.rov.mp2(timetag,prn.rov.v(ii))  = mp2(ii);							% Multipath ���`����(L2)
		LC.rov.mw(timetag,prn.rov.v(ii))   = mw(ii);							% Melbourne-Wubbena ���`����
		LC.rov.lgl(timetag,prn.rov.v(ii))  = lgl(ii);							% �􉽊w�t���[���`����(�����g)
		LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp(ii);							% �􉽊w�t���[���`����(�R�[�h)
		LC.rov.lg1(timetag,prn.rov.v(ii))  = lg1(ii);							% �􉽊w�t���[���`����(1���g)
		LC.rov.lg2(timetag,prn.rov.v(ii))  = lg2(ii);							% �􉽊w�t���[���`����(2���g)
		LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp(ii);						% �d���w(lgp����Z�o)
		LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl(ii);						% �d���w(lgl����Z�o,N���܂�)

		%------------------------------------------------------------------------------------------------------
		%----- �N���b�N�W�����v�␳ ---->> �I��
		%------------------------------------------------------------------------------------------------------

		%--- �q���ω��`�F�b�N
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.rovu);			% �q���ω��̃`�F�b�N
% 		end

		%--- ��ʕ\��
		%--------------------------------------------
		fprintf('%10.5f %10.5f %10.5f  %3d   PRN:',est_pos(1:3),length(prn.rovu));
		for k=1:length(prn.rovu), fprintf('%4d',prn.rovu(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		fprintf('\n')

		%--- ���ʏ����o��
		%--------------------------------------------
		fprintf(f_sol,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',timetag,time.week,time.tow,time.tod,x(1:3),est_pos);

		prn.o = prn.rovu;
		time_o=time;
		timetag_o=timetag;

% 		if timetag==1
% % 			figure; set(gcf,'doublebuffer','on');
% % 			line([-10 10],[0 0],'Color','k');
% % 			line([0 0],[-10 10],'Color','k');
% 		end
% % 		plot(est_pos(1),est_pos(2),'.');
% % 		plot3(est_pos(1),est_pos(2),est_pos(3),'.');
% 		plot(Result.spp.pos(timetag,5),Result.spp.pos(timetag,4),'.r');
% % 		plot3(Result.spp.pos(timetag,5),Result.spp.pos(timetag,4),Result.spp.pos(timetag,5),'.');
% 		hold on
% 		grid on
% 		box on
% % 		axis square
% 		axis equal
% % 		xlim([-5,5]);
% % 		ylim([-5,5]);
% 		xlabel('Longitude [deg.]');
% 		ylabel('Latitude [deg.]');
% 		drawnow;
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
matname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','OBS','LC');

%--- ���ʌ��ʃv���b�g
%--------------------------------------------
plot_data2([est_prm.dirs.result,matname]);

% %--- KML�o��
% %--------------------------------------------
% kmlname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname],Result.spp,'B','G');
% 
% %--- NMEA�o��
% %--------------------------------------------
% nmeaname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname],Result.spp);
% 
% %--- INS�p
% %--------------------------------------------
% insname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname],Result.spp,est_prm);

fclose('all');
