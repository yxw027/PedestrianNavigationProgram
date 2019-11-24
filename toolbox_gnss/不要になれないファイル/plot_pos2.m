function plot_pos2(result,est_prm,yl,dt)
%-------------------------------------------------------------------------------
% Function : 相対測位用推定結果プロット(ENU, 2D, 3D)
% 
% [argin]
% result  : 推定結果構造体(*.{float/fix}.time:時刻, *.{float/fix}.pos:位置)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% yl      : プロット範囲
% dt      : X軸の目盛り間隔
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<4, dt=3600;, end

result1=result.float;
result2=result.fix;

% 真値を基準とした各軸方向の誤差
%--------------------------------------------
for k=1:length(result1.pos)
	result1.pos(k,1:3)=xyz2enu(result1.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
	result2.pos(k,1:3)=xyz2enu(result2.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
end
for n=1:3
	heikin1(n) = mean(result1.pos(find(~isnan(result1.pos(:,n))),n));							% 平均(Float解)
	stdd1(n) = std(result1.pos(find(~isnan(result1.pos(:,n))),n));								% 標準偏差(Float解)
	rms1(n)=sqrt(mean(result1.pos(find(~isnan(result1.pos(:,n))),n).^2));						% RMS(Float解)
	heikin2(n) = mean(result2.pos(find(~isnan(result2.pos(:,n))),n));							% 平均(Fix解)
	stdd2(n) = std(result2.pos(find(~isnan(result2.pos(:,n))),n));								% 標準偏差(Fix解)
	rms2(n)=sqrt(mean(result2.pos(find(~isnan(result2.pos(:,n))),n).^2));						% RMS(Fix解)
end

fix_rate=length(find(~isnan(result2.pos(:,1))))/length(result2.pos)*100;						% Fix率

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');


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
	plot(result1.time(:,4),result1.pos(:,n),'.-r');												% Float解のプロット
	plot(result1.time(:,4),result2.pos(:,n),'.-b');												% Fix解のプロット
	grid on
	box on
	last = round(max(result1.time(:,4))/dt)*dt;													% X軸範囲の最大値
	if last<max(result1.time(:,4)), last=max(result1.time(:,4));, end							% X軸範囲の最大値
	if result1.time(1,4)>900
		xlim([result1.time(1,4),last]);															% X軸の範囲
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
		title(['Position Error - Relative',' : ',TT,sprintf('  Fix rate: %3.f%%',fix_rate)]);	% タイトル
	end
	legend({'Float','Fix'});																	% 凡例

	text(result2.time(1,4)+abs(result2.time(1,4)-last)*0.99,-yl*0.82,...
			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin2(n),stdd2(n),rms2(n)),...
			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
			'Color','b','HorizontalAlignment','right');											% 平均, 標準偏差, RMS(Fix解)
	text(result1.time(1,4)+abs(result1.time(1,4)-last)*0.99,-yl*0.62,...
			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin1(n),stdd1(n),rms1(n)),...
			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
			'Color','r','HorizontalAlignment','right');											% 平均, 標準偏差, RMS(Float解)
end

% 2D + UP
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figureを指定位置・サイズで作成
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% フォントの種類・サイズを指定
set(gca,'Position',[0.124 0.176 0.494 0.669]);													% axesを指定位置・サイズで作成
hold on
plot(result1.pos(:,1),result1.pos(:,2),'.r');													% Float解のプロット
plot(result2.pos(:,1),result2.pos(:,2),'.b');													% Fix解のプロット
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

title('Horizontal Error - Relative');															% タイトル
legend({'Float','Fix'});																		% 凡例
%
%
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% フォントの種類・サイズを指定
set(gca,'Position',[0.689 0.176 0.198 0.669]);													% axesを指定位置・サイズで作成
hold on
plot(result1.time(:,4)*0,result1.pos(:,3),'.r');												% Float解のプロット
plot(result2.time(:,4)*0,result2.pos(:,3),'.b');												% Fix解のプロット
line([-10 10],[0 0],'Color','k');																% ライン
line([0 0],[-10 10],'Color','k');																% ライン
grid on
box on
xlim([-1,1]);																					% X軸の範囲
ylim([-yl,yl]);																					% Y軸の範囲
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y軸の目盛り

title('Up Error - Relative');																	% タイトル
legend({'Float','Fix'});																		% 凡例
