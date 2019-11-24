function [lim] = lc_lim(est_prm,timetag,LC,REJ)
%-------------------------------------------------------------------------------
% Function : 線形結合によるサイクルスリップ検出閾値の計算
% 
% [argin]
% est_prm : 設定パラメータ
% timetag : タイムタグ
% LC      : 線形結合格納配列
% REJ     : スリップ検出衛星格納配列
%
% [argout]
% lim     : 閾値
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Oct. 25, 2008
%-------------------------------------------------------------------------------
% 構造体で処理, 入力引数の削減
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------

mag1=0;				% 平均倍率(LG以外は0にする)
lc_int=[1:est_prm.cycle_slip.lc_int];

diff_lc.mp1 = diff(LC.mp1(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
diff_lc.mp2 = diff(LC.mp2(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
diff_lc.mw = diff(LC.mw(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
diff_lc.lgl = diff(LC.lgl(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.lgp = diff(LC.lgp(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.lg1 = diff(LC.lg1(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.lg2 = diff(LC.lg2(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.ionp = diff(LC.ionp(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.ionl = diff(LC.ionl(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));

for j=1:61
	rej_epo.mp1 = find(REJ.mp1(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
	rej_epo.mp2 = find(REJ.mp2(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
	rej_epo.mw = find(REJ.mw(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
	rej_epo.lgl = find(REJ.lgl(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
% 	rej_epo.lgp = find(REJ.lgp(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
% 	rej_epo.lg1 = find(REJ.lg1(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
% 	rej_epo.lg2 = find(REJ.lg2(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% 除外衛星リストから衛星jの行列番号を抽出
% 	rej_epo.ionp = find(REJ.ionp(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);			% 除外衛星リストから衛星jの行列番号を抽出
% 	rej_epo.ionl = find(REJ.ionl(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);			% 除外衛星リストから衛星jの行列番号を抽出
	nan_epo.mp1 = find(isnan(diff_lc.mp1(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
	nan_epo.mp2 = find(isnan(diff_lc.mp2(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
	nan_epo.mw = find(isnan(diff_lc.mw(:,j)));														% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
	nan_epo.lgl = find(isnan(diff_lc.lgl(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
% 	nan_epo.lgp = find(isnan(diff_lc.lgp(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
% 	nan_epo.lg1 = find(isnan(diff_lc.lg1(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
% 	nan_epo.lg2 = find(isnan(diff_lc.lg2(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
% 	nan_epo.ionp = find(isnan(diff_lc.ionp(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
% 	nan_epo.ionl = find(isnan(diff_lc.ionl(:,j)));													% 線形結合がNaNの行列番号を抽出 (エポック抜け落ち対策)
	rej.mp1 = union(rej_epo.mp1,nan_epo.mp1);
	rej.mp2 = union(rej_epo.mp2,nan_epo.mp2);
	rej.mw = union(rej_epo.mw,nan_epo.mw);
	rej.lgl = union(rej_epo.lgl,nan_epo.lgl);
% 	rej.lgp = union(rej_epo.lgp,nan_epo.lgp);
% 	rej.lg1 = union(rej_epo.lg1,nan_epo.lg1);
% 	rej.lg2 = union(rej_epo,nan_epo);
% 	rej.ionp = union(rej_epo,nan_epo);
% 	rej.ionl = union(rej_epo,nan_epo);

	if length(rej.mp1)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
		a.mp1 = setdiff(lc_int,rej.mp1);																	% lc_intの要素の中から不使用の要素を除外
		lim_a.mp1 = std(diff_lc.mp1(a.mp1,j),1);															% 標準偏差(関数)
		lim.mp1(1,j) = abs(mean(diff_lc.mp1(a.mp1,j)))*mag1 + lim_a.mp1*est_prm.cycle_slip.sd;				% 平均*倍率+分散*倍率
	else
		lim.mp1(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
	end
	if length(rej.mp2)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
		a.mp2 = setdiff(lc_int,rej.mp2);																	% lc_intの要素の中から不使用の要素を除外
		lim_a.mp2 = std(diff_lc.mp2(a.mp2,j),1);															% 標準偏差(関数)
		lim.mp2(1,j) = abs(mean(diff_lc.mp2(a.mp2,j)))*mag1 + lim_a.mp2*est_prm.cycle_slip.sd;				% 平均*倍率+分散*倍率
	else
		lim.mp2(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
	end
	if length(rej.mw)<5																						% 衛星を使用しないエポックが5未満なら閾値を出す
		a.mw = setdiff(lc_int,rej.mw);																		% lc_intの要素の中から不使用の要素を除外
		lim_a.mw = std(diff_lc.mw(a.mw,j),1);																% 標準偏差(関数)
		lim.mw(1,j) = abs(mean(diff_lc.mw(a.mw,j)))*mag1 + lim_a.mw*est_prm.cycle_slip.sd;					% 平均*倍率+分散*倍率
	else
		lim.mw(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
	end
	if length(rej.lgl)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
		a.lgl = setdiff(lc_int,rej.lgl);																	% lc_intの要素の中から不使用の要素を除外
		lim_a.lgl = std(diff_lc.lgl(a.lgl,j),1);															% 標準偏差(関数)
		lim.lgl(1,j) = abs(mean(diff_lc.lgl(a.lgl,j)))*1 + lim_a.lgl*est_prm.cycle_slip.sd;					% 平均*倍率+分散*倍率
	else
		lim.lgl(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
	end
% 	if length(rej.lgp)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
% 		a.lgp = setdiff(lc_int,rej.lgp);																	% lc_intの要素の中から不使用の要素を除外
% 		lim_a.lgp = std(diff_lc.lgp(a.lgp,j),1);															% 標準偏差(関数)
% 		lim.lgp(1,j) = abs(mean(diff_lc.lgp(a.lgp,j)))*mag1 + lim_a.lgp*est_prm.cycle_slip.sd;				% 平均*倍率+分散*倍率
% 	else
% 		lim.lgp(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
% 	end
% 	if length(rej.lg1)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
% 		a.lg1 = setdiff(lc_int,rej.lg1);																	% lc_intの要素の中から不使用の要素を除外
% 		lim_a.lg1 = std(diff_lc.lg1(a.lg1,j),1);															% 標準偏差(関数)
% 		lim.lg1(1,j) = abs(mean(diff_lc.lg1(a.lg1,j)))*mag1 + lim_a.lg1*est_prm.cycle_slip.sd;				% 平均*倍率+分散*倍率
% 	else
% 		lim.lg1(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
% 	end
% 	if length(rej.lg2)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
% 		a.lg2 = setdiff(lc_int,rej.lg2);																	% lc_intの要素の中から不使用の要素を除外
% 		lim_a.lg2 = std(diff_lc.lg2(a.lg2,j),1);															% 標準偏差(関数)
% 		lim.lg2(1,j) = abs(mean(diff_lc.lg2(a.lg2,j)))*mag1 + lim_a.lg2*est_prm.cycle_slip.sd;				% 平均*倍率+分散*倍率
% 	else
% 		lim.lg2(1,j) = NaN;																					% 衛星を使用しないエポックが5以上なら閾値を出さない
% 	end
% 	if length(rej.ionp)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
% 		a.ionp = setdiff(lc_int,rej.ionp);																	% lc_intの要素の中から不使用の要素を除外
% 		lim_a.ionp = std(diff_lc.ionp(a.ionp,j),1);															% 標準偏差(関数)
% 		lim.ionp(1,j) = abs(mean(diff_lc.ionp(a.ionp,j)))*mag1 + lim_a.ionp*est_prm.cycle_slip.sd;			% 平均*倍率+分散*倍率
% 	else
% 		lim.ionp(1,j) = NaN;																				% 衛星を使用しないエポックが5以上なら閾値を出さない
% 	end
% 	if length(rej.ionl)<5																					% 衛星を使用しないエポックが5未満なら閾値を出す
% 		a.ionl = setdiff(lc_int,rej.ionl);																	% lc_intの要素の中から不使用の要素を除外
% 		lim_a.ionl = std(diff_lc.ionl(a.ionl,j),1);															% 標準偏差(関数)
% 		lim.ionl(1,j) = abs(mean(diff_lc.ionl(a.ionl,j)))*mag1 + lim_a.ionl*est_prm.cycle_slip.sd;			% 平均*倍率+分散*倍率
% 	else
% 		lim.ionl(1,j) = NaN;																				% 衛星を使用しないエポックが5以上なら閾値を出さない
% 	end
end
