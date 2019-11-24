function [U,D,nh,ZTi]=permutation(U,D,nh,ZTi,m,i,t1)
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

t2 = U(i,i+1) * D(i+1);
t3 = t2/t1;
t4 = -U(i,i+1)*t3+1;
D(i) = D(i+1) - t2 * t3;        % 対角要素の更新
D(i+1) = t1;
for j = 1 : i-1                 % ブロック(U_12)行列の更新
    a = U(j,i);
    b = U(j,i+1);
    U(j,i)   =  -U(i,i+1) * a + b;
    U(j,i+1) = a*t4 + b*t3;
end
U(i,i+1) = t3;                  % ブロック(U_22)行列の更新
tmp = U(i,i+2:m);               % ブロック(U_23)行列の更新
U(i,i+2:m) = U(i+1,i+2:m);
U(i+1,i+2:m) = tmp;
%tmp = ZTi(i,:);                 % 変換行列ZTiのi行目とi+1行目を入れ替え
%ZTi(i,:) = ZTi(i+1,:);
%ZTi(i+1,:) = tmp;
tmp = ZTi(:,i);                 % 変換行列ZTiのi列目とi+1列目を入れ替え
ZTi(:,i) = ZTi(:,i+1);
ZTi(:,i+1) = tmp;
tmp = nh(i);                    % zhのi番目とi+1番目を入れ替え
nh(i) = nh(i+1);
nh(i+1) = tmp;

