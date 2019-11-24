function plot_rtk2(result,result_test,est_prm)


% 真値を基準とした各軸方向の誤差
%--------------------------------------------
result1=result.spp;
result2=result.float;
result3=result.fix;

for k=1:length(result1.pos)
	result1.pos(k,7:9)=xyz2enu(result1.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
	result2.pos(k,7:9)=xyz2enu(result2.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
	result3.pos(k,7:9)=xyz2enu(result3.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
end

% 推定開始・終了時刻
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% % ENU
% %--------------------------------------------
screen=get(0,'screensize');
% figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figureを指定位置・サイズで作成
% 
% plot3(result1.pos(1:1500,7), result1.pos(1:1500,8), result1.pos(1:1500,9),'g.')
% hold on
% plot3(result2.pos(1:1500,7), result2.pos(1:1500,8), result2.pos(1:1500,9),'b.')
% hold on
% plot3(result3.pos(1:1500,7), result3.pos(1:1500,8), result3.pos(1:1500,9),'r*')
% grid on
% box on
% 
% xlim([min(result1.pos(1:1500,7)),max(result1.pos(1:1500,7))]);															% X軸の範囲
% set(gca,'XTick',[min(result1.pos(1:1500,7)):1500:max(result1.pos(1:1500,7))]);											% X軸の目盛り
% ylim([min(result1.pos(1:1500,8)),max(result1.pos(1:1500,8))]);															% Y軸の範囲
% set(gca,'YTick',[min(result1.pos(1:1500,8)):1500:max(result1.pos(1:1500,8))]);											% Y軸の目盛り
% zlim([min(result1.pos(:,9)),max(result1.pos(:,9))]);															% Z軸の範囲
% set(gca,'ZTick',[min(result1.pos(:,9)):1500:max(result1.pos(:,9))]);											% Z軸の目盛り
% 
% title(['Position RTK',TT]);	% タイトル
% % 		title(['Position Error - Relative',' : ',TT,sprintf('  Fix rate: %3.f%%',fix_rate)]);	% タイトル
% % 	legend({'Float','Fix'});																	% 凡例



% 真値を基準とした各軸方向の誤差
%--------------------------------------------
result_test1=result_test.spp;
result_test2=result_test.float;
result_test3=result_test.fix;

for k=1:length(result_test1.pos)
	result_test1.pos(k,7:9)=xyz2enu(result_test1.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
	result_test2.pos(k,7:9)=xyz2enu(result_test2.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
	result_test3.pos(k,7:9)=xyz2enu(result_test3.pos(k,1:3)',est_prm.rovpos);								% ENUに変換
end

% % ENU
% %--------------------------------------------
% figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figureを指定位置・サイズで作成
% 
% plot3(result_test1.pos(1:1500,7), result_test1.pos(1:1500,8), result_test1.pos(1:1500,9),'y.')
% hold on
% plot3(result_test2.pos(1:1500,7), result_test2.pos(1:1500,8), result_test2.pos(1:1500,9),'c.')
% hold on
% plot3(result_test3.pos(1:1500,7), result_test3.pos(1:1500,8), result_test3.pos(1:1500,9),'m*')
% grid on
% box on
% 
% xlim([min(result_test1.pos(1:1500,7)),max(result_test1.pos(1:1500,7))]);															% X軸の範囲
% set(gca,'XTick',[min(result_test1.pos(1:1500,7)):1500:max(result_test1.pos(1:1500,7))]);											% X軸の目盛り
% ylim([min(result_test1.pos(1:1500,8)),max(result_test1.pos(1:1500,8))]);															% Y軸の範囲
% set(gca,'YTick',[min(result_test1.pos(1:1500,8)):1500:max(result_test1.pos(1:1500,8))]);											% Y軸の目盛り
% zlim([min(result_test1.pos(:,9)),max(result_test1.pos(:,9))]);															% Z軸の範囲
% set(gca,'ZTick',[min(result_test1.pos(:,9)):1500:max(result_test1.pos(:,9))]);											% Z軸の目盛り
% 
% title(['Position RTK_test',TT]);	% タイトル
% % 		title(['Position Error - Relative',' : ',TT,sprintf('  Fix rate: %3.f%%',fix_rate)]);	% タイトル
% % 	legend({'Float','Fix'});																	% 凡例



% ENU
%--------------------------------------------
figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figureを指定位置・サイズで作成

plot3(result1.pos(1500:3000,7), result1.pos(1500:3000,8), result1.pos(1500:3000,9),'g.')
hold on
plot3(result2.pos(1500:3000,7), result2.pos(1500:3000,8), result2.pos(1500:3000,9),'b.')
hold on
plot3(result3.pos(1500:3000,7), result3.pos(1500:3000,8), result3.pos(1500:3000,9),'r*')
hold on
plot3(result_test1.pos(1500:3000,7), result_test1.pos(1500:3000,8), result_test1.pos(1500:3000,9),'y.')
hold on
plot3(result_test2.pos(1500:3000,7), result_test2.pos(1500:3000,8), result_test2.pos(1500:3000,9),'c.')
hold on
plot3(result_test3.pos(1500:3000,7), result_test3.pos(1500:3000,8), result_test3.pos(1500:3000,9),'m*')
grid on
box on

xlim([min(result_test1.pos(1500:3000,7)),max(result_test1.pos(1500:3000,7))]);															% X軸の範囲
set(gca,'XTick',[min(result_test1.pos(1500:3000,7)):1500:max(result_test1.pos(1500:3000,7))]);											% X軸の目盛り
ylim([min(result_test1.pos(1500:3000,8)),max(result_test1.pos(1500:3000,8))]);															% Y軸の範囲
set(gca,'YTick',[min(result_test1.pos(1500:3000,8)):1500:max(result_test1.pos(1500:3000,8))]);											% Y軸の目盛り
zlim([min(result_test1.pos(:,9)),max(result_test1.pos(:,9))]);															% Z軸の範囲
set(gca,'ZTick',[min(result_test1.pos(:,9)):1500:max(result_test1.pos(:,9))]);											% Z軸の目盛り

title(['Position RTK',TT]);	% タイトル
% 		title(['Position Error - Relative',' : ',TT,sprintf('  Fix rate: %3.f%%',fix_rate)]);	% タイトル
% 	legend({'Float','Fix'});																	% 凡例



% LLH
%--------------------------------------------
figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figureを指定位置・サイズで作成

plot3(result1.pos(:,4), result1.pos(:,5), result1.pos(:,6),'g.')
hold on
plot3(result2.pos(:,4), result2.pos(:,5), result2.pos(:,6),'b.')
hold on
plot3(result3.pos(:,4), result3.pos(:,5), result3.pos(:,6),'r*')
hold on
plot3(result_test1.pos(:,4), result_test1.pos(:,5), result_test1.pos(:,6),'y.')
hold on
plot3(result_test2.pos(:,4), result_test2.pos(:,5), result_test2.pos(:,6),'c.')
hold on
plot3(result_test3.pos(:,4), result_test3.pos(:,5), result_test3.pos(:,6),'m*')
grid on
box on

xlim([min(result1.pos(:,4)),max(result1.pos(:,4))]);															% X軸の範囲
set(gca,'XTick',[min(result1.pos(:,4)):0.05:max(result1.pos(:,4))]);											% X軸の目盛り
ylim([min(result1.pos(:,5)),max(result1.pos(:,5))]);															% Y軸の範囲
set(gca,'YTick',[min(result1.pos(:,5)):0.05:max(result1.pos(:,5))]);											% Y軸の目盛り
zlim([min(result1.pos(:,6)),max(result1.pos(:,6))]);															% Z軸の範囲
set(gca,'ZTick',[min(result1.pos(:,6)):50:max(result1.pos(:,6))]);											% Z軸の目盛り



% LLH
%--------------------------------------------
figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figureを指定位置・サイズで作成

plot3(result_test1.pos(:,4), result_test1.pos(:,5), result_test1.pos(:,6),'g.')
hold on
plot3(result_test2.pos(:,4), result_test2.pos(:,5), result_test2.pos(:,6),'b.')
hold on
plot3(result_test3.pos(:,4), result_test3.pos(:,5), result_test3.pos(:,6),'r*')
grid on
box on

xlim([min(result_test1.pos(:,4)),max(result_test1.pos(:,4))]);															% X軸の範囲
set(gca,'XTick',[min(result_test1.pos(:,4)):0.05:max(result_test1.pos(:,4))]);											% X軸の目盛り
ylim([min(result_test1.pos(:,5)),max(result_test1.pos(:,5))]);															% Y軸の範囲
set(gca,'YTick',[min(result_test1.pos(:,5)):0.05:max(result_test1.pos(:,5))]);											% Y軸の目盛り
zlim([min(result_test1.pos(:,6)),max(result_test1.pos(:,6))]);															% Z軸の範囲
set(gca,'ZTick',[min(result_test1.pos(:,6)):50:max(result_test1.pos(:,6))]);											% Z軸の目盛り



% 高さ軸ノルム表現時間差分
%--------------------------------------------
for i=1:length(result1.pos)
kyori(i,3)=norm(result2.pos(i,6));
kyori(i,4)=norm(result_test2.pos(i,6));
end
jikansa(:,3)=diff(kyori(:,3));
jikansa(:,4)=diff(kyori(:,4));
figure
plot(jikansa(:,3),'b')
hold on
plot(jikansa(:,4),'r')

bibun(:,3)=diff(kyori(:,3),2);
bibun(:,4)=diff(kyori(:,4),2);
figure
plot(bibun(:,3),'b')
hold on
plot(bibun(:,4),'r')



% 高さ各軸方向時間差分
%--------------------------------------------
figure
plot(result2.pos(:,6),'b.')
hold on
plot(result_test2.pos(:,6),'r.')
