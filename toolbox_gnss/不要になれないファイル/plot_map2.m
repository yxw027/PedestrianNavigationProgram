function plot_map(s)
%
% 海岸線地図のプロット(海岸線データはgshhs_l.bを利用)
%

%--- generate figure
%--------------------------------------------
newfig([900,600]);												% New figure

hold on, box on, axis equal

% rov:大津1 ref:宇治
%--------------------------------------------
lat_rov1=str2num('3.5137040081E+01');			% Lat. (deg.)
lon_rov1=str2num('1.3587080804E+02');			% Lon. (deg.)
lat_ref1=str2num('3.4882031084E+01');			% Lat. (deg.)
lon_ref1=str2num('1.3578984753E+02');			% Lon. (deg.)

% rov:大津2 ref:根尾
%--------------------------------------------
lat_rov2=str2num('3.4939602603E+01');			% Lat. (deg.)
lon_rov2=str2num('1.3590616507E+02');			% Lon. (deg.)
lat_ref2=str2num('3.5632897742E+01');			% Lat. (deg.)
lon_ref2=str2num('1.3661139408E+02');			% Lon. (deg.)

% rov:下呂 ref:福知山
%--------------------------------------------
lat_rov3=str2num('3.5800483761E+01');			% Lat. (deg.)
lon_rov3=str2num('1.3724837272E+02');			% Lon. (deg.)
lat_ref3=str2num('3.5292336384E+01');			% Lat. (deg.)
lon_ref3=str2num('1.3516403423E+02');			% Lon. (deg.)

xlabel('Longitude [deg.]','fontname','Times New Roman','fontsize',18);			% X軸のラベル
ylabel('Latitude [deg.]','fontname','Times New Roman','fontsize',18);			% Y軸のラベル
% xlim([120,155]), ylim([20,50]);
xlim([134,138]), ylim([33,37]);
% title('GSI Stations Map','fontsize',10);

load('gshhs_i_map');
% if nargin==1
% 	plot(xlon,ylat,s);
% else
% 	plot(xlon,ylat,'color',[0.4 0.4 0.4]);
% end

if isempty(src), load('gshhs_l_map_mod'); end

for a=src
	lon=a.Lon; lon(abs(diff(lon))>180)=NaN;
	if nargin==1
		plot(lon,a.Lat,s);
	else
		plot(lon,a.Lat,'color',[0 0 0],'LineWidth',2);
	end
end

% set(axis,'fontname','Times New Roman','fontsize',14);									% fontname, fontsize

rov1=plot(lon_rov1,lat_rov1,'.r','markersize',30);
ref1=plot(lon_ref1,lat_ref1,'.r','markersize',30);
rov2=plot(lon_rov2,lat_rov2,'.b','markersize',30);
ref2=plot(lon_ref2,lat_ref2,'.b','markersize',30);
rov3=plot(lon_rov3,lat_rov3,'.g','markersize',30);
ref3=plot(lon_ref3,lat_ref3,'.g','markersize',30);

hl=legend([rov1,rov2,rov3],{'Dataset A','Dataset B','Dataset C'},'Orientation','horizontal');									% 凡例
lines = findobj(get(hl,'children'),'type','line');
set(lines(1),'.r','markersize',30);
set(lines(2),'.b','markersize',30);
set(lines(3),'.g','markersize',30);


%--- new figure
%-------------------------------------------------------------------------------
function newfig(siz)
screen=get(0,'screensize');															% スクリーンサイズ取得
pos=[(screen(3)-siz(1))/2 (screen(4)-siz(2))/2 siz(1) siz(2)];						% position
figure('Position',pos);																% figureを指定位置・サイズで作成
