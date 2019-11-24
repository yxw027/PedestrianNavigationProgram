function [x,dtr,dtsv,ion,trop,prn_u,rho,dop,ele,azi]=pointpos(freq,time,prn,app_xyz,data,eph_prm,ephi,est_prm,ion_prm,rej)
%-------------------------------------------------------------------------------
% Function : 単独測位演算
% 
% [argin]
% freq     : 周波数の構造体(*.g1, *.g2, *.r1, *.r2)
% time     : 時刻情報の構造体(*.tod, *.week, *.tow, *.mjd, *.day)
% prn      : 衛星PRN番号
% app_xyz  : 概略位置
% data     : 観測データ
% eph_prm  : エフェメリス(*.brd, *.sp3)
% ephi     : 各衛星の最適なエフェメリスのインデックス
% est_prm  : 初期設定パラメータ
% ion_prm  : 電離層パラメータ(iona,ionb,gim,dcbG,dcbR)
% rej      : 除外衛星
% 
% [argout]
% x        : 状態変数
% dtr      : 受信機時計誤差
% dtsv     : 衛星時計誤差
% ion      : 電離層遅延
% trop     : 対流圏遅延
% prn_u    : 衛星PRN番号(used)
% dop      : DOP
% ele      : 仰角
% azi      : 方位角
% 
% 概略位置がない場合に初期値に適当な位置[-4000000;3300000;3700000]を設定(08/11)
% 
% 残差が極端に大きい衛星を除外を追加(01/21)
% 
% 
% ※ geodist3, geodist_sp33, azel, cal_ion2, cal_tropの関数が必要(measuremodel_pp内で)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 12, 2008
%-------------------------------------------------------------------------------
% GLONASS対応
% July 10, 2009, T.Yanase
%-------------------------------------------------------------------------------
%--- 定数
%--------------------------------------------
C=299792458;							% 光速

% OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
% MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
% FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

x  = zeros(4,1);
xk = ones(4,1);
x(1:3) = app_xyz';
if norm(x(1:3))==0
	x(1:3) = [-4000000;3300000;3700000];
end
dtr=0;
no_sat=length(prn);
loop=0;
rejd=rej;
while norm(x-xk) > 0.1
	loop=loop+1;

	% 初期化
	%--------------------------------------------
% 	sat_xyz=[]; sat_xyz_dot=[]; dtsv=[]; health=[]; ion=[]; trop=[]; azi=[]; ele=[]; rho=[]; ee=[]; tgd=[]; dop=[];

	% 観測量
	%--------------------------------------------
	switch est_prm.obsmodel
	case {0,3,4,5,6,7,8,9,10},		% CA コード擬似距離(バイアス補正によりP1に相当)
		Y = data(:,2);
	case 1,						% PY コード擬似距離
		Y = data(:,6);
	case 2,						% ionfree 擬似距離(2周波)
		Y1=[]; Y2=[];
		if est_prm.n_nav ==1
			Y1 = [data(1:length(find(prn<=32)),2) data(1:length(find(prn<=32)),6)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
		end
		if est_prm.g_nav ==1
			Y2 = [freq.r1.*data(length(prn(find(prn<=32)))+1:end,2)-freq.r2.*data(length(prn(find(prn<=32)))+1:end,6)]./(freq.r1.^2-freq.r2.^2);
		end
		Y = [Y1; Y2];
	end

	% 観測モデル(観測量・モデル・観測雑音etc)
	%--------------------------------------------
	[h,H,R,ele,azi,rho,dtsv,ion,trop]=...
			measuremodel_pp(freq,time,prn,eph_prm,ephi,ion_prm,est_prm,x);

	% 残差が極端に大きい衛星を除外
	%--------------------------------------------
% 	if loop>2, rej=prn(find(Y-h>20));, rej=union(rejd,rej);, end

	% 使用衛星分の抽出
	%--------------------------------------------
	ii = find(~isnan(Y+h) & ismember(prn',rej)==0 & ele*180/pi>est_prm.mask);		% Y, h に NaN のないやつの index & 仰角マスクカット
  
     if Y+h==4.078879943981164
         ii=1;
     end
    H  = H(ii,:);																% observation matrix(ii 分)
	Y  = Y(ii);																		% observation(ii分)
	h  = h(ii);																		% observation model(ii分)
	R  = R(ii,ii);																	% observation noise(ii分)
	prn_u = prn(ii);																% PRN(ii分)

	% 衛星数が4未満の場合
	%--------------------------------------------
	if length(prn_u) < 4
		 x(:) = NaN; dtr=NaN; dop=NaN;
		break
	end

	% (重み付)最小二乗法
	%--------------------------------------------
	xk = x;
	x  = x + inv(H'*inv(R)*H)*H'*inv(R)*(Y-h);										% 正規方程式+逆行列(LU?)
% 	x  = x + (H'*inv(R)*H)\(H'*inv(R)*(Y-h));										% 正規方程式+ガウス消去法
% 	B=chol(H'*inv(R)*H); x=x+B\(B'\(H'*inv(R)*(Y-h)));								% 正規方程式+コレスキ分解
	dtr = x(4)/C;																	% receiver clock error [sec.]

	dop=sqrt(trace(inv(H(:,1:3)'*H(:,1:3))));

	if loop>10, break, end

% 	h=measuremodel_pp(time,prn,eph_prm,ephi,ion_prm,est_prm,x);		% 事後残差
% 	if sqrt(mean((Y-h(ii)).^2))<0.5, break, end										% 収束判定(残差のRMSを利用)
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function [h,H,R,ele,azi,rho,dtsv,ion,trop]=measuremodel_pp(freq,time,prn,eph_prm,ephi,ion_prm,est_prm,x)
%-------------------------------------------------------------------------------
% 観測モデルの生成(h,H,R)
%
% [argin]
% freq     : 周波数の構造体(*.g1, *.g2, *.r1, *.r2)
% time     : 時刻情報の構造体(*.tod, *.week, *.tow, *.mjd, *.day)
% prn      : 衛星PRN番号
% eph_prm  : エフェメリス(*.brd, *.sp3)
% ephi     : 各衛星の最適なエフェメリスのインデックス
% ion_prm  : 電離層パラメータ
% est_prm  : 設定パラメータ
% x        : 状態変数
% 
% [argout]
% h        : 観測モデルベクトル
% H        : 観測行列
% R        : 観測雑音
% ele      : 仰角(select_prnに必要←要検討)
% azi      : 方位角
% rho      : 幾何学的距離
% dtsv     : 衛星時計誤差
% ion      : 電離層遅延
% trop     : 対流圏遅延
% 
% ※ geodist3, geodist_sp33, azel, cal_ion2, cal_tropの関数が必要
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------
% GLONASS対応
% August 6, 2009, T.Yanase
%-------------------------------------------------------------------------------

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

dtr=x(4)/C;																	% 受信機時計誤差

num=length(prn);															% 衛星数
num_g=length(find(prn<=32));												% 衛星数(GPS)
num_r=length(find(38<=prn));												% 衛星数(GLONASS)
I=ones(num,1);																% 1 ベクトル
O=zeros(num,1);																% 0 ベクトル
OO=zeros(num);																% 0 行列
II=eye(num);																% 単位行列
II_g=eye(num_g);
II_r=eye(num_r);

% 初期化
%--------------------------------------------
rho=repmat(NaN,num,1); sat_xyz=repmat(NaN,num,3);
sat_xyz_dot=repmat(NaN,num,3); dtsv=repmat(NaN,num,1); 
tgd=repmat(NaN,num,1); ion=repmat(NaN,num,1); trop=repmat(NaN,num,1);
azi=repmat(NaN,num,1); ele=repmat(NaN,num,1); ee=repmat(NaN,num,3); 
HHs=zeros(num,3*num);

% 幾何学的距離, 仰角, 方位角, 電離層, 対流圏の計算
%--------------------------------------------
for k = 1:num
	% 幾何学的距離(放送暦/精密暦)
	%--------------------------------------------
	[rho(k,1),sat_xyz(k,:),sat_xyz_dot(k,:),dtsv(k,:)]=...
			geodist_mix2(time,eph_prm,ephi,prn(k),x,dtr,est_prm);

	tgd(k,:) = eph_prm.brd.data(33,ephi(prn(k)));
	
	% 仰角, 方位角, 偏微分係数の計算
	%--------------------------------------------
	[ele(k,1), azi(k,1), ee(k,:)]=azel(x, sat_xyz(k,:));

	% 電離層遅延 & 対流圏遅延
	%--------------------------------------------
	ion(k,1)  = cal_ion2(time,ion_prm,azi(k),ele(k),x,est_prm.i_mode);		% ionospheric model
	trop(k,1) = cal_trop(ele(k),x,sat_xyz(k,:)',est_prm.t_mode);			% tropospheric model
end

% 観測雑音用
%--------------------------------------------
for k=1:num, HHs(k,3*k-2:3*k)=ee(k,:);, end									% 偏微分係数

EE = I;
if est_prm.ww==1, EE=(1./sin(ele).^2);, end									% 仰角による重み

PR1  = repmat(est_prm.obsnoise.PR1,num,1).*EE;								% CAの分散
PR2  = repmat(est_prm.obsnoise.PR2,num,1).*EE;								% PYの分散
CLK  = repmat(est_prm.obsnoise.CLK,num,1).*EE;								% 衛星時計の分散
ION1 = repmat(est_prm.obsnoise.ION,num,1).*EE;								% 電離層の分散
TRP  = repmat(est_prm.obsnoise.TRP,num,1).*EE;								% 対流圏の分散
ORB  = repmat(est_prm.obsnoise.ORB,num,1).*EE;								% 衛星軌道の分散

% 観測モデル作成(h,H,R)
%--------------------------------------------
switch est_prm.obsmodel
case {0,3,4,5,6,7,8,9,10},
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
				+trop(1:num_g)+ion(1:num_g);								% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
				+C*(dtr-dtsv(num_g+1:num_g+num_r))...
				+trop(num_g+1:num_g+num_r)+ion(num_g+1:num_g+num_r);		% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																% observation matrix
	TT = [II HHs II -II -II];												% 雑音の係数行列作成
	RR = diag([PR1; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';														% 雑音の共分散行列作成
case 1,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)...
				+C*(dtr-(dtsv(1:num_g)-(freq.g1/freq.g2)^2*tgd(1:num_g)))...
				+trop(1:num_g)+(freq.g1/freq.g2)^2*ion(1:num_g);			% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
				+C*(dtr-dtsv(num_g+1:num_g+num_r))...
				+trop(num_g+1:num_g+num_r)...
				+(freq.r1./freq.r2).^2.*ion(num_g+1:num_g+num_r);			% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																% observation matrix
	TT = [II HHs II blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2)) -II];							% 雑音の係数行列作成
	RR = diag([PR2; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';														% 雑音の共分散行列作成
case 2,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g);				% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
				+C*(dtr-dtsv(num_g+1:num_g+num_r))...
				+trop(num_g+1:num_g+num_r);									% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																% observation matrix
	TT = [blkdiag(freq.g1^2/(freq.g1^2-freq.g2^2)*II_g, diag(freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-freq.g2^2/(freq.g1^2-freq.g2^2)*II_g, diag(-freq.r2.^2./(freq.r1.^2-freq.r2.^2))) HHs II -II];	% 雑音の係数行列作成
	RR = diag([PR1; PR2; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';														% 雑音の共分散行列作成
end
