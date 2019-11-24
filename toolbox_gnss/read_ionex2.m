function [ion_prm] = read_ionex(ionex_file)
%-------------------------------------------------------------------------------
% Function : ionex �t�@�C������ TEC �f�[�^�S�擾
% 
% [argin]
% ionex_file : ionex �t�@�C����
% 
% [argout]
% ion_prm : TEC�f�[�^(t,tec,deg : 3dim)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------

% ionex �t�@�C���I�[�v��
%--------------------------------------------
fpo = fopen(ionex_file,'rt');

% ionex �w�b�_�[���
%--------------------------------------------
[tofi,toei,s_timei,e_timei,interval,maps,lats,lons,hgts,baseRe,nexp,dcbG,dcbR] = ionex_h(fpo);


% TEC�f�[�^�S�擾
%--------------------------------------------
j = 0;
e_o_h  = 1;
tt     = 1;
tof    = [];
toe    = [];
s_time = [];
e_time = [];
time=[];
while 1
	temp  = fgetl(fpo);													% 1�s�ǂݍ���
	if (temp == -1)														% END OF FILE �ȑO�� EOF �̎�
		fprintf('"ionex" �t�@�C��������ɓǂݍ��܂�܂���ł���\n')
		break;
	elseif findstr(temp,'START OF TEC MAP')								% START OF TEC MAP
		j = 0;
		smap = str2num(temp(1:60));
	elseif findstr(temp,'EPOCH OF CURRENT MAP')							% EPOCH OF CURRENT MAP
		tof = str2num(temp(1:60));
		if tof(1) < 80
			tof(1) = tof(1) + 2000;
		end
		tod_s = round(tof(4)*3600 + tof(5)*60 + tof(6));				% stime �� TOD
		mjd_s = mjuliday(tof);											% stime �� Modified Julian day
		[week_s,tow_s] = weekf(mjd_s);									% stime �� WEEK, TOW
		s_time = [tod_s; week_s; tow_s; mjd_s];							% stime �� ���������i�[
		time=[time; mjd_s];
	elseif findstr(temp,'LAT/LON1/LON2/DLON/H')							% LAT/LON1/LON2/DLON/H
		lat    = str2num(temp(3:8));
		lon1   = str2num(temp(9:14));
		lon2   = str2num(temp(15:20));
		dlon   = str2num(temp(21:26));
		height = str2num(temp(27:32));
		j = j + 1;														% TEC �擾
		tec_map = [];
		for k = 1:5
			temp  = fgetl(fpo);
			tec_m = str2num(temp);
			tec_map = [tec_map tec_m];
		end
		TEC(smap,:,j) = tec_map*10^nexp;
	elseif findstr(temp,'END OF TEC MAP')								% END OF TEC MAP
		j = 0;
		emap = str2num(temp(1:60));
		if emap == maps
			break;
		end
	elseif findstr(temp,'END OF FILE')									% END OF FILE�Ȃ�I��
		break;
	end
	temp = [];
end
ion_prm.time=time;
ion_prm.map=TEC;
ion_prm.dcbG=dcbG;
ion_prm.dcbR=dcbR;
ion_prm.lats=lats;
ion_prm.lons=lons;
ion_prm.hgts=hgts;
ion_prm.baseRe=baseRe;



%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

function [tof,toe,s_time,e_time,interval,maps,lats,lons,hgts,baseRe,nexp,dcbG,dcbR] = ionex_h(fpo)
%-------------------------------------------------------------------------------
% ionex �t�@�C���̃w�b�_�[���
% 
% [argin]
% ionex : ionex �t�@�C���|�C���^
% 
% [argout]
% tof      : TIME OF FIRST OBS
% toe      : TIME OF LAST OBS
% s_time   : stime �̎������ (ToD, Week, ToW, JD)
% e_time   : etime �̎������ (ToD, Week, ToW, JD)
% interval : �X�V�Ԋu
% maps     : MAP �̐�
% lats     : �ܓx�͈̔�, �Ԋu
% lons     : �o�x�͈̔�, �Ԋu
% hgts     : ���x�͈̔�, �Ԋu
% nexp     : TEC MAP�̃X�P�[��
% dcbG     : DIFFERENTIAL CODE BIASES(G)
% dcbR     : DIFFERENTIAL CODE BIASES(R)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 16, 2007
%-------------------------------------------------------------------------------

tof    = [];
toe    = [];
s_time = [];
e_time = [];
dcbG   = [];
dcbR   = [];
while 1
	temp  = fgetl(fpo);															% 1�s�ǂݍ���
	if (temp == -1)																% END OF HEADER �ȑO�� EOF �̎�
		fprintf('"ionex" �t�@�C���̃w�b�_������ɓǂݍ��܂�܂���ł���\n')
		break;
	elseif findstr(temp,'EPOCH OF FIRST MAP')									% EPOCH OF FIRST MAP
		tof = str2num(temp(1:60));
		if tof(1)<80, tof(1)=tof(1)+2000;, end
		tod_s = round(tof(4)*3600 + tof(5)*60 + tof(6));						% stime �� TOD
		mjd_s = mjuliday(tof);													% stime �� Modified Julian day
		[week_s,tow_s] = weekf(mjd_s);											% stime �� WEEK, TOW
		s_time = [tod_s; week_s; tow_s; mjd_s];									% stime �� ���������i�[
	elseif findstr(temp,'EPOCH OF LAST MAP')									% EPOCH OF LAST MAP
		toe = str2num(temp(1:60));
		if toe(1)<80, toe(1)=toe(1)+2000;, end
		tod_e = round(toe(4)*3600 + toe(5)*60 + toe(6));						% etime �� TOD
		mjd_e = mjuliday(toe);													% etime �� Modified Julian day
		[week_e,tow_e] = weekf(mjd_e);											% etime �� WEEK, TOW
		e_time = [tod_e; week_e; tow_e; mjd_e];									% etime �� ���������i�[
	elseif findstr(temp,'INTERVAL')												% INTERVAL
		interval = str2num(temp(1:60));
	elseif findstr(temp,'# OF MAPS IN FILE')									% # OF MAPS IN FILE �s�̊i�[
		maps = str2num(temp(1:60));
	elseif findstr(temp,'BASE RADIUS')											% BASE RADIUS �s�̊i�[
		baseRe = str2num(temp(1:60));
	elseif findstr(temp,'HGT1 / HGT2 / DHGT')									% HGT1 / HGT2 / DHGT �s�̊i�[
		hgts = str2num(temp(1:60));
	elseif findstr(temp,'LAT1 / LAT2 / DLAT')									% LAT1 / LAT2 / DLAT �s�̊i�[
		lats = str2num(temp(1:60));
	elseif findstr(temp,'LON1 / LON2 / DLON')									% LON1 / LON2 / DLON �s�̊i�[
		lons = str2num(temp(1:60));
	elseif findstr(temp,'EXPONENT')												% EXPONENT �s�̊i�[
		nexp = str2num(temp(1:60));
	elseif findstr(temp,'START OF AUX DATA')									% START OF AUX DATA
		while 1
			temp  = fgetl(fpo);													% 1�s�ǂݍ���
			if findstr(temp,'PRN / BIAS / RMS');								% PRN / BIAS / RMS
				if temp(4)=='G' | temp(4)==' '
					dcbG=[dcbG; str2num(temp(5:26))];
				elseif temp(4)=='R'
					dcbR=[dcbR; str2num(temp(5:26))];
				end
			elseif findstr(temp,'STATION / BIAS / RMS')							% STATION / BIAS / RMS

			elseif findstr(temp,'END OF AUX DATA')								% END OF AUX DATA
				break;
			end
		end
	elseif findstr(temp,'END OF HEADER')										% END OF HEADER�Ȃ�I��
		break;
	end
	temp = [];
end
