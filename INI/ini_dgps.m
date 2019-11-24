%-----------------------------------------------------------------------------------------
% "初期設定"   DGPS用		rov:大津1 ref:大津2
%-----------------------------------------------------------------------------------------

% ディレクトリ設定
%--------------------------------------------
est_prm.dirs.obs    = './OBS_NAV/';						% 観測ファイルのディレクトリ
est_prm.dirs.ionex  = './IONEX/';						% IONEXファイルのディレクトリ
est_prm.dirs.sp3    = './SP3/';							% SP3ファイルのディレクトリ
est_prm.dirs.result = './RESULT/DGPS/';					% 結果ファイルのディレクトリ

% 観測条件設定
%--------------------------------------------
% ファイルは自動的にDL(真値は自動設定)---要インターネット
est_prm.rcv    ={'950322','950324'};					% 局番号(rov,refの順) 例: {'950322','950324'}, etc
est_prm.ephsrc = 'igs';									% SP3                 例: 'igs','cod', etc
est_prm.ionsrc = 'igs';									% IONEX               例: 'igs','cod', etc
est_prm.stime  = '2007/06/01/00/00/00';					% Start time (例: '2007/01/01/00/00/00')
est_prm.etime  = '2007/06/01/23/59/30';					% End time   (例: '2007/01/01/24/00/00')

% データファイル設定
%--------------------------------------------
% ファイルは指定(上記の局番号は必ず設定すること, DLする場合は '' , [] にすること)
est_prm.file.rov_o = '';								% Rov obs    (例: '****.07o')
est_prm.file.rov_n = '';								% Rov nav    (例: '****.07n')
est_prm.file.ref_o = '';								% Ref obs    (例: '****.07o')
est_prm.file.ref_n = '';								% Ref nav    (例: '****.07n')
est_prm.file.ionex  = '';								% IONEX      (例: 'igsg****.07i')
est_prm.file.sp3    = '';								% SP3        (例: 'igs*****.sp3')
est_prm.rovpos      = [];								% Rover Pos  (例: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])
est_prm.refpos      = [];								% Ref Pos    (例: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])

% モデル設定
%--------------------------------------------
% est_prm.simu      = 0;								% シミュレーション [0:OFF, 1:ON]
est_prm.freq      = 2;									% 周波数 [1:L1, 2:L1L2]
est_prm.obsmodel  = 0;									% 観測モデル [0:SPP(CA), 1:SPP(PY), 2:SPP(CA,PY)] ← SPP用
est_prm.i_mode    = 1;									% 電離層モデル [1:Klobuchar, 2:GIM]
est_prm.t_mode    = 4;									% 対流圏モデル [1:Simple, 2:Magnavox, 3:Colins, 4:Saastamoinen]
est_prm.mapf_trop = 2;									% 対流圏マッピング関数 [1:cosz, 2:Chao, 3:GMF, 4:Marini]
est_prm.mask      = 15;									% 仰角マスク [deg]
est_prm.clk_flag  = 1;									% clock jump [0:OFF, 1:ON]
est_prm.sp3       = 0;									% 精密暦 [0:OFF, 1:ON]
est_prm.ww        = 1;									% 重み [0:OFF, 1:ON]
est_prm.iteration = 1;									% 観測更新の反復回数[default:1]

% 観測雑音設定
%--------------------------------------------
est_prm.obsnoise.PR1 = 0.3^2;							% CAの分散
est_prm.obsnoise.PR2 = 0.3^2;							% PYの分散
est_prm.obsnoise.Ph1 = 0.003^2;							% L1の分散
est_prm.obsnoise.Ph2 = 0.003^2;							% L2の分散
est_prm.obsnoise.CLK = 2.0^2*1;							% 衛星時計の分散
est_prm.obsnoise.ION = 4.0^2*1;							% 電離層の分散
est_prm.obsnoise.TRP = 0.7^2*1;							% 対流圏の分散
est_prm.obsnoise.ORB = 2.0^2/3*1;						% 衛星軌道の分散

% 状態モデル
%--------------------------------------------
est_prm.statemodel.pos  = 0;							% 状態モデル(Position)    [0:static, 1:velocity, 2:acceleration, 3:jerk]
est_prm.statemodel.ion  = 0;							% 状態モデル(Ionosphere)  [0:OFF, 1:DD, 2:SD, 3:SD(Zenith), 4:ZID, 5:ZID+dZID]
est_prm.statemodel.trop = 0;							% 状態モデル(Troposphere) [0:OFF, 1:ZWD, 2:ZTD] ONの場合, 対流圏モデルは 4 に設定すること

est_prm.statemodel.alpha_u = 1;							% 位置
est_prm.statemodel.alpha_v = 1.01;						% 時定数の逆数 速度
est_prm.statemodel.alpha_a = 1.01;						% 時定数の逆数 加速度
est_prm.statemodel.alpha_j = 1.01;						% 時定数の逆数 躍度
est_prm.statemodel.alpha_i = 1;							% Ionosphere
est_prm.statemodel.alpha_T = 1;							% Troposphere

est_prm.statemodel.std_dev_u = 0;						% 位置
est_prm.statemodel.std_dev_v = 1e-0*1;					% 速度
est_prm.statemodel.std_dev_a = 1e-2*1;					% 加速度
est_prm.statemodel.std_dev_j = 1e-4*1;					% 躍度
est_prm.statemodel.std_dev_i = 1e-3;					% Ionosphere
est_prm.statemodel.std_dev_T = 1e-5;					% Troposphere

% 状態変数の初期分散
%--------------------------------------------
est_prm.P0.std_dev_p = [10,10,10];						% 受信機座標(X,Y,Z)
est_prm.P0.std_dev_v = [1,1,1];							% 受信機速度(X,Y,Z)
est_prm.P0.std_dev_a = [1,1,1];							% 受信機加速度(X,Y,Z)
est_prm.P0.std_dev_j = [1,1,1];							% 受信機躍度(X,Y,Z)
est_prm.P0.std_dev_i = [1.0];							% Ionosphere
est_prm.P0.std_dev_T = [0.3];							% Troposphere

%-----------------------------------------------------------------------------------------
% "初期設定" ---->> 終了
%-----------------------------------------------------------------------------------------
