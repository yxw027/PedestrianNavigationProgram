function [h,H,R,ele,rho,dtsv,ion,trop]=measuremodel2(freq,wave,time,prn,eph_prm,ephi,ion_prm,est_prm,x,nx)
%-------------------------------------------------------------------------------
% Function : 観測モデルの生成(h,H,R)
%
% [argin]
% freq     : 周波数の構造体(*.g1, *.g2, *.r1, *.r2)
% wave     : 波長の構造体(*.g1, *.g2, *.r1, *.r2)
% time     : 時刻情報の構造体(*.tod, *.week, *.tow, *.mjd, *.day)
% prn      : 衛星PRN番号
% eph_prm  : エフェメリス(*.brd, *.sp3)
% ephi     : 各衛星の最適なエフェメリスのインデックス
% ion_prm  : 電離層パラメータ
% est_prm  : 設定パラメータ
% x        : 状態変数
% nx       : 状態変数の次元
% 
% [argout]
% h        : 観測モデルベクトル
% H        : 観測行列
% R        : 観測雑音
% ele      : 仰角(select_prnに必要←要検討)
% rho      : 幾何学的距離
% dtsv     : 衛星時計誤差
% ion      : 電離層遅延
% trop     : 対流圏遅延
% 
% gen_model.mをサブルーチンとして組込み
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% GLONASSの周波数, 波長の変化に対応
% Jan. 15, 2010, T.Yanase
%-------------------------------------------------------------------------------

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
% f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
% f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

% OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
% MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
% FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

dtr=x(nx.u+1)/C;						% 受信機時計誤差

% 幾何学的距離, 仰角, 方位角, 電離層, 対流圏の計算
%--------------------------------------------
for k = 1:length(prn)
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
	ion(k,1)=cal_ion2(time,ion_prm,azi(k),ele(k),x,est_prm.i_mode);					% ionospheric model
	[trop(k,1),tzd(k,1),tzw(k,1)]=...
			cal_trop(ele(k),x,sat_xyz(k,:)',est_prm.t_mode);						% tropospheric model
end

% 観測モデル
%--------------------------------------------
[h,H,R]=gen_model(rho,dtr,dtsv,tgd,trop,ion,ee,ele,azi,est_prm,x,prn,nx,tzd,tzw,freq,wave,time);


if find([0,1,2]==est_prm.obsmodel)
	H=[H(:,1:3) repmat(0,size(H,1),nx.u-3)...
		 H(:,4) repmat(0,size(H,1),nx.t-1) zeros(size(H,1),1)];										% observation matrix for kinematic
else
	H=[H(:,1:3) repmat(0,size(H,1),nx.u-3)...
		 H(:,4) repmat(0,size(H,1),nx.t-1) H(:,5:end)];								% observation matrix for kinematic
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function [h,H,R]=gen_model(rho,dtr,dtsv,tgd,trop,ion,ee,ele,azi,est_prm,x,prn,nx,tzd,tzw,freq,wave,time)
%-------------------------------------------------------------------------------
% Function : 観測モデルの作成(h,H,R)
% 
% [argin]
% rho     : 幾何学的距離
% dtr     : 受信機時計誤差
% dtsv    : 衛星時計誤差
% tgd     : 群遅延パラメータ
% trop    : 対流圏遅延
% ion     : 電離層遅延
% ee      : 偏微分係数
% ele     : 仰角
% est_prm : パラメータ設定値
% x       : 状態変数
% prn     : 衛星PRN番号
% nx      : 状態変数の次元
% 
% [argout]
% h       : 観測モデルベクトル
% H       : 観測行列
% R       : 観測雑音行列
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
% f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
% f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長
% 
% OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
% MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
% FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

num=length(prn);
num_g=length(find(prn<=32));											% 衛星数(GPS)
num_r=length(find(38<=prn));											% 衛星数(GLONASS)
I=ones(num,1);
I_g=ones(num_g,1);
I_r=ones(num_r,1);
O=zeros(num,1);
OO=zeros(num);
II=eye(num);
II_g=eye(num_g);
II_r=eye(num_r);
OOO = zeros(num,3);
III = eye(3);
OOOO = zeros(3,num);

% ハードウェアバイアス
%--------------------------------------------
hwb1=0; hwb2=0; hwb3=0; hwb4=0;
if est_prm.statemodel.hw==1
	switch nx.b
	case 4,
		hwb1=x(nx.u+nx.t+1); hwb2=x(nx.u+nx.t+2);
		hwb3=x(nx.u+nx.t+3); hwb4=x(nx.u+nx.t+4);
	case 3,
		hwb1=x(nx.u+nx.t+1); hwb2=x(nx.u+nx.t+2); hwb3=x(nx.u+nx.t+3);
	case 2,
		hwb1=x(nx.u+nx.t+1); hwb2=x(nx.u+nx.t+2);
	end
end

% 対流圏遅延
%--------------------------------------------
Mw=[];
if est_prm.statemodel.trop~=0
	switch est_prm.mapf_trop
	case 1, [Md,Mw]=mapf_cosz(ele);												% cosz(Md,Mw)
	case 2, [Md,Mw]=mapf_chao(ele);												% Chao(Md,Mw)
	case 3, [Md,Mw]=mapf_gmf(time.day,x,ele)									% GMF(Md,Mw)
	case 4, [Md,Mw]=mapf_marini(time.day,x,ele)									% Marini(Md,Mw)
	end
end
Mgn=[]; Mge=[];
switch est_prm.statemodel.trop
case 1, trop=Md.*tzd+Mw.*x(nx.u+nx.t+nx.b+nx.T);								% ZWD推定用
case 2, trop=Md.*tzd+Mw.*(x(nx.u+nx.t+nx.b+nx.T)-tzd);							% ZTD推定用
case 3, Mgn=Mw.*cot(ele).*cos(azi); Mge=Mw.*cot(ele).*sin(azi);
		trop=Md.*tzd+Mw.*x(nx.u+nx.t+nx.b+1)...
				+Mgn.*x(nx.u+nx.t+nx.b+2)...
				+Mge.*x(nx.u+nx.t+nx.b+3);										% ZWD+Gradient推定用
case 4, Mgn=Mw.*cot(ele).*cos(azi); Mge=Mw.*cot(ele).*sin(azi);
		trop=Md.*tzd+Mw.*(x(nx.u+nx.t+nx.b+1)-tzd)...
				+Mgn.*x(nx.u+nx.t+nx.b+2)...
				+Mge.*x(nx.u+nx.t+nx.b+3);										% ZTD+Gradient推定用
end

% 電離層遅延
%--------------------------------------------
Fi=[];
if est_prm.statemodel.ion~=0
	Re = 6371000;																% earth radius
	Hr = 450000;																% ionospheric height
	Fi=1./sqrt(1-(Re.*cos(ele)/(Re+Hr)).^2);									% mapping function
end
Fgn=[]; Fge=[];
switch est_prm.statemodel.ion
case 1, ion=Fi.*x(nx.u+nx.t+nx.b+nx.T+1);										% ZID推定用
case 2, ion=Fi.*x(nx.u+nx.t+nx.b+nx.T+1); Fi=[Fi Fi*0];							% ZID+dZID推定用
case 3, Fgn=Fi.*cot(ele).*cos(azi); Fge=Fi.*cot(ele).*sin(azi);
		ion=Fi.*x(nx.u+nx.t+nx.b+nx.T+1)...
				+Fgn.*x(nx.u+nx.t+nx.b+nx.T+2)...
				+Fge.*x(nx.u+nx.t+nx.b+nx.T+3);									% ZID+Gradient推定用
end

% 整数値バイアス
%--------------------------------------------
if find([3,4,5,6,7,8,9]==est_prm.obsmodel)
	N1_g=repmat(NaN,num_g,1);
	N1_r=repmat(NaN,num_r,1);
	N2_g=repmat(NaN,num_g,1);
	N2_r=repmat(NaN,num_r,1);
	N1_g=x(nx.u+nx.t+nx.b+nx.T+nx.i+1:nx.u+nx.t+nx.b+nx.T+nx.i+num_g);
	N1_r=x(nx.u+nx.t+nx.b+nx.T+nx.i+num_g+1:nx.u+nx.t+nx.b+nx.T+nx.i+num_g+num_r);
	if est_prm.freq==2
		N2_g=x(nx.u+nx.t+nx.b+nx.T+nx.i+num_g+num_r+1:nx.u+nx.t+nx.b+nx.T+nx.i+2*num_g+num_r);
		N2_r=x(nx.u+nx.t+nx.b+nx.T+nx.i+2*num_g+num_r+1:nx.u+nx.t+nx.b+nx.T+nx.i+2*(num_g+num_r));
	end
end

% 観測雑音用
%--------------------------------------------
for k=1:num, HHs(k,3*k-2:3*k)=ee(k,:);, end										% 偏微分係数

EE = I;
if est_prm.ww==1, EE=(1./sin(ele).^2);, end										% 仰角による重み

PR1  = repmat(est_prm.obsnoise.PR1,num,1).*EE;									% CAの分散
PR2  = repmat(est_prm.obsnoise.PR2,num,1).*EE;									% PYの分散
Ph1  = repmat(est_prm.obsnoise.Ph1,num,1).*EE;									% L1の分散
Ph2  = repmat(est_prm.obsnoise.Ph2,num,1).*EE;									% L2の分散
CLK  = repmat(est_prm.obsnoise.CLK,num,1).*EE;									% 衛星時計の分散
ION1 = repmat(est_prm.obsnoise.ION,num,1).*EE;									% 電離層の分散
TRP  = repmat(est_prm.obsnoise.TRP,num,1).*EE;									% 対流圏の分散
ORB  = repmat(est_prm.obsnoise.ORB,num,1).*EE;									% 衛星軌道の分散
%INS  = repmat(est_prm.obsnoise.INS,3,1);


% 観測モデル作成(h,H,R)
%--------------------------------------------
switch est_prm.obsmodel
case 0
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
			+trop(1:num_g)+ion(1:num_g);										% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			+trop(num_g+1:num_g+num_r)+ion(num_g+1:num_g+num_r);				% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																	% observation matrix
	TT = [II HHs II -II -II];													% 雑音の係数行列作成
	RR = diag([PR1; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 1,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)...
			+C*(dtr-(dtsv(1:num_g)-(freq.g1/freq.g2)^2*tgd(1:num_g)))...
			+trop(1:num_g)+(freq.g1/freq.g2)^2*ion(1:num_g);					% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
			+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
			+(freq.r1./freq.r2).^2.*ion(num_g+1:num_g+num_r);					% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																	% observation matrix
	TT = [II HHs II blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2))...
			 -II];																% 雑音の係数行列作成
	RR = diag([PR2; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 2,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g);					% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)...
			+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r);		% observation model
	end
	h = [h_g; h_r];
	H = [ee I];																	% observation matrix
	TT = [blkdiag(freq.g1^2/(freq.g1^2-freq.g2^2)*II_g, diag(freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-freq.g2^2/(freq.g1^2-freq.g2^2)*II_g, diag(-freq.r2.^2./(freq.r1.^2-freq.r2.^2)))...
		  HHs II -II];															% 雑音の係数行列作成
	RR = diag([PR1; PR2; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 3,
	h_g1=[];, h_g2=[];, h_r1=[];, h_r2=[];
	if est_prm.n_nav==1
		h_g1 = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
			 +trop(1:num_g)+ion(1:num_g)+hwb1;									% observation model
		h_g2 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))...
			 +trop(1:num_g)-ion(1:num_g)+wave.g1*N1_g+hwb2;						% observation model
	end
	if est_prm.g_nav==1
		h_r1 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			+trop(num_g+1:num_g+num_r)+ion(num_g+1:num_g+num_r)+hwb1;			% observation model
		h_r2 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
		-ion(num_g+1:num_g+num_r)+wave.r1.*N1_r+hwb2;							% observation model
	end
	if est_prm.statemodel.hw == 0
		H1 = [ee I Mw Mgn Mge  Fi  Fgn  Fge OO];								% observation matrix
		H2 = [ee I Mw Mgn Mge -Fi -Fgn -Fge...
			 blkdiag(wave.g1*II_g, diag(wave.r1))];								% observation matrix
	else
		H1 = [ee I I O Mw Mgn Mge  Fi  Fgn  Fge OO];							% observation matrix
		H2 = [ee I O I Mw Mgn Mge -Fi -Fgn -Fge...
			 blkdiag(wave.g1*II_g, diag(wave.r1))];								% observation matrix
	end
	h=[h_g1;h_r1;h_g2;h_r2];  H=[H1;H2];
	TT = [II OO HHs II -II -II;													% 雑音の係数行列作成
	      OO II HHs II  II -II];
	RR = diag([PR1; Ph1; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 4,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-0.5*tgd(1:num_g)))...
			+trop(1:num_g)+0.5*wave.g1*N1_g;									% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)+C*(dtr-(dtsv(num_g+1:num_g+num_r)))...
			+trop(num_g+1:num_g+num_r)+0.5*wave.r1.*N1_r;						% observation model
	end
	h = [h_g; h_r];
	H = [ee I Mw Mgn Mge 0.5*blkdiag(wave.g1*II_g, diag(wave.r1))];				% observation matrix
	TT = [0.5*II 0.5*II HHs II -II];											% 雑音の係数行列作成
	RR = diag([PR1; Ph1; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 5,
	h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g)...
			+wave.g1*freq.g1^2/(freq.g1^2-freq.g2^2)*N1_g...
			-wave.g2*freq.g2^2/(freq.g1^2-freq.g2^2)*N2_g;						% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
			+wave.r1.*freq.r1.^2./(freq.r1.^2-freq.r2.^2).*N1_r...
			-wave.r2.*freq.r2.^2./(freq.r1.^2-freq.r2.^2).*N2_r;				% observation model
	end
	h = [h_g; h_r];
	H = [ee I Mw Mgn Mge...
		 blkdiag(wave.g1*freq.g1^2/(freq.g1^2-freq.g2^2)*II_g,...
		 diag(wave.r1.*freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-wave.g2*freq.g2^2/(freq.g1^2-freq.g2^2)*II_g,...
		 diag(-wave.r2.*freq.r2.^2./(freq.r1.^2-freq.r2.^2)))];					% observation matrix
	TT = [blkdiag(freq.g1^2/(freq.g1^2-freq.g2^2)*II_g,...
		 diag(freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-freq.g2^2/(freq.g1^2-freq.g2^2)*II_g,...
		 diag(-freq.r1.^2./(freq.r1.^2-freq.r2.^2))) HHs II -II];				% 雑音の係数行列作成
	RR = diag([Ph1; Ph2; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 6,
	h_g1=[];, h_g2=[];, h_g3=[];, h_g4=[]; h_r1=[];, h_r2=[];, h_r3=[];, h_r4=[];
	if est_prm.n_nav==1
	h_g1 = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
		 +trop(1:num_g)+ion(1:num_g)+hwb1;										% observation model
	h_g2 = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-(freq.g1/freq.g2)^2*tgd(1:num_g)))...
		 +trop(1:num_g)+(freq.g1/freq.g2)^2*ion(1:num_g)+hwb2;					% observation model
	h_g3 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))...
		 +trop(1:num_g)-ion(1:num_g)+wave.g1*N1_g+hwb3;							% observation model
	h_g4 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g)...
		 -(freq.g1/freq.g2)^2*ion(1:num_g)+wave.g2*N2_g+hwb4;					% observation model
	end
	if est_prm.g_nav==1 & ~isempty(freq.r1./freq.r2)
	h_r1 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)
		 +ion(num_g+1:num_g+num_r)+hwb1;										% observation model
	h_r2 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
		 +(freq.r1./freq.r2).^2.*ion(num_g+1:num_g+num_r)+hwb2;					% observation model
	h_r3 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
		 -ion(num_g+1:num_g+num_r)+wave.r1.*N1_r+hwb3;							% observation model
	h_r4 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
		 -(freq.r1./freq.r2).^2.*ion(num_g+1:num_g+num_r)...
		 +wave.r2.*N2_r+hwb4;													% observation model
	end
	if est_prm.statemodel.hw == 0
		if ~isempty(Fi) & ~isempty(Fgn)
			H1 = [ee I Mw Mgn Mge  Fi  Fgn  Fge  OO OO];						% observation matrix
			H2 = [ee I Mw Mgn Mge  [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fi...
					  [(freq.g1/freq.g2)^2*I_g;  (freq.r1./freq.r2).^2].*Fgn...
					  [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fge...
					 OO OO];													% observation matrix
			H3 = [ee I Mw Mgn Mge  -Fi  -Fgn  -Fge...
				 blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H4 = [ee I Mw Mgn Mge  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fi...
					  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fgn...
					  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fge...
					 OO blkdiag(wave.g2*II_g, diag(wave.r2))];					% observation matrix
		elseif ~isempty(Fi)
			H1 = [ee I Mw Mgn Mge  Fi  OO OO];									% observation matrix
			H2 = [ee I Mw Mgn Mge  [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fi...
				 OO OO];														% observation matrix
			H3 = [ee I Mw Mgn Mge -Fi...
				  blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H4 = [ee I Mw Mgn Mge  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fi...
				  OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		else
			H1 = [ee I Mw Mgn Mge OO OO];										% observation matrix
			H2 = [ee I Mw Mgn Mge OO OO];										% observation matrix
			H3 = [ee I Mw Mgn Mge blkdiag(wave.g1*II_g, diag(wave.r1)) OO];		% observation matrix
			H4 = [ee I Mw Mgn Mge OO blkdiag(wave.g2*II_g, diag(wave.r2))];		% observation matrix
		end
	else
		if ~isempty(Fi) & ~isempty(Fgn)
			H1 = [ee I I O O O Mw Mgn Mge  Fi  Fgn  Fge OO OO];					% observation matrix
			H2 = [ee I O I O O Mw Mgn Mge [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fi...
					  [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fgn...
					  [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fge...
					 OO OO];													% observation matrix
			H3 = [ee I O O I O Mw Mgn Mge  -Fi  -Fgn  -Fge...
				 blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H4 = [ee I O O O I Mw Mgn Mge  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fi...
					  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fgn...
					  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fge...
					 OO blkdiag(wave.g2*II_g, diag(wave.r2))];					% observation matrix
		elseif ~isempty(Fi)
			H1 = [ee I I O O O Mw Mgn Mge Fi OO OO];							% observation matrix
			H2 = [ee I O I O O Mw Mgn Mge  [(freq.g1/freq.g2)^2*I_g; (freq.r1./freq.r2).^2].*Fi...
				  OO OO];														% observation matrix
			H3 = [ee I O O I O Mw Mgn Mge -Fi...
				  blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H4 = [ee I O O O I Mw Mgn Mge  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fi...
				  OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		else
			H1 = [ee I I O O O Mw Mgn Mge OO OO];								% observation matrix
			H2 = [ee I O I O O Mw Mgn Mge OO OO];								% observation matrix
			H3 = [ee I O O I O Mw Mgn Mge...
				 blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H4 = [ee I O O O I Mw Mgn Mge...
				 OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		end
    end
	h=[h_g1;h_g2;h_g3;h_g4];
    %H行列を拡張
    H=[H1;H2;H3;H4];
    %雑音の係数行列を拡張
	TT = [II OO OO OO HHs II -II -II;											% 雑音の係数行列作成
	      OO II OO OO HHs II -(freq.g1/freq.g2)^2*II -II;
	      OO OO II OO HHs II  II -II;
	      OO OO OO II HHs II  (freq.g1/freq.g2)^2*II -II];
	RR = diag([PR1; PR2; Ph1; Ph2; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 7,
	h_g1=[];, h_g2=[];, h_r1=[];, h_r2=[];
	if est_prm.n_nav==1
		h_g1 = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-0.5*tgd(1:num_g)))...
			 +trop(1:num_g)+0.5*wave.g1*N1_g;									% observation model
		h_g2 = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-0.5*(freq.g1/freq.g2)^2*tgd(1:num_g)))...
			 +trop(1:num_g)+0.5*wave.g2*N2_g;									% observation model
	end
	if est_prm.g_nav==1
		h_r1 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			 +trop(num_g+1:num_g+num_r)+0.5*wave.r1.*N1_r;						% observation model
		h_r2 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			 +trop(num_g+1:num_g+num_r)+0.5*wave.r2.*N2_r;						% observation model
	end
	H1 = [ee I Mw Mgn Mge 0.5*blkdiag(wave.g1*II_g, diag(wave.r1)) OO];			% observation matrix
	H2 = [ee I Mw Mgn Mge OO 0.5*blkdiag(wave.g2*II_g, diag(wave.r2))];			% observation matrix
	h=[h_g1;h_r1;h_g2;h_r2]; H=[H1;H2];
	TT = [0.5*II 0.5*II OO OO HHs II -II;										% 雑音の係数行列作成
	      OO OO 0.5*II 0.5*II HHs II -II];
	RR = diag([PR1; Ph1; PR2; Ph2; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 8,
	h_g1=[];, h_g2=[];, h_r1=[];, h_r2=[];
	if est_prm.n_nav==1
		h_g1 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g);				% observation model
		h_g2 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g)...
			 +wave.g1*freq.g1^2/(freq.g1^2-freq.g2^2)*N1_g...
			 -wave.g2*freq.g2^2/(freq.g1^2-freq.g2^2)*N2_g;						% observation model
	end
	if est_prm.g_nav==1
		h_r1 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			 +trop(num_g+1:num_g+num_r);										% observation model
		h_r2 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
			 +wave.r1.*freq.r1.^2./(freq.r1.^2-freq.r2.^2).*N1_r...
			 -wave.r2.*freq.r2.^2./(freq.r1.^2-freq.r2.^2).*N2_r;				% observation model
	end
	H1 = [ee I Mw Mgn Mge OO OO];											% observation matrix
	H2 = [ee I Mw Mgn Mge...
		 wave.g1*freq.g1^2/(freq.g1^2-freq.g2^2)*II...
		 -wave.g2*freq.g2^2/(freq.g1^2-freq.g2^2)*II];							% observation matrix
	h=[h_g1;h_r1;h_g2;h_r2]; H=[H1;H2];
	TT = [blkdiag(freq.g1^2/(freq.g1^2-freq.g2^2)*II_g, diag(freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-freq.g2^2/(freq.g1^2-freq.g2^2)*II_g, diag(-freq.r2.^2./(freq.r1.^2-freq.r2.^2)))...
		 OO OO HHs II -II;
		 OO OO blkdiag(freq.g1^2/(freq.g1^2-freq.g2^2)*II_g, diag(freq.r1.^2./(freq.r1.^2-freq.r2.^2)))...
		 blkdiag(-freq.g2^2/(freq.g1^2-freq.g2^2)*II_g, diag(-freq.r2.^2./(freq.r1.^2-freq.r2.^2)))...
		 HHs II -II];															% 雑音の係数行列作成
	RR = diag([PR1; PR2; Ph1; Ph2; ORB; ORB; ORB; CLK; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成

case 9,
	h_g1=[];, h_g2=[];, h_g3=[];, h_r1=[];, h_r2=[];, h_r3=[];
	if est_prm.n_nav==1
		h_g1 = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
			 +trop(1:num_g)+ion(1:num_g)+hwb1;									% observation model
		h_g2 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))...
			 +trop(1:num_g)-ion(1:num_g)+wave.g1*N1_g+hwb2;						% observation model
		h_g3 = rho(1:num_g)+C*(dtr-dtsv(1:num_g))+trop(1:num_g)...
			 -(freq.g1/freq.g2)^2*ion(1:num_g)+wave.g2*N2_g+hwb3;				% observation model
	end
	if est_prm.g_nav==1
		h_r1 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			 +trop(num_g+1:num_g+num_r)+ion(num_g+1:num_g+num_r)+hwb1;			% observation model
		h_r2 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
			 -ion(num_g+1:num_g+num_r)+wave.r1.*N1_r+hwb2;						% observation model
		h_r3 = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))+trop(num_g+1:num_g+num_r)...
			 -(freq.r1./freq.r2).^2.*ion(num_g+1:num_g+num_r)...
			 +wave.r2.*N2_r+hwb3;												% observation model
	end
	if est_prm.statemodel.hw == 0
		if ~isempty(Fi) & ~isempty(Fgn)
			H1 = [ee I Mw Mgn Mge  Fi  Fgn  Fge  OO OO];						% observation matrix
			H2 = [ee I Mw Mgn Mge  -Fi  -Fgn  -Fge...
				 blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H3 = [ee I Mw Mgn Mge...
				  blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2))*Fi...
				  blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2))*Fgn...
				  blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2))*Fge...
				  OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		elseif ~isempty(Fi)
			H1 = [ee I Mw Mgn Mge  Fi  OO OO];									% observation matrix
			H2 = [ee I Mw Mgn Mge  -Fi...
				  blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H3 = [ee I Mw Mgn Mge blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2))*Fi...
				 OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		else
			H1 = [ee I Mw Mgn Mge OO OO];										% observation matrix
			H2 = [ee I Mw Mgn Mge blkdiag(wave.g1*II_g, diag(wave.r1)) OO];		% observation matrix
			H3 = [ee I Mw Mgn Mge OO blkdiag(wave.g2*II_g, diag(wave.r2))];		% observation matrix
		end
	else
		if ~isempty(Fi) & ~isempty(Fgn)
			H1 = [ee I I O O Mw Mgn Mge  Fi  Fgn  Fge  OO OO];					% observation matrix
			H2 = [ee I O I O Mw Mgn Mge  -Fi  -Fgn  -Fge...
				  blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H3 = [ee I O O I Mw Mgn Mge...
				  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fi...
				  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fgn...
				  [-(freq.g1/freq.g2)^2*I_g; -(freq.r1./freq.r2).^2].*Fge...
				  OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		elseif ~isempty(Fi)
			H1 = [ee I I O O Mw Mgn Mge  Fi  OO OO];							% observation matrix
			H2 = [ee I O I O Mw Mgn Mge  -Fi...
				  blkdiag(wave.g1*II_g, diag(wave.r1)) OO];						% observation matrix
			H3 = [ee I O O I Mw Mgn Mge blkdiag(-(freq.g1/freq.g2)^2*II_g, diag(-(freq.r1./freq.r2).^2))*Fi...
				  OO blkdiag(wave.g2*II_g, diag(wave.r2))];						% observation matrix
		else
			H1 = [ee I Mw Mgn Mge OO OO];										% observation matrix
			H2 = [ee I Mw Mgn Mge blkdiag(wave.g1*II_g, diag(wave.r1)) OO];		% observation matrix
			H3 = [ee I Mw Mgn Mge OO blkdiag(wave.g2*II_g, diag(wave.r2))];		% observation matrix
		end
	end
	h=[h_g1;h_r1;h_g2;h_r2;h_g3;h_r3];  H=[H1;H2;H3];
	TT = [II OO OO HHs II -II -II;												% 雑音の係数行列作成
	      OO II OO HHs II  II -II;
	      OO OO II HHs II  blkdiag((freq.g1/freq.g2)^2*II_g, diag((freq.r1./freq.r2).^2))  -II];
	RR = diag([PR1; Ph1; Ph2; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';															% 雑音の共分散行列作成
case 10
    h_g=[]; h_r=[];
	if est_prm.n_nav==1
		h_g = rho(1:num_g)+C*(dtr-(dtsv(1:num_g)-tgd(1:num_g)))...
			+trop(1:num_g)+ion(1:num_g);										% observation model
	end
	if est_prm.g_nav==1
		h_r = rho(num_g+1:num_g+num_r)+C*(dtr-dtsv(num_g+1:num_g+num_r))...
			+trop(num_g+1:num_g+num_r)+ion(num_g+1:num_g+num_r);				% observation model
	end
	h = [h_g; h_r];
	H = [ee zeros(num,1) I];																	% observation matrix
    TT = [II HHs II -II -II];													% 雑音の係数行列作成
	RR = diag([PR1; ORB; ORB; ORB; CLK; ION1; TRP]);
	R = TT * RR * TT';
end
