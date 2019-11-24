function [zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=chi2test_dd(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,a)
%-------------------------------------------------------------------------------
% Function : χ2検定＋次元調節(相対測位用)
%
% [argin]
% zz      : mx1 イノベーションベクトル: y-h(x^)
% H       : mxn 観測行列: 線形化した際の偏微分係数
% R       : mxm 観測雑音共分散行列
% Kalx_p  : nx1 一段予測値
% KalP_p  : nxn 一段予測値の推定誤差共分散行列
% prn     : 衛星PRN構造体
% ix      : 状態変数のインデックス
% nx      : 状態変数の次元
% est_prm : 初期設定パラメータ
% a       : 有意水準(危険率)
%
% [argout]
% zz      : mx1 イノベーションベクトル: y-h(x^)
% H       : mxn 観測行列: 線形化した際の偏微分係数
% R       : mxm 観測雑音共分散行列
% Kalx_p  : nx1 濾波推定値
% KalP_p  : nxn 濾波推定値の推定誤差共分散行列
% prn     : 衛星PRN構造体
% ix      : 状態変数のインデックス
% nx      : 状態変数の次元
% prn_rej : 除外された衛星PRN
%
% 基準衛星に異常が起きた場合の保証はできません
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 05, 2008
%-------------------------------------------------------------------------------
% 電離層二重差推定時に対応
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

% 事前残差の検定(χ2検定)
%--------------------------------------------
M=H*KalP_p*H'+R;							% イノベーションの共分散
Zs=(zz.^2)./diag(M);						% 正規化したイノベーション
n=1;										% n:自由度, 有意水準(危険率)は引数
sigma=x2a(n,a);								% χ2分布の上側確率点 n:自由度, 有意水準(危険率)

no_dd=length(prn.u)-1; j1=[]; j2=[];
Zs1=Zs(1:no_dd);							% L1帯
j1=find(Zs1>=sigma);						% χ2検定(検出された場合は除外)
if est_prm.freq==2
	Zs2=Zs(no_dd+1:2*no_dd);				% L2帯
	j2=find(Zs2>=sigma);					% χ2検定(検出された場合は除外)
end
j=union(j1,j2);								% L1帯とL2帯の検出したインデックスを結合(2周波のみ)
if size(j,1)~=1, j=j'; end					% インデックスを転置(横に並べるため)
prn_rej=prn.u(j+1);							% 除外衛星PRN


% 事前残差の検定(絶対値検定)
%--------------------------------------------
% sigma=30;
% no_dd=length(prn.u)-1; j1=[]; j2=[];
% zz1=zz(1:no_dd);							% L1帯
% j1=find(abs(zz1)>=sigma);					% 絶対値検定(検出された場合は除外)
% if est_prm.freq==2
% 	zz2=zz(no_dd+1:2*no_dd);				% L2帯
% 	j2=find(zz2>=sigma);					% 絶対値検定(検出された場合は除外)
% end
% j=union(j1,j2);								% L1帯とL2帯の検出したインデックスを結合(2周波のみ)
% if size(j,1)~=1, j=j'; end					% インデックスを転置(横に並べるため)
% prn_rej=prn.u(j+1);							% 除外衛星PRN


if ~isempty(j)
	%--- 除外するためのインデックス生成
	%--------------------------------------------
	if est_prm.freq==1												% 1周波
		switch est_prm.statemodel.ion	% yanase
		case 0, indexxp=[ix.n(j)];									% X,P用のインデックス
		case 1, indexxp=[ix.i(j),ix.n(j)];							% X,P用のインデックス
		case 2, indexxp=[ix.i(j+1),ix.n(j)];						% X,P用のインデックス
		case 3, indexxp=[ix.i(j+1),ix.n(j)];						% X,P用のインデックス
		case 4, indexxp=[ix.i(j+1),ix.n(j)];						% X,P用のインデックス
		case 5, indexxp=[ix.n(j)];									% X,P用のインデックス
		case 6, indexxp=[ix.n(j)];									% X,P用のインデックス
		case 7, indexxp=[ix.n(j)];									% X,P用のインデックス
		end

		if est_prm.pr_flag==1
			indexz=[j,no_dd+j];										% 観測関連用のインデックス(PRあり)
		else
			indexz=[j];												% 観測関連用のインデックス(PRなし)
		end
	else															% 2周波
		switch est_prm.statemodel.ion	% yanase
		case 0, indexxp=[ix.n([j,no_dd+j])];						% X,P用のインデックス
		case 1, indexxp=[ix.i(j),ix.n([j,no_dd+j])];				% X,P用のインデックス
		case 2, indexxp=[ix.i(j+1),ix.n([j,no_dd+j])];				% X,P用のインデックス
		case 3, indexxp=[ix.i(j+1),ix.n([j,no_dd+j])];				% X,P用のインデックス
		case 4, indexxp=[ix.i(j+1),ix.n([j,no_dd+j])];				% X,P用のインデックス
		case 5, indexxp=[ix.n([j,no_dd+j])];						% X,P用のインデックス
		case 6, indexxp=[ix.n([j,no_dd+j])];						% X,P用のインデックス
		case 7, indexxp=[ix.n([j,no_dd+j])];						% X,P用のインデックス
		end

		if est_prm.pr_flag==1
			indexz=[j,no_dd+j,2*no_dd+j,3*no_dd+j];					% 観測関連用のインデックス(PRあり)
		else
			indexz=[j,no_dd+j];										% 観測関連用のインデックス(PRなし)
		end
	end

	%--- 検出した衛星部分を除外
	%--------------------------------------------
	Kalx_p(indexxp)=[]; KalP_p(indexxp,:)=[]; KalP_p(:,indexxp)=[];
	zz(indexz)=[]; H(indexz,:)=[]; H(:,indexxp)=[];
	R(indexz,:)=[]; R(:,indexz)=[];
	irej1=[]; irej2=[];
	for k=prn_rej
		irej1=[irej1 find(prn.float==k)];							% prn.float用
		irej2=[irej2 find(prn.fix==k)];								% prn.fix用
	end
	prn.float(irej1)=[];											% 除外
	prn.fix(irej2)=[];												% 除外
	prn.u(j+1)=[];													% 除外

	%--- 除外後の次元の設定(使用衛星)
	%--------------------------------------------
	ns=length(prn.u); 
	switch est_prm.statemodel.ion	% yanase
	case 0, ix.i=[]; nx.i=0; nx.x=nx.u+nx.T+nx.i;
	case 1, ix.i=nx.u+nx.T+(1:ns-1); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 2, ix.i=nx.u+nx.T+(1:ns); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 3, ix.i=nx.u+nx.T+(1:ns); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 4, ix.i=nx.u+nx.T+(1:ns+4); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 5, ix.i=nx.u+nx.T+(1:2); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 6, ix.i=nx.u+nx.T+(1:4); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 7, ix.i=nx.u+nx.T+(1:6); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	end
	ix.n=nx.x+(1:est_prm.freq*(ns-1)); nx.n=length(ix.n); nx.x=nx.x+nx.n;
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

% x2a(n) : chi-squre distribution critical value -------------------------------
function x=x2a(n,a)

% set range of search
r=[0,10]; while a<x2q(n,r(2)), r(2)=r(2)*2; end

% binary search
while 1
    x=(r(1)+r(2))/2; p=x2q(n,x);
    if abs(p-a)<a*1E-5, break, elseif p<a, r(2)=x; else r(1)=x; end
end

% chi-square function ----------------------------------------------------------
function p=x2q(n,x), p=1-gammainc(x/2,n/2);
