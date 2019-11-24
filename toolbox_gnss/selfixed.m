function [prn,Ndd1,Ndd2,N_ref,Fixed_N]=selfixed(prn,Ndd1,Ndd2,Fixed_N,est_prm)
%-------------------------------------------------------------------------------
% Function : �Œ�\�E�s�\�ȉq��PRN������
% 
% [argin]
% prn       : �q��PRN�\����(prn.u, prn.o)
% Ndd1      : �����l�o�C�A�X(�X�V�O)
% Ndd2      : �����l�o�C�A�X(�X�V�O)
% Fixed_N   : �����l�o�C�A�X�ƃJ�E���g�̔z��
% est_prm   : �p�����[�^�ݒ�l
% 
% [argout]
% prn       : �q��PRN�\����(prn.u, prn.o, prn.float, prn.fix)
% Ndd1      : �����l�o�C�A�X(�X�V�ς�)
% Ndd2      : �����l�o�C�A�X(�X�V�ς�)
% Fixed_N   : �����l�o�C�A�X�ƃJ�E���g�̔z��
% N_ref     : ��؊��������p
% 
% ����؂�ւ�����ꍇ, �ϊ��������ׂ������Z�b�g���ׂ����͌�����
% ������, ����Ƃ��Ă̓��Z�b�g������������
% 
% �S�������Ƃ��ė��p������@��ǉ�
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

%--- Fix���Ƃ��ė��p�ł������(�ϊ��ς�)
%--------------------------------------------
if ~isempty(prn.o)
	%--- ��؊�������
	%--------------------------------------------
	iref=find(prn.o==prn.u(1));														% ��q���̃C���f�b�N�X(prn.o��)
	N_ref(1)=Fixed_N{1}(prn.u(1),1);												% ��؊��������̏���
	if est_prm.freq==2
		N_ref(2)=Fixed_N{2}(prn.u(1),1);											% ��؊��������̏���
	end
	if iref~=1																		% ��q�����ω������ꍇ(���̓��Z�b�g)
		if est_prm.freq==1
% 			if ~isnan(N_ref(1))
% 				Fixed_N{1}(:,1)=Fixed_N{1}(:,1)-N_ref(1);
% 				Fixed_N{1}(prn.o(1),1)=-N_ref(1);									% ��؊�������
% 				Fixed_N{1}(:,2)=0; Fixed_N{1}(prn.u(2:end),2)=est_prm.ambc;			% �J�E���g�X�V
% 			else
% 				Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;								% �����l�o�C�A�X�ƃJ�E���g�̃��Z�b�g
% 			end
			Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;									% �����l�o�C�A�X�ƃJ�E���g�̃��Z�b�g
		elseif est_prm.freq==2
% 			if ~isnan(N_ref(1)) & ~isnan(N_ref(2))
% 				Fixed_N{1}(:,1)=Fixed_N{1}(:,1)-N_ref(1);
% 				Fixed_N{1}(prn.o(1),1)=-N_ref(1);									% ��؊�������
% 				Fixed_N{1}(:,2)=0; Fixed_N{1}(prn.u(2:end),2)=est_prm.ambc;			% �J�E���g�X�V
% 				Fixed_N{2}(:,1)=Fixed_N{2}(:,1)-N_ref(2);
% 				Fixed_N{2}(prn.o(1),1)=-N_ref(2);									% ��؊�������
% 				Fixed_N{2}(:,2)=0; Fixed_N{2}(prn.u(2:end),2)=est_prm.ambc;			% �J�E���g�X�V
% 			else
% 				Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;								% �����l�o�C�A�X�ƃJ�E���g�̃��Z�b�g
% 				Fixed_N{2}(:,1)=NaN; Fixed_N{2}(:,2)=0;								% �����l�o�C�A�X�ƃJ�E���g�̃��Z�b�g
% 			end
			Fixed_N{1}(:,1)=NaN; Fixed_N{1}(:,2)=0;									% �����l�o�C�A�X�ƃJ�E���g�̃��Z�b�g
			Fixed_N{2}(:,1)=NaN; Fixed_N{2}(:,2)=0;									% �����l�o�C�A�X�ƃJ�E���g�̃��Z�b�g
		end
	end

	%--- �Œ�\�E�s�\�̉q��PRN
	%--------------------------------------------
	switch est_prm.ambf
	case {0,2}
		prn.fix=[]; prn.float=prn.u; N_ref(1:2)=NaN;								% �Œ���s��Ȃ��ꍇ
	case 1,
		prn.fix=prn.u(1); prn.float=prn.u(1); j=0;
		for i=prn.u(2:end)
			j=j+1;																	% �C���f�b�N�X���C���N�������g
			if est_prm.freq==1
				if Fixed_N{1}(i,2)>=est_prm.ambc									% �J�E���g���w��񐔈ȏォ�ǂ����̔���
					prn.fix=[prn.fix i];											% �Œ�\�ȉq��PRN(�萔�Ƃ��Ď戵������)
					Ndd1(j)=Fixed_N{1}(i,1);										% �Œ�\��FixN�Œu������
				else
					prn.float=[prn.float i];										% �Œ�s�\�ȉq��PRN(��ԕϐ��Ƃ��Ď戵������)
				end
			elseif est_prm.freq==2
				if Fixed_N{1}(i,2)>=est_prm.ambc & Fixed_N{2}(i,2)>=est_prm.ambc	% �J�E���g���w��񐔈ȏォ�ǂ����̔���
					prn.fix=[prn.fix i];											% �Œ�\�ȉq��PRN(�萔�Ƃ��Ď戵������)
					Ndd1(j)=Fixed_N{1}(i,1); Ndd2(j)=Fixed_N{2}(i,1);				% �Œ�\��FixN�Œu������
				else
					prn.float=[prn.float i];										% �Œ�s�\�ȉq��PRN(��ԕϐ��Ƃ��Ď戵������)
				end
			end
		end
	end
else
	prn.fix=[]; prn.float=prn.u; N_ref(1:2)=NaN;									% �Œ���s��Ȃ��ꍇ
end
