function output_nmea(file,result,est_prm)
%-------------------------------------------------------------------------------
% Function : INS�p�t�H�[�}�b�g�o��
% 
% [argin]
% file   : �t�@�C����
% result : ���茋�ʍ\����(*.time:����, *.pos:�ʒu)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Sep. 30, 2008
%-------------------------------------------------------------------------------

% �t�@�C���I�[�v��
%--------------------------------------------
fp=fopen(file,'w');

% NaN�����O
%--------------------------------------------
i=find(~isnan(result.pos(:,1)));
result.pos=result.pos(i,:);

for k=1:length(result.pos)
	enu(k,1:3)=xyz2enu(result.pos(k,1:3)',est_prm.rovpos);									% ENU�ɕϊ�
	if k == 1
		vel(k,1:3) = [0 0 0];
	else
		vel(k,1:3) = enu(k,1:3) - enu(k-1,1:3);
	end
end
org=xyz2llh(est_prm.rovpos).*[180/pi,180/pi,1];

fprintf(fp,'GPS���ʉ��Z���ʃt�@�C��,11-%s-001\n',datestr(now,'yyyy-mm-dd'));	
fprintf(fp,'���_�ʒu(L_L_H)(deg_deg_m),%.10f,%.10f,%.4f\n',org);	
fprintf(fp,'�N����,����,�ʒu(E)(m),�ʒu(N)(m),�ʒu(U)(m),���x(E)(m/s),���x(N)(m/s),���x(U)(m/s)\n');	

for n=1:size(enu,1)
	time_ymd=sprintf('%4d%02d%02d',result.time(n,5:7));
	time_hms=sprintf('%02d%02d%06.3f',result.time(n,8:10));
	fprintf(fp,'%s,%s,%5.4f,%5.4f,%5.4f,%5.4f,%5.4f,%5.4f\n',time_ymd,time_hms,enu(n,1:3),vel(n,1:3));
end
fclose('all');
