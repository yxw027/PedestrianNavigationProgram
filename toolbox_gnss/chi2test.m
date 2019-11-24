function [zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=chi2test(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,a)
%-------------------------------------------------------------------------------
% Function : χ2検定＋次元調節
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
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 05, 2008
%-------------------------------------------------------------------------------
% 単独測位に対応
% January 25, 2010, T.Yanase
%-------------------------------------------------------------------------------

% 事前残差の検定(χ2検定)
%--------------------------------------------
M=H*KalP_p*H'+R;							% イノベーションの共分散
Zs=(zz.^2)./diag(M);						% 正規化したイノベーション
n=1;										% n:自由度, 有意水準(危険率)は引数
sigma=x2a(n,a);								% χ2分布の上側確率点 n:自由度, 有意水準(危険率)

j1=[]; j2=[];
Zs1=Zs(1:length(prn.u));					% L1帯
j1=find(Zs1>=sigma);						% χ2検定(検出された場合は除外)
if est_prm.freq==2
	Zs2=Zs(length(prn.u)+1:2*length(prn.u));% L2帯
	j2=find(Zs2>=sigma);					% χ2検定(検出された場合は除外)
end
j=union(j1,j2);								% L1帯とL2帯の検出したインデックスを結合(2周波のみ)
if size(j,1)~=1, j=j'; end					% インデックスを転置(横に並べるため)
prn_rej=prn.u(j);							% 除外衛星PRN


if ~isempty(j)
	%--- 除外するためのインデックス生成
	%--------------------------------------------
	if est_prm.freq==1												% 1周波
		indexxp=[ix.n(j)]
		indexz=[j];
	else															% 2周波
		indexxp=[ix.n([j,length(prn.u)+j])];						% X,P用のインデックス
		indexz=[j,length(prn.u)+j];
	end

	%--- 検出した衛星部分を除外
	%--------------------------------------------
	Kalx_p(indexxp)=[]; KalP_p(indexxp,:)=[]; KalP_p(:,indexxp)=[];
	zz(indexz)=[]; H(indexz,:)=[]; H(:,indexxp)=[];
	R(indexz,:)=[]; R(:,indexz)=[];
	irej1=[]; irej2=[];
	prn.u(j)=[];													% 除外

	%--- 除外後の次元の設定(使用衛星)
	%--------------------------------------------
	ns=length(prn.u); 
	switch est_prm.statemodel.ion
	case 0, ix.i=[]; nx.i=0; nx.x=nx.u+nx.T+nx.i;
	case 1, ix.i=nx.u+nx.T+1; nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 2, ix.i=nx.u+nx.T+(1:2); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 3, ix.i=nx.u+nx.T+(1:3); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
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
