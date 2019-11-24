function [U,D] = ud(Q,m)
%�s��Q��UDU^T�������s���CU,D���o��

% Q: mxm ����l�Ώ̍s��
% n: �s��Q�̎���
% U: �P�ʏ�O�p�s��
% D: �Ίp�s��̑Ίp�����in�����x�N�g���j
%
% Reference: �ЎR�C�V�ŉ��p�J���}���t�B���^�C���q���X
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
