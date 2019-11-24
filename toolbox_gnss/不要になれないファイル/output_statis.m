function output_statis(result,ref,mode)
%-------------------------------------------------------------------------------
% Function : 統計量(平均, 標準偏差, RMS)の出力
% 
% [argin]
% result : 推定結果(1:Tod, 2-4:XYZ(ECEF))
% ref    : 真値XYZ
% mode   : Tex出力
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

% 真値を基準とした各軸方向の誤差
%--------------------------------------------
for k=1:length(result)
	ss(k,1:3)=xyz2enu(result(k,2:4),ref');									% ENUに変換
end

% 平均, 標準偏差, RMS
%--------------------------------------------
for n=1:3
	heikin(n) = mean(ss(find(~isnan(ss(:,n))),n));
	stdd(n) = std(ss(find(~isnan(ss(:,n))),n));
	rms(n)=sqrt(mean(ss(find(~isnan(ss(:,n))),n).^2));
end


% 画面表示
%--------------------------------------------
fprintf('\n      & Bias[m] &  STD[m] &  RMS[m] \n');
fprintf('East  & % 6.4f & % 6.4f & % 6.4f \n',heikin(1),stdd(1),rms(1));
fprintf('North & % 6.4f & % 6.4f & % 6.4f \n',heikin(2),stdd(2),rms(2));
fprintf('Up    & % 6.4f & % 6.4f & % 6.4f \n\n',heikin(3),stdd(3),rms(3));

% 画面表示(Tex用)
%--------------------------------------------
if mode==1
	fprintf('\n\\begin{table}[htbp] \n');
	fprintf('\\begin{center} \n');
	fprintf('\\caption{Summary statistics} \n');
	fprintf('\\begin{tabular}{|c|c|c|c|} \\hline \n');

	fprintf('      & Bias[m] &  STD[m] &  RMS[m] \\\\ \\hline\\hline \n');
	fprintf('East  & % 6.4f & % 6.4f & % 6.4f \\\\ \\hline \n',heikin(1),stdd(1),rms(1));
	fprintf('North & % 6.4f & % 6.4f & % 6.4f \\\\ \\hline \n',heikin(2),stdd(2),rms(2));
	fprintf('Up    & % 6.4f & % 6.4f & % 6.4f \\\\ \\hline \n',heikin(3),stdd(3),rms(3));

	fprintf('\\end{tabular} \n');
	fprintf('\\end{center} \n');
	fprintf('\\end{table} \n\n');
end
