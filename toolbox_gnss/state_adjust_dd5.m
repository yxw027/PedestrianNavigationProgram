function [x,P]=state_adjust_dd(prn,x_p,P_p,nx,est_prm,X1,X2,X3,N_ref)
%-------------------------------------------------------------------------------
% Function : 一段予測の次元調整(DD用) --- 増えた衛星の初期値は逆算で算出したもの
% 
% [argin]
% prn         : 衛星PRN番号(prn.u, prn.o, prn.float_o)
% x_p         : 一段予測値
% P_p         : 一段予測値の共分散
% nx          : 状態変数の次元(構造体)---前エポック
% est_prm     : 初期設定パラメータ(構造体)
% X1          : 初期値(整数値バイアス, 電離層など)
% X2          : 初期値(整数値バイアス, 電離層など)
% X3          : 初期値(整数値バイアス, 電離層など)
% N_ref       : 基準切換処理用(固定時)
% 
% [argout]
% x     : 一段予測値(次元調整後)
% P     : 一段予測値の共分散(次元調整後)
% 
% 
% 周波数に関係なく, 次元調整が必要な状態変数の個数に応じて次元調整できるように変更
% 電離層の推定をする場合, 観測行列と対応する順番でX1-X3(できる限りX1)の所に入れること
% 
% 基準切換え処理も関数内で行うように変更
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% 電離層二重差推定時に対応
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

%--------------------------------------------
% 最初に状態変数, 分散に大きな配列を準備する.
% その配列を予測値で置換して次元調節された
% 状態変数, 分散を作成する.
% 注: 配列はPRNを列番号として扱う
%--------------------------------------------
nn=3;
if isempty(X1), nn=nn-1;, end												% 空であれば "-1" する
if isempty(X2), nn=nn-1;, end												% 空であれば "-1" する
if isempty(X3), nn=nn-1;, end												% 空であれば "-1" する

%--- 状態変数と共分散(基準切換え処理)
%--------------------------------------------
init_flag=0;																% 初期化フラグ(OFF)
if isfield(prn,'float_o')
	N_o{1}(1:32,1)=NaN;														% 衛星PRNをインデックスとして扱うための準備
	N_o{1}(prn.float_o(2:end),1)=...
			x_p(nx.u+nx.T+nx.i+1:nx.u+nx.T+nx.i+nx.n/est_prm.freq);			% フロート解を格納
	N_refo(1)=N_o{1}(prn.u(1),1);											% 基準切換え処理の準備
	if est_prm.freq==2
		N_o{2}(1:32,1)=NaN;													% 衛星PRNをインデックスとして扱うための準備
		N_o{2}(prn.float_o(2:end),1)=...
				x_p(nx.u+nx.T+nx.i+nx.n/est_prm.freq+1:end);				% フロート解を格納
		N_refo(2)=N_o{2}(prn.u(1),1);										% 基準切換え処理の準備
	end
	iref=find(prn.float_o==prn.u(1));										% 基準衛星のインデックス(prn.float_o内)
	DD=eye(length(prn.float_o)-1); DD2=eye(nx.u+nx.T+nx.i);					% 単位行列
	if iref~=1																% 基準衛星が変化した場合(固定してない衛星に)
		N_o{1}(:,1)=N_o{1}(:,1)-N_refo(1);									% 基準切換え処理
		N_o{1}(prn.float_o(1),1)=-N_refo(1);								% 基準切換え処理
		if est_prm.freq==2
			N_o{2}(:,1)=N_o{2}(:,1)-N_refo(2);								% 基準切換え処理
			N_o{2}(prn.float_o(1),1)=-N_refo(2);							% 基準切換え処理
		end
		DD(:,iref-1)=-1;													% 変換行列(整数値バイアスの部分)
	elseif isempty(iref)													% 基準衛星が変化した場合(固定した衛星に)
		if ~isnan(N_ref(1))
			N_o{1}(:,1)=N_o{1}(:,1)-N_ref(1);								% 基準切換え処理(N_ref1を利用) N_ref1:定数
			N_o{1}(prn.float_o(1),1)=-N_ref(1);								% 基準切換え処理(N_ref1を利用) N_ref1:定数
			if est_prm.freq==2
				N_o{2}(:,1)=N_o{2}(:,1)-N_ref(2);							% 基準切換え処理(N_ref2を利用) N_ref2:定数
				N_o{2}(prn.float_o(1),1)=-N_ref(2);							% 基準切換え処理(N_ref2を利用) N_ref2:定数
			end
		else
			init_flag=1;													% 初期化フラグ(ON)
		end
	end
	if est_prm.freq==1
		x_p(nx.u+nx.T+nx.i+1:end)=[N_o{1}(prn.float_o(2:end))];				% 状態変数(変換後, 1周波)
	elseif est_prm.freq==2
		x_p(nx.u+nx.T+nx.i+1:end)=...
				[N_o{1}(prn.float_o(2:end)); N_o{2}(prn.float_o(2:end))];	% 状態変数(変換後, 2周波)
	end
	if nx.n/est_prm.freq~=0 & est_prm.freq==1
		DD2=blkdiag(DD2,DD);												% 変換行列(1周波)
	end
	if nx.n/est_prm.freq~=0 & est_prm.freq==2
		DD2=blkdiag(DD2,DD,DD);												% 変換行列(2周波)
	end
	P_p=DD2*P_p*DD2';														% 共分散(変換後)
else
	prn.float_o=prn.o;
end

%--- 状態変数と共分散(次元調整処理)
%--------------------------------------------
switch est_prm.statemodel.ion	% yanase
case {0,1,2,3,4}															% 電離層の状態変数が衛星数により変動する場合
	index_o=[];																% 前エポックのインデックス用
	index_n=[];																% 今エポックのインデックス用
	for k=1:nn
		if k==1 & ~isempty(X1)
			switch est_prm.statemodel.ion	% yanase
			case 1,
				index_o=[index_o nx.u+nx.T+prn.o(2:end)+32*(k-1)];			% インデックス(prn.o利用)
				index_n=[index_n nx.u+nx.T+prn.u(2:end)+32*(k-1)];			% インデックス(prn)
			case {2,3},
				index_o=[index_o nx.u+nx.T+prn.o+32*(k-1)];					% インデックス(prn.o利用)
				index_n=[index_n nx.u+nx.T+prn.u+32*(k-1)];					% インデックス(prn)
			case 4,
				index_o=[index_o nx.u+nx.T+prn.o+32*(k-1)];					% インデックス(prn.o利用)
				index_n=[index_n nx.u+nx.T+prn.u+32*(k-1)];					% インデックス(prn)
				X1=X1(1:end-4);
			end
		else
			if length(prn.float_o)>1
				index_o=[index_o nx.u+nx.T+prn.float_o(2:end)+32*(k-1)];	% インデックス(prn.float_o利用)
			end
			index_n=[index_n nx.u+nx.T+prn.u(2:end)+32*(k-1)];				% インデックス(prn.u利用)
		end
	end
	x=zeros(nx.u+nx.T+32*nn,1);												% 状態の準備(prnを列番号として利用するため全衛星分を確保)
	% P=eye(nx.u+nx.T+32*nn)*10;											% 分散の準備(prnを列番号として利用するため全衛星分を確保)
	P=eye(nx.u+nx.T);
	for i=1:nn
		if ~isempty(X1) & i==1
			P=blkdiag(P,eye(32)*0.1);										% 分散の準備(prnを列番号として利用するため全衛星分を確保)
		else
			P=blkdiag(P,eye(32)*10);										% 分散の準備(prnを列番号として利用するため全衛星分を確保)
		end
	end

	x(index_n)=[X1;X2;X3];													% 電離層, 整数値バイアスの部分を置換

	if est_prm.statemodel.ion==4	% yanase
		x([1:nx.u+nx.T+4,index_o])=x_p;											% 予測値で置換
		x=x([1:nx.u+nx.T+4,index_n]);												% 可視衛星のみ抽出
		P([1:nx.u+nx.T+4,index_o],[1:nx.u+nx.T+4,index_o])=P_p;						% 予測分散で置換
		P=P([1:nx.u+nx.T+4,index_n],[1:nx.u+nx.T+4,index_n]);						% 可視衛星のみ抽出
	else
		x([1:nx.u+nx.T,index_o])=x_p;											% 予測値で置換
		x=x([1:nx.u+nx.T,index_n]);												% 可視衛星のみ抽出
		P([1:nx.u+nx.T,index_o],[1:nx.u+nx.T,index_o])=P_p;						% 予測分散で置換
		P=P([1:nx.u+nx.T,index_n],[1:nx.u+nx.T,index_n]);						% 可視衛星のみ抽出
	end

case {5,6,7}																% 電離層の状態変数が変動しない場合
	index_o=[];																% 前エポックのインデックス用
	index_n=[];																% 今エポックのインデックス用
	nn=nn-1;																% 電離層の状態変数は固定なのでループ回数を-1する
	for k=1:nn
		if length(prn.float_o)>1
			index_o=[index_o nx.u+nx.T+nx.i+prn.float_o(2:end)+32*(k-1)];	% インデックス(prn.float_o利用)
		end
		index_n=[index_n nx.u+nx.T+nx.i+prn.u(2:end)+32*(k-1)];				% インデックス(prn.u利用)
	end
	x=zeros(nx.u+nx.T+nx.i+32*nn,1);										% 状態の準備(prnを列番号として利用するため全衛星分を確保)
	% P=eye(nx.u+nx.T+nx.i+32*nn)*10;										% 分散の準備(prnを列番号として利用するため全衛星分を確保)
	P=eye(nx.u+nx.T+nx.i);
	for i=1:nn
		P=blkdiag(P,eye(32)*10);											% 分散の準備(prnを列番号として利用するため全衛星分を確保)
	end
	x(index_n)=[X2;X3];														% 整数値バイアスの部分を置換
	x([1:nx.u+nx.T+nx.i,index_o])=x_p;										% 予測値で置換
	x=x([1:nx.u+nx.T+nx.i,index_n]);										% 可視衛星のみ抽出
	P([1:nx.u+nx.T+nx.i,index_o],[1:nx.u+nx.T+nx.i,index_o])=P_p;			% 予測分散で置換
	P=P([1:nx.u+nx.T+nx.i,index_n],[1:nx.u+nx.T+nx.i,index_n]);				% 可視衛星のみ抽出
end

%--- 状態変数と共分散(Fixで置換)
% 
% 固定できる整数値バイアスが一旦, 予測値で
% 上書きされるので, 固定できる部分については
% 再度, 上書きする
%--------------------------------------------
if isfield(prn,'fix')
	if length(prn.fix)>1
		index_f=[];
		for k=prn.fix(2:end)
			j=find(prn.u(2:end)==k);										% 固定できる衛星のインデックス
			index_f=[index_f j];											% インデックスを格納
		end

		switch est_prm.statemodel.ion	% yanase
		case 0, dimi=0;
		case 1, dimi=length(prn.u)-1;
		case 2, dimi=length(prn.u);
		case 3, dimi=length(prn.u);
		case 4, dimi=length(prn.u)+4;
		case 5, dimi=nx.i;
		case 6, dimi=nx.i;
		case 7, dimi=nx.i;
		end

		dimn=length(prn.u)-1;												% 整数値バイアスの数
		x(nx.u+nx.T+dimi+index_f)=X2(index_f);								% 固定できる部分を上書き(N1)
		if est_prm.freq==2
			x(nx.u+nx.T+dimi+dimn+index_f)=X3(index_f);						% 固定できる部分を上書き(N2)
		end
		index_fix=[nx.u+nx.T+dimi+index_f];									% 固定できる部分のインデックス(N1)
		if est_prm.freq==2
			index_fix=[index_fix,nx.u+nx.T+dimi+dimn+index_f];				% 固定できる部分のインデックス(N2)
		end
		P(index_fix,:)=0; P(:,index_fix)=0;									% 固定できる部分を0にする(最終的に除外される部分)
	end
end

%--- 状態変数と共分散(リセット)
%--------------------------------------------
if init_flag==1
	switch est_prm.statemodel.ion	% yanase
	case 0, dimi=0;
	case 1, dimi=length(prn.u)-1;
	case 2, dimi=length(prn.u);
	case 3, dimi=length(prn.u);
	case 4, dimi=length(prn.u)+4;
	case 5, dimi=nx.i;
	case 6, dimi=nx.i;
	case 7, dimi=nx.i;
	end

% 	x=[x_p(1:nx.u+nx.T+dimi); X2; X3];										% 状態変数(リセット)
	x=[x(1:nx.u+nx.T+dimi); X2; X3];										% 次元が変わるものだけリセット
% 	P=blkdiag(P_p(1:nx.u+nx.T+dimi,1:nx.u+nx.T+dimi),...
% 		eye(length(X2)+length(X3))*est_prm.P0.std_dev_n.^2);				% 共分散行列(リセット)
	P=blkdiag(P(1:nx.u+nx.T+dimi,1:nx.u+nx.T+dimi),...
		eye(length(X2)+length(X3))*est_prm.P0.std_dev_n.^2);				% 次元が変わるものだけリセット
	end
end
