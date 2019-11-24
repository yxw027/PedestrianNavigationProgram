function [tof, toe, s_time, e_time, app_xyz, no_obs, TYPES, dt, Rec_type] = read_obs_h(fpo)
%-------------------------------------------------------------------------------
% Function : observation �t�@�C���̃w�b�_�[���
% 
% [argin]
% fpo     : obs �t�@�C���|�C���^
% 
% [argout]
% tof     : TIME OF FIRST OBS
% toe     : TIME OF LAST OBS
% s_time  : stime �̎������ (ToD, Week, ToW, JD)
% e_time  : etime �̎������ (ToD, Week, ToW, JD)
% app_xyz : APPROX POSITION (X, Y, Z)
% no_obs  : �ϑ��ް���
% TYPES   : �ϑ��ް��̎�� (������)
% dt      : �X�V�Ԋu
% Rec_type: ��M�@�^�C�v
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------

dt=1;
ant_delta=[];
app_xyz=[];
TYPES=[];
tof=[];
toe=[];
s_time=[];
e_time=[];
while 1
	temp  = fgetl(fpo);														% 1�s�ǂݍ���
	if (temp == -1)															% END OF HEADER �ȑO�� EOF �̎�
		fprintf('"o" �t�@�C���̃w�b�_������ɓǂݍ��܂�܂���ł���\n')
		break;
	elseif findstr(temp,'MARKER NAME')										% MARKER NAME
	elseif findstr(temp,'REC # / TYPE / VERS')								% REC # / TYPE / VERS
		Rec_type = temp(20:40);
	elseif findstr(temp,'ANT # / TYPE');									% ANT # / TYPE
	elseif findstr(temp,'APPROX POSITION XYZ')								% APPROX POSITION XYZ
		app_xyz=str2num(temp(1:60));										% X Y Z ��
		if isempty(app_xyz), app_xyz=[0,0,0];, end
	elseif findstr(temp,'ANTENNA: DELTA H/E/N')								% ANTENNA: DELTA H/E/N
		ant_delta=str2num(temp(1:60));										% X Y Z ��
	elseif findstr(temp,'# / TYPES OF OBSERV')								% # / TYPES OF OBSERV
		no_obs = str2num(temp(1:6));										% �ϑ��ް����̎��o��
		TYPES=temp(7:60); TYPES=TYPES(find(TYPES~=' '));					% �ϑ��ް��̎�ނ��i�[
	elseif findstr(temp,'INTERVAL')											% INTERVAL
		dt=str2num(temp(1:60));												% �X�V�Ԋu�̎��o��
	elseif findstr(temp,'TIME OF FIRST OBS')								% TIME OF FIRST OBS
		tof=str2num(temp(1:43));
		if tof(1)<80, tof(1)=tof(1)+2000;, end
		tod_s = round(tof(4)*3600 + tof(5)*60 + tof(6));					% stime �� TOD
		mjd_s = mjuliday(tof);												% stime �� Modified Julian day
		[week_s,tow_s] = weekf(mjd_s);										% stime �� WEEK, TOW
		s_time = [tod_s; week_s; tow_s; mjd_s];								% stime �� ���������i�[
	elseif findstr(temp,'TIME OF LAST OBS')									% TIME OF LAST OBS
		toe=str2num(temp(1:43));
		if toe(1)<80, toe(1)=toe(1)+2000;, end
		tod_e = round(toe(4)*3600 + toe(5)*60 + toe(6));					% etime �� TOD
		mjd_e = mjuliday(toe);												% etime �� Modified Julian day
		[week_e,tow_e] = weekf(mjd_e);										% etime �� WEEK, TOW
		e_time = [tod_e; week_e; tow_e; mjd_e];								% etime �� ���������i�[
	elseif findstr(temp,'END OF HEADER')									% END OF HEADER�Ȃ�I��
		break;
	end;
	temp = [];
end
