function Y=obs_vec(freq,wave,data,prn,obsmodel,est_prm)
%-------------------------------------------------------------------------------
% Function : 観測量の作成
% 
% [argin]
% freq      : 周波数の構造体(*.g1, *.g2, *.r1, *.r2)
% wave      : 波長の構造体(*.g1, *.g2, *.r1, *.r2)
% data      : 観測データ
% prn       : 衛星PRN番号(構造体)
% obs_model : 観測モデル
% est_prm   : 設定パラメータ
% 
% [argout]
% Y         : 観測量ベクトル
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------
% GLONASSの周波数, 波長の変化に対応
% Aug 03, 2009, T.Yanase
%-------------------------------------------------------------------------------

switch obsmodel
case 0,		% CA コード擬似距離(バイアス補正によりP1に相当)
	Y = data(:,2);

case 1,		% PY コード擬似距離
	Y = data(:,6);

case 2,		% ionfree 観測量(2周波擬似距離)
	Y = [data(:,2) data(:,6)]*[f1^2; -f2^2]/(f1^2-f2^2);

case 3,		% CA コード擬似距離(バイアス補正によりP1に相当) & L1 搬送波位相
	Y1=[]; Y_g2=[]; Y_r2=[];
	Y1 = data(:,2);
	if est_prm.n_nav ==1
		Y_g2 = wave.g1*data(1:length(prn.rov.vg),1);
	end
	if est_prm.g_nav ==1
		Y_r2 = wave.r1.*data(length(prn.rov.vg)+1:end,1);
	end
	Y = [Y1; Y_g2; Y_r2];

case 4,		% ionfree 観測量(1周波擬似距離 & 搬送波)
	Y_g=[]; Y_r=[];
	if est_prm.n_nav ==1
		Y_g = 0.5*(data(1:length(prn.rov.vg),2) + wave.g1*data(1:length(prn.rov.vg),1));
	end
	if est_prm.g_nav ==1
		Y_r = 0.5*(data(length(prn.rov.vg)+1:end,2) + wave.r1.*data(length(prn.rov.vg)+1:end,1));
	end
	Y = [Y_g; Y_r];

case 5,		% ionfree 観測量(2周波搬送波)
	Y_g=[]; Y_r=[];
	if est_prm.n_nav ==1
		Y_g = [wave.g1*data(1:length(prn.rov.vg),1) wave.g2*data(1:length(prn.rov.vg),5)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
	end
	if est_prm.g_nav ==1
		Y_r = (wave.r1.*data(length(prn.rov.vg)+1:end,1).*freq.r1.^2 - wave.r2.*data(length(prn.rov.vg)+1:end,5).*freq.r2.^2)./(freq.r1.^2-freq.r2.^2);
	end
	Y = [Y_g; Y_r];

case 6,		% CA,PY コード擬似距離(バイアス補正によりP1に相当) & L1,L2 搬送波位相
	Y1=[]; Y_g2=[]; Y_r2=[]; Y3=[]; Y_g4=[]; Y_r4=[];
	Y1 = data(:,2);
	if est_prm.n_nav ==1
		Y_g2 = wave.g1*data(1:length(prn.rov.vg),1);
		Y_g4 = wave.g2*data(1:length(prn.rov.vg),5);
	end
	Y3 = data(:,6);
	if est_prm.g_nav ==1
		Y_r2 = wave.r1.*data(length(prn.rov.vg)+1:end,1);
		Y_r4 = wave.r2.*data(length(prn.rov.vg)+1:end,5);
	end
	Y = [Y1; Y3; Y_g2; Y_r2; Y_g4; Y_r4];

case 7,		% ionfree 観測量(2周波擬似距離 & 搬送波)
	Y_g1=[];, Y_g2=[];, Y_r1=[];, Y_r2=[];
	if est_prm.n_nav ==1
		Y_g1 = 0.5*(data(1:length(prn.rov.vg),2) + wave.g1*data(1:length(prn.rov.vg),1));
		Y_g2 = 0.5*(data(1:length(prn.rov.vg),6) + wave.g2*data(1:length(prn.rov.vg),5));
	end
	if est_prm.g_nav ==1
		Y_r1 = 0.5*(data(length(prn.rov.vg)+1:end,2) + wave.r1.*data(length(prn.rov.vg)+1:end,1));
		Y_r2 = 0.5*(data(length(prn.rov.vg)+1:end,6) + wave.r2.*data(length(prn.rov.vg)+1:end,5));
	end
	Y = [Y_g1; Y_r1; Y_g2; Y_r2];

case 8,		% ionfree 観測量(2周波擬似距離 & 搬送波)
	Y_g1=[];, Y_g2=[];, Y_r1=[];, Y_r2=[];
	if est_prm.n_nav ==1
		Y_g1 = [data(1:length(prn.rov.vg),2) data(1:length(prn.rov.vg),6)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
		Y_g2 = [wave.g1*data(1:length(prn.rov.vg),1) wave.g2*data(1:length(prn.rov.vg),5)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
	end
	if est_prm.g_nav ==1
		Y_r1 = (data(length(prn.rov.vg)+1:end,2).*freq.r1.^2 - data(length(prn.rov.vg)+1:end,6).*freq.r2.^2)./(freq.r1.^2-freq.r2.^2);
		Y_r2 = (wave.r1.*data(length(prn.rov.vg)+1:end,1).*freq.r1.^2 - wave.r2.*data(length(prn.rov.vg)+1:end,5).*freq.r2.^2)./(freq.r1.^2-freq.r2.^2);
	end
	Y = [Y_g1; Y_r1; Y_g2; Y_r2];

case 9,		% CA コード擬似距離(バイアス補正によりP1に相当) & L1,L2 搬送波位相
	Y_g1=[];, Y_g2=[];, Y_g3=[];, Y_r1=[];, Y_r2=[]; Y_r3=[];
	if est_prm.n_nav ==1
		Y_g1 = data(1:length(prn.rov.vg),2);
		Y_g2 = wave.g1*data(1:length(prn.rov.vg),1);
		Y_g3 = wave.g2*data(1:length(prn.rov.vg),5);
	end
	if est_prm.g_nav ==1
		Y_r1 = data(length(prn.rov.vg)+1:end,2);
		Y_r2 = wave.r1.*data(length(prn.rov.vg)+1:end,1);
		Y_r3 = wave.r2.*data(length(prn.rov.vg)+1:end,5);
	end
	Y = [Y_g1; Y_r1; Y_g2; Y_r2; Y_g3; Y_r3];
case 10,		% CA コード擬似距離(バイアス補正によりP1に相当)
	Y = data(:,2);
end
