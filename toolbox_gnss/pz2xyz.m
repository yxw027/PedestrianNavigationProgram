function xyz = pz2xyz(pz)
%-------------------------------------------------------------------------------
% Function : XYZ2ENU	WGS-84 直交座標系を ENU(East-North-Up) 座標系へ座標変換
%
% [argin]
% pz(1:3) : PZ-90座標 X, Y, Z [m]
%
% [argout]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% T.Yanase: July. 13, 2009
%-------------------------------------------------------------------------------

% Kuranov
% [xyz] = [0 0 1m] + [1 -1.6*10^{-6} 0;-1.0*10^{-6} 1 0;0 0 1]*[pz];

% Rossbach
xyz = [1 -1.6e-6 0;1.6e-6 1 0;0 0 1]*pz';
xyz = xyz';

% Misra
% xyz = [0; 2.5; 0] + [1 -1.9*10^-6 0;1.9*10^-6 1 0;0 0 1]*pz';
% xyz = xyz';


