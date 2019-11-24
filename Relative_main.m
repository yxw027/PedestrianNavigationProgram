%-------------------------------------------------------------------------------%
%                 杉本・久保研版 GPS測位演算ﾌﾟﾛｸﾞﾗﾑ　Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS測位演算プログラム(Relative DD Fix版)
% 
% < Programの流れ >
% 
%  1. 初期設定の取得
%  2. obs ヘッダー解析
%  3. nav からエフェメリス取得
%  4. start, end を設定
%  5. nav から電離層パラメータを取得
%  6. ionex から全TECデータ取得
%  7. 精密暦読込み
%  8. メイン処理
%     0. 時刻同期
%     1. 単独測位 (最小二乗法)
%     2. クロックジャンプ補正→補正済み観測量を作成
%     3. 相対測位 (カルマンフィルタ)
%  9. 結果格納
% 10. 結果グラフ表示
% 
% 
%-------------------------------------------------------------------------------
% 必要な外部ファイル・関数
%-------------------------------------------------------------------------------
% phisic_const.m      : 物理変数定義
%-------------------------------------------------------------------------------
% fileget2.m          : ファイル名生成とダウンロード(wget.exe, gzip.exe)
% read_obs_h.m        : OBSヘッダー解析
% read_eph.m          : エフェメリスの取得
% read_ionex2.m       : IONEXデータ取得
% read_sp3.m          : 精密暦データ取得
% read_obs_epo_data.m : OBSエポック情報解析 & OBS観測データ取得
%-------------------------------------------------------------------------------
% cal_time2.m         : 指定時刻のGPS週番号・ToW・ToDの計算
% clkjump_repair2.m   : 受信機時計の飛びの検出/修正
% mjuliday.m          : MJDの計算
% weekf.m             : WEEK, TOW の計算
%-------------------------------------------------------------------------------
% azel.m              : 仰角, 方位角, 偏微分係数の計算
% geodist_mix.m       : 幾何学的距離等の計算(放送暦,精密暦)
% interp_lag.m        : ラグランジュ補間
% pointpos2.m         : 単独測位演算
% sat_pos.m           : 衛星軌道計算(位置・速度・時計誤差)
%-------------------------------------------------------------------------------
% cal_ion2.m          : 電離層モデル
% cal_trop.m          : 対流圏モデル
% ion_gim.m           : GIMモデル
% ion_klob.m          : Klobucharモデル
% ion_rits.m          : 研究室モデル
% mapf_cosz.m         : マッピング関数(cosz)
% mapf_chao.m         : マッピング関数(chao)
% mapf_gmf.m          : マッピング関数(gmf)
% mapf_marini.m       : マッピング関数(marini)
%-------------------------------------------------------------------------------
% chi2test_dd         : 事前残差の検定(χ2検定)(DD用)
% lc_lim              : 線形結合によるサイクルスリップ検出閾値の計算
% lc_chi2             : 線形結合のカイ二乗検定
% lc_chi2r            : 線形結合のカイ二乗検定(連続エポック)
% outlier_detec.m     : 線形結合による異常値検定
% pre_chi2.m          : 線形結合のカイ二乗検定の閾値, 無相関化行列計算
%-------------------------------------------------------------------------------
% prn_check.m         : 衛星変化の検出
% sat_order.m         : 衛星PRNの順番の決定
% select_prn.m        : 使用衛星の選択
% state_adjust_dd5.m  : 衛星変化時の次元調節(DD用)
%-------------------------------------------------------------------------------
% obs_comb.m          : 各種線形結合の計算
% obs_vec.m           : 観測量ベクトル作成
%-------------------------------------------------------------------------------
% FQ_state_all6.m     : 状態モデルの生成
%-------------------------------------------------------------------------------
% filtekf_pre.m       : カルマンフィルタの時間更新
% filtekf_upd.m       : カルマンフィルタの観測更新
%-------------------------------------------------------------------------------
% ambfix3             : Ambiguity Resolution & Validation(amb_scnをサブ化)
% lambda2.m           : LAMBDA法(by Kubo, 各関数をサブ化)
% mlambda.m           : MLAMBDA法(by Takasu)
% selfixed            : 整数値バイアスの固定判定
% likelihood          : 尤度比検定
%-------------------------------------------------------------------------------
% geoidh.m            : ジオイド高計算(EGM96:geoid_egm96.mat)
% enu2xyz.m           : ENU→XYZ 座標変換
% llh2xyz.m           : LLH→XYZ 座標変換
% xyz2enu.m           : XYZ→ENU 座標変換
% xyz2llh.m           : XYZ→LLH 座標変換
%-------------------------------------------------------------------------------
% output_fig.m        : figureのファイル出力関数
% output_ins.m        : INS用フォーマット出力
% output_kml.m        : KMLフォーマット出力
% output_log.m        : 出力ファイルのヘッダー部分の書き込み
% output_nmea.m       : NMEAフォーマット出力
% output_statis.m     : 統計量の出力
% output_zenrin.m     : ZENRIN用フォーマット出力
%-------------------------------------------------------------------------------
% plot_data2.m        : 結果グラフ出力
% plot_ion.m          : グラフ出力(電離層遅延)
% plot_ionv2.m        : グラフ出力(電離層遅延変動)
% plot_pos.m          : グラフ出力(E-N-U, Bias,STD,RMS)
% plot_pos2.m         : グラフ出力(E-N-U, Bias,STD,RMS) 相対測位用
% plot_pos22.m        : グラフ出力(E-N-U, Bias,STD,RMS) 相対測位用
% plot_pos23.m        : グラフ出力(E-N-U, Bias,STD,RMS) 相対測位用
% plot_res.m          : グラフ出力(残差)
% plot_sat.m          : グラフ出力(PRN)
% plot_sky.m          : グラフ出力(衛星配置)
% plot_trop.m         : グラフ出力(対流圏遅延)
%-------------------------------------------------------------------------------
% p1c1bias.m          : P1-C1バイアス
% p1p2bias.m          : P1-P2バイアス
%-------------------------------------------------------------------------------
% recpos3.m           : 電子基準点の局番号検索
%-------------------------------------------------------------------------------
% 
% ・2周波コードおよび搬送波の相対測位(カルマンフィルタ)に対応
% ・電離層・対流圏モデル2重差を考慮(中長基線では必須)
% ・観測更新のループに対応?
% ・キネマティック対応
% ・電離層遅延の推定に対応(SD電離層)
% ・対流圏推定に対応(観測局ごとに設定→ref:1, rov:1)
% ・整数値バイアス固定バージョンに改造(固定あり・なしの選択が可能)
% 
% ・DD相対測位 + 電離層推定(Slant SD) + 対流圏推定(局毎ZWD) → Best + 長基線もOK
% 
% <課題>
% ・サイクルスリップ, 異常値検出(線形結合, 事前残差・事後残差検査)
% ・ARの方法(瞬時, 連続など)・・・連続はOK
% ・データ更新間隔が 1[sec]以下の場合× → 読み飛ばし, 時刻同期を修正
% 
% 残差チェックのために観測モデルを関数化する必要がある
% 事前と事後の観測モデルで利用する状態変数のみ異なるだけだから関数で利用できた方が便利
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov     : 可視衛星(rov)
%  prn.rovu    : 使用衛星(rov)
%  prn.ref.v     : 可視衛星(ref)
%  prn.refu    : 使用衛星(ref)
%  prn.c       : 共通可視衛星(rov,ref)
%  prn.u       : 共通使用衛星(rov,ref)
%  prn.float   : Floatとして利用する衛星(rov,ref)
%  prn.fix     : Fixとして利用する衛星(rov,ref)
%  prn.ar      : ARで利用する衛星(rov,ref)
%  prn.o       : 前エポックの使用衛星(rov,ref)
%  prn.float_o : 前エポックのFloatとして利用した衛星(rov,ref)
% 
% 時刻同期の部分を改造(MJDのみで比較するようにしてみた+0.1秒まで見るように変更)
% → 更新間隔が1[Hz]以上でもできるように修正
% → それに伴い, 他にも修正している部分あり
% 
% LAMBDAで決定された整数解を拘束条件として利用すれば，従来の手法(固定なし)でも
% Fix率が改善するのでは・・・？
% 
% WL+NLを拘束条件で利用することでもFix率が改善するはず
% 
%-------------------------------------------------------------------------------
% latest update : 2009/02/25 by Fujita
%-------------------------------------------------------------------------------
% 
% ・電離層推定(DD)対応
% ・尤度比検定対応
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov.v   : 可視衛星(rov)
%  prn.rov.vg  : GPSの可視衛星(rov)
%  prn.rov.vr  : GLONASSの可視衛星(rov)
%  prn.ref.v   : 可視衛星(ref)
%  prn.ref.vg  : GPSの可視衛星(ref)
%  prn.ref.vr  : GLONASSの可視衛星(ref)
%  prn.ug      : GPSの使用衛星
%  prn.ur      : GLONASSの使用衛星
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/25 by Yanase, Ohashi, Tomita
%-------------------------------------------------------------------------------
% 
% ・異常値検定対応
% 
% <課題>
% ・線形結合χ2検定が作成途中
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/ by Ishimaru
%-------------------------------------------------------------------------------

clear all
clc

%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算
%-----------------------------------------------------------------------------------------
addpath ./toolbox_gnss/
addpath ./LAMBDA_KUBO/

%--- 初期設定取得
%--------------------------------------------
cd('./INI/');
inifile=input('初期設定ファイル名を拡張子なしで入力して下さい>> \n','s');
eval(inifile);
cd ..

%--- ファイル名生成とファイル取得
%--------------------------------------------
est_prm=fileget2(est_prm);

if ~exist(est_prm.dirs.result)
	mkdir(est_prm.dirs.result);			% 結果のディレクトリ生成
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

%--- 定数(グローバル変数)
%--------------------------------------------
% phisic_const;

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

freq.g1=1.57542e9;						% L1 周波数(GPS)
wave.g1=C/1.57542e9;					% L1 波長(GPS)
freq.g2=1.22760e9;						% L2 周波数(GPS)
wave.g2=C/1.22760e9;					% L2 波長(GPS)


%--- start time の設定
%--------------------------------------------
if ~isempty(est_prm.stime)
	time_s=cal_time2(est_prm.stime);										% Start time の Juliday, WEEK, TOW, TOD
end

%--- end time の設定
%--------------------------------------------
if ~isempty(est_prm.etime)
	time_e=cal_time2(est_prm.etime);										% End time の Juliday, WEEK, TOW, TOD
else
	time_e.day = [];
	time_e.mjd = 1e50;														% End time(mjd) に大きな値を割当
end

%--- ファイルオープン
%--------------------------------------------
fpo1=fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');						% Rov obs
fpn1=fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');						% Rov nav
fpo2=fopen([est_prm.dirs.obs,est_prm.file.ref_o],'rt');						% Ref obs
fpn2=fopen([est_prm.dirs.obs,est_prm.file.ref_n],'rt');						% Ref nav

f_lam = fopen([est_prm.dirs.result,est_prm.file.lambda], 'w');				% LAMBDA 法のログ

if fpo1==-1 | fpn1==-1 | fpo2==-1 | fpo2==-1
	if fpo1==-1, fprintf('%sを開けません.\n',est_prm.file.rov_o);, end		% Rov obs(エラー処理)
	if fpn1==-1, fprintf('%sを開けません.\n',est_prm.file.rov_n);, end		% Rov nav(エラー処理)
	if fpo2==-1, fprintf('%sを開けません.\n',est_prm.file.ref_o);, end		% Ref obs(エラー処理)
	if fpn2==-1, fprintf('%sを開けません.\n',est_prm.file.ref_n);, end		% Ref nav(エラー処理)
	break;
end

%--- obs ヘッダー解析
%--------------------------------------------
[tofh1,toeh1,s_time1,e_time1,app_xyz1,no_obs1,TYPES1,dt,Rec_type1]=read_obs_h(fpo1);		% Rov
[tofh2,toeh2,s_time2,e_time2,app_xyz2,no_obs2,TYPES2,dt,Rec_type2]=read_obs_h(fpo2);		% Ref

%--- エフェメリス読込み(Klobuchar model パラメータの抽出も)
%--------------------------------------------
[eph_prm.brd.data1,ion_prm.klob.ionab]=read_eph(fpn1);										% Rov
[eph_prm.brd.data2,ion_prm.klob.ionab]=read_eph(fpn2);										% Ref
eph_prm.brd.data=[eph_prm.brd.data1,eph_prm.brd.data2];
[n,i]=unique(eph_prm.brd.data(1:34,:)','rows'); eph_prm.brd.data=eph_prm.brd.data(:,i);		% RovとRefの結合

%--- IONEXデータ取得
%--------------------------------------------
if est_prm.i_mode==2
	[ion_prm.gim]=read_ionex2([est_prm.dirs.ionex,est_prm.file.ionex]);
else
	ion_prm.gim.time=[]; ion_prm.gim.map=[]; ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- 精密暦の読込み
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);
else
	eph_prm.sp3.data=[];
end

%--- 設定情報の出力(Float用)
%--------------------------------------------
datname1=sprintf('Float_%s_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol1  = fopen([est_prm.dirs.result,datname1],'w');							% 結果書き出しファイルのオープン
output_log(f_sol1,time_s,time_e,est_prm,2);

%--- 設定情報の出力(Fix用)
%--------------------------------------------
datname2=sprintf('Fix_%s_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol2  = fopen([est_prm.dirs.result,datname2],'w');							% 結果書き出しファイルのオープン
output_log(f_sol2,time_s,time_e,est_prm,3);

%--- 次元とインデックスの設定(状態モデルごと)
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

%--- 配列の準備
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;

%--- SPP用
%--------------------------------------------
Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% 時刻
Result.spp.pos(1:tt,1:6)=NaN;													% 位置
Result.spp.dtr(1:tt,1:1)=NaN;													% 受信機時計誤差
Result.spp.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.spp.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.spp.prn{3}(1:tt,1:3)=NaN;												% 衛星数

%--- Float用
%--------------------------------------------
Result.float.time(1:tt,1:10)=NaN; Result.float.time(:,1)=1:tt;					% 時刻
Result.float.pos(1:tt,1:6)=NaN;													% 位置
Result.float.dion(1:tt,1:32)=NaN;												% 電離層遅延
Result.float.dtrop(1:tt,1:2)=NaN;												% 対流圏遅延
for j=1:2, for k=1:32, Result.float.amb{j,k}(1:tt,1:32)=NaN;, end, end			% 整数値バイアス
Result.float.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.float.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.float.prn{3}(1:tt,1:3)=NaN;												% 衛星数
Result.float.prn{4}(1:tt,1:32)=NaN;												% 使用衛星(基準)

%--- Fix用
%--------------------------------------------
Result.fix.time(1:tt,1:10)=NaN; Result.fix.time(:,1)=1:tt;						% 時刻
Result.fix.pos(1:tt,1:6)=NaN;													% 位置
Result.fix.dion(1:tt,1:32)=NaN;													% 電離層遅延
Result.fix.dtrop(1:tt,1:2)=NaN;													% 対流圏遅延
for j=1:2, for k=1:32, Result.fix.amb{j,k}(1:tt,1:32)=NaN;, end, end			% 整数値バイアス
Result.fix.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.fix.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.fix.prn{3}(1:tt,1:4)=NaN;												% 衛星数
Result.fix.prn{4}(1:tt,1:32)=NaN;												% 使用衛星(基準)

Result.float.ps(1:tt,1:3)=NaN;													% 位置
Result.fix.ps(1:tt,1:3)=NaN;													% 位置

%--- 残差用
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% 時刻
for j=1:4, for k=1:32, Res.pre{j,k}(1:tt,1:32)=NaN;, end, end					% 残差(pre-fit)
for j=1:4, for k=1:32, Res.post{j,k}(1:tt,1:32)=NaN;, end, end					% 残差(post-fit)

%--- clock jump用
%--------------------------------------------
dtr_all1(1:tt,1:2)=NaN; dtr_all2(1:tt,1:2)=NaN;

%--- 観測データ用
%--------------------------------------------
OBS.rov.time(1:tt,1:10)=NaN; OBS.rov.time(:,1)=1:tt;							% 時刻
OBS.rov.ca(1:tt,1:32)=NaN; OBS.rov.py(1:tt,1:32)=NaN;							% CA, PY
OBS.rov.ph1(1:tt,1:32)=NaN; OBS.rov.ph2(1:tt,1:32)=NaN;							% L1, L2
OBS.rov.ion(1:tt,1:32)=NaN; OBS.rov.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.rov.ele(1:tt,1:32)=NaN; OBS.rov.azi(1:tt,1:32)=NaN;							% Elevation, Azimuth
OBS.rov.ca_cor(1:tt,1:32)=NaN; OBS.rov.py_cor(1:tt,1:32)=NaN;					% CA, PY(Corrected)
OBS.rov.ph1_cor(1:tt,1:32)=NaN; OBS.rov.ph2_cor(1:tt,1:32)=NaN;					% L1, L2(Corrected)

OBS.ref.time(1:tt,1:10)=NaN; OBS.ref.time(:,1)=1:tt;							% 時刻
OBS.ref.ca(1:tt,1:32)=NaN; OBS.ref.py(1:tt,1:32)=NaN;							% CA, PY
OBS.ref.ph1(1:tt,1:32)=NaN; OBS.ref.ph2(1:tt,1:32)=NaN;							% L1, L2
OBS.ref.ion(1:tt,1:32)=NaN; OBS.ref.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.ref.ele(1:tt,1:32)=NaN; OBS.ref.azi(1:tt,1:32)=NaN;							% Elevation, Azimuth
OBS.ref.ca_cor(1:tt,1:32)=NaN; OBS.ref.py_cor(1:tt,1:32)=NaN;					% CA, PY(Corrected)
OBS.ref.ph1_cor(1:tt,1:32)=NaN; OBS.ref.ph2_cor(1:tt,1:32)=NaN;					% L1, L2(Corrected)

%--- LC用
%--------------------------------------------
LC.rov.time(1:tt,1:10)=NaN; LC.rov.time(:,1)=1:tt;								% 時刻
LC.rov.mp1(1:tt,1:61)=NaN; LC.rov.mp2(1:tt,1:61)=NaN;							% MP1, MP2
LC.rov.mw(1:tt,1:61)=NaN;														% MW
LC.rov.lgl(1:tt,1:61)=NaN; LC.rov.lgp(1:tt,1:61)=NaN;							% LGL, LGP
LC.rov.lg1(1:tt,1:61)=NaN; LC.rov.lg2(1:tt,1:61)=NaN;							% LG1, LG2
LC.rov.ionp(1:tt,1:61)=NaN; LC.rov.ionl(1:tt,1:61)=NaN;							% IONP, IONL

LC.ref.time(1:tt,1:10)=NaN; LC.ref.time(:,1)=1:tt;								% 時刻
LC.ref.mp1(1:tt,1:61)=NaN; LC.ref.mp2(1:tt,1:61)=NaN;							% MP1, MP2
LC.ref.mw(1:tt,1:61)=NaN;														% MW
LC.ref.lgl(1:tt,1:61)=NaN; LC.ref.lgp(1:tt,1:61)=NaN;							% LGL, LGP
LC.ref.lg1(1:tt,1:61)=NaN; LC.ref.lg2(1:tt,1:61)=NaN;							% LG1, LG2
LC.ref.ionp(1:tt,1:61)=NaN; LC.ref.ionl(1:tt,1:61)=NaN;							% IONP, IONL

%--- 異常値検出用
%--------------------------------------------
LC.rov.mp1_va(1:tt,1:61)=NaN; LC.rov.mp2_va(1:tt,1:61)=NaN;						% 線形結合の分散(rov)
LC.rov.mw_va(1:tt,1:61)=NaN;
LC.rov.lgl_va(1:tt,1:61)=NaN; LC.rov.lgp_va(1:tt,1:61)=NaN;
LC.rov.lg1_va(1:tt,1:61)=NaN; LC.rov.lg2_va(1:tt,1:61)=NaN;
LC.rov.ionp_va(1:tt,1:61)=NaN; LC.rov.ionl_va(1:tt,1:61)=NaN;
LC.rov.mp1_lim(1:tt,1:61)=NaN; LC.rov.mp2_lim(1:tt,1:61)=NaN;					% 線形結合サイクルスリップ標準偏差閾値(rov)
LC.rov.mw_lim(1:tt,1:61)=NaN; LC.rov.lgl_lim(1:tt,1:61)=NaN;
% LC.rov.lgp_lim(1:tt,1:61)=NaN;LC.rov.lg1_lim(1:tt,1:61)=NaN;
% LC.rov.lg2_lim(1:tt,1:61)=NaN; LC.rov.ionp_lim(1:tt,1:61)=NaN;
% LC.rov.ionl_lim(1:tt,1:61)=NaN;
LC.ref.mp1_va(1:tt,1:61)=NaN; LC.ref.mp2_va(1:tt,1:61)=NaN;						% 線形結合の分散(ref)
LC.ref.mw_va(1:tt,1:61)=NaN;
LC.ref.lgl_va(1:tt,1:61)=NaN; LC.ref.lgp_va(1:tt,1:61)=NaN;
LC.ref.lg1_va(1:tt,1:61)=NaN; LC.ref.lg2_va(1:tt,1:61)=NaN;
LC.ref.ionp_va(1:tt,1:61)=NaN; LC.ref.ionl_va(1:tt,1:61)=NaN;
LC.ref.mp1_lim(1:tt,1:61)=NaN; LC.ref.mp2_lim(1:tt,1:61)=NaN;					% 線形結合サイクルスリップ標準偏差閾値(ref)
LC.ref.mw_lim(1:tt,1:61)=NaN; LC.ref.lgl_lim(1:tt,1:61)=NaN;
% LC.ref.lgp_lim(1:tt,1:61)=NaN;LC.ref.lg1_lim(1:tt,1:61)=NaN;
% LC.ref.lg2_lim(1:tt,1:61)=NaN; LC.ref.ionp_lim(1:tt,1:61)=NaN;
% LC.ref.ionl_lim(1:tt,1:61)=NaN;

LC.rov.cs1(1:tt,1:61)=NaN;														% スリップ量推定値(rov)
LC.rov.cs2(1:tt,1:61)=NaN;
LC.rov.lgl_cs(1:tt,1:61) = NaN; LC.rov.mw_cs(1:tt,1:61) = NaN;
LC.rov.mp1_cs(1:tt,1:61) = NaN; LC.rov.mp2_cs(1:tt,1:61) = NaN;
LC.ref.cs1(1:tt,1:61)=NaN;														% スリップ量推定値(ref)
LC.ref.cs2(1:tt,1:61)=NaN;
LC.ref.lgl_cs(1:tt,1:61) = NaN; LC.ref.mw_cs(1:tt,1:61) = NaN;
LC.ref.mp1_cs(1:tt,1:61) = NaN; LC.ref.mp2_cs(1:tt,1:61) = NaN;

LC_r.rov.mp1(1:tt,1:61)=NaN; LC_r.rov.mp2(1:tt,1:61)=NaN;						% 除外衛星を排除した線形結合(rov)
LC_r.rov.mw(1:tt,1:61)=NaN;
LC_r.rov.lgl(1:tt,1:61)=NaN; LC_r.rov.lgp(1:tt,1:61)=NaN;
LC_r.rov.lg1(1:tt,1:61)=NaN; LC_r.rov.lg2(1:tt,1:61)=NaN;
LC_r.rov.ionp(1:tt,1:61)=NaN; LC_r.rov.ionl(1:tt,1:61)=NaN;
LC_r.ref.mp1(1:tt,1:61)=NaN; LC_r.ref.mp2(1:tt,1:61)=NaN;						% 除外衛星を排除した線形結合(ref)
LC_r.ref.mw(1:tt,1:61)=NaN;
LC_r.ref.lgl(1:tt,1:61)=NaN; LC_r.ref.lgp(1:tt,1:61)=NaN;
LC_r.ref.lg1(1:tt,1:61)=NaN; LC_r.ref.lg2(1:tt,1:61)=NaN;
LC_r.ref.ionp(1:tt,1:61)=NaN; LC_r.ref.ionl(1:tt,1:61)=NaN;

CHI2.kal.l1(1:tt,1:61)=NaN; CHI2.kal.l2(1:tt,1:61)=NaN;							% カルマンフィルタのイノベーションによる検定のカイ2乗検定統計量

CHI2.rov.mp1(1:tt,1:61)=NaN; CHI2.rov.mp2(1:tt,1:61)=NaN;						% 線形結合サイクルスリップカイ2乗検定統計量(rov)
CHI2.rov.mw(1:tt,1:61)=NaN; CHI2.rov.lgl(1:tt,1:61)=NaN;
CHI2.rov.lgp(1:tt,1:61)=NaN; CHI2.rov.lg1(1:tt,1:61)=NaN;
CHI2.rov.lg2(1:tt,1:61)=NaN; CHI2.rov.ionp(1:tt,1:61)=NaN;
CHI2.rov.ionl(1:tt,1:61)=NaN;
CHI2.ref.mp1(1:tt,1:61)=NaN; CHI2.ref.mp2(1:tt,1:61)=NaN;						% 線形結合サイクルスリップカイ2乗検定統計量(ref)
CHI2.ref.mw(1:tt,1:61)=NaN; CHI2.ref.lgl(1:tt,1:61)=NaN;
CHI2.ref.lgp(1:tt,1:61)=NaN; CHI2.ref.lg1(1:tt,1:61)=NaN;
CHI2.ref.lg2(1:tt,1:61)=NaN; CHI2.ref.ionp(1:tt,1:61)=NaN;
CHI2.ref.ionl(1:tt,1:61)=NaN;
[CHI2.sigma, Vb, Gb] = pre_chi2(est_prm.cycle_slip.A,est_prm.cycle_slip.lc_b);	% カイ二乗検定のカイ2乗上側確立点, 無相関化行列

REJ.rov.mp1(1:tt,1:61)=NaN; REJ.rov.mp2(1:tt,1:61)=NaN;							% 線形結合サイクルスリップ除外衛星(rov)
REJ.rov.mw(1:tt,1:61)=NaN; REJ.rov.lgl(1:tt,1:61)=NaN;
% REJ.rov.lgp(1:tt,1:61)=NaN; REJ.rov.lg1(1:tt,1:61)=NaN;
% REJ.rov.lg2(1:tt,1:61)=NaN; REJ.rov.ionp(1:tt,1:61)=NaN;
% REJ.rov.ionl(1:tt,1:61)=NaN;
REJ.ref.mp1(1:tt,1:61)=NaN; REJ.ref.mp2(1:tt,1:61)=NaN;							% 線形結合サイクルスリップ除外衛星(ref)
REJ.ref.mw(1:tt,1:61)=NaN; REJ.ref.lgl(1:tt,1:61)=NaN;
% REJ.ref.lgp(1:tt,1:61)=NaN; REJ.ref.lg1(1:tt,1:61)=NaN;
% REJ.ref.lg2(1:tt,1:61)=NaN; REJ.ref.ionp(1:tt,1:61)=NaN;
% REJ.ref.ionl(1:tt,1:61)=NaN;
REJ.rej(1:tt,1:61)=NaN;

%--- 整数値バイアスの固定用
%--------------------------------------------
Fixed_N{1}(1:32,1)=NaN; Fixed_N{1}(1:32,2)=0;
if est_prm.freq==2
	Fixed_N{2}(1:32,1)=NaN; Fixed_N{2}(1:32,2)=0;
end

%--- 整数値バイアスの尤度比検定用
%--------------------------------------------
ratio_l=0;


%--- Local(ENU)用の変換行列(キネマティック用)
%--------------------------------------------
ref_L=xyz2llh(est_prm.refpos);
lat=ref_L(1); lon=ref_L(2);
LL = [         -sin(lon),           cos(lon),        0;
      -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
       cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算 ---->> 開始
%-----------------------------------------------------------------------------------------
while 1

	%--- start 判定
	%--------------------------------------------
	if sf == 0
		time1.mjd = -1e10;
		time2.mjd = -1e10;
		while time_s.mjd > time1.mjd+0.1/86400													% 約 0.1 秒ｽﾞﾚまで認める
			%--- エポック情報取得(時刻, PRN, Dataなど)
			%--------------------------------------------
			[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
					read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);

			if time_s.mjd <= time1.mjd+0.1/86400, sf=1; break;, end
		end
		while time_s.mjd > time2.mjd+0.1/86400		%10秒ずらす										% 約 0.1 秒ｽﾞﾚまで認める
			%--- エポック情報取得(時刻, PRN, Dataなど)
			%--------------------------------------------
			[time2,no_sat2,prn.ref.v,dtrec2,ephi2,data2]=...
					read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);

			if time_s.mjd <= time2.mjd+0.1/86400, sf=1; break;, end
        end
	else
		%--- エポック情報取得(時刻, PRN, Dataなど)
		%--------------------------------------------
		[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
				read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
		[time2,no_sat2,prn.ref.v,dtrec2,ephi2,data2]=...
				read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
    end
    if sf==1
		%--- 時刻同期
		%--------------------------------------------
		while 1
			%if abs(time1.mjd-time2.mjd)<=0.1/86400
				%break;
			%else
				if time1.mjd < time2.mjd
					while time1.mjd < time2.mjd
						%--- エポック情報取得(時刻, PRN など)
						%--------------------------------------------
						[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
								read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time1.mjd-0.1/86400, break;, end						% 約 0.1 秒ｽﾞﾚまで認める
					end
				elseif time1.mjd > time2.mjd
					while time1.mjd > time2.mjd
						%--- エポック情報取得(時刻, PRN, Dataなど)
						%--------------------------------------------
						[time2,no_sat2,prn.ref.v,dtrec2,ephi2,data2]=...
								read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time2.mjd-0.1/86400, break;, end						% 約 0.1 秒ｽﾞﾚまで認める
					end
				end
			%end
			if abs(time1.mjd-time2.mjd)<=0.1/86400 | feof(fpo1) | feof(fpo2), break;, end
		end

		%--- end 判定
		%--------------------------------------------
		if time_e.mjd <= time1.mjd-0.1/86400 | time_e.mjd <= time2.mjd-0.1/86400, break;, end	% 約 0.1 秒ｽﾞﾚまで認める

		%--- タイムタグ
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
		else
			timetag = timetag + round((time1.mjd-time_o.mjd)*86400/dt);
		end

		%--- 読み取り中のエポックの時間表示
		%--------------------------------------------
		fprintf('%7d: 移動局-%2d:%2d %5.2f , 基準局-%2d:%2d %5.2f"  ',timetag,time1.day(4),time1.day(5),time1.day(6),time2.day(4),time2.day(5),time2.day(6));

		%------------------------------------------------------------------------------------------------------
		%----- 単独測位(最小二乗法)
		%------------------------------------------------------------------------------------------------------

		%--- サイクルスリップ設定
		%--------------------------------------------
		if length(est_prm.cycle_slip.prn)>=1
			stl = [1:est_prm.cycle_slip.timel];											% スリップ持続時間 [epoch]
			sti = est_prm.cycle_slip.timei;												% スリップ発生間隔 [epoch]
			sliptime = [];
			for st=est_prm.cycle_slip.stime*dt:sti*dt:est_prm.cycle_slip.etime*dt		% スリップ開始&終了時刻 [epoch*観測間隔]
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

		%--- 単独測位
		%--------------------------------------------
		[x1,dtr1,dtsv1,ion1,trop1,prn.rovu,rho1,dop1,ele1,azi1]=...
				pointpos2(time1,prn.rov.v,app_xyz1,data1,eph_prm,ephi1,est_prm,ion_prm,rej);
		[x2,dtr2,dtsv2,ion2,trop2,prn.refu,rho2,dop2,ele2,azi2]=...
				pointpos2(time2,prn.ref.v,app_xyz2,data2,eph_prm,ephi2,est_prm,ion_prm,rej);
		if ~isnan(x1(1)), app_xyz1(1:3)=x1(1:3);, end
		if ~isnan(x2(1)), app_xyz2(1:3)=x2(1:3);, end

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos1 = xyz2enu(x1(1:3),est_prm.rovpos)';												% ENUに変換
		est_pos2 = xyz2enu(x2(1:3),est_prm.refpos)';												% ENUに変換

		%--- 結果格納(SPP)
		%--------------------------------------------
		Result.spp.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% 時刻
		Result.spp.pos(timetag,:)=[x1(1:3)', xyz2llh(x1(1:3)).*[180/pi 180/pi 1]];					% 位置
		Result.spp.dtr(timetag,:)=C*dtr1;															% 受信機時計誤差

		%--- 衛星格納
		%--------------------------------------------
		Result.spp.prn{3}(timetag,1:4)=[time1.tod,length(prn.rov.v),length(prn.rovu),dop1];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rovu), Result.spp.prn{2}(timetag,prn.rovu)=prn.rovu;, end

		%--- OBSデータ,電離層遅延(構造体)
		%--------------------------------------------
		OBS.rov.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];					% 時刻
		OBS.ref.time(timetag,2:10)=[time2.week, time2.tow, time2.tod, time2.day];					% 時刻
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
		%----- 単独測位(最小二乗法) ---->> 終了 ---->> クロックジャンプ補正
		%------------------------------------------------------------------------------------------------------

		%--- clock jump の検出 & 補正
		%--------------------------------------------
		if est_prm.clk_flag == 1
			dtr_all1(timetag,1) = dtr1;																% 受信機時計誤差を格納
			[data1,dtr1,time1.day,clk_jump1,dtr_o1,jump_width_all1]=...
						clkjump_repair2(time1.day,data1,dtr1,dtr_o1,jump_width_all1,Rec_type1);		% clock jump 検出/補正
			clk_check1(timetag,1) = clk_jump1;														% ジャンプフラグを格納

			dtr_all2(timetag,1) = dtr2;																% 受信機時計誤差を格納
			[data2,dtr2,time2.day,clk_jump2,dtr_o2,jump_width_all2]=...
						clkjump_repair2(time2.day,data2,dtr2,dtr_o2,jump_width_all2,Rec_type2);		% clock jump 検出/補正
			clk_check2(timetag,1) = clk_jump2;														% ジャンプフラグを格納
		end
		dtr_all1(timetag,2) = dtr1;																	% 補正済み受信機時計誤差を格納
		dtr_all2(timetag,2) = dtr2;																	% 補正済み受信機時計誤差を格納

		%--- 補正済み観測量を格納
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
		%----- 異常値検出
		%------------------------------------------------------------------------------------------------------

		%--- GPS・GLONASSの衛星分別
		%--------------------------------------------
		prn.rov.vg=prn.rov.v(find(prn.rov.v<=32));							% 可視衛星(GPS)(rov)
		prn.rov.vr=prn.rov.v(find(38<=prn.rov.v));							% 可視衛星(GLONASS)(rov)
		prn.ref.vg=prn.ref.v(find(prn.ref.v<=32));							% 可視衛星(GPS)(ref)
		prn.ref.vr=prn.ref.v(find(38<=prn.ref.v));							% 可視衛星(GLONASS)(ref)

		LC.rov.variance(1:length(prn.rov.v),1:4)=NaN; 														% 分散格納配列(rov)
		LC.ref.variance(1:length(prn.ref.v),1:4)=NaN; 														% 分散格納配列(ref)
		if est_prm.ww == 0																					% 重みなし
			LC.rov.variance(1:length(prn.rov.v),1)=repmat(est_prm.obsnoise.PR1,length(prn.rov.v),1);		% CAコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),2)=repmat(est_prm.obsnoise.PR2,length(prn.rov.v),1);		% PYコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),3)=repmat(est_prm.obsnoise.Ph1,length(prn.rov.v),1);		% L1搬送波の分散(rov)
			LC.rov.variance(1:length(prn.rov.v),4)=repmat(est_prm.obsnoise.Ph2,length(prn.rov.v),1);		% L2搬送波の分散(rov)
			LC.ref.variance(1:length(prn.ref.v),1)=repmat(est_prm.obsnoise.PR1,length(prn.ref.v),1);		% CAコードの分散(ref)
			LC.ref.variance(1:length(prn.ref.v),2)=repmat(est_prm.obsnoise.PR2,length(prn.ref.v),1);		% PYコードの分散(ref)
			LC.ref.variance(1:length(prn.ref.v),3)=repmat(est_prm.obsnoise.Ph1,length(prn.ref.v),1);		% L1搬送波の分散(ref)
			LC.ref.variance(1:length(prn.ref.v),4)=repmat(est_prm.obsnoise.Ph2,length(prn.ref.v),1);		% L2搬送波の分散(ref)
		else																								% 重み考慮
			LC.rov.variance(1:length(prn.rov.v),1)= (est_prm.obsnoise.PR1./sin(ele1).^2);					% CAコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),2)= (est_prm.obsnoise.PR2./sin(ele1).^2);					% PYコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),3)= (est_prm.obsnoise.Ph1./sin(ele1).^2);					% L1搬送波の分散(rov)
			LC.rov.variance(1:length(prn.rov.v),4)= (est_prm.obsnoise.Ph2./sin(ele1).^2);					% L2搬送波の分散(rov)
% 			LC.rov.variance(1,prn.rov.v)= (est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);	% CAコードの分散(rov)
% 			LC.rov.variance(2,prn.rov.v)= (est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);	% PYコードの分散(rov)
% 			LC.rov.variance(3,prn.rov.v)= (est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele1(ii(b))).^2);	% L1搬送波の分散(rov)
% 			LC.rov.variance(4,prn.rov.v)= (est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele1(ii(b))).^2);	% L2搬送波の分散(rov)
			LC.ref.variance(1:length(prn.ref.v),1)= (est_prm.obsnoise.PR1./sin(ele2).^2);					% CAコードの分散(ref)
			LC.ref.variance(1:length(prn.ref.v),2)= (est_prm.obsnoise.PR2./sin(ele2).^2);					% PYコードの分散(ref)
			LC.ref.variance(1:length(prn.ref.v),3)= (est_prm.obsnoise.Ph1./sin(ele2).^2);					% L1搬送波の分散(ref)
			LC.ref.variance(1:length(prn.ref.v),4)= (est_prm.obsnoise.Ph2./sin(ele2).^2);					% L2搬送波の分散(ref)
% 			LC.ref.variance(1,prn.ref.v)= (est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele(ii(b))).^2);	% CAコードの分散(ref)
% 			LC.ref.variance(2,prn.ref.v)= (est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele(ii(b))).^2);	% PYコードの分散(ref)
% 			LC.ref.variance(3,prn.ref.v)= (est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele(ii(b))).^2);	% L1搬送波の分散(ref)
% 			LC.ref.variance(4,prn.ref.v)= (est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele(ii(b))).^2);	% L2搬送波の分散(ref)
		end

		%--- 各種線形結合と分散(補正済み観測量を使用)
		%--------------------------------------------
		[mp11,mp21,lgl1,lgp1,lg11,lg21,mw1,ionp1,ionl1,lgl_ion1,...
			mp11_va,mp21_va,lgl1_va,lgp1_va,lg11_va,lg21_va,mw1_va,ionp1_va,ionl1_va]=...
					obs_comb2(est_prm,freq,wave,data1,LC.rov.variance,prn.rov,ion1,ele1);
		[mp12,mp22,lgl2,lgp2,lg12,lg22,mw2,ionp2,ionl2,lgl_ion2,...
			mp12_va,mp22_va,lgl2_va,lgp2_va,lg12_va,lg22_va,mw2_va,ionp2_va,ionl2_va]=...
					obs_comb2(est_prm,freq,wave,data2,LC.ref.variance,prn.ref,ion2,ele2);

		%--- 各種線形結合と分散を格納
		%--------------------------------------------
		ii=find(ele1*180/pi>est_prm.mask);
		if ~isempty(ii)
			if est_prm.cycle_slip.lgl_ion == 0
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl1_va(ii);								% 幾何学フリー線形結合(搬送波)(rov)
			else
				LC.rov.lgl(timetag,prn.rov.v(ii)) = lgl_ion1(ii);								% 幾何学フリー線形結合(搬送波)-電離層遅延分(rov)
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_ion1_va(ii);							% 幾何学フリー線形結合(搬送波)-電離層遅延分の分散(rov)
			end

			LC.rov.mp1(timetag,prn.rov.v(ii)) = mp11(ii);										% Multipath 線形結合(L1)(rov)
			LC.rov.mp2(timetag,prn.rov.v(ii)) = mp21(ii);										% Multipath 線形結合(L2)(rov)
			LC.rov.mw(timetag,prn.rov.v(ii))  = mw1(ii);										% Melbourne-Wubbena 線形結合(rov)
			LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp1(ii);										% 幾何学フリー線形結合(コード)(rov)
			LC.rov.lg1(timetag,prn.rov.v(ii))  = lg11(ii);										% 幾何学フリー線形結合(1周波)(rov)
			LC.rov.lg2(timetag,prn.rov.v(ii))  = lg21(ii);										% 幾何学フリー線形結合(2周波)(rov)
			LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp1(ii);										% 電離層(lgpから算出)(rov)
			LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl1(ii);										% 電離層(lglから算出,Nを含む)(rov)

			LC.rov.mp1_va(timetag,prn.rov.v(ii)) = mp11_va(ii);									% Multipath 線形結合(L1)の分散(rov)
			LC.rov.mp2_va(timetag,prn.rov.v(ii)) = mp21_va(ii);									% Multipath 線形結合(L2)の分散(rov)
			LC.rov.mw_va(timetag,prn.rov.v(ii))  = mw1_va(ii);									% Melbourne-Wubbena 線形結合の分散(rov)
			LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl1_va(ii);									% 幾何学フリー線形結合(搬送波)(rov)
			LC.rov.lgp_va(timetag,prn.rov.v(ii))  = lgp1_va(ii);								% 幾何学フリー線形結合(コード)の分散(rov)
			LC.rov.lg1_va(timetag,prn.rov.v(ii))  = lg11_va(ii);								% 幾何学フリー線形結合(1周波)の分散(rov)
			LC.rov.lg2_va(timetag,prn.rov.v(ii))  = lg21_va(ii);								% 幾何学フリー線形結合(2周波)の分散(rov)
			LC.rov.ionp_va(timetag,prn.rov.v(ii)) = ionp1_va(ii);								% 電離層(lgpから算出)の分散(rov)
			LC.rov.ionl_va(timetag,prn.rov.v(ii)) = ionl1_va(ii);								% 電離層(lglから算出,Nを含む)の分散(rov)
		end

		ii=find(ele2*180/pi>est_prm.mask);
		if ~isempty(ii)
			if est_prm.cycle_slip.lgl_ion == 0
% 				LC.ref.lgl_va(timetag,prn.ref.v(ii)) = lgl2_va(ii);								% 幾何学フリー線形結合(搬送波)(ref)
			else
				LC.ref.lgl(timetag,prn.ref.v(ii)) = lgl_ion2(ii);								% 幾何学フリー線形結合(搬送波)-電離層遅延分(ref)
% 				LC.ref.lgl_va(timetag,prn.ref.v(ii)) = lgl_ion2_va(ii);							% 幾何学フリー線形結合(搬送波)-電離層遅延分の分散(ref)
			end

			LC.ref.mp1(timetag,prn.ref.v(ii)) = mp12(ii);										% Multipath 線形結合(L1)(ref)
			LC.ref.mp2(timetag,prn.ref.v(ii)) = mp22(ii);										% Multipath 線形結合(L2)(ref)
			LC.ref.mw(timetag,prn.ref.v(ii))  = mw2(ii);										% Melbourne-Wubbena 線形結合(ref)
			LC.ref.lgp(timetag,prn.ref.v(ii))  = lgp2(ii);										% 幾何学フリー線形結合(コード)(ref)
			LC.ref.lg1(timetag,prn.ref.v(ii))  = lg12(ii);										% 幾何学フリー線形結合(1周波)(ref)
			LC.ref.lg2(timetag,prn.ref.v(ii))  = lg22(ii);										% 幾何学フリー線形結合(2周波)(ref)
			LC.ref.ionp(timetag,prn.ref.v(ii)) = ionp2(ii);										% 電離層(lgpから算出)(ref)
			LC.ref.ionl(timetag,prn.ref.v(ii)) = ionl2(ii);										% 電離層(lglから算出,Nを含む)(ref)

			LC.ref.mp1_va(timetag,prn.ref.v(ii)) = mp12_va(ii);									% Multipath 線形結合(L1)の分散(ref)
			LC.ref.mp2_va(timetag,prn.ref.v(ii)) = mp22_va(ii);									% Multipath 線形結合(L2)の分散(ref)
			LC.ref.mw_va(timetag,prn.ref.v(ii))  = mw2_va(ii);									% Melbourne-Wubbena 線形結合の分散(ref)
			LC.ref.lgl_va(timetag,prn.ref.v(ii)) = lgl2_va(ii);									% 幾何学フリー線形結合(搬送波)(ref)
			LC.ref.lgp_va(timetag,prn.ref.v(ii))  = lgp2_va(ii);								% 幾何学フリー線形結合(コード)の分散(ref)
			LC.ref.lg1_va(timetag,prn.ref.v(ii))  = lg12_va(ii);								% 幾何学フリー線形結合(1周波)の分散(ref)
			LC.ref.lg2_va(timetag,prn.ref.v(ii))  = lg22_va(ii);								% 幾何学フリー線形結合(2周波)の分散(ref)
			LC.ref.ionp_va(timetag,prn.ref.v(ii)) = ionp2_va(ii);								% 電離層(lgpから算出)の分散(ref)
			LC.ref.ionl_va(timetag,prn.ref.v(ii)) = ionl2_va(ii);								% 電離層(lglから算出,Nを含む)の分散(ref)
		end

		%--- 線形結合による異常値検定
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

		%--- 除外衛星を考慮した線形結合格納配列
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
	
			%--- 線形結合による異常値検定
			%--------------------------------------------
			[lim_rov,chi2_rov,rej_rov,lcbb_rov]=outlier_detec(est_prm,timetag,LC.rov,LC_r.rov,CHI2.sigma,REJ.rov,prn.rov.v,Vb,Gb);
			[lim_ref,chi2_ref,rej_ref,lcbb_ref]=outlier_detec(est_prm,timetag,LC.ref,LC_r.ref,CHI2.sigma,REJ.ref,prn.ref.v,Vb,Gb);

			switch est_prm.cs_mode
			case 0,
				rej_uni=rej;
			case 2,
				if timetag>est_prm.cycle_slip.lc_int+1

					%--- 閾値の格納
					%------------------------------------------
					LC.rov.mp1_lim(timetag,:)  = lim_rov.mp1;						% Multipath 線形結合(L1)(rov)
					LC.rov.mp2_lim(timetag,:)  = lim_rov.mp2;						% Multipath 線形結合(L2)(rov)
					LC.rov.mw_lim(timetag,:)   = lim_rov.mw;						% Melbourne-Wubbena 線形結合(rov)
					LC.rov.lgl_lim(timetag,:)  = lim_rov.lgl;						% 幾何学フリー線形結合(搬送波)(rov)
% 					LC.rov.lgp_lim(timetag,:)  = lim_rov.lgp;						% 幾何学フリー線形結合(コード)(rov)
% 					LC.rov.lg1_lim(timetag,:)  = lim_rov.lg1;						% 幾何学フリー線形結合(1周波)(rov)
% 					LC.rov.lg2_lim(timetag,:)  = lim_rov.lg2;						% 幾何学フリー線形結合(2周波)(rov)
% 					LC.rov.ionp_lim(timetag,:) = lim_rov.ionp;						% 電離層(lgpから算出)(rov)
% 					LC.rov.ionl_lim(timetag,:) = lim_rov.ionl;						% 電離層(lglから算出,Nを含む)(rov)

					LC.ref.mp1_lim(timetag,:)  = lim_ref.mp1;						% Multipath 線形結合(L1)(ref)
					LC.ref.mp2_lim(timetag,:)  = lim_ref.mp2;						% Multipath 線形結合(L2)(ref)
					LC.ref.mw_lim(timetag,:)   = lim_ref.mw;						% Melbourne-Wubbena 線形結合(ref)
					LC.ref.lgl_lim(timetag,:)  = lim_ref.lgl;						% 幾何学フリー線形結合(搬送波)(ref)
% 					LC.ref.lgp_lim(timetag,:)  = lim_ref.lgp;						% 幾何学フリー線形結合(コード)(ref)
% 					LC.ref.lg1_lim(timetag,:)  = lim_ref.lg1;						% 幾何学フリー線形結合(1周波)(ref)
% 					LC.ref.lg2_lim(timetag,:)  = lim_ref.lg2;						% 幾何学フリー線形結合(2周波)(ref)
% 					LC.ref.ionp_lim(timetag,:) = lim_ref.ionp;						% 電離層(lgpから算出)(ref)
% 					LC.ref.ionl_lim(timetag,:) = lim_ref.ionl;						% 電離層(lglから算出,Nを含む)(ref)

					%--- 異常値検出
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

					%--- 異常値検出された衛星番号の格納
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
				%--- 異常値検出された衛星番号の格納
				%------------------------------------------
				REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
				REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
				REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
				REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;
				REJ.ref.mp1(timetag,rej_ref.mp1)=rej_ref.mp1;
				REJ.ref.mp2(timetag,rej_ref.mp2)=rej_ref.mp2;
				REJ.ref.mw(timetag,rej_ref.mw)=rej_ref.mw;
				REJ.ref.lgl(timetag,rej_ref.lgl)=rej_ref.lgl;

				%--- カイ二乗値の格納
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;						% Multipath 線形結合(L1)(rov)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;						% Multipath 線形結合(L2)(rov)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;							% Melbourne-Wubbena 線形結合(rov)
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;						% 幾何学フリー線形結合(搬送波)(rov)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov_lgp;						% 幾何学フリー線形結合(コード)(rov)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov_lg1;						% 幾何学フリー線形結合(1周波)(rov)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov_lg2;						% 幾何学フリー線形結合(2周波)(rov)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov_ionp;						% 電離層(lgpから算出)(rov)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov_ionl;						% 電離層(lglから算出,Nを含む)(rov)

				CHI2.ref.mp1(timetag,:)  = chi2_ref.mp1;						% Multipath 線形結合(L1)(ref)
				CHI2.ref.mp2(timetag,:)  = chi2_ref.mp2;						% Multipath 線形結合(L2)(ref)
				CHI2.ref.mw(timetag,:)   = chi2_ref.mw;							% Melbourne-Wubbena 線形結合(ref)
				CHI2.ref.lgl(timetag,:)  = chi2_ref.lgl;						% 幾何学フリー線形結合(搬送波)(ref)
% 				CHI2.ref.lgp(timetag,:)  = chi2_ref_lgp;						% 幾何学フリー線形結合(コード)(ref)
% 				CHI2.ref.lg1(timetag,:)  = chi2_ref_lg1;						% 幾何学フリー線形結合(1周波)(ref)
% 				CHI2.ref.lg2(timetag,:)  = chi2_ref_lg2;						% 幾何学フリー線形結合(2周波)(ref)
% 				CHI2.ref.ionp(timetag,:) = chi2_ref_ionp;						% 電離層(lgpから算出)(ref)
% 				CHI2.ref.ionl(timetag,:) = chi2_ref_ionl;						% 電離層(lglから算出,Nを含む)(ref)

				%--- 異常値検出衛星の除外
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

				%--- 異常値修正(サイクルスリップ)
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
					rej_rov_sum = union(rej_rov_1,rej_rov_2);							% 未知局側検出衛星
					rej_ref_1 = union(rej_ref.lgl,rej_ref.mw);
					rej_ref_2 = union(rej_ref.mp1,rej_ref.mp2);
					rej_ref_sum = union(rej_ref_1,rej_ref_2);							% 既知局側検出衛星

					%--- 修正可能な観測量の修正
					%--------------------------------------
					if ~isnan(rej_rov_sum)
						[s1_rov,s2_rov,rov_lgl_cs,rov_mw_cs,rov_mp1_cs,rov_mp2_cs] = lc_slip(LC.rov,CHI2.rov,timetag,rej_rov_sum);
						LC.rov.cs1(timetag,rej_rov_sum) = s1_rov(rej_rov_sum);				% 未知局スリップ推定量格納(L1)
						LC.rov.cs2(timetag,rej_rov_sum) = s2_rov(rej_rov_sum);				% 未知局スリップ推定量格納(L2)
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
						LC.ref.cs1(timetag,rej_ref_sum) = s1_ref(rej_ref_sum);				% 既知局スリップ推定量格納(L1)
						LC.ref.cs2(timetag,rej_ref_sum) = s2_ref(rej_ref_sum);				% 既知局スリップ推定量格納(L2)
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

					%--- 修正不可能な衛星の除外
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
				%--- カイ二乗値の格納
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;					% Multipath 線形結合(L1)(rov)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;					% Multipath 線形結合(L2)(rov)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;						% Melbourne-Wubbena 線形結合(rov)
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;					% 幾何学フリー線形結合(搬送波)(rov)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov.lgp;					% 幾何学フリー線形結合(コード)(rov)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov.lg1;					% 幾何学フリー線形結合(1周波)(rov)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov.lg2;					% 幾何学フリー線形結合(2周波)(rov)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov.ionp;					% 電離層(lgpから算出)(rov)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov.ionl;					% 電離層(lglから算出,Nを含む)(rov)

				CHI2.ref.mp1(timetag,:)  = chi2_ref.mp1;					% Multipath 線形結合(L1)(ref)
				CHI2.ref.mp2(timetag,:)  = chi2_ref.mp2;					% Multipath 線形結合(L2)(ref)
				CHI2.ref.mw(timetag,:)   = chi2_ref.mw;						% Melbourne-Wubbena 線形結合(ref)
				CHI2.ref.lgl(timetag,:)  = chi2_ref.lgl;					% 幾何学フリー線形結合(搬送波)(ref)
% 				CHI2.ref.lgp(timetag,:)  = chi2_ref.lgp;					% 幾何学フリー線形結合(コード)(ref)
% 				CHI2.ref.lg1(timetag,:)  = chi2_ref.lg1;					% 幾何学フリー線形結合(1周波)(ref)
% 				CHI2.ref.lg2(timetag,:)  = chi2_ref.lg2;					% 幾何学フリー線形結合(2周波)(ref)
% 				CHI2.ref.ionp(timetag,:) = chi2_ref.ionp;					% 電離層(lgpから算出)(ref)
% 				CHI2.ref.ionl(timetag,:) = chi2_ref.ionl;					% 電離層(lglから算出,Nを含む)(ref)

				%--- 異常値検出された衛星番号の格納
				%------------------------------------------
				REJ.rov.mp1(timetag,:)=rej_rov.mp1;
				REJ.rov.mp2(timetag,:)=rej_rov.mp2;
				REJ.rov.mw(timetag,:)=rej_rov.mw;
				REJ.rov.lgl(timetag,:)=rej_rov.lgl;

				REJ.ref.mp1(timetag,:)=rej_ref.mp1;
				REJ.ref.mp2(timetag,:)=rej_ref.mp2;
				REJ.ref.mw(timetag,:)=rej_ref.mw;
				REJ.ref.lgl(timetag,:)=rej_ref.lgl;

				%--- 異常値検出衛星の除外
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

				%--- 線形結合格納配列の除外衛星のNaN化
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
		%----- 相対測位(カルマンフィルタ)
		%------------------------------------------------------------------------------------------------------

		%--- 共通衛星の抽出
		%--------------------------------------------
		[prn.c,a,b]=intersect(prn.rov.v,prn.ref.v);													% 共通衛星
		data1=data1(a,:);																			% 観測データ(共通衛星, rov)
		data2=data2(b,:);																			% 観測データ(共通衛星, ref)
		no_sat=length(prn.c);																		% 衛星数(共通衛星)

		%--- カルマンフィルタの設定(1/2)
		% 次元調節は基準衛星決定後に行う
		%--------------------------------------------
		if timetag == 1 | isnan(Kalx_f(1)) % | timetag-timetag_o > 5								% 1エポック目
			Kalx_p=[x1(1:3); repmat(0,nx.u-3,1)];													% 初期値
		else																						% 2エポック以降
			%--- 状態遷移行列・システム雑音行列生成
			%--------------------------------------------
			[F,Q]=FQ_state_all6(nxo,round((time1.mjd-time_o.mjd)*86400),est_prm,6);

			%--- ECEF(WGS84)からLocal(ENU)に変換
			%--------------------------------------------
			Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),est_prm.refpos);

			%--- カルマンフィルタ(時間更新)
			%--------------------------------------------
			[Kalx_p, KalP_p] = filtekf_pre(Kalx_f,KalP_f,F,Q);

			%--- Local(ENU)からECEF(WGS84)に変換
			%--------------------------------------------
			Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),est_prm.refpos);
		end

		if est_prm.statemodel.pos==4, Kalx_p(1:3)=x1(1:3);, end										% SPPの解で置換

		%--- 観測更新の計算(反復可能)
		%--------------------------------------------
		if ~isnan(x1(1)) & length(prn.c)>3
			for nn=1:est_prm.iteration

				%--- 初期化
				%--------------------------------------------
				sat_xyz1=[];  sat_xyz_dot1=[];  dtsv1=[];  ion1=[];  trop1=[];
				sat_xyz2=[];  sat_xyz_dot2=[];  dtsv2=[];  ion2=[];  trop2=[];
				azi1=[];  ele1=[];  rho1=[];  ee1=[];  tgd1=[];  tzd1=[];  tzw1=[];
				azi2=[];  ele2=[];  rho2=[];  ee2=[];  tgd2=[];  tzd2=[];  tzw2=[];

				%--- 幾何学的距離, 仰角, 方位角, 電離層, 対流圏の計算
				%--------------------------------------------
				for k = 1:length(prn.c)
					% 幾何学的距離(放送暦/精密暦)
					%--------------------------------------------
					[rho1(k,1),sat_xyz1(k,:),sat_xyz_dot1(k,:),dtsv1(k,:)]=...
							geodist_mix(time1,eph_prm,ephi1,prn.c(k),Kalx_p,dtr1,est_prm);
					[rho2(k,1),sat_xyz2(k,:),sat_xyz_dot2(k,:),dtsv2(k,:)]=...
							geodist_mix(time2,eph_prm,ephi2,prn.c(k),est_prm.refpos,dtr2,est_prm);
					tgd1(k,:)=eph_prm.brd.data(33,ephi1(prn.c(k)));									% TGD(相対測位では不要)
					tgd2(k,:)=eph_prm.brd.data(33,ephi2(prn.c(k)));									% TGD(相対測位では不要)

					%--- 仰角, 方位角, 偏微分係数の計算
					%--------------------------------------------
					[ele1(k,1),azi1(k,1),ee1(k,:)]=azel(Kalx_p,sat_xyz1(k,:));
					[ele2(k,1),azi2(k,1),ee2(k,:)]=azel(est_prm.refpos,sat_xyz2(k,:));

					%--- 電離層遅延 & 対流圏遅延
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

				%--- 対流圏遅延のマッピング関数
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

				%--- 電離層遅延のマッピング関数
				%--------------------------------------------
				Mi1=1./sqrt(1-(6371000.*cos(ele1)/(6371000+450000)).^2);							% mapping function
				Mi2=1./sqrt(1-(6371000.*cos(ele2)/(6371000+450000)).^2);							% mapping function

				%--- Single Difference
				%--------------------------------------------
				Ysdp1 = data1(:,2) - data2(:,2);													% CA
				Ysdp2 = data1(:,6) - data2(:,6);													% PY
				Ysdl1 = data1(:,1) - data2(:,1);													% L1
				Ysdl2 = data1(:,5) - data2(:,5);													% L2

				%--- 利用可能な衛星のインデックス
				%--------------------------------------------
				if est_prm.freq==1
					ii=find(~isnan(Ysdp1+Ysdl1+rho1+rho2) & ...
							ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% 利用可能な衛星のインデックス
				else
					ii=find(~isnan(Ysdp1+Ysdp2+Ysdl1+Ysdl2+rho1+rho2) & ...
							ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% 利用可能な衛星のインデックス
				end

				%--- 衛星数が4未満の場合
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

				% 衛星PRNの順番を決定(基準衛星を1番目に配置)
				%--------------------------------------------
				b=sat_order(prn.c,prn.o,ele1,ii,50);

				%--- SD→DD変換行列と仰角順にソート(高→低)
				%--------------------------------------------
				prn.u=prn.c(ii(b));																	% 使用衛星PRN
				TD=[-ones((length(prn.u)-1),1) eye((length(prn.u)-1))];								% 変換行列
				OO=zeros((length(prn.u)-1)); II=eye((length(prn.u)-1));								% ゼロ行列,単位行列

				%--- 次元とインデックスの設定(使用衛星)
				%--------------------------------------------
				ns=length(prn.u);																	% 使用衛星数
				ix.u=1:nx.u; nx.x=nx.u;																% 受信機位置

				switch est_prm.statemodel.trop														% 対流圏遅延
				case 0, ix.T=[]; nx.x=nx.x+nx.T;													% 推定なし
				case 1, ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;											% ZWD推定
				case 2, ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;											% ZTD推定
				end

				switch est_prm.statemodel.ion														% 電離層遅延
				case 0, ix.i=[]; nx.i=0; nx.x=nx.x+nx.i;											% 推定なし
				case 1, ix.i=nx.x+(1:ns-1); nx.i=length(ix.i); nx.x=nx.x+nx.i;						% DDID推定
				case 2, ix.i=nx.x+(1:ns); nx.i=length(ix.i); nx.x=nx.x+nx.i;						% SDID推定
				case 3, ix.i=nx.x+(1:ns); nx.i=length(ix.i); nx.x=nx.x+nx.i;						% SDZID推定
				case 4, ix.i=nx.x+(1:2);  nx.i=length(ix.i); nx.x=nx.x+nx.i;						% ZID推定
				case 5, ix.i=nx.x+(1:4);  nx.i=length(ix.i); nx.x=nx.x+nx.i;						% ZID+dZID推定
				end

				ix.n=nx.x+(1:est_prm.freq*(ns-1)); nx.n=length(ix.n); nx.x=nx.x+nx.n;				% 整数値バイアス

				%--- 初期値用(DD)
				%--------------------------------------------
				Ndd1=[];Ndd2=[];
				Nsd1=(lam1*Ysdl1-Ysdp1-2*(ion1-ion2)*0)/lam1;										% L1整数値バイアス(SD)
				Ndd1=TD*Nsd1(ii(b));																% L1整数値バイアス(DD)
				if est_prm.freq==2
					Nsd2=(lam2*Ysdl2-Ysdp2-2*(f1/f2)^2*(ion1-ion2)*0)/lam2;							% L2整数値バイアス(SD)
					Ndd2=TD*Nsd2(ii(b));															% L2整数値バイアス(DD)
				end

				%--- Fix解として利用できるもの(変換済み)
				%--------------------------------------------
				[prn,Ndd1,Ndd2,N_ref,Fixed_N]=selfixed(prn,Ndd1,Ndd2,Fixed_N,est_prm);				% prn.fix:固定可, prn.float:固定不可

				%--- 対流圏遅延推定用(初期値)
				%--------------------------------------------
				switch est_prm.statemodel.trop
				case 0, trop12p=[];																	% 推定なし
				case 1, trop12p=[tzw1; tzw2];														% ZWD推定
				case 2, trop12p=[tzd1+tzw1; tzd2+tzw2];												% ZTD推定
				end

				%--- 電離層遅延推定用(初期値)
				%--------------------------------------------
				switch est_prm.statemodel.ion
				case 0, ion12p=[];																	% 推定なし
				case 1, ion12p=TD*(ion1(ii(b))-ion2(ii(b)));										% DDID推定
				case 2, ion12p=(ion1(ii(b))-ion2(ii(b)));											% SDID推定
				case 3, ion12p=(ion1(ii(b))./Mi1(ii(b))-ion2(ii(b))./Mi2(ii(b)));					% SDZID推定
				case 4, ion12p=[1.0; 1.0];															% ZID推定
				case 5, ion12p=[1.0; 0; 1.0; 0];													% ZID+dZID推定
				end

				%--- カルマンフィルタの設定(2/2)と次元調節
				%--------------------------------------------
				if timetag == 1 | isnan(Kalx_f(1)) % | timetag-timetag_o > 5						% 1エポック目(初期値設定)
					Kalx_p=[Kalx_p(1:3); repmat(0,nx.u-3,1)];										% 受信機位置
					switch est_prm.statemodel.trop
					case {1,2}, Kalx_p=[Kalx_p; trop12p];											% 対流圏遅延(各局)
					end
					switch est_prm.statemodel.ion
					case {1,2,3,4,5}, Kalx_p=[Kalx_p; ion12p];										% 電離層遅延(DD or SD)
					end
					if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; Ndd1; Ndd2];, end				% 整数値バイアス(DD)

					KalP_p=[est_prm.P0.std_dev_p,est_prm.P0.std_dev_v,...
							est_prm.P0.std_dev_a,est_prm.P0.std_dev_j];
					KalP_p=blkdiag(diag(KalP_p(ix.u)),eye(nx.T)*est_prm.P0.std_dev_T,...
							eye(nx.i)*est_prm.P0.std_dev_i,eye(nx.n)*est_prm.P0.std_dev_n).^2;		% 初期共分散行列
				else																				% 2エポック目以降(次元調節)
					%--- 次元調節後の状態変数と共分散
					%--------------------------------------------
					[Kalx_p,KalP_p]=...
							state_adjust_dd5(prn,Kalx_p,KalP_p,nxo,est_prm,ion12p,Ndd1,Ndd2,N_ref);	% 一段予測値 / 共分散行列
				end
				Ndd1=Kalx_p(ix.n(1:ns-1));															% L1整数値バイアス(DD)
				if est_prm.freq==2
					Ndd2=Kalx_p(ix.n(ns:end));														% L2整数値バイアス(DD)
				end

				%--- 対流圏遅延推定用
				%--------------------------------------------
				switch est_prm.statemodel.trop
				case 0, 
					trop12=trop1(ii(b))-trop2(ii(b)); Mwu=[];										% Troposphere(SD)
					trop12=TD*trop12;																% Troposphere(DD)
				case 1, 
					trop1=Md1.*tzd1+Mw1.*Kalx_p(ix.T(1));											% ZWD推定用
					trop2=Md2.*tzd2+Mw2.*Kalx_p(ix.T(2));											% ZWD推定用
					trop12=trop1(ii(b))-trop2(ii(b));												% Troposphere(SD)
					Mwu=[TD*Mw1(ii(b)) -TD*Mw2(ii(b))];												% マッピング関数(行列)
					trop12=TD*trop12;																% Troposphere(DD)
				case 2, 
					trop1=Md1.*tzd1+Mw1.*(Kalx_p(ix.T(1))-tzd1);									% ZTD推定用
					trop2=Md2.*tzd2+Mw2.*(Kalx_p(ix.T(2))-tzd2);									% ZTD推定用
					trop12=trop1(ii(b))-trop2(ii(b));												% Troposphere(SD)
					Mwu=[TD*Mw1(ii(b)) -TD*Mw2(ii(b))];												% マッピング関数(行列)
					trop12=TD*trop12;																% Troposphere(DD)
				end

				%--- 電離層遅延推定用
				%--------------------------------------------
				switch est_prm.statemodel.ion
				case 0, 
					ion12=ion1(ii(b))-ion2(ii(b));													% Ionosphere(SD,model)
					MI=TD;																			% 係数行列
					ion12=MI*ion12;																	% Ionosphere(DD)
				case 1, 
					ion12=Kalx_p(ix.i);																% Ionosphere(DD,estimate)
					MI=II;
				case 2, 
					ion12=Kalx_p(ix.i);																% Ionosphere(SD,estimate)
					MI=TD;																			% 係数行列
					ion12=MI*ion12;																	% Ionosphere(DD)
				case 3, 
					ion12=Kalx_p(ix.i);																% Ionosphere(SD,estimate)
% 					Miu=(Mi1(ii(b))+Mi2(ii(b)))/2;
					Miu=Mi1(ii(b));
					MI=[-Miu(1)*ones(length(Miu)-1,1) diag(Miu(2:end))];							% 係数行列
					ion12=MI*ion12;																	% Ionosphere(DD)
				case 4, 
					ion1=Mi1.*Kalx_p(ix.i(1));														% ZID推定用
					ion2=Mi2.*Kalx_p(ix.i(2));														% ZID推定用
					ion12=ion1(ii(b))-ion2(ii(b));													% Ionosphere(SD)
					MI=[TD*Mi1(ii(b)) -TD*Mi2(ii(b))];												% マッピング関数(行列)
					ion12=TD*ion12;																	% Ionosphere(DD)
				case 5, 
					ion1=Mi1.*Kalx_p(ix.i(1));														% ZID推定用
					ion2=Mi2.*Kalx_p(ix.i(3));														% ZID推定用
					ion12=ion1(ii(b))-ion2(ii(b));													% Ionosphere(SD)
					MI=[TD*Mi1(ii(b)) repmat(0,ns-1,1) -TD*Mi2(ii(b)) repmat(0,ns-1,1)];			% マッピング関数(行列)
					ion12=TD*ion12;																	% Ionosphere(DD)
				end

				%--- DD観測モデル(Y,H,h)
				%--------------------------------------------
				if est_prm.freq==1																	% 1周波(L1, CA)
					%--- DD観測モデル(L1)
					%--------------------------------------------
					Y=TD*lam1*Ysdl1(ii(b));															% DD obs(L1)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu -MI lam1*II];										% DD obs matrix(L1)
					else
						H=[TD*ee1(ii(b),:) Mwu     lam1*II];										% DD obs matrix(L1)
					end
					h=TD*(rho1(ii(b))-rho2(ii(b)))+trop12-ion12+lam1*Ndd1;							% DD obs model(L1)

					%--- DD観測モデル(L1,CA)
					%--------------------------------------------
					if est_prm.pr_flag==1															% 擬似距離も利用
						Y=[Y; TD*Ysdp1(ii(b))];														% DD obs(L1, CA)
						if est_prm.statemodel.ion~=0
							H=[H; TD*ee1(ii(b),:) Mwu  MI  OO];										% DD obs matrix(L1,CA)
						else
							H=[H; TD*ee1(ii(b),:) Mwu      OO];										% DD obs matrix(L1,CA)
						end
						h=[h; TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12];							% DD obs model(L1,CA)
					end
				else																				% 2周波(L1, L2, CA, PY)
					%--- DD観測モデル(L1,L2)
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

					%--- DD観測モデル(L1,L2,CA,PY)
					%--------------------------------------------
					if est_prm.pr_flag==1															% 擬似距離も利用
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
				H=[H(:,1:3) repmat(0,size(H,1),nx.u-3) H(:,4:end)];									% キネマティックのため

				%--- 偏微分をLocal(ENU)用に変換(キネマティック用)
				%--------------------------------------------
				H(:,1:3)=(LL*H(:,1:3)')';

				%--- 観測雑音生成
				%--------------------------------------------
				if est_prm.ww == 0
					PR1a=repmat(est_prm.obsnoise.PR1,length(prn.u),1);								% コードの分散
					PR2a=repmat(est_prm.obsnoise.PR2,length(prn.u),1);								% コードの分散
					PR1b=repmat(est_prm.obsnoise.PR1,length(prn.u),1);								% コードの分散
					PR2b=repmat(est_prm.obsnoise.PR2,length(prn.u),1);								% コードの分散
					Ph1a=repmat(est_prm.obsnoise.Ph1,length(prn.u),1);								% 搬送波の分散
					Ph2a=repmat(est_prm.obsnoise.Ph2,length(prn.u),1);								% 搬送波の分散
					Ph1b=repmat(est_prm.obsnoise.Ph1,length(prn.u),1);								% 搬送波の分散
					Ph2b=repmat(est_prm.obsnoise.Ph2,length(prn.u),1);								% 搬送波の分散
				else
					PR1a=(est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);								% コードの分散(重み考慮)
					PR2a=(est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);								% コードの分散(重み考慮)
					PR1b=(est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);								% コードの分散(重み考慮)
					PR2b=(est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);								% コードの分散(重み考慮)
					Ph1a=(est_prm.obsnoise.Ph1./sin(ele1(ii(b))).^2);								% 搬送波の分散(重み考慮)
					Ph2a=(est_prm.obsnoise.Ph2./sin(ele1(ii(b))).^2);								% 搬送波の分散(重み考慮)
					Ph1b=(est_prm.obsnoise.Ph1./sin(ele2(ii(b))).^2);								% 搬送波の分散(重み考慮)
					Ph2b=(est_prm.obsnoise.Ph2./sin(ele2(ii(b))).^2);								% 搬送波の分散(重み考慮)
% 					PR1a=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);			% コードの分散(重み考慮)
% 					PR2a=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);			% コードの分散(重み考慮)
% 					PR1b=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);			% コードの分散(重み考慮)
% 					PR2b=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);			% コードの分散(重み考慮)
% 					Ph1a=(est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele1(ii(b))).^2);			% 搬送波の分散(重み考慮)
% 					Ph2a=(est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele1(ii(b))).^2);			% 搬送波の分散(重み考慮)
% 					Ph1b=(est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele2(ii(b))).^2);			% 搬送波の分散(重み考慮)
% 					Ph2b=(est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele2(ii(b))).^2);			% 搬送波の分散(重み考慮)
				end
				PR1 = diag(PR1a+PR1b); PR2 = diag(PR2a+PR2b);										% コードの分散(1重差)
				Ph1 = diag(Ph1a+Ph1b); Ph2 = diag(Ph2a+Ph2b);										% 搬送波の分散(1重差)
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

				%--- イノベーション
				%--------------------------------------------
				zz = Y - h;

				% 事前残差の検定(χ2検定)
				%--------------------------------------------
				[zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=...
						chi2test_dd(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,0.000001);

				%--- 観測更新の準備(Floatで取扱うものだけ)
				%--------------------------------------------
				if est_prm.ambf==1
					if length(prn.float)>1															% Float解を求める必要がある場合
						ind=[]; for i=prn.float(2:end), ind=[ind,find(prn.u(2:end)==i)];, end		% 整数値バイアスの部分(prn.float)
						if est_prm.freq==1
							indkk=[ix.u,ix.T,ix.i,ix.n(ind)];										% 推定する部分のインデックス(今エポック)
						else
							indkk=[ix.u,ix.T,ix.i,ix.n([ind,length(prn.u)-1+ind])];					% 推定する部分のインデックス(今エポック)
						end
						H=H(:,indkk);																% インデックスで抽出
						Kalx_p=Kalx_p(indkk);														% インデックスで抽出
						KalP_p=KalP_p(indkk,indkk);													% インデックスで抽出
					else																			% Float解を求める必要がない場合(全てFix解)
						H=H(:,[ix.u,ix.T,ix.i]);													% インデックスで抽出
						Kalx_p=Kalx_p([ix.u,ix.T,ix.i]);											% インデックスで抽出
						KalP_p=KalP_p([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i]);							% インデックスで抽出
					end
				end

				%--- 整数値バイアス(Fix)を拘束条件として利用
				%--------------------------------------------
				if est_prm.ambf==2
					if est_prm.freq==1
						iref=find(prn.o==prn.u(1));													% 基準衛星の変化のチェック
						Nc1=Fixed_N{1}(prn.u(2:end),1);												% 拘束条件で利用可能な整数値バイアス(L1)
						CC1=eye(nx.n/2);															% 観測行列で利用する単位行列
						if ~isempty(find(~isnan(Nc1))) & iref==1									% 拘束条件が利用できるかどうかの判定
							Nc1=Nc1-Kalx_p(ix.n(1:nx.n/2));											% 残差
							ic1=find(isnan(Nc1));													% NaNを除外するためのインデックス
							if ~isempty(ic1), Nc1(ic1)=[]; CC1(ic1,:)=[];, end						% NaNの部分を除外
							zz=[zz;Nc1];															% 拘束条件を追加
							H=[H; zeros(length(Nc1),nx.u+nx.T+nx.i) CC1];							% 拘束条件を追加
							RN=2*(ones(length(Nc1))+eye(length(Nc1)))*1e-4;							% 拘束条件部分の観測雑音
							R=blkdiag(R,RN);														% 拘束条件を追加
						end
					else
						iref=find(prn.o==prn.u(1));													% 基準衛星の変化のチェック
						Nc1=Fixed_N{1}(prn.u(2:end),1); Nc2=Fixed_N{2}(prn.u(2:end),1);				% 拘束条件で利用可能な整数値バイアス(L1)
						CC1=eye(nx.n/2); CC2=eye(nx.n/2);											% 観測行列で利用する単位行列
						if ~isempty(find(~isnan(Nc1))) & ~isempty(find(~isnan(Nc2))) & iref==1		% 拘束条件が利用できるかどうかの判定
							Nc1=Nc1-Kalx_p(ix.n(1:nx.n/2)); Nc2=Nc2-Kalx_p(ix.n(nx.n/2+1:end));		% 残差
							ic1=find(isnan(Nc1));													% NaNを除外するためのインデックス
							if ~isempty(ic1), Nc1(ic1)=[]; CC1(ic1,:)=[];, end						% NaNの部分を除外
							ic2=find(isnan(Nc2));													% NaNを除外するためのインデックス
							if ~isempty(ic2), Nc2(ic2)=[]; CC2(ic2,:)=[];, end						% NaNの部分を除外
							zz=[zz;Nc1;Nc2];														% 拘束条件を追加
							H=[H; zeros(length(Nc1)+length(Nc2),nx.u+nx.T+nx.i) blkdiag(CC1,CC2)];	% 拘束条件を追加
							RN=2*(ones(length(Nc1)+length(Nc2))+eye(length(Nc1)+length(Nc2)))*1e-4;	% 拘束条件部分の観測雑音
							R=blkdiag(R,RN);														% 拘束条件を追加
						end
					end
				end

				%--- ECEF(WGS84)からLocal(ENU)に変換
				%--------------------------------------------
				Kalx_p(1:3)=xyz2enu(Kalx_p(1:3),est_prm.refpos);

				%--- カルマンフィルタ(観測更新)
				%--------------------------------------------
				[Kalx_f, KalP_f,V] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);
% 				[Kalx_f, KalP_f] = filtsrcf_upd(zz, H, R, Kalx_p, KalP_p);

				%--- Local(ENU)からECEF(WGS84)に変換
				%--------------------------------------------
				Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),est_prm.refpos);

				%--- Float解の次元
				%--------------------------------------------
				% 電離層遅延と整数値バイアスについては, 時間更新のために利用する必要があるから
				nxo.u=nx.u;
				nxo.T=nx.T;
				nxo.i=nx.i;
				nxo.n=est_prm.freq*(length(prn.float)-1);
				nxo.x=nxo.u+nxo.T+nxo.i+nxo.n;

				prn.o=prn.u;					% 観測更新のために必要
				prn.float_o=prn.float;			% 観測更新のために必要
			end

			%--- ECEF(WGS84)からLocalに変換
			%--------------------------------------------
			Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),est_prm.refpos);

			%--- Ambiguity Resolution & Validation
			%--------------------------------------------
			[prn,Fix_X,Fix_N,Fixed_N,s,KalP_f_fix,ratio]=...
					ambfix3(prn,ele1,ele2,Kalx_p,Kalx_f,KalP_f,Fixed_N,ix,nx,est_prm,H,ratio_l);

			%--- LocalからECEF(WGS84)に変換
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

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos3 = xyz2enu(Kalx_f(1:3),est_prm.rovpos)';											% ENUに変換(float)
		est_pos4 = xyz2enu(Fix_X(1:3),est_prm.rovpos)';												% ENUに変換(fix)

		%--- 結果格納(Float解)
		%--------------------------------------------
		Result.float.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% 時刻
		Res.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];						% 時刻
		if ~isempty(zz)
			%--- 残差
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

			%--- 結果格納(Float解)
			%--------------------------------------------
			Result.float.pos(timetag,:)=[Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1]];	% 位置
			switch est_prm.statemodel.ion
			case 1,
				Result.float.dion(timetag,prn.u(2:end))=Kalx_f(ix.i);								% 電離層遅延
			case {2,3}
				Result.float.dion(timetag,prn.u)=Kalx_f(ix.i);										% 電離層遅延
			case 4
				Result.float.dion(timetag,1:2)=Kalx_f(ix.i);										% 電離層遅延
			case 5
				Result.float.dion(timetag,1:4)=Kalx_f(ix.i);										% 電離層遅延
			end
			if est_prm.statemodel.trop~=0
				Result.float.dtrop(timetag,:)=Kalx_f(ix.T);											% 対流圏遅延
			end
			if length(prn.float)>1
				Float_N=Kalx_f(nx.u+nx.T+nx.i+1:end);												% Float解
				Result.float.amb{1,prn.u(1)}(timetag,prn.float(2:end))=...
						Float_N(1:length(Float_N)/est_prm.freq);									% 整数値バイアス(L1)
				if est_prm.freq==2
					Result.float.amb{2,prn.u(1)}(timetag,prn.float(2:end))=...
							Float_N(1+length(Float_N)/est_prm.freq:end);							% 整数値バイアス(L2)
				end
			end
			Result.float.ps(timetag,1:3)=diag(KalP_f(1:3,1:3));										% 位置
		end

		%--- 結果格納(Fix解)
		%--------------------------------------------
		Result.fix.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% 時刻
		Result.fix.ratio(timetag,1)=ratio;															% 尤度比
		if ~isempty(zz)
			if ~isnan(Fix_X(1))
				Result.fix.pos(timetag,:)=[Fix_X(1:3)', xyz2llh(Fix_X(1:3)).*[180/pi 180/pi 1]];	% 位置
				switch est_prm.statemodel.ion
				case 1,
					Result.fix.dion(timetag,prn.u(2:end))=Fix_X(ix.i);								% 電離層遅延
				case {2,3}
					Result.fix.dion(timetag,prn.u)=Fix_X(ix.i);										% 電離層遅延
				case 4
					Result.fix.dion(timetag,1:2)=Fix_X(ix.i);										% 電離層遅延
				case 5
					Result.fix.dion(timetag,1:4)=Fix_X(ix.i);										% 電離層遅延
				end
				if est_prm.statemodel.trop~=0
					Result.fix.dtrop(timetag,:)=Fix_X(ix.T);										% 対流圏遅延
				end
				Result.fix.amb{1,prn.u(1)}(timetag,:)=Fixed_N{1}(:,1)';								% 整数値バイアス(L1)
				if est_prm.freq==2
					Result.fix.amb{2,prn.u(1)}(timetag,:)=Fixed_N{2}(:,1)';							% 整数値バイアス(L2)
				end
			end
			Result.fix.ps(timetag,1:3)=diag(KalP_f_fix(1:3,1:3));									% 位置
		end

		%------------------------------------------------------------------------------------------------------
		%----- 相対測位(カルマンフィルタ) ---->> 終了
		%------------------------------------------------------------------------------------------------------

		%--- 衛星変化チェック
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.u);							% 衛星変化のチェック
% 		end

		%--- 画面表示
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

		%--- 衛星格納
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

		%--- 結果書き出し
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
	%--- end 判定
	%--------------------------------------------
	if  feof(fpo1) | feof(fpo2), break;, end
end
fclose('all');
toc
%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算 ---->> 終了
%-----------------------------------------------------------------------------------------

%--- MATに保存
%--------------------------------------------
matname=sprintf('Relative_%s_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','Res','OBS','LC');

%--- 測位結果プロット
%--------------------------------------------
plot_data([est_prm.dirs.result,matname]);

% %--- KML出力
% %--------------------------------------------
% kmlname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
%kmlname2=sprintf('Float_%s_%s_%4d%02d%02d_%02d-%02d.kml',...
 		%est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% kmlname3=sprintf('Fix_%s_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp);
fn_kml = 'result.kml';
point_color = 'G';                                                          %マーカの色指定'Y','M','C','R','G','B','W','K'
track_color = 'G';                                                          %取り敢えず指定する（いじらなくてOK）
data.time = Result.float.time(:,1:6);                      %Y M D H M S lat lon alt
data.pos =  Result.float.pos(:,4:6);
output_kml(fn_kml,data,track_color,point_color);
% output_kml([est_prm.dirs.result,kmlname3],Result.fix);
% 
% %--- NMEA出力
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
% %--- INS用
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
