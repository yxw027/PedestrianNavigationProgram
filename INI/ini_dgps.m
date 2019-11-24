%-----------------------------------------------------------------------------------------
% "�����ݒ�"   DGPS�p		rov:���1 ref:���2
%-----------------------------------------------------------------------------------------

% �f�B���N�g���ݒ�
%--------------------------------------------
est_prm.dirs.obs    = './OBS_NAV/';						% �ϑ��t�@�C���̃f�B���N�g��
est_prm.dirs.ionex  = './IONEX/';						% IONEX�t�@�C���̃f�B���N�g��
est_prm.dirs.sp3    = './SP3/';							% SP3�t�@�C���̃f�B���N�g��
est_prm.dirs.result = './RESULT/DGPS/';					% ���ʃt�@�C���̃f�B���N�g��

% �ϑ������ݒ�
%--------------------------------------------
% �t�@�C���͎����I��DL(�^�l�͎����ݒ�)---�v�C���^�[�l�b�g
est_prm.rcv    ={'950322','950324'};					% �ǔԍ�(rov,ref�̏�) ��: {'950322','950324'}, etc
est_prm.ephsrc = 'igs';									% SP3                 ��: 'igs','cod', etc
est_prm.ionsrc = 'igs';									% IONEX               ��: 'igs','cod', etc
est_prm.stime  = '2007/06/01/00/00/00';					% Start time (��: '2007/01/01/00/00/00')
est_prm.etime  = '2007/06/01/23/59/30';					% End time   (��: '2007/01/01/24/00/00')

% �f�[�^�t�@�C���ݒ�
%--------------------------------------------
% �t�@�C���͎w��(��L�̋ǔԍ��͕K���ݒ肷�邱��, DL����ꍇ�� '' , [] �ɂ��邱��)
est_prm.file.rov_o = '';								% Rov obs    (��: '****.07o')
est_prm.file.rov_n = '';								% Rov nav    (��: '****.07n')
est_prm.file.ref_o = '';								% Ref obs    (��: '****.07o')
est_prm.file.ref_n = '';								% Ref nav    (��: '****.07n')
est_prm.file.ionex  = '';								% IONEX      (��: 'igsg****.07i')
est_prm.file.sp3    = '';								% SP3        (��: 'igs*****.sp3')
est_prm.rovpos      = [];								% Rover Pos  (��: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])
est_prm.refpos      = [];								% Ref Pos    (��: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])

% ���f���ݒ�
%--------------------------------------------
% est_prm.simu      = 0;								% �V�~�����[�V���� [0:OFF, 1:ON]
est_prm.freq      = 2;									% ���g�� [1:L1, 2:L1L2]
est_prm.obsmodel  = 0;									% �ϑ����f�� [0:SPP(CA), 1:SPP(PY), 2:SPP(CA,PY)] �� SPP�p
est_prm.i_mode    = 1;									% �d���w���f�� [1:Klobuchar, 2:GIM]
est_prm.t_mode    = 4;									% �Η������f�� [1:Simple, 2:Magnavox, 3:Colins, 4:Saastamoinen]
est_prm.mapf_trop = 2;									% �Η����}�b�s���O�֐� [1:cosz, 2:Chao, 3:GMF, 4:Marini]
est_prm.mask      = 15;									% �p�}�X�N [deg]
est_prm.clk_flag  = 1;									% clock jump [0:OFF, 1:ON]
est_prm.sp3       = 0;									% ������ [0:OFF, 1:ON]
est_prm.ww        = 1;									% �d�� [0:OFF, 1:ON]
est_prm.iteration = 1;									% �ϑ��X�V�̔�����[default:1]

% �ϑ��G���ݒ�
%--------------------------------------------
est_prm.obsnoise.PR1 = 0.3^2;							% CA�̕��U
est_prm.obsnoise.PR2 = 0.3^2;							% PY�̕��U
est_prm.obsnoise.Ph1 = 0.003^2;							% L1�̕��U
est_prm.obsnoise.Ph2 = 0.003^2;							% L2�̕��U
est_prm.obsnoise.CLK = 2.0^2*1;							% �q�����v�̕��U
est_prm.obsnoise.ION = 4.0^2*1;							% �d���w�̕��U
est_prm.obsnoise.TRP = 0.7^2*1;							% �Η����̕��U
est_prm.obsnoise.ORB = 2.0^2/3*1;						% �q���O���̕��U

% ��ԃ��f��
%--------------------------------------------
est_prm.statemodel.pos  = 0;							% ��ԃ��f��(Position)    [0:static, 1:velocity, 2:acceleration, 3:jerk]
est_prm.statemodel.ion  = 0;							% ��ԃ��f��(Ionosphere)  [0:OFF, 1:DD, 2:SD, 3:SD(Zenith), 4:ZID, 5:ZID+dZID]
est_prm.statemodel.trop = 0;							% ��ԃ��f��(Troposphere) [0:OFF, 1:ZWD, 2:ZTD] ON�̏ꍇ, �Η������f���� 4 �ɐݒ肷�邱��

est_prm.statemodel.alpha_u = 1;							% �ʒu
est_prm.statemodel.alpha_v = 1.01;						% ���萔�̋t�� ���x
est_prm.statemodel.alpha_a = 1.01;						% ���萔�̋t�� �����x
est_prm.statemodel.alpha_j = 1.01;						% ���萔�̋t�� ���x
est_prm.statemodel.alpha_i = 1;							% Ionosphere
est_prm.statemodel.alpha_T = 1;							% Troposphere

est_prm.statemodel.std_dev_u = 0;						% �ʒu
est_prm.statemodel.std_dev_v = 1e-0*1;					% ���x
est_prm.statemodel.std_dev_a = 1e-2*1;					% �����x
est_prm.statemodel.std_dev_j = 1e-4*1;					% ���x
est_prm.statemodel.std_dev_i = 1e-3;					% Ionosphere
est_prm.statemodel.std_dev_T = 1e-5;					% Troposphere

% ��ԕϐ��̏������U
%--------------------------------------------
est_prm.P0.std_dev_p = [10,10,10];						% ��M�@���W(X,Y,Z)
est_prm.P0.std_dev_v = [1,1,1];							% ��M�@���x(X,Y,Z)
est_prm.P0.std_dev_a = [1,1,1];							% ��M�@�����x(X,Y,Z)
est_prm.P0.std_dev_j = [1,1,1];							% ��M�@���x(X,Y,Z)
est_prm.P0.std_dev_i = [1.0];							% Ionosphere
est_prm.P0.std_dev_T = [0.3];							% Troposphere

%-----------------------------------------------------------------------------------------
% "�����ݒ�" ---->> �I��
%-----------------------------------------------------------------------------------------
