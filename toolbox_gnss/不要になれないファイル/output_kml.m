function output_kml(file,data,track_color,point_color)
%-------------------------------------------------------------------------------
% Function : KMLフォーマット出力
% 
% 
% [argin]
% file        : ファイル名
% data        : n×9 エポック時刻 (Y,M,D,H,M,S, lat,lon,Ell.H)
% track_color : トラックカラー(文字列: 'Y','M','C','R','G','B','W','K') default:Y
% point_color : ポイントカラー(文字列: 'Y','M','C','R','G','B','W','K') default:R
% 
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: July 3, 2008
%-------------------------------------------------------------------------------

% B G R
%--------------------------------------------
RGB_color={'00FFFF',	% Yellow
           'FF00FF',	% Magenta
           'FFFF00',	% Cyan
           '0000FF',	% Red
           '00FF00',	% Green
           'FF0000',	% Blue
           'FFFFFF',	% White
           '000000'};	% Black

RGB={'Y','M','C','R','G','B','W','K'};

% カラー設定
%--------------------------------------------
if nargin < 4
	track_color=RGB_color{1};
	point_color=RGB_color{4};
else
	i=strmatch(track_color,RGB);
	j=strmatch(point_color,RGB);
	if ~isempty(i) & ~isempty(j)
		track_color=RGB_color{i};
		point_color=RGB_color{j};
	else
		track_color=RGB_color{1};
		point_color=RGB_color{4};
	end
end

% NaNを除外
%--------------------------------------------
i=find(~isnan(data.pos(:,1)));

% TIME
%--------------------------------------------
time=data.time(i,5:10);

% POSITION
%--------------------------------------------
pos=data.pos(i,4:6);
h=geoidh(pos(1,1:2));

% ファイルオープン
%--------------------------------------------
fp=fopen(file,'w');

% XMLヘッダ(変更不可)
%--------------------------------------------
fprintf(fp,'<?xml version="1.0" encoding="UTF-8"?>\n');

% KML version2.0のネームスペース宣言(変更不可)
%--------------------------------------------
fprintf(fp,'<kml xmlns="http://earth.google.com/kml/2.0">\n');


% 本文開始
%--------------------------------------------
fprintf(fp,'<Document>\n');

% トラック
%--------------------------------------------
fprintf(fp,'<Placemark>\n');
fprintf(fp,'  <name>Rover Track</name>\n');
fprintf(fp,'  <Style>\n');
fprintf(fp,'    <LineStyle>\n');
fprintf(fp,'      <color>aa%s</color>\n',track_color);
fprintf(fp,'    </LineStyle>\n');
fprintf(fp,'  </Style>\n');
fprintf(fp,'  <LineString>\n');
fprintf(fp,'    <coordinates>\n');
for n=1:size(pos,1)
	fprintf(fp,'       %15.9f,%15.9f,%15.9f\n',pos(n,2),pos(n,1),pos(n,3)-h);
end
fprintf(fp,'    </coordinates>\n');
fprintf(fp,'  </LineString>\n');
fprintf(fp,'</Placemark>\n');

% ポイント(フォルダに格納)
%--------------------------------------------
fprintf(fp,'<Folder>\n');
for n=1:size(pos,1)
	fprintf(fp,'  <name>Rover Position</name>\n');
	fprintf(fp,'<Placemark>\n');
	fprintf(fp,'  <TimeStamp><when>%4d-%02d-%02dT%02d:%02d:%04.2fZ</when></TimeStamp>\n',time(n,1:6));
	fprintf(fp,'  <Style>\n');
	fprintf(fp,'    <IconStyle>\n');
	fprintf(fp,'      <scale>0.2</scale>\n');
	fprintf(fp,'      <color>ff%s</color>\n',point_color);
	fprintf(fp,'      <Icon><href>http://maps.google.com/mapfiles/kml/pal2/icon26.png</href></Icon>\n');
	fprintf(fp,'    </IconStyle>\n');
	fprintf(fp,'  </Style>\n');
	fprintf(fp,'  <Point>\n');
%	fprintf(fp,'    <extrude>1</extrude>\n');
%	fprintf(fp,'    <altitudeMode>absolute</altitudeMode>\n');
	fprintf(fp,'    <coordinates>%15.9f,%15.9f,%15.9f</coordinates>\n',pos(n,2),pos(n,1),pos(n,3)-h);
	fprintf(fp,'  </Point>\n');
	fprintf(fp,'</Placemark>\n');
end
fprintf(fp,'</Folder>\n');

% 本文終了
%--------------------------------------------
fprintf(fp,'</Document>\n');

% ファイル終端
%--------------------------------------------
fprintf(fp,'</kml>\n');

fclose('all');

