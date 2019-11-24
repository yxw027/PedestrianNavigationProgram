function [Eph_mat, ionab] = read_eph(est_prm,fpn,fpg)
%-------------------------------------------------------------------------------
% Function : ephemeris データを読み込み，配列に代入して返す
%
% [argin]
% fid     : ephemeris ファイルポインタ
%
% [argin]
% Eph_mat : エフェメリスデータ
% ionab   : 電離層パラメータ (Nファイルのみ)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% GLONASS対応
% 読み込み部分のサブ関数化
% July 08, 2009, T.Yanase
%-------------------------------------------------------------------------------

Eph_mat=[];, Eph_mat_n=[];, Eph_mat_g=[];, ionab=[];, dtsys=[];

[Eph_mat_n, ionab] = read_n(fpn);										% エフェメリス(GPS)
if est_prm.g_nav==1
	[Eph_mat_g, dtsys] = read_g(fpg);									% エフェメリス(GLONASS)
end

Eph_mat=[Eph_mat_n, Eph_mat_g];


%-------------------------------------------------------------------------------
% 以下, サブルーチン

function [Eph_mat_n, ionab] = read_n(fpn)
%-------------------------------------------------------------------------------
% Function : ephemeris データを読み込み，配列に代入して返す
%
% [argin]
% fpn       : ephemeris(GPS) ファイルポインタ
%
% [argin]
% Eph_mat_n : エフェメリスデータ(GPS)
% ionab     : 電離層パラメータ
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

%  GPS NAVIGATION MESSAGE FILE - HEADER SECTION DESCRIPTION
%  +--------------------+------------------------------------------+------------+
%  |    HEADER LABEL    |               DESCRIPTION                |   FORMAT   |
%  |  (Columns 61-80)   |                                          |            |
%  +--------------------+------------------------------------------+------------+
%  |RINEX VERSION / TYPE| - Format version (2.10)                  | F9.2,11X,  |
%  |                    | - File type ('N' for Navigation data)    |   A1,19X   |
%  +--------------------+------------------------------------------+------------+
%  |PGM / RUN BY / DATE | - Name of program creating current file  |     A20,   |
%  |                    | - Name of agency  creating current file  |     A20,   |
%  |                    | - Date of file creation                  |     A20    |
%  +--------------------+------------------------------------------+------------+
% *|COMMENT             | Comment line(s)                          |     A60    |*
%  +--------------------+------------------------------------------+------------+
% *|ION ALPHA           | Ionosphere parameters A0-A3 of almanac   |  2X,4D12.4 |*
%  |                    | (page 18 of subframe 4)                  |            |
%  +--------------------+------------------------------------------+------------+
% *|ION BETA            | Ionosphere parameters B0-B3 of almanac   |  2X,4D12.4 |*
%  +--------------------+------------------------------------------+------------+
% *|DELTA-UTC: A0,A1,T,W| Almanac parameters to compute time in UTC| 3X,2D19.12,|*
%  |                    | (page 18 of subframe 4)                  |     2I9    |
%  |                    | A0,A1: terms of polynomial               |            |
%  |                    | T    : reference time for UTC data       |      *)    ||
%  |                    | W    : UTC reference week number.        |            |
%  |                    |        Continuous number, not mod(1024)! |            |
%  +--------------------+------------------------------------------+------------+
% *|LEAP SECONDS        | Delta time due to leap seconds           |     I6     |*
%  +--------------------+------------------------------------------+------------+
%  |END OF HEADER       | Last record in the header section.       |    60X     |
%  +--------------------+------------------------------------------+------------+

%  GPS NAVIGATION MESSAGE FILE - DATA RECORD DESCRIPTION
%  +--------------------+------------------------------------------+------------+
%  |PRN / EPOCH / SV CLK| - Satellite PRN number                   |     I2,    |
%  |                    | - Epoch: Toc - Time of Clock             |            |
%  |                    |          year (2 digits, padded with 0   |            |
%  |                    |                if necessary)             |  1X,I2.2,  |
%  |                    |          month                           |   1X,I2,   |
%  |                    |          day                             |   1X,I2,   |
%  |                    |          hour                            |   1X,I2,   |
%  |                    |          minute                          |   1X,I2,   |
%  |                    |          second                          |    F5.1,   |
%  |                    | - SV clock bias       (seconds)          |  3D19.12   |
%  |                    | - SV clock drift      (sec/sec)          |            |
%  |                    | - SV clock drift rate (sec/sec2)         |     *)     |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 1| - IODE Issue of Data, Ephemeris          | 3X,4D19.12 |
%  |                    | - Crs                 (meters)           |            |
%  |                    | - Delta n             (radians/sec)      |            |
%  |                    | - M0                  (radians)          |            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 2| - Cuc                 (radians)          | 3X,4D19.12 |
%  |                    | - e Eccentricity                         |            |
%  |                    | - Cus                 (radians)          |            |
%  |                    | - sqrt(A)             (sqrt(m))          |            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 3| - Toe Time of Ephemeris                  | 3X,4D19.12 |
%  |                    |                       (sec of GPS week)  |            |
%  |                    | - Cic                 (radians)          |            |
%  |                    | - OMEGA               (radians)          |            |
%  |                    | - CIS                 (radians)          |            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 4| - i0                  (radians)          | 3X,4D19.12 |
%  |                    | - Crc                 (meters)           |            |
%  |                    | - omega               (radians)          |            |
%  |                    | - OMEGA DOT           (radians/sec)      |            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 5| - IDOT                (radians/sec)      | 3X,4D19.12 |
%  |                    | - Codes on L2 channel                    |            |
%  |                    | - GPS Week # (to go with TOE)            |            |
%  |                    |   Continuous number, not mod(1024)!      |            |
%  |                    | - L2 P data flag                         |            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 6| - SV accuracy         (meters)           | 3X,4D19.12 |
%  |                    | - SV health        (bits 17-22 w 3 sf 1) |            |
%  |                    | - TGD                 (seconds)          |            |
%  |                    | - IODC Issue of Data, Clock              |            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 7| - Transmission time of message       **) | 3X,4D19.12 |
%  |                    |         (sec of GPS week, derived e.g.   |            |
%  |                    |    from Z-count in Hand Over Word (HOW)  |            |
%  |                    | - Fit interval        (hours)            |            |
%  |                    |         (see ICD-GPS-200, 20.3.4.4)      |            |
%  |                    |   Zero if not known                      |            |
%  |                    | - spare                                  |            |
%  |                    | - spare                                  |            |
%  +--------------------+------------------------------------------+------------+

% ヘッダー解析
%--------------------------------------------
ionab(1:4,1:2) = NaN;
while 1
	temp = fgetl(fpn);
	if findstr(temp,'END OF HEADER');
		break;
	elseif findstr(temp,'GPSA');
		ionab(1:4,1) = str2num(temp(5:60))';
	elseif findstr(temp,'GPSB');
		ionab(1:4,2) = str2num(temp(5:60))';
	end
end

% エフェメリス取得
%--------------------------------------------
Eph_mat_n=zeros(38,2000); n=0; m=1;									% n:全データ数, m:行カウント(各データごと)
while 1
	temp=fgetl(fpn);
	if feof(fpn), break, end
	if m==1
		eph=str2num(temp(1:2)); eph=[eph;str2num(temp(3:22))'];		% PRN, 時刻情報
	else
		eph=[eph;str2num(temp(4:22))];								% データ(1列目)
	end
	if m~=8
		for p=23:19:61
			eph=[eph;str2num(temp(p:min(p+18,length(temp))))];		% データ(2-4列目)
		end
	else
		eph=[eph;NaN;NaN;NaN];										% 予備の部分にNaNを追加
	end
	if m<8
		m=m+1;														% 行カウントをインクリメント
	else
		n=n+1; m=1; Eph_mat_n(:,n)=eph;								% データ数をインクリメント, データを格納
	end
end
Eph_mat_n=Eph_mat_n(:,1:n);											% 全エフェメリスデータ(GPS)

if Eph_mat_n(29,1)<1023
	Eph_mat_n(29,:)=Eph_mat_n(29,:)+1024;							% 1023でリセットされているため(1024=0, 1025=1, ・・・)
end


function [Eph_mat_g, dtsys] = read_g(fpg)
%-------------------------------------------------------------------------------
% Function : ephemeris データを読み込み，配列に代入して返す
%
% [argin]
% fpg       : ephemeris(GLONASS) ファイルポインタ
%
% [argin]
% Eph_mat_g : エフェメリスデータ(GLONASS)
% dtsys     : GLONASS-GPS システム時計誤差
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% T.Yanase: July. 09, 2009
%-------------------------------------------------------------------------------

%  GLONASS NAVIGATION MESSAGE FILE - HEADER SECTION DESCRIPTION
%  +--------------------+------------------------------------------+------------+
%  |    HEADER LABEL    |               DESCRIPTION                |   FORMAT   |
%  |  (Columns 61-80)   |                                          |            |
%  +--------------------+------------------------------------------+------------+
%  |RINEX VERSION / TYPE| - Format version (2.10)                  | F9.2,11X,  |
%  |                    | - File type ('G' = GLONASS nav mess data)|   A1,39X   |
%  +--------------------+------------------------------------------+------------+
%  |PGM / RUN BY / DATE | - Name of program creating current file  |     A20,   |
%  |                    | - Name of agency  creating current file  |     A20,   |
%  |                    | - Date of file creation (dd-mmm-yy hh:mm)|     A20    |
%  +--------------------+------------------------------------------+------------+
% *|COMMENT             | Comment line(s)                          |     A60    |*
%  +--------------------+------------------------------------------+------------+
% *|CORR TO SYSTEM TIME | - Time of reference for system time corr |            |*
%  |                    |   (year, month, day)                     |     3I6,   |
%  |                    | - Correction to system time scale (sec)  |  3X,D19.12 |
%  |                    |   to correct GLONASS system time to      |            |
%  |                    |   UTC(SU)                         (-TauC)|      *)    |
%  +--------------------+------------------------------------------+------------+
% *|LEAP SECONDS        | Number of leap seconds since 6-Jan-1980  |     I6     |*
%  +--------------------+------------------------------------------+------------+
%  |END OF HEADER       | Last record in the header section.       |    60X     |
%  +--------------------+------------------------------------------+------------+

%  GLONASS NAVIGATION MESSAGE FILE - DATA RECORD DESCRIPTION
%  +--------------------+------------------------------------------+------------+
%  |    OBS. RECORD     | DESCRIPTION                              |   FORMAT   |
%  +--------------------+------------------------------------------+------------+
%  |PRN / EPOCH / SV CLK| - Satellite number:                      |     I2,    |
%  |                    |       Slot number in sat. constellation  |            |
%  |                    | - Epoch of ephemerides             (UTC) |            |
%  |                    |     - year (2 digits, padded with 0,     |   1X,I2.2, |
%  |                    |                if necessary)             |            |
%  |                    |     - month,day,hour,minute,             |  4(1X,I2), |
%  |                    |     - second                             |    F5.1,   |
%  |                    | - SV clock bias (sec)             (-TauN)|   D19.12,  |
%  |                    | - SV relative frequency bias    (+GammaN)|   D19.12,  |
%  |                    | - message frame time                 (tk)|   D19.12   |
%  |                    |   (0 .le. tk .lt. 86400 sec of day UTC)  |            |
%  |                    |                                          |      *)    |
%  |                    |   The 2-digit years in RINEX 1 and 2.xx  |            |
%  |                    |   files are understood to represent      |            |
%  |                    |   80-99: 1980-1999  and  00-79: 2000-2079|            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 1| - Satellite position X      (km)         | 3X,4D19.12 |
%  |                    | -           velocity X dot  (km/sec)     |            |
%  |                    | -           X acceleration  (km/sec2)    |            |
%  |                    | -           health (0=OK)            (Bn)|            |
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 2| - Satellite position Y      (km)         | 3X,4D19.12 |
%  |                    | -           velocity Y dot  (km/sec)     |            |
%  |                    | -           Y acceleration  (km/sec2)    |            |
%  |                    | -           frequency number (-7 ... +13)|            ||
%  +--------------------+------------------------------------------+------------+
%  | BROADCAST ORBIT - 3| - Satellite position Z      (km)         | 3X,4D19.12 |
%  |                    | -           velocity Z dot  (km/sec)     |            |
%  |                    | -           Z acceleration  (km/sec2)    |            |
%  |                    | - Age of oper. information  (days)   (E) |            |
%  +--------------------+------------------------------------------+------------+

% ヘッダー解析
%--------------------------------------------
dtsys = 0;
while 1
	temp = fgetl(fpg);
	if findstr(temp,'END OF HEADER');
		break;
	elseif findstr(temp,'CORR TO SYSTEM TIME');
		dtsys = str2num(temp(24:41));
	elseif findstr(temp,'LEAP SECONDS');
		leap_sec = str2num(temp(5:7));
	end
end


% エフェメリス取得
%--------------------------------------------
Eph_mat_g=zeros(38,2000); n=0; m=1;									% n:全データ数, m:行カウント(各データごと)
while 1
	temp=fgetl(fpg);
	if feof(fpg), break, end
	if m==1
		eph=str2num(temp(1:2)); eph=[eph+37;str2num(temp(3:22))'];	% PRN, 時刻情報
	else
		eph=[eph;str2num(temp(4:22))];								% データ(1列目)
	end
	for p=23:19:61
		eph=[eph;str2num(temp(p:min(p+18,length(temp))))];			% データ(2-4列目)
	end
	if m<4
		m=m+1;														% 行カウントをインクリメント
	else
		n=n+1; m=1;

		if eph(7,1) == 59											% 1秒ずれる受信機バグ？に対応
		time_g=[eph(2,1)+2000, eph(3:5,1)', eph(6,1)+1, eph(7,1)-59];
		else
		time_g=[eph(2,1)+2000, eph(3:7,1)'];
		end

% 		time_g=utc2gps(time_g, dtsys, leap_sec);					% GPSTに変換
		time_g=num2str(datevec(datenum(time_g) + leap_sec/86400 + dtsys/86400));

		[times_g]=cal_time2(time_g);
		
		eph=[eph;times_g.tow;times_g.week];							% 23, 24行にTOW,weekを加える→後のエフェメリスの列選択や軌道計算のため
		Eph_mat_g(1:24,n)=eph;										% データ数をインクリメント, データを格納
		Eph_mat_g(25:38,n)=NaN;										% NaNを追加してGPSのエフェメリスと行を揃える
	end
end
Eph_mat_g=Eph_mat_g(:,1:n);											% 全エフェメリスデータ(GLONASS)

Eph_mat_g(25,:)=Eph_mat_g(18,:)*0.5625e6 + 1.602e9;					% L1 周波数		% 25, 26行に対応する周波数を加える
Eph_mat_g(26,:)=Eph_mat_g(18,:)*0.4375e6 + 1.246e9;					% L2 周波数


