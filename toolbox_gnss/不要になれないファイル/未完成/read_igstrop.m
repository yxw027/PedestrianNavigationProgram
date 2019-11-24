function [trop_igs] = read_trop(trop_file)
%-------------------------------------------------------------------------------
% Function : zpd �t�@�C������ trop �f�[�^�擾
% 
% [argin]
% trop_file : trop �t�@�C����
% 
% [argout]
% trop : ZTD �␳�l (dt=300��dt=30�ɕϊ�)
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% K.Nishikawa: Feb. 12, 2009
%-------------------------------------------------------------------------------

% trop �t�@�C���I�[�v��
%--------------------------------------------
fpo = fopen(trop_file,'rt');

% 61�s�ǂݔ�΂�
%--------------------------------------------
temp  = fgetl(fpo);											% 1�s�ǂݍ���
while findstr(temp,'*SITE EPOCH_______ TROTOT STDEV')		% 61�s�ڂȂ�I��
	temp = [];
	temp = fgetl(fpo);
end


% trop�f�[�^�S�擾
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
