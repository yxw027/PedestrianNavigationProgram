function [rho,sat_xyz,sat_xyz_dot,dtsv] = geodist_mix(time, eph_prm, ephi, prn, x, dtr, est_prm)
%-------------------------------------------------------------------------------
% Function : 衛星軌道計算 & 幾何学距離計算(光路差方程式より)
%
% [argin]
% time        : 時刻情報の構造体(*.tod, *.week, *.tow, *.mjd, *.day)
% eph_prm     : エフェメリス(*.brd, *.sp3)
% ephi        : 各衛星の最適なエフェメリスのインデックス
% prn         : 衛星PRN番号
% x           : 状態変数
% dtr         : 受信機時計誤差
% est_prm     : 初期設定パラメータ
% 
% [argout]
% rho         : 幾何学距離
% sat_xyz     : 衛星座標
% sat_xyz_dot : 衛星速度
% dtsv        : 衛星時計誤差
% 
% 放送暦/精密暦のどちらにも対応
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% GLONASS対応
% July 10, 2009, T.Yanase
%-------------------------------------------------------------------------------

% argoutの値の初期値にNaNを設定
%--------------------------------------------
rho=NaN;,sat_xyz(1:3)=NaN;,sat_xyz_dot(1:3)=NaN;,dtsv=NaN;

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

% 衛星軌道, 幾何学距離計算
%--------------------------------------------
rho  = 2e7;
rhok = 0;
Eph_mat=eph_prm.brd.data(:,ephi(prn));
Data_sp3=eph_prm.sp3.data;
degree=9;
while abs(rho-rhok) > 1e-4
	if est_prm.sp3==0
		[sat_xyz,sat_xyz_dot,dtsv]=...
				sat_pos2(time.day,Eph_mat,rho,dtr,est_prm);				% 衛星軌道, 衛星時計計算
	elseif est_prm.sp3 == 1
		[sat_xyz,sat_xyz_dot,dtsv]=...
				interp_lag(time.day,Data_sp3,prn,rho,dtr,degree);		% IGS(sp3) データ補間(新バージョン)
	end
	Rz = [ cos(OMGE*rho/C),sin(OMGE*rho/C),0;
		  -sin(OMGE*rho/C),cos(OMGE*rho/C),0;
		                 0,              0,1];							% 回転補正
% 	if est_prm.simu == 0;												% シミュレーション [0:OFF, 1:ON]
% 		[sat_xyz, sat_xyz_dot, dtsv]=...
% 				sat_pos(time.day, Eph_mat, rho*0, dtr*0);				% シミュレーション用
% 		Rz=eye(3);														% シミュレーション用(回転補正無し)
% 	end
	rrs  = x(1:3) - Rz*sat_xyz';
	rhok = rho;															% 幾何学距離(1つ前のループ)
	rho = norm(rrs);													% 幾何学距離(今ループ)
end
if est_prm.sp3 == 1
% 	dtsv = dtsv - 2*sat_xyz*sat_xyz_dot'/C^2;										% 特殊相対論補正
% 	dtsv = dtsv - 2*dot(sat_xyz',sat_xyz_dot')/C^2;									% 特殊相対論補正
% 	dtsv = dtsv - 2*sat_xyz*(sat_xyz_dot+cross([0,0,OMGE],sat_xyz))'/C^2;			% 特殊相対論補正
	dtsv = dtsv - 2*dot(sat_xyz',(sat_xyz_dot'+cross([0,0,OMGE]',sat_xyz')))'/C^2;	% 特殊相対論補正
end

if 37<prn
	sat_xyz=pz2xyz((Rz*sat_xyz')');										% 衛星軌道(GLONASS)(回転補正済)
else
	sat_xyz=(Rz*sat_xyz')';												% 衛星軌道(GPS)(回転補正済)
end
