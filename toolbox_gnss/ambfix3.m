function [prn,Fix_X,Fix_N,Fixed_N,s,KalP_f_fix,ratio]=ambfix(prn,ele1,ele2,Kalx_p,Kalx_f,KalP_f,Fixed_N,ix,nx,est_prm,H,ratio_l,x_f_ar)
%-------------------------------------------------------------------------------
% Function : Ambiguity Resolution & Validation
% 
% [argin]
% prn       : �q��PRN�\����(prn.u, prn.float, prn.fix)
% ele1      : �p(Rover)
% ele2      : �p(Reference)
% Kalx_p    : ��i�\���l
% Kalx_f    : �h�g����l
% KalP_f    : ����덷�����U�s��
% Fixed_N   : �����l�o�C�A�X�ƃJ�E���g�̔z��
% ix        : ��ԕϐ��̃C���f�b�N�X
% nx        : ��ԕϐ��̎���
% est_prm   : �p�����[�^�ݒ�l
% H         : �ϑ��s��
% ratio_l   : �ޓx��
% 
% [argout]
% prn       : �q��PRN�\����(prn.u, prn.float, prn.fix, prn.ar)
% Fix_X     : �t�B�b�N�X��
% Fix_N     : �t�B�b�N�X��(�����l�o�C�A�X)
% Fixed_N   : �����l�o�C�A�X�ƃJ�E���g�̔z��
% s         : LAMBDA�̎c�����a
% KalP_f_fix: �덷�����U(Fix�ς�)
% ratio     : �ޓx��(���G�|�b�N)
% 
% AR�Ŏg�p����q����I�ʉ\(3���)---�֐�:ambscn �𗘗p
% 
% Fix����
% �E����OK��Fix
% �E����NG�{���������Œ聨Fix�Ȃ�
% �E����NG�{�����ȏ�Œ聨Float��Fix�Ƃ��Ĉ���
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% �ޓx�䌟��Ή�
% Jan. 29, 2010, T.Yanase
%-------------------------------------------------------------------------------

ratio=0;		% �ޓx�䏉����

%--- Ambiguity Resolution & Validation
%--------------------------------------------
if ~isnan(Kalx_f(1)) & length(prn.float)>1
	%--- AR�Ŏg�p����q����I��(3���)
	% 
	% 1. �p�}�X�N�𗘗p
	% 2. �g�p�q���ɂȂ��Ă���̃G�|�b�N���𗘗p
	% 3. �����U�𗘗p
	%--------------------------------------------
	[prn.ar,x_p_ar,x_f_ar,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,H_c,index_xx]=...
						ambscn(prn,ele1,Kalx_p,Kalx_f,KalP_f,H,ix,nx,est_prm);

	if length(prn.ar)>1
		%--- Ambiguity Resolution Method
		%--------------------------------------------
		switch est_prm.ambr													% ambiguity resolution
		case 0, Fix_N=round(Float_N_ar); s=[1;100];							% round
		case 1, [Fix_N,s]=lambda2(P_f_nn_ar, Float_N_ar, -1);				% LAMBDA
				Fix_N12=Fix_N;												% \check{n} LAMBDA
				Fix_N=Fix_N(:,1);											% \check{n} LAMBDA
		case 2, [Fix_N,s,Z]=mlambda(Float_N_ar,P_f_nn_ar,2);				% MLAMBDA
				Fix_N=Fix_N(:,1);											% \check{n} MLAMBDA
		end

		%--- Ambiguity Validation Method
		%--------------------------------------------
		switch est_prm.ambv													% ambiguity validation
		case 0, valid=1;													% no validation
		case 1, valid=s(2)/s(1)>=est_prm.ambt;								% ratio test
		case 2, 
			[valid,ratio,Fix_N]=likelihood(nx,ele1,ele2,prn,est_prm,x_p_ar,x_f_ar,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,Fix_N12,H_c,ratio_l);
																			% likelihood ratio test
		case 3, 
			valid=s(2)/s(1)>=est_prm.ambt;									% ratio test
			if valid == 0
				[valid,ratio,Fix_N]=likelihood(nx,ele1,ele2,prn,est_prm,x_p_ar,x_f_ar,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,Fix_N12,H_c,ratio_l);
																			% likelihood ratio test
			end
		end
		if valid
			index_f=[ix.u,ix.T,ix.i];
			Fix_X=Kalx_f(index_f);
			Fix_X(index_xx)=...
					x_f_ar-P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N);		% \check{x}
			KalP_f_fix=KalP_f(index_f,index_f);
			KalP_f_fix(index_xx,index_xx)=...
					P_f_xx_ar-P_f_xn_ar*inv(P_f_nn_ar)*P_f_xn_ar';			% \check{P}
		else
			Fix_N=[];
			Fix_X([ix.u,ix.T,ix.i],1) = NaN;
			KalP_f_fix([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i])=NaN;
		end
	else
		prn.ar=prn.float; Fix_N=[]; s=[NaN;NaN];
		Fix_X([ix.u,ix.T,ix.i],1) = NaN;
		KalP_f_fix([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i])=NaN;
	end
else
	prn.ar=prn.float; Fix_N=[]; s=[NaN;NaN];
	Fix_X([ix.u,ix.T,ix.i],1) = NaN;
	KalP_f_fix([ix.u,ix.T,ix.i],[ix.u,ix.T,ix.i])=NaN;
end

%--- Fix�����g�p�����q�����������ȏ�̏ꍇ(Fix�̔���)
% �E�����ʉ߂��Ă��Ȃ��Ă�, �����ȏ�Œ�ł����
%   Fix���Ƃ��Ĉ���
%--------------------------------------------
if est_prm.ambf==1
	if ~isnan(Kalx_f(1))
		if (length(prn.fix)-1)>=(length(prn.u)-1)/2							% �����ȏ�,�Œ�ł����ꍇ
			if isnan(Fix_X(1))
				Fix_X=Kalx_f;												% Float����Fix���Ƃ���
				KalP_f_fix=KalP_f;
			end
		end
	end
end

%--- Fix�����i�[(�J�E���g��)
%--------------------------------------------
Fixed_Nk{1}=Fixed_N{1};														% �S�G�|�b�N�̒l��ێ�
if est_prm.freq==2
	Fixed_Nk{2}=Fixed_N{2};													% �S�G�|�b�N�̒l��ێ�
end
Fixed_N{1}(1:32,1)=NaN; Fixed_N{1}(1:32,2)=0;
Fixed_N{1}(prn.u(2:end),1)=Fixed_Nk{1}(prn.u(2:end),1);						% �g�p�q����Fix��(�O�G�|�b�N�܂�)
if est_prm.freq==2
	Fixed_N{2}(1:32,1)=NaN; Fixed_N{2}(1:32,2)=0;
	Fixed_N{2}(prn.u(2:end),1)=Fixed_Nk{2}(prn.u(2:end),1);					% �g�p�q����Fix��(�O�G�|�b�N�܂�)
end
if ~isempty(Fix_N)
	Fixed_N{1}(prn.ar(2:end),1)=Fix_N(1:(length(prn.ar)-1),1);				% ���G�|�b�N�ł�Fix����ǉ�
	if est_prm.freq==2
		Fixed_N{2}(prn.ar(2:end),1)=...
				Fix_N(1+(length(prn.ar)-1):2*(length(prn.ar)-1),1);			% ���G�|�b�N�ł�Fix����ǉ�
	end
else
	Fixed_N{1}(prn.float(2:end),1)=NaN;										% ���G�|�b�N�ł�Fix�����Ȃ��ꍇ, NaN��ǉ�
	if est_prm.freq==2
		Fixed_N{2}(prn.float(2:end),1)=NaN;									% ���G�|�b�N�ł�Fix�����Ȃ��ꍇ, NaN��ǉ�
	end
end
for i=2:length(prn.u)														% �J�E���g�̍X�V
	if Fixed_N{1}(prn.u(i),1)==Fixed_Nk{1}(prn.u(i),1)
		Fixed_N{1}(prn.u(i),2)=Fixed_Nk{1}(prn.u(i),2)+1;					% �O�G�|�b�N�ƍ��G�|�b�N������
	else
		Fixed_N{1}(prn.u(i),2)=1;											% �O�G�|�b�N�ƍ��G�|�b�N���قȂ�
	end
	if est_prm.freq==2
		if Fixed_N{2}(prn.u(i),1)==Fixed_Nk{2}(prn.u(i),1)
			Fixed_N{2}(prn.u(i),2)=Fixed_Nk{2}(prn.u(i),2)+1;				% �O�G�|�b�N�ƍ��G�|�b�N������
		else
			Fixed_N{2}(prn.u(i),2)=1;										% �O�G�|�b�N�ƍ��G�|�b�N���قȂ�
		end
	end
end



%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

function [prn_ar,Xp,Xf,FloatN,Pf_xn,Pf_nn,Pf_xx,H_c,index_xx]=ambscn(prn,ele,x_p,x_f,P_f,H,ix,nx,est_prm)
%-------------------------------------------------------------------------------
% Function : AR�Ŏg�p����q����I��
% 
% [argin]
% prn       : �q��PRN�\����
% ele       : �p
% x_p       : ��i�\���l
% x_f       : �h�g����l
% P_f       : ����덷�����U�s��
% H         : �ϑ��s��
% ix        : ��ԕϐ��̃C���f�b�N�X
% nx        : ��ԕϐ��̎���
% est_prm   : �p�����[�^�ݒ�l
% 
% [argout]
% prn_ar    : AR�g�p����q��PRN
% Xp        : ��i�\���l(�I�ʌ�)
% Xf        : �h�g����l(�I�ʌ�)
% FloatN    : �t���[�g��(�����l�o�C�A�X, �I�ʌ�)
% Pf_xn     : ����덷�����U�s��(X*N����, �I�ʌ�)
% Pf_nn     : ����덷�����U�s��(N*N����, �I�ʌ�)
% Pf_xx     : ����덷�����U�s��(X*X����, �I�ʌ�)
% H_c         : �ϑ��s��(�I�ʌ�)
% index_xx  : �C���f�b�N�X(Float����Fix���ŏ㏑�����邽��)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% �d���w��d�����莞�ɑΉ�
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

%--- AR�Ŏg�p����q����I��(3���)
% 
% 1. �p�}�X�N�𗘗p
% 2. �g�p�q���ɂȂ��Ă���̃G�|�b�N���𗘗p
% 3. �����U�𗘗p
%--------------------------------------------
persistent count_satk count_sat


%--- X, P�𕪉�(PRN���E�s�ԍ��Ƃ��Ĉ���)
%--------------------------------------------
switch est_prm.statemodel.ion	% yanase
case 0, dimi=0;
case 1, dimi=32;
case 2, dimi=32;
case 3, dimi=32;
case 4, dimi=36;
case 5, dimi=nx.i;
case 6, dimi=nx.i;
case 7, dimi=nx.i;
end

Xp(1:nx.u+nx.T+dimi,1)=0;											% Xp(N�ȊO)���i�[���鏀��
Xf(1:nx.u+nx.T+dimi,1)=0;											% Xf(N�ȊO)���i�[���鏀��
FloatN(1:32*est_prm.freq,1)=0;										% FloatN���i�[���鏀��
Pf_xn(1:nx.u+nx.T+dimi,1:32*est_prm.freq)=0;						% P_xn���i�[���鏀��
Pf_nn(1:32*est_prm.freq,1:32*est_prm.freq)=0;						% P_nn���i�[���鏀��
Pf_xx(1:nx.u+nx.T+dimi,1:nx.u+nx.T+dimi)=0;							% P_xx���i�[���鏀��
H_c(1:length(H(:,1)), 1:nx.u+nx.T+dimi)=0;							% H_c���i�[���鏀��

index_x=[ix.u,ix.T];												% �C���f�b�N�X(pos,trop) PRN���ԍ��Ƃ��ė��p

switch est_prm.statemodel.ion	% yanase
case 1, index_x=[index_x,nx.u+nx.T+prn.u(2:end)];					% �C���f�b�N�X(pos,trop,ion) PRN(��q���ȊO)���ԍ��Ƃ��ė��p
case 2, index_x=[index_x,nx.u+nx.T+prn.u];							% �C���f�b�N�X(pos,trop,ion) PRN���ԍ��Ƃ��ė��p
case 3, index_x=[index_x,nx.u+nx.T+prn.u];							% �C���f�b�N�X(pos,trop,ion) PRN���ԍ��Ƃ��ė��p
case 4, index_x=[index_x,nx.u+nx.T+1:nx.u+nx.T+4,nx.u+nx.T+4+prn.u];										% �C���f�b�N�X(pos,trop,ion)
case 5, index_x=[index_x,ix.i];										% �C���f�b�N�X(pos,trop,ion)
case 6, index_x=[index_x,ix.i];										% �C���f�b�N�X(pos,trop,ion)
case 7, index_x=[index_x,ix.i];										% �C���f�b�N�X(pos,trop,ion)
end

if est_prm.freq==1
	index_n=[prn.float(2:end)];										% �C���f�b�N�X(N1) PRN���ԍ��Ƃ��ė��p
else
	index_n=[prn.float(2:end),32+prn.float(2:end)];					% �C���f�b�N�X(N1,N2) PRN���ԍ��Ƃ��ė��p
end

switch est_prm.statemodel.ion	% yanase
case 0, indk=nx.u+nx.T;												% �����l�o�C�A�X�ȊO�̕���
case 1, indk=nx.u+nx.T+length(prn.u)-1;								% �����l�o�C�A�X�ȊO�̕���
case 2, indk=nx.u+nx.T+length(prn.u);								% �����l�o�C�A�X�ȊO�̕���
case 3, indk=nx.u+nx.T+length(prn.u);								% �����l�o�C�A�X�ȊO�̕���
case 4, indk=nx.u+nx.T+4+length(prn.u);								% �����l�o�C�A�X�ȊO�̕���
case 5, indk=nx.u+nx.T+nx.i;										% �����l�o�C�A�X�ȊO�̕���
case 6, indk=nx.u+nx.T+nx.i;										% �����l�o�C�A�X�ȊO�̕���
case 7, indk=nx.u+nx.T+nx.i;										% �����l�o�C�A�X�ȊO�̕���
end

Xp(index_x)=x_p(1:indk);											% Xp(N�ȊO)
Xf(index_x)=x_f(1:indk);											% Xf(N�ȊO)
FloatN(index_n)=x_f(indk+1:end);									% FloatN
Pf_xn(index_x,index_n)=P_f(1:indk, indk+1:end);						% P_xn
Pf_nn(index_n,index_n)=P_f(indk+1:end, indk+1:end);					% P_nn
Pf_xx(index_x,index_x)=P_f(1:indk, 1:indk);							% P_xx
H_c(:,index_x)=H(:, 1:indk);										% H_c


switch est_prm.ambs
case 0
	prn_ar=prn.float;
case 1
	%--- AR�Ɏg�p���Ȃ��q�������O(�p<25[deg])
	%--------------------------------------------
	ele_ar=ele*180/pi;												% �q���̋p
	prn_ele=prn.c(find(ele_ar>est_prm.ambse)); prn_ar=[];			% �p�}�X�N�ȏ�̉q��PRN
	if ~isempty(prn_ele)
		for i=1:length(prn.float)
			k=find(prn_ele==prn.float(i));							% prn_ele���ł�prn.float�̃C���f�b�N�X
			if ~isempty(k)
				prn_ar=[prn_ar prn_ele(k)];							% AR�Ŏg�p����q��PRN���i�[
			end
		end
	else
		prn_ar=prn.float;
	end

case 2
	%--- �g�p�q���ɂȂ��Ĉ��̃G�|�b�N�͎g�p���Ȃ�
	%--------------------------------------------
	if isempty(count_satk)
		count_satk(1:32)=0;											% ������
	else
		count_satk=count_sat;										% �S�G�|�b�N�܂ł̒l��ێ�
	end
	count_sat(1:32)=0;												% ������
	count_sat(prn.u(2:end))=count_satk(prn.u(2:end))+1;				% �g�p�q���ɂȂ��Ă���̃G�|�b�N��

	prn_arn=[];
	for i=prn.float(2:end)
		if count_sat(i)>=est_prm.ambsc								% �G�|�b�N���� 20 �ȏ�̏ꍇ
			prn_arn=[prn_arn i];									% AR�Ŏg�p����q��PRN���i�[(��q���ȊO)
		end
	end
	prn_ar=[prn.u(1) prn_arn];										% AR�Ŏg�p����q��PRN���i�[
	if isempty(prn_arn)
		prn_ar=prn.float;
	end

case 3
	%--- �����U�̑傫���q���͎g�p���Ȃ�
	%--------------------------------------------
	Pf_nn1=diag(Pf_nn(1:32,1:32));									% �����U�s��̑Ίp����(N1)
	if est_prm.freq==2
		Pf_nn2=diag(Pf_nn(1+32:end,1+32:end));						% �����U�s��̑Ίp����(N2)
	end
	prn_arn=[];
	for i=prn.float(2:end)
		if est_prm.freq==1
			if Pf_nn1(i)<est_prm.ambsp								% �����U�� 0.1 �����̏ꍇ
				prn_arn=[prn_arn i];								% AR�Ŏg�p����q��PRN���i�[(��q���ȊO)
			end
		else
			if Pf_nn1(i)<est_prm.ambsp & Pf_nn2(i)<est_prm.ambsp	% �����U�� 0.1 �����̏ꍇ
				prn_arn=[prn_arn i];								% AR�Ŏg�p����q��PRN���i�[(��q���ȊO)
			end
		end
	end
	prn_ar=[prn.u(1) prn_arn];										% AR�Ŏg�p����q��PRN���i�[
	if isempty(prn_arn)
		prn_ar=prn.float;
	end
end


%--- ��������X, P����g�p����PRN�Œ��o
%--------------------------------------------
index_x=[ix.u,ix.T];												% �C���f�b�N�X(pos,trop) PRN���ԍ��Ƃ��ė��p

switch est_prm.statemodel.ion	% yanase
case 1, index_x=[index_x,nx.u+nx.T+prn_ar(2:end)];					% �C���f�b�N�X(pos,trop,ion) PRN���ԍ��Ƃ��ė��p
case 2, index_x=[index_x,nx.u+nx.T+prn_ar];							% �C���f�b�N�X(pos,trop,ion) PRN���ԍ��Ƃ��ė��p
case 3, index_x=[index_x,nx.u+nx.T+prn_ar];							% �C���f�b�N�X(pos,trop,ion) PRN���ԍ��Ƃ��ė��p
case 4, index_x=[index_x,nx.u+nx.T+1:nx.u+nx.T+4,nx.u+nx.T+4+prn_ar];	% �C���f�b�N�X(pos,trop,ion) PRN���ԍ��Ƃ��ė��p
case 5, index_x=[index_x,ix.i];										% �C���f�b�N�X(pos,trop,ion) 
case 6, index_x=[index_x,ix.i];										% �C���f�b�N�X(pos,trop,ion) 
case 7, index_x=[index_x,ix.i];										% �C���f�b�N�X(pos,trop,ion) 
end

if est_prm.freq==1
	index_n=[prn_ar(2:end)];										% �C���f�b�N�X(N1) PRN���ԍ��Ƃ��ė��p
else
	index_n=[prn_ar(2:end),32+prn_ar(2:end)];						% �C���f�b�N�X(N1,N2) PRN���ԍ��Ƃ��ė��p
end
Xp=Xp(index_x);														% Xp(N�ȊO)(�I�ʌ�)
Xf=Xf(index_x);														% Xf(N�ȊO)(�I�ʌ�)
FloatN=FloatN(index_n);												% FloatN(�I�ʌ�)
Pf_xn=Pf_xn(index_x,index_n);										% P_xn(�I�ʌ�)
Pf_nn=Pf_nn(index_n,index_n);										% P_nn(�I�ʌ�)
Pf_xx=Pf_xx(index_x,index_x);										% P_xx(�I�ʌ�)
H_c=H_c(:, index_x);												% H_c(�I�ʌ�)

index_xxx=[];
for i=1:length(prn_ar)
	index_xxx=[index_xxx find(prn.u==prn_ar(i))];					% prn.u���ł�prn_ar�̃C���f�b�N�X
end

index_xx=[ix.u,ix.T];												% �C���f�b�N�X(pos,trop, Float����Fix���ŏ㏑�����邽��)

switch est_prm.statemodel.ion	% yanase
case 1, index_xx=[index_xx,nx.u+nx.T+index_xxx(2:end)];				% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
case 2, index_xx=[index_xx,nx.u+nx.T+index_xxx];					% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
case 3, index_xx=[index_xx,nx.u+nx.T+index_xxx];					% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
case 4, index_xx=[index_xx,nx.u+nx.T+1:nx.u+nx.T+4,nx.u+nx.T+4+index_xxx];					% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
case 5, index_xx=[index_xx,ix.i];									% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
case 6, index_xx=[index_xx,ix.i];									% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
case 7, index_xx=[index_xx,ix.i];									% �C���f�b�N�X(pos,trop,ion, Float����Fix���ŏ㏑�����邽��)
end



