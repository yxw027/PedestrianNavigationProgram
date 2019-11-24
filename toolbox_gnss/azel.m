function [ele, azi, ee]=azel(x, sat_xyz)
%-------------------------------------------------------------------------------
% Function : ‹ÂŠp, •ûˆÊŠp, •Î”÷•ªŒW”‚ÌŒvZ
%
% [argin]
% x       : óM‹@À•W
% sat_xyz : ‰q¯À•W
% 
% [argout]
% ele     : ‹ÂŠp
% azi     : •ûˆÊŠp
% ee      : Œù”z(•Î”÷•ª)
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
sat_enu = xyz2enu(sat_xyz', x(1:3));			% Še‰q¯À•W‚ğ ENU ‚É•ÏŠ·
azi = atan2(sat_enu(1),sat_enu(2));				% azimuth
ele = asin(sat_enu(3)/norm(sat_enu));			% elevation
