function output_zenrin(file,data)
%-------------------------------------------------------------------------------
% Function : ゼンリンフォーマット出力
% 
% [argin]
% file : ファイル名
% data : n×9 エポック時刻 (Y,M,D,H,M,S, lat,lon,Ell.H)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

% ファイルオープン
%--------------------------------------------
fp=fopen(file,'w');

% NaNを除外
%--------------------------------------------
i=find(~isnan(data(:,7)));
data=data(i,:);

% POSITION
%--------------------------------------------
pos=data(:,7:9);

fprintf(fp,'経度, 緯度\n');
for n=1:size(pos,1)
	fprintf(fp,'%15.9f, %15.9f\n',pos(n,2),pos(n,1));
end
fclose('all');
