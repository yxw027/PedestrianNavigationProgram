function plot_map(s)
%
% �C�ݐ��n�}�̃v���b�g(�C�ݐ��f�[�^��gshhs_l.b�𗘗p)
%
% [argin]
% s : �J���[�ݒ�
% 
% [argout]
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Nov. 27, 2007

persistent src
if isempty(src), load('gshhs_l_map'); end
for a=src
	lon=a.Lon; lon(abs(diff(lon))>180)=NaN;
	plot(lon,a.Lat,s);
end
