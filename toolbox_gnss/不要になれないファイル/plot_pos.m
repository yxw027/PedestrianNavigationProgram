function plot_pos(result,est_prm,mode,yl,dt)
%-------------------------------------------------------------------------------
% Function : 推定結果プロット(ENU, 2D, 3D)
% 
% [argin]
% result  : 推定結果構造体(*.time:時刻, *.pos:位置)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% mode    : 測位方法(1:SPP,2:PPP,3:DGPS,4:Relative(Float),5:Relative(Fix),6:VPPP)
% yl      : プロット範囲
% dt      : X軸の目盛り間隔
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<4, yl=10;, dt=3600;, end
if nargin<5, dt=3600;, end

mode_name={'SPP','PPP','DGPS','Relative(Float)','Relative(Fix)','VPPP'};


% 真値を基準とした各軸方向の誤差
%--------------------------------------------
for k=1:length(result.pos)
	result.pos(k,1:3)=xyz2enu(result.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
end
for n=1:3
	heikin(n) = mean(result.pos(find(~isnan(result.pos(:,n))),n));								% 平均
	stdd(n) = std(result.pos(find(~isnan(result.pos(:,n))),n));									% 標準偏差
	rms(n)=sqrt(mean(result.pos(find(~isnan(result.pos(:,n))),n).^2));							% RMS
end

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

% ENU
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figureを指定位置・サイズで作成
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.171 0.812 0.669]);													% axesを指定位置・サイズで作成
hold on
plot(result.time(:,4),result.pos(:,1:3),'.-');													% プロット
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;														% X軸範囲の最大値
if last<max(result.time(:,4)), last=max(result.time(:,4));, end									% X軸範囲の最大値
if result.time(1,4)>900
	xlim([result.time(1,4),last]);																% X軸の範囲
else
	xlim([0,last]);																				% X軸の範囲
end
ylim([-yl,yl]);																					% Y軸の範囲
set(gca,'XTick',[0:dt:last]);																	% X軸の目盛り
set(gca,'XTickLabel',{0:dt:last});																% X軸の目盛りのラベル
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y軸の目盛り
xlabel('ToD [sec.]');																			% X軸のラベル
ylabel('Position Error [m]');																	% Y軸のラベル
title(['Position Error - ',mode_name{mode},' : ',TT]);											% タイトル
legend({'East','North','Up'});																	% 凡例

text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.93,...
		sprintf('RMS:   E:%7.4f[m]  N:%7.4f[m]  U:%7.4f[m]',rms),...
		'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
		'Color','k','HorizontalAlignment','right');												% RMS
text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.84,...
		sprintf('STD:   E:%7.4f[m]  N:%7.4f[m]  U:%7.4f[m]',stdd),...
		'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
		'Color','k','HorizontalAlignment','right');												% 標準偏差
text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.75,...
		sprintf('MEAN:   E:%7.4f[m]  N:%7.4f[m]  U:%7.4f[m]',heikin),...
		'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
		'Color','k','HorizontalAlignment','right');												% 平均



% 2D + UP
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figureを指定位置・サイズで作成
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% フォントの種類・サイズを指定
set(gca,'Position',[0.124 0.176 0.494 0.669]);													% axesを指定位置・サイズで作成
hold on
plot(result.pos(:,1),result.pos(:,2),'.');														% プロット
line([-10 10],[0 0],'Color','k');																% ライン
line([0 0],[-10 10],'Color','k');																% ライン
grid on
box on
axis square
xlim([-yl,yl]);																					% X軸の範囲
ylim([-yl,yl]);																					% Y軸の範囲
set(gca,'XTick',[-yl:yl/5:yl]);																	% X軸の目盛り
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y軸の目盛り
xlabel('East Error [m]');																		% X軸のラベル
ylabel('North Error [m]');																		% Y軸のラベル
title(['Horizontal Error - ',mode_name{mode},' : ',TT]);										% タイトル
%
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% フォントの種類・サイズを指定
set(gca,'Position',[0.689 0.176 0.198 0.669]);													% axesを指定位置・サイズで作成
hold on
plot(result.time(:,4)*0,result.pos(:,3),'.');													% プロット
line([-10 10],[0 0],'Color','k');																% ライン
line([0 0],[-10 10],'Color','k');																% ライン
grid on
box on
xlim([-1,1]);																					% X軸の範囲
ylim([-yl,yl]);																					% Y軸の範囲
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y軸の目盛り
title(['Up Error - ',mode_name{mode}]);															% タイトル


% % 2D + 3D
% %--------------------------------------------
% if 0
% 	figure
% 	subplot(1,2,[1])
% 	set(gca,'FontName','times','FontSize',16);
% 	hold on
% 	plot(result(:,2),result(:,3),'.')
% 	line([-10 10],[0 0],'Color','k');
% 	line([0 0],[-10 10],'Color','k');
% 	grid on
% 	box on
% 	axis square
% 	xlim([-yl,yl]);
% 	ylim([-yl,yl]);
% 	xlabel('East Error [m]');
% 	ylabel('North Error [m]');
% 
% 	if mode == 0
% 		title('Horizontal Error - SPP')
% 	elseif mode == 1
% 		title('Horizontal Error - PPP')
% 	elseif mode == 2
% 		title('Horizontal Error - Relative')
% 	elseif mode == 3
% 		title('Horizontal Error - VPPP')
% 	end
% 	%
% 	subplot(1,2,2)
% 	set(gca,'FontName','times','FontSize',16);
% 	hold on
% 	plot3(result(:,2),result(:,3),result(:,4),'.-')
% 	% line([-10 10],[0 0],[0 0],'Color','k');
% 	% line([0 0],[-10 10],[0 0],'Color','k');
% 	% line([0 0],[0 0],[-10 10],'Color','k');
% 	grid on
% 	box on
% 	axis square
% 	view([-30,25])
% 	xlim([-yl,yl]);
% 	ylim([-yl,yl]);
% 	zlim([-yl,yl]);
% 
% 	if mode == 0
% 		title('3D Error - SPP')
% 	elseif mode == 1
% 		title('3D Error - PPP')
% 	elseif mode == 2
% 		title('3D Error - Relative')
% 	elseif mode == 3
% 		title('3D Error - VPPP')
% 	end
% end


% ENU(別々)
%--------------------------------------------
Yn={'East [m]','North [m]','Up [m]'};
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figureを指定位置・サイズで作成
for n=1:3
	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);													% フォントの種類・サイズを指定
	if n==1
		set(gca,'Position',[0.109 0.668 0.812 0.259]);											% axesを指定位置・サイズで作成
	elseif n==2
		set(gca,'Position',[0.109 0.387 0.812 0.259]);											% axesを指定位置・サイズで作成
	elseif n==3
		set(gca,'Position',[0.109 0.107 0.812 0.259]);											% axesを指定位置・サイズで作成
	end
	hold on
	plot(result.time(:,4),result.pos(:,n),'.-');												% プロット
	grid on
	box on
	last = round(max(result.time(:,4))/dt)*dt;													% X軸範囲の最大値
	if last<max(result.time(:,4)), last=max(result.time(:,4));, end								% X軸範囲の最大値
	if result.time(1,4)>900
		xlim([result.time(1,4),last]);															% X軸の範囲
	else
		xlim([0,last]);																			% X軸の範囲
	end
	ylim([-yl,yl]);																				% Y軸の範囲
	if n<3
		set(gca,'XTick',[0:dt:last]);															% X軸の目盛り
		set(gca,'XTickLabel','');																% X軸の目盛りのラベル
	else
		set(gca,'XTick',[0:dt:last]);															% X軸の目盛り
		set(gca,'XTickLabel',{0:dt:last});														% X軸の目盛りのラベル
		xlabel('ToD [sec.]');																	% X軸のラベル
	end
	set(gca,'YTick',[-yl:yl/5:yl]);																% Y軸の目盛り
	ylabel(Yn{n});																				% Y軸のラベル
	if n==1
		title(['Position Error - ',mode_name{mode},' : ',TT]);									% タイトル
	end

	text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.79,...
			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin(n),stdd(n),rms(n)),...
			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
			'Color','k','HorizontalAlignment','right');											% 平均, 標準偏差, RMS
end
