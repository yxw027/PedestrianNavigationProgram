function h=geoidh(pos)
%-------------------------------------------------------------------------------
% Function : ジオイド高を求める(ジオイドモデル: egm96)
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

if isempty(map), load('geoid_egm96.mat');, end		% ジオイドモデル(egm96)読込
lats=gprm.lat1:gprm.dlat:gprm.lat2;					% Lat. 
lons=gprm.lon1:gprm.dlon:gprm.lon2;					% Lon. 
h=interp2(lons,lats,map,pos(2),pos(1));				% ジオイド高
