function index=sat_order(prn,prn_o,ele,ii,xx)
%-------------------------------------------------------------------------------
% Function : �q��PRN�̏��Ԃ�����(��q����1�Ԗڂɔz�u)
% 
% [argin]
% prn   : ���G�|�b�N�̉q��PRN
% prn_o : �O�G�|�b�N�̉q��PRN
% ele   : �p
% ii    : �g�p�\�ȉq���̃C���f�b�N�X
% xx    : �p��臒l(��q���Ƃ��ė��p����Ƃ�)
% 
% [argout]
% index : �C���f�b�N�X(��q����1�Ԗڂɔz�u)
%         ii�̏��Ԃ�index�œ������ė��p
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 22, 2008
%-------------------------------------------------------------------------------

%--- �p���̃C���f�b�N�X(������)
%--------------------------------------------
[a,index]=sort(ele(ii)*180/pi,'descend');			% a:�p, index:�C���f�b�N�X(Matlab7�ȍ~)

% ��q���I��(prn��1�ԖڂɊ�q����z�u)
%--------------------------------------------
% 1. �O�G�|�b�N�̊�q���ō��G�|�b�N�̋p��
%    XX�x�ȏ�̏ꍇ
%    �� �O�G�|�b�N�̊�q�����ێ�����
% 
% 2. �O�G�|�b�N�̊�q���ō��G�|�b�N�̋p��
%    XX�x�����̏ꍇ�܂��͑O�G�|�b�N�̊�q��
%    �����G�|�b�N�ɑ��݂��Ȃ��ꍇ
%    �� �ō��p�̉q������Ƃ���
% 
% ���̏����ɂ���q����ݒ肷��
%--------------------------------------------
if ~isempty(prn_o)
	prn_u=prn(ii(index)); ele11=ele(ii(index));		% �p���Ƀ\�[�g���Ď��o��
	irefo=find(prn_u==prn_o(1));
	if ~isempty(irefo)
		if ele11(irefo)*180/pi>xx					% �O�G�|�b�N�̊�q���̋p��XX�x�ȏ�Ȃ�ێ�
			bk=index;								% ����(����ւ��O)
			index(1)=bk(irefo); index(irefo)=bk(1);	% ����(�C���f�b�N�X�œ���ւ�)
		end
	end
end
