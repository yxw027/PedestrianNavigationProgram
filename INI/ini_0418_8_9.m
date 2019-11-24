%-----------------------------------------------------------------------------------------
% "�����ݒ�"   PPP�p		rov:BKC����g���b�N(�V�l�J�[�g)
%-----------------------------------------------------------------------------------------

% �f�B���N�g���ݒ�
%--------------------------------------------
est_prm.dirs.obs    = './OBS_NAV/';						% �ϑ��t�@�C���̃f�B���N�g��
est_prm.dirs.ionex  = './IONEX/';						% IONEX�t�@�C���̃f�B���N�g��
est_prm.dirs.sp3    = './SP3/';							% SP3�t�@�C���̃f�B���N�g��
est_prm.dirs.result = './RESULT/PPP/';					% ���ʃt�@�C���̃f�B���N�g��

% �ϑ������ݒ�
%--------------------------------------------
% �t�@�C���͎����I��DL(�^�l�͎����ݒ�)---�v�C���^�[�l�b�g
est_prm.rcv    ={'AndroidOBS'};								% �ǔԍ�(rov) ��: {'950322'}, etc
est_prm.ephsrc = 'igu';									% SP3         ��: 'igs','cod', etc
est_prm.ionsrc = 'c2p';									% IONEX       ��: 'igs','cod', etc
est_prm.stime  = '2018/4/18/08/09/54';					% Start time (��: '2007/01/01/00/00/00')
est_prm.etime  = '2018/4/18/08/11/03';					% End time   (��: '2007/01/01/24/00/00')

% �f�[�^�t�@�C���ݒ�
%--------------------------------------------
% �t�@�C���͎w��(��L�̋ǔԍ��͕K���ݒ肷�邱��, DL����ꍇ�� '' , [] �ɂ��邱��)
est_prm.file.rov_o = '2018_4_18_8_9.18o';			% Rov obs             (��: '****.07o')
est_prm.file.rov_n = 'brdc1080.18n';			% Rov nav(GPS)        (��: '****.07n')
est_prm.file.csv = '2018_4_18_8_9.csv';
est_prm.file.rov_g = '';								% Rov nav(GLONASS)    (��: '****.07g')
est_prm.file.ionex = 'c2pg3570.16i';								% IONEX      (��: 'igsg****.07i')
est_prm.file.sp3   = 'igu19284_12.sp3';								% SP3        (��: 'igs*****.sp3')
est_prm.rovpos     = [-3.761063499E+06;  3.636647578E+06;  3.636362767E+06];			% Rover Pos  (��: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])
% �����̏����l
est_prm.steplength = 1;

% ���f���ݒ�
%--------------------------------------------
% est_prm.simu      = 0;								% �V�~�����[�V���� [0:OFF, 1:ON]
est_prm.freq      = 1;									% ���g�� [1:L1, 2:L1L2]
est_prm.n_nav     = 1;									% �G�t�F�����X(GPS) [0:OFF, 1:ON]
est_prm.g_nav     = 0;									% �G�t�F�����X(GLONASS) [0:OFF, 1:ON]
est_prm.obsmodel  = 0;									% �ϑ����f�� [0:SPP(CA), 1:SPP(PY), 2:SPP(CA,PY), 3:GR(CA,L1), 4:UoC(CA,L1), 5:Trad(L1,L2), 6:GR(CA,PY,L1,L2), 7:UoC(CA,PY,L1,L2), 8:Trad(CA,PY,L1,L2), 9:GR(CA,L1,L2), 10:HWM(CA)]
est_prm.i_mode    = 1;									% �d���w���f�� [1:Klobuchar, 2:GIM]
est_prm.t_mode    = 4;									% �Η������f�� [1:Simple, 2:Magnavox, 3:Colins, 4:Saastamoinen, 5:IGS_trop]
est_prm.cs_mode   = 0;									% �T�C�N���X���b�v���o���@ [0:OFF, 1:�J���}����2����, 2:���`����(�W���΍��ɂ�錟�o), 3:���`������2����, 4:���`������2����(�����G�|�b�N)]
est_prm.tide      = 0;									% �n���ő̒����ɂ��␳ [0:OFF, 1:ON]
est_prm.mapf_trop = 3;									% �Η����}�b�s���O�֐� [1:cosz, 2:Chao, 3:GMF, 4:Marini]
est_prm.mask      = 30;									% �p�}�X�N [deg]
est_prm.clk_flag  = 1;									% clock jump [0:OFF, 1:ON]
est_prm.sp3       = 0;									% ������ [0:OFF, 1:ON]
est_prm.ww        = 1;									% �d�� [0:OFF, 1:ON]
est_prm.iteration = 1;									% �ϑ��X�V�̔�����[default:1]
est_prm.sensormixmode =1;                              % �Z���T�[�������[�h[1:�J���}���t�B���^�̏�Ԑ���� 2:�J���}���t�B���^�̊ϑ��ʂ�]
est_prm.useconststep = 0;                               % �����ɂ��J���}���t�B���^��K�p���邩�ۂ�

% �ϑ��G���ݒ�
%--------------------------------------------
est_prm.obsnoise.PR1 = 0.5^2;							% CA�̕��U
est_prm.obsnoise.PR2 = 0.5^2;							% PY�̕��U
est_prm.obsnoise.Ph1 = 0.003^2;							% L1�̕��U
est_prm.obsnoise.Ph2 = 0.003^2;							% L2�̕��U
est_prm.obsnoise.CLK = 2.0^2*1;							% �q�����v�̕��U
est_prm.obsnoise.ION = 4.0^2*1;							% �d���w�̕��U
est_prm.obsnoise.TRP = 0.7^2*1;							% �Η����̕��U
est_prm.obsnoise.ORB = 2.0^2/3*1;						% �q���O���̕��U

% est_prm.obsnoise.CLK = 0.03^2*1;						% �q�����v�̕��U
% est_prm.obsnoise.ION = 0.5^2*1;							% �d���w�̕��U
% est_prm.obsnoise.TRP = 0.1^2*1;							% �Η����̕��U
% est_prm.obsnoise.ORB = 0.05^2/3*1;						% �q���O���̕��U

%est_prm.obsnoise.WARKING = 0.3^2;                       %�����̕��U

% ��ԃ��f��
%--------------------------------------------
est_prm.statemodel.pos  = 1;							% ��ԃ��f��(Position)    [0:static, 1:velocity, 2:accelelation, 3:jerk, 4:walking]
est_prm.statemodel.dt   = 1;							% ��ԃ��f��(��M�@���v)  [0:dtr, 1:dtr_dot]
est_prm.statemodel.hw   = 0;							% ��ԃ��f��(Rec.HWB)     [0:OFF, 1:ON] ON�̏ꍇ, obsmodel�� 3,6,9 �ɐݒ肷�邱��
est_prm.statemodel.ion  = 0;							% ��ԃ��f��(Ionosphere)  [0:OFF, 1:ZID, 2:ZID+dZID, 3:ZID+Grad]
est_prm.statemodel.trop = 0;							% ��ԃ��f��(Troposphere) [0:OFF, 1:ZWD, 2:ZTD, 3:ZWD+Grad, 4:ZTD+Grad] ON�̏ꍇ, �Η������f���� 4 �ɐݒ肷�邱��
est_prm.statemodel.amb  = 1;							% ��ԃ��f��(Ambiguity)   [0:OFF, 1:ON]
%210
est_prm.statemodel.alpha_u = 1;							% �ʒu
est_prm.statemodel.alpha_v = 1.01;						% ���萔�̋t�� ���x
est_prm.statemodel.alpha_a = 1.01;						% ���萔�̋t�� �����x
est_prm.statemodel.alpha_j = 1.01;						% ���萔�̋t�� ���x
est_prm.statemodel.alpha_t = 0.99;						% ��M�@���v�덷
est_prm.statemodel.alpha_i = 1;							% Ionosphere
est_prm.statemodel.alpha_T = 1;							% Troposphere
est_prm.statemodel.alpha_n = 1;							% �����l�o�C�A�X
est_prm.statemodel.alpha_b = 0.99;						% ��M�@�n�[�h�E�F�A�o�C�A�X

est_prm.statemodel.std_dev_u = 0.18;						% �ʒu
est_prm.statemodel.std_dev_vx = 0.18;					% ���x %STATE�p
est_prm.statemodel.std_dev_vy = 0.18;					% ���x %STATE�p
est_prm.statemodel.std_dev_vz = 0.05;                   % ���x %STATE�p
%est_prm.statemodel.std_dev_vx = 0.33;                    % ���x %OBS�p
%est_prm.statemodel.std_dev_vy = 0.33;                    % ���x %OBS�p
%est_prm.statemodel.std_dev_vz = 0.33;                    % ���x %OBS�p
%est_prm.statemodel.sensorbias = 1;
est_prm.statemodel.std_dev_a = 0.1;					% �����x
est_prm.statemodel.std_dev_j = 1e-4*1;					% ���x
est_prm.statemodel.std_dev_t = 2e+1;					% ��M�@���v�덷
est_prm.statemodel.std_dev_i = 1e-3;					% Ionosphere
est_prm.statemodel.std_dev_T = 1e-4;					% Troposphere
est_prm.statemodel.std_dev_n = 0;						% �����l�o�C�A�X
est_prm.statemodel.std_dev_b = 1e-3;					% ��M�@�n�[�h�E�F�A�o�C�A�X
est_prm.statemodel.std_walking = 0.01;               %%����

% ��ԕϐ��̏������U
%--------------------------------------------
est_prm.P0.std_dev_p = [5,5,5];						% ��M�@���W(X,Y,Z)
est_prm.P0.std_dev_v = [0.1,0.1,0.1];							% ��M�@���x(X,Y,Z)
est_prm.P0.std_dev_a = [0.1,0.1,0.1];							% ��M�@�����x(X,Y,Z)
est_prm.P0.std_dev_j = [1,1,1];							% ��M�@���x(X,Y,Z)
est_prm.P0.std_dev_t = [0,0];							% ��M�@���v�덷(dtr,dtr_dot)
est_prm.P0.std_dev_b = [1,1,1,1];						% ��M�@�n�[�h�E�F�A�o�C�A�X(CA,PY,L1,L2)
est_prm.P0.std_dev_i = [0.5,0.01,0.01];					% Ionosphere
est_prm.P0.std_dev_T = [0.1,0.01,0.01];					% Troposphere
est_prm.P0.std_dev_n = [10];							% �����l�o�C�A�X
est_prm.P0.std_walking = 0.01;                     % ����[E����, N����]

% �T�C�N���X���b�v�ݒ�
%--------------------------------------------
est_prm.cycle_slip.LC = [0];							% �g�p������`���� [0:GF, 1:MW, 2:MP1, 3:MP2] (��:[0 2])
est_prm.cycle_slip.rej_flag = 0;						% ���`�����ɂ��T�C�N���X���b�v���o��̏��� [0:�q�����O�̂�, 1:�ϑ��ʏC��(�s�̏ꍇ�͉q�����O)]���܂��g���Ȃ�

est_prm.cycle_slip.lc_b    = 1;							% ���`���������G�|�b�N�ɂ�錟��̍ő厩�R�x(�ő�g�p�G�|�b�N��)
est_prm.cycle_slip.lgl_ion = 1;							% �􉽊w�t���[���`�����̓d���w�x���l�� [0:OFF, 1:ON]
est_prm.cycle_slip.sd      = 5;							% ���`����臒l�̕W���΍��{�� (�ʏ�3-5)
est_prm.cycle_slip.lc_int  = 20;						% ���`����臒l�̌���v�f�͈� [epoch]

est_prm.cycle_slip.A.a_mp1 = 0.001;						% ���`������2����̊댯��(MP1)
est_prm.cycle_slip.A.a_mp2 = 0.001;						% ���`������2����̊댯��(MP2)
est_prm.cycle_slip.A.a_mw  = 0.001;						% ���`������2����̊댯��(MW)
est_prm.cycle_slip.A.a_lgl = 0.001;						% ���`������2����̊댯��(GF)
est_prm.cycle_slip.A.b_mp1 = 0.1;						% ���`������2����ɂ��C���l����̊댯��(MP1)
est_prm.cycle_slip.A.b_mp2 = 0.1;						% ���`������2����ɂ��C���l����̊댯��(MP2)
est_prm.cycle_slip.A.b_mw  = 0.1;						% ���`������2����ɂ��C���l����̊댯��(MW)
est_prm.cycle_slip.A.b_lgl = 0.1;						% ���`������2����ɂ��C���l����̊댯��(GF)

est_prm.cycle_slip.timel   = 60;						% �T�C�N���X���b�v�������� [epoch]
est_prm.cycle_slip.timei   = 120;						% �T�C�N���X���b�v�����Ԋu [epoch]
est_prm.cycle_slip.stime   = 1440;						% �T�C�N���X���b�v�����J�n [epoch]
est_prm.cycle_slip.etime   = 2880;						% �T�C�N���X���b�v�����I�� [epoch]
est_prm.cycle_slip.slip_l1 = 50;						% L1 �X���b�v��[cycle]
est_prm.cycle_slip.slip_l2 = 10;						% L2 �X���b�v��[cycle]
est_prm.cycle_slip.prn     = [];						% �T�C�N���X���b�v�����q���ԍ� (��:[16 25] ,���������Ȃ��ꍇ��[])

%-----------------------------------------------------------------------------------------
% "�����ݒ�" ---->> �I��
%--------------------------------------------------------------------------
%---------------