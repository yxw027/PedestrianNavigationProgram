function output_log(f_sol,time_s,time_e,est_prm,mode)
%-------------------------------------------------------------------------------
% Function : 出力ファイルのヘッダー部分の書き込み
% 
% [argin]
% f_sol   : 出力ファイルポインタ
% time_s  : 開始時刻
% time_e  : 終了時刻
% est_prm : 設定パラメータ
% mode    : 測位モード(1:PPP, 2:Relative(float), 3:Relative(fix))
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: November 29, 2007
%-------------------------------------------------------------------------------
% Gファイルに対応
% July 08, 2009, T.Yanase
%-------------------------------------------------------------------------------

% PPP
%--------------------------------------------
if mode==1
	fprintf(f_sol,'%% %d年 %d月 %d日 %d時 %d分 %f秒 実行\n',clock);
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'Observation File :  %s\n',est_prm.file.rov_o);
	if est_prm.n_nav==1
		fprintf(f_sol,'Ephemeris_N File :  %s\n',est_prm.file.rov_n);
	else
		fprintf(f_sol,'Ephemeris_N File :  Nothing\n');
	end
	if est_prm.g_nav==1
		fprintf(f_sol,'Ephemeris_G File :  %s\n',est_prm.file.rov_g);
	else
		fprintf(f_sol,'Ephemeris_G File :  Nothing\n');
	end
	if est_prm.i_mode==2
		fprintf(f_sol,'IONEX       File :  %s\n',est_prm.file.ionex);
	else
		fprintf(f_sol,'IONEX       File :  Nothing\n');
	end
	if est_prm.sp3==1
		fprintf(f_sol,'IGS SP3     File :  %s\n',est_prm.file.sp3);
	else
		fprintf(f_sol,'IGS SP3     File :  Nothing\n');
	end
	fprintf(f_sol,'START       TIME :  %4d/%2d/%2d %2d:%2d:%2d\n',time_s.day);
	if ~isempty(time_e.day)
		fprintf(f_sol,'END         TIME :  %4d/%2d/%2d %2d:%2d:%2d\n',time_e.day);
	else
		fprintf(f_sol,'END         TIME :  End of File\n');
	end
	fprintf(f_sol,'True Position[m] :  X = %12.4f,  Y = %12.4f,  Z = %12.4f\n',est_prm.rovpos');
	fprintf(f_sol,'\n');

	% 結果並び順の書き出し
	%--------------------------------------------
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'%% Epoch  WEEK      ToW     ToD        X[m]           Y[m]           Z[m]          East[m]     North[m]        Up[m] \n' );
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
end

% Relative(float用)
%--------------------------------------------
if mode==2
	fprintf(f_sol,'%% %d年 %d月 %d日 %d時 %d分 %f秒 実行\n',clock);
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'Observation File :  %s\n',est_prm.file.rov_o);
	if est_prm.n_nav==1
		fprintf(f_sol,'Ephemeris_N File :  %s\n',est_prm.file.rov_n);
	else
		fprintf(f_sol,'Ephemeris_N File :  Nothing\n');
	end
	if est_prm.g_nav==1
		fprintf(f_sol,'Ephemeris_G File :  %s\n',est_prm.file.rov_g);
	else
		fprintf(f_sol,'Ephemeris_G File :  Nothing\n');
	end
	if est_prm.i_mode==2
		fprintf(f_sol,'IONEX       File :  %s\n',est_prm.file.ionex);
	else
		fprintf(f_sol,'IONEX       File :  Nothing\n');
	end
	if est_prm.sp3==1
		fprintf(f_sol,'IGS SP3     File :  %s\n',est_prm.file.sp3);
	else
		fprintf(f_sol,'IGS SP3     File :  Nothing\n');
	end
	fprintf(f_sol,'START       TIME :  %4d/%2d/%2d %2d:%2d:%2d\n',time_s.day);
	if ~isempty(time_e.day)
		fprintf(f_sol,'END         TIME :  %4d/%2d/%2d %2d:%2d:%2d\n',time_e.day);
	else
		fprintf(f_sol,'END         TIME :  End of File\n');
	end
	fprintf(f_sol,'Ref. Position[m] :  X = %12.4f,  Y = %12.4f,  Z = %12.4f\n',est_prm.refpos');
	if est_prm.statemodel.pos==0
		fprintf(f_sol,'True Position[m] :  X = %12.4f,  Y = %12.4f,  Z = %12.4f\n',est_prm.rovpos');
		fprintf(f_sol,'True Baseline[m] :  %12.4f\n',norm(est_prm.rovpos-est_prm.refpos));
	end
	fprintf(f_sol,'\n');

	% 結果並び順の書き出し
	%--------------------------------------------
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'%% Epoch  WEEK      ToW     ToD     X_float[m]     Y_float[m]     Z_float[m]    E_float[m]   N_float[m]   U_float[m] \n' );
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
end

% Relative(fix用)
%--------------------------------------------
if mode==3
	fprintf(f_sol,'%% %d年 %d月 %d日 %d時 %d分 %f秒 実行\n',clock);
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'Observation File :  %s\n',est_prm.file.rov_o);
	if est_prm.n_nav==1
		fprintf(f_sol,'Ephemeris_N File :  %s\n',est_prm.file.rov_n);
	else
		fprintf(f_sol,'Ephemeris_N File :  Nothing\n');
	end
	if est_prm.g_nav==1
		fprintf(f_sol,'Ephemeris_G File :  %s\n',est_prm.file.rov_g);
	else
		fprintf(f_sol,'Ephemeris_G File :  Nothing\n');
	end
	if est_prm.i_mode==2
		fprintf(f_sol,'IONEX       File :  %s\n',est_prm.file.ionex);
	else
		fprintf(f_sol,'IONEX       File :  Nothing\n');
	end
	if est_prm.sp3==1
		fprintf(f_sol,'IGS SP3     File :  %s\n',est_prm.file.sp3);
	else
		fprintf(f_sol,'IGS SP3     File :  Nothing\n');
	end
	fprintf(f_sol,'START       TIME :  %4d/%2d/%2d %2d:%2d:%2d\n',time_s.day);
	if ~isempty(time_e.day)
		fprintf(f_sol,'END         TIME :  %4d/%2d/%2d %2d:%2d:%2d\n',time_e.day);
	else
		fprintf(f_sol,'END         TIME :  End of File\n');
	end
	fprintf(f_sol,'Ref. Position[m] :  X = %12.4f,  Y = %12.4f,  Z = %12.4f\n',est_prm.refpos');
	if est_prm.statemodel.pos==0
		fprintf(f_sol,'True Position[m] :  X = %12.4f,  Y = %12.4f,  Z = %12.4f\n',est_prm.rovpos');
		fprintf(f_sol,'True Baseline[m] :  %12.4f\n',norm(est_prm.rovpos-est_prm.refpos));
	end
	fprintf(f_sol,'\n');

	% 結果並び順の書き出し
	%--------------------------------------------
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'%% Epoch  WEEK      ToW     ToD      X_fix[m]       Y_fix[m]       Z_fix[m]       E_fix[m]     N_fix[m]     U_fix[m] \n' );
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
end
