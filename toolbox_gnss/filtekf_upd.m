function [x_f, P_f, V] = filtekf_upd(Z, H, R, x, P)
%-------------------------------------------------------------------------------
% extended Kalman filter update calculation
% Y. Kubo (Ritsumeikan Univ., Dept of EEE, Sugimoto Lab.)
% Last modified on November 18, 1999
%
%
% Function : �g���J���}���t�B���^���Z(�ϑ��X�V)
%
% [argin]
% Z   : mx1 �C�m�x�[�V�����x�N�g��: y-h(x^)
% H   : mxn �ϑ��s��: ���`�������ۂ̕Δ����W��
% R   : mxm �ϑ��G�������U�s��
% x   : nx1 ��i�\���l
% P   : nxn ��i�\���l�̐���덷�����U�s��
%
% [argout]
% x_f : nx1 �h�g����l
% P_f : nxn �h�g����l�̐���덷�����U�s��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 21, 2007
%-------------------------------------------------------------------------------

% �J���}���Q�C���̌v�Z
%--------------------------------------------
   
K = P*H'*inv(H*P*H'+R);
%size(K)

% �h�g����l�̌v�Z
%--------------------------------------------
x_f = x + K*Z;

%
%--------------------------------------------
P_f = P - K*H*P;

I=eye(length(Z));
V=(I-H*K)*Z;
Pv=H*P_f*H'+R;
