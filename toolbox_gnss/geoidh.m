function h=geoidh(pos)
%-------------------------------------------------------------------------------
% Function : �W�I�C�h�������߂�(�W�I�C�h���f��: egm96)
% 
% [argin]
% pos : lat[deg], lon[deg], Ell.height[m]
% 
% [argin]
% h : geoid height[m]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 20, 2008
%-------------------------------------------------------------------------------

persistent gprm map

if isempty(map), load('geoid_egm96.mat');, end		% �W�I�C�h���f��(egm96)�Ǎ�
lats=gprm.lat1:gprm.dlat:gprm.lat2;					% Lat. 
lons=gprm.lon1:gprm.dlon:gprm.lon2;					% Lon. 
h=interp2(lons,lats,map,pos(2),pos(1));				% �W�I�C�h��
