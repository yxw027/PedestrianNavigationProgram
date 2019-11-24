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

p=2;                          % �T����ԂɊ܂߂���̍Œ��(p<=m+1)
maxcan = 2;                   % �L�^������̍ő��
nhd = rem(nh,1);              % Ambiguity�̐�������������
ndiff = nh - nhd;             % ��������
[Un,Dn] = ud(Q,m);            % Q��UDU^T��������
[Uz,Dz,zh,ZTi]=lamtrans(Un,Dn,nhd,m);   % �����։�����
[chi2] = chisetting(Uz, Dz, m, zh, p);  % �T����Ԃ̑傫�������߂�
chi2 = chi2 + 1e-6;                     % ���E���܂�ŒT������悤��Chi^2�������傫������
[can, Jall, ncan] = search(zh, Uz, Dz, m, chi2, maxcan);    % �T��
zcheck = can(1,:)';             % �����
Jzcheck = Jall(1);              % �����ɑ΂���]���֐��l
ncheck = ZTi * zcheck + ndiff;  % �������t�ϊ�����
if fid ~= -1                    % LAMBDA�@�̃��O���o��
    savelamlog(fid,m,nh,nhd,ndiff,Q,Un,Dn,ZTi,zh,Uz,Dz,ncan,chi2,Jall,can);
end

%
%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%
%fid
%fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%
%


