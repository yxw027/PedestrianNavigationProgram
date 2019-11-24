function [prn,Fix_X,Fix_N,Fixed_N,s,KalP_f_fix,ratio]=ambfix(prn,ele1,ele2,Kalx_p,Kalx_f,KalP_f,Fixed_N,ix,nx,est_prm,H,ratio_l,x_f_ar)
%-------------------------------------------------------------------------------
% Function : Ambiguity Resolution & Validation
% 
% [argin]
% prn       : 衛星PRN構造体(prn.u, prn.float, prn.fix)
% ele1      : 仰角(Rover)
% ele2      : 仰角(Reference)
% Kalx_p    : 一段予測値
% Kalx_f    : 濾波推定値
% KalP_f    : 推定誤差共分散行列
% Fixed_N   : 整数値バイアスとカウントの配列
% ix        : 状態変数のインデックス
% nx        : 状態変数の次元
% est_prm   : パラメータ設定値
% H         : 観測行列
% ratio_l   : 尤度比
% 
% [argout]
% prn       : 衛星PRN構造体(prn.u, prn.float, prn.fix, prn.ar)
% Fix_X     : フィックス解
% Fix_N     : フィックス解(整数値バイアス)
% Fixed_N   : 整数値バイアスとカウントの配列
% s         : LAMBDAの残差二乗和
% KalP_f_fix: 誤差共分散(Fix済み)
% ratio     : 尤度比(今エポック)
% 
% ARで使用する衛星を選別可能(3種類)---関数:ambscn を利用
% 
% Fix判定
% ・検定OK→Fix
% ・検定NG＋半分未満固定→Fixなし
% ・検定NG＋半分以上固定→FloatをFixとして扱う
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% 尤度比検定対応
% Jan. 29, 2010, T.Yanase
%-------------------------------------------------------------------------------

ratio=0;		% 尤度比初期化

%--- Ambiguity Resolution & Validation
%--------------------------------------------
if ~isnan(Kalx_f(1)) & length(prn.float)>1
	%--- ARで使用する衛星を選別(3種類)
	% 
	% 1. 仰角マスクを利用
	% 2. 使用衛星になってからのエポック数を利用
	% 3. 共分散を利用
	%--------------------------------------------
	[prn.ar,x_p_ar,x_f_ar,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,H_c,index_xx]=...
						ambscn(prn,ele1,Kalx_p,Kalx_f,KalP_f,H,ix,nx,est_prm);

	if length(prn.ar)>1
		%--- Ambiguity Resolution Method
		%--------------------------------------------
		switch est_prm.ambr													% ambiguity resolution
		case 0, Fix_N=round(Float_N_ar); s=[1;100];							% round
		case 1, [Fix_N,s]=lambda2(P_f_nn_ar, Float_N_ar, -1);				% LAMBDA
				Fix_N12=Fix_N;												% \check{n} LAMBDA
				Fix_N=Fix_N(:,1);											% \check{n} LAMBDA
		case 2, [Fix_N,s,Z]=mlambda(Float_N_ar,P_f_nn_ar,2);				% MLAMBDA
				Fix_N=Fix_N(:,1);											% \check{n} MLAMBDA
		end

		%--- Ambiguity Validation Method
		%--------------------------------------------
		switch est_prm.ambv													% ambiguity validation
		case 0, valid=1;													% no validation
		case 1, valid=s(2)/s(1)>=est_prm.ambt;								% ratio test
		case 2, 
			[valid,ratio,Fix_N]=likelihood(nx,ele1,ele2,prn,est_prm,x_p_ar,x_f_ar,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,Fix_N12,H_c,ratio_l);
																			% likelihood ratio test
		case 3, 
			valid=s(2)/s(1)>=est_prm.ambt;									% ratio test
			if valid == 0
				[valid,ratio,Fix_N]=likelihood(nx,ele1,ele2,prn,est_prm,x_p_ar,x_f_ar,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,Fix_N12,H_c,ratio_l);
																			% likelihood ratio test
			end
		end
		if valid
			index_f=[ix.u,ix.T,ix.i];
			Fix_X=Kalx_f(index_f);
			Fix_X(index_xx)=...
					x_f_ar-P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N);		% \check{x}
			KalP_f_fix=KalP_f(index_f,index_f);
			KalP_f_fix(index_xx,index_xx)=...
					P_f_xx_ar-P_f_xn_ar*inv(P_f_nn_ar)*P_f_xn_ar';			% \check{P}
		else
			Fix_N=[];
			Fix_X([ix.u,ix.T,ix.i],1) = NaN;
			KalP_f_fix([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i])=NaN;
		end
	else
		prn.ar=prn.float; Fix_N=[]; s=[NaN;NaN];
		Fix_X([ix.u,ix.T,ix.i],1) = NaN;
		KalP_f_fix([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i])=NaN;
	end
else
	prn.ar=prn.float; Fix_N=[]; s=[NaN;NaN];
	Fix_X([ix.u,ix.T,ix.i],1) = NaN;
	KalP_f_fix([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i])=NaN;
end

%--- Fix解を使用した衛星数が半分以上の場合(Fixの判定)
% ・検定を通過していなくても, 半分以上固定できれば
%   Fix解として扱う
%--------------------------------------------
if est_prm.ambf==1
	if ~isnan(Kalx_f(1))
		if (length(prn.fix)-1)>=(length(prn.u)-1)/2							% 半分以上,固定できた場合
			if isnan(Fix_X(1))
				Fix_X=Kalx_f;												% Float解をFix解とする
				KalP_f_fix=KalP_f;
			end
		end
	end
end

%--- Fix解を格納(カウントも)
%--------------------------------------------
Fixed_Nk{1}=Fixed_N{1};														% 全エポックの値を保持
if est_prm.freq==2
	Fixed_Nk{2}=Fixed_N{2};													% 全エポックの値を保持
end
Fixed_N{1}(1:32,1)=NaN; Fixed_N{1}(1:32,2)=0;
Fixed_N{1}(prn.u(2:end),1)=Fixed_Nk{1}(prn.u(2:end),1);						% 使用衛星のFix解(前エポックまで)
if est_prm.freq==2
	Fixed_N{2}(1:32,1)=NaN; Fixed_N{2}(1:32,2)=0;
	Fixed_N{2}(prn.u(2:end),1)=Fixed_Nk{2}(prn.u(2:end),1);					% 使用衛星のFix解(前エポックまで)
end
if ~isempty(Fix_N)
	Fixed_N{1}(prn.ar(2:end),1)=Fix_N(1:(length(prn.ar)-1),1);				% 今エポックでのFix解を追加
	if est_prm.freq==2
		Fixed_N{2}(prn.ar(2:end),1)=...
				Fix_N(1+(length(prn.ar)-1):2*(length(prn.ar)-1),1);			% 今エポックでのFix解を追加
	end
else
	Fixed_N{1}(prn.float(2:end),1)=NaN;										% 今エポックでのFix解がない場合, NaNを追加
	if est_prm.freq==2
		Fixed_N{2}(prn.float(2:end),1)=NaN;									% 今エポックでのFix解がない場合, NaNを追加
	end
end
for i=2:length(prn.u)														% カウントの更新
	if Fixed_N{1}(prn.u(i),1)==Fixed_Nk{1}(prn.u(i),1)
		Fixed_N{1}(prn.u(i),2)=Fixed_Nk{1}(prn.u(i),2)+1;					% 前エポックと今エポックが同一
	else
		Fixed_N{1}(prn.u(i),2)=1;											% 前エポックと今エポックが異なる
	end
	if est_prm.freq==2
		if Fixed_N{2}(prn.u(i),1)==Fixed_Nk{2}(prn.u(i),1)
			Fixed_N{2}(prn.u(i),2)=Fixed_Nk{2}(prn.u(i),2)+1;				% 前エポックと今エポックが同一
		else
			Fixed_N{2}(prn.u(i),2)=1;										% 前エポックと今エポックが異なる
		end
	end
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function [prn_ar,Xp,Xf,FloatN,Pf_xn,Pf_nn,Pf_xx,H_c,index_xx]=ambscn(prn,ele,x_p,x_f,P_f,H,ix,nx,est_prm)
%-------------------------------------------------------------------------------
% Function : ARで使用する衛星を選別
% 
% [argin]
% prn       : 衛星PRN構造体
% ele       : 仰角
% x_p       : 一段予測値
% x_f       : 濾波推定値
% P_f       : 推定誤差共分散行列
% H         : 観測行列
% ix        : 状態変数のインデックス
% nx        : 状態変数の次元
% est_prm   : パラメータ設定値
% 
% [argout]
% prn_ar    : AR使用する衛星PRN
% Xp        : 一段予測値(選別後)
% Xf        : 濾波推定値(選別後)
% FloatN    : フロート解(整数値バイアス, 選別後)
% Pf_xn     : 推定誤差共分散行列(X*N部分, 選別後)
% Pf_nn     : 推定誤差共分散行列(N*N部分, 選別後)
% Pf_xx     : 推定誤差共分散行列(X*X部分, 選別後)
% H_c         : 観測行列(選別後)
% index_xx  : インデックス(Float解をFix解で上書きするため)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% 電離層二重差推定時に対応
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

%--- ARで使用する衛星を選別(3種類)
% 
% 1. 仰角マスクを利用
% 2. 使用衛星になってからのエポック数を利用
% 3. 共分散を利用
%--------------------------------------------
persistent count_satk count_sat


%--- X, Pを分解(PRNを列・行番号として扱う)
%--------------------------------------------
switch est_prm.statemodel.ion	% yanase
case 0, dimi=0;
case 1, dimi=32;
case 2, dimi=32;
case 3, dimi=32;
case 4, dimi=36;
case 5, dimi=nx.i;
case 6, dimi=nx.i;
case 7, dimi=nx.i;
end

Xp(1:nx.u+nx.T+dimi,1)=0;											% Xp(N以外)を格納する準備
Xf(1:nx.u+nx.T+dimi,1)=0;											% Xf(N以外)を格納する準備
FloatN(1:32*est_prm.freq,1)=0;										% FloatNを格納する準備
Pf_xn(1:nx.u+nx.T+dimi,1:32*est_prm.freq)=0;						% P_xnを格納する準備
Pf_nn(1:32*est_prm.freq,1:32*est_prm.freq)=0;						% P_nnを格納する準備
Pf_xx(1:nx.u+nx.T+dimi,1:nx.u+nx.T+dimi)=0;							% P_xxを格納する準備
H_c(1:length(H(:,1)), 1:nx.u+nx.T+dimi)=0;							% H_cを格納する準備

index_x=[ix.u,ix.T];												% インデックス(pos,trop) PRNを列番号として利用

switch est_prm.statemodel.ion	% yanase
case 1, index_x=[index_x,nx.u+nx.T+prn.u(2:end)];					% インデックス(pos,trop,ion) PRN(基準衛星以外)を列番号として利用
case 2, index_x=[index_x,nx.u+nx.T+prn.u];							% インデックス(pos,trop,ion) PRNを列番号として利用
case 3, index_x=[index_x,nx.u+nx.T+prn.u];							% インデックス(pos,trop,ion) PRNを列番号として利用
case 4, index_x=[index_x,nx.u+nx.T+1:nx.u+nx.T+4,nx.u+nx.T+4+prn.u];										% インデックス(pos,trop,ion)
case 5, index_x=[index_x,ix.i];										% インデックス(pos,trop,ion)
case 6, index_x=[index_x,ix.i];										% インデックス(pos,trop,ion)
case 7, index_x=[index_x,ix.i];										% インデックス(pos,trop,ion)
end

if est_prm.freq==1
	index_n=[prn.float(2:end)];										% インデックス(N1) PRNを列番号として利用
else
	index_n=[prn.float(2:end),32+prn.float(2:end)];					% インデックス(N1,N2) PRNを列番号として利用
end

switch est_prm.statemodel.ion	% yanase
case 0, indk=nx.u+nx.T;												% 整数値バイアス以外の部分
case 1, indk=nx.u+nx.T+length(prn.u)-1;								% 整数値バイアス以外の部分
case 2, indk=nx.u+nx.T+length(prn.u);								% 整数値バイアス以外の部分
case 3, indk=nx.u+nx.T+length(prn.u);								% 整数値バイアス以外の部分
case 4, indk=nx.u+nx.T+4+length(prn.u);								% 整数値バイアス以外の部分
case 5, indk=nx.u+nx.T+nx.i;										% 整数値バイアス以外の部分
case 6, indk=nx.u+nx.T+nx.i;										% 整数値バイアス以外の部分
case 7, indk=nx.u+nx.T+nx.i;										% 整数値バイアス以外の部分
end

Xp(index_x)=x_p(1:indk);											% Xp(N以外)
Xf(index_x)=x_f(1:indk);											% Xf(N以外)
FloatN(index_n)=x_f(indk+1:end);									% FloatN
Pf_xn(index_x,index_n)=P_f(1:indk, indk+1:end);						% P_xn
Pf_nn(index_n,index_n)=P_f(indk+1:end, indk+1:end);					% P_nn
Pf_xx(index_x,index_x)=P_f(1:indk, 1:indk);							% P_xx
H_c(:,index_x)=H(:, 1:indk);										% H_c


switch est_prm.ambs
case 0
	prn_ar=prn.float;
case 1
	%--- ARに使用しない衛星を除外(仰角<25[deg])
	%--------------------------------------------
	ele_ar=ele*180/pi;												% 衛星の仰角
	prn_ele=prn.c(find(ele_ar>est_prm.ambse)); prn_ar=[];			% 仰角マスク以上の衛星PRN
	if ~isempty(prn_ele)
		for i=1:length(prn.float)
			k=find(prn_ele==prn.float(i));							% prn_ele内でのprn.floatのインデックス
			if ~isempty(k)
				prn_ar=[prn_ar prn_ele(k)];							% ARで使用する衛星PRNを格納
			end
		end
	else
		prn_ar=prn.float;
	end

case 2
	%--- 使用衛星になって一定のエポックは使用しない
	%--------------------------------------------
	if isempty(count_satk)
		count_satk(1:32)=0;											% 初期化
	else
		count_satk=count_sat;										% 全エポックまでの値を保持
	end
	count_sat(1:32)=0;												% 初期化
	count_sat(prn.u(2:end))=count_satk(prn.u(2:end))+1;				% 使用衛星になってからのエポック数

	prn_arn=[];
	for i=prn.float(2:end)
		if count_sat(i)>=est_prm.ambsc								% エポック数が 20 以上の場合
			prn_arn=[prn_arn i];									% ARで使用する衛星PRNを格納(基準衛星以外)
		end
	end
	prn_ar=[prn.u(1) prn_arn];										% ARで使用する衛星PRNを格納
	if isempty(prn_arn)
		prn_ar=prn.float;
	end

case 3
	%--- 共分散の大きい衛星は使用しない
	%--------------------------------------------
	Pf_nn1=diag(Pf_nn(1:32,1:32));									% 共分散行列の対角成分(N1)
	if est_prm.freq==2
		Pf_nn2=diag(Pf_nn(1+32:end,1+32:end));						% 共分散行列の対角成分(N2)
	end
	prn_arn=[];
	for i=prn.float(2:end)
		if est_prm.freq==1
			if Pf_nn1(i)<est_prm.ambsp								% 共分散が 0.1 未満の場合
				prn_arn=[prn_arn i];								% ARで使用する衛星PRNを格納(基準衛星以外)
			end
		else
			if Pf_nn1(i)<est_prm.ambsp & Pf_nn2(i)<est_prm.ambsp	% 共分散が 0.1 未満の場合
				prn_arn=[prn_arn i];								% ARで使用する衛星PRNを格納(基準衛星以外)
			end
		end
	end
	prn_ar=[prn.u(1) prn_arn];										% ARで使用する衛星PRNを格納
	if isempty(prn_arn)
		prn_ar=prn.float;
	end
end


%--- 分解したX, Pから使用するPRNで抽出
%--------------------------------------------
index_x=[ix.u,ix.T];												% インデックス(pos,trop) PRNを列番号として利用

switch est_prm.statemodel.ion	% yanase
case 1, index_x=[index_x,nx.u+nx.T+prn_ar(2:end)];					% インデックス(pos,trop,ion) PRNを列番号として利用
case 2, index_x=[index_x,nx.u+nx.T+prn_ar];							% インデックス(pos,trop,ion) PRNを列番号として利用
case 3, index_x=[index_x,nx.u+nx.T+prn_ar];							% インデックス(pos,trop,ion) PRNを列番号として利用
case 4, index_x=[index_x,nx.u+nx.T+1:nx.u+nx.T+4,nx.u+nx.T+4+prn_ar];	% インデックス(pos,trop,ion) PRNを列番号として利用
case 5, index_x=[index_x,ix.i];										% インデックス(pos,trop,ion) 
case 6, index_x=[index_x,ix.i];										% インデックス(pos,trop,ion) 
case 7, index_x=[index_x,ix.i];										% インデックス(pos,trop,ion) 
end

if est_prm.freq==1
	index_n=[prn_ar(2:end)];										% インデックス(N1) PRNを列番号として利用
else
	index_n=[prn_ar(2:end),32+prn_ar(2:end)];						% インデックス(N1,N2) PRNを列番号として利用
end
Xp=Xp(index_x);														% Xp(N以外)(選別後)
Xf=Xf(index_x);														% Xf(N以外)(選別後)
FloatN=FloatN(index_n);												% FloatN(選別後)
Pf_xn=Pf_xn(index_x,index_n);										% P_xn(選別後)
Pf_nn=Pf_nn(index_n,index_n);										% P_nn(選別後)
Pf_xx=Pf_xx(index_x,index_x);										% P_xx(選別後)
H_c=H_c(:, index_x);												% H_c(選別後)

index_xxx=[];
for i=1:length(prn_ar)
	index_xxx=[index_xxx find(prn.u==prn_ar(i))];					% prn.u内でのprn_arのインデックス
end

index_xx=[ix.u,ix.T];												% インデックス(pos,trop, Float解をFix解で上書きするため)

switch est_prm.statemodel.ion	% yanase
case 1, index_xx=[index_xx,nx.u+nx.T+index_xxx(2:end)];				% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
case 2, index_xx=[index_xx,nx.u+nx.T+index_xxx];					% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
case 3, index_xx=[index_xx,nx.u+nx.T+index_xxx];					% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
case 4, index_xx=[index_xx,nx.u+nx.T+1:nx.u+nx.T+4,nx.u+nx.T+4+index_xxx];					% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
case 5, index_xx=[index_xx,ix.i];									% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
case 6, index_xx=[index_xx,ix.i];									% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
case 7, index_xx=[index_xx,ix.i];									% インデックス(pos,trop,ion, Float解をFix解で上書きするため)
end



