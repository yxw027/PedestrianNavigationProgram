function xyz = enu2xyz(enu,orgxyz)
%-------------------------------------------------------------------------------
% Function : XYZ2ENU	ENU(East-North-Up) 座標系を WGS-84 直交座標系へ座標変換
%
% [argin]
% enu(1:3) : East[m], North[m], Up[m]
%
% [argout]
% xyz(1:3) : ECEF座標 X, Y, Z [m]
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

orgllh = xyz2llh(orgxyz(1:3));
lat = orgllh(1);
lon = orgllh(2);

LL = [          -sin(lon),            cos(lon),         0;
      - sin(lat)*cos(lon), - sin(lat)*sin(lon),  cos(lat);
        cos(lat)*cos(lon),   cos(lat)*sin(lon),  sin(lat)];

xyz = orgxyz(1:3)+LL'*enu(1:3);
