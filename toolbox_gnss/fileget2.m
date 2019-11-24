function est_prm=fileget(est_prm)
%-------------------------------------------------------------------------------
% Function : �t�@�C����������,�_�E�����[�h����
% 
% [argin]
% est_prm : �����ݒ�p�����[�^(�\����)
%           .rcv    : ��M�@�ԍ�(�Z���z��; ��:{'950322','950322'})
%           .ephsrc : ������(������, ��:'igs', 'igr', 'igu')
%           .ionsrc : IONEX(������, ��:'igs', 'cod', 'jpl')
% 
% [argout]
% est_prm : �����ݒ�p�����[�^(�X�V)
% 
% 2007,2008,2009�N�x�݂̂̑Ή�
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 23, 2009
%-------------------------------------------------------------------------------
% F3���ɑΉ�
% ����F2, F3���̃t�@�C�����������Ȃ̂�, ��r�̍ۂ͍H�v����K�v������(���O�̕ύX, �؂�ւ�������)
% April 19, 2009, T.Yanase
%-------------------------------------------------------------------------------
% 2010�N�ȍ~���Ή�(2012�N�܂�)
% February 9, 2010, T.Yanase
%-------------------------------------------------------------------------------


fprintf('�f�[�^�t�@�C�����擾���܂�.\n');


%--- IP�A�h���X�̃`�F�b�N(���[�^�̓����O��)
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

%--- start time �̐ݒ�
%--------------------------------------------
if ~isempty(est_prm.stime)
	time_s=cal_time2(est_prm.stime);										% Start time �� Juliday, WEEK, TOW, TOD
end

%--- end time �̐ݒ�(���݂͕s�v)
%--------------------------------------------
% if ~isempty(est_prm.etime)
% 	time_e=cal_time2(est_prm.etime);										% End time �� Juliday, WEEK, TOW, TOD
% else
% 	time_e.day = [];
% 	time_e.mjd = 1e50;														% End time(mjd) �ɑ傫�Ȓl������
% end

%--- �t�@�C���������̏���
%--------------------------------------------
for k=1:length(est_prm.rcv)
	if length(est_prm.rcv{k})>=4, rcvf{k}=est_prm.rcv{k}(end-3:end); else rcvf{k}=est_prm.rcv{k}; end
end
day=mjuliday(time_s.day(1:3))-mjuliday([time_s.day(1),1,1])+1;
gpsd=mjuliday(time_s.day(1:3))-44244; gpsw=floor(gpsd/7); gpsd=floor(gpsd-gpsw*7);

%--- �t�@�C���_�E�����[�h�̏���
%--------------------------------------------
login = 'anonymous';											% ���O�C��ID
passwd = 'user@';												% ���O�C���p�X���[�h
host1 = 'terras.gsi.go.jp';										% GSI
host2 = 'cddis.gsfc.nasa.gov';									% IGS

if flag==1
	% ���[�^��
	switch time_s.day(1)
	case 2007, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2008, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2009, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2010, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2011, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2012, host3 = '//Kubolab-epson/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	end
else
	% ���[�^�O
	switch time_s.day(1)
	case 2007, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2008, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2009, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2010, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2011, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	case 2012, host3 = '//133.19.153.121/gps/DATA/GEONET/';			% �l�b�g���[�N�h���C�u(Kubolab-epson)
	end
end

%--- OBS,NAV�_�E�����[�h
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

%--- IONEX�_�E�����[�h
%--------------------------------------------
if strcmp(est_prm.file.ionex,'') & est_prm.i_mode==2
	est_prm.file.ionex =sprintf('%sg%03d%1d.%02di',est_prm.ionsrc,day,0,mod(time_s.day(1),100));		% IONEX IGS Final
	filei = sprintf('%s/%04d/%03d/%s.%s','/gps/products/ionex',time_s.day(1),day,est_prm.file.ionex,'Z');
	ftpdown2(host2,login,passwd,est_prm.dirs.ionex,filei);
	uncompact(est_prm.dirs.ionex,[est_prm.file.ionex,'.Z']);
end

%--- SP3�_�E�����[�h
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

%--- GSI F3���̎擾
%--------------------------------------------
if isempty(est_prm.rovpos)
	%--- �t�@�C��������
	%--------------------------------------------
	est_prm.file.rovpos=sprintf('%s.%02d.pos',est_prm.rcv{1},mod(time_s.day(1),100));					% GSI F3��(rov)
% 	est_prm.file.rovpos=sprintf('%s.%s.pos',est_prm.rcv{1},datestr(now,'yy'));							% GSI F2��(rov) ���݂̔N�x

	%--- �t�@�C���_�E�����[�h(POS,GSI����)
	%--------------------------------------------
	switch time_s.day(1)
	case 2007
		filep1 = sprintf('%s/%4d/%s','/coordinates_F3',time_s.day(1),est_prm.file.rovpos);
		if flag==1
			% ���[�^��
			ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep1);
		else
			% ���[�^�O
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
		%--- �t�@�C��������
		%--------------------------------------------
		est_prm.file.refpos=sprintf('%s.%02d.pos',est_prm.rcv{2},mod(time_s.day(1),100));				% GSI F3��(ref)
% 		est_prm.file.refpos=sprintf('%s.%s.pos',est_prm.rcv{2},datestr(now,'yy'));						% GSI F2��(rov) ���݂̔N�x

		%--- �t�@�C���_�E�����[�h(POS,GSI����)
		%--------------------------------------------
		switch time_s.day(1)
		case 2007
			filep2 = sprintf('%s/%4d/%s','/coordinates_F3',time_s.day(1),est_prm.file.refpos);
			if flag==1
				% ���[�^��
				ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep2);
			else
				% ���[�^�O
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

fprintf('�f�[�^�t�@�C�����擾���܂���.\n');

% %--- GSI F2���̎擾
% %--------------------------------------------
% if isempty(est_prm.rovpos)
% 	%--- �t�@�C��������
% 	%--------------------------------------------
% 	est_prm.file.rovpos=sprintf('%s.%02d.pos',est_prm.rcv{1},mod(time_s.day(1),100));					% GSI F2��(rov)
% % 	est_prm.file.rovpos=sprintf('%s.%s.pos',est_prm.rcv{1},datestr(now,'yy'));						% GSI F2��(rov) ���݂̔N�x
% 
% 	%--- �t�@�C���_�E�����[�h(POS,GSI����)
% 	%--------------------------------------------
% 	switch time_s.day(1)
% 	case 2007
% 		filep1 = sprintf('%s/%4d/%s','/coordinates_F2',time_s.day(1),est_prm.file.rovpos);
% 		if flag==1
% 			% ���[�^��
% 			ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep1);
% 		else
% 			% ���[�^�O
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
% 		%--- �t�@�C��������
% 		%--------------------------------------------
% 		est_prm.file.refpos=sprintf('%s.%02d.pos',est_prm.rcv{2},mod(time_s.day(1),100));				% GSI F2��(ref)
% % 		est_prm.file.refpos=sprintf('%s.%s.pos',est_prm.rcv{2},datestr(now,'yy'));						% GSI F2��(rov) ���݂̔N�x
% 
% 		%--- �t�@�C���_�E�����[�h(POS,GSI����)
% 		%--------------------------------------------
% 		switch time_s.day(1)
% 		case 2007
% 			filep2 = sprintf('%s/%4d/%s','/coordinates_F2',time_s.day(1),est_prm.file.refpos);
% 			if flag==1
% 				% ���[�^��
% 				ftpdown3('//Kubolab-epson/gps/DATA/GEONET/',est_prm.dirs.obs,filep2);
% 			else
% 				% ���[�^�O
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
% fprintf('�f�[�^�t�@�C�����擾���܂���.\n');


%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

function ftpdown2(host,login,passwd,ldir,file)
%-------------------------------------------------------------------------------
% Function : �t�@�C���_�E�����[�h
% 
% [argin]
% host   : �z�X�g
% login  : ���O�C�����[�U�[��
% passwd : ���O�C���p�X���[�h
% ldir   : ���[�J���f�B���N�g��(�ۑ���)
% file   : �_�E�����[�h�t�@�C��(host�ȉ��̃f�B���N�g���t����)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 06, 2008
%-------------------------------------------------------------------------------

[dirs,f] = fileparts(which(mfilename));																	% wget�����̊֐��Ɠ����f�B���N�g���Ȃ̂�
cmd = fullfile(dirs,'wget.exe');																		% wget�̎��s�̂���(�f�B���N�g���t��)
opt = sprintf('--timestamping --ftp-user=%s --ftp-password=%s --glob=off --passive-ftp',login,passwd);	% wget�̃I�v�V����
wd=pwd;																									% �J�����g�f�B���N�g��(���C��)
cd(ldir);																								% ���[�J���f�B���N�g��(�ۑ���)�Ɉړ�
[p,name,ext]=fileparts(file);
if exist(name)==0
	[stat,log] = dos(['"',cmd,'" ',opt,' ftp://',host,file]);											% wget��DL
end
cd(wd);																									% �J�����g�f�B���N�g��(���C��)�Ɉړ�


function ftpdown3(host,ldir,file)
%-------------------------------------------------------------------------------
% Function : �t�@�C���_�E�����[�h(���[�J���̃f�B���N�g������R�s�[)
% 
% [argin]
% host   : �z�X�g
% ldir   : ���[�J���f�B���N�g��(�ۑ���)
% file   : �_�E�����[�h�t�@�C��(host�ȉ��̃f�B���N�g���t����)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 06, 2008
%-------------------------------------------------------------------------------

cmd=['xcopy ',host,file];
cmd=strrep(cmd,'/','\');									% "/"��"\"�ɒu��
% opt=' /Y ';													% �����̃t�@�C�������݂���ꍇ�A�㏑���̊m�F���s��Ȃ�
opt=' /D ';													% �R�s�[��ɓ����̃t�@�C�������݂���ꍇ�ɍX�V�����V�����t�@�C���̂݃R�s�[����
wd=pwd;														% �J�����g�f�B���N�g��(���C��)
cd(ldir);													% ���[�J���f�B���N�g��(�ۑ���)�Ɉړ�
[p,name,ext]=fileparts(file);
if strcmp(ext,'.pos')										% pos�t�@�C���̏ꍇ
	if exist([name,ext])==0
		[stat,log] = dos([cmd,opt]);						% xcopy�Ńt�@�C���R�s�[
	end
else														% pos�t�@�C���ȊO(���k�t�@�C��)
	if exist(name)==0
		[stat,log] = dos([cmd,opt]);						% xcopy�Ńt�@�C���R�s�[
	end
end
cd(wd);														% �J�����g�f�B���N�g��(���C��)�Ɉړ�


function uncompact(ldir,file)
%-------------------------------------------------------------------------------
% Function : �t�@�C����
% 
% [argin]
% Path : ���k�t�@�C����΃p�X
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: June 06, 2008
%-------------------------------------------------------------------------------

% �t�@�C����(���t�@�C���폜)
%--------------------------------------------
[dirs,f] = fileparts(which(mfilename));						% gzip�����̊֐��Ɠ����f�B���N�g���Ȃ̂�
cmd = fullfile(dirs,'gzip.exe');							% gzip�̎��s�̂���(�f�B���N�g���t��)
opt=' -f -d ';												% gzip�̃I�v�V����
wd=pwd;														% �J�����g�f�B���N�g��(���C��)
cd(ldir);													% ���[�J���f�B���N�g��(�ۑ���)�Ɉړ�
[stat,log] = dos(['"',cmd,'"',opt,'"',file,'"']);			% gzip�ŉ�
cd(wd);														% �J�����g�f�B���N�g��(���C��)�Ɉړ�


% function ref = f2gsi(file,time)
% %-------------------------------------------------------------------------------
% % GSI F2���̎擾(�^�l)
% % 
% % [argin]
% % file : �t�@�C����
% % time : ����(YMD)
% % 
% % [argout]
% % ref : XYZ���W
% % 
% % Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% % S.Fujita: Oct. 02, 2008
% %-------------------------------------------------------------------------------
% 
% % �t�@�C���I�[�v��
% %--------------------------------------------
% fp = fopen(file,'rt');
% 
% % �w�b�_�[�����̓ǂݔ�΂�
% %--------------------------------------------
% for i=1:20, temp = fgetl(fp);, end
% 
% % F2���̓Ǎ�
% %--------------------------------------------
% while 1
% 	temp = fgets(fp);
% 	if temp == -1, break;, end
% 	bbb = [];
% 	for k = 1:10
% 		[aa temp] = strtok(temp);
% 		if k==4, bb = 12;				% 11:59:59��12
% 		else, bb = str2num(aa);			% ����ȊO�̕���
% 		end
% 		bbb = [bbb bb];					% 1�s�����i�[
% 	end
% 	if bbb(1)==time(1)					% Y�̃`�F�b�N
% 		if bbb(2)==time(2)				% M�̃`�F�b�N
% 			if bbb(3)>=time(3)			% D�̃`�F�b�N
% 				break;					% ��͓��ŏI��
% 			end
% 		end
% 	else
% 		break;							% Y���قȂ�ꍇ, 1�s�ڂ̒l��ݒ肷��̂ŏI��
% 	end
% end
% ref = [bbb(5:7)]';						% GSI F2��
% 
% % �t�@�C���N���[�Y
% %--------------------------------------------
% fclose(fp);


function ref = f3gsi(file,time)
%-------------------------------------------------------------------------------
% GSI F3���̎擾(�^�l)
% 
% [argin]
% file : �t�@�C����
% time : ����(YMD)
% 
% [argout]
% ref : XYZ���W
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 02, 2008
%-------------------------------------------------------------------------------

% �t�@�C���I�[�v��
%--------------------------------------------
fp = fopen(file,'rt');

% �w�b�_�[�����̓ǂݔ�΂�
%--------------------------------------------
for i=1:20, temp = fgetl(fp);, end

% F3���̓Ǎ�
%--------------------------------------------
while 1
	temp = fgets(fp);
	if temp == -1, break;, end
	bbb = [];
	for k = 1:10
		[aa temp] = strtok(temp);
		if k==4, bb = 12;				% 11:59:59��12
		else, bb = str2num(aa);			% ����ȊO�̕���
		end
		bbb = [bbb bb];					% 1�s�����i�[
	end
	if bbb(1)==time(1)					% Y�̃`�F�b�N
		if bbb(2)==time(2)				% M�̃`�F�b�N
			if bbb(3)>=time(3)			% D�̃`�F�b�N
				break;					% ��͓��ŏI��
			end
		end
	else
		break;							% Y���قȂ�ꍇ, 1�s�ڂ̒l��ݒ肷��̂ŏI��
	end
end
ref = [bbb(5:7)]';						% GSI F3��

% �t�@�C���N���[�Y
%--------------------------------------------
fclose(fp);
