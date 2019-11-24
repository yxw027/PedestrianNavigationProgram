function est_prm=fileget(est_prm)
%-------------------------------------------------------------------------------
% Function : ファイル名生成し,ダウンロードする
% 
% [argin]
% est_prm : 初期設定パラメータ(構造体)
%           .rcv    : 受信機番号(セル配列; 例:{'950322','950322'})
%           .ephsrc : 精密暦(文字列, 例:'igs', 'igr', 'igu')
%           .ionsrc : IONEX(文字列, 例:'igs', 'cod', 'jpl')
% 
% [argout]
% est_prm : 初期設定パラメータ(更新)
% 
% 2007,2008,2009年度のみの対応
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 23, 2009
%-------------------------------------------------------------------------------
% F3解に対応
% 現在F2, F3解のファイル名が同じなので, 比較の際は工夫する必要がある(名前の変更, 切り替え処理等)
% April 19, 2009, T.Yanase
%-------------------------------------------------------------------------------
% 2010年以降も対応(2012年まで)
% February 9, 2010, T.Yanase
%-------------------------------------------------------------------------------


fprintf('データファイルを取得します.\n');


%--- IPアドレスのチェック(ルータの内か外か)
%--------------------------------------------
[status, result] = dos('ipconfig /all');
[start, finish] = regexp(result, '\d*\.\d*\.\d*\.\d*');
ip_str = result(start(1):finish(1));
ip_num = str2num(strrep(ip_str,'.',' '));
if ip_num(1)==169
	flag=1;
else
	flag=0;
end

%--- start time の設定
%--------------------------------------------
if ~isempty(est_prm.stime)
	time_s=cal_time2(est_prm.stime);										% Start time の Juliday, WEEK, TOW, TOD
end

%--- end time の設定(現在は不要)
%--------------------------------------------
% if ~isempty(est_prm.etime)
% 	time_e=cal_time2(est_prm.etime);										% End time の Juliday, WEEK, TOW, TOD
% else
% 	time_e.day = [];
% 	time_e.mjd = 1e50;														% End time(mjd) に大きな値を割当
% end

%--- ファイル名生成の準備
%--------------------------------------------
for k=1:length(est_prm.rcv)
	if length(est_prm.rcv{k})>=4, rcvf{k}=est_prm.rcv{k}(end-3:end); else rcvf{k}=est_prm.rcv{k}; end
end
day=mjuliday(time_s.day(1:3))-mjuliday([time_s.day(1),1,1])+1;
gpsd=mjuliday(time_s.day(1:3))-44244; gpsw=floor(gpsd/7); gpsd=floor(gpsd-gpsw*7);

%--- ファイルダウンロードの準備
%--------------------------------------------
login = 'anonymous';											% ログインID
passwd = 'user@';												% ログインパスワード
host1 = 'terras.gsi.go.jp';										% GSI
host2 = 'cddis.gsfc.nasa.gov';									% IGS

if flag==1
	% ルータ内
	switch time_s.day(1)
	case 2007, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2008, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2009, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2010, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2011, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2012, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	end
else
	% ルータ外
	switch time_s.day(1)
	case 2007, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2008, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2009, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2010, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2011, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	case 2012, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% ネットワークドライブ(Kubolab-epson)
	end
end

%--- OBS,NAVダウンロード
%--------------------------------------------
if strcmp(est_prm.file.rov_o,'')
	est_prm.file.rov_o=sprintf('%s%03d%1d.%02do',rcvf{1},day,0,mod(time_s.day(1),100));		% GSI OBS(rov)
	fileo1 = sprintf('%4d/%03d/%s.%s',time_s.day(1),day,est_prm.file.rov_o,'gz');
% 	ftpdown2(host1,login,passwd,est_prm.dirs.obs,fileo1);
	ftpdown3(host3,est_prm.dirs.obs,fileo1);
	uncompact(est_prm.dirs.obs,[est_prm.file.rov_o,'.gz']);
end
if strcmp(est_prm.file.rov_n,'')
	est_prm.file.rov_n=sprintf('%s%03d%1d.%02dn',rcvf{1},day,0,mod(time_s.day(1),100));		% GSI NAV(rov)
	filen1 = sprintf('%4d/%03d/%s.%s',time_s.day(1),day,est_prm.file.rov_n,'gz');
% 	ftpdown2(host1,login,passwd,est_prm.dirs.obs,filen1);
	ftpdown3(host3,est_prm.dirs.obs,filen1);
	uncompact(est_prm.dirs.obs,[est_prm.file.rov_n,'.gz']);
end
if length(est_prm.rcv)==2
	if strcmp(est_prm.file.ref_o,'')
		est_prm.file.ref_o=sprintf('%s%03d%1d.%02do',rcvf{2},day,0,mod(time_s.day(1),100));	% GSI OBS(ref)
		fileo2 = sprintf('%4d/%03d/%s.%s',time_s.day(1),day,est_prm.file.ref_o,'gz');
% 		ftpdown2(host1,login,passwd,est_prm.dirs.obs,fileo2);
		ftpdown3(host3,est_prm.dirs.obs,fileo2);
		uncompact(est_prm.dirs.obs,[est_prm.file.ref_o,'.gz']);
	end
	if strcmp(est_prm.file.ref_n,'')
		est_prm.file.ref_n=sprintf('%s%03d%1d.%02dn',rcvf{2},day,0,mod(time_s.day(1),100));	% GSI NAV(ref)
		filen2 = sprintf('%4d/%03d/%s.%s',time_s.day(1),day,est_prm.file.ref_n,'gz');
% 		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filen2);
		ftpdown3(host3,est_prm.dirs.obs,filen2);
		uncompact(est_prm.dirs.obs,[est_prm.file.ref_n,'.gz']);
	end
end

%--- IONEXダウンロード
%--------------------------------------------
if strcmp(est_prm.file.ionex,'') & est_prm.i_mode==2
	est_prm.file.ionex =sprintf('%sg%03d%1d.%02di',est_prm.ionsrc,day,0,mod(time_s.day(1),100));		% IONEX IGS Final
	filei = sprintf('%s/%04d/%03d/%s.%s','/gps/products/ionex',time_s.day(1),day,est_prm.file.ionex,'Z');
	ftpdown2(host2,login,passwd,est_prm.dirs.ionex,filei);
	uncompact(est_prm.dirs.ionex,[est_prm.file.ionex,'.Z']);
end

%--- SP3ダウンロード
%--------------------------------------------
if strcmp(est_prm.file.sp3,'') & est_prm.sp3==1
	switch est_prm.ephsrc
		case {'igs','igr'}
		est_prm.file.sp3   =sprintf('%s%04d%1d.sp3',est_prm.ephsrc,gpsw,gpsd);							% SP3 IGS Final/Rapid
		case {'igu'}
		est_prm.file.sp3   =sprintf('%s%04d%1d_00.sp3',est_prm.ephsrc,gpsw,gpsd);						% SP3 IGS UltraRapid
	end
	files = sprintf('%s/%04d/%s.%s','/gps/products',gpsw,est_prm.file.sp3,'Z');
	ftpdown2(host2,login,passwd,est_prm.dirs.sp3,files);
	uncompact(est_prm.dirs.sp3,[est_prm.file.sp3,'.Z']);
end

%--- GSI F3解の取得
%--------------------------------------------
if isempty(est_prm.rovpos)
	%--- ファイル名生成
	%--------------------------------------------
	est_prm.file.rovpos=sprintf('%s.%02d.pos',est_prm.rcv{1},mod(time_s.day(1),100));					% GSI F3解(rov)
% 	est_prm.file.rovpos=sprintf('%s.%s.pos',est_prm.rcv{1},datestr(now,'yy'));							% GSI F2解(rov) 現在の年度

	%--- ファイルダウンロード(POS,GSIから)
	%--------------------------------------------
	switch time_s.day(1)
	case 2007
		filep1 = sprintf('%s/%4d/%s','/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		if flag==1
			% ルータ内
			ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep1);
		else
			% ルータ外
			ftpdown3('//133.19.153.121/gps/DATA/GEONET/',est_prm.dirs.obs,filep1);
		end
	case 2008
		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
	case 2009
		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
	case 2010
		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
	case 2011
		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
	case 2012
		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
	end
	est_prm.rovpos = f3gsi([est_prm.dirs.obs,est_prm.file.rovpos],time_s.day);
end
if length(est_prm.rcv)==2
	if isempty(est_prm.refpos)
		%--- ファイル名生成
		%--------------------------------------------
		est_prm.file.refpos=sprintf('%s.%02d.pos',est_prm.rcv{2},mod(time_s.day(1),100));				% GSI F3解(ref)
% 		est_prm.file.refpos=sprintf('%s.%s.pos',est_prm.rcv{2},datestr(now,'yy'));						% GSI F2解(rov) 現在の年度

		%--- ファイルダウンロード(POS,GSIから)
		%--------------------------------------------
		switch time_s.day(1)
		case 2007
			filep2 = sprintf('%s/%4d/%s','/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			if flag==1
				% ルータ内
				ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep2);
			else
				% ルータ外
				ftpdown3('//133.19.153.121/gps/DATA/GEONET/',est_prm.dirs.obs,filep2);
			end
		case 2008
			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
		case 2009
			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
		case 2010
			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
		case 2011
			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
		case 2012
			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
		end
		est_prm.refpos = f3gsi([est_prm.dirs.obs,est_prm.file.refpos],time_s.day);
	end
end

fprintf('データファイルを取得しました.\n');

% %--- GSI F2解の取得
% %--------------------------------------------
% if isempty(est_prm.rovpos)
% 	%--- ファイル名生成
% 	%--------------------------------------------
% 	est_prm.file.rovpos=sprintf('%s.%02d.pos',est_prm.rcv{1},mod(time_s.day(1),100));					% GSI F2解(rov)
% % 	est_prm.file.rovpos=sprintf('%s.%s.pos',est_prm.rcv{1},datestr(now,'yy'));						% GSI F2解(rov) 現在の年度
% 
% 	%--- ファイルダウンロード(POS,GSIから)
% 	%--------------------------------------------
% 	switch time_s.day(1)
% 	case 2007
% 		filep1 = sprintf('%s/%4d/%s','/coordinates_F2',time_s.day(1),est_prm.file.rovpos);
% 		if flag==1
% 			% ルータ内
% 			ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep1);
% 		else
% 			% ルータ外
% 			ftpdown3('//133.19.153.121/gps/DATA/GEONET/',est_prm.dirs.obs,filep1);
% 		end
% 	case 2008
% 		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F2',time_s.day(1),est_prm.file.rovpos);
% 		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
% 	case 2009
% 		filep1 = sprintf('%s/%4d/%s','/data/coordinates_F2',time_s.day(1),est_prm.file.rovpos);
% 		ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep1);
% 	end
% 	est_prm.rovpos = f2gsi([est_prm.dirs.obs,est_prm.file.rovpos],time_s.day);
% end
% if length(est_prm.rcv)==2
% 	if isempty(est_prm.refpos)
% 		%--- ファイル名生成
% 		%--------------------------------------------
% 		est_prm.file.refpos=sprintf('%s.%02d.pos',est_prm.rcv{2},mod(time_s.day(1),100));				% GSI F2解(ref)
% % 		est_prm.file.refpos=sprintf('%s.%s.pos',est_prm.rcv{2},datestr(now,'yy'));						% GSI F2解(rov) 現在の年度
% 
% 		%--- ファイルダウンロード(POS,GSIから)
% 		%--------------------------------------------
% 		switch time_s.day(1)
% 		case 2007
% 			filep2 = sprintf('%s/%4d/%s','/coordinates_F2',time_s.day(1),est_prm.file.refpos);
% 			if flag==1
% 				% ルータ内
% 				ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep2);
% 			else
% 				% ルータ外
% 				ftpdown3('//133.19.153.121/gps/DATA/GEONET/',est_prm.dirs.obs,filep2);
% 			end
% 		case 2008
% 			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F2',time_s.day(1),est_prm.file.refpos);
% 			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
% 		case 2009
% 			filep2 = sprintf('%s/%4d/%s','/data/coordinates_F2',time_s.day(1),est_prm.file.refpos);
% 			ftpdown2(host1,login,passwd,est_prm.dirs.obs,filep2);
% 		end
% 		est_prm.refpos = f2gsi([est_prm.dirs.obs,est_prm.file.refpos],time_s.day);
% 	end
% end
% 
% fprintf('データファイルを取得しました.\n');


%-------------------------------------------------------------------------------
% 以下, サブルーチン

function ftpdown2(host,login,passwd,ldir,file)
%-------------------------------------------------------------------------------
% Function : ファイルダウンロード
% 
% [argin]
% host   : ホスト
% login  : ログインユーザー名
% passwd : ログインパスワード
% ldir   : ローカルディレクトリ(保存先)
% file   : ダウンロードファイル(host以下のディレクトリ付きで)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 06, 2008
%-------------------------------------------------------------------------------

[dirs,f] = fileparts(which(mfilename));																	% wgetがこの関数と同じディレクトリなので
cmd = fullfile(dirs,'wget.exe');																		% wgetの実行のため(ディレクトリ付き)
opt = sprintf('--timestamping --ftp-user=%s --ftp-password=%s --glob=off --passive-ftp',login,passwd);	% wgetのオプション
wd=pwd;																									% カレントディレクトリ(メイン)
cd(ldir);																								% ローカルディレクトリ(保存先)に移動
[p,name,ext]=fileparts(file);
if exist(name)==0
	[stat,log] = dos(['"',cmd,'" ',opt,' ftp://',host,file]);											% wgetでDL
end
cd(wd);																									% カレントディレクトリ(メイン)に移動


function ftpdown3(host,ldir,file)
%-------------------------------------------------------------------------------
% Function : ファイルダウンロード(ローカルのディレクトリからコピー)
% 
% [argin]
% host   : ホスト
% ldir   : ローカルディレクトリ(保存先)
% file   : ダウンロードファイル(host以下のディレクトリ付きで)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 06, 2008
%-------------------------------------------------------------------------------

cmd=['xcopy ',host,file];
cmd=strrep(cmd,'/','\');									% "/"を"\"に置換
% opt=' /Y ';													% 同名のファイルが存在する場合、上書きの確認を行わない
opt=' /D ';													% コピー先に同名のファイルが存在する場合に更新日が新しいファイルのみコピーする
wd=pwd;														% カレントディレクトリ(メイン)
cd(ldir);													% ローカルディレクトリ(保存先)に移動
[p,name,ext]=fileparts(file);
if strcmp(ext,'.pos')										% posファイルの場合
	if exist([name,ext])==0
		[stat,log] = dos([cmd,opt]);						% xcopyでファイルコピー
	end
else														% posファイル以外(圧縮ファイル)
	if exist(name)==0
		[stat,log] = dos([cmd,opt]);						% xcopyでファイルコピー
	end
end
cd(wd);														% カレントディレクトリ(メイン)に移動


function uncompact(ldir,file)
%-------------------------------------------------------------------------------
% Function : ファイル解凍
% 
% [argin]
% Path : 圧縮ファイル絶対パス
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 06, 2008
%-------------------------------------------------------------------------------

% ファイル解凍(元ファイル削除)
%--------------------------------------------
[dirs,f] = fileparts(which(mfilename));						% gzipがこの関数と同じディレクトリなので
cmd = fullfile(dirs,'gzip.exe');							% gzipの実行のため(ディレクトリ付き)
opt=' -f -d ';												% gzipのオプション
wd=pwd;														% カレントディレクトリ(メイン)
cd(ldir);													% ローカルディレクトリ(保存先)に移動
[stat,log] = dos(['"',cmd,'"',opt,'"',file,'"']);			% gzipで解凍
cd(wd);														% カレントディレクトリ(メイン)に移動


% function ref = f2gsi(file,time)
% %-------------------------------------------------------------------------------
% % GSI F2解の取得(真値)
% % 
% % [argin]
% % file : ファイル名
% % time : 時間(YMD)
% % 
% % [argout]
% % ref : XYZ座標
% % 
% % Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% % S.Fujita: Oct. 02, 2008
% %-------------------------------------------------------------------------------
% 
% % ファイルオープン
% %--------------------------------------------
% fp = fopen(file,'rt');
% 
% % ヘッダー部分の読み飛ばし
% %--------------------------------------------
% for i=1:20, temp = fgetl(fp);, end
% 
% % F2解の読込
% %--------------------------------------------
% while 1
% 	temp = fgets(fp);
% 	if temp == -1, break;, end
% 	bbb = [];
% 	for k = 1:10
% 		[aa temp] = strtok(temp);
% 		if k==4, bb = 12;				% 11:59:59→12
% 		else, bb = str2num(aa);			% それ以外の部分
% 		end
% 		bbb = [bbb bb];					% 1行分を格納
% 	end
% 	if bbb(1)==time(1)					% Yのチェック
% 		if bbb(2)==time(2)				% Mのチェック
% 			if bbb(3)>=time(3)			% Dのチェック
% 				break;					% 解析日で終了
% 			end
% 		end
% 	else
% 		break;							% Yが異なる場合, 1行目の値を設定するので終了
% 	end
% end
% ref = [bbb(5:7)]';						% GSI F2解
% 
% % ファイルクローズ
% %--------------------------------------------
% fclose(fp);


function ref = f3gsi(file,time)
%-------------------------------------------------------------------------------
% GSI F3解の取得(真値)
% 
% [argin]
% file : ファイル名
% time : 時間(YMD)
% 
% [argout]
% ref : XYZ座標
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 02, 2008
%-------------------------------------------------------------------------------

% ファイルオープン
%--------------------------------------------
fp = fopen(file,'rt');

% ヘッダー部分の読み飛ばし
%--------------------------------------------
for i=1:20, temp = fgetl(fp);, end

% F3解の読込
%--------------------------------------------
while 1
	temp = fgets(fp);
	if temp == -1, break;, end
	bbb = [];
	for k = 1:10
		[aa temp] = strtok(temp);
		if k==4, bb = 12;				% 11:59:59→12
		else, bb = str2num(aa);			% それ以外の部分
		end
		bbb = [bbb bb];					% 1行分を格納
	end
	if bbb(1)==time(1)					% Yのチェック
		if bbb(2)==time(2)				% Mのチェック
			if bbb(3)>=time(3)			% Dのチェック
				break;					% 解析日で終了
			end
		end
	else
		break;							% Yが異なる場合, 1行目の値を設定するので終了
	end
end
ref = [bbb(5:7)]';						% GSI F3解

% ファイルクローズ
%--------------------------------------------
fclose(fp);
