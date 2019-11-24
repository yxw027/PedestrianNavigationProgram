function [x_p, P_p] = filtekf_pre(x_f,P_f, F, Q, CI)
%-------------------------------------------------------------------------------
% extended Kalman filter update calculation
% Y. Kubo (Ritsumeikan Univ., Dept of EEE, Sugimoto Lab.)
% Last modified on November 18, 1999
%
%
% Function : �g���J���}���t�B���^���Z(���ԍX�V)
%
% [argin]
% x_f : nx1 �h�g����l
% P_f : nxn �h�g����l�̐���덷�����U�s��
% F   : nxn ��Ԑ��ڍs��
% Q   : nxn �V�X�e���G�������U�s��
% CI  : nx1 �������
%
% [argout]
% x_p : nx1 ��i�\���l
% P_p : nxn ��i�\���l�̐���덷�����U�s��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

% ��i�\���l�̌v�Z
%--------------------------------------------
x_p = F*x_f + CI;

% ����덷�����U�s��̍X�V
%--------------------------------------------
P_p = F*P_f*F' + Q;
