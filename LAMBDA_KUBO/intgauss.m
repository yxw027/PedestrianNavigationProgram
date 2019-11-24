function [U nh ZTi] = intgauss(U,nh,ZTi,m,start,stop)
% UDU^T �������ꂽ�����U�s���start�񂩂�stop��܂ł̐����K�E�X�ϊ�
% ���s���i�񂲂Ƃ̕ϊ����s���j

% U:  mxm�P�ʏ�O�p�s��
% nh: m���������l�o�C�A�X��float��
% m:  ����
%
% ZTi: mxm�ϊ��s��Z^T�̋t�s��
% nh: �ϊ����m���������l�o�C�A�Xfloat��
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

for j = start : stop        % j: ��̃C���f�b�N�X
    for i = 1 : j-1         % i: �s�̃C���f�b�N�X
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
% Matlab���̂܂ܓI�i�����I�������ʂ���j
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

