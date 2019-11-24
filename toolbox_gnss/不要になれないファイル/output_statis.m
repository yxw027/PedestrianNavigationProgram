function output_statis(result,ref,mode)
%-------------------------------------------------------------------------------
% Function : ���v��(����, �W���΍�, RMS)�̏o��
% 
% [argin]
% result : ���茋��(1:Tod, 2-4:XYZ(ECEF))
% ref    : �^�lXYZ
% mode   : Tex�o��
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

% �^�l����Ƃ����e�������̌덷
%--------------------------------------------
for k=1:length(result)
	ss(k,1:3)=xyz2enu(result(k,2:4),ref');									% ENU�ɕϊ�
end

% ����, �W���΍�, RMS
%--------------------------------------------
for n=1:3
	heikin(n) = mean(ss(find(~isnan(ss(:,n))),n));
	stdd(n) = std(ss(find(~isnan(ss(:,n))),n));
	rms(n)=sqrt(mean(ss(find(~isnan(ss(:,n))),n).^2));
end


% ��ʕ\��
%--------------------------------------------
fprintf('\n      & Bias[m] &  STD[m] &  RMS[m] \n');
fprintf('East  & % 6.4f & % 6.4f & % 6.4f \n',heikin(1),stdd(1),rms(1));
fprintf('North & % 6.4f & % 6.4f & % 6.4f \n',heikin(2),stdd(2),rms(2));
fprintf('Up    & % 6.4f & % 6.4f & % 6.4f \n\n',heikin(3),stdd(3),rms(3));

% ��ʕ\��(Tex�p)
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
