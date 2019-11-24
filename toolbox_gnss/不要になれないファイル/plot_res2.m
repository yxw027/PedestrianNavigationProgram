function plot_res2(res,OBS,est_prm,yl)
%-------------------------------------------------------------------------------
% Function : 残差プロット
% 
% [argin]
% res     : 残差(構造体; *.time:時刻, *.data:残差)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% yl      : Y軸の範囲
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


% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

% 残差のプロット
%--------------------------------------------
for j=1:size(res.data,1)
	figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);					% figureを指定位置・サイズで作成
	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);											% フォントの種類・サイズを指定
% 	set(gca,'Position',[0.109 0.171 0.812 0.669]);										% axesを指定位置・サイズで作成
	set(gca,'Position',[0.109 0.55 0.812 0.35]);											% axesを指定位置・サイズで作成
	hold on
	for k=1:size(res.data,2)
		for i=1:31
			plot(OBS.ele(:,i)*180/pi,res.data{j,k}(:,i),'.');							% 残差のプロット
		end
	end
	grid on
	box on
	last = 90;																			% X軸範囲の最大値
	xlim([0,last]);																		% X軸の範囲
	ylim([-yl,yl]);																		% Y軸の範囲
	set(gca,'XTick',[0:10:last]);														% X軸の目盛り
	set(gca,'XTickLabel',{0:10:last});													% X軸目盛りのラベル
	set(gca,'YTick',[-yl:yl/5:yl]);														% Y軸の目盛り
	xlabel('Elevation [deg.]');															% X軸のラベル
	ylabel('Residual [m]');																% Y軸のラベル
	title(['Residual',' : ',TT]);														% タイトル

	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);											% フォントの種類・サイズを指定
% 	set(gca,'Position',[0.109 0.171 0.812 0.669]);										% axesを指定位置・サイズで作成
	set(gca,'Position',[0.109 0.113 0.812 0.35]);											% axesを指定位置・サイズで作成
	hold on
	for k=1:size(res.data,2)
		for i=1:31
			plot(OBS.azi(:,i)*180/pi,res.data{j,k}(:,i),'.');							% 残差のプロット
		end
	end
	grid on
	box on
	last = 180;																			% X軸範囲の最大値
	xlim([-last,last]);																	% X軸の範囲
	ylim([-yl,yl]);																		% Y軸の範囲
	set(gca,'XTick',[-last:30:last]);													% X軸の目盛り
	set(gca,'XTickLabel',{-last:30:last});												% X軸目盛りのラベル
	set(gca,'YTick',[-yl:yl/5:yl]);														% Y軸の目盛り
	xlabel('Azimuth [deg.]');															% X軸のラベル
	ylabel('Residual [m]');																% Y軸のラベル
% 	title(['Residual',' : ',TT]);														% タイトル
end
