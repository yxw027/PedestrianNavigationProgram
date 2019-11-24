function [ncheck Jall] = lambda(Q,nh,fid)
%-------------------------------------------------------------------------------
% LAMBDA Method
%
% [argin]
% Q   : Float Ambiguity Covarience Matrix
% nh  : Float Ambiguity
% fid : File pointer
%
% [argout]
% ncheck : Fix Ambiguity
% Jall   : Residuals
%
% サブ関数化と引数の変更(by fujita)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Kubo: 
%-------------------------------------------------------------------------------

m=length(nh);												% Ambiguityの数
p=2;														% 探索空間に含める候補の最低個数(p<=m+1)
maxcan = 2; 												% 記録する候補の最大個数
nhd = rem(nh,1);											% Ambiguityの整数部分を除く
ndiff = nh - nhd;											% 整数部分
[Un,Dn] = ud(Q,m);											% QをUDU^T分解する
[Uz,Dz,zh,ZTi]=lamtrans(Un,Dn,nhd,m);						% 無相関化する
[chi2] = chisetting(Uz, Dz, m, zh, p);						% 探索空間の大きさを決める
chi2 = chi2 + 1e-6; 										% 境界を含んで探索するようにChi^2を少し大きくする
[can, Jall, ncan] = search(zh, Uz, Dz, m, chi2, maxcan);	% 探索(候補, 評価関数値)
% zcheck = can(1,:)';											% 第一候補
% Jzcheck = Jall(1);											% 第一候補に対する評価関数値
% ncheck = ZTi * zcheck + ndiff;								% 第一候補を逆変換する
% if fid ~= -1												% LAMBDA法のログを出力
% 	savelamlog(fid,m,nh,nhd,ndiff,Q,Un,Dn,ZTi,zh,Uz,Dz,ncan,chi2,Jall,can);
% end
for i=1:size(can,1)
	ncheck(:,i)=ZTi*can(i,:)' + ndiff;						% 候補全てについて逆変換する
end



%-------------------------------------------------------------------------------
% サブルーチン

function [U,D] = ud(Q,m)
%-------------------------------------------------------------------------------
%行列QのUDU^T分解を行い，U,Dを出力

% Q: mxm 正定値対称行列
% n: 行列Qの次元
% U: 単位上三角行列
% D: 対角行列の対角成分（n次元ベクトル）
%
% Reference: 片山，新版応用カルマンフィルタ，朝倉書店
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 8/Nov. 2007
%-------------------------------------------------------------------------------

for k=m:-1:2
	D(k)=Q(k,k); U(k,k)=1;
	for j=1:k-1
		U(j,k)=Q(j,k)/D(k);
		for i=1:j
			Q(i,j)=Q(i,j)-U(i,k)*U(j,k)*D(k);
		end
	end
end
U(1,1)=1; D(1)=Q(1,1);


function [U,D,nh,ZTi]=lamtrans(U,D,nh,m)
%-------------------------------------------------------------------------------
% 引数
% U:  nxn単位上三角行列(QのUDU^T分解)
% D:  n次元ベクトル(QのUDU^T分解の対角要素)
% n:  次元
% zh: 整数値バイアスのフロート解
% 返戻値
% U:  nxn変換後の単位上三角行列
% D:  n次元ベクトル(変換後の対角行列の要素)
% ZT: nxn変換行列
% zh: 変換後の整数値バイアスのフロート解
%
% Reference: LGR12
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 14/Nov. 2007
%-------------------------------------------------------------------------------

ZTi=eye(m); 	 % 変換行列リセット
ic=0; pf=1;
while pf==1
	i=1; pf=0;
	while (pf==0) & (i<m)
		if i>=ic
			[U,nh,ZTi]=intgauss(U,nh,ZTi,m,i+1,i+1);
		end
		t1=D(i)+U(i,i+1)^2*D(i+1);
		if D(i+1)>t1
			[U,D,nh,ZTi]=permutation(U,D,nh,ZTi,m,i,t1);
			pf=1;
		end
		ic=i; i=i+1;
	end
end


function [U nh ZTi] = intgauss(U,nh,ZTi,m,start,stop)
%-------------------------------------------------------------------------------
% UDU^T 分解された共分散行列のstart列からstop列までの整数ガウス変換
% を行う（列ごとの変換を行う）

% U:  mxm単位上三角行列
% nh: m次元整数値バイアスのfloat解
% m:  次元
%
% ZTi: mxm変換行列Z^Tの逆行列
% nh: 変換後のm次元整数値バイアスfloat解
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 12/Nov. 2007
%-------------------------------------------------------------------------------

for j=start:stop			% j: 列のインデックス
	for i=1:j-1				% i: 行のインデックス
		alpha=-round(U(i,j));
		if alpha~=0
			U(i,j:m)=U(i,j:m)+alpha*U(j,j:m);
%			ZT(i,1:m)=ZT(i,1:m)+alpha*ZT(j,1:m);
			ZTi(1:m,j)=ZTi(1:m,j)-alpha*ZTi(1:m,i);
		end
		nh(i)=nh(i)+alpha*nh(j);
	end
end


function [U,D,nh,ZTi]=permutation(U,D,nh,ZTi,m,i,t1)
%-------------------------------------------------------------------------------
% UDU^T のi行目とi+1行目を入れ換える

% U:  mxm単位上三角行列
% D:  mxm対角行列
% nh: mx1float解ベクトル
% ti: D(i) + U(i,i+1)^2 * D(i+1)
%
%(返戻値)
% U: 上三角行列（上書き）
% D: 対角行列（上書き）
% nh: float解ベクトル（上書き）
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 12/Nov. 2007
%-------------------------------------------------------------------------------

t2=U(i,i+1)*D(i+1);
t3=t2/t1;
t4=-U(i,i+1)*t3+1;
D(i)=D(i+1)-t2*t3;				% 対角要素の更新
D(i+1)=t1;
for j=1:i-1						% ブロック(U_12)行列の更新
	a=U(j,i);
	b=U(j,i+1);
	U(j,i)=-U(i,i+1)*a+b;
	U(j,i+1)=a*t4+b*t3;
end
U(i,i+1)=t3;					% ブロック(U_22)行列の更新
tmp=U(i,i+2:m);					% ブロック(U_23)行列の更新
U(i,i+2:m)=U(i+1,i+2:m);
U(i+1,i+2:m)=tmp;
%tmp = ZTi(i,:);				% 変換行列ZTiのi行目とi+1行目を入れ替え
%ZTi(i,:) = ZTi(i+1,:);
%ZTi(i+1,:) = tmp;
tmp=ZTi(:,i);					% 変換行列ZTiのi列目とi+1列目を入れ替え
ZTi(:,i)=ZTi(:,i+1);
ZTi(:,i+1)=tmp;
tmp=nh(i);						% zhのi番目とi+1番目を入れ替え
nh(i)=nh(i+1);
nh(i+1)=tmp;


function [chi2] = chisetting(U, D, m, nh, p)
%-------------------------------------------------------------------------------
% 探索空間の大きさを決める
%
% 引数
% 返戻値
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

res=zeros(m+1,1);

i=m+1;
while i>1
	i=i-1;
	mu(i)=U(i,i+1:m)*res(i+1:m);
	nb(i)=nh(i)+mu(i);
	nc(i)=round(nb(i));
	res(i)=nc(i)-nb(i);
end
J=(1./D)*(res(1:m).^2);

for k=m:-1:1
	if res(k)<0
		beta=1;
	else
		beta=-1;
	end
	resnew=res;
	resnew(k)=res(k)+beta;
	j=k;
	while j>1
		j=j-1;
		mu(j)=U(j,j+1:m)*resnew(j+1:m);
		nb(j)=nh(j)+mu(j);
		nc(j)=round(nb(j));
		resnew(j)=nc(j)-nb(j);
	end
	Jk(k)=(1./D)*(resnew(1:m).^2);
end

J = sort([J Jk]);
chi2 = J(p);
%chi2 = J(p)+1e-6;



function [can, Jall, ncan] = search(nh, U, D, m, chi2, maxcan)
%-------------------------------------------------------------------------------
% 探索
%
% 引数
% 返戻値
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

Jmin=1e10;
Jmax=1e10;
ncan=0;
Jall=[];
can=[];
res=zeros(m+1,1);
theta2(m+1)=chi2;

for i=1:m-1
	df(i)=D(i)/D(i+1);
end
df(m) = D(m);

i=m+1;
while i>1
	i=i-1;
	mu(i)=U(i,i+1:m)*res(i+1:m);
	theta2(i)=df(i)*(theta2(i+1)-res(i+1)^2);
	theta(i)=sqrt(theta2(i));
	delta=nh(i)+mu(i)-theta(i);
	lim(i)=delta+2*theta(i);
	nc(i)=ceil(delta);
	if nc(i)>lim(i)
		[i, nc, res]=backtrack(i, m, nc, lim, res);
	else
		res(i)=nc(i)-nh(i)-mu(i);
	end
	if i==1
		J=chi2-(theta2(1)-res(1)^2)/D(1);
		while nc(1)<=lim(1)
			ncan=ncan+1;
			[can, Jall, Jmin, Jmax]=savecan(J, Jall, Jmin, Jmax, nc, can, ncan, maxcan);
			nc(1)=nc(1)+1;
			J=J+(2*res(1)+1)/D(1);
			res(1)=res(1)+1;
		end
		[i nc res]=backtrack(i, m, nc, lim, res);
	end
end


function [i nc res] = backtrack(i, m, nc, lim, res)
%-------------------------------------------------------------------------------
% 
%
% 引数
% 返戻値
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

j=i+1;
while j<=m
	a=nc(j)+1;
	if a<=lim(j)
		nc(j)=a; res(j)=res(j)+1; i=j;
		break;
	end
	j=j+1;
end


function [can, Jall, Jmin, Jmax] = savecan(J, Jall, Jmin, Jmax, nc, can, ncan, maxcan)
%-------------------------------------------------------------------------------
% 候補を格納
%
% 引数
% 返戻値
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

if (ncan<=maxcan) | (maxcan==0)
	Jall=[Jall; J];
	can=[can; nc];
	[Jall order]=sort(Jall);
	can=can(order,:);
	Jmin=Jall(1);
	Jmax=Jall(ncan);
elseif J<Jmax
	Jall(maxcan)=J;
	can(maxcan,:)=nc;
	[Jall order]=sort(Jall);
	can=can(order,:);
	Jmin=Jall(1);
	Jmax=Jall(maxcan);
end

