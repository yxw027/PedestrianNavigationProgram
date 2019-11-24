function skyplot(ele,azi,est_prm)
%-------------------------------------------------------------------------------
% Function : Sky Plot
% 
% [argin]
% ele     : 仰角(行:エポック, 列:PRN)
% azi     : 方位角(行:エポック, 列:PRN)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 03, 2008
%-------------------------------------------------------------------------------

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

% Sky Plot
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);
set(gca,'Position',[0.109 0.171 0.812 0.669]);
hold on
axis equal
axis([-110 110 -110 110])
axis off
patch(90*sin(0:pi/36:2*pi),90*cos(0:pi/36:2*pi),'w','linestyle','none')

ele = ele*180/pi;
xpol = (90-ele).*cos(azi);
ypol = (90-ele).*sin(azi);
pol = plot(ypol,xpol,'Color',[0,0.5,0],'LineWidth',2);

% 方位角の目盛り
%--------------------------------------------
label='NESW';
for k=0:30:330
	plot([0 90*sin(k*pi/180)],[0 90*cos(k*pi/180)],'Color','k','LineStyle',':');
	if mod(k,90)==0
		str=label(k/90+1);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,'horizontal','center','FontSize',16,'FontWeight','bold')
	else
		str=num2str(k);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,'horizontal','center','FontSize',12,'FontWeight','demi')
	end
end

% 仰角の目盛り
%--------------------------------------------
for k=1:6
	if k~=6
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),'LineStyle',':','LineWidth',0.1,'Color','k')
	else
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),'LineStyle','-','LineWidth',0.1,'Color','k')
	end
end
line((90-est_prm.mask)*cos(0:0.001:2*pi),(90-est_prm.mask)*sin(0:0.001:2*pi),'LineStyle',':','LineWidth',0.1,'Color','r')
text(0,0,'90','HorizontalAlignment','center','FontSize',12,'FontWeight','demi','Color','k')
text(0,30,'60','HorizontalAlignment','center','FontSize',12,'FontWeight','demi','Color','k')
text(0,60,'30','HorizontalAlignment','center','FontSize',12,'FontWeight','demi','Color','k')
text(0,90,'0','HorizontalAlignment','center','FontSize',12,'FontWeight','demi','Color','k')
text(0,90-est_prm.mask,int2str(est_prm.mask),'HorizontalAlignment','center','FontSize',12,'FontWeight','demi','Color','r')

title(['Sky Plot',' : ',TT],'fontname','times','FontSize',16)
set(gca,'FontName','times');

% 衛星番号表示部分(衛星配置グラフ用)
%--------------------------------------------
% inde=[];
% xmin = min(xpol);
% for k=1:31
% 	ind=find(xmin(k)==xpol);
% 	if ~isempty(ind)
% 		ind = ind;
% 	else
% 		ind = NaN;
% 	end
% 	inde = [inde ind];
% end
% for k = 1:31
% 	if ~isnan(inde(k))
% 		text(ypol(inde(k)),xpol(inde(k))+1,[num2str(k)],'FontSize',10)
% 	end
% end

inde(1:31)=NaN;
for i=1:31
% 	indm=min(find(~isnan(ele(:,i))));
	indm=max(find(~isnan(ele(:,i))));
	if ~isempty(indm)
		inde(i)=indm;
		text(ypol(indm,i),xpol(indm,i),['PRN',num2str(i)],'FontSize',10,'horizontal','center','vertical','top')
	end
end
