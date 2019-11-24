function [valid,ratio,Fix_N]=likelihood(nx,ele1,ele2,prn,est_prm,Kalx_pp,Kalx_ff,Float_N_ar,P_f_xn_ar,P_f_nn_ar,P_f_xx_ar,Fix_N,H_c,ratio_l)
%-------------------------------------------------------------------------------
% Function : likelihood ratio test
% 
% [argin]
% nx        : ��ԕϐ��̎���
% ele1      : �p(Rover)
% ele2      : �p(Reference)
% prn       : �q��PRN�\����(prn.u, prn.float, prn.fix)
% est_prm   : �p�����[�^�ݒ�l
% Kalx_pp   : ��i�\���l(�I�ʌ�)
% Kalx_ff   : �h�g����l(�I�ʌ�)
% FloatN_ar : �t���[�g��(�����l�o�C�A�X, �I�ʌ�)
% Pf_xn_ar  : ����덷�����U�s��(X*N����, �I�ʌ�)
% Pf_nn_ar  : ����덷�����U�s��(N*N����, �I�ʌ�)
% Pf_xx_ar  : ����덷�����U�s��(X*X����, �I�ʌ�)
% Fix_N     : �t�B�b�N�X��(�����l�o�C�A�X)
% H_c       : �ϑ��s��(�I�ʌ�)
% 
% [argout]
% valid     : ���茋��(0 or 1)
% ratio     : �ޓx��
% Fix_N     : �t�B�b�N�X��(�����l�o�C�A�X)
% 
% ���͈��� ratio_l �Ŗޓx����X�V
% 
% �v����
% �E���U, 臒l�̌��ߕ�
% �E���Ԃɂ��q���̑����ւ̑Ή�
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% T.Yanase: Jan. 25, 2010
%-------------------------------------------------------------------------------


C_ar=[]; U_ar=[];
for t=1:length(prn.ar)
	A=prn.ar(1,t);
	C=findstr(prn.c,A);		% AR�g�p����q��PRN�Ɉ�v���鋤�ʉq��PRN
	U=findstr(prn.u,A);		% AR�g�p����q��PRN�Ɉ�v����g�p�q��PRN
	C_ar=[C_ar, C];
	U_ar=[U_ar, U];
end
U_ar=U_ar-1;				% ��q��������AR�g�p����q��PRN

H1=H_c(U_ar(2:end),:);
H1=[H1; H_c((length(prn.float)-1)+U_ar(2:end),:)];
if est_prm.freq==2
	H1=[H1; H_c(2*(length(prn.float)-1)+U_ar(2:end),:)];
	H1=[H1; H_c(3*(length(prn.float)-1)+U_ar(2:end),:)];
end

PR1a=(est_prm.obsnoise.PR1./sin(ele1(C_ar,1)).^2);							% �R�[�h�̕��U(�d�ݍl��)
PR2a=(est_prm.obsnoise.PR2./sin(ele1(C_ar,1)).^2);							% �R�[�h�̕��U(�d�ݍl��)
PR1b=(est_prm.obsnoise.PR1./sin(ele2(C_ar,1)).^2);							% �R�[�h�̕��U(�d�ݍl��)
PR2b=(est_prm.obsnoise.PR2./sin(ele2(C_ar,1)).^2);							% �R�[�h�̕��U(�d�ݍl��)
Ph1a=(est_prm.obsnoise.Ph1./sin(ele1(C_ar,1)).^2);							% �����g�̕��U(�d�ݍl��)
Ph2a=(est_prm.obsnoise.Ph2./sin(ele1(C_ar,1)).^2);							% �����g�̕��U(�d�ݍl��)
Ph1b=(est_prm.obsnoise.Ph1./sin(ele2(C_ar,1)).^2);							% �����g�̕��U(�d�ݍl��)
Ph2b=(est_prm.obsnoise.Ph2./sin(ele2(C_ar,1)).^2);							% �����g�̕��U(�d�ݍl��)

PR1 = diag(PR1a+PR1b); PR2 = diag(PR2a+PR2b);									% �R�[�h�̕��U(1�d��)
Ph1 = diag(Ph1a+Ph1b); Ph2 = diag(Ph2a+Ph2b);									% �����g�̕��U(1�d��)

TD=[-ones((length(prn.ar)-1),1) eye((length(prn.ar)-1))];						% �ϊ��s��

if est_prm.freq==1
	R=TD*Ph1*TD';																% DD obs noise(L1)
	if est_prm.pr_flag==1
		R=blkdiag(R,TD*PR1*TD');												% DD obs noise(L1,CA)
	end
else
	R=blkdiag(TD*Ph1*TD',TD*Ph2*TD');											% DD obs noise(L1,L2)
	if est_prm.pr_flag==1
		R=blkdiag(R,TD*PR1*TD',TD*PR2*TD');										% DD obs noise(L1,L2,CA,PY)
	end
end

Fix_N1=Fix_N(:,1);																%first
mu_f=H1*(Kalx_ff-Kalx_pp+P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N1));			%first�̎c��
% heikin_f=H1*P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N1);						%first�̎c���̕���
heikin_f=0;																		%first�̎c���̕���
bunsan_f=H1*P_f_xx_ar*H1'+R;													%first�̎c���̕��U

Fix_N2=Fix_N(:,2);																%second   
mu_s=H1*(Kalx_ff-Kalx_pp+P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N2));			%second�̎c��
% heikin_s=H1*P_f_xn_ar*inv(P_f_nn_ar)*(Float_N_ar-Fix_N2);						%second�̎c���̕���
heikin_s=0;																		%second�̎c���̕���
bunsan_s=H1*P_f_xx_ar*H1'+R;													%second�̎c���̕��U

yuudohi=exp((-1/2)*(mu_s-heikin_s)'*inv(bunsan_s)*(mu_s-heikin_s)+(1/2)*(mu_f-heikin_f)'*inv(bunsan_f)*(mu_f-heikin_f));
yuudohi=log(yuudohi);

ratio=[ratio_l+yuudohi];					% �ΐ��ޓx

alpha=0.01;			% ����̉ߌ�
beta=0.01;			% ����̉ߌ�
eta_0=log(beta/(1-alpha));
eta_1=log((1-beta)/alpha);

if ~isnan(ratio)
	if ratio <= eta_0
		valid=1;
		Fix_N=Fix_N(:,1);
	elseif ratio >= eta_1
		valid=1;
		Fix_N=Fix_N(:,2);
	else
		valid=0;
	end
end

