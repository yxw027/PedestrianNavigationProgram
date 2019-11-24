function plot_ionv2(LC,result,est_prm,dt)
%-------------------------------------------------------------------------------
% Function : 電離層遅延変動用プロット
% 
% [argin]
% LC      : 線形結合構造体
% result  : 推定結果構造体(*.dion 1-31:Ionosphere delay)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% dt      : X軸の目盛り間隔
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

ionsd=LC.rov.ionl-LC.ref.ionl;
ionsd_lcv(1:length(ionsd),1:31)=NaN;
IONsd_estv(1:length(ionsd),1:31)=NaN;

for prn=1:31
	% SD電離層遅延変動(LC)
	%--------------------------------------------
	i=find(~isnan(ionsd(:,prn)));														% NaN以外のインデックス
	if ~isempty(i)
		j=find(diff(i)>30);																% インデックスの差が30より大きいもの(分割点の探索)
		arc=[]; off=[]; arcs=[]; arce=[];
		for k=1:length(j)
			arc(k)=i(j(k)+1);															% 分割点
		end
		arcs=[i(1),arc];																% 分割開始点(分割数分)
		arce=[arc-1,i(end)];															% 分割終了点(分割数分)
		for ii=1:length(arcs)
			A=ionsd(arcs(ii):arce(ii),prn);												% 分割範囲で取り出し
			off=mean(A(find(~isnan(A))));												% バイアス成分
			ionsd_lcv(arcs(ii):arce(ii),prn)=ionsd(arcs(ii):arce(ii),prn)-off;			% 変動成分
		end
	end

	% SD電離層遅延変動(Estimate)
	%--------------------------------------------
	i=find(~isnan(result.dion(:,prn)));													% NaN以外のインデックス
	if ~isempty(i)
		j=find(diff(i)>30);																% インデックスの差が30より大きいもの(分割点の探索)
		arc=[]; off=[]; arcs=[]; arce=[];
		for k=1:length(j)
			arc(k)=i(j(k)+1);															% 分割点
		end
		arcs=[i(1),arc];																% 分割開始点(分割数分)
		arce=[arc-1,i(end)];															% 分割終了点(分割数分)
		for ii=1:length(arcs)
			A=result.dion(arcs(ii):arce(ii),prn);										% 分割範囲で取り出し
			off=mean(A(find(~isnan(A))));												% バイアス成分
			IONsd_estv(arcs(ii):arce(ii),prn)=result.dion(arcs(ii):arce(ii),prn)-off;	% 変動成分
		end
	end
end


% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

% プロット
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);						% figureを指定位置・サイズで作成
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.513 0.812 0.37]);											% axesを指定位置・サイズで作成
hold on
plot(result.time(:,4),ionsd_lcv,'.-');													% SD電離層遅延変動(LC)のプロット
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;												% X軸範囲の最大値
if last<max(result.time(:,4)), last=max(result.time(:,4));, end							% X軸範囲の最大値
if result.time(1,4)>900
	xlim([result.time(1,4),last]);														% X軸範囲の最大値
else
	xlim([0,last]);																		% X軸範囲の最大値
end
% ylim([-0.6,0.8]);																		% Y軸の範囲
ylim([-1,1]);																			% Y軸の範囲
set(gca,'XTick',[0:dt:last]);															% X軸の目盛り
% set(gca,'XTickLabel',{0:dt:last});													% X軸の目盛りのラベル
set(gca,'XTickLabel','');																% X軸のラベル
% xlabel('ToD [sec.]');																	% X軸のラベル
ylabel('LC[m]');																		% Y軸のラベル
title(['Ionospheric Delay Variation','(SD)',' : ',TT]);									% タイトル

% プロット
%--------------------------------------------
% figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.113 0.812 0.37]);											% axesを指定位置・サイズで作成
hold on
plot(result.time(:,4),IONsd_estv,'.-');													% SD電離層遅延変動(Estimate)のプロット
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;												% X軸範囲の最大値
if last<max(result.time(:,4)), last=max(result.time(:,4));, end							% X軸範囲の最大値
if result.time(1,4)>900
	xlim([result.time(1,4),last]);														% X軸範囲の最大値
else
	xlim([0,last]);																		% X軸範囲の最大値
end
% ylim([-0.6,0.8]);																		% Y軸の範囲
ylim([-1,1]);																			% Y軸の範囲
set(gca,'XTick',[0:dt:last]);															% X軸の目盛り
set(gca,'XTickLabel',{0:dt:last});														% X軸の目盛りのラベル
xlabel('ToD [sec.]');																	% X軸のラベル
ylabel('Estimate[m]');																	% Y軸のラベル
% title(['Ionospheric Delay Variation','(Estimate)',' : ',TT]);							% タイトル
