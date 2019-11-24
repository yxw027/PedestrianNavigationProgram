function output_nmea(file,result,est_prm)
%-------------------------------------------------------------------------------
% Function : INS用フォーマット出力
% 
% [argin]
% file   : ファイル名
% result : 推定結果構造体(*.time:時刻, *.pos:位置)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Sep. 30, 2008
%-------------------------------------------------------------------------------

% ファイルオープン
%--------------------------------------------
fp=fopen(file,'w');

% NaNを除外
%--------------------------------------------
i=find(~isnan(result.pos(:,1)));
result.pos=result.pos(i,:);

for k=1:length(result.pos)
	enu(k,1:3)=xyz2enu(result.pos(k,1:3)',est_prm.rovpos);									% ENUに変換
	if k == 1
		vel(k,1:3) = [0 0 0];
	else
		vel(k,1:3) = enu(k,1:3) - enu(k-1,1:3);
	end
end
org=xyz2llh(est_prm.rovpos).*[180/pi,180/pi,1];

fprintf(fp,'GPS測位演算結果ファイル,11-%s-001\n',datestr(now,'yyyy-mm-dd'));	
fprintf(fp,'原点位置(L_L_H)(deg_deg_m),%.10f,%.10f,%.4f\n',org);	
fprintf(fp,'年月日,時刻,位置(E)(m),位置(N)(m),位置(U)(m),速度(E)(m/s),速度(N)(m/s),速度(U)(m/s)\n');	

for n=1:size(enu,1)
	time_ymd=sprintf('%4d%02d%02d',result.time(n,5:7));
	time_hms=sprintf('%02d%02d%06.3f',result.time(n,8:10));
	fprintf(fp,'%s,%s,%5.4f,%5.4f,%5.4f,%5.4f,%5.4f,%5.4f\n',time_ymd,time_hms,enu(n,1:3),vel(n,1:3));
end
fclose('all');
