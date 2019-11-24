function [time, no_sat, prn, dtrec, ephi, data] = read_obs_epo_data(fpo, Eph_mat, no_obs, TYPES)
%-------------------------------------------------------------------------------
% Function : エポック解析 & 観測データ取得
% 
% [argin]
% fpo     : obs ファイルポインタ
% Eph_mat : エフェメリス
% no_obs  : 観測データ数
% TYPES   : データの並び
% 
% [argout]
% time    : 時刻情報の構造体(*.tod, *.week, *.tow, *.mjd, *.day)
% no_sat  : 観測衛星数
% prn     : 衛星番号
% dtrec   : 受信機時計誤差
% ephi    : 各衛星の最適なエフェメリスのインデックス
% data    : 観測データ(PRN順, L1, C1, P1, D1, L2, P2, D2, S1, S2)
% 
% 衛星システムの種別を出力するように変更(20070904 Fujita)
% 
% 衛星数が "0" のとき, 再度エポック解析をするように変更→データが無ければ測位できないから
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 06, 2008
%-------------------------------------------------------------------------------

% 初期値
%--------------------------------------------
time=[];, no_sat=[];, neg_sat=[];, neg_sat_num=[];, prn=[];, dtrec=[];, ef=[];, sys=[];, ephi=[];, data=[];

while 1
	temp = fgetl(fpo);														% 1行取得

	% 終了処理(tempが空の場合)
	%--------------------------------------------
	if isempty(temp), break;, end

	% 終了処理(EOFの場合)
	%--------------------------------------------
	if feof(fpo), break;, end

	% 1 行を 80 文字のベクトルに変更
	%--------------------------------------------
	for i=1:(80-size(temp,2)), temp=[temp ' '];, end

	%--------------------------------------------
	% イベントフラグの確認
	%
	%	Event flag (Epoch flag > 1)
	%			== 2: start moving anntenna
	%			== 3: new site occupation
	%			== 4: header information follows
	%			== 5: external event
	%			== 6: cycle slip records
	%
	%			現時点では 4 にのみ対応
	%
	%	参考文献 Liner Algebra Geodesy, and GPS
	%				G. Strang, K. Borre
	%--------------------------------------------
	ef = str2num(temp(27:29));
	if ef == 4
		c_line = str2num(temp(30:32));										% コメント行の数
		for i=1:c_line
			temp = fgetl(fpo);
			fprintf('%s \n',temp)											% 読み飛ばしたコメント行の表示
		end
		temp = fgetl(fpo);													% コメント行の次の行の読み出し
		for i=1:(80 - size(temp,2))
			temp = [temp ' '];
		end
	end

	% 時刻情報
	%--------------------------------------------
	time.day = str2num(temp(1:26));											% 年, 月, 日, 時, 分, 秒
	if time.day(1) < 80														% 2079年まで対応
		time.day(1) = time.day(1) + 2000;
	elseif time.day(1) >= 80
		time.day(1) = time.day(1) + 1900;
	end

	time.mjd = mjuliday(time.day);											% ユリウス暦計算
	[time.week, time.tow] = weekf(time.mjd);								% 週番号,週秒の計算
	time.tod = round(time.day(4)*3600 + time.day(5)*60 + time.day(6));		% ToD

	no_sat = str2num(temp(30:32));											% 衛星数	I3

	% 衛星数が "0" でない場合はデータを格納して Break
	% エポック情報のみで衛星数が "0" のときは再度読込
	%--------------------------------------------
	if no_sat ~= 0
		% PRN
		%--------------------------------------------
		neg_sat = [];
		ephi = repmat(NaN,1,32);
		neg_sat_num = 0;

		dtrec  = str2num(temp(69:80));										% 受信機時計誤差
		if isempty(dtrec), dtrec=NaN;, end

		prn = zeros(1,no_sat);
		sys = zeros(1,no_sat);
		p=33;
		for k=1:no_sat
			if k==13
				temp=fgetl(fpo); p=33;										% エポック情報数が2行にまたがるとき
			end
			prn(k)=sscanf(temp(p+1:min(p+1+2-1,length(temp))),'%f');		% 衛星番号を取得(文字列→数字に変換)
			SYS=temp(p);													% 衛星システムを取得
			if ~isempty(findstr(SYS,'G')), SYS=1;, end
			if ~isempty(findstr(SYS,'R')), SYS=2;, end
			if ~isempty(findstr(SYS,'S')), SYS=3;, end
			sys(k) = SYS;
			ephi(prn(k)) = eph_search(Eph_mat, prn(k), time);
			if ephi(prn(k)) == 0											% エフェメリスの無い衛星数カウント
				neg_sat_num = neg_sat_num + 1;
				neg_sat = [neg_sat; k];										% エフェメリスの無い衛星の位置格納
				ephi(prn(k))=NaN;
			end
			p=p+3;															% 次の衛星のため
		end

		% 観測データ読み込み
		%--------------------------------------------
		data = read_obs(fpo, no_obs, no_sat, neg_sat, TYPES);

		% 最適なエフェメリスの無い衛星を除外
		%--------------------------------------------
		if ~isempty(neg_sat)
			data(neg_sat,:)=[]; prn(neg_sat)=[]; sys(neg_sat)=[];
		end

		%--- GPSのみ利用(SBASは除外)
		%--------------------------------------------
		data(find(sys==3),:)=[]; prn(find(sys==3))=[]; 
		data(find(prn>32),:)=[]; prn(find(prn>32))=[]; no_sat=length(prn);
		data(:,2) = data(:,2) + p1c1bias(time.day,prn);						% P1C1 DCB 補正

		if no_sat~=0, break;, end
	end
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

function column = eph_search(Eph_mat,prn,tt)
%-------------------------------------------------------------------------------
% eph_search: eph_read で作成された Eph_mat 行列から適切な列を選択する
%
% [argin]
% Eph_mat : エフェメリスデータ
% prn     : 指定衛星番号
% tt      : 時刻情報(day,tod,week,tow,mjd)
% 
% [argout]
% column: 与えられた衛星番号と時刻で最適な Eph_mat の列番号
%
% エフェメリス有効期間の設定が必要(エフェメリス更新が無い衛星があると誤差が増大するため)
%
% ヘルスのチェックをこの関数内でするように変更
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 12, 2008
%-------------------------------------------------------------------------------

% New version
column = 0;															% インデックスの初期値
index = find(Eph_mat(1,:)==prn);									% 衛星PRN に対するエフェメリスの列インデックス
if isempty(index), return;, end										% 最適なエフェメリスが無い場合は終了
ttm=Eph_mat(35,index);												% エフェメリス送信時刻(tow)
index=index(find(ttm<=tt.tow));										% エフェメリス送信時刻がエポック時刻より以前のインデックス
if isempty(index), return;, end										% 最適なエフェメリスが無い場合は終了
toe=Eph_mat(19,index);												% 軌道元期(tow)
week=Eph_mat(29,index);												% 週番号
dt=abs((week-tt.week)*7*86400+(toe-tt.tow));						% 軌道元期との時間差の絶対値(towを利用, weekも考慮)
[mm,imin]=min(dt);													% 最近点のインデックス(indexの中で)

fit=Eph_mat(36,index(imin))/2;										% エフェメリス有効期間±[h]
if isnan(fit), fit=2;, end											% エフェメリス有効期間±2[h](記載されていない場合)

if mm<=fit*3600														% 有効期間以内にあるかどうかの判定
	column=index(imin);												% 最近点のインデックス(エフェメリスの中で)
end
if column~=0
	if Eph_mat(32,column)~=0										% 衛星のヘルスをチェック
		column=0;													% 最適なエフェメリスが無いとする
	end
end



function data = read_obs(fpo, no_obs, no_sat, neg_sat, TYPES)
%-------------------------------------------------------------------------------
% obsrvation ファイルから観測データ取得
% 
% [argin]
% fpo     : obs ファイルポインタ
% no_obs  : 観測データ数
% no_sat  : 観測衛星数
% neg_sat : エフェメリスのない衛星の位置
% TYPES   : データの並び
% 
% [argout]
% data : 観測データ(PRN順, L1, C1, P1, D1, L2, P2, D2, S1, S2)
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 16, 2007
%-------------------------------------------------------------------------------

% 観測データ読み込み
%--------------------------------------------
Data = repmat(NaN,no_sat,no_obs);									% 配列の準備(NaNで埋める)
for i = 1 : no_sat
	if find(i==neg_sat)												% エフェメリスの無い衛星の観測データ読み飛ばし
		if no_obs <= 5
			temp = fgetl(fpo);
		elseif no_obs > 5
			temp=fgetl(fpo);
			temp=fgetl(fpo);
		end
	else															% エフェメリスのある衛星の観測データ
		temp = fgetl(fpo); k=1;
		for j=1:no_obs
			if j==6
				temp=fgetl(fpo); k=1;								% 観測データ数が2行にまたがるとき
			end
			s=sscanf(temp(k:min(k+14-1,length(temp))),'%f');		% 観測データを取得(文字列→数字に変換)
			if ~isempty(s)
				Data(i,j)=s; k=k+16;								% 観測データ格納
			end
		end
	end
end

% "o" のデータが "dat" ﾌｫｰﾏｯﾄのどこに入るか？
%--------------------------------------------
for k = 1 : 2 : size(TYPES,2)
	t = findstr('L1C1P1D1L2P2D2S1S2T1T2', TYPES(k:k+1));
	t = (t+1)/2;
	map((k+1)/2) = t;
end

% data の並び --> L1, C1, P1, D1, L2, P2, D2, S1, S2
%--------------------------------------------
data = [];
for i = 1:9
	dat_ind = find(map==i);
	if ~isempty(dat_ind)
		data(:,i) = Data(:,dat_ind);
	else
		data(:,i) = NaN;
	end
end
