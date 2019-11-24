function [U,D,nh,ZTi]=lamtrans(U,D,nh,m)
%

% ����
% U:  nxn�P�ʏ�O�p�s��(Q��UDU^T����)
% D:  n�����x�N�g��(Q��UDU^T�����̑Ίp�v�f)
% n:  ����
% zh: �����l�o�C�A�X�̃t���[�g��
% �Ԗߒl
% U:  nxn�ϊ���̒P�ʏ�O�p�s��
% D:  n�����x�N�g��(�ϊ���̑Ίp�s��̗v�f)
% ZT: nxn�ϊ��s��
% zh: �ϊ���̐����l�o�C�A�X�̃t���[�g��
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


ZTi=eye(m);      % �ϊ��s�񃊃Z�b�g
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
