function [U,D] = ud(Q,m)
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

for k = m : -1 : 2
	D(k) = Q(k,k);
	U(k,k) = 1;
	for j = 1 : k-1
		U(j,k) = Q(j,k) / D(k);
		for i = 1 : j
			Q(i,j) = Q(i,j) - U(i,k)*U(j,k)*D(k);
		end
	end
end
U(1,1) = 1;
D(1) = Q(1,1);
