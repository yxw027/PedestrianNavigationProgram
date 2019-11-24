%-----------------------------------------------------------------------------------------
% "�����ݒ�"   ���Α��ʗp		rov:���1 ref:���2
%-----------------------------------------------------------------------------------------

% �f�B���N�g���ݒ�
%--------------------------------------------
est_prm.dirs.obs    = './OBS_NAV/';						% �ϑ��t�@�C���̃f�B���N�g��
est_prm.dirs.ionex  = './IONEX/';						% IONEX�t�@�C���̃f�B���N�g��
est_prm.dirs.sp3    = './SP3/';							% SP3�t�@�C���̃f�B���N�g��
est_prm.dirs.result = './RESULT/Relative/';				% ���ʃt�@�C���̃f�B���N�g��

% �ϑ������ݒ�
%--------------------------------------------
% �t�@�C���͎����I��DL(�^�l�͎����ݒ�)---�v�C���^�[�l�b�g
est_prm.rcv    ={'rov_rtk','ref_rtk'};					% �ǔԍ�(rov,ref�̏�) ��: {'950322','950324'}, etc
est_prm.ephsrc = 'igs';									% SP3                 ��: 'igs','cod', etc
est_prm.ionsrc = 'igs';									% IONEX               ��: 'igs','cod', etc
est_prm.stime  = '2002/06/06/05/15/20';					% Start time (��: '2007/01/01/00/00/00')
est_prm.etime  = '2002/06/06/05/23/20';					% End time   (��: '2007/01/01/24/00/00')

% �f�[�^�t�@�C���ݒ�
%--------------------------------------------
% �t�@�C���͎w��(��L�̋ǔԍ��͕K���ݒ肷�邱��, DL����ꍇ�� '' , [] �ɂ��邱��)
est_prm.file.rov_o  = '020606_rov_mod.02o';								% Rov obs    (��: '****.07o')
est_prm.file.rov_n  = '020606_rov_mod.02n';								% Rov nav    (��: '****.07n')
est_prm.file.refobs = '020606_ref.02o';								% Ref obs    (��: '****.07o')
est_prm.file.refnav = '020606_ref.02n';								% Ref nav    (��: '****.07n')
est_prm.file.ionex  = '';								% IONEX      (��: 'igsg****.07i')
est_prm.file.sp3    = '';								% SP3        (��: 'igs*****.sp3')
est_prm.rovpos      = [-3761137.645;3636645.777;3636348.138];								% Rover Pos  (��: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])
est_prm.refpos      = [-3761137.645;3636645.777;3636348.138];								% Ref Pos    (��: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])
est_prm.file.lambda = 'lamlogfile.log';					% LAMBDA log

% ���f���ݒ�
%--------------------------------------------
% est_prm.simu      = 0;								% �V�~�����[�V���� [0:OFF, 1:ON]
est_prm.freq      = 2;									% ���g�� [1:L1, 2:L1L2]
est_prm.pr_flag   = 1;									% �[���������p [0:OFF, 1:ON]
est_prm.obsmodel  = 0;									% �ϑ����f�� [0:SPP(CA), 1:SPP(PY), 2:SPP(CA,PY)] �� SPP�p
est_prm.i_mode    = 1;									% �d���w���f�� [1:Klobuchar, 2:GIM]
est_prm.t_mode    = 4;									% �Η������f�� [1:Simple, 2:Magnavox, 3:Colins, 4:Saastamoinen]
est_prm.mapf_trop = 2;									% �Η����}�b�s���O�֐� [1:cosz, 2:Chao, 3:GMF, 4:Marini]
est_prm.mask      = 15;									% �p�}�X�N [deg]
est_prm.clk_flag  = 1;									% clock jump [0:OFF, 1:ON]
est_prm.sp3       = 0;									% ������ [0:OFF, 1:ON]
est_prm.ww        = 1;									% �d�� [0:OFF, 1:ON]
est_prm.iteration = 1;									% �ϑ��X�V�̔�����[default:1]

est_prm.ambr      = 1;									% ambiguity resolution [0:round, 1:lambda, 2:mlambda(by Takasu)]
est_prm.ambv      = 2;									% ambiguity validation [0:no, 1:ratio, 2:likelihood, 3:ratio+likelihood]
est_prm.ambt      = 3;									% ambiguity validation threshold [default:3]
est_prm.ambf      = 0;									% ambiguity fixed flag [0:no, 1:fixed, 2:constraint]
est_prm.ambc      = 3;									% count of same ambiguity [default:3-5]

est_prm.ambs      = 0;									% screening method for ambiguity resolution [0:none, 1:elevation, 2:count, 3:cov]
est_prm.ambse     = 20;									% elevation mask(screening method=1) [deg]
est_prm.ambsc     = 20;									% epoch count   (screening method=2) [epoch]
est_prm.ambsp     = 0.1;								% covariance    (screening method=3) [m^2]

% �ϑ��G���ݒ�
%--------------------------------------------
est_prm.obsnoise.PR1 = 0.21;							% CA�̕��U
est_prm.obsnoise.PR2 = 0.21;							% PY�̕��U
est_prm.obsnoise.Ph1 = 0.02^2;							% L1�̕��U
est_prm.obsnoise.Ph2 = 0.02^2;							% L2�̕��U
est_prm.obsnoise.CLK = 2.0^2*1;							% �q�����v�̕��U
est_prm.obsnoise.ION = 4.0^2*1;							% �d���w�̕��U
est_prm.obsnoise.TRP = 0.7^2*1;							% �Η����̕��U
est_prm.obsnoise.ORB = 2.0^2/3*1;						% �q���O���̕��U

% ��ԃ��f��
%--------------------------------------------
est_prm.statemodel.pos  = 0;							% ��ԃ��f��(Position)    [0:static, 1:velocity, 2:acceleration, 3:jerk]
est_prm.statemodel.ion  = 0;							% ��ԃ��f��(Ionosphere)  [0:OFF, 1:DD, 2:SD, 3:SD(Zenith), 4:ZID, 5:ZID+dZID]
est_prm.statemodel.trop = 2;							% ��ԃ��f��(Troposphere) [0:OFF, 1:ZWD, 2:ZTD] ON�̏ꍇ, �Η������f���� 4 �ɐݒ肷�邱��
est_prm.statemodel.amb  = 1;							% ��ԃ��f��(Ambiguity)   [0:OFF, 1:ON]

est_prm.statemodel.alpha_u = 1;							% �ʒu
est_prm.statemodel.alpha_v = 1.01;						% ���萔�̋t�� ���x
est_prm.statemodel.alpha_a = 1.01;						% ���萔�̋t�� �����x
est_prm.statemodel.alpha_j = 1.01;						% ���萔�̋t�� ���x
est_prm.statemodel.alpha_i = 1;							% Ionosphere
est_prm.statemodel.alpha_T = 1;							% Troposphere
est_prm.statemodel.alpha_n = 1;							% �����l�o�C�A�X

est_prm.statemodel.std_dev_u = 0;						% �ʒu
est_prm.statemodel.std_dev_v = 1e-0*1;					% ���x
est_prm.statemodel.std_dev_a = 1e-2*1;					% �����x
est_prm.statemodel.std_dev_j = 1e-4*1;					% ���x
est_prm.statemodel.std_dev_i = 1e-3;					% Ionosphere
est_prm.statemodel.std_dev_T = 1e-4;					% Troposphere
est_prm.statemodel.std_dev_n = 0;						% �����l�o�C�A�X

% ��ԕϐ��̏������U
%--------------------------------------------
est_prm.P0.std_dev_p = [10,10,10];						% ��M�@���W(X,Y,Z)
est_prm.P0.std_dev_v = [1,1,1];							% ��M�@���x(X,Y,Z)
est_prm.P0.std_dev_a = [1,1,1];							% ��M�@�����x(X,Y,Z)
est_prm.P0.std_dev_j = [1,1,1];							% ��M�@���x(X,Y,Z)
est_prm.P0.std_dev_i = [1.0];							% Ionosphere
est_prm.P0.std_dev_T = [0.3];							% Troposphere
est_prm.P0.std_dev_n = [10];							% �����l�o�C�A�X

%-----------------------------------------------------------------------------------------
% "�����ݒ�" ---->> �I��
%-----------------------------------------------------------------------------------------
