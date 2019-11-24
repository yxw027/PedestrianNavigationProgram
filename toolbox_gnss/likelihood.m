function [valid,ratio,Fix_N]=likelihood(nx,ele1,ele2,prn,est_prm,Kalx_pp,Kalx_ff,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,Fix_N,H_c,ratio_l)
%-------------------------------------------------------------------------------
% Function : likelihood ratio test
% 
% [argin]
% nx        : 状態変数の次元
% ele1      : 仰角(Rover)
% ele2      : 仰角(Reference)
% prn       : 衛星PRN構造体(prn.u, prn.float, prn.fix)
% est_prm   : パラメータ設定値
% Kalx_pp   : 一段予測値(選別後)
% Kalx_ff   : 濾波推定値(選別後)
% FloatN_ar : フロート解(整数値バイアス, 選別後)
% Pf_xn_ar  : 推定誤差共分散行列(X*N部分, 選別後)
% Pf_nn_ar  : 推定誤差共分散行列(N*N部分, 選別後)
% Pf_xx_ar  : 推定誤差共分散行列(X*X部分, 選別後)
% Fix_N     : フィックス解(整数値バイアス)
% H_c       : 観測行列(選別後)
% 
% [argout]
% valid     : 検定結果(0 or 1)
% ratio     : 尤度比
% Fix_N     : フィックス解(整数値バイアス)
% 
% 入力引数 ratio_l で尤度比を更新
% 
% 要検討
% ・分散, 閾値の決め方
% ・時間による衛星の増減への対応
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% T.Yanase: Jan. 25, 2010
%-------------------------------------------------------------------------------


C_ar=[]; U_ar=[];
for t=1:length(prn.ar)
	A=prn.ar(1,t);
	C=findstr(prn.c,A);		% AR使用する衛星PRNに一致する共通衛星PRN
	U=findstr(prn.u,A);		% AR使用する衛星PRNに一致する使用衛星PRN
	C_ar=[C_ar, C];
	U_ar=[U_ar, U];
end
U_ar=U_ar-1;				% 基準衛星を除くAR使用する衛星PRN

H1=H_c(U_ar(2:end),:);
H1=[H1; H_c((length(prn.float)-1)+U_ar(2:end),:)];
if est_prm.freq==2
	H1=[H1; H_c(2*(length(prn.float)-1)+U_ar(2:end),:)];
	H1=[H1; H_c(3*(length(prn.float)-1)+U_ar(2:end),:)];
end

PR1a=(est_prm.obsnoise.PR1./sin(ele1(C_ar,1)).^2);							% コードの分散(重み考慮)
PR2a=(est_prm.obsnoise.PR2./sin(ele1(C_ar,1)).^2);							% コードの分散(重み考慮)
PR1b=(est_prm.obsnoise.PR1./sin(ele2(C_ar,1)).^2);							% コードの分散(重み考慮)
PR2b=(est_prm.obsnoise.PR2./sin(ele2(C_ar,1)).^2);							% コードの分散(重み考慮)
Ph1a=(est_prm.obsnoise.Ph1./sin(ele1(C_ar,1)).^2);							% 搬送波の分散(重み考慮)
Ph2a=(est_prm.obsnoise.Ph2./sin(ele1(C_ar,1)).^2);							% 搬送波の分散(重み考慮)
Ph1b=(est_prm.obsnoise.Ph1./sin(ele2(C_ar,1)).^2);							% 搬送波の分散(重み考慮)
Ph2b=(est_prm.obsnoise.Ph2./sin(ele2(C_ar,1)).^2);							% 搬送波の分散(重み考慮)

PR1 = diag(PR1a+PR1b); PR2 = diag(PR2a+PR2b);									% コードの分散(1重差)
Ph1 = diag(Ph1a+Ph1b); Ph2 = diag(Ph2a+Ph2b);									% 搬送波の分散(1重差)

TD=[-ones((length(prn.ar)-1),1) eye((length(prn.ar)-1))];						% 変換行列

if est_prm.freq==1
	R=TD*Ph1*TD';																% DD obs noise(L1)
	if est_prm.pr_flag==1
		R=blkdiag(R,TD*PR1*TD');												% DD obs noise(L1,CA)
	end
else
	R=blkdiag(TD*Ph1*TD',TD*Ph2*TD');											% DD obs noise(L1,L2)
	if est_prm.pr_flag==1
		R=blkdiag(R,TD*PR1*TD',TD*PR2*TD');										% DD obs noise(L1,L2,CA,PY)
	end
end

Fix_N1=Fix_N(:,1);																%first
mu_f=H1*(Kalx_ff-Kalx_pp+P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N1));			%firstの残差
% heikin_f=H1*P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N1);						%firstの残差の平均
heikin_f=0;																		%firstの残差の平均
bunsan_f=H1*P_f_xx_ar*H1'+R;													%firstの残差の分散

Fix_N2=Fix_N(:,2);																%second   
mu_s=H1*(Kalx_ff-Kalx_pp+P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N2));			%secondの残差
% heikin_s=H1*P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N2);						%secondの残差の平均
heikin_s=0;																		%secondの残差の平均
bunsan_s=H1*P_f_xx_ar*H1'+R;													%secondの残差の分散

yuudohi=exp((-1/2)*(mu_s-heikin_s)'*inv(bunsan_s)*(mu_s-heikin_s)+(1/2)*(mu_f-heikin_f)'*inv(bunsan_f)*(mu_f-heikin_f));
yuudohi=log(yuudohi);

ratio=[ratio_l+yuudohi];					% 対数尤度

alpha=0.01;			% 第一種の過誤
beta=0.01;			% 第二種の過誤
eta_0=log(beta/(1-alpha));
eta_1=log((1-beta)/alpha);

if ~isnan(ratio)
	if ratio <= eta_0
		valid=1;
		Fix_N=Fix_N(:,1);
	elseif ratio >= eta_1
		valid=1;
		Fix_N=Fix_N(:,2);
	else
		valid=0;
	end
end

