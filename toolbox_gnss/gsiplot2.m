function varargout = gsiplot2(varargin)
% GSIPLOT2 M-file for gsiplot2.fig
%      GSIPLOT2, by itself, creates a new GSIPLOT2 or raises the existing
%      singleton*.
%
%      H = GSIPLOT2 returns the handle to a new GSIPLOT2 or the handle to
%      the existing singleton*.
%
%      GSIPLOT2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GSIPLOT2.M with the given input arguments.
%
%      GSIPLOT2('Property','Value',...) creates a new GSIPLOT2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gsiplot_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gsiplot2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gsiplot2

% Last Modified by GUIDE v2.5 20-Apr-2009 21:53:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gsiplot2_OpeningFcn, ...
                   'gui_OutputFcn',  @gsiplot2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gsiplot2 is made visible.
function gsiplot2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gsiplot2 (see VARARGIN)

% Choose default command line output for gsiplot2
handles.output = hObject;

% スクリーンの中央で起動
movegui(gcf,'center');

% 初期値の設定
handles.year            = [];
handles.month           = [];
handles.day             = [];
handles.mjd             = [];
handles.ken_rov         = [];
handles.posid_rov       = [];
handles.posname_rov     = [];
handles.ken_ref         = [];
handles.posid_ref       = [];
handles.posname_ref     = [];

handles.hdl_rov =[];
handles.hdl_ref =[];
handles.hdl_BL  =[];
handles.hdl_rovn=[];
handles.hdl_refn=[];
handles.hdl_BLn =[];

year_df = {'Y','2009','2008','2007','2006','2005','2004','2003','2002','2001','2000'};
month_df = {'M','01','02','03','04','05','06','07','08','09','10','11','12'};
day_df = {'D','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15'...
		'16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'};
ken_df = {'選択してください.','北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県','埼玉県'...
		'千葉県','東京都','神奈川県','新潟県','富山県','石川県','福井県','山梨県','長野県','岐阜県','静岡県','愛知県'...
		'三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県','鳥取県','島根県','岡山県','広島県','山口県'...
		'徳島県','香川県','愛媛県','高知県','福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県','沖縄県'};

set(handles.popupmenu_year,'string',year_df);
% set(handles.popupmenu_year,'enable','off','userdata',1);
% set(handles.listbox_rov,'enable','off','userdata',1);
% set(handles.popupmenu_year,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.popupmenu_month,'string',month_df);
% set(handles.popupmenu_month,'enable','off','userdata',1);
% set(handles.listbox_rov,'enable','off','userdata',1);
% set(handles.popupmenu_month,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.popupmenu_day,'string',day_df);
% set(handles.popupmenu_day,'enable','off','userdata',1);
% set(handles.listbox_rov,'enable','off','userdata',1);
% set(handles.popupmenu_day,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));

set(handles.popupmenu_rov,'string',ken_df);
% set(handles.popupmenu_rov,'enable','off','userdata',1);
% set(handles.listbox_rov,'enable','off','userdata',1);
set(handles.popupmenu_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.listbox_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));

set(handles.popupmenu_ref,'string',ken_df);
% set(handles.popupmenu_ref,'enable','off','userdata',1);
% set(handles.listbox_ref,'enable','off','userdata',1);
set(handles.popupmenu_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.listbox_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));

set(handles.listbox_rov,'enable','off','userdata',1);
set(handles.edit_id_rov,'enable','off','userdata',1);
set(handles.edit_lat_rov,'enable','off','userdata',1);
set(handles.edit_lon_rov,'enable','off','userdata',1);
set(handles.edit_h_rov,'enable','off','userdata',1);
set(handles.edit_rcv_rov,'enable','off','userdata',1);
set(handles.edit_ant_rov,'enable','off','userdata',1);
set(handles.listbox_ref,'enable','off','userdata',1);
set(handles.edit_id_ref,'enable','off','userdata',1);
set(handles.edit_lat_ref,'enable','off','userdata',1);
set(handles.edit_lon_ref,'enable','off','userdata',1);
set(handles.edit_h_ref,'enable','off','userdata',1);
set(handles.edit_rcv_ref,'enable','off','userdata',1);
set(handles.edit_ant_ref,'enable','off','userdata',1);

set(handles.edit_BL,'enable','off','userdata',1);
set(handles.pushbutton2,'enable','off','userdata',1);
set(handles.edit_BL,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));

set(handles.listbox_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_id_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_lat_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_lon_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_h_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_rcv_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_ant_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.listbox_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_id_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_lat_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_lon_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_h_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_rcv_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
set(handles.edit_ant_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));


% 日本地図プロット
hold on, box on, axis equal, grid on
plot_map;
xlabel('Longitude [deg.]');									% X軸のラベル
ylabel('Latitude [deg.]');									% Y軸のラベル
xlim([120,155]), ylim([20,50]);
title('GSI Stations Map','fontsize',10);
% set(gca,'xcolor',[0.4 0.4 0.4]);
% set(gca,'ycolor',[0.4 0.4 0.4]);
% set(get(gca,'Title'),'Color','k');
% set(get(gca,'XLabel'),'Color','k');
% set(get(gca,'YLabel'),'Color','k');
% zoom on;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gsiplot2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gsiplot2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 観測日時の取得
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% --- Executes on selection change in popupmenu_year.
function popupmenu_year_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_year contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_year

i = get(hObject,'Value');
year = {'Y','2009','2008','2007','2006','2005','2004','2003','2002','2001','2000'};
handles.year = year{i};
handles.year = str2num(handles.year);

% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_year_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_month.
function popupmenu_month_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_month contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_month

i = get(hObject,'Value');
month = {'M','01','02','03','04','05','06','07','08','09','10','11','12'};
handles.month = month{i};
handles.month = str2num(handles.month);

% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_month_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_day.
function popupmenu_day_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_day contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_day

i = get(hObject,'Value');
	day = {'D','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15'...
		'16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'};
	handles.day = day{i};
	handles.day = str2num(handles.day);

% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_day_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 都道府県名の取得
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% --- Executes on selection change in popupmenu_rov.
function popupmenu_rov_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_rov contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_rov

if ~isempty(handles.hdl_rov) | ~isempty(handles.hdl_ref)
	delete(handles.hdl_rov); delete(handles.hdl_ref); delete(handles.hdl_BL);
	delete(handles.hdl_rovn); delete(handles.hdl_refn); delete(handles.hdl_BLn);
	handles.hdl_rov=[]; handles.hdl_ref=[]; handles.hdl_BL=[];
	handles.hdl_rovn=[]; handles.hdl_refn=[]; handles.hdl_BLn=[];

	set(handles.edit_BL, 'String','');
end

i = get(hObject,'Value');
ken = {'','北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県','埼玉県'...
		'千葉県','東京都','神奈川県','新潟県','富山県','石川県','福井県','山梨県','長野県','岐阜県','静岡県','愛知県'...
		'三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県','鳥取県','島根県','岡山県','広島県','山口県'...
		'徳島県','香川県','愛媛県','高知県','福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県','沖縄県'};
handles.ken_rov = ken{i};
% if i~=1
if i~=1 & ~isempty(handles.year) & ~isempty(handles.month) & ~isempty(handles.day)
	times=[handles.year, handles.month, handles.day];
	handles.mjd = mjuliday(times);						% time の Modified Julian day
	handles.fileList_rov = recpos_mod(handles.mjd, handles.ken_rov);
	handles.nFile_rov = length(handles.fileList_rov(:,3));
	set(handles.listbox_rov, 'Value', 1);
	set(handles.listbox_rov, 'String', handles.fileList_rov(:,3));
	% posid default set
	handles.posid_rov = handles.fileList_rov{1,2};
	handles.posname_rov = handles.fileList_rov{1,3};
	handles.rec_name_rov{1} = handles.fileList_rov{1,4};
	handles.rec_name_rov{2} = handles.fileList_rov{1,5};
	handles.posllh_rov{1} = handles.fileList_rov{1,6};
	handles.posllh_rov{2} = handles.fileList_rov{1,7};
	handles.posllh_rov{3} = handles.fileList_rov{1,8};
	set(handles.edit_id_rov, 'String', handles.posid_rov);
	set(handles.edit_lat_rov, 'String', handles.posllh_rov{1});
	set(handles.edit_lon_rov, 'String', handles.posllh_rov{2});
	set(handles.edit_h_rov, 'String', handles.posllh_rov{3});
	set(handles.edit_rcv_rov, 'String', handles.rec_name_rov{1});
	set(handles.edit_ant_rov, 'String', handles.rec_name_rov{2});

	set(handles.listbox_rov,'enable','on','userdata',1);
	set(handles.edit_id_rov,'enable','on','userdata',1);
	set(handles.edit_lat_rov,'enable','on','userdata',1);
	set(handles.edit_lon_rov,'enable','on','userdata',1);
	set(handles.edit_h_rov,'enable','on','userdata',1);
	set(handles.edit_rcv_rov,'enable','on','userdata',1);
	set(handles.edit_ant_rov,'enable','on','userdata',1);
	set(handles.edit_BL,'enable','on','userdata',1);
	if ~isempty(handles.ken_ref)
		set(handles.pushbutton2,'enable','on','userdata',1);
	end
	set(handles.listbox_rov,'BackgroundColor','white');
	set(handles.edit_id_rov,'BackgroundColor','white');
	set(handles.edit_lat_rov,'BackgroundColor','white');
	set(handles.edit_lon_rov,'BackgroundColor','white');
	set(handles.edit_h_rov,'BackgroundColor','white');
	set(handles.edit_rcv_rov,'BackgroundColor','white');
	set(handles.edit_ant_rov,'BackgroundColor','white');
	set(handles.edit_BL,'BackgroundColor','white');
else
	set(handles.listbox_rov, 'Value', 1);
	set(handles.listbox_rov, 'String', '選択してください.');
	set(handles.edit_id_rov, 'String', '');
	set(handles.edit_lat_rov, 'String', '');
	set(handles.edit_lon_rov, 'String', '');
	set(handles.edit_h_rov, 'String', '');
	set(handles.edit_rcv_rov, 'String','');
	set(handles.edit_ant_rov, 'String','');
	set(handles.edit_BL, 'String','');
	handles.posid_rov = [];
	handles.posname_rov = [];

	set(handles.listbox_rov,'enable','off','userdata',1);
	set(handles.edit_id_rov,'enable','off','userdata',1);
	set(handles.edit_lat_rov,'enable','off','userdata',1);
	set(handles.edit_lon_rov,'enable','off','userdata',1);
	set(handles.edit_h_rov,'enable','off','userdata',1);
	set(handles.edit_rcv_rov,'enable','off','userdata',1);
	set(handles.edit_ant_rov,'enable','off','userdata',1);
	set(handles.edit_BL,'enable','off','userdata',1);
	set(handles.pushbutton2,'enable','off','userdata',1);

	set(handles.listbox_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_id_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_lat_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_lon_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_h_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_rcv_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_ant_rov,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_BL,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 電子基準点リスト
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% --- Executes on selection change in listbox_rov.
function listbox_rov_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_rov contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_rov

% set(handles.message,'String','');

if ~isempty(handles.hdl_rov) | ~isempty(handles.hdl_ref)
	delete(handles.hdl_rov); delete(handles.hdl_ref); delete(handles.hdl_BL);
	delete(handles.hdl_rovn); delete(handles.hdl_refn); delete(handles.hdl_BLn);
	handles.hdl_rov=[]; handles.hdl_ref=[]; handles.hdl_BL=[];
	handles.hdl_rovn=[]; handles.hdl_refn=[]; handles.hdl_BLn=[];

	set(handles.edit_BL, 'String','');
end

contents = get(hObject,'String');
fileNumber = get(hObject,'Value');
if isempty(strmatch('選択',contents))
	handles.posid_rov = handles.fileList_rov{fileNumber,2};
	handles.posname_rov = contents{fileNumber};
	handles.rec_name_rov{1} = handles.fileList_rov{fileNumber,4};
	handles.rec_name_rov{2} = handles.fileList_rov{fileNumber,5};
	handles.posllh_rov{1} = handles.fileList_rov{fileNumber,6};
	handles.posllh_rov{2} = handles.fileList_rov{fileNumber,7};
	handles.posllh_rov{3} = handles.fileList_rov{fileNumber,8};
	set(handles.edit_id_rov, 'String', handles.posid_rov);
	set(handles.edit_lat_rov, 'String', handles.posllh_rov{1});
	set(handles.edit_lon_rov, 'String', handles.posllh_rov{2});
	set(handles.edit_h_rov, 'String', handles.posllh_rov{3});
	set(handles.edit_rcv_rov, 'String', handles.rec_name_rov{1});
	set(handles.edit_ant_rov, 'String', handles.rec_name_rov{2});
end

% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 電子基準点ID
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_id_rov_Callback(hObject, eventdata, handles)
% hObject    handle to edit_id_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_id_rov as text
%        str2double(get(hObject,'String')) returns contents of edit_id_rov as a double


% --- Executes during object creation, after setting all properties.
function edit_id_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_id_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 緯度表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_lat_rov_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lat_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lat_rov as text
%        str2double(get(hObject,'String')) returns contents of edit_lat_rov as a double


% --- Executes during object creation, after setting all properties.
function edit_lat_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lat_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 経度表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_lon_rov_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lon_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lon_rov as text
%        str2double(get(hObject,'String')) returns contents of edit_lon_rov as a double


% --- Executes during object creation, after setting all properties.
function edit_lon_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lon_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 高度表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_h_rov_Callback(hObject, eventdata, handles)
% hObject    handle to edit_h_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_h_rov as text
%        str2double(get(hObject,'String')) returns contents of edit_h_rov as a double


% --- Executes during object creation, after setting all properties.
function edit_h_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_h_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 都道府県名の取得
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% --- Executes on selection change in popupmenu_ref.
function popupmenu_ref_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_ref contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_ref

if ~isempty(handles.hdl_rov) | ~isempty(handles.hdl_ref)
	delete(handles.hdl_rov); delete(handles.hdl_ref); delete(handles.hdl_BL);
	delete(handles.hdl_rovn); delete(handles.hdl_refn); delete(handles.hdl_BLn);
	handles.hdl_rov=[]; handles.hdl_ref=[]; handles.hdl_BL=[];
	handles.hdl_rovn=[]; handles.hdl_refn=[]; handles.hdl_BLn=[];

	set(handles.edit_BL, 'String','');
end

i = get(hObject,'Value');
ken = {'','北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県','埼玉県'...
		'千葉県','東京都','神奈川県','新潟県','富山県','石川県','福井県','山梨県','長野県','岐阜県','静岡県','愛知県'...
		'三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県','鳥取県','島根県','岡山県','広島県','山口県'...
		'徳島県','香川県','愛媛県','高知県','福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県','沖縄県'};
handles.ken_ref = ken{i};
if i~=1 & ~isempty(handles.year) & ~isempty(handles.month) & ~isempty(handles.day)
	times=[handles.year, handles.month, handles.day];
	handles.mjd = mjuliday(times);						% time の Modified Julian day
	handles.fileList_ref = recpos_mod(handles.mjd, handles.ken_ref);
	handles.nFile_ref = length(handles.fileList_ref(:,3));
	set(handles.listbox_ref, 'Value', 1);
	set(handles.listbox_ref, 'String', handles.fileList_ref(:,3));
	% posid default set
	handles.posid_ref = handles.fileList_ref{1,2};
	handles.posname_ref = handles.fileList_ref{1,3};
	handles.rec_name_ref{1} = handles.fileList_ref{1,4};
	handles.rec_name_ref{2} = handles.fileList_ref{1,5};
	handles.posllh_ref{1} = handles.fileList_ref{1,6};
	handles.posllh_ref{2} = handles.fileList_ref{1,7};
	handles.posllh_ref{3} = handles.fileList_ref{1,8};
	set(handles.edit_id_ref, 'String', handles.posid_ref);
	set(handles.edit_lat_ref, 'String', handles.posllh_ref{1});
	set(handles.edit_lon_ref, 'String', handles.posllh_ref{2});
	set(handles.edit_h_ref, 'String', handles.posllh_ref{3});
	set(handles.edit_rcv_ref, 'String', handles.rec_name_ref{1});
	set(handles.edit_ant_ref, 'String', handles.rec_name_ref{2});

	set(handles.listbox_ref,'enable','on','userdata',1);
	set(handles.edit_id_ref,'enable','on','userdata',1);
	set(handles.edit_lat_ref,'enable','on','userdata',1);
	set(handles.edit_lon_ref,'enable','on','userdata',1);
	set(handles.edit_h_ref,'enable','on','userdata',1);
	set(handles.edit_rcv_ref,'enable','on','userdata',1);
	set(handles.edit_ant_ref,'enable','on','userdata',1);
	set(handles.edit_BL,'enable','on','userdata',1);
	if ~isempty(handles.ken_rov)
		set(handles.pushbutton2,'enable','on','userdata',1);
	end
	set(handles.listbox_ref,'BackgroundColor','white');
	set(handles.edit_id_ref,'BackgroundColor','white');
	set(handles.edit_lat_ref,'BackgroundColor','white');
	set(handles.edit_lon_ref,'BackgroundColor','white');
	set(handles.edit_h_ref,'BackgroundColor','white');
	set(handles.edit_rcv_ref,'BackgroundColor','white');
	set(handles.edit_ant_ref,'BackgroundColor','white');
	set(handles.edit_BL,'BackgroundColor','white');
else
	set(handles.listbox_ref, 'Value', 1);
	set(handles.listbox_ref, 'String', '選択してください.');
	set(handles.edit_id_ref, 'String', '');
	set(handles.edit_lat_ref, 'String', '');
	set(handles.edit_lon_ref, 'String', '');
	set(handles.edit_h_ref, 'String', '');
	set(handles.edit_rcv_ref, 'String','');
	set(handles.edit_ant_ref, 'String','');
	set(handles.edit_BL, 'String','');
	handles.posid_ref = [];
	handles.posname_ref = [];

	set(handles.listbox_ref,'enable','off','userdata',1);
	set(handles.edit_id_ref,'enable','off','userdata',1);
	set(handles.edit_lat_ref,'enable','off','userdata',1);
	set(handles.edit_lon_ref,'enable','off','userdata',1);
	set(handles.edit_h_ref,'enable','off','userdata',1);
	set(handles.edit_rcv_ref,'enable','off','userdata',1);
	set(handles.edit_ant_ref,'enable','off','userdata',1);
	set(handles.edit_BL,'enable','off','userdata',1);
	set(handles.pushbutton2,'enable','off','userdata',1);

	set(handles.listbox_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_id_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_lat_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_lon_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_h_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_rcv_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_ant_ref,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	set(handles.edit_BL,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 電子基準点リスト
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% --- Executes on selection change in listbox_ref.
function listbox_ref_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_ref contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_ref

if ~isempty(handles.hdl_rov) | ~isempty(handles.hdl_ref)
	delete(handles.hdl_rov); delete(handles.hdl_ref); delete(handles.hdl_BL);
	delete(handles.hdl_rovn); delete(handles.hdl_refn); delete(handles.hdl_BLn);
	handles.hdl_rov=[]; handles.hdl_ref=[]; handles.hdl_BL=[];
	handles.hdl_rovn=[]; handles.hdl_refn=[]; handles.hdl_BLn=[];

	set(handles.edit_BL, 'String','');
end

contents = get(hObject,'String');
fileNumber = get(hObject,'Value');
if isempty(strmatch('選択',contents))
	handles.posid_ref = handles.fileList_ref{fileNumber,2};
	handles.posname_ref = contents{fileNumber};
	handles.rec_name_ref{1} = handles.fileList_ref{fileNumber,4};
	handles.rec_name_ref{2} = handles.fileList_ref{fileNumber,5};
	handles.posllh_ref{1} = handles.fileList_ref{fileNumber,6};
	handles.posllh_ref{2} = handles.fileList_ref{fileNumber,7};
	handles.posllh_ref{3} = handles.fileList_ref{fileNumber,8};
	set(handles.edit_id_ref, 'String', handles.posid_ref);
	set(handles.edit_lat_ref, 'String', handles.posllh_ref{1});
	set(handles.edit_lon_ref, 'String', handles.posllh_ref{2});
	set(handles.edit_h_ref, 'String', handles.posllh_ref{3});
	set(handles.edit_rcv_ref, 'String', handles.rec_name_ref{1});
	set(handles.edit_ant_ref, 'String', handles.rec_name_ref{2});
end

% save data into 'handles'
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 電子基準点ID
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_id_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_id_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_id_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_id_ref as a double


% --- Executes during object creation, after setting all properties.
function edit_id_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_id_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 緯度表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_lat_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lat_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lat_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_lat_ref as a double


% --- Executes during object creation, after setting all properties.
function edit_lat_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lat_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 経度表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_lon_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lon_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lon_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_lon_ref as a double


% --- Executes during object creation, after setting all properties.
function edit_lon_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lon_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 高度表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_h_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_h_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_h_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_h_ref as a double


% --- Executes during object creation, after setting all properties.
function edit_h_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_h_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% 基線長表示
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function edit_BL_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BL as text
%        str2double(get(hObject,'String')) returns contents of edit_BL as a double


% --- Executes during object creation, after setting all properties.
function edit_BL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% プロット
%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.hdl_rov) | ~isempty(handles.hdl_ref)
	delete(handles.hdl_rov); delete(handles.hdl_ref); delete(handles.hdl_BL);
	delete(handles.hdl_rovn); delete(handles.hdl_refn); delete(handles.hdl_BLn);
	handles.hdl_rov=[]; handles.hdl_ref=[]; handles.hdl_BL=[];
	handles.hdl_rovn=[]; handles.hdl_refn=[]; handles.hdl_BLn=[];
end

hold on, box on, axis equal, grid on
lon_rov=str2num(handles.posllh_rov{2});
lat_rov=str2num(handles.posllh_rov{1});
h_rov  =str2num(handles.posllh_rov{3});
lon_ref=str2num(handles.posllh_ref{2});
lat_ref=str2num(handles.posllh_ref{1});
h_ref  =str2num(handles.posllh_ref{3});
handles.hdl_rov=plot(lon_rov,lat_rov,'.b','markersize',20);
handles.hdl_ref=plot(lon_ref,lat_ref,'.r','markersize',20);
handles.hdl_BL =line([lon_rov,lon_ref],[lat_rov,lat_ref],'color',[0,0.5,0],'linewidth',2);
% xlabel('Longitude [deg.]');									% X軸のラベル
% ylabel('Latitude [deg.]');									% Y軸のラベル
xlim([120,155]), ylim([20,50]);
legend([handles.hdl_rov,handles.hdl_ref,handles.hdl_BL],'Rover','Reference','Baseline','Location','SouthEast');
handles.hdl_rovn=text(lon_rov-0.2,lat_rov,handles.posid_rov,'fontname','times','FontSize',14,'color','b','fontweight','demi','HorizontalAlignment','right');
handles.hdl_refn=text(lon_ref+0.2,lat_ref,handles.posid_ref,'fontname','times','FontSize',14,'color','r','fontweight','demi');

xyz_rov = llh2xyz([lat_rov,lon_rov,h_rov].*[pi/180,pi/180,1]);
xyz_ref = llh2xyz([lat_ref,lon_ref,h_ref].*[pi/180,pi/180,1]);
baseline=norm(xyz_rov-xyz_ref);
handles.hdl_BLn=text((lon_rov+lon_ref)/2+0.2,(lat_rov+lat_ref)/2,sprintf('%.3fkm',baseline*1e-3),'fontname','times','FontSize',14,'color',[0,0.5,0],'fontweight','demi');

hold off

set(handles.edit_BL, 'String', sprintf('%.3f',baseline*1e-3));

% save data into 'handles'
guidata(hObject,handles);


function edit_rcv_rov_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rcv_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rcv_rov as text
%        str2double(get(hObject,'String')) returns contents of edit_rcv_rov as a double


% --- Executes during object creation, after setting all properties.
function edit_rcv_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rcv_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_ant_rov_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ant_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ant_rov as text
%        str2double(get(hObject,'String')) returns contents of edit_ant_rov as a double


% --- Executes during object creation, after setting all properties.
function edit_ant_rov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ant_rov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_rcv_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rcv_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rcv_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_rcv_ref as a double


% --- Executes during object creation, after setting all properties.
function edit_rcv_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rcv_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_ant_ref_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ant_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ant_ref as text
%        str2double(get(hObject,'String')) returns contents of edit_ant_ref as a double


% --- Executes during object creation, after setting all properties.
function edit_ant_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ant_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in togglebutton_move.
function togglebutton_move_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_move

if get(hObject,'Value')
	zoom off;
	set(handles.togglebutton_zoom,'Value',0);
	set(handles.togglebutton_zoom,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	pan on;
	set(hObject,'BackgroundColor','white');
else
	pan off;
	set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in togglebutton_zoom.
function togglebutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_zoom

if get(hObject,'Value')
	pan off;
	set(handles.togglebutton_move,'Value',0);
	set(handles.togglebutton_move,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	zoom on;
	set(hObject,'BackgroundColor','white');
else
	zoom off;
	set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function plot_map(s)
%
% 海岸線地図のプロット(海岸線データはgshhs_l.bを利用)
%
% [argin]
% s : カラー設定
% 
% [argout]
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 27, 2007

% persistent src
% if isempty(src), load('gshhs_l_map_mod'); end

% for a=src
% 	lon=a.Lon; lon(abs(diff(lon))>180)=NaN;
% 	if nargin==1
% 		plot(lon,a.Lat,s);
% 	else
% 		plot(lon,a.Lat,'color',[0.4 0.4 0.4]);
% 	end
% end

persistent xlon ylat
if isempty(xlon)|isempty(ylat), load('gshhs_l_map_mod'); end
if nargin==1
	plot(xlon,ylat,s);
else
	plot(xlon,ylat,'color',[0.4 0.4 0.4]);
end



function mjd = mjuliday(time)
%-------------------------------------------------------------------------------
% Function : Modified Julian day の計算
%
% [argin]
% time : 時刻 [Y,M,D,H,M,S]
%
% [argout]
% mjd : Modified JUlian day
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 21, 2008
%-------------------------------------------------------------------------------

if time(2) <= 2
   time(1) = time(1)-1; 
   time(2) = time(2)+12;
end
mjd = floor(365.25*time(1))+floor(30.6001*(time(2)+1))+time(3)+1720981.5 - 2400000.5;
% if length(time)>3,mjd=mjd+time(4)/24+time(5)/1440+time(6)/86400;,end


function xyz = llh2xyz(llh)
%-------------------------------------------------------------------------------
% Function : LLH (緯度, 経度, 楕円体高) 座標系から WGS-84 直交座標系への座標変換
% ・近似による計算
% ・繰返し計算
%
% [argin]
% llh(1:3) : 緯度[rad], 経度[rad], 楕円体高[m]
%
% [argout]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

lat = llh(1);							% 緯度[rad]
lon = llh(2);							% 経度[rad]
h   = llh(3);							% 楕円体高[m]

a = 6378137.0000;						% 赤道半径
b = 6356752.3142;						% 極半径

e=sqrt(a^2-b^2)/a;
N=a/sqrt(1-e^2*sin(lat)^2);

x=(N+h)*cos(lat)*cos(lon);				% X(ECEF)
y=(N+h)*cos(lat)*sin(lon);				% Y(ECEF)
z=(N*(1-e^2)+h)*sin(lat);				% Z(ECEF)

xyz = [x,y,z];							% ECEF座標 X, Y, Z [m]


function posid = recpos_mod(mjd, pos)
%-------------------------------------------------------------------------------
% 電子基準点の局番号検索
% 
% [argin]
% mjd : 観測日時のmujuliday
% pos : 都道府県名(全角文字列)
% 
% [argout]
% posid : 局情報(文字列)--cell配列
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct 19, 2008
%-------------------------------------------------------------------------------
persistent list
date_of_update = [
% 					2004, 07, 01;
% 					2004, 07, 21;
% 					2005, 03, 01;
% 					2005, 12, 01;
% 					2007, 01, 15;
% 					2007, 12, 03;
					2008, 06, 25;
					2008, 07, 01;
					2008, 08, 21;
					2008, 08, 25;
					2008, 08, 26;
					2008, 09, 12;
					2008, 09, 16;
					2008, 10, 27;
					2008, 10, 28;
					2008, 10, 29;
					2008, 10, 30;
					2008, 10, 31;
					2008, 11, 05;
					2008, 11, 06;
					2008, 11, 07;
					2008, 12, 10;
					2008, 12, 11;
					2008, 12, 12;
					2008, 12, 15;
					2008, 12, 16;
					2008, 12, 17;
					2008, 12, 18;
					2008, 12, 19;
					2008, 12, 20;
					2008, 12, 22;
					2009, 02, 05;
					2009, 02, 06;
					2009, 02, 09;
					2009, 02, 10;
					2009, 02, 12;
					2009, 02, 13;
					2009, 02, 16;
					2009, 02, 17;
					2009, 02, 18;
					2009, 02, 19;
					2009, 02, 20];
date_of_change = [];
for n=1:36
	date_of_change = [date_of_change; mjuliday(date_of_update(n,:))];
end

addpath ./poslist/
% 	dirs=[fileparts(which('p1c1bias')),'/P1C1DCB/'];					% ディレクトリ
% 	filen=sprintf('%sP1C1%02d%02d.DCB',dirs,mod(time(1),100),time(2));	% ファイル名
% 	fpo=fopen(filen,'rt');												% ファイルオープン

% if isempty(list)
	if mjd >= date_of_change(36), load('poslist20090220');
		elseif mjd >= date_of_change(35), load('poslist20090219');
		elseif mjd >= date_of_change(34), load('poslist20090218');
		elseif mjd >= date_of_change(33), load('poslist20090217');
		elseif mjd >= date_of_change(32), load('poslist20090216');
		elseif mjd >= date_of_change(31), load('poslist20090213');
		elseif mjd >= date_of_change(30), load('poslist20090212');
		elseif mjd >= date_of_change(29), load('poslist20090210');
		elseif mjd >= date_of_change(28), load('poslist20090209');
		elseif mjd >= date_of_change(27), load('poslist20090206');
		elseif mjd >= date_of_change(26), load('poslist20090205');
		elseif mjd >= date_of_change(25), load('poslist20081222');
		elseif mjd >= date_of_change(24), load('poslist20081220');
		elseif mjd >= date_of_change(23), load('poslist20081219');
		elseif mjd >= date_of_change(22), load('poslist20081218');
		elseif mjd >= date_of_change(21), load('poslist20081217');
		elseif mjd >= date_of_change(20), load('poslist20081216');
		elseif mjd >= date_of_change(19), load('poslist20081215');
		elseif mjd >= date_of_change(18), load('poslist20081212');
		elseif mjd >= date_of_change(17), load('poslist20081211');
		elseif mjd >= date_of_change(16), load('poslist20081210');
		elseif mjd >= date_of_change(15), load('poslist20081107');
		elseif mjd >= date_of_change(14), load('poslist20081106');
		elseif mjd >= date_of_change(13), load('poslist20081105');
		elseif mjd >= date_of_change(12), load('poslist20081031');
		elseif mjd >= date_of_change(11), load('poslist20081030');
		elseif mjd >= date_of_change(10), load('poslist20081029');
		elseif mjd >= date_of_change(9), load('poslist20081028');
		elseif mjd >= date_of_change(8), load('poslist20081227');
		elseif mjd >= date_of_change(7), load('poslist20080916');
		elseif mjd >= date_of_change(6), load('poslist20080912');
		elseif mjd >= date_of_change(5), load('poslist20080826');
		elseif mjd >= date_of_change(4), load('poslist20080825');
		elseif mjd >= date_of_change(3), load('poslist20080821');
		elseif mjd >= date_of_change(2), load('poslist20080701');
		elseif mjd >= date_of_change(1), load('poslist20080625');
		elseif mjd <= date_of_change(1), load('poslist20080625');
	end
% end



if nargin==2
	index = strmatch(pos,list(:,3));
	id = list(index,[1,2,5,6,10:12]);
else
	index = 1:length(list(:,3));
	id = list(index,[1,2,5,6,10:12]);
end

for k=1:length(index)
	posid(k,:) = {num2str(k),id{k,:}};
end

% 
% 
% 	
% 	if handles.mjd <= date_of_change(1)
% 		handles.fileList_rov = recpos3(handles.ken_rov);
% 	elseif handles.mjd <= date_of_change(2,:)
% 		handles.fileList_rov = recpos4(handles.ken_rov);
% 	elseif handles.mjd <= date_of_change(3,:)
% 	
% 	elseif handles.mjd <= date_of_change(4,:)
% 	
% 	elseif handles.mjd <= date_of_change(5,:)
% 	
% 	elseif handles.mjd <= date_of_change(6,:)
% 	
% 	elseif handles.mjd <= date_of_change(7,:)
% 	
% 	elseif handles.mjd <= date_of_change(8,:)
% 		handles.fileList_rov = recpos2(handles.ken_rov);
% 	else
% 		handles.fileList_rov = recpos20090415(handles.ken_rov);
% 	end
% 	
% 	
% 	
	