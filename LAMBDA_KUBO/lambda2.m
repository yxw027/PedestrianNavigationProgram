function [ncheck Jall] = lambda(Q,nh,fid)
%-------------------------------------------------------------------------------
% LAMBDA Method
%
% [argin]
% Q   : Float Ambiguity Covarience Matrix
% nh  : Float Ambiguity
% fid : File pointer
%
% [argout]
% ncheck : Fix Ambiguity
% Jall   : Residuals
%
% �T�u�֐����ƈ����̕ύX(by fujita)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Kubo: 
%-------------------------------------------------------------------------------

m=length(nh);												% Ambiguity�̐�
p=2;														% �T����ԂɊ܂߂���̍Œ��(p<=m+1)
maxcan = 2; 												% �L�^������̍ő��
nhd = rem(nh,1);											% Ambiguity�̐�������������
ndiff = nh - nhd;											% ��������
[Un,Dn] = ud(Q,m);											% Q��UDU^T��������
[Uz,Dz,zh,ZTi]=lamtrans(Un,Dn,nhd,m);						% �����։�����
[chi2] = chisetting(Uz, Dz, m, zh, p);						% �T����Ԃ̑傫�������߂�
chi2 = chi2 + 1e-6; 										% ���E���܂�ŒT������悤��Chi^2�������傫������
[can, Jall, ncan] = search(zh, Uz, Dz, m, chi2, maxcan);	% �T��(���, �]���֐��l)
% zcheck = can(1,:)';											% �����
% Jzcheck = Jall(1);											% �����ɑ΂���]���֐��l
% ncheck = ZTi * zcheck + ndiff;								% �������t�ϊ�����
% if fid ~= -1												% LAMBDA�@�̃��O���o��
% 	savelamlog(fid,m,nh,nhd,ndiff,Q,Un,Dn,ZTi,zh,Uz,Dz,ncan,chi2,Jall,can);
% end
for i=1:size(can,1)
	ncheck(:,i)=ZTi*can(i,:)' + ndiff;						% ���S�Ăɂ��ċt�ϊ�����
end



%-------------------------------------------------------------------------------
% �T�u���[�`��

function [U,D] = ud(Q,m)
%-------------------------------------------------------------------------------
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
%-------------------------------------------------------------------------------

for k=m:-1:2
	D(k)=Q(k,k); U(k,k)=1;
	for j=1:k-1
		U(j,k)=Q(j,k)/D(k);
		for i=1:j
			Q(i,j)=Q(i,j)-U(i,k)*U(j,k)*D(k);
		end
	end
end
U(1,1)=1; D(1)=Q(1,1);


function [U,D,nh,ZTi]=lamtrans(U,D,nh,m)
%-------------------------------------------------------------------------------
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
%-------------------------------------------------------------------------------

ZTi=eye(m); 	 % �ϊ��s�񃊃Z�b�g
ic=0; pf=1;
while pf==1
	i=1; pf=0;
	while (pf==0) & (i<m)
		if i>=ic
			[U,nh,ZTi]=intgauss(U,nh,ZTi,m,i+1,i+1);
		end
		t1=D(i)+U(i,i+1)^2*D(i+1);
		if D(i+1)>t1
			[U,D,nh,ZTi]=permutation(U,D,nh,ZTi,m,i,t1);
			pf=1;
		end
		ic=i; i=i+1;
	end
end


function [U nh ZTi] = intgauss(U,nh,ZTi,m,start,stop)
%-------------------------------------------------------------------------------
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
%-------------------------------------------------------------------------------

for j=start:stop			% j: ��̃C���f�b�N�X
	for i=1:j-1				% i: �s�̃C���f�b�N�X
		alpha=-round(U(i,j));
		if alpha~=0
			U(i,j:m)=U(i,j:m)+alpha*U(j,j:m);
%			ZT(i,1:m)=ZT(i,1:m)+alpha*ZT(j,1:m);
			ZTi(1:m,j)=ZTi(1:m,j)-alpha*ZTi(1:m,i);
		end
		nh(i)=nh(i)+alpha*nh(j);
	end
end


function [U,D,nh,ZTi]=permutation(U,D,nh,ZTi,m,i,t1)
%-------------------------------------------------------------------------------
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
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 12/Nov. 2007
%-------------------------------------------------------------------------------

t2=U(i,i+1)*D(i+1);
t3=t2/t1;
t4=-U(i,i+1)*t3+1;
D(i)=D(i+1)-t2*t3;				% �Ίp�v�f�̍X�V
D(i+1)=t1;
for j=1:i-1						% �u���b�N(U_12)�s��̍X�V
	a=U(j,i);
	b=U(j,i+1);
	U(j,i)=-U(i,i+1)*a+b;
	U(j,i+1)=a*t4+b*t3;
end
U(i,i+1)=t3;					% �u���b�N(U_22)�s��̍X�V
tmp=U(i,i+2:m);					% �u���b�N(U_23)�s��̍X�V
U(i,i+2:m)=U(i+1,i+2:m);
U(i+1,i+2:m)=tmp;
%tmp = ZTi(i,:);				% �ϊ��s��ZTi��i�s�ڂ�i+1�s�ڂ����ւ�
%ZTi(i,:) = ZTi(i+1,:);
%ZTi(i+1,:) = tmp;
tmp=ZTi(:,i);					% �ϊ��s��ZTi��i��ڂ�i+1��ڂ����ւ�
ZTi(:,i)=ZTi(:,i+1);
ZTi(:,i+1)=tmp;
tmp=nh(i);						% zh��i�Ԗڂ�i+1�Ԗڂ����ւ�
nh(i)=nh(i+1);
nh(i+1)=tmp;


function [chi2] = chisetting(U, D, m, nh, p)
%-------------------------------------------------------------------------------
% �T����Ԃ̑傫�������߂�
%
% ����
% �Ԗߒl
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

res=zeros(m+1,1);

i=m+1;
while i>1
	i=i-1;
	mu(i)=U(i,i+1:m)*res(i+1:m);
	nb(i)=nh(i)+mu(i);
	nc(i)=round(nb(i));
	res(i)=nc(i)-nb(i);
end
J=(1./D)*(res(1:m).^2);

for k=m:-1:1
	if res(k)<0
		beta=1;
	else
		beta=-1;
	end
	resnew=res;
	resnew(k)=res(k)+beta;
	j=k;
	while j>1
		j=j-1;
		mu(j)=U(j,j+1:m)*resnew(j+1:m);
		nb(j)=nh(j)+mu(j);
		nc(j)=round(nb(j));
		resnew(j)=nc(j)-nb(j);
	end
	Jk(k)=(1./D)*(resnew(1:m).^2);
end

J = sort([J Jk]);
chi2 = J(p);
%chi2 = J(p)+1e-6;



function [can, Jall, ncan] = search(nh, U, D, m, chi2, maxcan)
%-------------------------------------------------------------------------------
% �T��
%
% ����
% �Ԗߒl
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

Jmin=1e10;
Jmax=1e10;
ncan=0;
Jall=[];
can=[];
res=zeros(m+1,1);
theta2(m+1)=chi2;

for i=1:m-1
	df(i)=D(i)/D(i+1);
end
df(m) = D(m);

i=m+1;
while i>1
	i=i-1;
	mu(i)=U(i,i+1:m)*res(i+1:m);
	theta2(i)=df(i)*(theta2(i+1)-res(i+1)^2);
	theta(i)=sqrt(theta2(i));
	delta=nh(i)+mu(i)-theta(i);
	lim(i)=delta+2*theta(i);
	nc(i)=ceil(delta);
	if nc(i)>lim(i)
		[i, nc, res]=backtrack(i, m, nc, lim, res);
	else
		res(i)=nc(i)-nh(i)-mu(i);
	end
	if i==1
		J=chi2-(theta2(1)-res(1)^2)/D(1);
		while nc(1)<=lim(1)
			ncan=ncan+1;
			[can, Jall, Jmin, Jmax]=savecan(J, Jall, Jmin, Jmax, nc, can, ncan, maxcan);
			nc(1)=nc(1)+1;
			J=J+(2*res(1)+1)/D(1);
			res(1)=res(1)+1;
		end
		[i nc res]=backtrack(i, m, nc, lim, res);
	end
end


function [i nc res] = backtrack(i, m, nc, lim, res)
%-------------------------------------------------------------------------------
% 
%
% ����
% �Ԗߒl
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

j=i+1;
while j<=m
	a=nc(j)+1;
	if a<=lim(j)
		nc(j)=a; res(j)=res(j)+1; i=j;
		break;
	end
	j=j+1;
end


function [can, Jall, Jmin, Jmax] = savecan(J, Jall, Jmin, Jmax, nc, can, ncan, maxcan)
%-------------------------------------------------------------------------------
% �����i�[
%
% ����
% �Ԗߒl
%
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%-------------------------------------------------------------------------------

if (ncan<=maxcan) | (maxcan==0)
	Jall=[Jall; J];
	can=[can; nc];
	[Jall order]=sort(Jall);
	can=can(order,:);
	Jmin=Jall(1);
	Jmax=Jall(ncan);
elseif J<Jmax
	Jall(maxcan)=J;
	can(maxcan,:)=nc;
	[Jall order]=sort(Jall);
	can=can(order,:);
	Jmin=Jall(1);
	Jmax=Jall(maxcan);
end

