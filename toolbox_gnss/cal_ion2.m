function ion = cal_ion(time,ion_prm,azi,ele,pos,mode)
%-------------------------------------------------------------------------------
% Function : Ionosphere model(mode 1:Klobuchar, 2:GIM, 3:Rits)
% 
% [argin]
% ttime   : ����(year month day hour minute sec),time �̎������ (ToD, Week, ToW, JD)
% ion_prm : �d���w�p�����[�^(klob, gim, rits)
% azi     : ���ʊp
% ele     : �p
% pos     : XYZ(ECEF)[m]
% mode    : �d���w���f��
% 
% [argout]
% ion     : �d���w�x��
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
