function [U,D,nh,ZTi]=lamtrans(U,D,nh,m)
%

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



%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [1 1 1];
%m=3;
%
%Q = [6.290  5.978  0.544;
%      5.978  6.292  2.340;
%      0.544  2.340  6.288];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [1 1 1 1 1 1 1 1 1];
%m=9;
%QQ = [Q         zeros(3) zeros(3);
%      zeros(3)  Q        zeros(3);
%      zeros(3)  zeros(3) Q];
%
%Q = QQ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [1.05 1.30];
%m=2;
%Q = [53.4 38.4;
%      38.4 28.0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[U,D] = ud(Q,m);


ZTi=eye(m);      % 変換行列リセット
ic=0;
pf=1;
while pf==1
    i = 1;
    pf = 0;
    while (pf == 0) & (i<m)
        if i>=ic
            [U,nh,ZTi] = intgauss(U,nh,ZTi,m,i+1,i+1);
        end
        t1 = D(i) + U(i,i+1)^2 * D(i+1);
        if D(i+1) > t1
            [U,D,nh,ZTi] = permutation(U,D,nh,ZTi,m,i,t1);
            pf = 1;
        end
        ic = i;
        i = i+1;
    end
end
