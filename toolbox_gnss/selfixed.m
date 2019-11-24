function [prn,Ndd1,Ndd2,N_ref,Fixed_N]=selfixed(prn,Ndd1,Ndd2,Fixed_N,est_prm)
%-------------------------------------------------------------------------------
% Function : 固定可能・不可能な衛星PRNを決定
% 
% [argin]
% prn       : 衛星PRN構造体(prn.u, prn.o)
% Ndd1      : 整数値バイアス(更新前)
% Ndd2      : 整数値バイアス(更新前)
% Fixed_N   : 整数値バイアスとカウントの配列
% est_prm   : パラメータ設定値
% 
% [argout]
% prn       : 衛星PRN構造体(prn.u, prn.o, prn.float, prn.fix)
% Ndd1      : 整数値バイアス(更新済み)
% Ndd2      : 整数値バイアス(更新済み)
% Fixed_N   : 整数値バイアスとカウントの配列
% N_ref     : 基準切換え処理用
% 
% 基準が切り替わった場合, 変換処理すべきかリセットすべきかは検討中
% ただし, 現状としてはリセットした方が無難
% 
% 拘束条件として利用する方法を追加
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

%--- Fix解として利用できるもの(変換済み)
%--------------------------------------------
if ~isempty(prn.o)
	%--- 基準切換え処理
	%--------------------------------------------
	iref=find(prn.o==prn.u(1));														% 基準衛星のインデックス(prn.o内)
	N_ref(1)=Fixed_N{1}(prn.u(1),1);												% 基準切換え処理の準備
	if est_prm.freq==2
		N_ref(2)=Fixed_N{2}(prn.u(1),1);											% 基準切換え処理の準備
	end
	if iref~=1																		% 基準衛星が変化した場合(今はリセット)
		if est_prm.freq==1
% 			if ~isnan(N_ref(1))
% 				Fixed_N{1}(:,1)=Fixed_N{1}(:,1)-N_ref(1);
% 				Fixed_N{1}(prn.o(1),1)=-N_ref(1);									% 基準切換え処理
% 				Fixed_N{1}(:,2)=0; Fixed_N{1}(prn.u(2:end),2)=est_prm.ambc;			% カウント更新
% 			else
% 				Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;								% 整数値バイアスとカウントのリセット
% 			end
			Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;									% 整数値バイアスとカウントのリセット
		elseif est_prm.freq==2
% 			if ~isnan(N_ref(1)) & ~isnan(N_ref(2))
% 				Fixed_N{1}(:,1)=Fixed_N{1}(:,1)-N_ref(1);
% 				Fixed_N{1}(prn.o(1),1)=-N_ref(1);									% 基準切換え処理
% 				Fixed_N{1}(:,2)=0; Fixed_N{1}(prn.u(2:end),2)=est_prm.ambc;			% カウント更新
% 				Fixed_N{2}(:,1)=Fixed_N{2}(:,1)-N_ref(2);
% 				Fixed_N{2}(prn.o(1),1)=-N_ref(2);									% 基準切換え処理
% 				Fixed_N{2}(:,2)=0; Fixed_N{2}(prn.u(2:end),2)=est_prm.ambc;			% カウント更新
% 			else
% 				Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;								% 整数値バイアスとカウントのリセット
% 				Fixed_N{2}(:,1)=NaN; Fixed_N{2}(:,2)=0;								% 整数値バイアスとカウントのリセット
% 			end
			Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;									% 整数値バイアスとカウントのリセット
			Fixed_N{2}(:,1)=NaN; Fixed_N{2}(:,2)=0;									% 整数値バイアスとカウントのリセット
		end
	end

	%--- 固定可能・不可能の衛星PRN
	%--------------------------------------------
	switch est_prm.ambf
	case {0,2}
		prn.fix=[]; prn.float=prn.u; N_ref(1:2)=NaN;								% 固定を行わない場合
	case 1,
		prn.fix=prn.u(1); prn.float=prn.u(1); j=0;
		for i=prn.u(2:end)
			j=j+1;																	% インデックスをインクリメント
			if est_prm.freq==1
				if Fixed_N{1}(i,2)>=est_prm.ambc									% カウントが指定回数以上かどうかの判定
					prn.fix=[prn.fix i];											% 固定可能な衛星PRN(定数として取扱うもの)
					Ndd1(j)=Fixed_N{1}(i,1);										% 固定可能なFixNで置き換え
				else
					prn.float=[prn.float i];										% 固定不可能な衛星PRN(状態変数として取扱うもの)
				end
			elseif est_prm.freq==2
				if Fixed_N{1}(i,2)>=est_prm.ambc & Fixed_N{2}(i,2)>=est_prm.ambc	% カウントが指定回数以上かどうかの判定
					prn.fix=[prn.fix i];											% 固定可能な衛星PRN(定数として取扱うもの)
					Ndd1(j)=Fixed_N{1}(i,1); Ndd2(j)=Fixed_N{2}(i,1);				% 固定可能なFixNで置き換え
				else
					prn.float=[prn.float i];										% 固定不可能な衛星PRN(状態変数として取扱うもの)
				end
			end
		end
	end
else
	prn.fix=[]; prn.float=prn.u; N_ref(1:2)=NaN;									% 固定を行わない場合
end
