function [x,P]=state_adjust_dd(prn,x_p,P_p,nx,est_prm,X1,X2,X3,N_ref)
%-------------------------------------------------------------------------------
% Function : ��i�\���̎�������(DD�p) --- �������q���̏����l�͋t�Z�ŎZ�o��������
% 
% [argin]
% prn         : �q��PRN�ԍ�(prn.u, prn.o, prn.float_o)
% x_p         : ��i�\���l
% P_p         : ��i�\���l�̋����U
% nx          : ��ԕϐ��̎���(�\����)---�O�G�|�b�N
% est_prm     : �����ݒ�p�����[�^(�\����)
% X1          : �����l(�����l�o�C�A�X, �d���w�Ȃ�)
% X2          : �����l(�����l�o�C�A�X, �d���w�Ȃ�)
% X3          : �����l(�����l�o�C�A�X, �d���w�Ȃ�)
% N_ref       : ��؊������p(�Œ莞)
% 
% [argout]
% x     : ��i�\���l(����������)
% P     : ��i�\���l�̋����U(����������)
% 
% 
% ���g���Ɋ֌W�Ȃ�, �����������K�v�ȏ�ԕϐ��̌��ɉ����Ď��������ł���悤�ɕύX
% �d���w�̐��������ꍇ, �ϑ��s��ƑΉ����鏇�Ԃ�X1-X3(�ł������X1)�̏��ɓ���邱��
% 
% ��؊����������֐����ōs���悤�ɕύX
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% �d���w��d�����莞�ɑΉ�
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

%--------------------------------------------
% �ŏ��ɏ�ԕϐ�, ���U�ɑ傫�Ȕz�����������.
% ���̔z���\���l�Œu�����Ď������߂��ꂽ
% ��ԕϐ�, ���U���쐬����.
% ��: �z���PRN���ԍ��Ƃ��Ĉ���
%--------------------------------------------
nn=3;
if isempty(X1), nn=nn-1;, end												% ��ł���� "-1" ����
if isempty(X2), nn=nn-1;, end												% ��ł���� "-1" ����
if isempty(X3), nn=nn-1;, end												% ��ł���� "-1" ����

%--- ��ԕϐ��Ƌ����U(��؊�������)
%--------------------------------------------
init_flag=0;																% �������t���O(OFF)
if isfield(prn,'float_o')
	N_o{1}(1:32,1)=NaN;														% �q��PRN���C���f�b�N�X�Ƃ��Ĉ������߂̏���
	N_o{1}(prn.float_o(2:end),1)=...
			x_p(nx.u+nx.T+nx.i+1:nx.u+nx.T+nx.i+nx.n/est_prm.freq);			% �t���[�g�����i�[
	N_refo(1)=N_o{1}(prn.u(1),1);											% ��؊��������̏���
	if est_prm.freq==2
		N_o{2}(1:32,1)=NaN;													% �q��PRN���C���f�b�N�X�Ƃ��Ĉ������߂̏���
		N_o{2}(prn.float_o(2:end),1)=...
				x_p(nx.u+nx.T+nx.i+nx.n/est_prm.freq+1:end);				% �t���[�g�����i�[
		N_refo(2)=N_o{2}(prn.u(1),1);										% ��؊��������̏���
	end
	iref=find(prn.float_o==prn.u(1));										% ��q���̃C���f�b�N�X(prn.float_o��)
	DD=eye(length(prn.float_o)-1); DD2=eye(nx.u+nx.T+nx.i);					% �P�ʍs��
	if iref~=1																% ��q�����ω������ꍇ(�Œ肵�ĂȂ��q����)
		N_o{1}(:,1)=N_o{1}(:,1)-N_refo(1);									% ��؊�������
		N_o{1}(prn.float_o(1),1)=-N_refo(1);								% ��؊�������
		if est_prm.freq==2
			N_o{2}(:,1)=N_o{2}(:,1)-N_refo(2);								% ��؊�������
			N_o{2}(prn.float_o(1),1)=-N_refo(2);							% ��؊�������
		end
		DD(:,iref-1)=-1;													% �ϊ��s��(�����l�o�C�A�X�̕���)
	elseif isempty(iref)													% ��q�����ω������ꍇ(�Œ肵���q����)
		if ~isnan(N_ref(1))
			N_o{1}(:,1)=N_o{1}(:,1)-N_ref(1);								% ��؊�������(N_ref1�𗘗p) N_ref1:�萔
			N_o{1}(prn.float_o(1),1)=-N_ref(1);								% ��؊�������(N_ref1�𗘗p) N_ref1:�萔
			if est_prm.freq==2
				N_o{2}(:,1)=N_o{2}(:,1)-N_ref(2);							% ��؊�������(N_ref2�𗘗p) N_ref2:�萔
				N_o{2}(prn.float_o(1),1)=-N_ref(2);							% ��؊�������(N_ref2�𗘗p) N_ref2:�萔
			end
		else
			init_flag=1;													% �������t���O(ON)
		end
	end
	if est_prm.freq==1
		x_p(nx.u+nx.T+nx.i+1:end)=[N_o{1}(prn.float_o(2:end))];				% ��ԕϐ�(�ϊ���, 1���g)
	elseif est_prm.freq==2
		x_p(nx.u+nx.T+nx.i+1:end)=...
				[N_o{1}(prn.float_o(2:end)); N_o{2}(prn.float_o(2:end))];	% ��ԕϐ�(�ϊ���, 2���g)
	end
	if nx.n/est_prm.freq~=0 & est_prm.freq==1
		DD2=blkdiag(DD2,DD);												% �ϊ��s��(1���g)
	end
	if nx.n/est_prm.freq~=0 & est_prm.freq==2
		DD2=blkdiag(DD2,DD,DD);												% �ϊ��s��(2���g)
	end
	P_p=DD2*P_p*DD2';														% �����U(�ϊ���)
else
	prn.float_o=prn.o;
end

%--- ��ԕϐ��Ƌ����U(������������)
%--------------------------------------------
switch est_prm.statemodel.ion	% yanase
case {0,1,2,3,4}															% �d���w�̏�ԕϐ����q�����ɂ��ϓ�����ꍇ
	index_o=[];																% �O�G�|�b�N�̃C���f�b�N�X�p
	index_n=[];																% ���G�|�b�N�̃C���f�b�N�X�p
	for k=1:nn
		if k==1 & ~isempty(X1)
			switch est_prm.statemodel.ion	% yanase
			case 1,
				index_o=[index_o nx.u+nx.T+prn.o(2:end)+32*(k-1)];			% �C���f�b�N�X(prn.o���p)
				index_n=[index_n nx.u+nx.T+prn.u(2:end)+32*(k-1)];			% �C���f�b�N�X(prn)
			case {2,3},
				index_o=[index_o nx.u+nx.T+prn.o+32*(k-1)];					% �C���f�b�N�X(prn.o���p)
				index_n=[index_n nx.u+nx.T+prn.u+32*(k-1)];					% �C���f�b�N�X(prn)
			case 4,
				index_o=[index_o nx.u+nx.T+prn.o+32*(k-1)];					% �C���f�b�N�X(prn.o���p)
				index_n=[index_n nx.u+nx.T+prn.u+32*(k-1)];					% �C���f�b�N�X(prn)
				X1=X1(1:end-4);
			end
		else
			if length(prn.float_o)>1
				index_o=[index_o nx.u+nx.T+prn.float_o(2:end)+32*(k-1)];	% �C���f�b�N�X(prn.float_o���p)
			end
			index_n=[index_n nx.u+nx.T+prn.u(2:end)+32*(k-1)];				% �C���f�b�N�X(prn.u���p)
		end
	end
	x=zeros(nx.u+nx.T+32*nn,1);												% ��Ԃ̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
	% P=eye(nx.u+nx.T+32*nn)*10;											% ���U�̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
	P=eye(nx.u+nx.T);
	for i=1:nn
		if ~isempty(X1) & i==1
			P=blkdiag(P,eye(32)*0.1);										% ���U�̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
		else
			P=blkdiag(P,eye(32)*10);										% ���U�̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
		end
	end

	x(index_n)=[X1;X2;X3];													% �d���w, �����l�o�C�A�X�̕�����u��

	if est_prm.statemodel.ion==4	% yanase
		x([1:nx.u+nx.T+4,index_o])=x_p;											% �\���l�Œu��
		x=x([1:nx.u+nx.T+4,index_n]);												% ���q���̂ݒ��o
		P([1:nx.u+nx.T+4,index_o],[1:nx.u+nx.T+4,index_o])=P_p;						% �\�����U�Œu��
		P=P([1:nx.u+nx.T+4,index_n],[1:nx.u+nx.T+4,index_n]);						% ���q���̂ݒ��o
	else
		x([1:nx.u+nx.T,index_o])=x_p;											% �\���l�Œu��
		x=x([1:nx.u+nx.T,index_n]);												% ���q���̂ݒ��o
		P([1:nx.u+nx.T,index_o],[1:nx.u+nx.T,index_o])=P_p;						% �\�����U�Œu��
		P=P([1:nx.u+nx.T,index_n],[1:nx.u+nx.T,index_n]);						% ���q���̂ݒ��o
	end

case {5,6,7}																% �d���w�̏�ԕϐ����ϓ����Ȃ��ꍇ
	index_o=[];																% �O�G�|�b�N�̃C���f�b�N�X�p
	index_n=[];																% ���G�|�b�N�̃C���f�b�N�X�p
	nn=nn-1;																% �d���w�̏�ԕϐ��͌Œ�Ȃ̂Ń��[�v�񐔂�-1����
	for k=1:nn
		if length(prn.float_o)>1
			index_o=[index_o nx.u+nx.T+nx.i+prn.float_o(2:end)+32*(k-1)];	% �C���f�b�N�X(prn.float_o���p)
		end
		index_n=[index_n nx.u+nx.T+nx.i+prn.u(2:end)+32*(k-1)];				% �C���f�b�N�X(prn.u���p)
	end
	x=zeros(nx.u+nx.T+nx.i+32*nn,1);										% ��Ԃ̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
	% P=eye(nx.u+nx.T+nx.i+32*nn)*10;										% ���U�̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
	P=eye(nx.u+nx.T+nx.i);
	for i=1:nn
		P=blkdiag(P,eye(32)*10);											% ���U�̏���(prn���ԍ��Ƃ��ė��p���邽�ߑS�q�������m��)
	end
	x(index_n)=[X2;X3];														% �����l�o�C�A�X�̕�����u��
	x([1:nx.u+nx.T+nx.i,index_o])=x_p;										% �\���l�Œu��
	x=x([1:nx.u+nx.T+nx.i,index_n]);										% ���q���̂ݒ��o
	P([1:nx.u+nx.T+nx.i,index_o],[1:nx.u+nx.T+nx.i,index_o])=P_p;			% �\�����U�Œu��
	P=P([1:nx.u+nx.T+nx.i,index_n],[1:nx.u+nx.T+nx.i,index_n]);				% ���q���̂ݒ��o
end

%--- ��ԕϐ��Ƌ����U(Fix�Œu��)
% 
% �Œ�ł��鐮���l�o�C�A�X����U, �\���l��
% �㏑�������̂�, �Œ�ł��镔���ɂ��Ă�
% �ēx, �㏑������
%--------------------------------------------
if isfield(prn,'fix')
	if length(prn.fix)>1
		index_f=[];
		for k=prn.fix(2:end)
			j=find(prn.u(2:end)==k);										% �Œ�ł���q���̃C���f�b�N�X
			index_f=[index_f j];											% �C���f�b�N�X���i�[
		end

		switch est_prm.statemodel.ion	% yanase
		case 0, dimi=0;
		case 1, dimi=length(prn.u)-1;
		case 2, dimi=length(prn.u);
		case 3, dimi=length(prn.u);
		case 4, dimi=length(prn.u)+4;
		case 5, dimi=nx.i;
		case 6, dimi=nx.i;
		case 7, dimi=nx.i;
		end

		dimn=length(prn.u)-1;												% �����l�o�C�A�X�̐�
		x(nx.u+nx.T+dimi+index_f)=X2(index_f);								% �Œ�ł��镔�����㏑��(N1)
		if est_prm.freq==2
			x(nx.u+nx.T+dimi+dimn+index_f)=X3(index_f);						% �Œ�ł��镔�����㏑��(N2)
		end
		index_fix=[nx.u+nx.T+dimi+index_f];									% �Œ�ł��镔���̃C���f�b�N�X(N1)
		if est_prm.freq==2
			index_fix=[index_fix,nx.u+nx.T+dimi+dimn+index_f];				% �Œ�ł��镔���̃C���f�b�N�X(N2)
		end
		P(index_fix,:)=0; P(:,index_fix)=0;									% �Œ�ł��镔����0�ɂ���(�ŏI�I�ɏ��O����镔��)
	end
end

%--- ��ԕϐ��Ƌ����U(���Z�b�g)
%--------------------------------------------
if init_flag==1
	switch est_prm.statemodel.ion	% yanase
	case 0, dimi=0;
	case 1, dimi=length(prn.u)-1;
	case 2, dimi=length(prn.u);
	case 3, dimi=length(prn.u);
	case 4, dimi=length(prn.u)+4;
	case 5, dimi=nx.i;
	case 6, dimi=nx.i;
	case 7, dimi=nx.i;
	end

% 	x=[x_p(1:nx.u+nx.T+dimi); X2; X3];										% ��ԕϐ�(���Z�b�g)
	x=[x(1:nx.u+nx.T+dimi); X2; X3];										% �������ς����̂������Z�b�g
% 	P=blkdiag(P_p(1:nx.u+nx.T+dimi,1:nx.u+nx.T+dimi),...
% 		eye(length(X2)+length(X3))*est_prm.P0.std_dev_n.^2);				% �����U�s��(���Z�b�g)
	P=blkdiag(P(1:nx.u+nx.T+dimi,1:nx.u+nx.T+dimi),...
		eye(length(X2)+length(X3))*est_prm.P0.std_dev_n.^2);				% �������ς����̂������Z�b�g
	end
end
