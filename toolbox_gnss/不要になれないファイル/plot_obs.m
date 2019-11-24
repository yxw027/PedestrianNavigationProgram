function plot_obs(OBS,dtr_all,est_prm,prn,dt)
%-------------------------------------------------------------------------------
% Function : 観測データプロット(補正前と補正後の比較)
% 
% [argin]
% OBS         : 観測データ構造体(*.time:時刻, *.{ca,py,ph1,ph2,etc}:観測データ)
% dtr_all     : 受信機時計誤差(1:補正前,2:補正済)
% est_prm     : パラメータ設定値(推定時刻, 真値などを利用)
% prn         : 衛星PRN番号
% dt          : X軸の目盛り間隔
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<5, dt=3600;, end

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% スクリーンサイズ取得
%--------------------------------------------
screen=get(0,'screensize');

pt=round(length(OBS.time)/180);				% プロット間隔(間引くため)

% 1:OBS(raw,corrected), 2:clock error(raw,corrected)
%--------------------------------------------
Yn={'CA [m]','PY [m]','L1 [cycle]','L2 [cycle]'};
field1={'ca','py','ph1','ph2'};
field2={'ca_cor','py_cor','ph1_cor','ph2_cor'};
for m=1:4
	ax=[];
	figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);					% figureを指定位置・サイズで作成
	for n=1:2
		ax(n)=axes('Parent',gcf);
		set(gca,'FontName','times','FontSize',16);										% フォントの種類・サイズを指定
		if n==1
			set(gca,'Position',[0.109 0.387 0.812 0.259*2+0.022]);						% axesを指定位置・サイズで作成
		elseif n==2
			set(gca,'Position',[0.109 0.107 0.812 0.259]);								% axesを指定位置・サイズで作成
		end
		hold on
		if n==1
			plot(OBS.time(:,4),OBS.(field1{m})(:,prn),'.-','Color',[0.7,0.7,0.7]);		% OBS(raw)のプロット
			plot(OBS.time(1:pt:end,4),OBS.(field2{m})(1:pt:end,prn),'.-b');				% OBS(corrected)のプロット
		elseif n==2
			plot(OBS.time(:,4),dtr_all(:,1),'.-','Color',[0.7,0.7,0.7]);				% clock error(raw)のプロット
			plot(OBS.time(1:pt:end,4),dtr_all(1:pt:end,2),'.-b');						% clock error(corrected)のプロット
		end
		grid on
		box on
		last = round(max(OBS.time(:,4))/dt)*dt;											% X軸範囲の最大値
		if last<max(OBS.time(:,4)), last=max(OBS.time(:,4));, end						% X軸範囲の最大値
		if OBS.time(1,4)>900
			xlim([OBS.time(1,4),last]);													% X軸の範囲
		else
			xlim([0,last]);																% X軸の範囲
		end
	% 	ylim([-yl,yl]);																	% Y軸の範囲
		if n<2
			set(gca,'XTick',[0:dt:last]);												% X軸の目盛り
			set(gca,'XTickLabel','');													% X軸の目盛りのラベル
		else
			set(gca,'XTick',[0:dt:last]);												% X軸の目盛り
			set(gca,'XTickLabel',{0:dt:last});											% X軸の目盛りのラベル
			xlabel('ToD [sec.]');														% X軸のラベル
		end
% 		set(gca,'YTick',[-yl:yl/5:yl]);													% Y軸の目盛り
		if n==1
			ylabel(Yn{m});																% Y軸のラベル
			title(['Observation Data ',sprintf('(PRN%02d)',prn),' : ',TT]);				% タイトル
			legend({'Raw','Corrected'});												% 凡例
		else
			ylabel('clock error [sec]');												% Y軸のラベル
		end
	end
% 	linkaxes(ax,'x');
end