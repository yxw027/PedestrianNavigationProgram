function plot_sat(result,est_prm,dt)
%-------------------------------------------------------------------------------
% Function : 衛星関連プロット
% 
% [argin]
% result  : 推定結果の構造体(例: Result.spp; 使用するのは下記のフィールド部分)
%           衛星関連の構造体(result.prn)
%            (セル配列 1: 可視衛星, 2: 使用衛星, 3: 衛星数など(tod,all,used,dop), 4: 基準衛星)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% dt      : ラベルの間隔(ToD)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 18, 2008
%-------------------------------------------------------------------------------

if nargin==1, dt=3600;, end

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

% 衛星数の変化
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);					% figureを指定位置・サイズで作成
axes('Parent',gcf);																	
set(gca,'FontName','times','FontSize',12);											% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.668 0.812 0.259]);										% axesを指定位置・サイズで作成
hold on
plot(result.prn{3}(:,1),result.prn{3}(:,2),'color','r');							% 可視衛星数のプロット
plot(result.prn{3}(:,1),result.prn{3}(:,3),'color','b');							% 使用衛星数のプロット
ylabel('No. of Satellites');														% Y軸のラベル
mm = min(result.prn{3}(:,3));														% 使用衛星数の最小値
nn = max(result.prn{3}(:,2));														% 可視衛星数の最大値
last = round(max(result.prn{3}(:,1))/dt)*dt;										% X軸の範囲の最大値
if last<max(result.prn{3}(:,1)), last=max(result.prn{3}(:,1));, end					% X軸の範囲の最大値
if result.prn{3}(1,1)>900
	xlim([result.prn{3}(1,1),last]);												% X軸の範囲
else
	xlim([0,last]);																	% X軸の範囲
end
ylim([mm-1,nn+2]);																	% Y軸の範囲
set(gca,'YTick',[mm-1:1:nn+2]);														% Y軸の目盛り
set(gca,'XTick',[0:dt:last]);														% X軸の目盛り
set(gca,'XTickLabel',{0:dt:last});													% X軸の目盛りのラベル
title(['Satellites',' : ',TT],'fontname','times','FontSize',16);					% タイトル
legend({'Visible','Used'},'Orientation','horizontal');								% 凡例
grid on
box on
set(gca,'FontName','times','FontSize',11);											% フォントの種類・サイズを指定

% 各衛星についての変化
%--------------------------------------------
axes('Parent',gcf);																	
set(gca,'FontName','times','FontSize',12);											% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.087 0.812 0.539]);										% axesを指定位置・サイズで作成
hold on
h1=plot(result.prn{3}(:,1),result.prn{1},'LineWidth',4,'color','r');				% 可視衛星PRNのプロット
h2=plot(result.prn{3}(:,1),result.prn{2},'LineWidth',4,'color','b');				% 可視衛星PRNのプロット
if size(result.prn,2)==4
	h3=plot(result.prn{3}(:,1),result.prn{4},'LineWidth',4,'color',[0,0.5,0]);		% 基準衛星PRNのプロット
end
xlabel('ToD [sec.]');																% X軸のラベル
ylabel('PRN')																		% Y軸のラベル
last = round(max(result.prn{3}(:,1))/dt)*dt;										% X軸の範囲の最大値
if last<max(result.prn{3}(:,1)), last=max(result.prn{3}(:,1));, end					% X軸の範囲の最大値
if result.prn{3}(1,1)>900
	xlim([result.prn{3}(1,1),last]);												% X軸の範囲
else
	xlim([0,last]);																	% X軸の範囲
end
ylim([0,32]);																		% Y軸の範囲
set(gca,'XTick',[0:dt:last]);														% X軸の目盛り
set(gca,'XTickLabel',{0:dt:last});													% X軸の目盛りのラベル
set(gca,'ytick',[1:31]);															% X軸の目盛り
set(gca,'YDir','reverse');															% X軸の目盛りの反転
grid on
box on
set(gca,'FontName','times','FontSize',11);											% フォントの種類・サイズを指定

if size(result.prn,2)==4
	legend([h1(1),h2(1),h3(1)],{'Visible','Used','Ref'},...
			'Orientation','horizontal','Location','SouthEast');						% 凡例
else
	legend([h1(1),h2(1)],{'Visible','Used'},...
			'Orientation','horizontal','Location','SouthEast');						% 凡例
end
