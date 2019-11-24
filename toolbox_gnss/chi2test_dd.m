function [zz,H,R,Kalx_p,KalP_p,prn,ix,nx,prn_rej]=chi2test_dd(zz,H,R,Kalx_p,KalP_p,prn,ix,nx,est_prm,a)
%-------------------------------------------------------------------------------
% Function : ��2����{��������(���Α��ʗp)
%
% [argin]
% zz      : mx1 �C�m�x�[�V�����x�N�g��: y-h(x^)
% H       : mxn �ϑ��s��: ���`�������ۂ̕Δ����W��
% R       : mxm �ϑ��G�������U�s��
% Kalx_p  : nx1 ��i�\���l
% KalP_p  : nxn ��i�\���l�̐���덷�����U�s��
% prn     : �q��PRN�\����
% ix      : ��ԕϐ��̃C���f�b�N�X
% nx      : ��ԕϐ��̎���
% est_prm : �����ݒ�p�����[�^
% a       : �L�Ӑ���(�댯��)
%
% [argout]
% zz      : mx1 �C�m�x�[�V�����x�N�g��: y-h(x^)
% H       : mxn �ϑ��s��: ���`�������ۂ̕Δ����W��
% R       : mxm �ϑ��G�������U�s��
% Kalx_p  : nx1 �h�g����l
% KalP_p  : nxn �h�g����l�̐���덷�����U�s��
% prn     : �q��PRN�\����
% ix      : ��ԕϐ��̃C���f�b�N�X
% nx      : ��ԕϐ��̎���
% prn_rej : ���O���ꂽ�q��PRN
%
% ��q���Ɉُ킪�N�����ꍇ�̕ۏ؂͂ł��܂���
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 05, 2008
%-------------------------------------------------------------------------------
% �d���w��d�����莞�ɑΉ�
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

% ���O�c���̌���(��2����)
%--------------------------------------------
M=H*KalP_p*H'+R;							% �C�m�x�[�V�����̋����U
Zs=(zz.^2)./diag(M);						% ���K�������C�m�x�[�V����
n=1;										% n:���R�x, �L�Ӑ���(�댯��)�͈���
sigma=x2a(n,a);								% ��2���z�̏㑤�m���_ n:���R�x, �L�Ӑ���(�댯��)

no_dd=length(prn.u)-1; j1=[]; j2=[];
Zs1=Zs(1:no_dd);							% L1��
j1=find(Zs1>=sigma);						% ��2����(���o���ꂽ�ꍇ�͏��O)
if est_prm.freq==2
	Zs2=Zs(no_dd+1:2*no_dd);				% L2��
	j2=find(Zs2>=sigma);					% ��2����(���o���ꂽ�ꍇ�͏��O)
end
j=union(j1,j2);								% L1�т�L2�т̌��o�����C���f�b�N�X������(2���g�̂�)
if size(j,1)~=1, j=j'; end					% �C���f�b�N�X��]�u(���ɕ��ׂ邽��)
prn_rej=prn.u(j+1);							% ���O�q��PRN


% ���O�c���̌���(��Βl����)
%--------------------------------------------
% sigma=30;
% no_dd=length(prn.u)-1; j1=[]; j2=[];
% zz1=zz(1:no_dd);							% L1��
% j1=find(abs(zz1)>=sigma);					% ��Βl����(���o���ꂽ�ꍇ�͏��O)
% if est_prm.freq==2
% 	zz2=zz(no_dd+1:2*no_dd);				% L2��
% 	j2=find(zz2>=sigma);					% ��Βl����(���o���ꂽ�ꍇ�͏��O)
% end
% j=union(j1,j2);								% L1�т�L2�т̌��o�����C���f�b�N�X������(2���g�̂�)
% if size(j,1)~=1, j=j'; end					% �C���f�b�N�X��]�u(���ɕ��ׂ邽��)
% prn_rej=prn.u(j+1);							% ���O�q��PRN


if ~isempty(j)
	%--- ���O���邽�߂̃C���f�b�N�X����
	%--------------------------------------------
	if est_prm.freq==1												% 1���g
		switch est_prm.statemodel.ion	% yanase
		case 0, indexxp=[ix.n(j)];									% X,P�p�̃C���f�b�N�X
		case 1, indexxp=[ix.i(j),ix.n(j)];							% X,P�p�̃C���f�b�N�X
		case 2, indexxp=[ix.i(j+1),ix.n(j)];						% X,P�p�̃C���f�b�N�X
		case 3, indexxp=[ix.i(j+1),ix.n(j)];						% X,P�p�̃C���f�b�N�X
		case 4, indexxp=[ix.i(j+1),ix.n(j)];						% X,P�p�̃C���f�b�N�X
		case 5, indexxp=[ix.n(j)];									% X,P�p�̃C���f�b�N�X
		case 6, indexxp=[ix.n(j)];									% X,P�p�̃C���f�b�N�X
		case 7, indexxp=[ix.n(j)];									% X,P�p�̃C���f�b�N�X
		end

		if est_prm.pr_flag==1
			indexz=[j,no_dd+j];										% �ϑ��֘A�p�̃C���f�b�N�X(PR����)
		else
			indexz=[j];												% �ϑ��֘A�p�̃C���f�b�N�X(PR�Ȃ�)
		end
	else															% 2���g
		switch est_prm.statemodel.ion	% yanase
		case 0, indexxp=[ix.n([j,no_dd+j])];						% X,P�p�̃C���f�b�N�X
		case 1, indexxp=[ix.i(j),ix.n([j,no_dd+j])];				% X,P�p�̃C���f�b�N�X
		case 2, indexxp=[ix.i(j+1),ix.n([j,no_dd+j])];				% X,P�p�̃C���f�b�N�X
		case 3, indexxp=[ix.i(j+1),ix.n([j,no_dd+j])];				% X,P�p�̃C���f�b�N�X
		case 4, indexxp=[ix.i(j+1),ix.n([j,no_dd+j])];				% X,P�p�̃C���f�b�N�X
		case 5, indexxp=[ix.n([j,no_dd+j])];						% X,P�p�̃C���f�b�N�X
		case 6, indexxp=[ix.n([j,no_dd+j])];						% X,P�p�̃C���f�b�N�X
		case 7, indexxp=[ix.n([j,no_dd+j])];						% X,P�p�̃C���f�b�N�X
		end

		if est_prm.pr_flag==1
			indexz=[j,no_dd+j,2*no_dd+j,3*no_dd+j];					% �ϑ��֘A�p�̃C���f�b�N�X(PR����)
		else
			indexz=[j,no_dd+j];										% �ϑ��֘A�p�̃C���f�b�N�X(PR�Ȃ�)
		end
	end

	%--- ���o�����q�����������O
	%--------------------------------------------
	Kalx_p(indexxp)=[]; KalP_p(indexxp,:)=[]; KalP_p(:,indexxp)=[];
	zz(indexz)=[]; H(indexz,:)=[]; H(:,indexxp)=[];
	R(indexz,:)=[]; R(:,indexz)=[];
	irej1=[]; irej2=[];
	for k=prn_rej
		irej1=[irej1 find(prn.float==k)];							% prn.float�p
		irej2=[irej2 find(prn.fix==k)];								% prn.fix�p
	end
	prn.float(irej1)=[];											% ���O
	prn.fix(irej2)=[];												% ���O
	prn.u(j+1)=[];													% ���O

	%--- ���O��̎����̐ݒ�(�g�p�q��)
	%--------------------------------------------
	ns=length(prn.u); 
	switch est_prm.statemodel.ion	% yanase
	case 0, ix.i=[]; nx.i=0; nx.x=nx.u+nx.T+nx.i;
	case 1, ix.i=nx.u+nx.T+(1:ns-1); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 2, ix.i=nx.u+nx.T+(1:ns); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 3, ix.i=nx.u+nx.T+(1:ns); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 4, ix.i=nx.u+nx.T+(1:ns+4); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 5, ix.i=nx.u+nx.T+(1:2); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 6, ix.i=nx.u+nx.T+(1:4); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	case 7, ix.i=nx.u+nx.T+(1:6); nx.i=length(ix.i); nx.x=nx.u+nx.T+nx.i;
	end
	ix.n=nx.x+(1:est_prm.freq*(ns-1)); nx.n=length(ix.n); nx.x=nx.x+nx.n;
end



%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

% x2a(n) : chi-squre distribution critical value -------------------------------
function x=x2a(n,a)

% set range of search
r=[0,10]; while a<x2q(n,r(2)), r(2)=r(2)*2; end

% binary search
while 1
    x=(r(1)+r(2))/2; p=x2q(n,x);
    if abs(p-a)<a*1E-5, break, elseif p<a, r(2)=x; else r(1)=x; end
end

% chi-square function ----------------------------------------------------------
function p=x2q(n,x), p=1-gammainc(x/2,n/2);
