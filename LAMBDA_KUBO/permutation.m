function [U,D,nh,ZTi]=permutation(U,D,nh,ZTi,m,i,t1)
% UDU^T ��i�s�ڂ�i+1�s�ڂ���ꊷ����

% U:  mxm�P�ʏ�O�p�s��
% D:  mxm�Ίp�s��
% nh: mx1float���x�N�g��
% ti: D(i) + U(i,i+1)^2 * D(i+1)
%
%(�Ԗߒl)
% U: ��O�p�s��i�㏑���j
% D: �Ίp�s��i�㏑���j
% nh: float���x�N�g���i�㏑���j

t2 = U(i,i+1) * D(i+1);
t3 = t2/t1;
t4 = -U(i,i+1)*t3+1;
D(i) = D(i+1) - t2 * t3;        % �Ίp�v�f�̍X�V
D(i+1) = t1;
for j = 1 : i-1                 % �u���b�N(U_12)�s��̍X�V
    a = U(j,i);
    b = U(j,i+1);
    U(j,i)   =  -U(i,i+1) * a + b;
    U(j,i+1) = a*t4 + b*t3;
end
U(i,i+1) = t3;                  % �u���b�N(U_22)�s��̍X�V
tmp = U(i,i+2:m);               % �u���b�N(U_23)�s��̍X�V
U(i,i+2:m) = U(i+1,i+2:m);
U(i+1,i+2:m) = tmp;
%tmp = ZTi(i,:);                 % �ϊ��s��ZTi��i�s�ڂ�i+1�s�ڂ����ւ�
%ZTi(i,:) = ZTi(i+1,:);
%ZTi(i+1,:) = tmp;
tmp = ZTi(:,i);                 % �ϊ��s��ZTi��i��ڂ�i+1��ڂ����ւ�
ZTi(:,i) = ZTi(:,i+1);
ZTi(:,i+1) = tmp;
tmp = nh(i);                    % zh��i�Ԗڂ�i+1�Ԗڂ����ւ�
nh(i) = nh(i+1);
nh(i+1) = tmp;

