function [trop_igs] = read_trop(trop_file)
%-------------------------------------------------------------------------------
% Function : zpd ファイルから trop データ取得
% 
% [argin]
% trop_file : trop ファイル名
% 
% [argout]
% trop : ZTD 補正値 (dt=300をdt=30に変換)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% K.Nishikawa: Feb. 12, 2009
%-------------------------------------------------------------------------------

% trop ファイルオープン
%--------------------------------------------
fpo = fopen(trop_file,'rt');

% 61行読み飛ばし
%--------------------------------------------
temp  = fgetl(fpo);											% 1行読み込み
while findstr(temp,'*SITE EPOCH_______ TROTOT STDEV')		% 61行目なら終了
	temp = [];
	temp = fgetl(fpo);
end


% tropデータ全取得
%--------------------------------------------
j = 1;
temp  = fgetl(fpo);
while findstr(temp,'-TROP/SOLUTION')
	trop_igs(j,2)=str2num(temp(19:24));
	temp = [];
	j = j + 1;
end

for i=1:length(trop_igs)
	trop_igs(i*10-9:i*10,1)=ccjm_ZTD(i,2)/1000;
end
