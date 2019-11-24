function plot_res(res,est_prm,dt,yl)
%-------------------------------------------------------------------------------
% Function : 残差プロット
% 
% [argin]
% res     : 残差(構造体; *.time:時刻, *.data:残差)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% dt      : X軸の目盛り間隔
% yl      : Y軸の範囲
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

% 残差のプロット
%--------------------------------------------
for j=1:size(res.data,1)
	figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);					% figureを指定位置・サイズで作成
	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);											% フォントの種類・サイズを指定
	set(gca,'Position',[0.109 0.171 0.812 0.669]);										% axesを指定位置・サイズで作成
	hold on
	for k=1:size(res.data,2)
		plot(res.time(:,4),res.data{j,k},'.-');											% 残差のプロット
	end
	grid on
	box on
	last = round(max(res.time(:,4))/dt)*dt;												% X軸範囲の最大値
	if last<max(res.time(:,4)), last=max(res.time(:,4));, end							% X軸範囲の最大値
	if res.time(1,4)>900
		xlim([res.time(1,4),last]);														% X軸の範囲
	else
		xlim([0,last]);																	% X軸の範囲
	end
	ylim([-yl,yl]);																		% Y軸の範囲
	set(gca,'XTick',[0:dt:last]);														% X軸の目盛り
	set(gca,'XTickLabel',{0:dt:last});													% X軸目盛りのラベル
	set(gca,'YTick',[-yl:yl/5:yl]);														% Y軸の目盛り
	xlabel('ToD [sec.]');																% X軸のラベル
	ylabel('Residual [m]');																% Y軸のラベル
	title(['Residual',' : ',TT]);														% タイトル
end
