function ion = cal_ion(time,ion_prm,azi,ele,pos,mode)
%-------------------------------------------------------------------------------
% Function : Ionosphere model(mode 1:Klobuchar, 2:GIM, 3:Rits)
% 
% [argin]
% ttime   : 時刻(year month day hour minute sec),time の時刻情報 (ToD, Week, ToW, JD)
% ion_prm : 電離層パラメータ(klob, gim, rits)
% azi     : 方位角
% ele     : 仰角
% pos     : XYZ(ECEF)[m]
% mode    : 電離層モデル
% 
% [argout]
% ion     : 電離層遅延
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 02, 2008
%-------------------------------------------------------------------------------

if mode == 0
	ion = 0;
elseif mode == 1
	ion = ion_klob(ion_prm.klob,time.tod,pos,azi,ele);		% Klobuchar model
elseif mode == 2
	ion = ion_gim(ion_prm.gim,time.mjd,pos,azi,ele);		% GIM
elseif mode == 3
	ion=ion_rits(ion_prm.rits,time,pos,azi,ele);			% Rits model
end
