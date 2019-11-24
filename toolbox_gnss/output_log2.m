function output_log(f_sol,time_s,time_e,est_prm,mode)
%-------------------------------------------------------------------------------
% Function : �o�̓t�@�C���̃w�b�_�[�����̏�������
% 
% [argin]
% f_sol   : �o�̓t�@�C���|�C���^
% time_s  : �J�n����
% time_e  : �I������
% est_prm : �ݒ�p�����[�^
% mode    : ���ʃ��[�h(1:PPP, 2:Relative(float), 3:Relative(fix))
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: November 29, 2007
%-------------------------------------------------------------------------------
% G�t�@�C���ɑΉ�
% July 08, 2009, T.Yanase
%-------------------------------------------------------------------------------

% PPP
%--------------------------------------------
if mode==1
	fprintf(f_sol,'%% %d�N %d�� %d�� %d�� %d�� %f�b ���s\n',clock);
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

	% ���ʕ��я��̏����o��
	%--------------------------------------------
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'%% Epoch  WEEK      ToW     ToD        X[m]           Y[m]           Z[m]          East[m]     North[m]        Up[m] \n' );
	fprintf(f_sol,'%%------------------------------------------------------------------------------------------------------------------------------\n' );
end

% Relative(float�p)
%--------------------------------------------
if mode==2
	fprintf(f_sol,'%% %d�N %d�� %d�� %d�� %d�� %f�b ���s\n',clock);
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

	% ���ʕ��я��̏����o��
	%--------------------------------------------
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'%% Epoch  WEEK      ToW     ToD     X_float[m]     Y_float[m]     Z_float[m]    E_float[m]   N_float[m]   U_float[m] \n' );
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
end

% Relative(fix�p)
%--------------------------------------------
if mode==3
	fprintf(f_sol,'%% %d�N %d�� %d�� %d�� %d�� %f�b ���s\n',clock);
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

	% ���ʕ��я��̏����o��
	%--------------------------------------------
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
	fprintf(f_sol,'%% Epoch  WEEK      ToW     ToD      X_fix[m]       Y_fix[m]       Z_fix[m]       E_fix[m]     N_fix[m]     U_fix[m] \n' );
	fprintf(f_sol,'%%-------------------------------------------------------------------------------------------------------------------------------\n' );
end
