function [sat_xyz,sat_xyz_dot,sat_clk] = interp_lag(time, Data, prn, rho, dtr, degree)
%-------------------------------------------------------------------------------
% Function : 精密暦用ラグランジュ補間プログラム
%
% [argin]
% time         : 時刻情報[year month day hour min sec]
% Data         : sp3 全データ
% prn          : 衛星PRN
% rho          : 各衛星 - 受信機間コード擬似距離 (L1C)
% degree       : ラグランジュ補間の次数(degree点補間)
%
% [argout]
%  sat_xyz     : t-tau 時における各衛星補間 XYZ 座標 (column vector)
%  sat_xyz_dot : t-tau 時における各衛星速度 XYZ 成分 (column vector)
%  sat_clk     : t-tau 時における各衛星補間 衛星時計誤差
%
% 注：現在のラグランジュ補間では, 1日分のデータのみ用いているので, 
%     日の変り目(0-2h, 22-24h)の付近では, 補間点が前後で均等に利用
%     できないため, 精度が劣化します.
%     特に, 23:45以降は極端に悪くなります.(データ:0:00-23:45だから)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

persistent s_timek e_timek Lj1 tk

% 定数(グローバル変数)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- 定数
%--------------------------------------------
C=299792458;							% 光速
f1=1.57542e9;  lam1=C/f1;				% L1 周波数 & 波長
f2=1.22760e9;  lam2=C/f2;				% L2 周波数 & 波長

OMGE=7.2921151467e-5;					% WGS-84 採用地球回転角速度 [rad/s]
MUe=3.986005e14;						% WGS-84 の地心重力定数 [m^3s^{-2}]
FF=-4.442807633e-10;					% 相対論に関する誤差補正係数

% 受信時刻
%--------------------------------------------
t=time(4:6)*[3600;60;1]-dtr;								% time の TOD --- roundなし(受信機時計誤差考慮)

% 時刻から開始・終了を計算
%--------------------------------------------
sp3_dt = 900;												% 更新間隔[sec]

tc = round(t/sp3_dt);										% 入力時刻に最も近いところ

s_time = tc - floor(degree/2);								% 最初のインデックス
e_time = tc + floor(degree/2);								% 最後のインデックス

if s_time <= 0												% はみ出しの修正→はみ出した分はe_timeへ
	s_time = 1;
	e_time = degree;
end

if e_time >= size(Data,1)									% はみ出しの修正→はみ出した分はs_timeへ
	s_time = (size(Data,1) - degree) + 1;
	e_time = size(Data,1);
end

% ラグランジュ補間多項式の計算
%--------------------------------------------
dt = 0.01;													% 速度計算のため
sat_xyz1=zeros(1,3);										% XYZ用
sat_xyz2=zeros(1,3);										% XYZ用(速度計算のため)
sat_clk =zeros(1,1);										% clk用

t = t - rho/C;												% 衛星の電波発信時刻(伝搬時間考慮)

% New Version
% 補間のデータのみで計算できる部分(一定期間, 同一値が利用できる)
%--------------------------------------------
if isempty(s_timek) | s_timek~=s_time
    Data(s_time:e_time)
	tod           = (Data(s_time:e_time,3,:));				% ToD
	data_sp3_XYZC = (Data(s_time:e_time,4:7,:));			% XYZC

	tk=repmat(tod(:,1,prn),1,degree);						% tk
	tj=repmat(tod(:,1,prn)',degree,1);						% tj
	tt=tj-tk;												% Ljの分母の要素(k,jに関連するもの)
	for n=1:degree
		tt(n,n)=1;											% k=jの部分は1で置換(分母=0となるため)
		Lj1(n,:,:)=data_sp3_XYZC(n,1:4,:)/prod(tt(:,n));	% Ljの分母*データ  prod:配列の要素の積
	end
	s_timek=s_time; e_timek=e_time;							% データの必要な部分
end
% 各衛星・時刻が計算に必要な部分(常に計算する必要がある)
%--------------------------------------------
tt1=t-tk;    for n=1:degree, tt1(n,n)=1; end				% Ljの分子の要素(kに関連するもの)
tt2=t-dt-tk; for n=1:degree, tt2(n,n)=1; end				% Ljの分子の要素(kに関連するもの)
sat_xyz1(1:3)=(prod(tt1,1)*Lj1(:,1:3,prn));					% 衛星位置
sat_xyz2(1:3)=(prod(tt2,1)*Lj1(:,1:3,prn));					% 衛星位置(衛星速度計算のため)
sat_clk(1)=(prod(tt1,1)*Lj1(:,4,prn));						% 衛星時計誤差

% オフセット補正(Block IIA)
%--------------------------------------------
blk2A=sat_blk(mjuliday(time));								% Block IIA
if ~isempty(find(blk2A==prn))
	sat_xyz1=sat_xyz1-1.023*sat_xyz1/norm(sat_xyz1);		% オフセット補正
	sat_xyz2=sat_xyz2-1.023*sat_xyz2/norm(sat_xyz2);		% オフセット補正
end

sat_xyz=sat_xyz1;											% 衛星座標
sat_xyz_dot=(sat_xyz1-sat_xyz2)/dt;							% 衛星速度



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function blk2A=sat_blk(mjd)
% PRN  TYPE(0:IIA, 1:IIR, 2:IIR-M)  MJD    YEAR  MONTH  DAY  FREQ STD  PLANE
sat_blk_list=[
01   0   48948; %  1992  11     22   Cs        F6
02   1   53315; %  2004  11     06   Rb        D1
03   0   50170; %  1996  03     28   Cs        C2
04   0   49286; %  1993  10     26   Rb        D4
05   0   49229; %  1993  08     30   Rb        B5
06   0   49421; %  1994  03     10   Rb        C1
07   2   54540; %  2008  03     15   Rb        A6
08   0   50758; %  1997  11     06   Cs        A3
09   0   49164; %  1993  06     26   Cs        A1
10   0   50280; %  1996  07     16   Cs        E3
11   1   51458; %  1999  10     07   Rb        D2
12   2   54056; %  2006  11     17   Rb        B4
13   1   50652; %  1997  07     23   Rb        F3
14   1   51858; %  2000  11     10   Rb        F1
15   2   54390; %  2007  10     17   Rb        F2
16   1   52668; %  2003  01     29   Rb        B1
17   2   53639; %  2005  09     26   Rb        C4
18   1   51939; %  2001  01     30   Rb        E4
19   1   53084; %  2004  03     20   Rb        C3
20   1   51675; %  2000  05     11   Rb        E1
21   1   52729; %  2003  03     31   Rb        D3
22   1   52994; %  2003  12     21   Rb        E2
23   1   53179; %  2004  06     23   Rb        F4
24   0   48441; %  1991  07     04   Cs        D5
25   0   48675; %  1992  02     23   Rb        A5
26   0   48810; %  1992  07     07   Rb        F5
27   0   48874; %  1992  09     09   Cs        A4
28   1   51741; %  2000  07     16   Rb        B3
29   2   54454; %  2007  12     20   Rb        C6
30   0   50338; %  1996  09     12   Cs        B2
31   2   54003; %  2006  09     25   Rb        A2
32   0   48221  %  1990  11     26   Rb        E5
];

i=find(sat_blk_list(:,2)==0 & sat_blk_list(:,3)<=mjd);
blk2A=sat_blk_list(i,1);