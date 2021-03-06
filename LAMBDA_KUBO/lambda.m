function [ncheck Jzcheck] = lambda(Q,nh,m,fid)


%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [5.45 3.10 2.97]';
%m=3;
%Q = [6.290  5.978  0.544;
%     5.978  6.292  2.340;
%     0.544  2.340  6.288];
%[fid]=fopen('lambda.log','wt');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=2;                          % 探索空間に含める候補の最低個数(p<=m+1)
maxcan = 2;                   % 記録する候補の最大個数
nhd = rem(nh,1);              % Ambiguityの整数部分を除く
ndiff = nh - nhd;             % 整数部分
[Un,Dn] = ud(Q,m);            % QをUDU^T分解する
[Uz,Dz,zh,ZTi]=lamtrans(Un,Dn,nhd,m);   % 無相関化する
[chi2] = chisetting(Uz, Dz, m, zh, p);  % 探索空間の大きさを決める
chi2 = chi2 + 1e-6;                     % 境界を含んで探索するようにChi^2を少し大きくする
[can, Jall, ncan] = search(zh, Uz, Dz, m, chi2, maxcan);    % 探索
zcheck = can(1,:)';             % 第一候補
Jzcheck = Jall(1);              % 第一候補に対する評価関数値
ncheck = ZTi * zcheck + ndiff;  % 第一候補を逆変換する
if fid ~= -1                    % LAMBDA法のログを出力
    savelamlog(fid,m,nh,nhd,ndiff,Q,Un,Dn,ZTi,zh,Uz,Dz,ncan,chi2,Jall,can);
end

%
%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%
%fid
%fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%
%


