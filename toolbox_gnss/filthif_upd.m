function [x_f, P_f, gam] = filtekf_upd(Z, H, R, x, P, alpha)
%-------------------------------------------------------------------------------
% H_infinity filter update calculation
% Y. Kubo (Ritsumeikan Univ., Dept of EEE, Sugimoto Lab.)
% Last modified on November 18, 1999
%
%
% Function : �g���J���}���t�B���^���Z(�ϑ��X�V)
%
% [argin]
% Z    : mx1 �C�m�x�[�V�����x�N�g��: y-h(x^)
% H    : mxn �ϑ��s��: ���`�������ۂ̕Δ����W��
% R    : mxm �ϑ��G�������U�s��
% x    : nx1 ��i�\���l
% P    : nxn ��i�\���l�̐���덷�����U�s��
% alpha: 
%
% [argout]
% x_f  : nx1 �h�g����l
% P_f  : nxn �h�g����l�̐���덷�����U�s��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

% �J���}���Q�C���̌v�Z
%--------------------------------------------
K = P*H'*inv(H*P*H'+R);

% �h�g����l�̌v�Z
%--------------------------------------------
x_f = x + K*Z;

% ����덷�����U�s��̌v�Z
%--------------------------------------------
P_f = inv(inv(P)+H'*inv(R)*H);

% ���̎����I��(�\���p)
%--------------------------------------------
val_eig = eig(inv(P_f)+H'*inv(R)*H);				% ���̎����I��
gam = alpha*1/sqrt(min(val_eig));					% H���̃����A�_�v�e�B�u
