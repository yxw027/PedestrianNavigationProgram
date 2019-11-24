clear all;
close('all');
fclose all;

data_fn  = '1����_insgps_������.csv';      %CSV�t�@�C�����ݒ�
file = '1����_insgps_������.kml';               %�����o��KML�t�@�C�����ݒ�
mode = 'hyb';                    %�����o���f�[�^��ʂ��w��Dhyb:�����q�@���ʁCGPS:GPS�f�[�^
point_color = 'M';               %�}�[�J�̐F�w��'Y','M','C','R','G','B','W','K'
track_color = 'M';               %��芸�����w�肷��i������Ȃ���OK�j
col_offset = 2;                  %�ǂݔ�΂���̐�(������2��ڂɕ�����f�[�^������̂�2�񕪂�ǂݔ�΂��C������Ȃ���OK)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpd = fopen(data_fn,'rt');       %1�s�ځC�w�b�_������̉��
tmp = fgetl(fpd);                %1�s����Ă���
n=length(tmp);
j=1;
k=1;
for i = 1 : n                    %�J���}��؂�Ńw�b�_��������Z���z��ɑ��
    if tmp(i)~=','
        continue;
    else
        head{k} = tmp(j:i-1);
        j=i+1;
        k=k+1;
    end
end
head(1:col_offset) = [];         %�ǂݔ�΂��񐔂����폜
if strcmp(mode,'hyb')            %�����o���ܓx�C�o�x�C���x�̗�ԍ���T��
    lat = strmatch('Lat',head);
    lon = strmatch('Lon',head);
    alt = strmatch('Alt',head);
elseif strcmp(mode, 'GPS')
    lat = strmatch('GPS lat',head);
    lon = strmatch('GPS lon',head);
    alt = strmatch('GPS alt',head);
end      

sat = strmatch('GPS sat',head);
pdop = strmatch('GPS PDOP',head);
gpstime = strmatch('GPS UTC',head);
gps_vel = strmatch('GPS vel',head);

fclose(fpd);
DATA = csvread(data_fn,1,col_offset);   %csv�f�[�^�̓ǂݍ���
data.pos = [DATA(5:end,lat) DATA(5:end,lon) DATA(5:end,alt)];
data.sat = [DATA(5:end,sat) DATA(5:end,pdop) DATA(5:end,gpstime) DATA(5:end,gps_vel)];
no_data = length(data.pos(:,1));
for i = 1 : no_data
    data.time(i,:) = weeksow2dtime([1858,i]);   %��芸����week��1858�ɌŒ肵��2015�N8��16��0��0��1�b����̘A�Ԃ�U���Ă�
end


output_kml(file,data,track_color,point_color);
