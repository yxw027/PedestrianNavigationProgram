function [Eph_mat, ionab] = read_eph(fid)
%-------------------------------------------------------------------------------
% Function : ephemeris データを読み込み，配列に代入して返す
%
% [argin]
% fid     : ephemeris ファイルポインタ
%
% [argin]
% Eph_mat : エフェメリスデータ
% ionab   : 電離層パラメータ
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
	temp = fgetl(fid);
	if findstr(temp,'END OF HEADER');
		break;
	elseif findstr(temp,'ION ALPHA');
		ionab(1:4,1) = str2num(temp(1:60))';
	elseif findstr(temp,'ION BETA');
		ionab(1:4,2) = str2num(temp(1:60))';
	end
end

% エフェメリス取得
%--------------------------------------------
Eph_mat=zeros(38,2000); n=0; m=1;									% n:全データ数, m:行カウント(各データごと)
while 1
	temp=fgetl(fid);
	if feof(fid), break, end
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
		n=n+1; m=1; Eph_mat(:,n)=eph;								% データ数をインクリメント, データを格納
	end
end
Eph_mat=Eph_mat(:,1:n);												% 全エフェメリスデータ

if Eph_mat(29,1)<1023
	Eph_mat(29,:)=Eph_mat(29,:)+1024;								% 1023でリセットされているため(1024=0, 1025=1, ・・・)
end
