%-----------------------------------------------------------------------------------------
% "初期設定"   PPP用		rov:BKC陸上トラック(老人カート)
%-----------------------------------------------------------------------------------------

% ディレクトリ設定
%--------------------------------------------
est_prm.dirs.obs    = './OBS_NAV/';						% 観測ファイルのディレクトリ
est_prm.dirs.ionex  = './IONEX/';						% IONEXファイルのディレクトリ
est_prm.dirs.sp3    = './SP3/';							% SP3ファイルのディレクトリ
est_prm.dirs.result = './RESULT/PPP/';					% 結果ファイルのディレクトリ

% 観測条件設定
%--------------------------------------------
% ファイルは自動的にDL(真値は自動設定)---要インターネット
est_prm.rcv    ={'AndroidOBS'};								% 局番号(rov) 例: {'950322'}, etc
est_prm.ephsrc = 'igu';									% SP3         例: 'igs','cod', etc
est_prm.ionsrc = 'c2p';									% IONEX       例: 'igs','cod', etc
est_prm.stime  = '2018/4/18/08/09/54';					% Start time (例: '2007/01/01/00/00/00')
est_prm.etime  = '2018/4/18/08/11/03';					% End time   (例: '2007/01/01/24/00/00')

% データファイル設定
%--------------------------------------------
% ファイルは指定(上記の局番号は必ず設定すること, DLする場合は '' , [] にすること)
est_prm.file.rov_o = '2018_4_18_8_9.18o';			% Rov obs             (例: '****.07o')
est_prm.file.rov_n = 'brdc1080.18n';			% Rov nav(GPS)        (例: '****.07n')
est_prm.file.csv = '2018_4_18_8_9.csv';
est_prm.file.rov_g = '';								% Rov nav(GLONASS)    (例: '****.07g')
est_prm.file.ionex = 'c2pg3570.16i';								% IONEX      (例: 'igsg****.07i')
est_prm.file.sp3   = 'igu19284_12.sp3';								% SP3        (例: 'igs*****.sp3')
est_prm.rovpos     = [-3.761063499E+06;  3.636647578E+06;  3.636362767E+06];			% Rover Pos  (例: [-3.7481114801E+06;  3.6358775482E+06;  3.6504372263E+06])
% 歩幅の初期値
est_prm.steplength = 1;

% モデル設定
%--------------------------------------------
% est_prm.simu      = 0;								% シミュレーション [0:OFF, 1:ON]
est_prm.freq      = 1;									% 周波数 [1:L1, 2:L1L2]
est_prm.n_nav     = 1;									% エフェメリス(GPS) [0:OFF, 1:ON]
est_prm.g_nav     = 0;									% エフェメリス(GLONASS) [0:OFF, 1:ON]
est_prm.obsmodel  = 0;									% 観測モデル [0:SPP(CA), 1:SPP(PY), 2:SPP(CA,PY), 3:GR(CA,L1), 4:UoC(CA,L1), 5:Trad(L1,L2), 6:GR(CA,PY,L1,L2), 7:UoC(CA,PY,L1,L2), 8:Trad(CA,PY,L1,L2), 9:GR(CA,L1,L2), 10:HWM(CA)]
est_prm.i_mode    = 1;									% 電離層モデル [1:Klobuchar, 2:GIM]
est_prm.t_mode    = 4;									% 対流圏モデル [1:Simple, 2:Magnavox, 3:Colins, 4:Saastamoinen, 5:IGS_trop]
est_prm.cs_mode   = 0;									% サイクルスリップ検出方法 [0:OFF, 1:カルマンχ2検定, 2:線形結合(標準偏差による検出), 3:線形結合χ2検定, 4:線形結合χ2検定(複数エポック)]
est_prm.tide      = 0;									% 地球固体潮汐による補正 [0:OFF, 1:ON]
est_prm.mapf_trop = 3;									% 対流圏マッピング関数 [1:cosz, 2:Chao, 3:GMF, 4:Marini]
est_prm.mask      = 30;									% 仰角マスク [deg]
est_prm.clk_flag  = 1;									% clock jump [0:OFF, 1:ON]
est_prm.sp3       = 0;									% 精密暦 [0:OFF, 1:ON]
est_prm.ww        = 1;									% 重み [0:OFF, 1:ON]
est_prm.iteration = 1;									% 観測更新の反復回数[default:1]
est_prm.sensormixmode =1;                              % センサー統合モード[1:カルマンフィルタの状態推定へ 2:カルマンフィルタの観測量へ]
est_prm.useconststep = 0;                               % 歩幅にもカルマンフィルタを適用するか否か

% 観測雑音設定
%--------------------------------------------
est_prm.obsnoise.PR1 = 0.5^2;							% CAの分散
est_prm.obsnoise.PR2 = 0.5^2;							% PYの分散
est_prm.obsnoise.Ph1 = 0.003^2;							% L1の分散
est_prm.obsnoise.Ph2 = 0.003^2;							% L2の分散
est_prm.obsnoise.CLK = 2.0^2*1;							% 衛星時計の分散
est_prm.obsnoise.ION = 4.0^2*1;							% 電離層の分散
est_prm.obsnoise.TRP = 0.7^2*1;							% 対流圏の分散
est_prm.obsnoise.ORB = 2.0^2/3*1;						% 衛星軌道の分散

% est_prm.obsnoise.CLK = 0.03^2*1;						% 衛星時計の分散
% est_prm.obsnoise.ION = 0.5^2*1;							% 電離層の分散
% est_prm.obsnoise.TRP = 0.1^2*1;							% 対流圏の分散
% est_prm.obsnoise.ORB = 0.05^2/3*1;						% 衛星軌道の分散

%est_prm.obsnoise.WARKING = 0.3^2;                       %歩幅の分散

% 状態モデル
%--------------------------------------------
est_prm.statemodel.pos  = 1;							% 状態モデル(Position)    [0:static, 1:velocity, 2:accelelation, 3:jerk, 4:walking]
est_prm.statemodel.dt   = 1;							% 状態モデル(受信機時計)  [0:dtr, 1:dtr_dot]
est_prm.statemodel.hw   = 0;							% 状態モデル(Rec.HWB)     [0:OFF, 1:ON] ONの場合, obsmodelは 3,6,9 に設定すること
est_prm.statemodel.ion  = 0;							% 状態モデル(Ionosphere)  [0:OFF, 1:ZID, 2:ZID+dZID, 3:ZID+Grad]
est_prm.statemodel.trop = 0;							% 状態モデル(Troposphere) [0:OFF, 1:ZWD, 2:ZTD, 3:ZWD+Grad, 4:ZTD+Grad] ONの場合, 対流圏モデルは 4 に設定すること
est_prm.statemodel.amb  = 1;							% 状態モデル(Ambiguity)   [0:OFF, 1:ON]
%210
est_prm.statemodel.alpha_u = 1;							% 位置
est_prm.statemodel.alpha_v = 1.01;						% 時定数の逆数 速度
est_prm.statemodel.alpha_a = 1.01;						% 時定数の逆数 加速度
est_prm.statemodel.alpha_j = 1.01;						% 時定数の逆数 躍度
est_prm.statemodel.alpha_t = 0.99;						% 受信機時計誤差
est_prm.statemodel.alpha_i = 1;							% Ionosphere
est_prm.statemodel.alpha_T = 1;							% Troposphere
est_prm.statemodel.alpha_n = 1;							% 整数値バイアス
est_prm.statemodel.alpha_b = 0.99;						% 受信機ハードウェアバイアス

est_prm.statemodel.std_dev_u = 0.18;						% 位置
est_prm.statemodel.std_dev_vx = 0.18;					% 速度 %STATE用
est_prm.statemodel.std_dev_vy = 0.18;					% 速度 %STATE用
est_prm.statemodel.std_dev_vz = 0.05;                   % 速度 %STATE用
%est_prm.statemodel.std_dev_vx = 0.33;                    % 速度 %OBS用
%est_prm.statemodel.std_dev_vy = 0.33;                    % 速度 %OBS用
%est_prm.statemodel.std_dev_vz = 0.33;                    % 速度 %OBS用
%est_prm.statemodel.sensorbias = 1;
est_prm.statemodel.std_dev_a = 0.1;					% 加速度
est_prm.statemodel.std_dev_j = 1e-4*1;					% 躍度
est_prm.statemodel.std_dev_t = 2e+1;					% 受信機時計誤差
est_prm.statemodel.std_dev_i = 1e-3;					% Ionosphere
est_prm.statemodel.std_dev_T = 1e-4;					% Troposphere
est_prm.statemodel.std_dev_n = 0;						% 整数値バイアス
est_prm.statemodel.std_dev_b = 1e-3;					% 受信機ハードウェアバイアス
est_prm.statemodel.std_walking = 0.01;               %%歩幅

% 状態変数の初期分散
%--------------------------------------------
est_prm.P0.std_dev_p = [5,5,5];						% 受信機座標(X,Y,Z)
est_prm.P0.std_dev_v = [0.1,0.1,0.1];							% 受信機速度(X,Y,Z)
est_prm.P0.std_dev_a = [0.1,0.1,0.1];							% 受信機加速度(X,Y,Z)
est_prm.P0.std_dev_j = [1,1,1];							% 受信機躍度(X,Y,Z)
est_prm.P0.std_dev_t = [0,0];							% 受信機時計誤差(dtr,dtr_dot)
est_prm.P0.std_dev_b = [1,1,1,1];						% 受信機ハードウェアバイアス(CA,PY,L1,L2)
est_prm.P0.std_dev_i = [0.5,0.01,0.01];					% Ionosphere
est_prm.P0.std_dev_T = [0.1,0.01,0.01];					% Troposphere
est_prm.P0.std_dev_n = [10];							% 整数値バイアス
est_prm.P0.std_walking = 0.01;                     % 歩幅[E方向, N方向]

% サイクルスリップ設定
%--------------------------------------------
est_prm.cycle_slip.LC = [0];							% 使用する線形結合 [0:GF, 1:MW, 2:MP1, 3:MP2] (例:[0 2])
est_prm.cycle_slip.rej_flag = 0;						% 線形結合によるサイクルスリップ検出後の処理 [0:衛星除外のみ, 1:観測量修正(不可の場合は衛星除外)]※まだ使えない

est_prm.cycle_slip.lc_b    = 1;							% 線形結合複数エポックによる検定の最大自由度(最大使用エポック数)
est_prm.cycle_slip.lgl_ion = 1;							% 幾何学フリー線形結合の電離層遅延考慮 [0:OFF, 1:ON]
est_prm.cycle_slip.sd      = 5;							% 線形結合閾値の標準偏差倍率 (通常3-5)
est_prm.cycle_slip.lc_int  = 20;						% 線形結合閾値の決定要素範囲 [epoch]

est_prm.cycle_slip.A.a_mp1 = 0.001;						% 線形結合χ2検定の危険率(MP1)
est_prm.cycle_slip.A.a_mp2 = 0.001;						% 線形結合χ2検定の危険率(MP2)
est_prm.cycle_slip.A.a_mw  = 0.001;						% 線形結合χ2検定の危険率(MW)
est_prm.cycle_slip.A.a_lgl = 0.001;						% 線形結合χ2検定の危険率(GF)
est_prm.cycle_slip.A.b_mp1 = 0.1;						% 線形結合χ2検定による修正値推定の危険率(MP1)
est_prm.cycle_slip.A.b_mp2 = 0.1;						% 線形結合χ2検定による修正値推定の危険率(MP2)
est_prm.cycle_slip.A.b_mw  = 0.1;						% 線形結合χ2検定による修正値推定の危険率(MW)
est_prm.cycle_slip.A.b_lgl = 0.1;						% 線形結合χ2検定による修正値推定の危険率(GF)

est_prm.cycle_slip.timel   = 60;						% サイクルスリップ持続時間 [epoch]
est_prm.cycle_slip.timei   = 120;						% サイクルスリップ発生間隔 [epoch]
est_prm.cycle_slip.stime   = 1440;						% サイクルスリップ発生開始 [epoch]
est_prm.cycle_slip.etime   = 2880;						% サイクルスリップ発生終了 [epoch]
est_prm.cycle_slip.slip_l1 = 50;						% L1 スリップ量[cycle]
est_prm.cycle_slip.slip_l2 = 10;						% L2 スリップ量[cycle]
est_prm.cycle_slip.prn     = [];						% サイクルスリップ発生衛星番号 (例:[16 25] ,発生させない場合は[])

%-----------------------------------------------------------------------------------------
% "初期設定" ---->> 終了
%--------------------------------------------------------------------------
%---------------