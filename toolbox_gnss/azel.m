function [ele, azi, ee]=azel(x, sat_xyz)
%-------------------------------------------------------------------------------
% Function : �p, ���ʊp, �Δ����W���̌v�Z
%
% [argin]
% x       : ��M�@���W
% sat_xyz : �q�����W
% 
% [argout]
% ele     : �p
% azi     : ���ʊp
% ee      : ���z(�Δ���)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 13, 2007
%-------------------------------------------------------------------------------

rrs  = x(1:3)' - sat_xyz; 
rho = norm(rrs);

% partial derivative
%--------------------------------------------
ee = rrs/rho;

% azimuth, elevation
%--------------------------------------------
sat_enu = xyz2enu(sat_xyz', x(1:3));			% �e�q�����W�� ENU �ɕϊ�
azi = atan2(sat_enu(1),sat_enu(2));				% azimuth
ele = asin(sat_enu(3)/norm(sat_enu));			% elevation
