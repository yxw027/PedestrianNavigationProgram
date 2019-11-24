function [x_p, P_p] = filtekf_pre(x_f,P_f, F, Q, gam)
%-------------------------------------------------------------------------------
% H_infinity filter update calculation
% Y. Kubo (Ritsumeikan Univ., Dept of EEE, Sugimoto Lab.)
% Last modified on November 18, 1999
%
%
% Function : �g���J���}���t�B���^���Z(���ԍX�V)
%
% [argin]
% x_f   : nx1 �h�g����l
% P_f   : nxn �h�g����l�̐���덷�����U�s��
% F     : nxn ��Ԑ��ڍs��
% Q     : nxn �V�X�e���G�������U�s��
% gamma : 1x1 �t�B���^�݌v�p�����[�^ >0
%
% [argout]
% x_p   : nx1 ��i�\���l
% P_p   : nxn ��i�\���l�̐���덷�����U�s��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

% ��i�\���l�̎���
%--------------------------------------------
size_of_state = size(x_f,1);

% ��i�\���l�̌v�Z
%--------------------------------------------
x_p = F*x_f;

% ����덷�����U�s��̍X�V
%--------------------------------------------
P_p = F*P_f*F' + Q + F*P_f*(gam^2*eye(size_of_state)-P_f)^(-1)*P_f*F';
