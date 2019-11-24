%-------------------------------------------------------------------------------%
%                 杉本・久保研版 GPS測位演算ﾌﾟﾛｸﾞﾗﾑ　Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS測位演算プログラム(DGPS版)
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
%     3. DGPS(擬似距離の相対測位) (カルマンフィルタ)
%  9. 結果格納
% 10. 結果グラフ表示
% 
% 
%-------------------------------------------------------------------------------
% 必要な外部ファイル・関数
%-------------------------------------------------------------------------------
% phisic_const.m      : 物理変数定義
%-------------------------------------------------------------------------------
% FQ_state_all6.m     : 状態モデルの生成
%-------------------------------------------------------------------------------
% prn_check.m         : 衛星変化の検出
% sat_order.m         : 衛星PRNの順番の決定
% select_prn.m        : 使用衛星の選択
% state_adjust_dd5.m  : 衛星変化時の次元調節(DD用)
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
% measuremodel.m      : 観測モデル作成(h,H,R) + 幾何学距離
% obs_comb.m          : 各種線形結合の計算
% obs_vec.m           : 観測量ベクトル作成
%-------------------------------------------------------------------------------
% filtekf_pre.m       : カルマンフィルタの時間更新
% filtekf_upd.m       : カルマンフィルタの観測更新
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
% DGPSでは, 観測データが少ない(擬似距離のみ)のため, 電離層・対流圏推定が効果的に機能しない.
% したがって, 電離層・対流圏推定をしない方が現状としては精度がよい.
% 
% <課題>
% ・サイクルスリップ, 異常値検出(線形結合, 事前残差・事後残差検査)
% ・データ更新間隔が 1[sec]以下の場合× → 読み飛ばし, 時刻同期を修正
% 
% 残差チェックのために観測モデルを関数化する必要がある
% 事前と事後の観測モデルで利用する状態変数のみ異なるだけだから関数で利用できた方が便利
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov     : 可視衛星(rov)
%  prn.rovu    : 使用衛星(rov)
%  prn.ref.v.v     : 可視衛星(ref)
%  prn.refu    : 使用衛星(ref)
%  prn.c       : 共通可視衛星(rov,ref)
%  prn.u       : 共通使用衛星(rov,ref)
%  prn.o       : 前エポックの使用衛星(rov,ref)
% 
% 時刻同期の部分を改造(MJDのみで比較するようにしてみた+0.1秒まで見るように変更)
% → 更新間隔が1[Hz]以上でもできるように修正
% → それに伴い, 他にも修正している部分あり
% 
%-------------------------------------------------------------------------------
% latest update : 2009/02/25 by Fujita
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
fpo1=fopen([est_prm.dirs.obs,est_prm.file.rov_o],'rt');
fpn1=fopen([est_prm.dirs.obs,est_prm.file.rov_n],'rt');
fpo2=fopen([est_prm.dirs.obs,est_prm.file.ref_o],'rt');
fpn2=fopen([est_prm.dirs.obs,est_prm.file.ref_n],'rt');

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
	ion_prm.gim.time=[]; ion_prm.gim.map=[];
	ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- 精密暦の読込み
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);
else
	eph_prm.sp3.data=[];
end

%--- 設定情報の出力(DGPS用)
%--------------------------------------------
datname1=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol1  = fopen([est_prm.dirs.result,datname1],'w');							% 結果書き出しファイルのオープン
output_log(f_sol1,time_s,time_e,est_prm,2);

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

%--- DGPS用
%--------------------------------------------
Result.dgps.time(1:tt,1:10)=NaN; Result.dgps.time(:,1)=1:tt;					% 時刻
Result.dgps.pos(1:tt,1:6)=NaN;													% 位置
Result.dgps.dion(1:tt,1:32)=NaN;												% 電離層遅延
Result.dgps.dtrop(1:tt,1:2)=NaN;												% 対流圏遅延
for j=1:2, for k=1:32, Result.dgps.amb{j,k}(1:tt,1:32)=NaN;, end, end			% 整数値バイアス
Result.dgps.prn{1}(1:tt,1:32)=NaN;												% 可視衛星
Result.dgps.prn{2}(1:tt,1:32)=NaN;												% 使用衛星
Result.dgps.prn{3}(1:tt,1:3)=NaN;												% 衛星数
Result.dgps.prn{4}(1:tt,1:32)=NaN;												% 使用衛星(基準)

%--- 残差用
%--------------------------------------------
Res.time(1:tt,1:10)=NaN; Res.time(:,1)=1:tt;									% 時刻
for j=1:2, for k=1:32, Res.pre{j,k}(1:tt,1:32)=NaN;, end, end					% 残差(pre-fit)
for j=1:2, for k=1:32, Res.post{j,k}(1:tt,1:32)=NaN;, end, end					% 残差(post-fit)

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
LC.rov.mp1(1:tt,1:32)=NaN; LC.rov.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.rov.mw(1:tt,1:32)=NaN;														% MW
LC.rov.lgl(1:tt,1:32)=NaN; LC.rov.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.rov.lg1(1:tt,1:32)=NaN; LC.rov.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.rov.ionp(1:tt,1:32)=NaN; LC.rov.ionl(1:tt,1:32)=NaN;							% IONP, IONL

LC.ref.time(1:tt,1:10)=NaN; LC.ref.time(:,1)=1:tt;								% 時刻
LC.ref.mp1(1:tt,1:32)=NaN; LC.ref.mp2(1:tt,1:32)=NaN;							% MP1, MP2
LC.ref.mw(1:tt,1:32)=NaN;														% MW
LC.ref.lgl(1:tt,1:32)=NaN; LC.ref.lgp(1:tt,1:32)=NaN;							% LGL, LGP
LC.ref.lg1(1:tt,1:32)=NaN; LC.ref.lg2(1:tt,1:32)=NaN;							% LG1, LG2
LC.ref.ionp(1:tt,1:32)=NaN; LC.ref.ionl(1:tt,1:32)=NaN;							% IONP, IONL

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
		while time_s.mjd > time1.mjd+0.1/86400														% 約 0.1 秒ｽﾞﾚまで認める
			%--- エポック情報取得(時刻, PRN, Dataなど)
			%--------------------------------------------
			[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
					read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);

			if time_s.mjd <= time1.mjd+0.1/86400, sf=1; break;, end
		end
		while time_s.mjd > time2.mjd+0.1/86400														% 約 0.1 秒ｽﾞﾚまで認める
			%--- エポック情報取得(時刻, PRN, Dataなど)
			%--------------------------------------------
			[time2,no_sat2,prn.ref.v.v,dtrec2,ephi2,data2]=...
					read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);

			if time_s.mjd <= time2.mjd+0.1/86400, sf=1; break;, end
		end
	else
		%--- エポック情報取得(時刻, PRN, Dataなど)
		%--------------------------------------------
		[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
				read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
		[time2,no_sat2,prn.ref.v.v,dtrec2,ephi2,data2]=...
				read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
	end
	if sf==1
		%--- 時刻同期
		%--------------------------------------------
		while 1
			if abs(time1.mjd-time2.mjd)<=0.1/86400
				break;
			else
				if time1.mjd < time2.mjd
					while time1.mjd < time2.mjd
						%--- エポック情報取得(時刻, PRN など)
						%--------------------------------------------
						[time1,no_sat1,prn.rov.v,dtrec1,ephi1,data1]=...
								read_obs_epo_data(fpo1,eph_prm.brd.data,no_obs1,TYPES1);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time1.mjd-0.1/86400, break;, end							% 約 0.1 秒ｽﾞﾚまで認める
					end
				elseif time1.mjd > time2.mjd
					while time1.mjd > time2.mjd
						%--- エポック情報取得(時刻, PRN, Dataなど)
						%--------------------------------------------
						[time2,no_sat2,prn.ref.v.v,dtrec2,ephi2,data2]=...
								read_obs_epo_data(fpo2,eph_prm.brd.data,no_obs2,TYPES2);
						if abs(time1.mjd-time2.mjd)<=0.1/86400, break;, end
						if time_e.mjd <= time2.mjd-0.1/86400, break;, end							% 約 0.1 秒ｽﾞﾚまで認める
					end
				end
			end
			if abs(time1.mjd-time2.mjd)<=0.1/86400 | feof(fpo1) | feof(fpo2), break;, end
		end

		%--- end 判定
		%--------------------------------------------
		if time_e.mjd <= time1.mjd-0.1/86400 | time_e.mjd <= time2.mjd-0.1/86400, break;, end		% 約 0.1 秒ｽﾞﾚまで認める

		%--- タイムタグ
		%--------------------------------------------
		if timetag==0
			timetag = timetag + 1;
		else
			timetag = timetag + round((time1.mjd-time_o.mjd)*86400/dt);
		end

		%--- 読み取り中のエポックの時間表示
		%--------------------------------------------
		fprintf('%7d: %2d:%2d %5.2f"  ',timetag,time1.day(4),time1.day(5),time1.day(6));

		%------------------------------------------------------------------------------------------------------
		%----- 単独測位(最小二乗法)
		%------------------------------------------------------------------------------------------------------

		%--- 単独測位
		%--------------------------------------------
		[x1,dtr1,dtsv1,ion1,trop1,prn.rovu,rho1,dop1,ele1,azi1]=...
				pointpos2(time1,prn.rov.v,app_xyz1,data1,eph_prm,ephi1,est_prm,ion_prm,rej);
		[x2,dtr2,dtsv2,ion2,trop2,prn.refu,rho2,dop2,ele2,azi2]=...
				pointpos2(time2,prn.ref.v.v,app_xyz2,data2,eph_prm,ephi2,est_prm,ion_prm,rej);
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
		OBS.rov.ca(timetag,prn.rov.v)   = data1(:,2);													% CA
		OBS.rov.py(timetag,prn.rov.v)   = data1(:,6);													% PY
		OBS.rov.ph1(timetag,prn.rov.v)  = data1(:,1);													% L1
		OBS.rov.ph2(timetag,prn.rov.v)  = data1(:,5);													% L2
		OBS.rov.ion(timetag,prn.rov.v)  = ion1(:,1);													% Ionosphere
		OBS.rov.trop(timetag,prn.rov.v) = trop1(:,1);													% Troposphere

		OBS.ref.ca(timetag,prn.ref.v.v)   = data2(:,2);													% CA
		OBS.ref.py(timetag,prn.ref.v.v)   = data2(:,6);													% PY
		OBS.ref.ph1(timetag,prn.ref.v.v)  = data2(:,1);													% L1
		OBS.ref.ph2(timetag,prn.ref.v.v)  = data2(:,5);													% L2
		OBS.ref.ion(timetag,prn.ref.v.v)  = ion2(:,1);													% Ionosphere
		OBS.ref.trop(timetag,prn.ref.v.v) = trop2(:,1);													% Troposphere

		OBS.rov.ele(timetag,prn.rov.v) = ele1(:,1);													% elevation
		OBS.rov.azi(timetag,prn.rov.v) = azi1(:,1);													% azimuth
		OBS.ref.ele(timetag,prn.ref.v.v) = ele2(:,1);													% elevation
		OBS.ref.azi(timetag,prn.ref.v.v) = azi2(:,1);													% azimuth

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
		OBS.rov.ca_cor(timetag,prn.rov.v)  = data1(:,2);												% CA
		OBS.rov.py_cor(timetag,prn.rov.v)  = data1(:,6);												% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v) = data1(:,1);												% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v) = data1(:,5);												% L2

		OBS.ref.ca_cor(timetag,prn.ref.v.v)  = data2(:,2);												% CA
		OBS.ref.py_cor(timetag,prn.ref.v.v)  = data2(:,6);												% PY
		OBS.ref.ph1_cor(timetag,prn.ref.v.v) = data2(:,1);												% L1
		OBS.ref.ph2_cor(timetag,prn.ref.v.v) = data2(:,5);												% L2

		%--- 各種線形結合(補正済み観測量を使用)
		%--------------------------------------------
		[mp11,mp21,lgl1,lgp1,lg11,lg21,mw1,ionp1,ionl1] = obs_comb(data1);
		[mp12,mp22,lgl2,lgp2,lg12,lg22,mw2,ionp2,ionl2] = obs_comb(data2);

		%--- 各種線形結合を格納
		%--------------------------------------------
		ii=find(ele1*180/pi>est_prm.mask);
		LC.rov.mp1(timetag,prn.rov.v(ii))  = mp11(ii);												% Multipath 線形結合(L1)
		LC.rov.mp2(timetag,prn.rov.v(ii))  = mp21(ii);												% Multipath 線形結合(L2)
		LC.rov.mw(timetag,prn.rov.v(ii))   = mw1(ii);													% Melbourne-Wubbena 線形結合
		LC.rov.lgl(timetag,prn.rov.v(ii))  = lgl1(ii);												% 幾何学フリー線形結合(搬送波)
		LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp1(ii);												% 幾何学フリー線形結合(コード)
		LC.rov.lg1(timetag,prn.rov.v(ii))  = lg11(ii);												% 幾何学フリー線形結合(1周波)
		LC.rov.lg2(timetag,prn.rov.v(ii))  = lg21(ii);												% 幾何学フリー線形結合(2周波)
		LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp1(ii);												% 電離層(lgpから算出)
		LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl1(ii);												% 電離層(lglから算出,Nを含む)

		ii=find(ele2*180/pi>est_prm.mask);
		LC.ref.mp1(timetag,prn.ref.v.v(ii))  = mp12(ii);												% Multipath 線形結合(L1)
		LC.ref.mp2(timetag,prn.ref.v.v(ii))  = mp22(ii);												% Multipath 線形結合(L2)
		LC.ref.mw(timetag,prn.ref.v.v(ii))   = mw2(ii);													% Melbourne-Wubbena 線形結合
		LC.ref.lgl(timetag,prn.ref.v.v(ii))  = lgl2(ii);												% 幾何学フリー線形結合(搬送波)
		LC.ref.lgp(timetag,prn.ref.v.v(ii))  = lgp2(ii);												% 幾何学フリー線形結合(コード)
		LC.ref.lg1(timetag,prn.ref.v.v(ii))  = lg12(ii);												% 幾何学フリー線形結合(1周波)
		LC.ref.lg2(timetag,prn.ref.v.v(ii))  = lg22(ii);												% 幾何学フリー線形結合(2周波)
		LC.ref.ionp(timetag,prn.ref.v.v(ii)) = ionp2(ii);												% 電離層(lgpから算出)
		LC.ref.ionl(timetag,prn.ref.v.v(ii)) = ionl2(ii);												% 電離層(lglから算出,Nを含む)

		%--- 線形結合による異常値検定
		%--------------------------------------------
		% 未実装なので組み込んで下さい

		%------------------------------------------------------------------------------------------------------
		%----- 相対測位(カルマンフィルタ)
		%------------------------------------------------------------------------------------------------------

		%--- 共通衛星の抽出
		%--------------------------------------------
		[prn.c,a,b]=intersect(prn.rov.v,prn.ref.v.v);														% 共通衛星
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
			[F,Q]=FQ_state_all6(nxo,round((time1.mjd-time_o.mjd)*86400),est_prm,7);

			%--- ECEF(WGS84)からLocal(ENU)に変換
			%--------------------------------------------
			Kalx_f(1:3)=xyz2enu(Kalx_f(1:3),est_prm.refpos);

			%--- カルマンフィルタ(時間更新)
			%--------------------------------------------
			[Kalx_p, KalP_p] = filtekf_pre(Kalx_f, KalP_f, F, Q);

			%--- Local(ENU)からECEF(WGS84)に変換
			%--------------------------------------------
			Kalx_p(1:3)=enu2xyz(Kalx_p(1:3),est_prm.refpos);
		end

		if est_prm.statemodel.pos==4, Kalx_p(1:3)=x1(1:3);, end

		%--- 観測更新の計算(反復可能)
		%--------------------------------------------
		if ~isnan(x1(1))
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
					tgd1(k,:)=eph_prm.brd.data(33,ephi1(prn.c(k)));									% TGD
					tgd2(k,:)=eph_prm.brd.data(33,ephi2(prn.c(k)));									% TGD

					%--- 仰角, 方位角, 偏微分係数の計算
					%--------------------------------------------
					[ele1(k,1),azi1(k,1),ee1(k,:)]=azel(Kalx_p, sat_xyz1(k,:));
					[ele2(k,1),azi2(k,1),ee2(k,:)]=azel(est_prm.refpos, sat_xyz2(k,:));

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

				%--- 利用可能な衛星のインデックス
				%--------------------------------------------
				if est_prm.freq==1
					ii=find(~isnan(Ysdp1+rho1+rho2) & ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% 利用可能な衛星のインデックス
				else
					ii=find(~isnan(Ysdp1+Ysdp2+rho1+rho2) & ismember(prn.c',rej)==0 & ...
							ele1*180/pi>est_prm.mask & ele2*180/pi>est_prm.mask);					% 利用可能な衛星のインデックス
				end

				%--- 衛星数が4未満の場合
				%--------------------------------------------
				if length(ii)<4, z=[]; Kalx_f(1:nx.u+nx.T)=NaN; break;, end

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

					KalP_p=[est_prm.P0.std_dev_p,est_prm.P0.std_dev_v,...
							est_prm.P0.std_dev_a,est_prm.P0.std_dev_j];
					KalP_p=blkdiag(diag(KalP_p(1:nx.u)),eye(nx.T)*est_prm.P0.std_dev_T,...
							eye(nx.i)*est_prm.P0.std_dev_i).^2;										% 初期共分散行列
				else																				% 2エポック目以降(次元調節)
					%--- 次元調節後の状態変数と共分散
					%--------------------------------------------
					[Kalx_p,KalP_p]=...
							state_adjust_dd5(prn,Kalx_p,KalP_p,nxo,est_prm,ion12p,[],[],[]);		% 一段予測値 / 共分散行列
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
				if est_prm.freq==1																	% 1周波(CA)
					%--- DD観測モデル(CA)
					%--------------------------------------------
					Y=[TD*Ysdp1(ii(b))];															% DD obs(CA)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu  MI];												% DD obs matrix(CA)
					else
						H=[TD*ee1(ii(b),:) Mwu];													% DD obs matrix(CA)
					end
					h=[TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12];									% DD obs model(CA)
				else																				% 2周波(CA, PY)
					%--- DD観測モデル(CA,PY)
					%--------------------------------------------
					Y=[TD*Ysdp1(ii(b)); TD*Ysdp2(ii(b))];											% DD obs(CA, PY)
					if est_prm.statemodel.ion~=0
						H=[TD*ee1(ii(b),:) Mwu            MI;										% DD obs matrix(CA)
						   TD*ee1(ii(b),:) Mwu  (f1/f2)^2*MI];										% DD obs matrix(PY)
					else
						H=[TD*ee1(ii(b),:) Mwu;														% DD obs matrix(CA)
						   TD*ee1(ii(b),:) Mwu];													% DD obs matrix(PY)
					end
					h=[TD*(rho1(ii(b))-rho2(ii(b)))+trop12+ion12;									% DD obs model(CA)
					   TD*(rho1(ii(b))-rho2(ii(b)))+trop12+(f1/f2)^2*ion12];						% DD obs model(PY)
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
				else
					PR1a=(est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);								% コードの分散(重み考慮)
					PR2a=(est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);								% コードの分散(重み考慮)
					PR1b=(est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);								% コードの分散(重み考慮)
					PR2b=(est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);								% コードの分散(重み考慮)
% 					PR1a=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele1(ii(b))).^2);			% コードの分散(重み考慮)
% 					PR2a=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele1(ii(b))).^2);			% コードの分散(重み考慮)
% 					PR1b=(est_prm.obsnoise.PR1+est_prm.obsnoise.PR1./sin(ele2(ii(b))).^2);			% コードの分散(重み考慮)
% 					PR2b=(est_prm.obsnoise.PR2+est_prm.obsnoise.PR2./sin(ele2(ii(b))).^2);			% コードの分散(重み考慮)
				end
				PR1 = diag(PR1a+PR1b); PR2 = diag(PR2a+PR2b);										% コードの分散(1重差)
				if est_prm.freq==1
					R=TD*PR1*TD';																	% DD obs noise(CA)
				else
					R=blkdiag(TD*PR1*TD',TD*PR2*TD');												% DD obs noise(CA,PY)
				end

				%--- イノベーション
				%--------------------------------------------
				zz = Y - h;

				%--- ECEF(WGS84)からLocal(ENU)に変換
				%--------------------------------------------
				Kalx_p(1:3)=xyz2enu(Kalx_p(1:3),est_prm.refpos);

				%--- カルマンフィルタ(観測更新)
				%--------------------------------------------
				[Kalx_f, KalP_f, V] = filtekf_upd(zz, H, R, Kalx_p, KalP_p);
% 				[Kalx_f, KalP_f] = filtsrcf_upd(zz, H, R, Kalx_p, KalP_p);

				%--- Local(ENU)からECEF(WGS84)に変換
				%--------------------------------------------
				Kalx_f(1:3)=enu2xyz(Kalx_f(1:3),est_prm.refpos);

				Kalx_p=Kalx_f;  KalP_p=KalP_f;

				%--- DGPS解の次元
				%--------------------------------------------
				% 電離層遅延については, 時間更新のために利用する必要があるから
				nxo.u=nx.u;
				nxo.T=nx.T;
				nxo.i=nx.i;
				nxo.x=nxo.u+nxo.T+nxo.i;

				prn.o = prn.u;																		% 観測更新のために必要
			end
		else
			zz=[];
			prn.u=[];
			Kalx_f(1:nx.u+nx.T) = NaN;
		end

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos3 = xyz2enu(Kalx_f(1:3),est_prm.rovpos)';											% ENUに変換(dgps)

		%--- 結果格納(DGPS解)
		%--------------------------------------------
		Result.dgps.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];				% 時刻
		Res.time(timetag,2:10)=[time1.week, time1.tow, time1.tod, time1.day];						% 時刻
		if ~isempty(zz)
			%--- 残差
			%--------------------------------------------
			Res.pre{1,prn.u(1)}(timetag,prn.u(2:end))=zz(1:(length(prn.u)-1),1)';					% CA(pre-fit)
			Res.post{1,prn.u(1)}(timetag,prn.u(2:end))=V(1:(length(prn.u)-1),1)';					% CA(post-fit)
			if est_prm.freq==2
				Res.pre{2,prn.u(1)}(timetag,prn.u(2:end))=...
						zz(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';								% PY(pre-fit)
				Res.post{2,prn.u(1)}(timetag,prn.u(2:end))=...
						V(1+(length(prn.u)-1):2*(length(prn.u)-1),1)';								% PY(post-fit)
			end

			%--- 結果格納(DGPS解)
			%--------------------------------------------
			Result.dgps.pos(timetag,:)=[Kalx_f(1:3)', xyz2llh(Kalx_f(1:3)).*[180/pi 180/pi 1]];		% 位置
			switch est_prm.statemodel.ion
			case 1,
				Result.dgps.dion(timetag,prn.u(2:end))=Kalx_f(ix.i);								% 電離層遅延
			case {2,3}
				Result.dgps.dion(timetag,prn.u)=Kalx_f(ix.i);										% 電離層遅延
			case 4
				Result.dgps.dion(timetag,1:2)=Kalx_f(ix.i);											% 電離層遅延
			case 5
				Result.dgps.dion(timetag,1:4)=Kalx_f(ix.i);											% 電離層遅延
			end
			if est_prm.statemodel.trop~=0
				Result.dgps.dtrop(timetag,:)=Kalx_f(ix.T);											% 対流圏遅延
			end
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
		fprintf('%10.4f %10.4f %10.4f  %3d   PRN:',est_pos3(1:3),length(prn.u));
		for k=1:length(prn.u), fprintf('%4d',prn.u(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		if ~isempty(rej), fprintf(' , AHO');, end
		fprintf('\n')

		%--- 衛星格納
		%--------------------------------------------
		Result.dgps.prn{3}(timetag,1:4)=[time1.tod,length(prn.c),length(prn.u),dop1];
		Result.dgps.prn{1}(timetag,prn.c)=prn.c;
		if ~isempty(prn.u)
			Result.dgps.prn{2}(timetag,prn.u)=prn.u;
			Result.dgps.prn{4}(timetag,prn.u(1))=prn.u(1);
		end

		%--- 結果書き出し
		%--------------------------------------------
		fprintf(f_sol1,'%7d %5d %9.0f %7d %14.4f %14.4f %14.4f %12.4f %12.4f %12.4f\n',...
				timetag,time1.week,time1.tow,time1.tod,Kalx_f(1:3),est_pos3);

		prn.o = prn.u;
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
matname=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.mat',...
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
% kmlname2=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname1],Result.spp);
% output_kml([est_prm.dirs.result,kmlname2],Result.dgps);
% 
% %--- NMEA出力
% %--------------------------------------------
% nmeaname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% nmeaname2=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname1],Result.spp);
% output_nmea([est_prm.dirs.result,nmeaname2],Result.dgps);
% 
% %--- INS用
% %--------------------------------------------
% insname1=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% insname2=sprintf('DGPS_%s_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{:},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname1],Result.spp,est_prm);
% output_ins([est_prm.dirs.result,insname2],Result.dgps,est_prm);

fclose('all');
