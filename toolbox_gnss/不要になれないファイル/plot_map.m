function plot_map(s)
%
% 海岸線地図のプロット(海岸線データはgshhs_l.bを利用)
%
% [argin]
% s : カラー設定
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
