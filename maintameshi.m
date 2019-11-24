%-------------------------------------------------------------------------------%
%                 杉本・久保研版 GPS測位演算ﾌﾟﾛｸﾞﾗﾑ　Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS測位演算プログラム(PPP版)
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
%     1. 単独測位 (最小二乗法)
%     2. クロックジャンプ補正→補正済み観測量を作成
%     3. 異常値検出
%     4. 単独測位 or PPP (カルマンフィルタ)
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
% read_eph2.m         : エフェメリスの取得
% read_ionex2.m       : IONEXデータ取得
% read_sp3.m          : 精密暦データ取得
% read_obs_epo_data2.m: OBSエポック情報解析 & OBS観測データ取得
%-------------------------------------------------------------------------------
% cal_time2.m         : 指定時刻のGPS週番号・ToW・ToDの計算
% clkjump_repair2.m   : 受信機時計の飛びの検出/修正
% mjuliday.m          : MJDの計算
% weekf.m             : WEEK, TOW の計算
%-------------------------------------------------------------------------------
% azel.m              : 仰角, 方位角, 偏微分係数の計算
% geodist_mix2.m      : 幾何学的距離等の計算(放送暦,精密暦)
% interp_lag.m        : ラグランジュ補間
% pointpos3.m         : 単独測位演算
% sat_pos2.m          : 衛星軌道計算(位置・速度・時計誤差)
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
% chi2test            : 事前残差の検定(χ2検定)
% lc_lim              : 線形結合によるサイクルスリップ検出閾値の計算
% lc_chi2             : 線形結合のカイ二乗検定
% lc_chi2r            : 線形結合のカイ二乗検定(連続エポック)
% outlier_detec.m     : 線形結合による異常値検定
% pre_chi2.m          : 線形結合のカイ二乗検定の閾値, 無相関化行列計算
%-------------------------------------------------------------------------------
% measuremodel2.m     : 観測モデル作成(h,H,R) + 幾何学距離
% obs_comb2.m         : 各種線形結合の計算
% obs_vec2.m          : 観測量ベクトル作成
%-------------------------------------------------------------------------------
% FQ_state_all6.m     : 状態モデルの生成
%-------------------------------------------------------------------------------
% filtekf_pre.m       : カルマンフィルタの時間更新
% filtekf_upd.m       : カルマンフィルタの観測更新
%-------------------------------------------------------------------------------
% prn_check.m         : 衛星変化の検出
% select_prn.m        : 使用衛星の選択
% state_adjust2.m     : 衛星変化時の次元調節
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
% tide.m              : 潮汐による変動
%-------------------------------------------------------------------------------
% recpos3.m           : 電子基準点の局番号検索
%-------------------------------------------------------------------------------
% 
% ・2周波対応
% ・キネマティック対応
% ・GR, UoC, Traditional 各種モデルに対応
% ・対流圏推定に対応
% ・電離層推定に対応
% 
% <課題>
% ・データ更新間隔が 1[sec]以下の場合× → 読み飛ばしを修正
% ・異常値検出(線形結合, 事前残差・事後残差検査)
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov     : 可視衛星(rov)
%  prn.rovu    : 使用衛星(rov)
%  prn.v       : 可視衛星(rov) prn.rovと同一
%  prn.u       : 使用衛星(rov)
%  prn.o       : 前エポックの使用衛星(rov)
% 
% 更新間隔が1[Hz]以上でもできるように修正
% → それに伴い, 他にも修正している部分あり
% 
%-------------------------------------------------------------------------------
% latest update : 2009/02/25 by Fujita
%-------------------------------------------------------------------------------
% 
% ・GLONASS対応
% 
% <課題>
% ・衛星加速度・回転補正の考察
% ・各種雑音, パラメータ設定の見直し(GLONASS測位に限定)
% ・電離層等の推定手法
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov.v   : 可視衛星(rov)
%  prn.rov.vg  : GPSの可視衛星(rov)
%  prn.rov.vr  : GLONASSの可視衛星(rov)
%  prn.u       : 使用衛星
%  prn.ug      : GPSの使用衛星
%  prn.ur      : GLONASSの使用衛星
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/12 by Yanase, Tanaka
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
% 
% ・地球固体潮汐補正対応
%
% <課題>
% ・時間変化に対応した真値との比較, 期間を長くして試す
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/26 by Nishikawa, Nagano
%-------------------------------------------------------------------------------

clear all
clc

%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算
%-----------------------------------------------------------------------------------------
addpath ./toolbox_gnss/

%--- 初期設定取得
%--------------------------------------------
cd('./INI/');
inifile=input('初期設定ファイル名を拡張子なしで入力して下さい>> \n','s');
eval(inifile);
cd ..

%--- ファイル名生成とファイル取得
%--------------------------------------------
est_prm.rovpos=est_prm.rovpos;
est_prm=fileget2(est_prm);

if ~exist(est_prm.dirs.result)
	mkdir(est_prm.dirs.result);			% 結果のディレクトリ生成
end

tic
timetag=0;
timetag_o=0;
% change_flag=0;
dtr_o=[];
jump_width_all=[];
rej=[];
refl=[];

%--- 定数(グローバル変数)
%--------------------------------------------
% phisic_const;

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
freq.g1=1.57542e9;						% L1 周波数(GPS)
wave.g1=C/1.57542e9;					% L1 波長(GPS)
freq.g2=1.22760e9;						% L2 周波数(GPS)
wave.g2=C/1.22760e9;					% L2 波長(GPS)

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

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
fpo = fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');
fpn = fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');
fpcsv = csvread([est_prm.dirs.obs,est_prm.file.csv]);
if est_prm.g_nav==1
	fpg = fopen([est_prm.dirs.obs,est_prm.file.rov_g],'rt');
else
	fpg = [];
end

if fpo==-1
	fprintf('oファイル%sを開けません.\n',est_prm.file.rov_o);				% Rov obs(エラー処理)
	exit
end
if est_prm.n_nav==1
	if fpn==-1
	fprintf('nファイル%sを開けません.\n',est_prm.file.rov_n);				% Rov nav(GPS)(エラー処理)
	exit
	end
end
if est_prm.g_nav==1
	if fpg==-1
	fprintf('gファイル%sを開けません.\n',est_prm.file.rov_g);				% Rov nav(GLONASS)(エラー処理)
	exit
	end
end

%--- obs ヘッダー解析
%--------------------------------------------
[tofh,toeh,s_time,e_time,app_xyz,no_obs,TYPES,dt,Rec_type]=read_obs_h(fpo);

% エフェメリス読込み(Klobuchar model パラメータの抽出も)
%--------------------------------------------
[eph_prm.brd.data, ion_prm.klob.ionab]=read_eph2(est_prm,fpn,fpg);

%--- IONEXデータ取得
%--------------------------------------------
if est_prm.i_mode==2
	[ion_prm.gim]=read_ionex2([est_prm.dirs.ionex,est_prm.file.ionex]);
else
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end
if est_prm.i_mode==3
	load('ENMdata20080922_1.mat');
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- 精密暦の読込み
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);

	if strcmp(est_prm.ephsrc,'igu')
        Data_sp3=eph_prm.sp3.data;
		eph_prm.sp3.data=eph_prm.sp3.data(size(Data_sp3,1)/2+1:end,:,:);
% % 		eph_prm.sp3.data=eph_prm.sp3.data(1:size(Data_sp3,1)/2,:,:);
	end
else
	eph_prm.sp3.data=[];
end

%--- 設定情報の出力
%--------------------------------------------
datname=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol  = fopen([est_prm.dirs.result,datname],'w');								% 結果書き出しファイルのオープン
output_log2(f_sol,time_s,time_e,est_prm,1);

%--- 次元の設定(状態モデルごと)
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
switch est_prm.statemodel.hw
case 0, nx.b=0;
case 1, nx.b=est_prm.freq*2; if est_prm.obsmodel==9, nx.b=3; end
end
switch est_prm.statemodel.trop
case 0, nx.T=0;
case 1, nx.T=1;
case 2, nx.T=1;
case 3, nx.T=1+2;
case 4, nx.T=1+2;
end
switch est_prm.statemodel.ion
case 0, nx.i=0;
case 1, nx.i=1;
case 2, nx.i=1+1;
case 3, nx.i=1+2;
end

%--- 配列の準備
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;
less_frag=0;
%--- SPP用
%--------------------------------------------
Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% 時刻
Result.spp.pos(1:tt,1:6)=NaN;													% 位置
Result.spp.dtr(1:tt,1:1)=NaN;													% 受信機時計誤差
Result.spp.prn{1}(1:tt,1:61)=NaN;												% 可視衛星
Result.spp.prn{2}(1:tt,1:61)=NaN;												% 使用衛星
Result.spp.prn{3}(1:tt,1:3)=NaN;												% 衛星数

%--- PPP用
%--------------------------------------------
Result.ppp.time(1:tt,1:10)=NaN; Result.ppp.time(:,1)=1:tt;						% 時刻
Result.ppp.pos(1:tt,1:6)=NaN;													% 位置
Result.ppp.lostsat(1:tt)=NaN;                                                   % 3以下の衛星時のtimetag
%Result.ppp.error(1:tt)=NaN;
Result.ppp.dtr(1:tt,1:2)=NaN;													% 受信機時計誤差
Result.ppp.hwb(1:tt,1:4)=NaN;													% HWB
Result.ppp.dion(1:tt,1:3)=NaN;													% 電離層遅延
Result.ppp.dtrop(1:tt,1:3)=NaN;													% 対流圏遅延
for j=1:2, Result.ppp.amb{j,1}(1:tt,1:61)=NaN;, end								% 整数値バイアス
Result.ppp.prn{1}(1:tt,1:61)=NaN;												% 可視衛星
Result.ppp.prn{2}(1:tt,1:61)=NaN;												% 使用衛星
Result.ppp.prn{3}(1:tt,1:8)=NaN;												% 衛星数


%--- 残差用
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% 時刻
for j=1:4, Res.pre{j,1}(1:tt,1:61)=NaN; end									% 残差(pre-fit)
for j=1:4, Res.post{j,1}(1:tt,1:61)=NaN; end									% 残差(post-fit)

%--- clock jump用
%--------------------------------------------
dtr_all(1:tt,1:2)=NaN;

%--- 観測データ用
%--------------------------------------------
OBS.rov.time(1:tt,1:10)=NaN; OBS.rov.time(:,1)=1:tt;							% 時刻
OBS.rov.ca(1:tt,1:61)=NaN; OBS.rov.py(1:tt,1:61)=NaN;							% CA, PY
OBS.rov.ph1(1:tt,1:61)=NaN; OBS.rov.ph2(1:tt,1:61)=NaN;							% L1, L2
OBS.rov.ion(1:tt,1:61)=NaN; OBS.rov.trop(1:tt,1:61)=NaN;						% Ionosphere, Troposphere
OBS.rov.ele(1:tt,1:61)=NaN; OBS.rov.azi(1:tt,1:61)=NaN;							% Elevation, Azimuth
OBS.rov.ca_cor(1:tt,1:61)=NaN; OBS.rov.py_cor(1:tt,1:61)=NaN;					% CA, PY(Corrected)
OBS.rov.ph1_cor(1:tt,1:61)=NaN; OBS.rov.ph2_cor(1:tt,1:61)=NaN;					% L1, L2(Corrected)

%--- LC用
%--------------------------------------------
LC.rov.time(1:tt,1:10)=NaN; LC.rov.time(:,1)=1:tt;								% 時刻
LC.rov.mp1(1:tt,1:61)=NaN; LC.rov.mp2(1:tt,1:61)=NaN;							% MP1, MP2
LC.rov.mw(1:tt,1:61)=NaN;														% MW
LC.rov.lgl(1:tt,1:61)=NaN; LC.rov.lgp(1:tt,1:61)=NaN;							% LGL, LGP
LC.rov.lg1(1:tt,1:61)=NaN; LC.rov.lg2(1:tt,1:61)=NaN;							% LG1, LG2
LC.rov.ionp(1:tt,1:61)=NaN; LC.rov.ionl(1:tt,1:61)=NaN;							% IONP, IONL

%--- 異常値検出用
%--------------------------------------------
LC.rov.mp1_va(1:tt,1:61)=NaN; LC.rov.mp2_va(1:tt,1:61)=NaN;						% 線形結合の分散
LC.rov.mw_va(1:tt,1:61)=NaN;
LC.rov.lgl_va(1:tt,1:61)=NaN; LC.rov.lgp_va(1:tt,1:61)=NaN;
LC.rov.lg1_va(1:tt,1:61)=NaN; LC.rov.lg2_va(1:tt,1:61)=NaN;
LC.rov.ionp_va(1:tt,1:61)=NaN; LC.rov.ionl_va(1:tt,1:61)=NaN;
LC.rov.mp1_lim(1:tt,1:61)=NaN; LC.rov.mp2_lim(1:tt,1:61)=NaN;					% 線形結合サイクルスリップ標準偏差閾値
LC.rov.mw_lim(1:tt,1:61)=NaN; LC.rov.lgl_lim(1:tt,1:61)=NaN;
% LC.rov.lgp_lim(1:tt,1:61)=NaN;LC.rov.lg1_lim(1:tt,1:61)=NaN;
% LC.rov.lg2_lim(1:tt,1:61)=NaN; LC.rov.ionp_lim(1:tt,1:61)=NaN;
% LC.rov.ionl_lim(1:tt,1:61)=NaN;

LC.rov.cs1(1:tt,1:61)=NaN;														% スリップ量推定値
LC.rov.cs2(1:tt,1:61)=NaN;
LC.rov.lgl_cs(1:tt,1:61) = NaN; LC.rov.mw_cs(1:tt,1:61) = NaN;
LC.rov.mp1_cs(1:tt,1:61) = NaN; LC.rov.mp2_cs(1:tt,1:61) = NaN;

LC_r.rov.mp1(1:tt,1:61)=NaN; LC_r.rov.mp2(1:tt,1:61)=NaN;						% 除外衛星を排除した線形結合
LC_r.rov.mw(1:tt,1:61)=NaN;
LC_r.rov.lgl(1:tt,1:61)=NaN; LC_r.rov.lgp(1:tt,1:61)=NaN;
LC_r.rov.lg1(1:tt,1:61)=NaN; LC_r.rov.lg2(1:tt,1:61)=NaN;
LC_r.rov.ionp(1:tt,1:61)=NaN; LC_r.rov.ionl(1:tt,1:61)=NaN;

CHI2.rov.mp1(1:tt,1:61)=NaN; CHI2.rov.mp2(1:tt,1:61)=NaN;						% 線形結合サイクルスリップカイ2乗検定統計量
CHI2.rov.mw(1:tt,1:61)=NaN; CHI2.rov.lgl(1:tt,1:61)=NaN;
CHI2.rov.lgp(1:tt,1:61)=NaN; CHI2.rov.lg1(1:tt,1:61)=NaN;
CHI2.rov.lg2(1:tt,1:61)=NaN; CHI2.rov.ionp(1:tt,1:61)=NaN;
CHI2.rov.ionl(1:tt,1:61)=NaN;
[CHI2.sigma, Vb, Gb] = pre_chi2(est_prm.cycle_slip.A,est_prm.cycle_slip.lc_b);	% カイ二乗検定のカイ2乗上側確立点, 無相関化行列

REJ.rov.mp1(1:tt,1:61)=NaN; REJ.rov.mp2(1:tt,1:61)=NaN;							% 線形結合サイクルスリップ除外衛星
REJ.rov.mw(1:tt,1:61)=NaN; REJ.rov.lgl(1:tt,1:61)=NaN;
% REJ.rov.lgp(1:tt,1:61)=NaN; REJ.rov.lg1(1:tt,1:61)=NaN;
% REJ.rov.lg2(1:tt,1:61)=NaN; REJ.rov.ionp(1:tt,1:61)=NaN;
% REJ.rov.ionl(1:tt,1:61)=NaN;
REJ.rej(1:tt,1:61)=NaN;


%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算 ---->> 開始
%-----------------------------------------------------------------------------------------
while 1

	%--- エポック情報取得(時刻, PRN, Dataなど)
	%--------------------------------------------
	[time,no_sat,prn.rov.v,dtrec,ephi,data]=...
			read_obs_epo_data2(fpo,est_prm,eph_prm.brd.data,no_obs,TYPES);

	% end 判定
	%--------------------------------------------
	if time_e.mjd <= time.mjd-0.1/86400, break; end							% 約 0.1 秒ｽﾞﾚまで認める

	%--- start 判定
	%--------------------------------------------
	if time_s.mjd <= time.mjd+0.1/86400											% 約 0.1 秒ｽﾞﾚまで認める
		%--- タイムタグ
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
        else
			%timetag = timetag + round((time.mjd-time_o.mjd)*86400/dt);
            timetag = timetag + 1;
		end

		%--- 読み取り中のエポックの時間表示
		%--------------------------------------------
		fprintf('%7d:  %2d:%2d %5.2f"  ',timetag,time.day(4),time.day(5),time.day(6));

		%--- アンテナa,bのPRNのindexを格納(共通衛星のみ)
		%------------------------------------------------
% 		ind_p1 = [];
% 		ind_p2 = [];
% 		for k = 1 : (length(prn.rov.v)-1)
% 			if prn.rov.v(k) == prn.rov.v(k+1)
% 				ind_p1 = [ind_p1 k];
% 				ind_p2 = [ind_p2 k+1];
% 			end
% 		end
% % 		data=data(ind_p1,:);
% 		data=data(ind_p2,:);
% 		prn.rov.v=prn.rov.v(ind_p1); no_sat=length(prn.rov.v);

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
			if ismember(time.tod,sliptime)
				for cs_i=1:length(est_prm.cycle_slip.prn)
					is = find(prn.rov.v==est_prm.cycle_slip.prn(cs_i));
					if ~isempty(is)
						data(is,1) = data(is,1) + est_prm.cycle_slip.slip_l1;
						data(is,5) = data(is,5) + est_prm.cycle_slip.slip_l2;
					end
				end
			end
		end

		%--- GLONASSの周波数・波長処理
		%--------------------------------------------
		if est_prm.g_nav==1															% GLONASS周波数, 波長
			freq.r1=eph_prm.brd.data(25,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L1 周波数(GLONASS)
			wave.r1=C ./ freq.r1;													% L2 波長(GLONASS)
			freq.r2=eph_prm.brd.data(26,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L2 周波数(GLONASS)
			wave.r2=C ./ freq.r2;													% L2 波長(GLONASS)
			else
			freq.r1=[]; wave.r1=[];
			freq.r2=[]; wave.r2=[];
		end

		%--- 単独測位
		%--------------------------------------------
        %ここに初期値ぶちこむ
        
		[x,dtr,dtsv,ion,trop,prn.rovu,rho,dop,ele,azi]=...
				pointpos3(freq,time,prn.rov.v,app_xyz,data,eph_prm,ephi,est_prm,ion_prm,rej);
        
            
		if ~isnan(x(1)), app_xyz(1:3)=x(1:3);, end

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos = xyz2enu(x(1:3),est_prm.rovpos )';													% ENUに変換

		%--- 結果格納(SPP)
		%--------------------------------------------
		Result.spp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];					% 時刻
		Result.spp.pos(timetag,:)=[x(1:3)', xyz2llh(x(1:3)).*[180/pi 180/pi 1]];					% 位置
		Result.spp.dtr(timetag,:)=C*dtr;															% 受信機時計誤差

		%--- 衛星格納
		%--------------------------------------------
		Result.spp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rovu),dop];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
        
        
		if ~isempty(prn.rovu), Result.spp.prn{2}(timetag,prn.rovu)=prn.rovu;, end

		%--- OBSデータ,電離層遅延(構造体)
		%--------------------------------------------
		OBS.rov.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];						% 時刻
		OBS.rov.ca(timetag,prn.rov.v)   = data(:,2);
		OBS.rov.py(timetag,prn.rov.v)   = data(:,6);
		OBS.rov.ph1(timetag,prn.rov.v)  = data(:,1);
		OBS.rov.ph2(timetag,prn.rov.v)  = data(:,5);
		OBS.rov.ion(timetag,prn.rov.v)  = ion(:,1);
		OBS.rov.trop(timetag,prn.rov.v) = trop(:,1);

		OBS.rov.ele(timetag,prn.rov.v)  = ele(:,1);				% elevation
		OBS.rov.azi(timetag,prn.rov.v)  = azi(:,1);				% azimuth
       
		%------------------------------------------------------------------------------------------------------
		%----- 単独測位(最小二乗法) ---->> 終了 ---->> クロックジャンプ補正
		%------------------------------------------------------------------------------------------------------

		%--- clock jump の検出 & 補正
		%--------------------------------------------
		if est_prm.clk_flag == 1
			dtr_all(timetag,1) = dtr;																% 受信機時計誤差を格納
			[data,dtr,time.day,clk_jump,dtr_o,jump_width_all]=...
					clkjump_repair2(time.day,data,dtr,dtr_o,jump_width_all,Rec_type);				% clock jump 検出/補正
			clk_check(timetag,1) = clk_jump;														% ジャンプフラグを格納
		end
		dtr_all(timetag,2) = dtr;																	% 補正済み受信機時計誤差を格納

		%--- 補正済み観測量を格納
		%--------------------------------------------
		OBS.rov.ca_cor(timetag,prn.rov.v)   = data(:,2);						% CA
		OBS.rov.py_cor(timetag,prn.rov.v)   = data(:,6);						% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v)  = data(:,1);						% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v)  = data(:,5);						% L2

		%--- GPS・GLONASSの衛星分別
		%--------------------------------------------
		prn.rov.vg=prn.rov.v(find(prn.rov.v<=32));							% 可視衛星(GPS)
		prn.rov.vr=prn.rov.v(find(38<=prn.rov.v));							% 可視衛星(GLONASS)

		LC.rov.variance(1:61,1:4)=NaN; 														% 分散格納配列(rov)
		if est_prm.ww == 0																					% 重みなし
			LC.rov.variance(1:length(prn.rov.v),1)=repmat(est_prm.obsnoise.PR1,length(prn.rov.v),1);		% CAコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),2)=repmat(est_prm.obsnoise.PR2,length(prn.rov.v),1);		% PYコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),3)=repmat(est_prm.obsnoise.Ph1,length(prn.rov.v),1);		% L1搬送波の分散(rov)
			LC.rov.variance(1:length(prn.rov.v),4)=repmat(est_prm.obsnoise.Ph2,length(prn.rov.v),1);		% L2搬送波の分散(rov)
		else																								% 重み考慮
			LC.rov.variance(1:length(prn.rov.v),1)= (est_prm.obsnoise.PR1./sin(ele).^2);					% CAコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),2)= (est_prm.obsnoise.PR2./sin(ele).^2);					% PYコードの分散(rov)
			LC.rov.variance(1:length(prn.rov.v),3)= (est_prm.obsnoise.Ph1./sin(ele).^2);					% L1搬送波の分散(rov)
			LC.rov.variance(1:length(prn.rov.v),4)= (est_prm.obsnoise.Ph2./sin(ele).^2);					% L2搬送波の分散(rov)
% 			LC.rov.variance(1,prn.rov.v)= (est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele(ii(b))).^2);	% CAコードの分散(rov)
% 			LC.rov.variance(2,prn.rov.v)= (est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele(ii(b))).^2);	% PYコードの分散(rov)
% 			LC.rov.variance(3,prn.rov.v)= (est_prm.obsnoise.Ph1+est_prm.obsnoise.Ph1./sin(ele(ii(b))).^2);	% L1搬送波の分散(rov)
% 			LC.rov.variance(4,prn.rov.v)= (est_prm.obsnoise.Ph2+est_prm.obsnoise.Ph2./sin(ele(ii(b))).^2);	% L2搬送波の分散(rov)
        end
        
		%--- 各種線形結合と分散(補正済み観測量を使用)
		%--------------------------------------------
		[mp1,mp2,lgl,lgp,lg1,lg2,mw,ionp,ionl,lgl_ion,...
			mp1_va,mp2_va,lgl_va,lgp_va,lg1_va,lg2_va,mw_va,ionp_va,ionl_va]=...
					obs_comb2(est_prm,freq,wave,data,LC.rov.variance,prn.rov,ion,ele);

		%--- 各種線形結合と分散を格納
		%--------------------------------------------
		ii=find(ele*180/pi>est_prm.mask);
		if ~isempty(ii)
			LC.rov.mp1(timetag,prn.rov.v(ii)) = mp1(ii);										% Multipath 線形結合(L1)
			LC.rov.mp2(timetag,prn.rov.v(ii)) = mp2(ii);										% Multipath 線形結合(L2)
			LC.rov.mw(timetag,prn.rov.v(ii))  = mw(ii);											% Melbourne-Wubbena 線形結合
			LC.rov.mp1_va(timetag,prn.rov.v(ii)) = mp1_va(ii);									% Multipath 線形結合(L1)の分散
			LC.rov.mp2_va(timetag,prn.rov.v(ii)) = mp2_va(ii);									% Multipath 線形結合(L2)の分散
			LC.rov.mw_va(timetag,prn.rov.v(ii))  = mw_va(ii);									% Melbourne-Wubbena 線形結合の分散
			LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_va(ii);									% 幾何学フリー線形結合(搬送波)
			if est_prm.cycle_slip.lgl_ion == 0
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_va(ii);								% 幾何学フリー線形結合(搬送波)
			else
				LC.rov.lgl(timetag,prn.rov.v(ii)) = lgl_ion(ii);								% 幾何学フリー線形結合(搬送波)-電離層遅延分
% 				LC.rov.lgl_va(timetag,prn.rov.v(ii)) = lgl_ion_va(ii);							% 幾何学フリー線形結合(搬送波)-電離層遅延分の分散
			end
			LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp(ii);										% 幾何学フリー線形結合(コード)
			LC.rov.lg1(timetag,prn.rov.v(ii))  = lg1(ii);										% 幾何学フリー線形結合(1周波)
			LC.rov.lg2(timetag,prn.rov.v(ii))  = lg2(ii);										% 幾何学フリー線形結合(2周波)
			LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp(ii);										% 電離層(lgpから算出)
			LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl(ii);										% 電離層(lglから算出,Nを含む)
			LC.rov.lgp_va(timetag,prn.rov.v(ii))  = lgp_va(ii);									% 幾何学フリー線形結合(コード)の分散
			LC.rov.lg1_va(timetag,prn.rov.v(ii))  = lg1_va(ii);									% 幾何学フリー線形結合(1周波)の分散
			LC.rov.lg2_va(timetag,prn.rov.v(ii))  = lg2_va(ii);									% 幾何学フリー線形結合(2周波)の分散
			LC.rov.ionp_va(timetag,prn.rov.v(ii)) = ionp_va(ii);								% 電離層(lgpから算出)の分散
			LC.rov.ionl_va(timetag,prn.rov.v(ii)) = ionl_va(ii);								% 電離層(lglから算出,Nを含む)の分散
		end

		%--- 線形結合による異常値検定
		%--------------------------------------------
		rej_rov.mp1  = [];
		rej_rov.mp2  = [];
		rej_rov.mw   = [];
		rej_rov.lgl  = [];

		rej_lc  = [];
% 		rej_lgl = [];
% 		rej_mw  = [];
% 		rej_mp1 = [];
% 		rej_mp2 = [];
		rej_uni = [];

		%--- 除外衛星を考慮した線形結合格納配列
		%--------------------------------------
		LC_r.rov.mp1(timetag,:)=LC.rov.mp1(timetag,:); LC_r.rov.mp2(timetag,:)=LC.rov.mp2(timetag,:);		% MP1, MP2
		LC_r.rov.mw(timetag,:)=LC.rov.mw(timetag,:);														% MW
		LC_r.rov.lgl(timetag,:)=LC.rov.lgl(timetag,:); LC_r.rov.lgp(timetag,:)=LC.rov.lgp(timetag,:);		% LGL, LGP
		LC_r.rov.lg1(timetag,:)=LC.rov.lg1(timetag,:); LC_r.rov.lg2(timetag,:)=LC.rov.lg2(timetag,:);		% LG1, LG2
		LC_r.rov.ionp(timetag,:)=LC.rov.ionp(timetag,:); LC_r.rov.ionl(timetag,:)=LC.rov.ionl(timetag,:);	% IONP, IONL

		if timetag>1
	
			%--- 線形結合による異常値検定
			%--------------------------------------------
			[lim_rov,chi2_rov,rej_rov,lcbb_rov]=outlier_detec(est_prm,timetag,LC.rov,LC_r.rov,CHI2.sigma,REJ.rov,prn.rov.v,Vb,Gb);

			switch est_prm.cs_mode
			case 0
				rej_uni=rej;
			case 2
				if timetag>est_prm.cycle_slip.lc_int+1

					%--- 閾値の格納
					%------------------------------------------
					LC.rov.mp1_lim(timetag,:)  = lim_rov.mp1;						% Multipath 線形結合(L1)
					LC.rov.mp2_lim(timetag,:)  = lim_rov.mp2;						% Multipath 線形結合(L2)
					LC.rov.mw_lim(timetag,:)   = lim_rov.mw;						% Melbourne-Wubbena 線形結合
					LC.rov.lgl_lim(timetag,:)  = lim_rov.lgl;						% 幾何学フリー線形結合(搬送波)

% 					LC.rov.lgp_lim(timetag,:)  = lim_rov.lgp;						% 幾何学フリー線形結合(コード)
% 					LC.rov.lg1_lim(timetag,:)  = lim_rov.lg1;						% 幾何学フリー線形結合(1周波)
% 					LC.rov.lg2_lim(timetag,:)  = lim_rov.lg2;						% 幾何学フリー線形結合(2周波)
% 					LC.rov.ionp_lim(timetag,:) = lim_rov.ionp;						% 電離層(lgpから算出)
% 					LC.rov.ionl_lim(timetag,:) = lim_rov.ionl;						% 電離層(lglから算出,Nを含む)

					%--- 異常値検出
					%------------------------------------------
					rej_rov.mp1=find(abs(diff(LC.rov.mp1(timetag-1:timetag,:)))>lim_rov.mp1);
					rej_rov.mp2=find(abs(diff(LC.rov.mp2(timetag-1:timetag,:)))>lim_rov.mp2);
					rej_rov.mw=find(abs(diff(LC.rov.mw(timetag-1:timetag,:)))>lim_rov.mw);
					rej_rov.lgl=find(abs(diff(LC.rov.lgl(timetag-1:timetag,:)))>lim_rov.lgl);

					if ismember(0,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.lgl);
					end
					if ismember(1,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mw);
					end
					if ismember(2,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp1);
					end
					if ismember(3,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp2);
					end

					REJ.rej(timetag,rej_lc)=rej_lc;
					rej_uni = union(rej, rej_lc);

					%--- 異常値検出された衛星番号の格納
					%------------------------------------------
					REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
					REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
					REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
					REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;
				end

			case 3
				%--- 異常値検出された衛星番号の格納
				%------------------------------------------
				REJ.rov.mp1(timetag,rej_rov.mp1)=rej_rov.mp1;
				REJ.rov.mp2(timetag,rej_rov.mp2)=rej_rov.mp2;
				REJ.rov.mw(timetag,rej_rov.mw)=rej_rov.mw;
				REJ.rov.lgl(timetag,rej_rov.lgl)=rej_rov.lgl;

				%--- カイ二乗値の格納
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;						% Multipath 線形結合(L1)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;						% Multipath 線形結合(L2)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;							% Melbourne-Wubbena 線形結合
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;						% 幾何学フリー線形結合(搬送波)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov_lgp;						% 幾何学フリー線形結合(コード)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov_lg1;						% 幾何学フリー線形結合(1周波)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov_lg2;						% 幾何学フリー線形結合(2周波)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov_ionp;						% 電離層(lgpから算出)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov_ionl;						% 電離層(lglから算出,Nを含む)

				%--- 異常値検出衛星の除外
				%------------------------------------------
				if est_prm.cycle_slip.rej_flag==0
					if ismember(0,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.lgl);
					end
					if ismember(1,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mw);
					end
					if ismember(2,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp1);
					end
					if ismember(3,est_prm.cycle_slip.LC)
						rej_lc = union(rej_lc, rej_rov.mp2);
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
					
					rej_rov_1 = union(rej_rov.lgl,rej_rov.mw);
					rej_rov_2 = union(rej_rov.mp1,rej_rov.mp2);
					rej_rov_sum = union(rej_rov_1,rej_rov_2);							% 未知局側検出衛星

					%--- 修正可能な観測量の修正
					%--------------------------------------
					if ~isnan(rej_rov_sum)
						VA.rov=[];
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
								data(rov_ii,1) = data(rov_ii,1) + s1_rov(rov_i);
								data(rov_ii,5) = data(rov_ii,5) + s2_rov(rov_i);
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

			case 4
				%--- カイ二乗値の格納
				%------------------------------------------
				CHI2.rov.mp1(timetag,:)  = chi2_rov.mp1;					% Multipath 線形結合(L1)
				CHI2.rov.mp2(timetag,:)  = chi2_rov.mp2;					% Multipath 線形結合(L2)
				CHI2.rov.mw(timetag,:)   = chi2_rov.mw;						% Melbourne-Wubbena 線形結合
				CHI2.rov.lgl(timetag,:)  = chi2_rov.lgl;					% 幾何学フリー線形結合(搬送波)
% 				CHI2.rov.lgp(timetag,:)  = chi2_rov.lgp;					% 幾何学フリー線形結合(コード)
% 				CHI2.rov.lg1(timetag,:)  = chi2_rov.lg1;					% 幾何学フリー線形結合(1周波)
% 				CHI2.rov.lg2(timetag,:)  = chi2_rov.lg2;					% 幾何学フリー線形結合(2周波)
% 				CHI2.rov.ionp(timetag,:) = chi2_rov.ionp;					% 電離層(lgpから算出)
% 				CHI2.rov.ionl(timetag,:) = chi2_rov.ionl;					% 電離層(lglから算出,Nを含む)

				%--- 異常値検出された衛星番号の格納
				%------------------------------------------
				REJ.rov.mp1(timetag,:)=rej_rov.mp1;
				REJ.rov.mp2(timetag,:)=rej_rov.mp2;
				REJ.rov.mw(timetag,:)=rej_rov.mw;
				REJ.rov.lgl(timetag,:)=rej_rov.lgl;

				%--- 異常値検出衛星の除外
				%------------------------------------------
				if ismember(0,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.lgl);
				end
				if ismember(1,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.mw);
				end
				if ismember(2,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.mp1);
				end
				if ismember(3,est_prm.cycle_slip.LC)
					rej_lc = union(rej_lc, rej_rov.mp2);
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
			end
        end
        %信号強度により使用する衛星を除外
        
        if(find(data(:,8)<20) ~= 0)
            rej_uni = prn.rov.v(find(data(:,8)<20));
        end
        
          if(timetag > 22 && timetag < 52)
              %est_prm.mask = 35;
              rej_uni = [rej_uni,18];
          else
              rej_uni = [];
          end
%         if(timetag > 92)
%             rej_uni = [rej_uni,21];
%         end

		%------------------------------------------------------------------------------------------------------
		%----- 単独測位 & PPP (カルマンフィルタ)
		%------------------------------------------------------------------------------------------------------
 else
       
		%--- カルマンフィルタの設定(衛星変化処理なし)
		%--------------------------------------------
		if find([0,1,2,10]==est_prm.obsmodel)

			%--- 次元とインデックスの設定(可視衛星)
			%--------------------------------------------
			ns=length(prn.rov.v);																% 可視衛星数
			ns_g=length(prn.rov.vg);															% 可視衛星数(GPS)
			ns_r=length(prn.rov.vr);															% 可視衛星数(GLONASS)
			ix.u=1:nx.u; nx.x=nx.u;																% 受信機位置
			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;													% 受信機時計誤差

			est_prm.statemodel.hw=0;
			N1ls=[];  N2ls=[];  N12ls=[];

			if timetag==1 || isnan(Kalx_f(1)) || timetag-timetag_o > 5
				Kalx_p=[x(1:3); zeros(nx.u-3,1); x(4); zeros(nx.t-1,1); est_prm.steplength];						% 初期値
				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j];
				KalP_p=diag([KalP_p(1:nx.u), est_prm.P0.std_dev_t(1:nx.t),est_prm.P0.std_walking]).^2;
              
                if isempty(refl), refl=est_prm.rovpos; end
			else
				%--- 状態遷移行列・システム雑音行列生成
				%--------------------------------------------
                %%センサーからの値を取得する.
                INS(1:3) = getSensor(fpcsv,time,timetag);
				[F,Q]=FQ_state_all6(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,1,INS);
                [m,n]=size(Kalx_p);
                CI = zeros(m,1);
                CI(3,1) = INS(3);  
                
				%--- ECEF(WGS84)からLocalに変換
				%--------------------------------------------
 				%refl=Kalx_f(1:3);
                
				Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),refl);
            % if timetag<=1
                   % Kalx_f(1:3)=[1.0e+06 * 3.7343,1.0e+06 *1.6868,1.0e+06*-4.8716]
              % end
              
				%--- カルマンフィルタ(時間更新)
				%--------------------------------------------
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q, CI);
                %衛星数が不足していそうなら補正する
                if(stepslip == 1)
                    if(isempty(x))
                        x = Kalx_f;
                        p = KalP_f;
                    end
                    [Kalx_p, KalP_p] = humanstateadjust(Kalx_f, KalP_f, Kalx_p, KalP_p, INS, truestep);
                end
                fprintf(',INS(E:%1.1f N:%1.1f)',Kalx_p(1),Kalx_p(2));
                %if(timetag > 2)
                    %%歩幅のカルマンフィルタ(時間更新)
                    %[Kalx_w, KalP_w] = filtekf_pre(Kalx_wf, KalP_wf, wF, wQ);
                %end

				%--- LocalからECEF(WGS84)に変換
				%--------------------------------------------
				Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),refl);
			end
        end
     
		%--- カルマンフィルタの設定(衛星変化処理あり)
		%--------------------------------------------
		if find([3,4,5,6,7,8,9]==est_prm.obsmodel)
			%--- Ambiguity の算出
			%--------------------------------------------
			N1ls=[];  N2ls=[];  N12ls=[];
			N1ls_g=[];  N2ls_g=[];  N12ls_g=[];
			N1ls_r=[];  N2ls_r=[];  N12ls_r=[];
			if est_prm.n_nav==1
				N1ls_g=(wave.g1*data(1:length(prn.rov.vg),1)-data(1:length(prn.rov.vg),2)...
					+2*ion(1:length(prn.rov.vg),1)+C*eph_prm.brd.data(33,ephi(prn.rov.vg))')/wave.g1;			% L1 整数値バイアス(逆算)+TGDも
				if est_prm.freq==2
					N2ls_g=(wave.g2*data(1:length(prn.rov.vg),5)-data(1:length(prn.rov.vg),6)...
						+2*(freq.g1/freq.g2)^2*ion(1:length(prn.rov.vg),1)+C*(freq.g1/freq.g2)^2*eph_prm.brd.data(33,ephi(prn.rov.vg))')/wave.g2;	% L2 整数値バイアス(逆算)+TGDも
					N12ls_g=[wave.g1*N1ls_g wave.g2*N2ls_g]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);					% LC 整数値バイアス(逆算)
				end
			end

			if est_prm.g_nav==1 & ~isempty(wave.r2)
				N1ls_r=(wave.r1.*data(length(prn.rov.vg)+1:end,1)-data(length(prn.rov.vg)+1:end,2)...
					+2*ion(length(prn.rov.vg)+1:end,1))./wave.r1;											% L1 整数値バイアス(逆算)
				if est_prm.freq==2
					N2ls_r=(wave.r2.*data(length(prn.rov.vg)+1:end,5)-data(length(prn.rov.vg)+1:end,6)...
						+2*(freq.r1./freq.r2).^2.*ion(length(prn.rov.vg)+1:end,1))./wave.r2;													% L2 整数値バイアス(逆算)
					if ~isempty(wave.r2)
						N12ls_r=[wave.r1.*N1ls_r.*freq.r1.^2 - wave.r2.*N2ls_r.*freq.r2.^2]./(freq.r1.^2-freq.r2.^2);		% LC 整数値バイアス(逆算)
					end
				end
			end
			N1ls=[N1ls_g; N1ls_r];
			N2ls=[N2ls_g; N2ls_r];
			N12ls=[N12ls_g; N12ls_r];

			%--- 次元とインデックスの設定(可視衛星)
			%--------------------------------------------
			ns=length(prn.rov.v);																	% 可視衛星数
			ns_g=length(prn.rov.vg);																% 可視衛星数(GPS)
			ns_r=length(prn.rov.vr);																% 可視衛星数(GLONASS)
			ix.u=1:nx.u; nx.x=nx.u;																	% 受信機位置
			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;														% 受信機時計誤差
			if est_prm.statemodel.hw==1
				ix.b=nx.x+(1:nx.b); nx.x=nx.x+nx.b;													% 受信機HWB(ON)
			else
				ix.b=[]; nx.x=nx.x+nx.b;															% 受信機HWB(OFF)
			end
			if est_prm.statemodel.trop~=0
				ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;													% 対流圏遅延(ON)
			else
				ix.T=[]; nx.x=nx.x+nx.T;															% 対流圏遅延(OFF)
			end
			if est_prm.statemodel.ion~=0
				ix.i=nx.x+(1:nx.i); nx.x=nx.x+nx.i;													% 電離層遅延(ON)
			else
				ix.i=[]; nx.x=nx.x+nx.i;															% 電離層遅延(OFF)
			end
			ix.n=nx.x+(1:est_prm.freq*ns); nx.n=length(ix.n); nx.x=nx.x+nx.n;						% 整数値バイアス
			ix.g=ix.n(1:ns_g); nx.g=length(ix.g);													% 整数値バイアス(GPS)
			ix.r=ix.n(ns_g+1:ns); nx.r=length(ix.r);												% 整数値バイアス(GLONASS)
			if est_prm.freq==2
				ix.g=[ix.g ix.n(ns+ns_g+1:end)];
				ix.r=[ix.r ix.n(ns+1:ns+ns_g)];
			end

			%--- 衛星が変化した場合に次元を調節する
			%--------------------------------------------
			if timetag == 1 | isnan(Kalx_f(1)) | timetag-timetag_o > 5								% 1エポック目
				Kalx_p=[x(1:3); repmat(0,nx.u-3,1); x(4); repmat(0,nx.t-1,1)];						% 初期値
				if est_prm.statemodel.hw==1,   Kalx_p=[Kalx_p; repmat(0,nx.b,1)];, end
				switch est_prm.statemodel.trop
				case 1, Kalx_p=[Kalx_p; 0.4];														% ZWD推定
				case 2, Kalx_p=[Kalx_p; 2.4];														% ZTD推定
				case 3, Kalx_p=[Kalx_p; 0.4; 0; 0];													% ZWD+Grad推定
				case 4, Kalx_p=[Kalx_p; 2.4; 0; 0];													% ZTD+Grad推定
				end
				switch est_prm.statemodel.ion
				case 1, Kalx_p=[Kalx_p; 1.0];														% ZID推定
				case 2, Kalx_p=[Kalx_p; 1.0; 0];													% ZID+dZID推定
				case 3, Kalx_p=[Kalx_p; 1.0; 0; 0];													% ZID+Grad推定
				end
				if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; N1ls; N2ls];, end
				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j];
				KalP_p=diag([KalP_p(1:nx.u), est_prm.P0.std_dev_t(1:nx.t),...
							est_prm.P0.std_dev_b(1:nx.b), est_prm.P0.std_dev_T(1:nx.T),...
							est_prm.P0.std_dev_i(1:nx.i), ones(1,nx.n)*est_prm.P0.std_dev_n]).^2;

				%--- dt_dotの初期値を(dtr-dtr_o)で書き換え
				%--------------------------------------------
				if timetag~=1&est_prm.statemodel.dt==1
					idtr=max(find(diff(find(~isnan(dtr_all(:,2))))==1));
					if ~isempty(idtr)
						Kalx_p(nx.u+nx.t) = C*(diff(dtr_all(idtr:idtr+1,2)));
					end
				end
				if isempty(refl), refl=est_prm.rovpos;, end
			else																					% 2エポック以降
				%--- dt_dotの初期値を(dtr-dtr_o)で書き換え
				%--------------------------------------------
				if timetag==2&est_prm.statemodel.dt==1
					idtr=max(find(diff(find(~isnan(dtr_all(:,2))))==1));
					if ~isempty(idtr)
						Kalx_f(nx.u+nx.t) = C*(diff(dtr_all(idtr:idtr+1,2)));
					end
				end

				%--- 状態遷移行列・システム雑音行列生成
				%--------------------------------------------
				[F,Q]=FQ_state_all6(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,1);

				%--- ECEF(WGS84)からLocal(ENU)に変換
				%--------------------------------------------
				Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),refl);

				%--- カルマンフィルタ(時間更新)
				%--------------------------------------------
                    
                %ここを確認
                if(length(prn.u) < 5)
                    temp_step = Kalx_f(9);
                   
                    temp_stepcov = KalP_f(9,9);
                end
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);
               
                if(length(prn.u) < 5)
                    Kalx_p(9) = temp_step;
                    KalP_p(9,9) = temp_stepcov;
                end
				% H∞ Filter
% 				[Kalx_p, KalP_p] = filthif_pre(Kalx_f, KalP_f, F, Q, gam);

				%--- Local(ENU)からECEF(WGS84)に変換
				%--------------------------------------------
				Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),refl);
               
             
                   est_pos = xyz2enu(Kalx_f(1:3),refl)';
               
				%--- 次元調節後の状態変数と共分散
				%--------------------------------------------
				[Kalx_p,KalP_p]=state_adjust2(prn.rov.v,prn.o,Kalx_p,KalP_p,N1ls,N2ls,[]);			% 一段予測値 / 一段予測値の共分散行列
				N1ls=Kalx_p(ix.n(1:ns));															% 整数値バイアス
				if est_prm.freq==2
					N2ls=Kalx_p(ix.n(ns+1:end));													% 整数値バイアス
				end
			end
		end

		%--- 受信機時計誤差の置換
		%--------------------------------------------
		dtr=Kalx_p(nx.u+1)/C; if isnan(dtr), dtr=x(4)/C;, Kalx_p(nx.u+1)=dtr;, end

		if est_prm.statemodel.pos==4, Kalx_p(1:3)=x(1:3);, end
     
		%--- 観測更新の計算(反復可能)
		%--------------------------------------------
        
       if (length(prn.rov.vg)) >= 4
		if ~isnan(x(1))
            
			for nn=1:est_prm.iteration
				if nn~=1
					%--- 次元調節後の状態変数と共分散
					% ・prn.rov.vとNlsの順番を対応させること
					% ・prn.uとKalの順番を対応させること
					%--------------------------------------------
					[Kalx_p,KalP_p]=state_adjust2(prn.rov.v,prn.u,Kalx_p,KalP_p,N1ls,N2ls,[]);		% 一段予測値 / 一段予測値の共分散行列
					dtr=Kalx_p(nx.u+1)/C;
				end
                
            
           
				%--- 初期化
				%--------------------------------------------
				sat_xyz=[]; sat_xyz_dot=[]; dtsv=[]; ion=[];
				trop=[]; azi=[]; ele=[]; rho=[]; ee=[]; tgd=[];

				%--- 観測量
				%--------------------------------------------
				Y=obs_vec2(freq,wave,data,prn,est_prm.obsmodel,est_prm);
 
				% 観測モデル(観測量・モデル・観測雑音etc)
				%--------------------------------------------
                ref_L=xyz2llh(refl);
				lat=ref_L(1); lon=ref_L(2);
				LL = [         -sin(lon),           cos(lon),        0;
					  -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
					   cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
				[h,H,R,ele,rho,dtsv,ion,trop]=...
						measuremodel2(freq,wave,time,prn.rov.v,eph_prm,ephi,ion_prm,est_prm,Kalx_p,nx);
				%--- 偏微分をLocal(ENU)用に変換(キネマティック用)
				%--------------------------------------------
                    [Y,H,h,R,Kalx_p,KalP_p,prn.u]=...
						select_prn(Y,H,h,R,Kalx_p,KalP_p,prn.rov.v,est_prm,ele,rej_uni,nx,LL);
                H(:,1:3)=(LL*H(:,1:3)')';
                %衛星数は
                eiseisuu(1,timetag)=length(prn.u);
                
                %h = H*Kalx_p;
                %--- 衛星数が4未満の場合
				%--------------------------------------------
%                 if (length(prn.u) < 4 && est_prm.sensormixmode == 1)
% 					est_prm.statemodel.sensorbias = 1.5;
%                 else
%                     est_prm.statemodel.sensorbias = 1;
%                 end
				%--- イノベーション
				%--------------------------------------------
				zz = Y - h;
                
%                 if length(prn.u) < 4
% 					zz
%                     H
%                 end

				%--- 事前残差の検定(χ2検定)
				%--------------------------------------------
				if timetag>10
					if est_prm.cs_mode==1
					[zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=...
							chi2test(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,0.99);
					REJ.rej(timetag,prn_rej)=prn_rej;
					end
				end

				prn.ug=prn.u(find(prn.u<=32));							% 使用衛星(GPS)
				prn.ur=prn.u(find(38<=prn.u));							% 使用衛星(GLONASS)


				%--- ECEF(WGS84)からLocal(ENU)に変換
				%--------------------------------------------
				Kalx_p(1:3)=xyz2enu(Kalx_p(1:3),refl);

				%--- カルマンフィルタ(観測更新)
				%--------------------------------------------

				[Kalx_f, KalP_f, V] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);
              
            
                %ステップスリップの検出
                if(length(prn.u) < 5)
                    stepslip = 1;
                    %temp_step = Kalx_p(9);
                    %temp_stepcov = KalP_p(9,9);
                else
                    truestep = Kalx_f(9);
                    stepslip = 0;
                end
                %if(length(prn.u) < 5)
                    %Kalx_f(9) = temp_step;
                    %KalP_f(9,9) = temp_stepcov;
                %end
% 				[Kalx_f, KalP_f] = filtsrcf_upd(zz, H, R, Kalx_p, KalP_p);
% 				[Kalx_f, KalP_f, gam] = filthif_upd(zz, H, R, Kalx_p, KalP_p, 5);

				%--- Local(ENU)からECEF(WGS84)に変換
				%--------------------------------------------                      
				Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),refl);   
				Kalx_p=Kalx_f;  KalP_p=KalP_f;                 
				%--- 潮汐の補正
				%--------------------------------------------
				if est_prm.tide==1
					if timetag==1
						tidexyz(timetag,1:3)=tide2(Kalx_f(1:3)',time.mjd);
						Kalx_f(1:3)=Kalx_f(1:3)-tidexyz(timetag,1:3)';
					else
						tidexyz(timetag,1:3)=tide2(Kalx_f(1:3)',time.mjd);
						Kalx_f(1:3)=Kalx_f(1:3)-(tidexyz(timetag,1:3)-tidexyz(timetag_o,1:3))';
					end
				end

            end  
            
		else
			zz=[];
			prn.u=[]; prn.ug=[]; prn.ur=[];
			Kalx_f(1:nx.u+nx.t+nx.b+nx.T+nx.i,1) = NaN;
        end
       

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
        
		est_pos = xyz2enu(Kalx_f(1:3),refl)';  % ENUに変換
        
       else 
           less_frag = 1;
       end
        
		%--- 結果格納(PPP解)
		%--------------------------------------------
             % syoki=[135.9632729264,0034.9817953687,0195.8691933509];
       % syoki2=llh2xyz(syoki)         
 %syoki=[135.9632729264,0034.9817953687,0195.8691933509];
        %syoki2=llh2xyz(syoki)./[180/pi 180/pi 1]
        
		Result.ppp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];	% 時刻
        if less_frag == 1
		Result.ppp.pos(timetag,:)=[Kalx_p(1:3)', xyz2llh(Kalx_p(1:3)).*[180/pi 180/pi 1]];	
        else
        Result.ppp.pos(timetag,:)=[Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1]];	% 位置
        end
         
        
        if less_frag == 1
		Result.ppp.walk(1,timetag)=Kalx_p(9);
        else
        Result.ppp.walk(1,timetag)=Kalx_f(9);
        end
        
        if less_frag == 1
        if est_prm.statemodel.dt==1
			Result.ppp.dtr(timetag,1:nx.t)=Kalx_p(ix.t);											% 受信機時計誤差
		end
		if est_prm.statemodel.hw==1
			Result.ppp.hwb(timetag,1:nx.b)=Kalx_p(ix.b);											% 受信機HWB
		end
		if est_prm.statemodel.trop~=0
			Result.ppp.dtrop(timetag,1:nx.T)=Kalx_p(ix.T);											% 対流圏遅延
		end
		if est_prm.statemodel.ion~=0
			Result.ppp.dion(timetag,1:nx.i)=Kalx_p(ix.i);											% 電離層遅延
		end
        else
            
            if est_prm.statemodel.dt==1
			Result.ppp.dtr(timetag,1:nx.t)=Kalx_f(ix.t);											% 受信機時計誤差
		end
		if est_prm.statemodel.hw==1
			Result.ppp.hwb(timetag,1:nx.b)=Kalx_f(ix.b);											% 受信機HWB
		end
		if est_prm.statemodel.trop~=0
			Result.ppp.dtrop(timetag,1:nx.T)=Kalx_f(ix.T);											% 対流圏遅延
		end
		if est_prm.statemodel.ion~=0
			Result.ppp.dion(timetag,1:nx.i)=Kalx_f(ix.i);											% 電離層遅延
        end
        
        end
            
            
            less_frag =0;
            
		Res.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];							% 時刻
		if ~isempty(zz)
			if find([0,1,2,4,5]==est_prm.obsmodel)
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
			end
			if find([3,7,8]==est_prm.obsmodel)
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.post{2,1}(timetag,prn.u) = V(1+length(prn.u):2*length(prn.u),1)';
			end
			if est_prm.obsmodel==6
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.post{2,1}(timetag,prn.u) = V(1+length(prn.u):2*length(prn.u),1)';
				Res.pre{3,1}(timetag,prn.u) = zz(1+2*length(prn.u):3*length(prn.u),1)';
				Res.post{3,1}(timetag,prn.u) = V(1+2*length(prn.u):3*length(prn.u),1)';
				Res.pre{4,1}(timetag,prn.u) = zz(1+3*length(prn.u):4*length(prn.u),1)';
				Res.post{4,1}(timetag,prn.u) = V(1+3*length(prn.u):4*length(prn.u),1)';
			end
			if est_prm.obsmodel==9
				Res.pre{1,1}(timetag,prn.u) = zz(1:length(prn.u),1)';
				Res.post{1,1}(timetag,prn.u) = V(1:length(prn.u),1)';
				Res.pre{2,1}(timetag,prn.u) = zz(1+length(prn.u):2*length(prn.u),1)';
				Res.post{2,1}(timetag,prn.u) = V(1+length(prn.u):2*length(prn.u),1)';
				Res.pre{3,1}(timetag,prn.u) = zz(1+2*length(prn.u):3*length(prn.u),1)';
				Res.post{3,1}(timetag,prn.u) = V(1+2*length(prn.u):3*length(prn.u),1)';
			end
			if est_prm.obsmodel==3 | est_prm.obsmodel==4
				Result.ppp.amb{1,1}(timetag,prn.u) = ...
						Kalx_f(nx.u+nx.t+nx.b+nx.T+nx.i+1:nx.u+nx.t+nx.b+nx.T+nx.i+length(prn.u),1)';
			end
			if find([5,6,7,8,9]==est_prm.obsmodel)
				Result.ppp.amb{1,1}(timetag,prn.u) = ...
						Kalx_f(nx.u+nx.t+nx.b+nx.T+nx.i+1:nx.u+nx.t+nx.b+nx.T+nx.i+length(prn.u),1)';
				Result.ppp.amb{2,1}(timetag,prn.u) = ...
						Kalx_f(nx.u+nx.t+nx.b+nx.T+nx.i+length(prn.u)+1:nx.u+nx.t+nx.b+nx.T+nx.i+2*length(prn.u),1);
            
                
 
                        
                         
                    
			end
        end

		%------------------------------------------------------------------------------------------------------
		%----- 単独測位 & PPP (カルマンフィルタ) ---->> 終了
		%------------------------------------------------------------------------------------------------------

		%--- 衛星変化チェック
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.u);							% 衛星変化のチェック
% 		end

		%--- 画面表示
		%--------------------------------------------
       
		fprintf('%10.4f %10.4f %10.4f  %3d   PRN:',est_pos(1:3),length(prn.u));
        Result.ppp.error(timetag,1:3)=est_pos(1:3);
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
        if length(prn.u) < 4
            fprintf('：衛星数の不足により結果が著しく悪化する恐れがあります')
            Result.ppp.lostsat(timetag,1)=1;
        end
        fprintf('(STEP:%1.1f)',Kalx_p(9));
% 		if change_flag==1, fprintf(' , Change');, end
		fprintf('\n')
        %Result.ppp.pos(timetag,1:3)=est_pos(1:3);

		%--- 衛星格納
		%--------------------------------------------
       
		Result.ppp.prn{3}(timetag,1:8)=[time.tod,length(prn.rov.v),length(prn.rov.v(find(prn.rov.vg))),length(prn.rov.v(find(prn.rov.vr))),...
										length(prn.u),length(prn.u(find(prn.ug))),length(prn.u(find(prn.ur))),dop];
                                    
		Result.ppp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.u), Result.ppp.prn{2}(timetag,prn.u)=prn.u;, end

		%--- 結果書き出し
		%--------------------------------------------
		fprintf(f_sol,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',...
				timetag,time.week,time.tow,time.tod,Kalx_f(1:3),est_pos);

		%--- 次元の設定
		%--------------------------------------------
		nxo.u=nx.u; nxo.t=nx.t; nxo.b=nx.b; nxo.T=nx.T; nxo.i=nx.i;
		nxo.n=est_prm.freq*length(prn.u);
		nxo.x=nxo.u+nxo.t+nxo.b+nxo.T+nxo.i+nxo.n;

		prn.o = prn.u;
		time_o=time;
		timetag_o=timetag;

	end
	% end 判定
	%--------------------------------------------
	if feof(fpo), break;, end
end
fclose('all');

        
toc
%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算 ---->> 終了
%-----------------------------------------------------------------------------------------

%--- MATに保存
%--------------------------------------------
matname=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','Res','OBS','LC');

%--- 測位結果プロット
%--------------------------------------------
%plot_data2([est_prm.dirs.result,matname]);
plot_data([est_prm.dirs.result,matname]);


fn_kml = 'result.kml';
point_color = 'B';                                                          %マーカの色指定'Y','M','C','R','G','B','W','K'
track_color = 'B';                                                          %取り敢えず指定する（いじらなくてOK）
%data.time = Result.ppp.time(:,1:4);                      %Y M D H M S lat lon alt
%data.pos =  Result.ppp.inserror(:,4:6);
%output_kml(fn_kml,data,track_color,point_color);
% %--- KML出力
% %--------------------------------------------
% kmlname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
%		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
 % kmlname2=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.kml',...
%		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp,'B','G');
%output_kml([est_prm.dirs.result,kmlname2],Result.ppp,'Y','R');
 kmlname=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.kml',...
 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod])/3600);
 output_kml([est_prm.dirs.result,kmlname],Result.ppp,'G','G');
% %--- NMEA出力
% %--------------------------------------------
% nmeaname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname2=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname1],Result.spp);
% output_nmea([est_prm.dirs.result,nmeaname2],Result.ppp);
% 
% %--- INS用
% %--------------------------------------------
% insname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% insname2=sprintf('PPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname1],Result.spp,est_prm);
% output_ins([est_prm.dirs.result,insname2],Result.ppp,est_prm);

fclose('all');
