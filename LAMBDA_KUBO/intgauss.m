function [U nh ZTi] = intgauss(U,nh,ZTi,m,start,stop)
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

%For Debug%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [5.45 3.10 2.97];
%m=3;
%Q = [6.290  5.978  0.544;
%     5.978  6.292  2.340;
%     0.544  2.340  6.288];
%ZTi = eye(m);
%start = 2;
%stop = m;
%[U D] = ud(Q,m);
%For Debug%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = start : stop        % j: 列のインデックス
    for i = 1 : j-1         % i: 行のインデックス
        alpha = -round(U(i,j));
        if alpha ~= 0
            U(i,j:m)   = U(i,j:m)  + alpha * U(j,j:m);
%            ZT(i,1:m) = ZT(i,1:m) + alpha * ZT(j,1:m);
            ZTi(1:m,j) = ZTi(1:m,j) - alpha * ZTi(1:m,i);
        end
        nh(i) = nh(i) + alpha * nh(j);
    end
end


%
% Matlabそのまま的（直感的だが無駄あり）
%*********************************************************************
%II=eye(m);
%for j = start : stop
%    for i = 1 : j-1
%        alpha = -round(U(i,j));
%        if alpha ~= 0
%            G = II;
%            G(i,j) = alpha;
%            U = G *U;
%            ZT = G * ZT;
%        end
%    end
%end
%nh = ZT * nh';

