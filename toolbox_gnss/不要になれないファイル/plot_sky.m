function plot_sky2(OBS,result,est_prm)
%-------------------------------------------------------------------------------
% Function : Sky Plot
% 
% [argin]
% OBS     : 観測データ構造体(例: OBS.rov, OBS.ref)
%            **.ele : 仰角(行:エポック, 列:PRN)
%            **.azi : 方位角(行:エポック, 列:PRN)
% result  : 推定結果の構造体(例: Result.spp; 使用するのは下記のフィールド部分)
%           衛星関連の構造体(result.prn)
%            (セル配列 1: 可視衛星, 2: 使用衛星, 3: 衛星数など(tod,all,used,dop), 4: 基準衛星)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 18, 2008
%-------------------------------------------------------------------------------

ele=OBS.ele;		% 仰角
azi=OBS.azi;		% 方位角

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

% Sky Plot
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);						% figureを指定位置・サイズで作成
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% フォントの種類・サイズを指定
set(gca,'Position',[0.109 0.087 0.812 0.812]);											% axesを指定位置・サイズで作成
hold on
axis equal
% axis([-110 110 -110 110]);
axis([-95 95 -95 95]);
axis off
patch(90*sin(0:pi/36:2*pi),90*cos(0:pi/36:2*pi),'w','linestyle','none');				% 円の作成(背景は白)

ele = ele*180/pi;
xpol = (90-ele).*sin(azi);																% Xの値(sinに仰角, 方位角を利用)
ypol = (90-ele).*cos(azi);																% Yの値(cosに仰角, 方位角を利用)
pol = plot(xpol,ypol,'Color',[1,0.0,0],'LineWidth',2);									% skyplot(可視衛星)

xpol_use=xpol.*(result.prn{2}./result.prn{2});											% Xの値(使用衛星の抽出)
ypol_use=ypol.*(result.prn{2}./result.prn{2});											% Yの値(使用衛星の抽出)
pol_use = plot(xpol_use,ypol_use,'Color',[0,0.0,1],'LineWidth',2);						% skyplot(使用衛星)

if size(result.prn,2)==4
xpol_ref=xpol.*(result.prn{4}./result.prn{4});											% Xの値(基準衛星の抽出)
ypol_ref=ypol.*(result.prn{4}./result.prn{4});											% Yの値(基準衛星の抽出)
pol_ref = plot(xpol_ref,ypol_ref,'Color',[0,0.5,0],'LineWidth',2);						% skyplot(基準衛星)
end

% 方位角の目盛り
%--------------------------------------------
label='NESW';
for k=0:30:330
	plot([0 90*sin(k*pi/180)],[0 90*cos(k*pi/180)],'Color','k','LineStyle',':');		% 30度ごとに線プロット
	if mod(k,90)==0
		str=label(k/90+1);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,...
				'horizontal','center','FontSize',16,'FontWeight','bold');				% 90度ごとに目盛り(文字)
	else
		str=num2str(k);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,...
				'horizontal','center','FontSize',12,'FontWeight','demi');				% 30度ごとに目盛り(数字)
	end
end

% 仰角の目盛り
%--------------------------------------------
for k=1:6
	if k~=6
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),...
				'LineStyle',':','LineWidth',0.1,'Color','k');							% 15度ごとに点線プロット
	else
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),...
				'LineStyle','-','LineWidth',0.1,'Color','k');							% 最後は線プロット
	end
end
line((90-est_prm.mask)*cos(0:0.001:2*pi),(90-est_prm.mask)*sin(0:0.001:2*pi),...
			'LineStyle',':','LineWidth',0.1,'Color','r');								% 仰角マスクに赤点線プロット
for k=0:30:90
	text(0,k,num2str(90-k),'HorizontalAlignment','center',...
			'FontSize',12,'FontWeight','demi','Color','k');								% 30度ごとに目盛り
end
text(0,90-est_prm.mask,int2str(est_prm.mask),'HorizontalAlignment','center',...
		'FontSize',12,'FontWeight','demi','Color','r');									% 仰角マスクの目盛り

title(['Sky Plot',' : ',TT],'fontname','times','FontSize',16);							% タイトル
set(gca,'FontName','times');															% フォントの種類を指定

% 衛星番号表示部分(衛星配置グラフ用)
%--------------------------------------------
inde(1:31)=NaN;
for i=1:31
% 	indm=min(find(~isnan(ele(:,i))));
	indm=max(find(~isnan(ele(:,i))));
	if ~isempty(indm)
		inde(i)=indm;
		text(xpol(indm,i),ypol(indm,i),['PRN',num2str(i)],...
				'FontSize',10,'horizontal','center','vertical','top');
	end
end
