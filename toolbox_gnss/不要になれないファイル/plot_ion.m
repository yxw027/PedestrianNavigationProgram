function plot_ion(result,est_prm,dt)
%-------------------------------------------------------------------------------
% Function : 電離層遅延用推定結果プロット
% 
% [argin]
% result  : 推定結果構造体(*.dion 1-31:Ionosphere delay)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% dt      : X軸の目盛り間隔
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<3, dt=3600;, end

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);						% figureを指定位置・サイズで作成
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.171 0.812 0.669]);											% axesを指定位置・サイズで作成
hold on
plot(result.time(:,4),result.dion,'.-');												% 電離層遅延推定値のプロット
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;												% X軸範囲の最大値
if last<max(result.time(:,4)), last=max(result.time(:,4));, end							% X軸範囲の最大値
if result.time(1,4)>900
	xlim([result.time(1,4),last]);														% X軸の範囲
else
	xlim([0,last]);																		% X軸の範囲
end
% ylim([-yl,yl]);																		% Y軸の範囲
set(gca,'XTick',[0:dt:last]);															% X軸の目盛り
set(gca,'XTickLabel',{0:dt:last});														% X軸目盛りのラベル
% set(gca,'YTick',[-yl:yl/5:yl]);														% Y軸の目盛り
xlabel('ToD [sec.]');																	% X軸のラベル
ylabel('Ionosphere delay [m]');															% Y軸のラベル
title(['Ionosphere delay',' : ',TT]);													% タイトル
