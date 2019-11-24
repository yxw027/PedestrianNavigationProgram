%-------------------------------------------------------------------------------%
%                 杉本・久保研版 GPS測位演算ﾌﾟﾛｸﾞﾗﾑ　Ver. 0.1                   %
%                                                                               %
%             (C)Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division               %
%                           Fujita: December 12, 2006                           %
%-------------------------------------------------------------------------------%
% 
% GPS測位演算プログラム(SPP版)
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
%  9. 結果格納
% 10. 結果グラフ表示
% 
% 
%-------------------------------------------------------------------------------
% 必要な外部ファイル・関数
%-------------------------------------------------------------------------------
% phisic_const.m      : 物理変数定義
%-------------------------------------------------------------------------------
% FQ_state_all5.m     : 状態モデルの生成
%-------------------------------------------------------------------------------
% prn_check.m         : 衛星変化の検出
%-------------------------------------------------------------------------------
% cal_time2.m         : 指定時刻のGPS週番号・ToW・ToDの計算
% clkjump_repair2.m   : 受信機時計の飛びの検出/修正
% mjuliday.m          : MJDの計算
% weekf.m             : WEEK, TOW の計算
%-------------------------------------------------------------------------------
% fileget2.m          : ファイル名生成とダウンロード(wget.exe, gzip.exe)
%-------------------------------------------------------------------------------
% read_eph2.m         : エフェメリスの取得
% read_ionex2.m       : IONEXデータ取得
% read_obs_epo_data2.m: OBSエポック情報解析 & OBS観測データ取得
% read_obs_h.m        : OBSヘッダー解析
% read_sp3.m          : 精密暦データ取得
%-------------------------------------------------------------------------------
% azel.m              : 仰角, 方位角, 偏微分係数の計算
% geodist_mix.m       : 幾何学的距離等の計算(放送暦・精密暦)
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
% <課題>
% ・データ更新間隔が 1[sec]以下の場合× → 読み飛ばしを修正
% ・異常値検出(線形結合, 事前残差・事後残差検査)
% 
% 衛星PRN構造体について(取扱いに注意)
%  prn.rov.v     : 可視衛星(rov)
%  prn.rovu    : 使用衛星(rov)
% 
% 更新間隔が1[Hz]以上でもできるように修正
% → それに伴い, 他にも修正している部分あり
% 
%-------------------------------------------------------------------------------
% latest update : 2008/11/17 by Fujita
%-------------------------------------------------------------------------------
% 
% ・GLONASS対応
% 
% <課題>
% ・衛星加速度・回転補正の考察
% ・各種雑音, パラメータ設定の見直し(GLONASS測位に限定)
% ・電離層等の推定手法
% 
%-------------------------------------------------------------------------------
% latest update : 2010/01/12 by Yanase
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
	fprintf('oファイル%sを開けません.\n',est_prm.file.rov_o);				% Rov obs(エラー処理)
	break;
end
if est_prm.n_nav==1
	if fpn==-1
	fprintf('nファイル%sを開けません.\n',est_prm.file.rov_n);				% Rov nav(GPS)(エラー処理)
	break;
	end
end
if est_prm.g_nav==1
	if fpg==-1
	fprintf('gファイル%sを開けません.\n',est_prm.file.rov_g);				% Rov nav(GLONASS)(エラー処理)
	break;
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
	ion_prm.gim.time=[]; ion_prm.gim.map=[]; ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end
if est_prm.i_mode==3
	load('ENMdata20081201_2.mat');
	ion_prm.gim.time=[]; ion_prm.gim.map=[]; ion_prm.gim.dcbG=[]; ion_prm.gim.dcbR=[];
end

%--- 精密暦の読込み
%--------------------------------------------
if est_prm.sp3==1
	eph_prm.sp3.data=read_sp3([est_prm.dirs.sp3,est_prm.file.sp3]);
else
	eph_prm.sp3.data=[];
end

%--- 設定情報の出力
%--------------------------------------------
datname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.dat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
f_sol  = fopen([est_prm.dirs.result,datname],'w');							% 結果書き出しファイルのオープン
output_log2(f_sol,time_s,time_e,est_prm,1);

%--- 次元の設定(状態モデルごと)
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

%--- 配列の準備
%--------------------------------------------
tt=(time_e.tod-time_s.tod)/dt+1;

%--- SPP用
%--------------------------------------------
Result.spp.time(1:tt,1:10)=NaN; Result.spp.time(:,1)=1:tt;						% 時刻
Result.spp.pos(1:tt,1:6)=NaN;													% 位置
Result.spp.dtr(1:tt,1:1)=NaN;													% 受信機時計誤差
Result.spp.prn{1}(1:tt,1:61)=NaN;												% 可視衛星
Result.spp.prn{2}(1:tt,1:61)=NaN;												% 使用衛星
Result.spp.prn{3}(1:tt,1:3)=NaN;												% 衛星数

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

		%------------------------------------------------------------------------------------------------------
		%----- 単独測位(最小二乗法)
		%------------------------------------------------------------------------------------------------------

		%--- GLONASSの衛星・周波数処理
		%--------------------------------------------
		if est_prm.g_nav==1														% GLONASS周波数, 波長
			freq.r1=eph_prm.brd.data(25,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L1 周波数(GLONASS)
			wave.r1=C ./ freq.r1;												% L2 波長(GLONASS)
			freq.r2=eph_prm.brd.data(26,ephi(prn.rov.v(find(38<=prn.rov.v))))';		% L2 周波数(GLONASS)
			wave.r2=C ./ freq.r2;												% L2 波長(GLONASS)
			else
			freq.r1=[]; wave.r1=[];
			freq.r2=[]; wave.r2=[];
		end

		%--- 単独測位
		%--------------------------------------------
		[x,dtr,dtsv,ion,trop,prn.rovu,rho,dop,ele,azi]=...
				pointpos3(freq,time,prn.rov.v,app_xyz,data,eph_prm,ephi,est_prm,ion_prm,rej);
		if ~isnan(x(1)), app_xyz(1:3)=x(1:3);, end

		%--- 潮汐の補正
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

		%--- 真値を基準とした各軸方向の誤差
		%--------------------------------------------
		est_pos = xyz2enu(x(1:3),est_prm.rovpos)';											% ENUに変換

		%--- 結果格納(SPP)
		%--------------------------------------------
		Result.spp.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];			% 時刻
		Result.spp.pos(timetag,:)=[x(1:3)', xyz2llh(x(1:3)).*[180/pi 180/pi 1]];			% 位置
		Result.spp.dtr(timetag,:)=C*dtr;													% 受信機時計誤差

		%--- 衛星格納
		%--------------------------------------------
		Result.spp.prn{3}(timetag,1:4)=[time.tod,length(prn.rov.v),length(prn.rovu),dop];
		Result.spp.prn{1}(timetag,prn.rov.v)=prn.rov.v;
		if ~isempty(prn.rovu), Result.spp.prn{2}(timetag,prn.rovu)=prn.rovu;, end

		%--- OBSデータ,電離層遅延(構造体)
		%--------------------------------------------
		OBS.rov.time(timetag,2:10)=[time.week, time.tow, time.tod, time.day];				% 時刻
		OBS.rov.ca(timetag,prn.rov.v)   = data(:,2);				% CA
		OBS.rov.py(timetag,prn.rov.v)   = data(:,6);				% PY
		OBS.rov.ph1(timetag,prn.rov.v)  = data(:,1);				% L1
		OBS.rov.ph2(timetag,prn.rov.v)  = data(:,5);				% L2
		OBS.rov.ion(timetag,prn.rov.v)  = ion(:,1);				% Ionosphere
		OBS.rov.trop(timetag,prn.rov.v) = trop(:,1);				% Troposphere

		OBS.rov.ele(timetag,prn.rov.v)  = ele(:,1);				% elevation
		OBS.rov.azi(timetag,prn.rov.v)  = azi(:,1);				% azimuth

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
			dtr_all(timetag,1) = dtr;															% 受信機時計誤差を格納
			[data,dtr,time.day,clk_jump,dtr_o,jump_width_all]=...
					clkjump_repair2(time.day,data,dtr,dtr_o,jump_width_all,Rec_type);			% clock jump 検出/補正
			clk_check(timetag,1) = clk_jump;													% ジャンプフラグを格納
		end
		dtr_all(timetag,2) = dtr;															% 補正済み受信機時計誤差を格納

		%--- 補正済み観測量を格納
		%--------------------------------------------
		OBS.rov.ca_cor(timetag,prn.rov.v)  = data(:,2);				% CA
		OBS.rov.py_cor(timetag,prn.rov.v)  = data(:,6);				% PY
		OBS.rov.ph1_cor(timetag,prn.rov.v) = data(:,1);				% L1
		OBS.rov.ph2_cor(timetag,prn.rov.v) = data(:,5);				% L2

		%--- 各種線形結合(補正済み観測量を使用)
		%--------------------------------------------
		[mp1,mp2,lgl,lgp,lg1,lg2,mw,ionp,ionl] = obs_comb(data);

		%--- 各種線形結合を格納
		%--------------------------------------------
% 		LC.rov.mp1(timetag,prn.rov.v)  = mp1;							% Multipath 線形結合(L1)
% 		LC.rov.mp2(timetag,prn.rov.v)  = mp2;							% Multipath 線形結合(L2)
% 		LC.rov.mw(timetag,prn.rov.v)   = mw;							% Melbourne-Wubbena 線形結合
% 		LC.rov.lgl(timetag,prn.rov.v)  = lgl;							% 幾何学フリー線形結合(搬送波)
% 		LC.rov.lgp(timetag,prn.rov.v)  = lgp;							% 幾何学フリー線形結合(コード)
% 		LC.rov.lg1(timetag,prn.rov.v)  = lg1;							% 幾何学フリー線形結合(1周波)
% 		LC.rov.lg2(timetag,prn.rov.v)  = lg2;							% 幾何学フリー線形結合(2周波)
% 		LC.rov.ionp(timetag,prn.rov.v) = ionp;						% 電離層(lgpから算出)
% 		LC.rov.ionl(timetag,prn.rov.v) = ionl;						% 電離層(lglから算出,Nを含む)

		ii=find(ele*180/pi>est_prm.mask);
		LC.rov.mp1(timetag,prn.rov.v(ii))  = mp1(ii);							% Multipath 線形結合(L1)
		LC.rov.mp2(timetag,prn.rov.v(ii))  = mp2(ii);							% Multipath 線形結合(L2)
		LC.rov.mw(timetag,prn.rov.v(ii))   = mw(ii);							% Melbourne-Wubbena 線形結合
		LC.rov.lgl(timetag,prn.rov.v(ii))  = lgl(ii);							% 幾何学フリー線形結合(搬送波)
		LC.rov.lgp(timetag,prn.rov.v(ii))  = lgp(ii);							% 幾何学フリー線形結合(コード)
		LC.rov.lg1(timetag,prn.rov.v(ii))  = lg1(ii);							% 幾何学フリー線形結合(1周波)
		LC.rov.lg2(timetag,prn.rov.v(ii))  = lg2(ii);							% 幾何学フリー線形結合(2周波)
		LC.rov.ionp(timetag,prn.rov.v(ii)) = ionp(ii);						% 電離層(lgpから算出)
		LC.rov.ionl(timetag,prn.rov.v(ii)) = ionl(ii);						% 電離層(lglから算出,Nを含む)

		%------------------------------------------------------------------------------------------------------
		%----- クロックジャンプ補正 ---->> 終了
		%------------------------------------------------------------------------------------------------------

		%--- 衛星変化チェック
		%--------------------------------------------
% 		if timetag > 1
% 			[lost,rise,i_lost,i_rise,change_flag] = prn_check(prn.o,prn.rovu);			% 衛星変化のチェック
% 		end

		%--- 画面表示
		%--------------------------------------------
		fprintf('%10.5f %10.5f %10.5f  %3d   PRN:',est_pos(1:3),length(prn.rovu));
		for k=1:length(prn.rovu), fprintf('%4d',prn.rovu(k));, end
% 		if change_flag==1, fprintf(' , Change');, end
		fprintf('\n')

		%--- 結果書き出し
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
matname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.mat',...
		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% save([est_prm.dirs.result,matname]);
save([est_prm.dirs.result,matname],...
		'est_prm','ion_prm','eph_prm','Result','OBS','LC');

%--- 測位結果プロット
%--------------------------------------------
plot_data2([est_prm.dirs.result,matname]);

% %--- KML出力
% %--------------------------------------------
% kmlname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.kml',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_kml([est_prm.dirs.result,kmlname],Result.spp,'B','G');
% 
% %--- NMEA出力
% %--------------------------------------------
% nmeaname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d.nmea',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_nmea([est_prm.dirs.result,nmeaname],Result.spp);
% 
% %--- INS用
% %--------------------------------------------
% insname=sprintf('SPP_%s_%4d%02d%02d_%02d-%02d_ins.csv',...
% 		est_prm.rcv{1},time_s.day(1:3),round([time_s.tod,time_e.tod]/3600));
% output_ins([est_prm.dirs.result,insname],Result.spp,est_prm);

fclose('all');
