%-------------------------------------------------------------------------------%
%                 杉本・久保研版 GPS測位演算ﾌﾟﾛｸﾞﾗﾑ　Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS測位演算プログラム(VPPP版)
% 
% < Programの流れ >
% 
%  1. 初期設定の取得
%  2. obs ヘッダー解析
%  3. nav からエフェメリス取得
%  4. start, end を設定
%  5. nav から電離層パラメータを取得
%  6. ionex ファイル読込み
%  7. ionex ヘッダー解析
%  8. ionex から全TECデータ取得
%  9. 精密暦読込み
% 10. メイン処理
%     1. 単独測位 (最小二乗法)
%     2. クロックジャンプ補正→補正済み観測量を作成
%     3. VPPP (カルマンフィルタ)
% 11. 結果格納
% 12. 結果グラフ表示
% 
% 
%-------------------------------------------------------------------------------
% 必要な外部ファイル・関数
%-------------------------------------------------------------------------------
% phisic_const.m      : 物理変数定義
%-------------------------------------------------------------------------------
% FQ_state_all4.m     : 状態モデルの生成
%-------------------------------------------------------------------------------
% prn_check.m         : 衛星変化の検出
% sat_order.m         : 衛星PRNの順番の決定
% select_prn.m        : 使用衛星の選択
% state_adjust.m      : 衛星変化時の次元調節
%-------------------------------------------------------------------------------
% cal_time2.m         : 指定時刻のGPS週番号・ToW・ToDの計算
% clkjump_repair2.m   : 受信機時計の飛びの検出/修正
% mjuliday.m          : MJDの計算
% weekf.m             : WEEK, TOW の計算
%-------------------------------------------------------------------------------
% fileget2.m          : ファイル名生成とダウンロード(wget.exe, gzip.exe)
%-------------------------------------------------------------------------------
% read_eph.m          : エフェメリスの取得
% read_ionex2.m       : IONEXデータ取得
% read_obs_epo_data.m : OBSエポック情報解析 & OBS観測データ取得
% read_obs_h.m        : OBSヘッダー解析
% read_sp3.m          : 精密暦データ取得
%-------------------------------------------------------------------------------
% azel.m              : 仰角, 方位角, 偏微分係数の計算
% geodist3.m          : 幾何学的距離等の計算(放送暦)
% geodist_sp33.m      : 幾何学的距離等の計算(精密暦)
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
% measuremodel.m      : 観測モデル作成(h,H,R) + 幾何学距離
% obs_comb.m          : 各種線形結合の計算
% obs_vec.m           : 観測量ベクトル作成
%-------------------------------------------------------------------------------
% filtekf_pre.m       : カルマンフィルタの時間更新
% filtekf_upd.m       : カルマンフィルタの観測更新
%-------------------------------------------------------------------------------
% lambda2.m           : LAMBDA法(by Kubo, 各関数をサブ化)
% mlambda.m           : MLAMBDA法(by Takasu)
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
% VPPPに変更
% 
% 2台のアンテナのデータが一緒の場合のみ対応(別々のファイルの場合には変更が必要)
% 
% 受信機も別々の場合, 状態変数を対応するように変更する必要がある(古野のため)
% 
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov.v     : 可視衛星(rov)
%  prn.rovu    : 使用衛星(rov)
%  prn.rovu1   : 使用衛星(rov)
%  prn.rovu2   : 使用衛星(rov)
%  prn.rov.v       : 可視衛星(rov) prn.rov.vと同一
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
% 測位結果プロットと衛星の変数名の変更
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov.v   : 可視衛星(rov)
% 
%-------------------------------------------------------------------------------
% latest update : 2010/02/22 by Yanase
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
est_prm=fileget2(est_prm);

if ~exist(est_prm.dirs.result)
	mkdir(est_prm.dirs.result);			% 結果のディレクトリ生成
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

%--- 定数(グローバル変数)
%--------------------------------------------
phisic_const;

%--- start time の設定
%--------------------------------------------
if ~isempty(est_prm.stime)
	time_s = cal_time2(est_prm.stime);										% Start time の Juliday, WEEK, TOW, TOD
end

%--- end time の設定
%--------------------------------------------
if ~isempty(est_prm.etime)
	time_e = cal_time2(est_prm.etime);										% End time の Juliday, WEEK, TOW, TOD
else
	time_e.day = [];
	time_e.mjd = 1e50;														% End time(mjd) に大きな値を割当
end

%--- ファイルオープン
%--------------------------------------------
fpo = fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');
fpn = fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');

if fpo==-1 | fpn==-1
	if fpo==-1, fprintf('%sを開けません.\n',est_prm.file.rov_o);, end		% Rov obs(エラー処理)
	if fpn==-1, fprintf('%sを開けません.\n',est_prm.file.rov_n);, end		% Rov nav(エラー処理)
	break;
end

%--- obs ヘッダー解析
%--------------------------------------------
[tofh,toeh,s_time,e_time,app_xyz,no_obs,TYPES,dt,Rec_type]=read_obs_h(fpo);

%--- エフェメリス読込み(Klobuchar model パラメータの抽出も)
%--------------------------------------------
[eph_prm.brd.data, ion_prm.klob.ionab]=read_eph(fpn);

%--- IONEXデータ取得
%--------------------------------------------
if est_prm.i_mode==2
	[ion_prm.gim]=read_ionex2([est_prm.dirs.ionex,est_prm.file.ionex]);
else
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- 精密暦の読込み
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);			% IGS(sp3) データを全て読込む(1回だけ)
else
	eph_prm.sp3.data=[];
end

%--- 設定情報の出力
%--------------------------------------------
datname=sprintf('VPPP_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol  = fopen([est_prm.dirs.result,datname],'w');							% 結果書き出しファイルのオープン
output_log(f_sol,time_s,time_e,est_prm,1);

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

%--- 配列の準備
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;

%--- SPP用
%--------------------------------------------
Result.spp1.time(1:tt,1:10)=NaN; Result.spp1.time(:,1)=1:tt;					% 時刻
Result.spp1.pos(1:tt,1:6)=NaN;													% 位置
Result.spp1.dtr(1:tt,1:1)=NaN;													% 受信機時計誤差
Result.spp1.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.spp1.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.spp1.prn{3}(1:tt,1:3)=NaN;												% 衛星数

Result.spp2.time(1:tt,1:10)=NaN; Result.spp2.time(:,1)=1:tt;					% 時刻
Result.spp2.pos(1:tt,1:6)=NaN;													% 位置
Result.spp2.dtr(1:tt,1:1)=NaN;													% 受信機時計誤差
Result.spp2.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.spp2.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.spp2.prn{3}(1:tt,1:3)=NaN;												% 衛星数

Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% 時刻
Result.spp.pos(1:tt,1:6)=NaN;													% 位置
Result.spp.dtr(1:tt,1:1)=NaN;													% 受信機時計誤差
Result.spp.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.spp.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.spp.prn{3}(1:tt,1:3)=NaN;												% 衛星数

%--- VPPP用
%--------------------------------------------
Result.vppp.time(1:tt,1:10)=NaN; Result.vppp.time(:,1)=1:tt;					% 時刻
Result.vppp.pos(1:tt,1:6*3)=NaN;												% 位置
Result.vppp.dtr(1:tt,1:2)=NaN;													% 受信機時計誤差
Result.vppp.hwb(1:tt,1:4)=NaN;													% HWB
Result.vppp.dion(1:tt,1:32)=NaN;												% 電離層遅延
Result.vppp.dtrop(1:tt,1:1)=NaN;												% 対流圏遅延
for j=1:2, Result.vppp.amb{j,1}(1:tt,1:32)=NaN;, end							% 整数値バイアス
Result.vppp.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.vppp.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.vppp.prn{3}(1:tt,1:3)=NaN;												% 衛星数

%--- 残差用
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% 時刻
for j=1:4, Res.pre{j,1}(1:tt,1:32)=NaN;, end									% 残差

%--- clock jump用
%--------------------------------------------
dtr_all1(1:tt,1:2)=NaN; dtr_all2(1:tt,1:2)=NaN;

%--- 観測データ用
%--------------------------------------------
OBS.rov1.time(1:tt,1:10)=NaN; OBS.rov1.time(:,1)=1:tt;							% 時刻
OBS.rov1.ca(1:tt,1:32)=NaN; OBS.rov1.py(1:tt,1:32)=NaN; 						% CA, PY
OBS.rov1.ph1(1:tt,1:32)=NaN; OBS.rov1.ph2(1:tt,1:32)=NaN;						% L1, L2
OBS.rov1.ion(1:tt,1:32)=NaN; OBS.rov1.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.rov1.ele(1:tt,1:32)=NaN; OBS.rov1.azi(1:tt,1:32)=NaN;						% Elevation, Azimuth
OBS.rov1.ca_cor(1:tt,1:32)=NaN; OBS.rov1.py_cor(1:tt,1:32)=NaN; 				% CA, PY(Corrected)
OBS.rov1.ph1_cor(1:tt,1:32)=NaN; OBS.rov1.ph2_cor(1:tt,1:32)=NaN;				% L1, L2(Corrected)

OBS.rov2.time(1:tt,1:10)=NaN; OBS.rov2.time(:,1)=1:tt;							% 時刻
OBS.rov2.ca(1:tt,1:32)=NaN; OBS.rov2.py(1:tt,1:32)=NaN;							% CA, PY
OBS.rov2.ph1(1:tt,1:32)=NaN; OBS.rov2.ph2(1:tt,1:32)=NaN;						% L1, L2
OBS.rov2.ion(1:tt,1:32)=NaN; OBS.rov2.trop(1:tt,1:32)=NaN;						% Ionosphere, Troposphere
OBS.rov2.ele(1:tt,1:32)=NaN; OBS.rov2.azi(1:tt,1:32)=NaN;						% Elevation, Azimuth
OBS.rov2.ca_cor(1:tt,1:32)=NaN; OBS.rov2.py_cor(1:tt,1:32)=NaN;					% CA, PY(Corrected)
OBS.rov2.ph1_cor(1:tt,1:32)=NaN; OBS.rov2.ph2_cor(1:tt,1:32)=NaN;				% L1, L2(Corrected)

%--- LC用
%--------------------------------------------
LC.rov1.time(1:tt,1:10)=NaN; LC.rov1.time(:,1)=1:tt;							% 時刻
LC.rov1.mp1(1:tt,1:32)=NaN; LC.rov1.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.rov1.mw(1:tt,1:32)=NaN;														% MW
LC.rov1.lgl(1:tt,1:32)=NaN; LC.rov1.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.rov1.lg1(1:tt,1:32)=NaN; LC.rov1.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.rov1.ionp(1:tt,1:32)=NaN; LC.rov1.ionl(1:tt,1:32)=NaN;						% IONP, IONL

LC.rov2.time(1:tt,1:10)=NaN; LC.rov2.time(:,1)=1:tt;							% 時刻
LC.rov2.mp1(1:tt,1:32)=NaN; LC.rov2.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.rov2.mw(1:tt,1:32)=NaN;														% MW
LC.rov2.lgl(1:tt,1:32)=NaN; LC.rov2.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.rov2.lg1(1:tt,1:32)=NaN; LC.rov2.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.rov2.ionp(1:tt,1:32)=NaN; LC.rov2.ionl(1:tt,1:32)=NaN;						% IONP, IONL

%-----------------------------------------------------------------------------------------
%----- "メイン処理" 測位演算 ---->> 開始
%-----------------------------------------------------------------------------------------
while 1

	%--- エポック情報取得(時刻, PRN, Dataなど)
	%--------------------------------------------
	[time,no_sat,prn.rov.v,dtrec,ephi,data]=read_obs_epo_data(fpo,eph_prm.brd.data,no_obs,TYPES);

	% end 判定
	%--------------------------------------------
	if time_e.mjd <= time.mjd-0.1/86400, break;, end							% 約 0.1 秒ｽﾞﾚまで認める

	%--- start 判定
	%--------------------------------------------
	if time_s.mjd <= time.mjd+0.1/86400											% 約 0.1 秒ｽﾞﾚまで認める
		%--- タイムタグ
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
		else
			timetag = timetag + round((time.mjd-time_o.mjd)*86400/dt);
		end

		%--- 読み取り中のエポックの時間表示
		%--------------------------------------------
		fprintf('%7d:  %2d:%2d %5.2f"  ',timetag,time.day(4),time.day(5),time.day(6));

		%--- アンテナa,bのPRNのindexを格納(共通衛星のみ)
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
		%----- 単独測位(最小二乗法)
		%------------------------------------------------------------------------------------------------------

		%--- 単独測位
		%--------------------------------------------
		[x1,dtr1,dtsv1,ion1,trop1,prn.rov1,rho1,dop1,ele1,azi1]=...
				pointpos2(time,prn.rov.v,app_xyz,data1,eph_prm,ephi,est_prm,ion_prm,rej);
		[x2,dtr2,dtsv2,ion2,trop2,prn.rov2,rho2,dop2,ele2,azi2]=...
				pointpos2(time,prn.rov.v,app_xyz,data2,eph_prm,ephi,est_prm,ion_prm,rej);
		if ~isnan(x1(1)), app_xyz(1:3)=x1(1:3);, end
		if ~isnan(x2(1)), app_xyz(1:3)=x2(1:3);, end

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		x12=(x1(1:3)+x1(1:3))/2;															% mid position

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos1 = xyz2enu(x1(1:3),est_prm.rovpos)';										% ENUに変換
		est_pos2 = xyz2enu(x2(1:3),est_prm.rovpos)';										% ENUに変換
		est_pos12 = xyz2enu(x12,est_prm.rovpos)';											% ENUに変換
		est_pos12(3)=est_pos12(3)+0.3;

		%--- 結果格納(SPP)
		%--------------------------------------------
		Result.spp1.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% 時刻
		Result.spp1.pos(timetag,:)=[x1(1:3)', xyz2llh(x1(1:3)).*[180/pi 180/pi 1]];			% 位置
		Result.spp1.dtr(timetag,:)=C*dtr1;													% 受信機時計誤差

		Result.spp2.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% 時刻
		Result.spp2.pos(timetag,:)=[x2(1:3)', xyz2llh(x2(1:3)).*[180/pi 180/pi 1]];			% 位置
		Result.spp2.dtr(timetag,:)=C*dtr2;													% 受信機時計誤差

		Result.spp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% 時刻
		Result.spp.pos(timetag,:)=[x12', xyz2llh(x12).*[180/pi 180/pi 1]];					% 位置
		Result.spp1.dtr(timetag,:)=C*dtr1;													% 受信機時計誤差

		%--- 衛星格納
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

		%--- OBSデータ,電離層遅延(構造体)
		%--------------------------------------------
		OBS.rov1.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];		% 時刻
		OBS.rov2.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];		% 時刻
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
		%----- 単独測位(最小二乗法) ---->> 終了 ---->> クロックジャンプ補正
		%------------------------------------------------------------------------------------------------------

		%--- clock jump の検出 & 補正
		%--------------------------------------------
		% |dtrのエポック間差| > 0.5ms → 飛びと判定
		% dtrのエポック間差を飛び幅としms単位に丸める
		% 時刻, 観測データ, dtr から飛び幅を減算
		%--------------------------------------------
		if est_prm.clk_flag == 1
			dtr_all1(timetag,1) = dtr1;																% 受信機時計誤差を格納
			[data1,dtr1,time.day,clk_jump1,dtr_o1,jump_width_all1]=...
						clkjump_repair2(time.day,data1,dtr1,dtr_o1,jump_width_all1,Rec_type1);		% clock jump 検出/補正
			clk_check1(timetag,1) = clk_jump1;														% ジャンプフラグを格納

			dtr_all2(timetag,1) = dtr2;																% 受信機時計誤差を格納
			[data2,dtr2,time.day,clk_jump2,dtr_o2,jump_width_all2]=...
						clkjump_repair2(time.day,data2,dtr2,dtr_o2,jump_width_all2,Rec_type2);		% clock jump 検出/補正
			clk_check2(timetag,1) = clk_jump2;														% ジャンプフラグを格納
		end
		dtr_all1(timetag,2) = dtr1;																	% 補正済み受信機時計誤差を格納
		dtr_all2(timetag,2) = dtr2;																	% 補正済み受信機時計誤差を格納

		%--- 補正済み観測量を格納
		%--------------------------------------------
		OBS.rov1.ca_cor(timetag,prn.rov.v)  = data1(:,2);				% CA
		OBS.rov1.py_cor(timetag,prn.rov.v)  = data1(:,6);				% PY
		OBS.rov1.ph1_cor(timetag,prn.rov.v) = data1(:,1);				% L1
		OBS.rov1.ph2_cor(timetag,prn.rov.v) = data1(:,5);				% L2

		OBS.rov2.ca_cor(timetag,prn.rov.v)  = data2(:,2);				% CA
		OBS.rov2.py_cor(timetag,prn.rov.v)  = data2(:,6);				% PY
		OBS.rov2.ph1_cor(timetag,prn.rov.v) = data2(:,1);				% L1
		OBS.rov2.ph2_cor(timetag,prn.rov.v) = data2(:,5);				% L2

		%--- 各種線形結合(補正済み観測量を使用)
		%--------------------------------------------
		[mp11,mp21,lgl1,lgp1,lg11,lg21,mw1,ionp1,ionl1] = obs_comb(data1);
		[mp12,mp22,lgl2,lgp2,lg12,lg22,mw2,ionp2,ionl2] = obs_comb(data2);

		%--- 各種線形結合を格納
		%--------------------------------------------
		LC.rov1.mp1(timetag,prn.rov.v)  = mp11;						% Multipath 線形結合(L1)
		LC.rov1.mp2(timetag,prn.rov.v)  = mp21;						% Multipath 線形結合(L2)
		LC.rov1.mw(timetag,prn.rov.v)   = mw1;						% Melbourne-Wubbena 線形結合
		LC.rov1.lgl(timetag,prn.rov.v)  = lgl1;						% 幾何学フリー線形結合(搬送波)
		LC.rov1.lgp(timetag,prn.rov.v)  = lgp1;						% 幾何学フリー線形結合(コード)
		LC.rov1.lg1(timetag,prn.rov.v)  = lg11;						% 幾何学フリー線形結合(1周波)
		LC.rov1.lg2(timetag,prn.rov.v)  = lg21;						% 幾何学フリー線形結合(2周波)
		LC.rov1.ionp(timetag,prn.rov.v) = ionp1;					% 電離層(lgpから算出)
		LC.rov1.ionl(timetag,prn.rov.v) = ionl1;					% 電離層(lglから算出,Nを含む)

		LC.rov2.mp1(timetag,prn.rov.v)  = mp12;						% Multipath 線形結合(L1)
		LC.rov2.mp2(timetag,prn.rov.v)  = mp22;						% Multipath 線形結合(L2)
		LC.rov2.mw(timetag,prn.rov.v)   = mw2;						% Melbourne-Wubbena 線形結合
		LC.rov2.lgl(timetag,prn.rov.v)  = lgl2;						% 幾何学フリー線形結合(搬送波)
		LC.rov2.lgp(timetag,prn.rov.v)  = lgp2;						% 幾何学フリー線形結合(コード)
		LC.rov2.lg1(timetag,prn.rov.v)  = lg12;						% 幾何学フリー線形結合(1周波)
		LC.rov2.lg2(timetag,prn.rov.v)  = lg22;						% 幾何学フリー線形結合(2周波)
		LC.rov2.ionp(timetag,prn.rov.v) = ionp2;					% 電離層(lgpから算出)
		LC.rov2.ionl(timetag,prn.rov.v) = ionl2;					% 電離層(lglから算出,Nを含む)

% 		if timetag>1
% 			rej1=find(abs(diff(LC.rov1.lg1(timetag-1:timetag,:)))>1.5);
% 			rej2=find(abs(diff(LC.rov2.lg1(timetag-1:timetag,:)))>1.5);
% 			rej=union(rej1,rej2);
% 		end


		%------------------------------------------------------------------------------------------------------
		%----- VPPP (カルマンフィルタ)
		%------------------------------------------------------------------------------------------------------

		prn.rov.v=prn.rov.v;			% 可視衛星

		%--- カルマンフィルタの設定(衛星変化処理あり)
		%--------------------------------------------

		%--- 次元とインデックスの設定(可視衛星)
		%--------------------------------------------
		if est_prm.mode==1
			ns=length(prn.rov.v);																	% 可視衛星数
			ix.u1=1:nx.u; nx.x=nx.u;																% 受信機位置
			ix.u2=nx.x+(1:nx.u); nx.x=nx.x+nx.u;													% 受信機位置
			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;														% 受信機時計誤差
			if est_prm.statemodel.hw==1
				ix.b=nx.x+(1:2*nx.b); nx.x=nx.x+2*nx.b;												% 受信機HWB(ON)
			else
				ix.b=[]; nx.x=nx.x+2*nx.b;															% 受信機HWB(OFF)
			end
			if est_prm.statemodel.trop~=0
				ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;													% 対流圏遅延(ON)
			else
				ix.T=[]; nx.x=nx.x+nx.T;															% 対流圏遅延(OFF)
			end
% 			if est_prm.statemodel.ion~=0
% 				ix.i=nx.x+(1:nx.i); nx.x=nx.x+nx.i;													% 電離層遅延(ON)
% 			else
% 				ix.i=[]; nx.x=nx.x+nx.i;															% 電離層遅延(OFF)
% 			end
			nx.p=nx.x;
			ix.n=nx.x+(1:2*ns); nx.n=length(ix.n); nx.x=nx.x+nx.n;									% 整数値バイアス
		elseif est_prm.mode==2
			ns=length(prn.rov.v);																		% 可視衛星数
			ix.u1=1:nx.u; nx.x=nx.u;																% 受信機位置
			ix.u2=nx.x+(1:nx.u); nx.x=nx.x+nx.u;													% 受信機位置
% 			ix.t=nx.x+(1:nx.t); nx.x=nx.x+nx.t;														% 受信機時計誤差
			if est_prm.statemodel.hw==1
				ix.b=nx.x+(1:nx.b); nx.x=nx.x+nx.b;													% 受信機HWB(ON)
			else
				ix.b=[]; nx.x=nx.x+nx.b;															% 受信機HWB(OFF)
			end
% 			if est_prm.statemodel.trop~=0
% 				ix.T=nx.x+(1:nx.T); nx.x=nx.x+nx.T;													% 対流圏遅延(ON)
% 			else
% 				ix.T=[]; nx.x=nx.x+nx.T;															% 対流圏遅延(OFF)
% 			end
% 			if est_prm.statemodel.ion~=0
% 				ix.i=nx.x+(1:nx.i); nx.x=nx.x+nx.i;													% 電離層遅延(ON)
% 			else
% 				ix.i=[]; nx.x=nx.x+nx.i;															% 電離層遅延(OFF)
% 			end
			nx.p=nx.x;
			ix.n=nx.x+(1:ns); nx.n=length(ix.n); nx.x=nx.x+nx.n;									% 整数値バイアス
		end

		%--- Ambiguity の算出
		%--------------------------------------------
		N1ls=[];  N2ls=[];  N12ls=[];
		N1ls=(lam1*data1(:,1)-(rho1+C*(dtr1-dtsv1)+trop1(:,1)-ion1(:,1)))/lam1;						% L1 整数値バイアス(逆算)
		N2ls=(lam1*data2(:,1)-(rho2+C*(dtr2-dtsv2)+trop2(:,1)-ion2(:,1)))/lam1;						% L1 整数値バイアス(逆算)
		N12ls=N1ls-N2ls;

		%--- 衛星が変化した場合に次元を調節する
		%--------------------------------------------
		if est_prm.mode==1
			if timetag == 1 | isnan(Kalx_f(1)) %| timetag-timetag_o ~= 5							% 1エポック目
				Kalx_p=[x1(1:3); repmat(0,nx.u-3,1); x2(1:3); repmat(0,nx.u-3,1);...
						(x1(4)+x2(4))/2; repmat(0,nx.t-1,1)];										% 初期値
				if est_prm.statemodel.hw==1,   Kalx_p=[Kalx_p; repmat(0,2*nx.b,1)];, end
				switch est_prm.statemodel.trop
				case 1, Kalx_p=[Kalx_p; 0.4];														% ZWD推定
				case 2, Kalx_p=[Kalx_p; 2.4];														% ZTD推定
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
			else											% 2エポック以降
				%--- 状態遷移行列・システム雑音行列生成
				%--------------------------------------------
				[F,Q]=FQ_state_all6(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,3);

				%--- ECEF(WGS84)からLocalに変換
				%--------------------------------------------
% 				refl=Kalx_f(1:3);
				Kalx_f(ix.u1)=xyz2enu(Kalx_f(ix.u1),refl);
				Kalx_f(ix.u2)=xyz2enu(Kalx_f(ix.u2),refl);

				%--- カルマンフィルタ(時間更新)
				%--------------------------------------------
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);

				%--- LocalからECEF(WGS84)に変換
				%--------------------------------------------
				Kalx_p(ix.u1)=enu2xyz(Kalx_p(ix.u1),refl);
				Kalx_p(ix.u2)=enu2xyz(Kalx_p(ix.u2),refl);

				%--- 次元調節後の状態変数と共分散
				%--------------------------------------------
				[Kalx_p,KalP_p]=state_adjust2(prn.rov.v,prn.o,Kalx_p,KalP_p,N1ls,N2ls,[]);					% 一段予測値 / 一段予測値の共分散行列
				N1ls=Kalx_p(ix.n(1:ns));
				N2ls=Kalx_p(ix.n(ns+1:end));
			end
		elseif est_prm.mode==2
			if timetag == 1 | isnan(Kalx_f(1)) %| timetag-timetag_o ~= 5									% 1エポック目
				Kalx_p=[x1(1:3); repmat(0,nx.u-3,1); x2(1:3); repmat(0,nx.u-3,1);];							% 初期値
				if est_prm.statemodel.hw==1,   Kalx_p=[Kalx_p; repmat(0,nx.b,1)];, end
				if est_prm.statemodel.amb==1,  Kalx_p=[Kalx_p; N1ls; N2ls];, end

				KalP_p=[est_prm.P0.std_dev_p, est_prm.P0.std_dev_v,...
						est_prm.P0.std_dev_a, est_prm.P0.std_dev_j].^2;
				KalP_p=diag([KalP_p(1:nx.u),KalP_p(1:nx.u),...
							est_prm.P0.std_dev_b(1:nx.b),...
							ones(1,nx.n)*est_prm.P0.std_dev_n]).^2;

				if isempty(refl), refl=x1(1:3);, end
			else											% 2エポック以降
				%--- 状態遷移行列・システム雑音行列生成
				%--------------------------------------------
				[F,Q]=FQ_state_all5(nxo,round((time.mjd-time_o.mjd)*86400),est_prm,3);

				%--- ECEF(WGS84)からLocal(ENU)に変換
				%--------------------------------------------
% 				refl=Kalx_f(1:3);
				Kalx_f(ix.u1)=xyz2enu(Kalx_f(ix.u1),refl);
				Kalx_f(ix.u2)=xyz2enu(Kalx_f(ix.u2),refl);

				%--- カルマンフィルタ(時間更新)
				%--------------------------------------------
				[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);

				%--- Local(ENU)からECEF(WGS84)に変換
				%--------------------------------------------
				Kalx_p(ix.u1)=enu2xyz(Kalx_p(ix.u1),refl);
				Kalx_p(ix.u2)=enu2xyz(Kalx_p(ix.u2),refl);

				%--- 次元調節後の状態変数と共分散
				%--------------------------------------------
				[Kalx_p,KalP_p]=state_adjust(prn.rov.v,prn.o,Kalx_p,KalP_p,N12ls,[],[]);						% 一段予測値 / 一段予測値の共分散行列
				N12ls=Kalx_p(ix.n(1:ns));
			end
		end

		%--- 受信機時計誤差の置換
		%--------------------------------------------
		if est_prm.mode==1
			dtr1=Kalx_p(ix.t(1))/C;
			dtr2=Kalx_p(ix.t(1))/C;
		end

		if est_prm.statemodel.pos==4, Kalx_p(1:6)=[x1(1:3); x2(1:3)];, end

		%--- 観測更新の計算(反復可能)
		%--------------------------------------------
		if ~isnan(x1(1))
			for nn=1:est_prm.iteration
				if nn~=1
					if est_prm.mode==1
						%--- 次元調節後の状態変数と共分散
						% ・prn.rov.vとNlsの順番を対応させること
						% ・prn.uとKalの順番を対応させること
						%--------------------------------------------
						[Kalx_p,KalP_p]=state_adjust(prn.rov.v,prn.u,Kalx_p,KalP_p,N1ls,N2ls,[]);				% 一段予測値 / 一段予測値の共分散行列
						dtr1=Kalx_p(ix.t)/C;
						dtr2=Kalx_p(ix.t)/C;
						N1ls=Kalx_p(ix.n(1:ns));
						N2ls=Kalx_p(ix.n(ns+1:end));
					elseif est_prm.mode==2
						%--- 次元調節後の状態変数と共分散
						% ・prn.rov.vとNlsの順番を対応させること
						% ・prn.uとKalの順番を対応させること
						%--------------------------------------------
						[Kalx_p,KalP_p]=state_adjust(prn.rov.v,prn.u,Kalx_p,KalP_p,N12ls,[],[]);				% 一段予測値 / 一段予測値の共分散行列
						N12ls=Kalx_p(ix.n(1:ns));
					end
				end

				%--- 初期化
				%--------------------------------------------
				sat_xyz1=[];  sat_xyz_dot1=[];  dtsv1=[];  sat_enu1=[];  ion1=[];  trop1=[];
				sat_xyz2=[];  sat_xyz_dot2=[];  dtsv2=[];  sat_enu2=[];  ion2=[];  trop2=[];
				azi1=[];  ele1=[];  rho1=[];  ee1=[];  tgd1=[];  Y1=[];  H=[];  h=[];  tzd1=[];  tzw1=[];
				azi2=[];  ele2=[];  rho2=[];  ee2=[];  tgd2=[];  Y2=[];  H=[];  h=[];  tzd2=[];  tzw2=[];
				Y1=[];  H1=[];  h1=[];  Y2=[];  H2=[];  h2=[];
				Y3=[];  H3=[];  h3=[];  Y4=[];  H4=[];  h4=[];

				%--- 観測量
				%--------------------------------------------
				% CA コード擬似距離(バイアス補正によりP1に相当) & L1 搬送波位相
				Y1 = data1(:,2);
				Y2 = lam1*data1(:,1);
				Y3 = data2(:,2);
				Y4 = lam1*data2(:,1);

				%--- 幾何学的距離, 仰角, 方位角, 電離層, 対流圏の計算
				%--------------------------------------------
				for k = 1:length(prn.rov.v)
					% 幾何学的距離(放送暦/精密暦)
					%--------------------------------------------
					[rho1(k,1),sat_xyz1(k,:),sat_xyz_dot1(k,:),dtsv1(k,:)]=...
							geodist_mix(time,eph_prm,ephi,prn.rov.v(k),Kalx_p(ix.u1),dtr1,est_prm);
					[rho2(k,1),sat_xyz2(k,:),sat_xyz_dot2(k,:),dtsv2(k,:)]=...
							geodist_mix(time,eph_prm,ephi,prn.rov.v(k),Kalx_p(ix.u2),dtr2,est_prm);
					tgd1(k,:) = eph_prm.brd.data(33,ephi(prn.rov.v(k)));										% TGD
					tgd2(k,:) = eph_prm.brd.data(33,ephi(prn.rov.v(k)));										% TGD

					%--- 仰角, 方位角, 偏微分係数の計算
					%--------------------------------------------
					[ele1(k,1), azi1(k,1), ee1(k,:)]=azel(Kalx_p(ix.u1), sat_xyz1(k,:));
					[ele2(k,1), azi2(k,1), ee2(k,:)]=azel(Kalx_p(ix.u2), sat_xyz2(k,:));

					%--- 電離層遅延 & 対流圏遅延
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

				%--- 対流圏遅延のマッピング関数
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

				%--- 対流圏遅延推定用
				%--------------------------------------------
				if est_prm.mode==1
					switch est_prm.statemodel.trop
					case 1
						trop1=Md1.*tzd1+Mw1.*Kalx_p(ix.T);													% ZWD推定用
						trop2=Md2.*tzd2+Mw2.*Kalx_p(ix.T);													% ZWD推定用
					case 2
						trop1=Md1.*tzd1+Mw1.*(Kalx_p(ix.T)-tzd1);											% ZTD推定用
						trop2=Md2.*tzd2+Mw2.*(Kalx_p(ix.T)-tzd2);											% ZTD推定用
					end
				end

				% ハードウェアバイアス
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

				%--- 観測モデル
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

				%--- 観測雑音
				%--------------------------------------------
				HHs1 = []; HHs2 = [];
				for k = 1:length(prn.rov.v)
					HHs1(k,3*k-2:3*k) = ee1(k,:);															% 偏微分係数
					HHs2(k,3*k-2:3*k) = ee2(k,:);															% 偏微分係数
				end
				if est_prm.ww==1
					EE = (1./sin(ele1).^2);
				else
					EE = ones(length(prn.rov.v),1);
				end
				PR1  = repmat(est_prm.obsnoise.PR1,length(prn.rov.v),1).*EE;									% CAの分散
				PR2  = repmat(est_prm.obsnoise.PR2,length(prn.rov.v),1).*EE;									% PYの分散
				Ph1  = repmat(est_prm.obsnoise.Ph1,length(prn.rov.v),1).*EE;									% L1の分散
				Ph2  = repmat(est_prm.obsnoise.Ph2,length(prn.rov.v),1).*EE;									% L2の分散
				CLK  = repmat(est_prm.obsnoise.CLK,length(prn.rov.v),1).*EE;									% 衛星時計の分散
				ION1 = repmat(est_prm.obsnoise.ION,length(prn.rov.v),1).*EE;									% 電離層の分散
				TRP  = repmat(est_prm.obsnoise.TRP,length(prn.rov.v),1).*EE;									% 対流圏の分散
				ORB  = repmat(est_prm.obsnoise.ORB,length(prn.rov.v),1).*EE;									% 衛星軌道の分散

				if est_prm.mode==1
					TT = [II OO OO OO HHs1 II -II -II;														% 雑音の係数行列作成
					      OO II OO OO HHs2 II  II -II;
					      OO OO II OO HHs1 II -II -II;
					      OO OO OO II HHs2 II  II -II];
					RR = diag([PR1; PR1; Ph1; Ph1; ORB; ORB; ORB; CLK; ION1; TRP]);
					R = TT * RR * TT';																		% 雑音の共分散行列作成
				elseif est_prm.mode==2
					TT = [II OO (HHs1-HHs2);																% 雑音の係数行列作成
					      OO II (HHs1-HHs2)];
					RR = diag([2*PR1; 2*Ph1; ORB; ORB; ORB;]);
					R = TT * RR * TT';																		% 雑音の共分散行列作成
					R=[2*(eye(length(prn.rov.v)))*0.03^2 zeros(length(prn.rov.v));
					   zeros(length(prn.rov.v)) 2*(eye(length(prn.rov.v)))*0.3^2];									% observation noise
				end

				%--- 使用衛星分の抽出
				%--------------------------------------------
				if est_prm.mode==1
					ii = find(~isnan(Y1+Y2+Y3+Y4+h1+h2+h3+h4) &...
							ismember(prn.rov.v',rej)==0 & ele1*180/pi>est_prm.mask);							% Y, h に NaN のないやつの index & 仰角マスクカット
					H1 = H1(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H2 = H2(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H3 = H3(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H4 = H4(ii,[1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);
					H = [H1; H3; H2; H4];																	% observation matrix(ii 分)
					Y1 = Y1(ii,:);  Y2 = Y2(ii,:);  Y3 = Y3(ii,:);  Y4 = Y4(ii,:);
					Y = [Y1; Y3; Y2; Y4];																	% observation(ii分)
					h1 = h1(ii,:);  h2 = h2(ii,:);  h3 = h3(ii,:);  h4 = h4(ii,:);
					h = [h1; h3; h2; h4];																	% observation model(ii分)
					R  = R([ii',length(prn.rov.v)+ii',2*length(prn.rov.v)+ii',3*length(prn.rov.v)+ii'],...
						   [ii',length(prn.rov.v)+ii',2*length(prn.rov.v)+ii',3*length(prn.rov.v)+ii']);				% observation noise(ii分)
					prn.u = prn.rov.v(ii);

					Kalx_p=Kalx_p([1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);								% 次元調整
					KalP_p=KalP_p([1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii'],...
								  [1:nx.p,nx.p+ii',nx.p+length(prn.rov.v)+ii']);								% 次元調整
				elseif est_prm.mode==2
					ii = find(~isnan(Y1+Y2+h1+h2) &...
							ismember(prn.rov.v',rej)==0 & ele1*180/pi>est_prm.mask);							% Y, h に NaN のないやつの index & 仰角マスクカット
					H1 = H1(ii,[1:nx.p,nx.p+ii']);
					H2 = H2(ii,[1:nx.p,nx.p+ii']);
					H = [H1; H2];																			% observation matrix(ii 分)
					Y1 = Y1(ii,:);  Y2 = Y2(ii,:);  Y3 = Y3(ii,:);  Y4 = Y4(ii,:);
					Y = [Y1-Y3; Y2-Y4];																		% observation(ii分)
					h1 = h1(ii,:);  h2 = h2(ii,:);
					h = [h1; h2];																			% observation model(ii分)
					R  = R([ii',length(prn.rov.v)+ii'],[ii',length(prn.rov.v)+ii']);								% observation noise(ii分)
					prn.u = prn.rov.v(ii);

					Kalx_p=Kalx_p([1:nx.p,nx.p+ii']);														% 次元調整
					KalP_p=KalP_p([1:nx.p,nx.p+ii'],[1:nx.p,nx.p+ii']);										% 次元調整
				end

				%--- 偏微分をLocal(ENU)用に変換(キネマティック用)
				%--------------------------------------------
				ref_L=xyz2llh(refl);
				lat=ref_L(1); lon=ref_L(2);
				LL = [         -sin(lon),           cos(lon),        0;
					  -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
					   cos(lat)*cos(lon),  cos(lat)*sin(lon), sin(lat)];
				H(:,ix.u1)=(LL*H(:,ix.u1)')';
				H(:,ix.u2)=(LL*H(:,ix.u2)')';


				%--- 拘束条件
				%--------------------------------------------
				if est_prm.const == 1
					rr = 1;																					% 拘束の観測量
					rho12 = norm(Kalx_p(ix.u1)-Kalx_p(ix.u2));												% アンテナ間の距離
					H_c = [(Kalx_p(ix.u1)-Kalx_p(ix.u2))/rho12]';											% 勾配
					H_c = (LL*H_c')';
					H=[H; H_c repmat(0,1,nx.u-3) -H_c repmat(0,1,nx.u-3) repmat(0,1,size(H,2)-2*nx.u)];
					Y=[Y;rr];
					h=[h;rho12];
					R(length(Y),length(Y)) = 1e-6;
				end

				%--- イノベーション
				%--------------------------------------------
				zz = Y - h;

				%--- ECEF(WGS84)からLocalに変換
				%--------------------------------------------
				Kalx_p(ix.u1)=xyz2enu(Kalx_p(ix.u1),refl);
				Kalx_p(ix.u2)=xyz2enu(Kalx_p(ix.u2),refl);

				%--- カルマンフィルタ(観測更新)
				%--------------------------------------------
				[Kalx_f, KalP_f] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);

				%--- LocalからECEF(WGS84)に変換
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

		%--- MAP 推定(拘束条件)
		%-----------------------------------------------
		if est_prm.const == 2
			rr = 1;																						% 拘束の観測量
			rho12 = norm(Kalx_p(ix.u1)-Kalx_p(ix.u2));													% アンテナ間の距離
			H_c = [(Kalx_p(ix.u1)-Kalx_p(ix.u2))/rho12]';												% 勾配
			HH = [H_c repmat(0,1,nx.u-3) -H_c repmat(0,1,nx.u-3)];
			sigma_d = 1e-3;
			Rx = KalP_f(1:2*nx.u,1:2*nx.u);
			x_map = inv(inv(Rx) + HH'*HH./sigma_d^2)*(inv(Rx)*Kalx_f(1:2*nx.u) + rr*HH'./sigma_d^2);
			Kalx_f(1:2*nx.u) = x_map;
		end

		Kalx_fm=(Kalx_f(ix.u1)+Kalx_f(ix.u2))/2;														% mid pos

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos3 = xyz2enu(Kalx_f(ix.u1),est_prm.rovpos)';												% ENUに変換
		est_pos4 = xyz2enu(Kalx_f(ix.u2),est_prm.rovpos)';												% ENUに変換
		est_pos = xyz2enu(Kalx_fm,est_prm.rovpos)';
		est_pos(3)=est_pos(3)+0.3;

		%--- 結果格納
		%--------------------------------------------
% 		Result.vppp(timetag,1:2*nx.u+nx.t+2*nx.b+nx.T+1) = [time.tod Kalx_f(1:2*nx.u+nx.t+2*nx.b+nx.T)'];

		%--- 結果格納(VPPP解)
		%--------------------------------------------
		Result.vppp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];									% 時刻
		Result.vppp.pos(timetag,:)=[Kalx_fm', xyz2llh(Kalx_fm).*[180/pi 180/pi 1],...
									Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1],...
									Kalx_f(nx.u+1:nx.u+3)', xyz2llh(Kalx_f(nx.u+1:nx.u+3)).*[180/pi 180/pi 1]];		% 位置
		if est_prm.statemodel.dt==0 | est_prm.statemodel.dt==1
			Result.vppp.dtr(timetag,1:nx.t)=Kalx_f(2*nx.u+1:2*nx.u+nx.t);											% 受信機時計誤差
		end
		if est_prm.statemodel.hw==1
			Result.vppp.hwb(timetag,1:2*nx.b)=Kalx_f(2*nx.u+nx.t+1:2*nx.u+nx.t+2*nx.b);								% HWB
		end
		if est_prm.statemodel.trop~=0
			Result.vppp.dtrop(timetag,1:nx.T)=Kalx_f(2*nx.u+nx.t+2*nx.b+1:2*nx.u+nx.t+2*nx.b+nx.T);					% 対流圏遅延
		end

		%--- 結果格納
		%--------------------------------------------
		Res.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];											% 時刻
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
		%----- VPPP (カルマンフィルタ) ---->> 終了
		%------------------------------------------------------------------------------------------------------

		%--- 衛星変化チェック
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.u);			% 衛星変化のチェック
% 		end

		%--- 画面表示
		%--------------------------------------------
		fprintf('%10.5f %10.5f %10.5f   PRN:',est_pos(1),est_pos(2),est_pos(3));
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		fprintf('\n')

		%--- 衛星格納
		%--------------------------------------------
		Result.vppp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.u),dop1];
		Result.vppp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.u), Result.vppp.prn{2}(timetag,prn.u)=prn.u;, end

		%--- 結果書き出し
		%--------------------------------------------
		fprintf(f_sol,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',timetag,time.week,time.tow,time.tod,Kalx_fm,est_pos);

		%--- 次元の設定
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
%----- "メイン処理" 測位演算 ---->> 終了
%-----------------------------------------------------------------------------------------

%--- MATに保存
%--------------------------------------------
matname=sprintf('VPPP_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','Res','OBS','LC');

%--- 測位結果プロット
%--------------------------------------------
plot_data2([est_prm.dirs.result,matname]);

% %--- KML出力
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
% %--- NMEA出力
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
