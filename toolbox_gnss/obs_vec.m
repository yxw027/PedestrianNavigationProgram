function Y=obs_vec(data,prn,obsmodel)
%-------------------------------------------------------------------------------
% Function : 観測量の作成
% 
% [argin]
% data      : 観測データ
% prn       : 衛星PRN番号
% obs_model : 観測モデル
% 
% [argout]
% Y         : 観測量ベクトル
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

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

switch obsmodel
case 0,		% CA コード擬似距離(バイアス補正によりP1に相当)
	Y = data(:,2);
case 1,		% PY コード擬似距離
	Y = data(:,6);
case 2,		% ionfree 観測量(2周波擬似距離)
	Y = [data(:,2) data(:,6)]*[f1^2; -f2^2]/(f1^2-f2^2);
case 3,		% CA コード擬似距離(バイアス補正によりP1に相当) & L1 搬送波位相
	Y1 = data(:,2);
	Y2 = lam1*data(:,1);
	Y = [Y1; Y2];
case 4,		% ionfree 観測量(1周波擬似距離 & 搬送波)
	Y = 0.5*(data(:,2) + lam1*data(:,1));
case 5,		% ionfree 観測量(2周波搬送波)
	Y = [lam1*data(:,1) lam2*data(:,5)]*[f1^2; -f2^2]/(f1^2-f2^2);
case 6,		% CA,PY コード擬似距離(バイアス補正によりP1に相当) & L1,L2 搬送波位相
	Y1 = data(:,2);
	Y2 = lam1*data(:,1);
	Y3 = data(:,6);
	Y4 = lam2*data(:,5);
	Y = [Y1; Y3; Y2; Y4];
case 7,		% ionfree 観測量(1周波擬似距離 & 搬送波)
	Y1 = 0.5*(data(:,2) + lam1*data(:,1));
	Y2 = 0.5*(data(:,6) + lam2*data(:,5));
	Y = [Y1; Y2];
case 8,		% ionfree 観測量(2周波擬似距離 & 搬送波)
	Y1 = [data(:,2) data(:,6)]*[f1^2; -f2^2]/(f1^2-f2^2);
	Y2 = [lam1*data(:,1) lam2*data(:,5)]*[f1^2; -f2^2]/(f1^2-f2^2);
	Y = [Y1; Y2];
case 9,		% CA コード擬似距離(バイアス補正によりP1に相当) & L1,L2 搬送波位相
	Y1 = data(:,2);
	Y2 = lam1*data(:,1);
	Y3 = lam2*data(:,5);
	Y = [Y1; Y2; Y3];
end
