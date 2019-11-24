function plot_data(varargin)
%------------------------------------------------------------------------------- 
% Function : 各種データのプロット関数(マウス操作で利用可能)
% 
% file I/O
% 
% SPP,PPP,VPPP,DGPPS,Float,Fix,All(Float+Fix)
% 
% ENU,2D+U,Rcv_clk,Trop,Iono,Sats,Skyplot,LC,OBS,Res1,Res2
% 
% X-Range,Y-Range,Fit-X,Fit-Y
% 
% KMLファイルの出力を追加
% 
% 未実装項目
% ・残差プロット(測位時の格納の部分から見直す必要有り)
%   測位方法に応じて必要な項目に変更した方が良いかも
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: March 3, 2009
%-------------------------------------------------------------------------------
% VPPP, GLONASS対応
% 衛星プロットの変更
%
% 未実装項目
% ・相対測位 GLONASS 対応
%   SBAS等も見据えた衛星の結果格納に変更する必要がある
%
% Aug 21, 2009, T.Yanase
%-------------------------------------------------------------------------------

if nargin>0&strncmp(varargin{1},'cb_',3), feval(varargin{:}); return; end

%--- default setting
%--------------------------------------------
p.file='';
p.type='enu';																	% プロットタイプ
p.type_n=1;
p.opt.plot=1;
p.type_s=1;
p.opt.sat=1:61;
p.opt.station=1;
p.opt.LC_plot=0;
p.opt.OBS_plot=0;
p.opt.Res_pre_plot=0;
p.opt.Res_pos_plot=0;
p.opt.Res_pre_e_plot=0;
p.opt.Res_pos_e_plot=0;
p.opt.Res_pre_a_plot=0;
p.opt.Res_pos_a_plot=0;
p.opt.yrange1=-1;
p.opt.yrange2=1;
p.opt.yrange3=0.2;
p.opt.xrange1=0;
p.opt.xrange2=86400;
p.opt.xrange3=7200;
p.opt.view_stats=1;

p.esttime  =[];

p.enu_float=[]; p.enu_fix  =[];
p.enu_mix  =[]; p.enu_spp  =[];
p.enu_ppp  =[]; p.enu_vppp =[];
p.enu_dgps =[];

p.stime    =[]; p.etime    =[];
p.rovpos   =[]; p.refpos   =[];
p.dtrop    =[]; p.dion     =[];
p.dtr      =[];
p.dtr_vppp =[];

p.heikin0=[]; p.stdd0=[]; p.rms0=[];
p.heikin1=[]; p.stdd1=[]; p.rms1=[];
p.heikin2=[]; p.stdd2=[]; p.rms2=[];
p.heikin3=[]; p.stdd3=[]; p.rms3=[];
p.heikin4=[]; p.stdd4=[]; p.rms4=[];
p.heikin5=[]; p.stdd5=[]; p.rms5=[];
p.heikin6=[]; p.stdd6=[]; p.rms6=[];

p.obs_rov.ca     =[]; p.obs_ref.ca     =[];
p.obs_rov.py     =[]; p.obs_ref.py     =[];
p.obs_rov.ph1    =[]; p.obs_ref.ph1    =[];
p.obs_rov.ph2    =[]; p.obs_ref.ph2    =[];
p.obs_rov.ca_cor =[]; p.obs_ref.ca_cor =[];
p.obs_rov.py_cor =[]; p.obs_ref.py_cor =[];
p.obs_rov.ph1_cor=[]; p.obs_ref.ph1_cor=[];
p.obs_rov.ph2_cor=[]; p.obs_ref.ph2_cor=[];
p.obs_rov.ele    =[]; p.obs_ref.ele    =[];
p.obs_rov.azi    =[]; p.obs_ref.azi    =[];

p.LC_rov.mp1 =[]; p.LC_ref.mp1 =[];
p.LC_rov.mp2 =[]; p.LC_ref.mp2 =[];
p.LC_rov.mw  =[]; p.LC_ref.mw  =[];
p.LC_rov.lgl =[]; p.LC_ref.lgl =[];
p.LC_rov.lgp =[]; p.LC_ref.lgp =[];
p.LC_rov.lg1 =[]; p.LC_ref.lg1 =[];
p.LC_rov.lg2 =[]; p.LC_ref.lg2 =[];
p.LC_rov.ionp=[]; p.LC_ref.ionp=[];
p.LC_rov.ionl=[]; p.LC_ref.ionl=[];

p.Res=[];

% 引数にファイル名(ディレクトリ付き)が設定された場合
i=1;
while i<=nargin
	arg=varargin{i};
	if findstr(arg,'.mat'), p.file=arg;, end
	i=i+1;
end

%--- generate figure
%--------------------------------------------
newfig([900,600]);												% New figure

%--- generate menu file option
%--------------------------------------------
h=uimenu(gcf,'tag','file_io','label','&File_I/O','handlevisibility','off');
labels={'File open','File output','KML output','Statis output(Tex)'};
m=1;
for n=1:length(labels)
	menu(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_0']);
	m=m+1;
end
for n=1:length(labels)
	if n<length(menu)
		set(menu(n+1),'separator','on');
	end
end
guidata(h,p);

if isempty(p.file), return; end									% ファイル名が設定されていない場合はreturn

readdata;														% ファイルの読み込み



%--- callback menu file option
%-------------------------------------------------------------------------------
function cb_0
p=guidata(gcf);
switch get(gcbo,'userdata')
case 1,
	[filename, pathname, filterindex] = uigetfile('*.mat', 'MAT-files (*.mat)');
	file=[pathname,filename];
	if isempty(file), return; else p.file=file; end
	guidata(gcf,p);

	readdata;
	return;
case 2,
	[file,path] = uiputfile('output.fig','Save file name');
	if file~=0
		[PATH,NAME,EXT, VERSION] = fileparts([path,file]);
		output_fig(fullfile(PATH,NAME),3,gcf);
	end
case 3,
	[file,path] = uiputfile('output.kml','Save file name');
	if file~=0
		output_kml2([path,file],p);
	end
case 4,
	output_statis(p);
end
guidata(gcf,p);



%--- callback menu plot
%-------------------------------------------------------------------------------
function cb_1
p=guidata(gcf);
p.type_n=get(gcbo,'userdata');
% plot type
switch p.type_n
case 1, p.type='enu';
case 2, p.type='2D';
case 3, p.type='rcv_clk';
case 4, p.type='trop';
case 5, p.type='iono';
case 6, p.type='sats';
case 7, p.type='skyp';
case 8, p.type='LCp';
case 9, p.type='OBSp';
case 10, p.type='Resprep';
case 11, p.type='Resposp';
case 12, p.type='Resprepe';
case 13, p.type='Respospe';
case 14, p.type='Resprepa';
case 15, p.type='Respospa';
end
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
switch p.type_n
case {1,2,3,4,5,6,7}
	upplot;
end


%--- callback menu plot option
%-------------------------------------------------------------------------------
function cb_2
p=guidata(gcf);
p.opt.plot=get(gcbo,'userdata');
switch p.type
case {'enu','2D'},
	p.type=p.type;
otherwise, 
	set(p.handles.menu1(p.type_n),'checked','off');
	p.type='enu'; set(p.handles.menu1(1),'checked','on');
end
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu plot range option
%-------------------------------------------------------------------------------
function cb_3
p=guidata(gcf);
switch get(gcbo,'userdata')
case 1,
	prompt = {'X-Range(Min)','X-Range(Max)','X-Range(Span)'};
	dlg_title = 'Input for X-Range';
	num_lines= 1;
	def     = {num2str(p.opt.xrange1),num2str(p.opt.xrange2),num2str(p.opt.xrange3)};
	answer  = inputdlg(prompt,dlg_title,num_lines,def);
	if ~isempty(answer)
		if ~isempty(answer{1})
			p.opt.xrange1=str2num(answer{1});
		end
		if ~isempty(answer{2})
			p.opt.xrange2=str2num(answer{2});
		end
		if ~isempty(answer{3})
			p.opt.xrange3=str2num(answer{3});
		end
	end
case 2,
	prompt = {'Y-Range(Min)','Y-Range(Max)','Y-Range(Span)'};
	dlg_title = 'Input for Y-Range';
	num_lines= 1;
	def     = {num2str(p.opt.yrange1),num2str(p.opt.yrange2),num2str(p.opt.yrange3)};
	answer  = inputdlg(prompt,dlg_title,num_lines,def);
	if ~isempty(answer)
		if ~isempty(answer{1})
			p.opt.yrange1=str2num(answer{1});
		end
		if ~isempty(answer{2})
			p.opt.yrange2=str2num(answer{2});
		end
		if ~isempty(answer{2})
			p.opt.yrange3=str2num(answer{3});
		end
	end
case 3,
	set(gca,'xlimmode','auto');
	set(gca,'xtickmode','auto');
	set(gca,'xticklabelmode','auto'); return;
case 4,
	set(gca,'ylimmode','auto');
	set(gca,'ytickmode','auto');
	set(gca,'yticklabelmode','auto'); return;
end
guidata(gcf,p);
upplot;



%--- callback menu sat
%-------------------------------------------------------------------------------
function cb_4
p=guidata(gcf);
p.type_s=get(gcbo,'userdata');
switch p.type_s
case 1,
	p.opt.sat=unique(p.satprn{1});
	p.opt.sat=p.opt.sat(~isnan(p.opt.sat));
end
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
switch p.type_s
case {1}
	upplot;
end



%--- callback menu station
%-------------------------------------------------------------------------------
function cb_5
p=guidata(gcf);
p.opt.station=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu View stats
%-------------------------------------------------------------------------------
function cb_6
p=guidata(gcf);
p.opt.view_stats=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu LC_mode
%-------------------------------------------------------------------------------
function cb_7
p=guidata(gcf);
p.opt.LC_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu OBS_mode
%-------------------------------------------------------------------------------
function cb_8
p=guidata(gcf);
p.opt.OBS_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu Res_pre_mode
%-------------------------------------------------------------------------------
function cb_9
p=guidata(gcf);
p.opt.Res_pre_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu Res_pos_mode
%-------------------------------------------------------------------------------
function cb_10
p=guidata(gcf);
p.opt.Res_pos_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu Res_pre_e_mode
%-------------------------------------------------------------------------------
function cb_11
p=guidata(gcf);
p.opt.Res_pre_e_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu Res_pos_e_mode
%-------------------------------------------------------------------------------
function cb_12
p=guidata(gcf);
p.opt.Res_pos_e_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu Res_pre_a_mode 
%-------------------------------------------------------------------------------
function cb_13
p=guidata(gcf);
p.opt.Res_pre_a_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu Res_pos_a_mode
%-------------------------------------------------------------------------------
function cb_14
p=guidata(gcf);
p.opt.Res_pos_a_plot=get(gcbo,'userdata');
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- callback menu GPS_prn_mode
%-------------------------------------------------------------------------------
function cb_15
p=guidata(gcf);
switch get(gcbo,'userdata')
case 1,
	p.opt.sat=unique(p.satprn{1});
	p.opt.sat=p.opt.sat(find(p.opt.sat<=32));
otherwise,
	p.opt.sat=sscanf(get(gcbo,'label'),'PRN%d');
	if isempty(p.opt.sat), p.opt.sat=1:32; end
end
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;


%--- callback menu GLONASS_prn_mode
%-------------------------------------------------------------------------------
function cb_16
p=guidata(gcf);
switch get(gcbo,'userdata')
case 1,
	p.opt.sat=unique(p.satprn{1});
	p.opt.sat=p.opt.sat(find(p.opt.sat>=38));
otherwise,
	p.opt.sat=sscanf(get(gcbo,'label'),'PRN%d');
	if isempty(p.opt.sat), p.opt.sat=38:61; end
end
set(get(get(gcbo,'parent'),'children'),'checked','off');
set(gcbo,'checked','on');
guidata(gcf,p);
upplot;



%--- update plot 
%-------------------------------------------------------------------------------
function upplot
p=guidata(gcf);
switch p.type
case 'enu',      plot_enu(p);
case '2D',       plot_2D(p);
case 'rcv_clk',  plot_rcvclk(p);
case 'trop',     plot_trop(p);
case 'iono',     plot_iono(p);
case 'sats',     plot_sats(p);
case 'skyp',     plot_sky(p);
case 'LCp',      plot_LC(p);
case 'OBSp',     plot_OBS(p);
case 'Resprep',  plot_Res_pre(p);
case 'Resposp',  plot_Res_pos(p);
case 'Resprepe', plot_Res_pre_e(p);
case 'Respospe', plot_Res_pos_e(p);
case 'Resprepa', plot_Res_pre_a(p);
case 'Respospa', plot_Res_pos_a(p);
end
switch p.type_n
case {1,2,3,4,5,6,7}
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 8
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 9
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 10
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 11
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 12
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 13
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu13,'checked','off');
	set(p.handles.menu14,'checked','off');
case 14
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu14,'checked','off');
case 15
	set(p.handles.menu7,'checked','off');
	set(p.handles.menu8,'checked','off');
	set(p.handles.menu9,'checked','off');
	set(p.handles.menu10,'checked','off');
	set(p.handles.menu11,'checked','off');
	set(p.handles.menu12,'checked','off');
	set(p.handles.menu13,'checked','off');
end
switch p.type_s
case 1
	set(p.handles.menu15,'checked','off');
	set(p.handles.menu16,'checked','off');
case 2
	set(p.handles.menu4,'checked','off');
	set(p.handles.menu16,'checked','off');
case 3
	set(p.handles.menu4,'checked','off');
	set(p.handles.menu15,'checked','off');
end
guidata(gcf,p);



%--- 事前残差プロット
%-------------------------------------------------------------------------------
function plot_Res_pre(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
Res=[];
if ~isempty(p.Res)
	switch p.opt.Res_pre_plot
	case 1,
		Res=p.Res.pre;
	case 2,
		Res=p.Res.pre;
	case 3,
		Res=p.Res.pre;
	case 4,
		Res=p.Res.pre;
	end
end
if ~isempty(Res)
	for k=1:size(Res,2)
		h=plot(p.esttime(:,4),Res{p.opt.Res_pre_plot,k}(:,p.opt.sat),'.-');		% 事前残差プロット
	end
	ylabel(yls{p.opt.Res_pre_plot});									% ylabel
end
xlabel('ToD [sec.]');													% xlabel
title(['Residual(pre-fit)',' : ',TT]);									% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- 事後残差プロット
%-------------------------------------------------------------------------------
function plot_Res_pos(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
Res=[];
if ~isempty(p.Res)
	switch p.opt.Res_pos_plot
	case 1,
		Res=p.Res.post;
	case 2,
		Res=p.Res.post;
	case 3,
		Res=p.Res.post;
	case 4,
		Res=p.Res.post;
	end
end
if ~isempty(Res)
	for k=1:size(Res,2)
		h=plot(p.esttime(:,4),Res{p.opt.Res_pos_plot,k}(:,p.opt.sat),'.-');		% 事前残差プロット
	end
	ylabel(yls{p.opt.Res_pos_plot});											% ylabel
end
xlabel('ToD [sec.]');															% xlabel
title(['Residual(post-fit)',' : ',TT]);											% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');




%--- 事前残差プロット(仰角との関係)
%-------------------------------------------------------------------------------
function plot_Res_pre_e(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[0:10:90];															% xtick
xl={0:10:90};															% xticklabel
xlm=[0,90];																% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
Res=[];
if ~isempty(p.Res)
	switch p.opt.Res_pre_e_plot
	case 1,
		Res=p.Res.pre;
	case 2,
		Res=p.Res.pre;
	case 3,
		Res=p.Res.pre;
	case 4,
		Res=p.Res.pre;
	end
end
if ~isempty(Res)
	for k=1:size(Res,2)
		h=plot(p.obs_rov.ele(:,p.opt.sat)*180/pi,...
				Res{p.opt.Res_pre_e_plot,k}(:,p.opt.sat),'.');			% 事前残差プロット
	end
	ylabel(yls{p.opt.Res_pre_e_plot});									% ylabel
end
xlabel('Elevation [deg.]');												% xlabel
title(['Residual(pre-fit)',' : ',TT]);									% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- 事後残差プロット(仰角との関係)
%-------------------------------------------------------------------------------
function plot_Res_pos_e(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[0:10:90];															% xtick
xl={0:10:90};															% xticklabel
xlm=[0,90];																% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
Res=[];
if ~isempty(p.Res)
	switch p.opt.Res_pos_e_plot
	case 1,
		Res=p.Res.post;
	case 2,
		Res=p.Res.post;
	case 3,
		Res=p.Res.post;
	case 4,
		Res=p.Res.post;
	end
end
if ~isempty(Res)
	for k=1:size(Res,2)
		h=plot(p.obs_rov.ele(:,p.opt.sat)*180/pi,...
				Res{p.opt.Res_pos_e_plot,k}(:,p.opt.sat),'.');			% 事前残差プロット
	end
	ylabel(yls{p.opt.Res_pos_e_plot});									% ylabel
end
xlabel('Elevation [deg.]');												% xlabel
title(['Residual(post-fit)',' : ',TT]);									% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- 事前残差プロット(方位角との関係)
%-------------------------------------------------------------------------------
function plot_Res_pre_a(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[-180:30:180];														% xtick
xl={-180:30:180};														% xticklabel
xlm=[-180,180];															% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
Res=[];
if ~isempty(p.Res)
	switch p.opt.Res_pre_a_plot
	case 1,
		Res=p.Res.pre;
	case 2,
		Res=p.Res.pre;
	case 3,
		Res=p.Res.pre;
	case 4,
		Res=p.Res.pre;
	end
end
if ~isempty(Res)
	for k=1:size(Res,2)
		h=plot(p.obs_rov.azi(:,p.opt.sat)*180/pi,...
				Res{p.opt.Res_pre_a_plot,k}(:,p.opt.sat),'.');			% 事前残差プロット
	end
	ylabel(yls{p.opt.Res_pre_a_plot});									% ylabel
end
xlabel('Azimuth [deg.]');												% xlabel
title(['Residual(pre-fit)',' : ',TT]);									% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- 事後残差プロット(方位角との関係)
%-------------------------------------------------------------------------------
function plot_Res_pos_a(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[-180:30:180];														% xtick
xl={-180:30:180};														% xticklabel
xlm=[-180,180];															% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
Res=[];
if ~isempty(p.Res)
	switch p.opt.Res_pos_a_plot
	case 1,
		Res=p.Res.post;
	case 2,
		Res=p.Res.post;
	case 3,
		Res=p.Res.post;
	case 4,
		Res=p.Res.post;
	end
end
if ~isempty(Res)
	for k=1:size(Res,2)
		h=plot(p.obs_rov.azi(:,p.opt.sat)*180/pi,...
				Res{p.opt.Res_pos_a_plot,k}(:,p.opt.sat),'.');				% 事前残差プロット
	end
	ylabel(yls{p.opt.Res_pos_a_plot});										% ylabel
end
xlabel('Azimuth [deg.]');													% xlabel
title(['Residual(post-fit)',' : ',TT]);										% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- 線形結合プロット
%-------------------------------------------------------------------------------
function plot_LC(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'MP1 [m]','MP2 [m]','MW [m]','LGL [m]','LGP [m]','LG1 [m]','LG2 [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
LC=[];
switch p.opt.LC_plot
case 1,
	switch p.opt.station
	case 1, LC=p.LC_rov.mp1;
	case 2, LC=p.LC_ref.mp1;
	end
case 2,
	switch p.opt.station
	case 1, LC=p.LC_rov.mp2;
	case 2, LC=p.LC_ref.mp2;
	end
case 3,
	switch p.opt.station
	case 1, LC=p.LC_rov.mw;
	case 2, LC=p.LC_ref.mw;
	end
case 4,
	switch p.opt.station
	case 1, LC=p.LC_rov.lgl;
	case 2, LC=p.LC_ref.lgl;
	end
case 5,
	switch p.opt.station
	case 1, LC=p.LC_rov.lgp;
	case 2, LC=p.LC_ref.lgp;
	end
case 6,
	switch p.opt.station
	case 1, LC=p.LC_rov.lg1;
	case 2, LC=p.LC_ref.lg1;
	end
case 7,
	switch p.opt.station
	case 1, LC=p.LC_rov.lg2;
	case 2, LC=p.LC_ref.lg2;
	end
end
if ~isempty(LC)
	h=plot(p.esttime(2:end,4),diff(LC(:,p.opt.sat)),'.-');				% 線形結合プロット
	ylabel(yls{p.opt.LC_plot});											% ylabel
end
xlabel('ToD [sec.]');													% xlabel
title(['Linear Combination',' : ',TT]);									% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- 観測データプロット
%-------------------------------------------------------------------------------
function plot_OBS(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
yls={'L1 [m]','L2 [m]','CA [m]','PY [m]',...
		'L1(cor) [m]','L2(cor) [m]','CA(cor) [m]','PY(cor) [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[-3:0.5:3];															% ytick
yl={-3:0.5:3};															% yticklabel
ylm=[-3,3];																% ylim
xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
% plot([0,86400],[0,0],'k');											% yzero line
% ここにプロットを挿入
OBS=[];
switch p.opt.OBS_plot
case 1,
	switch p.opt.station
	case 1, OBS=p.obs_rov.ph1;
	case 2, OBS=p.obs_ref.ph1;
	end
case 2,
	switch p.opt.station
	case 1, OBS=p.obs_rov.ph2;
	case 2, OBS=p.obs_ref.ph2;
	end
case 3,
	switch p.opt.station
	case 1, OBS=p.obs_rov.ca;
	case 2, OBS=p.obs_ref.ca;
	end
case 4,
	switch p.opt.station
	case 1, OBS=p.obs_rov.py;
	case 2, OBS=p.obs_ref.py;
	end
case 5,
	switch p.opt.station
	case 1, OBS=p.obs_rov.ph1_cor;
	case 2, OBS=p.obs_ref.ph1_cor;
	end
case 6,
	switch p.opt.station
	case 1, OBS=p.obs_rov.ph2_cor;
	case 2, OBS=p.obs_ref.ph2_cor;
	end
case 7,
	switch p.opt.station
	case 1, OBS=p.obs_rov.ca_cor;
	case 2, OBS=p.obs_ref.ca_cor;
	end
case 8,
	switch p.opt.station
	case 1, OBS=p.obs_rov.py_cor;
	case 2, OBS=p.obs_ref.py_cor;
	end
end
if ~isempty(OBS)
	h=plot(p.esttime(:,4),OBS(:,p.opt.sat),'.-');						% 観測データプロット
	ylabel(yls{p.opt.OBS_plot});										% ylabel
end
xlabel('ToD [sec.]');													% xlabel
title(['Observation',' : ',TT]);										% title
ylim('auto');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');



%--- ENUプロット
%-------------------------------------------------------------------------------
function plot_enu(p,yli,tspn)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
if ~isempty(p.enu_fix)
	index_float=find(isnan(p.enu_fix(:,1)));
	index_fix=find(~isnan(p.enu_fix(:,1)));
end

clf;
yls={'East error [m]','North error [m]','Up error [m]'};
np=3;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[p.opt.yrange1:p.opt.yrange3:p.opt.yrange2];							% ytick
yl={p.opt.yrange1:p.opt.yrange3:p.opt.yrange2};							% yticklabel
ylm=[p.opt.yrange1,p.opt.yrange2];										% ylim
for nn=1:3
	if nn<3
		xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];					% xtick
		xl={};															% xticklabel
		xlm=[p.opt.xrange1,p.opt.xrange2];								% xlim
	else
		xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];					% xtick
		xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};					% xticklabel
		xlm=[p.opt.xrange1,p.opt.xrange2];								% xlim
	end
	ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);						% New axes
	plot([0,86400],[0,0],'k');											% yzero line
	% ここにプロットを挿入
	switch p.opt.plot
	case 1,
		if ~isempty(p.enu_mix)
			h1=plot(p.esttime(:,4),p.enu_mix(:,nn),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
			h2=plot(p.esttime(index_float,4),p.enu_mix(index_float,nn),'.r');										% Float解の点プロット
			h3=plot(p.esttime(index_fix,4),p.enu_mix(index_fix,nn),'.b');											% Fix解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin6(nn),p.stdd6(nn),p.rms6(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				fix_rate=length(find(~isnan(p.enu_fix(:,1))))/length(p.enu_fix)*100;								% Fix率
				baseline=norm(p.rovpos-p.refpos)/1e+3;																% 基線長
				title(['Position Error - Relative',' : ',TT]);
% 					sprintf('  BL: %5.1f[km]',baseline),...
% 					sprintf('  Fix rate: %3.1f[%%]',fix_rate)]);													% タイトル
				if ~isempty(h3)
					if ~isempty(h2)
						hl=legend([h2,h3],{'Float','Fix'},'Orientation','horizontal');								% 凡例
						lines = findobj(get(hl,'children'),'type','line');
						set(lines(3),'markersize',15);
						set(lines(1),'markersize',15);
					else
						hl=legend([h3],{'Fix'},'Orientation','horizontal');											% 凡例
						lines = findobj(get(hl,'children'),'type','line');
						set(lines(1),'markersize',15);
					end
				else
					hl=legend([h2],{'Float'},'Orientation','horizontal');											% 凡例
					lines = findobj(get(hl,'children'),'type','line');
					set(lines(1),'markersize',15);
				end
				text(0.015,0.95,...
					[sprintf('Rov: %s  Ref: %s',p.rcv{:}),...
					sprintf('  BL: %5.1f[km]',baseline),...
					sprintf('  Fix rate: %3.1f[%%]',fix_rate)],...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	case 2,
		if ~isempty(p.enu_spp)
			h1=plot(p.esttime(:,4),p.enu_spp(:,nn),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
			h2=plot(p.esttime(:,4),p.enu_spp(:,nn),'.r');															% SPP解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin0(nn),p.stdd0(nn),p.rms0(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				title(['Position Error - SPP',' : ',TT])
				text(0.015,0.95,...
					sprintf('Rov: %s',p.rcv{1}),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	case 3,
		if ~isempty(p.enu_ppp)
			h1=plot(p.esttime(:,4),p.enu_ppp(:,nn),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
			h2=plot(p.esttime(:,4),p.enu_ppp(:,nn),'.r');															% PPP解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin1(nn),p.stdd1(nn),p.rms1(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				title(['Position Error - PPP',' : ',TT])
				text(0.015,0.95,...
					sprintf('Rov: %s',p.rcv{1}),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	case 4,
		if ~isempty(p.enu_vppp)
			h1=plot(p.esttime(:,4),p.enu_vppp(:,nn),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
			h2=plot(p.esttime(:,4),p.enu_vppp(:,nn),'.r');															% VPPP解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin2(nn),p.stdd2(nn),p.rms2(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				title(['Position Error - VPPP',' : ',TT])
				text(0.015,0.95,...
					sprintf('Rov: %s',p.rcv{1}),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	case 5,
		if ~isempty(p.enu_dgps)
			h1=plot(p.esttime(:,4),p.enu_dgps(:,nn),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
			h2=plot(p.esttime(:,4),p.enu_dgps(:,nn),'.r');															% DGPS解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin3(nn),p.stdd3(nn),p.rms3(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				baseline=norm(p.rovpos-p.refpos)/1e+3;																% 基線長
				title(['Position Error - DGPS',' : ',TT])
				text(0.015,0.95,...
					[sprintf('Rov: %s  Ref: %s',p.rcv{:}),...
					sprintf('  BL: %5.1f[km]',baseline)],...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	case 6,
		if ~isempty(p.enu_float)
			h1=plot(p.esttime(:,4),p.enu_float(:,nn),'-','Color',[0.5,0.5,0.5]);									% ラインプロット
			h2=plot(p.esttime(:,4),p.enu_float(:,nn),'.r');															% Float解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin4(nn),p.stdd4(nn),p.rms4(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				baseline=norm(p.rovpos-p.refpos)/1e+3;																% 基線長
				title(['Position Error - Float',' : ',TT])
				text(0.015,0.95,...
					[sprintf('Rov: %s  Ref: %s',p.rcv{:}),...
					sprintf('  BL: %5.1f[km]',baseline)],...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	case 7,
		if ~isempty(p.enu_fix)
			h1=plot(p.esttime(:,4),p.enu_fix(:,nn),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
			h2=plot(p.esttime(:,4),p.enu_fix(:,nn),'.r');															% Fix解の点プロット
			if p.opt.view_stats==1
				text(0.985,0.06,...
					sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',p.heikin5(nn),p.stdd5(nn),p.rms5(nn)),...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
			end
			if nn==1
				baseline=norm(p.rovpos-p.refpos)/1e+3;																% 基線長
				title(['Position Error - Fix',' : ',TT])
				text(0.015,0.95,...
					[sprintf('Rov: %s  Ref: %s',p.rcv{:}),...
					sprintf('  BL: %5.1f[km]',baseline)],...
						'FontName','times','FontSize',14,'FontWeight','normal',...
						'BackgroundColor','w','Color','k',...
						'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');				% 局番号などの表示
			end
		end
	end
	ylabel(yls{nn});													% ylabel
	if nn==3, xlabel('ToD [sec.]');, end								% xlabel
% 	if nn==1, title('Position error');, end								% title
end



%--- 2D+Uプロット
%-------------------------------------------------------------------------------
function plot_2D(p,yli,tspn)
%--- axes(Up)
%--------------------------------------------
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
if ~isempty(p.enu_fix)
	index_float=find(isnan(p.enu_fix(:,1)));
	index_fix=find(~isnan(p.enu_fix(:,1)));
end

clf;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
h=(1-2*margin(3))-2*margin(4);
pos=[0.7,margin(3)+2*margin(4),0.2,h];
xt=0;																	% xtick
xl={};																	% xticklabel
xlm=[-1,1];																% xlim
yt=[p.opt.yrange1:p.opt.yrange3:p.opt.yrange2];							% ytick
yl={p.opt.yrange1:p.opt.yrange3:p.opt.yrange2};							% yticklabel
ylm=[p.opt.yrange1,p.opt.yrange2];										% ylim
ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
set(ax,'yaxislocation','right');										% yaxis(right)
plot([-1,1],[0,0],'k');													% yzero line
plot(0,0,'k.','markersize',10);											% zero point
% ここにプロットを挿入
switch p.opt.plot
case 1,
	if ~isempty(p.enu_mix)
		plot(index_float*0,p.enu_mix(index_float,3),'.r');				% Float解の点プロット
		plot(index_fix*0,p.enu_mix(index_fix,3),'.b');					% Fix解の点プロット
	end
case 2,
	if ~isempty(p.enu_spp)
		plot(0,p.enu_spp(:,3),'.r');									% SPP解の点プロット
	end
case 3,
	if ~isempty(p.enu_ppp)
		plot(0,p.enu_ppp(:,3),'.r');									% PPP解の点プロット
	end
case 4,
	if ~isempty(p.enu_vppp)
		plot(0,p.enu_vppp(:,3),'.r');									% VPPP解の点プロット
	end
case 5,
	if ~isempty(p.enu_dgps)
		plot(0,p.enu_dgps(:,3),'.r');									% DGPS解の点プロット
	end
case 6,
	if ~isempty(p.enu_float)
		plot(0,p.enu_float(:,3),'.r');									% Float解の点プロット
	end
case 7,
	if ~isempty(p.enu_fix)
		plot(0,p.enu_fix(:,3),'.r');									% Fix解の点プロット
	end
end
ylabel('Up error [m]');													% ylabel

%--- axes(Horizontal)
%--------------------------------------------
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
h=(1-2*margin(3))-2*margin(4);
pos=[0,margin(3)+2*margin(4),0.75,h];
xt=[p.opt.yrange1:p.opt.yrange3:p.opt.yrange2];							% xtick
xl={p.opt.yrange1:p.opt.yrange3:p.opt.yrange2};							% xticklabel
xlm=[p.opt.yrange1,p.opt.yrange2];										% xlim
yt=[p.opt.yrange1:p.opt.yrange3:p.opt.yrange2];							% ytick
yl={p.opt.yrange1:p.opt.yrange3:p.opt.yrange2};							% yticklabel
ylm=[p.opt.yrange1,p.opt.yrange2];										% ylim
ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
axis square																% axis(square)
plot([-100,100],[0,0],'k');												% yzero line
plot([0,0],[-100,100],'k');												% xzero line
plot(0,0,'k.','markersize',10);											% zero point
% ここにプロットを挿入
switch p.opt.plot
case 1,
	if ~isempty(p.enu_mix)
		h4=plot(p.enu_mix(:,1),p.enu_mix(:,2),'-','Color',[0.5,0.5,0.5]);			% ラインプロット
		h5=plot(p.enu_mix(index_float,1),p.enu_mix(index_float,2),'.r');			% Float解の点プロット
		h6=plot(p.enu_mix(index_fix,1),p.enu_mix(index_fix,2),'.b');				% Fix解の点プロット
		if ~isempty(h6)
			if ~isempty(h5)
				hl=legend([h5,h6],{'Float','Fix'},'Orientation','horizontal');			% 凡例
				lines = findobj(get(hl,'children'),'type','line');
				set(lines(3),'markersize',15);
				set(lines(1),'markersize',15);
			else
				hl=legend([h6],{'Fix'},'Orientation','horizontal');			% 凡例
				lines = findobj(get(hl,'children'),'type','line');
				set(lines(1),'markersize',15);
			end
		else
			hl=legend([h5],{'Float'},'Orientation','horizontal');					% 凡例
			lines = findobj(get(hl,'children'),'type','line');
			set(lines(1),'markersize',15);
		end
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin6(4),p.stdd6(4),p.rms6(4)),...
					'FontName','times','FontSize',14,'FontWeight','normal',...
					'BackgroundColor','w','Color','k',...
					'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
		end
		fix_rate=length(find(~isnan(p.enu_fix(:,1))))/length(p.enu_fix)*100;									% Fix率
		baseline=norm(p.rovpos-p.refpos)/1e+3;																	% 基線長
		title(['Position Error - Relative',' : ',TT]);
		text(0.03,0.98,...
			sprintf('Rov: %s\nRef: %s\nBL: %5.1f[km]\nFix rate: %3.1f[%%]',p.rcv{:},baseline,fix_rate),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
case 2,
	if ~isempty(p.enu_spp)
		h4=plot(p.enu_spp(:,1),p.enu_spp(:,2),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
		h5=plot(p.enu_spp(:,1),p.enu_spp(:,2),'.r');															% SPP解の点プロット
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin0(4),p.stdd0(4),p.rms0(4)),...
					'FontName','times','FontSize',14,'FontWeight','normal',...
					'BackgroundColor','w','Color','k',...
					'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
		end
		title(['Position Error - SPP',' : ',TT])
		text(0.03,0.98,...
			sprintf('Rov: %s',p.rcv{1}),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
case 3,
	if ~isempty(p.enu_ppp)
		h4=plot(p.enu_ppp(:,1),p.enu_ppp(:,2),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
		h5=plot(p.enu_ppp(:,1),p.enu_ppp(:,2),'.r');															% PPP解の点プロット
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin1(4),p.stdd1(4),p.rms1(4)),...
					'FontName','times','FontSize',14,'FontWeight','normal',...
					'BackgroundColor','w','Color','k',...
					'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
		end
		title(['Position Error - PPP',' : ',TT])
		text(0.03,0.98,...
			sprintf('Rov: %s',p.rcv{1}),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
case 4,
	if ~isempty(p.enu_vppp)
		h4=plot(p.enu_vppp(:,1),p.enu_vppp(:,2),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
		h5=plot(p.enu_vppp(:,1),p.enu_vppp(:,2),'.r');															% VPPP解の点プロット
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin2(4),p.stdd2(4),p.rms2(4)),...
				'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
				'Color','k','HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');	% 平均, 標準偏差, RMS
		end
		title(['Position Error - VPPP',' : ',TT])
		text(0.03,0.98,...
			sprintf('Rov: %s',p.rcv{1}),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
case 5,
	if ~isempty(p.enu_dgps)
		h4=plot(p.enu_dgps(:,1),p.enu_dgps(:,2),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
		h5=plot(p.enu_dgps(:,1),p.enu_dgps(:,2),'.r');															% DGPS解の点プロット
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin3(4),p.stdd3(4),p.rms3(4)),...
					'FontName','times','FontSize',14,'FontWeight','normal',...
					'BackgroundColor','w','Color','k',...
					'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
		end
		baseline=norm(p.rovpos-p.refpos)/1e+3;																	% 基線長
		title(['Position Error - DGPS',' : ',TT])
		text(0.03,0.98,...
			sprintf('Rov: %s\nRef: %s\nBL: %5.1f[km]',p.rcv{:},baseline),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
case 6,
	if ~isempty(p.enu_float)
		h4=plot(p.enu_float(:,1),p.enu_float(:,2),'-','Color',[0.5,0.5,0.5]);									% ラインプロット
		h5=plot(p.enu_float(:,1),p.enu_float(:,2),'.r');														% Float解の点プロット
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin4(4),p.stdd4(4),p.rms4(4)),...
					'FontName','times','FontSize',14,'FontWeight','normal',...
					'BackgroundColor','w','Color','k',...
					'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
		end
		baseline=norm(p.rovpos-p.refpos)/1e+3;																	% 基線長
		title(['Position Error - Float',' : ',TT])
		text(0.03,0.98,...
			sprintf('Rov: %s\nRef: %s\nBL: %5.1f[km]',p.rcv{:},baseline),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
case 7,
	if ~isempty(p.enu_fix)
		h4=plot(p.enu_fix(:,1),p.enu_fix(:,2),'-','Color',[0.5,0.5,0.5]);										% ラインプロット
		h5=plot(p.enu_fix(:,1),p.enu_fix(:,2),'.r');															% Fix解の点プロット
		if p.opt.view_stats==1
			text(0.975,0.025,...
				sprintf('MEAN:%7.4f[m]\nSTD:%7.4f[m]\nRMS:%7.4f[m]',p.heikin5(4),p.stdd65(4),p.rms5(4)),...
					'FontName','times','FontSize',14,'FontWeight','normal',...
					'BackgroundColor','w','Color','k',...
					'HorizontalAlignment','right','VerticalAlignment','bottom','units','normalized');			% 平均, 標準偏差, RMS
		end
		baseline=norm(p.rovpos-p.refpos)/1e+3;																	% 基線長
		title(['Position Error - Fix',' : ',TT])
		text(0.03,0.98,...
			sprintf('Rov: %s\nRef: %s\nBL: %5.1f[km]',p.rcv{:},baseline),...
				'FontName','times','FontSize',14,'FontWeight','normal',...
				'BackgroundColor','w','Color','k',...
				'HorizontalAlignment','left','VerticalAlignment','top','units','normalized');					% 局番号などの表示
	end
end
xlabel('East error [m]');												% xlabel
ylabel('North error [m]');												% ylabel
% title('Position error');												% titke



%--- 受信機時計誤差プロット
%-------------------------------------------------------------------------------
function plot_rcvclk(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
ys1=-1; ye1=1; yspn1=0.2;
ys2=-1; ye2=1; yspn2=0.2;
if ~isempty(p.dtr)
	ys1=floor(min(min(p.dtr(:,1))));
	ye1=ceil(max(max(p.dtr(:,1))));
	yspn1=floor((ye1-ys1)/10);
	if size(p.dtr,2)==2
		ys2=floor(min(min(p.dtr(:,2))));
		ye2=ceil(max(max(p.dtr(:,2))));
		yspn2=floor((ye2-ys2)/10);
	end
end

clf;
yls={'Receiver clock bias [m]','Receiver clock drift [m]'};
np=size(p.dtr,2);
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
for nn=1:size(p.dtr,2)
	if size(p.dtr,2)==1
		xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];					% xtick
		xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};					% xticklabel
		xlm=[p.opt.xrange1,p.opt.xrange2];								% xlim
		yt=[ys1:yspn1:ye1];												% ytick
		yl={ys1:yspn1:ye1};												% yticklabel
		ylm=[ys1,ye1];													% ylim
	else
		if nn<2
			xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];				% xtick
			xl={};														% xticklabel
			xlm=[p.opt.xrange1,p.opt.xrange2];							% xlim
			yt=[ys1:yspn1:ye1];											% ytick
			yl={ys1:yspn1:ye1};											% yticklabel
			ylm=[ys1,ye1];												% ylim
		else
			xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];				% xtick
			xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};				% xticklabel
			xlm=[p.opt.xrange1,p.opt.xrange2];							% xlim
			yt=[ys2:yspn2:ye2];											% ytick
			yl={ys2:yspn2:ye2};											% yticklabel
			ylm=[ys2,ye2];												% ylim
		end
	end
	ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);						% New axes
	plot([0,86400],[0,0],'k');											% yzero line

	% ここにプロットを挿入
	if ~isempty(p.dtr_vppp)
		if nn==1
		h=plot(p.esttime(:,4),p.dtr_vppp(:,nn),'b.-');					% SPP1解プロット
		h=plot(p.esttime(:,4),p.dtr_vppp(:,nn+1),'r.-');				% SPP2解プロット
		else
		h=plot(p.esttime(:,4),p.dtr_vppp(:,nn+1),'b.-');				% VPPP解プロット
		h=plot(p.esttime(:,4),p.dtr_vppp(:,nn+2),'r.-');				% VPPP解プロット
		end	
	else
		h=plot(p.esttime(:,4),p.dtr(:,nn),'.-');						% Fix解の点プロット
	end

	ylabel(yls{nn});													% ylabel
	if nn==2, xlabel('ToD [sec.]');, end								% xlabel
	if nn==1, title(['Receiver clock error',' : ',TT]);, end			% title
	ylim('auto');
	set(gca,'ytickmode','auto');
	set(gca,'yticklabelmode','auto');
end


%--- 対流圏遅延プロット
%-------------------------------------------------------------------------------
function plot_trop(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
ys=-1; ye=1; yspn=0.2;
if ~isempty(p.dtrop)
	ys=floor(min(min(p.dtrop))/0.05)*0.05;
	ye=ceil(max(max(p.dtrop))/0.05)*0.05;
	yspn=0.05;
end
clf;
yls={'Tropospheric delay [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[ys:yspn:ye];														% ytick
yl={ys:yspn:ye};														% yticklabel
ylm=[ys,ye];															% ylim
xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
plot([0,86400],[0,0],'k');												% yzero line
% ここにプロットを挿入
if ~isempty(p.dtrop)
	h=plot(p.esttime(:,4),p.dtrop,'.-');								% Fix解の点プロット
end
ylabel(yls{nn});														% ylabel
xlabel('ToD [sec.]');													% xlabel
title(['Tropospheric delay',' : ',TT]);									% title



%--- 電離層遅延プロット
%-------------------------------------------------------------------------------
function plot_iono(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
ys=-1; ye=1; yspn=0.2;
if ~isempty(p.dion)
	if size(p.dion,2)~=32
		ys=floor(min(min(p.dion(:,1)))/0.05)*0.05;
		ye=ceil(max(max(p.dion(:,1)))/0.05)*0.05;
		yspn=0.5;
	end
end
clf;
yls={'Ionospheric delay [m]'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
yt=[ys:yspn:ye];														% ytick
yl={ys:yspn:ye};														% yticklabel
ylm=[ys,ye];															% ylim
xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm);							% New axes
plot([0,86400],[0,0],'k');												% yzero line
% ここにプロットを挿入
if ~isempty(p.dion)
	if size(p.dion,2)==32
		h=plot(p.esttime(:,4),p.dion(:,p.opt.sat),'.-');				% Fix解の点プロット
	else
		h=plot(p.esttime(:,4),p.dion(:,1),'.-');						% Fix解の点プロット
	end
end
ylabel(yls{nn});														% ylabel
xlabel('ToD [sec.]');													% xlabel
title(['Ionospheric delay',' : ',TT]);									% title



%--- 衛星関連プロット(衛星数, 衛星PRN)
%-------------------------------------------------------------------------------
function plot_sats(p)
if ~isempty(p.opt.sat)
	if find(p.opt.sat<=32)
		if find(p.opt.sat>=38)
			%- axes(Satellite PRN)
			%--------------------------------------------
			TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
				datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
			clf;
			yls={'Satellite PRN'};
			nn=3;np=3;
			margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
			h=(1-2*margin(3))/np;
			pos=[margin(1),...
				(np-nn)*h+margin(3)+2*margin(4),...
				1-margin(1)-margin(2),...
				3*h-2*margin(4)];													% [left,bottom,width,height]
			yt=[p.opt.sat];															% ytick
			yl={p.opt.sat};															% yticklabel
			ylm=[0.5,61.5];															% ylim(ALL)
			xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
			xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
			xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
			ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
			set(ax,'ygrid','off','ydir','reverse','ticklength',[0,0]);				% ygrid(off), ydir(reverse), ticklength(0)
			for k=1:61
				plot([0,86400],[k,k]+0.5,'k:');										% ygrid line(manual)
			end
			% ここにプロットを挿入
			% h1=plot(p.satprn{3}(:,1),p.satprn{1}(:,p.opt.sat),...
			% 		'LineWidth',4,'color','b');										% 可視衛星PRNのプロット
			h1=plot(p.satprn{3}(:,1),p.satprn{1}(:,p.opt.sat),...
					'LineWidth',4,'color','r');										% 可視衛星PRNのプロット
			h2=plot(p.satprn{3}(:,1),p.satprn{2}(:,p.opt.sat),...
					'LineWidth',4,'color','b');										% 使用衛星PRNのプロット
			if size(p.satprn,2)==4
				h3=plot(p.satprn{3}(:,1),p.satprn{4}(:,p.opt.sat),...
						'LineWidth',4,'color',[0,0.5,0]);							% 基準衛星PRNのプロット
			end
			ylabel(yls);															% ylabel
			xlabel('ToD [sec.]');													% xlabel
			title(['Satellite',' : ',TT]);											% title

		else
			%- axes(Satellite Number)
			%--------------------------------------------
			TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
				datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
			clf;
			yls={'No. of Satellite','Satellite PRN'};
			nn=1;np=4;
			margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
			h=(1-2*margin(3))/np;
			pos=[margin(1),...
				(np-nn)*h+margin(3)+2*margin(4),...
				1-margin(1)-margin(2),...
				h-2*margin(4)];														% [left,bottom,width,height]
			yt=[0:4:20];															% ytick
			yl={0:4:20};															% yticklabel
			ylm=[0,20];																% ylim
			xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
			xl={};																	% xticklabel
			xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
			ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
			% ここにプロットを挿入
			plot(p.satprn{3}(:,1),p.satprn{3}(:,3),'color','r','linewidth',1);		% 可視衛星数のプロット(GPS)(相対測位なら使用衛星プロット)
			plot(p.satprn{3}(:,1),p.satprn{3}(:,2),'color','b','linewidth',1);		% 可視衛星数のプロット(ALL)
			ylabel('No. of Satellite');												% ylabel
			title(['Satellite',' : ',TT]);											% title

			%- axes(Satellite PRN)
			%--------------------------------------------
			nn=4;np=4;
			margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
			h=(1-2*margin(3))/np;
			pos=[margin(1),...
				(np-nn)*h+margin(3)+2*margin(4),...
				1-margin(1)-margin(2),...
				3*h-2*margin(4)];													% [left,bottom,width,height]
			yt=[p.opt.sat];															% ytick
			yl={p.opt.sat};															% yticklabel
			ylm=[0.5,32.5];															% ylim(GPS)
			xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
			xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
			xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
			ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
			set(ax,'ygrid','off','ydir','reverse','ticklength',[0,0]);				% ygrid(off), ydir(reverse), ticklength(0)
			for k=1:61
				plot([0,86400],[k,k]+0.5,'k:');										% ygrid line(manual)
			end
			% ここにプロットを挿入
			% h1=plot(p.satprn{3}(:,1),p.satprn{1}(:,p.opt.sat),...
			% 		'LineWidth',4,'color','b');										% 可視衛星PRNのプロット
			h1=plot(p.satprn{3}(:,1),p.satprn{1}(:,p.opt.sat),...
					'LineWidth',4,'color','r');										% 可視衛星PRNのプロット(GPS)
			h2=plot(p.satprn{3}(:,1),p.satprn{2}(:,p.opt.sat),...
					'LineWidth',4,'color','b');										% 使用衛星PRNのプロット(GPS)
			if size(p.satprn,2)==4
				h3=plot(p.satprn{3}(:,1),p.satprn{4}(:,p.opt.sat),...
						'LineWidth',4,'color',[0,0.5,0]);							% 基準衛星PRNのプロット(GPS)
			end
			ylabel('Satellite PRN');												% ylabel
			xlabel('ToD [sec.]');													% xlabel
		end
	else
		%- axes(Satellite Number)
		%--------------------------------------------
		TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
			datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
		clf;
		yls={'No. of Satellite','Satellite PRN'};
		nn=1;np=4;
		margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
		h=(1-2*margin(3))/np;
		pos=[margin(1),...
			(np-nn)*h+margin(3)+2*margin(4),...
			1-margin(1)-margin(2),...
			h-2*margin(4)];														% [left,bottom,width,height]
		yt=[0:4:20];															% ytick
		yl={0:4:20};															% yticklabel
		ylm=[0,20];																% ylim
		xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
		xl={};																	% xticklabel
		xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
		ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
		% ここにプロットを挿入
		if find(p.opt.sat<=32)
			plot(p.satprn{3}(:,1),p.satprn{3}(:,3),'color','r','linewidth',1);	% 可視衛星数のプロット(GPS)(相対測位なら使用衛星プロット)
		end
		if find(p.opt.sat>=38)
			plot(p.satprn{3}(:,1),p.satprn{3}(:,4),'color','g','linewidth',1);	% 可視衛星数のプロット(GLONASS)
		end
		plot(p.satprn{3}(:,1),p.satprn{3}(:,2),'color','b','linewidth',1);		% 可視衛星数のプロット(ALL)
		ylabel('No. of Satellite');												% ylabel
		title(['Satellite',' : ',TT]);											% title

		%- axes(Satellite PRN)
		%--------------------------------------------
		nn=4;np=4;
		margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
		h=(1-2*margin(3))/np;
		pos=[margin(1),...
			(np-nn)*h+margin(3)+2*margin(4),...
			1-margin(1)-margin(2),...
			3*h-2*margin(4)];													% [left,bottom,width,height]
		yt=[p.opt.sat];															% ytick
		yl={p.opt.sat};															% yticklabel
		ylm=[38.5,61.5];														% ylim(GLONASS)
		xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];							% xtick
		xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};							% xticklabel
		xlm=[p.opt.xrange1,p.opt.xrange2];										% xlim
		ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
		set(ax,'ygrid','off','ydir','reverse','ticklength',[0,0]);				% ygrid(off), ydir(reverse), ticklength(0)
		for k=1:61
			plot([0,86400],[k,k]+0.5,'k:');										% ygrid line(manual)
		end
		% ここにプロットを挿入
		% h1=plot(p.satprn{3}(:,1),p.satprn{1}(:,p.opt.sat),...
		% 		'LineWidth',4,'color','b');										% 可視衛星PRNのプロット
		h1=plot(p.satprn{3}(:,1),p.satprn{1}(:,p.opt.sat),...
				'LineWidth',4,'color','r');										% 可視衛星PRNのプロット(GLONASS)
		h2=plot(p.satprn{3}(:,1),p.satprn{2}(:,p.opt.sat),...
				'LineWidth',4,'color','b');										% 使用衛星PRNのプロット(GLONASS)
		if size(p.satprn,2)==4
			h3=plot(p.satprn{3}(:,1),p.satprn{4}(:,p.opt.sat),...
					'LineWidth',4,'color',[0,0.5,0]);							% 基準衛星PRNのプロット(GLONASS)
		end
		ylabel('Satellite PRN');												% ylabel
		xlabel('ToD [sec.]');													% xlabel
	end
else
	%- axes(Satellite PRN)
	%--------------------------------------------
	nn=4;np=4;
	margin=[0.1,0.05,0.07,0.013];												% [left,right,figure top/bottom,axes top/bottom]
	h=(1-2*margin(3))/np;
	pos=[margin(1),...
		(np-nn)*h+margin(3)+2*margin(4),...
		1-margin(1)-margin(2),...
		3*h-2*margin(4)];														% [left,bottom,width,height]
	yt=[p.opt.sat];																	% ytick
	yl={p.opt.sat};																% yticklabel
	ylm=[38.5,61.5];															% ylim(GLONASS)
	xt=[p.opt.xrange1:p.opt.xrange3:p.opt.xrange2];								% xtick
	xl={p.opt.xrange1:p.opt.xrange3:p.opt.xrange2};								% xticklabel
	xlm=[p.opt.xrange1,p.opt.xrange2];											% xlim
	ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);										% New axes
	set(ax,'ygrid','off','ydir','reverse','ticklength',[0,0]);					% ygrid(off), ydir(reverse), ticklength(0)
	for k=1:61
		plot([0,86400],[k,k]+0.5,'k:');											% ygrid line(manual)
	end
end



%--- Skyplot
%-------------------------------------------------------------------------------
function plot_sky(p)
TT=[datestr(datenum(p.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(p.etime,'yyyy/mm/dd/HH/MM/SS'),'mm/dd HH:MM:SS'),' GPST'];
clf;
% yls={'No. of Satellite','Satellite PRN'};
nn=1;np=1;
margin=[0.1,0.05,0.07,0.013];											% [left,right,figure top/bottom,axes top/bottom]
h=(1-2*margin(3))/np;
pos=[margin(1),...
	(np-nn)*h+margin(3)+2*margin(4),...
	1-margin(1)-margin(2),...
	h-2*margin(4)];														% [left,bottom,width,height]
yt=[];																	% ytick
yl={};																	% yticklabel
ylm=[-95,95];															% ylim
xt=[];																	% xtick
xl={};																	% xticklabel
xlm=[-95,95];															% xlim
ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);									% New axes
axis equal
axis off
patch(90*sin(0:pi/36:2*pi),90*cos(0:pi/36:2*pi),'w','linestyle','none');			% 円の作成(背景は白)
%--- 方位角の目盛り
%--------------------------------------------
label='NESW';
for k=0:30:330
	plot([0 90*sin(k*pi/180)],[0 90*cos(k*pi/180)],'Color','k','LineStyle',':');	% 30度ごとに線プロット
	if mod(k,90)==0
		str=label(k/90+1);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,...
				'horizontal','center','FontSize',16,'FontWeight','bold');			% 90度ごとに目盛り(文字)
	else
		str=num2str(k);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,...
				'horizontal','center','FontSize',12,'FontWeight','demi');			% 30度ごとに目盛り(数字)
	end
end
%--- 仰角の目盛り
%--------------------------------------------
for k=1:6
	if k~=6
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),...
				'LineStyle',':','LineWidth',0.1,'Color','k');						% 15度ごとに点線プロット
	else
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),...
				'LineStyle','-','LineWidth',0.1,'Color','k');						% 最後は線プロット
	end
end
for k=0:30:90
	text(0,k,num2str(90-k),'HorizontalAlignment','center',...
			'FontSize',12,'FontWeight','demi','Color','k');							% 30度ごとに目盛り
end
% ここにプロットを挿入
switch p.opt.station
case 1,
	ele0=p.obs_rov.ele;
	azi0=p.obs_rov.azi;
case 2,
	ele0=p.obs_ref.ele;
	azi0=p.obs_ref.azi;
end

if ~isempty(ele0)&~isempty(azi0)
	ele = ele0*180/pi;
	xpol = (90-ele).*sin(azi0);														% Xの値(sinに仰角, 方位角を利用)
	ypol = (90-ele).*cos(azi0);														% Yの値(cosに仰角, 方位角を利用)
	pol = plot(xpol(:,p.opt.sat),ypol(:,p.opt.sat),...
				'Color',[1,0.0,0],'LineWidth',2);									% skyplot(可視衛星)

	xpol_use=xpol.*(p.satprn{2}./p.satprn{2});										% Xの値(使用衛星の抽出)
	ypol_use=ypol.*(p.satprn{2}./p.satprn{2});										% Yの値(使用衛星の抽出)
	pol_use = plot(xpol_use(:,p.opt.sat),ypol_use(:,p.opt.sat),...
					'Color',[0,0.0,1],'LineWidth',2);								% skyplot(使用衛星)

	if size(p.satprn,2)==4
		xpol_ref=xpol.*(p.satprn{4}./p.satprn{4});									% Xの値(基準衛星の抽出)
		ypol_ref=ypol.*(p.satprn{4}./p.satprn{4});									% Yの値(基準衛星の抽出)
		pol_ref = plot(xpol_ref(:,p.opt.sat),ypol_ref(:,p.opt.sat),...
						'Color',[0,0.5,0],'LineWidth',2);							% skyplot(基準衛星)
	end
end
title(['Skyplot',' : ',TT]);														% title

% %- Skyplot(another) % yanase
% %-------------------------------------------------------------------------------
% if ~isempty(ele0)&~isempty(azi0)
% 	ele = ele0*180/pi;
% 	xpol = (90-ele).*sin(azi0);														% Xの値(sinに仰角, 方位角を利用)
% 	ypol = (90-ele).*cos(azi0);														% Yの値(cosに仰角, 方位角を利用)
% 
% 	button = questdlg('skyplotを実行しますか？','SKYPLOT','はい','いいえ','いいえ') 
% 	if button == 'はい'
% 	Data=1:64;Data=(Data'*Data)/64;
% 	uiwait(msgbox('しばらくお待ちください','SKYPLOT','custom',Data,jet(64)));
% 	Nc = 90;                        % 作りたい色の数
% 	A = colormap(jet(Nc));
% 		for y=1:length(xpol(:,1))
% 			ele(y,p.opt.sat);
% 			n=round(ele(y,p.opt.sat));
% 			for k=1:length(p.opt.sat)
% 				if ~isnan(n(k)) & n(k)~=0
% 				A(n(k),:);
% 				pol = plot3(xpol(y,p.opt.sat(k)),ypol(y,p.opt.sat(k)),ele(y,p.opt.sat(k)),'Color',A(n(k),:),'LineWidth',2);	% gradationプロット
% 				hold on
% 				end
% 			end
% 		end
% 	hcb = colorbar('Location','East','YTickLabel',...
% 	{'0','','','','','45','','','','','90'});
% 	set(hcb,'YTickMode','manual')
% 	elseif button=='いいえ'
% 	end
% end
% title(['Skyplot',' : ',TT]);														% title



%--- new figure
%-------------------------------------------------------------------------------
function newfig(siz)
screen=get(0,'screensize');															% スクリーンサイズ取得
pos=[(screen(3)-siz(1))/2 (screen(4)-siz(2))/2 siz(1) siz(2)];						% position
figure('Position',pos);																% figureを指定位置・サイズで作成



%--- new axes
%-------------------------------------------------------------------------------
function ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm)
ax=axes('position',pos);															% New axes
hold on, grid on, box on															% hold, grid, box
set(ax,'fontname','Times New Roman','fontsize',14);									% fontname, fontsize
set(ax,'xlim',[xlm(1),xlm(end)]);													% xlim
set(ax,'xtick',xt,'xticklabel',xl);													% xtick, xticklabel
set(ax,'ylim',[ylm(1),ylm(end)]);													% ylim
set(ax,'ytick',yt,'yticklabel',yl);													% ytick, yticklabel



%--- subplot(vertical)
%-------------------------------------------------------------------------------
function ax=subplotv(nn,np,margin,xt,xl,xlm,yt,yl,ylm)
h=(1-2*margin(3))/np;																% 高さをnp等分にする
pos=[margin(1),...
	(np-nn)*h+margin(3)+2*margin(4),...
	1-margin(1)-margin(2),...
	h-2*margin(4)];																	% [left,bottom,width,height]
ax=newaxes(pos,xt,xl,xlm,yt,yl,ylm);												% New axes



%--- readdata
%-------------------------------------------------------------------------------
function readdata(file)
p=guidata(gcf);
p.esttime  =[];

p.enu_float=[]; p.enu_fix  =[];
p.enu_mix  =[]; p.enu_spp  =[];
p.enu_ppp  =[]; p.enu_vppp =[];
p.enu_dgps =[];

p.stime    =[]; p.etime    =[];
p.rovpos   =[]; p.refpos   =[];
p.dtrop    =[]; p.dion     =[];
p.dtr      =[];
p.dtr_vppp =[];

p.heikin0=[];,p.stdd0=[];,p.rms0=[];
p.heikin1=[];,p.stdd1=[];,p.rms1=[];
p.heikin2=[];,p.stdd2=[];,p.rms2=[];
p.heikin3=[];,p.stdd3=[];,p.rms3=[];
p.heikin4=[];,p.stdd4=[];,p.rms4=[];
p.heikin5=[];,p.stdd5=[];,p.rms5=[];
p.heikin6=[];,p.stdd6=[];,p.rms6=[];

p.obs_rov.ca     =[]; p.obs_ref.ca     =[];
p.obs_rov.py     =[]; p.obs_ref.py     =[];
p.obs_rov.ph1    =[]; p.obs_ref.ph1    =[];
p.obs_rov.ph2    =[]; p.obs_ref.ph2    =[];
p.obs_rov.ca_cor =[]; p.obs_ref.ca_cor =[];
p.obs_rov.py_cor =[]; p.obs_ref.py_cor =[];
p.obs_rov.ph1_cor=[]; p.obs_ref.ph1_cor=[];
p.obs_rov.ph2_cor=[]; p.obs_ref.ph2_cor=[];
p.obs_rov.ele    =[]; p.obs_ref.ele    =[];
p.obs_rov.azi    =[]; p.obs_ref.azi    =[];

p.LC_rov.mp1 =[]; p.LC_ref.mp1 =[];
p.LC_rov.mp2 =[]; p.LC_ref.mp2 =[];
p.LC_rov.mw  =[]; p.LC_ref.mw  =[];
p.LC_rov.lgl =[]; p.LC_ref.lgl =[];
p.LC_rov.lgp =[]; p.LC_ref.lgp =[];
p.LC_rov.lg1 =[]; p.LC_ref.lg1 =[];
p.LC_rov.lg2 =[]; p.LC_ref.lg2 =[];
p.LC_rov.ionp=[]; p.LC_ref.ionp=[];
p.LC_rov.ionl=[]; p.LC_ref.ionl=[];

%--- MATファイルの読み込み
%--------------------------------------------
try
	load('-mat',p.file);
catch
	disp(['file read error : ',p.file]); rethrow(lasterror); return;
end

set(gcf,'name',p.file,'renderer','painters','color','w');						% Figureの設定(name, renderer)

p.stime    =est_prm.stime;
p.etime    =est_prm.etime;
p.rcv      =est_prm.rcv;
if length(est_prm.rcv)==1
	p.rovpos   =est_prm.rovpos;
elseif length(est_prm.rcv)==2
	p.rovpos   =est_prm.rovpos;
	p.refpos   =est_prm.refpos;
end

fields=isfield(Result,{'spp','ppp','vppp','dgps','float','fix'});

%--- 各測位解
%--------------------------------------------
if fields(1)==1
	result0=Result.spp;
	for k=1:length(result0.pos)
		result0.pos(k,1:3)=xyz2enu(result0.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin0(n),p.stdd0(n),p.rms0(n)]=stats(result0.pos(:,n));			% 平均, 標準偏差, RMS(SPP解)
	end
	p.heikin0(4)=sqrt(sum(p.heikin0(1:2).^2));									% 平均(2D)
	p.stdd0(4)=sqrt(sum(p.stdd0(1:2).^2));										% 標準偏差(2D)
	p.rms0(4)=sqrt(sum(p.rms0(1:2).^2));										% RMS(2D)
	p.enu_spp  =result0.pos;
	p.esttime  =result0.time;
	p.satprn   =Result.spp.prn;
	p.dtr      =result0.dtr;
	if isfield(OBS,{'rov'})
		p.obs_rov.ele  =OBS.rov.ele;
		p.obs_rov.azi  =OBS.rov.azi;
	elseif isfield(OBS,{'rov1'})
		p.obs_rov.ele  =OBS.rov1.ele;
		p.obs_rov.azi  =OBS.rov1.azi;
	end
end
if fields(2)==1
	result1=Result.ppp;
	for k=1:length(result1.pos)
		result1.pos(k,1:3)=xyz2enu(result1.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin1(n),p.stdd1(n),p.rms1(n)]=stats(result1.pos(:,n));			% 平均, 標準偏差, RMS(PPP解)
	end
	p.heikin1(4)=sqrt(sum(p.heikin1(1:2).^2));									% 平均(2D)
	p.stdd1(4)=sqrt(sum(p.stdd1(1:2).^2));										% 標準偏差(2D)
	p.rms1(4)=sqrt(sum(p.rms1(1:2).^2));										% RMS(2D)
	p.enu_ppp  =result1.pos;
	p.esttime  =result1.time;
	if est_prm.statemodel.trop~=0
		p.dtrop    =result1.dtrop;
	end
	if est_prm.statemodel.ion~=0
		p.dion     =result1.dion;
	end
	p.satprn   =Result.ppp.prn;
	p.dtr      =result1.dtr;
	p.obs_rov.ele  =OBS.rov.ele;
	p.obs_rov.azi  =OBS.rov.azi;
end
if fields(3)==1
	result0=Result.spp1;
	result1=Result.spp2;
	result2=Result.vppp;
	for k=1:length(result2.pos)
		result2.pos(k,1:3)=xyz2enu(result2.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin2(n),p.stdd2(n),p.rms2(n)]=stats(result2.pos(:,n));			% 平均, 標準偏差, RMS(VPPP解)
	end
	p.heikin2(4)=sqrt(sum(p.heikin2(1:2).^2));									% 平均(2D)
	p.stdd2(4)=sqrt(sum(p.stdd2(1:2).^2));										% 標準偏差(2D)
	p.rms2(4)=sqrt(sum(p.rms2(1:2).^2));										% RMS(2D)
	p.enu_vppp =result2.pos;
	p.esttime  =result2.time;
	if est_prm.statemodel.trop~=0
		p.dtrop    =result2.dtrop;
	end
% 	if est_prm.statemodel.ion==1
% 		p.dion     =result2.dion;
% 	end
	p.satprn   =Result.vppp.prn;
	p.dtr_vppp =[result0.dtr,result1.dtr,result2.dtr];
	p.dtr      =result2.dtr;
	p.obs_rov.ele  =OBS.rov1.ele;
	p.obs_rov.azi  =OBS.rov1.azi;
end
if fields(4)==1
	result3=Result.dgps;
	for k=1:length(result3.pos)
		result3.pos(k,1:3)=xyz2enu(result3.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin3(n),p.stdd3(n),p.rms3(n)]=stats(result3.pos(:,n));			% 平均, 標準偏差, RMS(DGPS解)
	end
	p.heikin3(4)=sqrt(sum(p.heikin3(1:2).^2));									% 平均(2D)
	p.stdd3(4)=sqrt(sum(p.stdd3(1:2).^2));										% 標準偏差(2D)
	p.rms3(4)=sqrt(sum(p.rms3(1:2).^2));										% RMS(2D)
	p.enu_dgps =result3.pos;
	p.esttime  =result3.time;
	if est_prm.statemodel.trop~=0
		p.dtrop    =result3.dtrop;
	end
	if est_prm.statemodel.ion==1
		p.dion     =result3.dion;
	end
	p.satprn   =Result.dgps.prn;
	p.obs_rov.ele  =OBS.rov.ele;
	p.obs_rov.azi  =OBS.rov.azi;
end
if fields(5)==1
	result4=Result.float;
	for k=1:length(result4.pos)
		result4.pos(k,1:3)=xyz2enu(result4.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin4(n),p.stdd4(n),p.rms4(n)]=stats(result4.pos(:,n));			% 平均, 標準偏差, RMS(Float解)
	end
	p.heikin4(4)=sqrt(sum(p.heikin4(1:2).^2));									% 平均(2D)
	p.stdd4(4)=sqrt(sum(p.stdd4(1:2).^2));										% 標準偏差(2D)
	p.rms4(4)=sqrt(sum(p.rms4(1:2).^2));										% RMS(2D)
	p.enu_float=result4.pos;
	p.esttime  =result4.time;
	p.satprn   =Result.float.prn;
	p.obs_rov.ele  =OBS.rov.ele;
	p.obs_rov.azi  =OBS.rov.azi;
end
if fields(6)==1
	result5=Result.fix;
	for k=1:length(result5.pos)
		result5.pos(k,1:3)=xyz2enu(result5.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin5(n),p.stdd5(n),p.rms5(n)]=stats(result5.pos(:,n));			% 平均, 標準偏差, RMS(Fix解)
	end
	p.heikin5(4)=sqrt(sum(p.heikin5(1:2).^2));									% 平均(2D)
	p.stdd5(4)=sqrt(sum(p.stdd5(1:2).^2));										% 標準偏差(2D)
	p.rms5(4)=sqrt(sum(p.rms5(1:2).^2));										% RMS(2D)
	p.enu_fix  =result5.pos;
	p.esttime  =result5.time;
	p.satprn   =Result.fix.prn;
	p.obs_rov.ele  =OBS.rov.ele;
	p.obs_rov.azi  =OBS.rov.azi;
end
if fields(6)==1
	result6=Result.fix;
	% Float解とFix解を結合
	%--------------------------------------------
	index_float=find(isnan(result6.pos(:,1)));
	index_fix=find(~isnan(result6.pos(:,1)));
	result6.pos(index_float,:)=Result.float.pos(index_float,:);
	for k=1:length(result6.pos)
		result6.pos(k,1:3)=xyz2enu(result6.pos(k,1:3)',est_prm.rovpos);			% ENUに変換
	end
	for n=1:3
		[p.heikin6(n),p.stdd6(n),p.rms6(n)]=stats(result6.pos(:,n));			% 平均, 標準偏差, RMS(結合解)
	end
	p.heikin6(4)=sqrt(sum(p.heikin6(1:2).^2));									% 平均(2D)
	p.stdd6(4)=sqrt(sum(p.stdd6(1:2).^2));										% 標準偏差(2D)
	p.rms6(4)=sqrt(sum(p.rms6(1:2).^2));										% RMS(2D)
	p.enu_mix  =result6.pos;
	p.esttime  =result6.time;
	if est_prm.statemodel.trop~=0
		p.dtrop    =Result.fix.dtrop;
		p.dtrop(index_float,:)=Result.float.dtrop(index_float,:);
	end
	if est_prm.statemodel.ion~=0
		p.dion     =Result.fix.dion;
		p.dion(index_float,:)=Result.float.dion(index_float,:);
	end
	p.satprn   =Result.fix.prn;
	p.obs_rov.ele  =OBS.rov.ele;
	p.obs_rov.azi  =OBS.rov.azi;
end

p.opt.xrange2 = round(max(p.esttime(:,4))/p.opt.xrange3)*p.opt.xrange3;			% X軸範囲の最大値
if p.opt.xrange2<max(p.esttime(:,4)), p.opt.xrange2=max(p.esttime(:,4));, end	% X軸範囲の最大値
% p.opt.xrange1=p.esttime(1,4);													% X軸範囲の最小値
p.opt.xrange1=floor(p.esttime(1,4)/p.opt.xrange3)*p.opt.xrange3;				% X軸範囲の最小値
if p.esttime(1,4)<900
	p.opt.xrange1=0;															% X軸範囲の最小値
end

% 観測データと線形結合(Rov)

if fields(3)==1
	p.obs_rov1.ca    =OBS.rov1.ca;
	p.obs_rov1.py    =OBS.rov1.py;
	p.obs_rov1.ph1   =OBS.rov1.ph1;
	p.obs_rov1.ph2   =OBS.rov1.ph2;
	p.obs_rov1.ca_cor =OBS.rov1.ca_cor;
	p.obs_rov1.py_cor =OBS.rov1.py_cor;
	p.obs_rov1.ph1_cor=OBS.rov1.ph1_cor;
	p.obs_rov1.ph2_cor=OBS.rov1.ph2_cor;
	p.obs_rov1.ele    =OBS.rov1.ele;
	p.obs_rov1.azi    =OBS.rov1.azi;

	p.obs_rov2.ca    =OBS.rov2.ca;
	p.obs_rov2.py    =OBS.rov2.py;
	p.obs_rov2.ph1   =OBS.rov2.ph1;
	p.obs_rov2.ph2   =OBS.rov2.ph2;
	p.obs_rov2.ca_cor =OBS.rov2.ca_cor;
	p.obs_rov2.py_cor =OBS.rov2.py_cor;
	p.obs_rov2.ph1_cor=OBS.rov2.ph1_cor;
	p.obs_rov2.ph2_cor=OBS.rov2.ph2_cor;
	p.obs_rov2.ele    =OBS.rov2.ele;
	p.obs_rov2.azi    =OBS.rov2.azi;

	p.LC_rov1.mp1 =LC.rov1.mp1;
	p.LC_rov1.mp2 =LC.rov1.mp2;
	p.LC_rov1.mw  =LC.rov1.mw;
	p.LC_rov1.lgl =LC.rov1.lgl;
	p.LC_rov1.lgp =LC.rov1.lgp;
	p.LC_rov1.lg1 =LC.rov1.lg1;
	p.LC_rov1.lg2 =LC.rov1.lg2;
	p.LC_rov1.ionp=LC.rov1.ionp;
	p.LC_rov1.ionl=LC.rov1.ionl;

	p.LC_rov2.mp1 =LC.rov2.mp1;
	p.LC_rov2.mp2 =LC.rov2.mp2;
	p.LC_rov2.mw  =LC.rov2.mw;
	p.LC_rov2.lgl =LC.rov2.lgl;
	p.LC_rov2.lgp =LC.rov2.lgp;
	p.LC_rov2.lg1 =LC.rov2.lg1;
	p.LC_rov2.lg2 =LC.rov2.lg2;
	p.LC_rov2.ionp=LC.rov2.ionp;
	p.LC_rov2.ionl=LC.rov2.ionl;
else
	p.obs_rov.ca     =OBS.rov.ca;
	p.obs_rov.py     =OBS.rov.py;
	p.obs_rov.ph1    =OBS.rov.ph1;
	p.obs_rov.ph2    =OBS.rov.ph2;
	p.obs_rov.ca_cor =OBS.rov.ca_cor;
	p.obs_rov.py_cor =OBS.rov.py_cor;
	p.obs_rov.ph1_cor=OBS.rov.ph1_cor;
	p.obs_rov.ph2_cor=OBS.rov.ph2_cor;
	p.obs_rov.ele    =OBS.rov.ele;
	p.obs_rov.azi    =OBS.rov.azi;

	p.LC_rov.mp1 =LC.rov.mp1;
	p.LC_rov.mp2 =LC.rov.mp2;
	p.LC_rov.mw  =LC.rov.mw;
	p.LC_rov.lgl =LC.rov.lgl;
	p.LC_rov.lgp =LC.rov.lgp;
	p.LC_rov.lg1 =LC.rov.lg1;
	p.LC_rov.lg2 =LC.rov.lg2;
	p.LC_rov.ionp=LC.rov.ionp;
	p.LC_rov.ionl=LC.rov.ionl;
end

% 観測データと線形結合(Ref)
if length(est_prm.rcv)~=1
	p.obs_ref.ca     =OBS.ref.ca;
	p.obs_ref.py     =OBS.ref.py;
	p.obs_ref.ph1    =OBS.ref.ph1;
	p.obs_ref.ph2    =OBS.ref.ph2;
	p.obs_ref.ca_cor =OBS.ref.ca_cor;
	p.obs_ref.py_cor =OBS.ref.py_cor;
	p.obs_ref.ph1_cor=OBS.ref.ph1_cor;
	p.obs_ref.ph2_cor=OBS.ref.ph2_cor;
	p.obs_ref.ele    =OBS.ref.ele;
	p.obs_ref.azi    =OBS.ref.azi;

	p.LC_ref.mp1 =LC.ref.mp1;
	p.LC_ref.mp2 =LC.ref.mp2;
	p.LC_ref.mw  =LC.ref.mw;
	p.LC_ref.lgl =LC.ref.lgl;
	p.LC_ref.lgp =LC.ref.lgp;
	p.LC_ref.lg1 =LC.ref.lg1;
	p.LC_ref.lg2 =LC.ref.lg2;
	p.LC_ref.ionp=LC.ref.ionp;
	p.LC_ref.ionl=LC.ref.ionl;
end

% 残差
if exist('Res','var'), p.Res=Res;, end



%--- generate menu ↓ --------------------------------------------------------------
delete(findobj(gcf,'tag','plot')); 
delete(findall(gcf,'tag','plot'));

%--- generate menu plot
%--------------------------------------------
h=uimenu(gcf,'tag','plot','label','&Plot','handlevisibility','off');
labels={'ENU','2D','Rcv clock','Tropospheric delay','Ionospheric delay',...
		'Satellite','Skyplot','LC','OBS','Res(pre-fit)','Res(post-fit)',...
		'ResE(pre-fit)','ResE(post-fit)','ResA(pre-fit)','ResA(post-fit)'};
m=1;
for n=1:length(labels)
	p.handles.menu1(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_1']);
	m=m+1;
end
set(p.handles.menu1(4),'separator','on');
set(p.handles.menu1(6),'separator','on');
set(p.handles.menu1(8),'separator','on');
set(p.handles.menu1(10),'separator','on');
set(p.handles.menu1(12),'separator','on');
set(p.handles.menu1(14),'separator','on');
p.type='enu';
set(p.handles.menu1(1),'checked','on');
guidata(gcf,p);

%--- generate menu plot mode
%--------------------------------------------
delete(findobj(gcf,'tag','plot_mode')); 
delete(findall(gcf,'tag','plot_mode'));
h=uimenu(gcf,'tag','plot_mode','label','&PMode','handlevisibility','off');
labels={'ALL','SPP','PPP','VPPP','DGPS','Float','Fix'};
m=1;
for n=1:length(labels)
	p.handles.menu2(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_2']);
	m=m+1;
end
set(p.handles.menu2(2),'separator','on');
p.opt.plot=max(find(fields))+1;
if p.opt.plot==6|p.opt.plot==7, p.opt.plot=1;, end
set(p.handles.menu2(p.opt.plot),'checked','on');
guidata(gcf,p);

%--- generate menu plot edit
%--------------------------------------------
delete(findobj(gcf,'tag','plot_edt')); 
delete(findall(gcf,'tag','plot_edt'));
h=uimenu(gcf,'tag','plot_edt','label','&PEdit','handlevisibility','off');
labels={'X-Range','Y-Range','Fit-X','Fit-Y'};
m=1;
for n=1:length(labels)
	p.handles.menu3(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_3']);
	m=m+1;
end
set(p.handles.menu3(3),'separator','on');
guidata(gcf,p);

%--- generate menu sat
%--------------------------------------------
delete(findobj(gcf,'tag','sat'));
delete(findall(gcf,'tag','sat'));
h=uimenu(gcf,'tag','sat','label','&Satellite','handlevisibility','off');
labels={'ALL','GPS','GLONASS'};
m=1;
for n=1:length(labels)
	p.handles.menu4(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_4']);
	m=m+1;
end
set(p.handles.menu4(2),'separator','on');
p.opt.sat=1:32;
set(p.handles.menu4(2),'checked','on');
guidata(gcf,p);

%--- generate menu station
%--------------------------------------------
delete(findobj(gcf,'tag','station')); 
delete(findall(gcf,'tag','station'));
h=uimenu(gcf,'tag','station','label','&Station','handlevisibility','off');
labels={'Rover','Reference'};
m=1;
for n=1:length(labels)
	p.handles.menu5(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_5']);
	m=m+1;
end
p.opt.station=1;
set(p.handles.menu5(1),'checked','on');
guidata(gcf,p);

%--- generate menu view stats
%--------------------------------------------
delete(findobj(gcf,'tag','view_stats')); 
delete(findall(gcf,'tag','view_stats'));
h=uimenu(gcf,'tag','view_stats','label','&ViewStats','handlevisibility','off');
labels={'ON','OFF'};
m=1;
for n=1:length(labels)
	p.handles.menu6(n)=uimenu(h,'label',labels{n},'userdata',m,'callback',[mfilename,' cb_6']);
	m=m+1;
end
p.opt.view_stats=1;
set(p.handles.menu6(1),'checked','on');
guidata(gcf,p);



%--- generate menu LC_mode (sub_menu)
%--------------------------------------------
labels={'MP1','MP2','MW','LGL','LGP','LG1','LG2'};
m=1;
for n=1:length(labels)
	p.handles.menu7(n)=uimenu(p.handles.menu1(8),'tag','LC_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_7']);
	m=m+1;
end
set(p.handles.menu7(3),'separator','on');
set(p.handles.menu7(4),'separator','on');
set(p.handles.menu7(6),'separator','on');
p.opt.LC_plot=0;
set(p.handles.menu7,'checked','off');
guidata(gcf,p);

%--- generate menu OBS_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY','L1(cor)','L2(cor)','CA(cor)','PY(cor)'};
m=1;
for n=1:length(labels)
	p.handles.menu8(n)=uimenu(p.handles.menu1(9),'tag','OBS_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_8']);
	m=m+1;
end
set(p.handles.menu8(5),'separator','on');
p.opt.OBS_plot=0;
set(p.handles.menu8,'checked','off');
guidata(gcf,p);

%--- generate menu Res_pre_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY'};
m=1;
for n=1:length(labels)
	p.handles.menu9(n)=uimenu(p.handles.menu1(10),'tag','Res_pre_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_9']);
	m=m+1;
end
% set(p.handles.menu9(5),'separator','on');
p.opt.Res_pre_plot=0;
set(p.handles.menu9,'checked','off');
guidata(gcf,p);

%--- generate menu Res_pos_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY'};
m=1;
for n=1:length(labels)
	p.handles.menu10(n)=uimenu(p.handles.menu1(11),'tag','Res_pos_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_10']);
	m=m+1;
end
% set(p.handles.menu10(5),'separator','on');
p.opt.Res_pos_plot=0;
set(p.handles.menu10,'checked','off');
guidata(gcf,p);

%--- generate menu Res_pre_e_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY'};
m=1;
for n=1:length(labels)
	p.handles.menu11(n)=uimenu(p.handles.menu1(12),'tag','Res_pre_e_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_11']);
	m=m+1;
end
% set(p.handles.menu11(5),'separator','on');
p.opt.Res_pre_e_plot=0;
set(p.handles.menu11,'checked','off');
guidata(gcf,p);

%--- generate menu Res_pos_e_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY'};
m=1;
for n=1:length(labels)
	p.handles.menu12(n)=uimenu(p.handles.menu1(13),'tag','Res_pos_e_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_12']);
	m=m+1;
end
% set(p.handles.menu12(5),'separator','on');
p.opt.Res_pos_e_plot=0;
set(p.handles.menu12,'checked','off');
guidata(gcf,p);

%--- generate menu Res_pre_a_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY'};
m=1;
for n=1:length(labels)
	p.handles.menu13(n)=uimenu(p.handles.menu1(14),'tag','Res_pre_a_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_13']);
	m=m+1;
end
% set(p.handles.menu13(5),'separator','on');
p.opt.Res_pre_a_plot=0;
set(p.handles.menu13,'checked','off');
guidata(gcf,p);

%--- generate menu Res_pos_a_mode (sub_menu)
%--------------------------------------------
labels={'L1','L2','CA','PY'};
m=1;
for n=1:length(labels)
	p.handles.menu14(n)=uimenu(p.handles.menu1(15),'tag','Res_pos_a_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_14']);
	m=m+1;
end
% set(p.handles.menu14(5),'separator','on');
p.opt.Res_pos_a_plot=0;
set(p.handles.menu14,'checked','off');
guidata(gcf,p);

%--- generate menu GPS_prn_mode (sub_menu)
%--------------------------------------------
labels={'ALL'};
for i=1:31
	labels={labels{:},sprintf('PRN%02d',i)};
end
m=1;
for n=1:length(labels)
	p.handles.menu15(n)=uimenu(p.handles.menu4(2),'tag','GPS_prn_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_15']);
	m=m+1;
end
p.opt.sky_plot=0;
set(p.handles.menu15(2),'separator','on');
set(p.handles.menu15,'checked','off');
guidata(gcf,p);

%--- generate menu GLONASS_prn_mode (sub_menu)
%--------------------------------------------
labels={'ALL'};
for i=38:61
	labels={labels{:},sprintf('PRN%02d',i)};
end
m=1;
for n=1:length(labels)
	p.handles.menu16(n)=uimenu(p.handles.menu4(3),'tag','GLONASS_prn_mode',...
								'label',labels{n},'userdata',m,'callback',[mfilename,' cb_16']);
	m=m+1;
end
p.opt.sky_plot=0;
set(p.handles.menu16(2),'separator','on');
set(p.handles.menu16,'checked','off');
guidata(gcf,p);

upplot;



function output_fig(fname,mode,handle)
%-------------------------------------------------------------------------------
% Function : figureのファイル出力関数・・・EPS,TIFF,EMFで保存
%
% [argin]
% fname   : 出力ファイル名
% mode    : 出力サイズ設定(0:縦カスタム, 1:縦フル, 2:横フル, 3:横フル+)
% handles : figureのハンドル
%
% [argout]
%
% ※ modeは "3" がおすすめ---印刷のことも考慮しているから
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 31, 2007
%-------------------------------------------------------------------------------

if nargin<3, handle=get(0,'CurrentFigure');, end

set(handle, 'PaperPositionMode', 'manual');
set(handle, 'PaperUnits', 'centimeters');
if mode == 0
	set(handle, 'PaperPosition', [0 0 21 15]);
	set(handle, 'PaperOrientation', 'portrait');		% portrait:縦  landscape:横
elseif mode==1
	set(handle, 'PaperPosition', [0 0 21 29.68]);		% フルサイズ(portrait:縦)
	set(handle, 'PaperOrientation', 'portrait');		% portrait:縦  landscape:横
elseif mode==2
	set(handle, 'PaperPosition', [0 0 29.68 21]);		% フルサイズ(landscape:横)
	set(handle, 'PaperOrientation', 'landscape');		% portrait:縦  landscape:横
elseif mode==3
	set(handle, 'PaperPosition', [0 0 29.68 21]);		% フルサイズ(landscape:横)
	set(handle, 'PaperOrientation', 'portrait');		% portrait:縦  landscape:横
end

set(handle, 'Renderer', 'painters');					% レンダリング法

set(gca, 'xtickmode','manual');							% 座標軸の範囲と目盛(スクリーンと同じ)
set(gca, 'ytickmode','manual');							% 座標軸の範囲と目盛(スクリーンと同じ)
set(gca, 'ztickmode','manual');							% 座標軸の範囲と目盛(スクリーンと同じ)

set(gcf,'Color','none');
set(gcf,'InvertHardcopy','off')

print(handle,'-r300','-depsc2',fname)					% EPS Level2 Color
% print(handle,'-r300','-dtiff',fname)					% TIFF
print(handle,'-dmeta',fname)							% EMF

if mode==3
	set(handle, 'PaperOrientation', 'landscape');		% portrait:縦  landscape:横
end
set(gcf,'Color','w');
saveas(handle,fname,'fig')								% figureの保存


%-------------------------------------------------------------------------------
% 以下の関数はtoolbox内にあるので別に必要はない
%-------------------------------------------------------------------------------

function [m,s,r]=stats(x)
%-------------------------------------------------------------------------------
% Function : 統計量(mean, std, rms)の計算
% 
% [argin]
% x : 推定結果
% 
% [argout]
% m : mean
% s : std
% r : rms
% 
% NaNがある場合でも計算できるようにしています
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 24, 2008
%-------------------------------------------------------------------------------

m = mean(x(find(~isnan(x(:,1))),1));							% 平均
s = std(x(find(~isnan(x(:,1))),1));								% 標準偏差
r = sqrt(mean(x(find(~isnan(x(:,1))),1).^2));					% RMS



function enu = xyz2enu(xyz,orgxyz)
%-------------------------------------------------------------------------------
% Function : XYZ2ENU	WGS-84 直交座標系を ENU(East-North-Up) 座標系へ座標変換
%
% [argin]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% [argout]
% enu(1:3) : East[m], North[m], Up[m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

orgllh = xyz2llh(orgxyz(1:3));
lat = orgllh(1);
lon = orgllh(2);

LL = [          -sin(lon),            cos(lon),         0;
      - sin(lat)*cos(lon), - sin(lat)*sin(lon),  cos(lat);
        cos(lat)*cos(lon),   cos(lat)*sin(lon),  sin(lat)];

enu = LL*(xyz(1:3)-orgxyz(1:3));



function llh = xyz2llh(xyz)
%-------------------------------------------------------------------------------
% Function : WGS-84 直交座標系から LLH (緯度, 経度, 楕円体高) 座標系への座標変換
% ・近似による計算
% ・繰返し計算
%
% [argin]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% [argout]
% llh(1:3) : 緯度[rad], 経度[rad], 楕円体高[m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat=NaN; lon=NaN; h=NaN;

x = xyz(1);														% X(ECEF)
y = xyz(2);														% Y(ECEF)
z = xyz(3);														% Z(ECEF)

a = 6378137.0000;												% 赤道半径
b = 6356752.3142;												% 極半径

% 近似による計算
%-----------------------------------
e=sqrt(a^2-b^2)/a;
p=sqrt(x^2+y^2);
myu=sqrt(a^2-b^2)/b;
theta=atan((z*a)/(p*b));

lat=atan((z+myu^2*b*sin(theta)^3)/(p-e^2*a*cos(theta)^3));		% 緯度[rad]
if p^2<1E-12, lat=pi/2;, end
lon=atan2(y,x);													% 経度[rad]
N=a/sqrt(1-e^2*sin(lat)^2);
h=p/cos(lat)-N;													% 楕円体高[m]

llh=[lat,lon,h];												% 緯度[rad], 経度[rad], 楕円体高[m]


% % 繰返し計算
% %-----------------------------------
% e=sqrt(a^2-b^2)/a;
% p=sqrt(x^2+y^2);
% 
% lat=atan(z/(p*(1-e^2))); latk=0;
% while abs(lat-latk)>1e-4
% 	latk=lat;
% 	N=a/sqrt(1-e^2*sin(lat)^2);
% 	h=p/cos(lat)-N;												% 楕円体高[m]
% 	lat=atan(z/(p*(1-e^2*(N)/(N+h))));							% 緯度[rad]
% end
% if p^2<1E-12, lat=pi/2;, end
% lon=atan2(y,x);													% 経度[rad]
% 
% llh=[lat,lon,h];												% 緯度[rad], 経度[rad], 楕円体高[m]




function output_kml2(file,p,track_color,point_color)
%-------------------------------------------------------------------------------
% Function : KMLフォーマット出力 Ver.2
% 
% [argin]
% file        : ファイル名
% result      : 推定結果構造体(*.{spp/float/fix}.time:時刻, *.{spp/float/fix}.pos:位置)
% track_color : トラックカラー(文字列: 'Y','M','C','R','G','B','W','K') default:Y
% point_color : ポイントカラー(文字列: 'Y','M','C','R','G','B','W','K') default:R
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: July 3, 2008
%-------------------------------------------------------------------------------

% B G R
%--------------------------------------------
RGB_color={'00FFFF',	% Yellow
           'FF00FF',	% Magenta
           'FFFF00',	% Cyan
           '0000FF',	% Red
           '00FF00',	% Green
           'FF0000',	% Blue
           'FFFFFF',	% White
           '000000'};	% Black

RGB={'Y','M','C','R','G','B','W','K'};

% カラー設定
%--------------------------------------------
% if nargin < 4
% 	track_color=RGB_color{1};
% 	point_color=RGB_color{4};
% else
% 	i=strmatch(track_color,RGB);
% 	j=strmatch(point_color,RGB);
% 	if ~isempty(i) & ~isempty(j)
% 		track_color=RGB_color{i};
% 		point_color=RGB_color{j};
% 	else
% 		track_color=RGB_color{1};
% 		point_color=RGB_color{4};
% 	end
% end

track_color=RGB_color{1};
point_color1=RGB_color{4};
point_color2=RGB_color{5};
point_color3=RGB_color{6};


pos3=[];
switch p.opt.plot
case 1,
	if ~isempty(p.enu_mix)
		% SPP, Float解, Fix解を結合
		%--------------------------------------------
		index_float=find(~isnan(p.enu_float(:,1)));		% Floatのインデックス
		index_fix=find(~isnan(p.enu_fix(:,1)));			% Fixのインデックス
		Q=repmat(0,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
		Q(index_float)=4;								% Float=4
		Q(index_fix)=5;									% Fix=5
		pos3=p.enu_spp;									% SPP
		pos3(index_float,:)=p.enu_float(index_float,:);	% Floatで上書き
		pos3(index_fix,:)=p.enu_fix(index_fix,:);		% Fixで上書き
	end
case 2,
	if ~isempty(p.enu_spp)
		pos3=p.enu_spp;									% SPP
		Q=repmat(0,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
	end
case 3,
	if ~isempty(p.enu_ppp)
		pos3=p.enu_ppp;									% PPP
		Q=repmat(1,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
	end
case 4,
	if ~isempty(p.enu_vppp)
		pos3=p.enu_vppp;								% VPPP
		Q=repmat(2,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
	end
case 5,
	if ~isempty(p.enu_dgps)
		pos3=p.enu_dgps;								% DGPS
		Q=repmat(3,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
	end
case 6,
	if ~isempty(p.enu_float)
		pos3=p.enu_float;								% Float
		Q=repmat(4,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
	end
case 7,
	if ~isempty(p.enu_fix)
		pos3=p.enu_fix;									% Fix
		Q=repmat(5,length(p.enu_spp),1);				% SPP=0,PPP=1,VPPP=2,DGPS=3,Float=4,Fix=5
	end
end


% NaNを除外
%--------------------------------------------
i=[];
if ~isempty(pos3)
	i=find(~isnan(pos3(:,1)));
end

% Fix=length(index_fix)/length(i)*100
% Float=length(index_float)/length(i)*100-Fix
% SPP=100-(Fix+Float)

if ~isempty(i)
	% TIME
	%--------------------------------------------
	time=p.esttime(i,5:10);

	% POSITION
	%--------------------------------------------
	pos=pos3(i,4:6);
	h=geoidh(pos(1,1:2));
	Q=Q(i);

	% ファイルオープン
	%--------------------------------------------
	fp=fopen(file,'w');

	% XMLヘッダ(変更不可)
	%--------------------------------------------
	fprintf(fp,'<?xml version="1.0" encoding="UTF-8"?>\n');

	% KML version2.0のネームスペース宣言(変更不可)
	%--------------------------------------------
	fprintf(fp,'<kml xmlns="http://earth.google.com/kml/2.0">\n');


	% 本文開始
	%--------------------------------------------
	fprintf(fp,'<Document>\n');

	% トラック
	%--------------------------------------------
	fprintf(fp,'<Placemark>\n');
	fprintf(fp,'  <name>Rover Track</name>\n');
	fprintf(fp,'  <Style>\n');
	fprintf(fp,'    <LineStyle>\n');
	fprintf(fp,'      <color>aa%s</color>\n',track_color);
	fprintf(fp,'    </LineStyle>\n');
	fprintf(fp,'  </Style>\n');
	fprintf(fp,'  <LineString>\n');
	fprintf(fp,'    <coordinates>\n');
	for n=1:size(pos,1)
		fprintf(fp,'       %15.9f,%15.9f,%15.9f\n',pos(n,2),pos(n,1),pos(n,3)-h);
	end
	fprintf(fp,'    </coordinates>\n');
	fprintf(fp,'  </LineString>\n');
	fprintf(fp,'</Placemark>\n');

	% ポイント(フォルダに格納)
	%--------------------------------------------
	fprintf(fp,'<Folder>\n');
	for n=1:size(pos,1)
		fprintf(fp,'  <name>Rover Position</name>\n');
		fprintf(fp,'<Placemark>\n');
		fprintf(fp,'  <TimeStamp><when>%4d-%02d-%02dT%02d:%02d:%04.2fZ</when></TimeStamp>\n',time(n,1:6));
		fprintf(fp,'  <Style>\n');
		fprintf(fp,'    <IconStyle>\n');
		fprintf(fp,'      <scale>0.2</scale>\n');
		switch Q(n)
		case 0, fprintf(fp,'      <color>ff%s</color>\n',point_color3);			% SPP
		case 1, fprintf(fp,'      <color>ff%s</color>\n',point_color1);			% PPP
		case 2, fprintf(fp,'      <color>ff%s</color>\n',point_color1);			% VPPP
		case 3, fprintf(fp,'      <color>ff%s</color>\n',point_color1);			% DGPS
		case 4, fprintf(fp,'      <color>ff%s</color>\n',point_color2);			% Float
		case 5, fprintf(fp,'      <color>ff%s</color>\n',point_color1);			% Fix
		end
		fprintf(fp,'      <Icon><href>http://maps.google.com/mapfiles/kml/pal2/icon26.png</href></Icon>\n');
		fprintf(fp,'    </IconStyle>\n');
		fprintf(fp,'  </Style>\n');
		fprintf(fp,'  <Point>\n');
	%	fprintf(fp,'    <extrude>1</extrude>\n');
	%	fprintf(fp,'    <altitudeMode>absolute</altitudeMode>\n');
		fprintf(fp,'    <coordinates>%15.9f,%15.9f,%15.9f</coordinates>\n',pos(n,2),pos(n,1),pos(n,3)-h);
		fprintf(fp,'  </Point>\n');
		fprintf(fp,'</Placemark>\n');
	end
	fprintf(fp,'</Folder>\n');

	% 本文終了
	%--------------------------------------------
	fprintf(fp,'</Document>\n');

	% ファイル終端
	%--------------------------------------------
	fprintf(fp,'</kml>\n');

	fclose('all');
end

if isempty(i)
	msgbox('KMLファイルを出力できませんでした.','Message','error','modal');
else
	msgbox('KMLファイルを出力しました.','Message','modal');
end



function output_statis(p)
%-------------------------------------------------------------------------------
% Function : 統計量(平均, 標準偏差, RMS)の出力
% 
% [argin]
% result  : 推定結果構造体(*.time:時刻, *.pos:位置)
% est_prm : パラメータ設定値(推定時刻, 真値などを利用)
% mode    : Tex出力
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

% 平均, 標準偏差, RMS
%--------------------------------------------
switch p.opt.plot
case 1, heikin=p.heikin6; stdd=p.stdd6;rms=p.rms6; pmode='ALL';
case 2, heikin=p.heikin0; stdd=p.stdd0;rms=p.rms0; pmode='SPP';
case 3, heikin=p.heikin1; stdd=p.stdd1;rms=p.rms1; pmode='PPP';
case 4, heikin=p.heikin2; stdd=p.stdd2;rms=p.rms2; pmode='VPPP';
case 5, heikin=p.heikin3; stdd=p.stdd3;rms=p.rms3; pmode='DGPS';
case 6, heikin=p.heikin4; stdd=p.stdd4;rms=p.rms4; pmode='Float';
case 7, heikin=p.heikin5; stdd=p.stdd5;rms=p.rms5; pmode='Fix';
end

% 画面表示
%--------------------------------------------
% fprintf('\n      & Bias[m] &  STD[m] &  RMS[m] \n');
% fprintf('East  & % 6.4f & % 6.4f & % 6.4f \n',heikin(1),stdd(1),rms(1));
% fprintf('North & % 6.4f & % 6.4f & % 6.4f \n',heikin(2),stdd(2),rms(2));
% fprintf('Up    & % 6.4f & % 6.4f & % 6.4f \n',heikin(3),stdd(3),rms(3));
% fprintf('2D    & % 6.4f & % 6.4f & % 6.4f \n\n',sqrt(sum(heikin(1:2).^2)),sqrt(sum(stdd(1:2).^2)),sqrt(sum(rms(1:2).^2)));

% 画面表示(Tex用)
%--------------------------------------------
if ~isempty(heikin)
	fprintf('\n\\begin{table}[htbp] \n');
	fprintf('\\begin{center} \n');
	fprintf('\\caption{Summary statistics} \n');
	fprintf('\\begin{tabular}{|c|c|c|c|c|} \\hline \n');

	fprintf('Method & Dir.  & Bias[m] &  STD[m] &  RMS[m] \\\\ \\hline\\hline \n');
	fprintf('\\multirow{4}*{%s} \n',pmode);
	fprintf('       & East  & % 6.4f & % 6.4f & % 6.4f \\\\ \\cline{2-5} \n',heikin(1),stdd(1),rms(1));
	fprintf('       & North & % 6.4f & % 6.4f & % 6.4f \\\\ \\cline{2-5} \n',heikin(2),stdd(2),rms(2));
	fprintf('       & Up    & % 6.4f & % 6.4f & % 6.4f \\\\ \\cline{2-5} \n',heikin(3),stdd(3),rms(3));
	fprintf('       & 2D    & % 6.4f & % 6.4f & % 6.4f \\\\ \\hline \n',sqrt(sum(heikin(1:2).^2)),sqrt(sum(stdd(1:2).^2)),sqrt(sum(rms(1:2).^2)));

	fprintf('\\end{tabular} \n');
	fprintf('\\end{center} \n');
	fprintf('\\end{table} \n\n');
end