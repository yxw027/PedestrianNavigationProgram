function [Result2,Result_KGPS,ENUEr_spp,ENUEr_ppp]=jaxakgps(Result)

Result2=Result;
Result_KGPS=readkgps('L:\�����֘A\JAXA�����f�[�^\JAXA�f�[�^02\20070508chofu\KGPS\kinematic.txt');
% Results2.ppp.pos(:,1:6)=NaN;
% for i=1:length(Result_KGPS)
% 	j=find(Result2.ppp.time(:,3)==Result_KGPS(i,1));
% 	Result2.ppp.pos(j,4:6)=Result_KGPS(i,2:4);
% 	Result2.ppp.pos(j,1:3)=llh2xyz(Result_KGPS(i,2:4).*[pi/180,pi/180,1]);
% end
% for i=1:length(Result_KGPS),ENUEr_spp(i,:)=xyz2enu(Result.spp.pos(i,1:3)',Result2.ppp.pos(i,1:3)')';,end
% for i=1:length(Result_KGPS),ENUEr_ppp(i,:)=xyz2enu(Result.ppp.pos(i,1:3)',Result2.ppp.pos(i,1:3)')';,end

Results2.float.pos(:,1:6)=NaN;
for i=1:length(Result_KGPS)
	j=find(Result2.float.time(:,3)==Result_KGPS(i,1));
	Result2.float.pos(j,4:6)=Result_KGPS(i,2:4);
	Result2.float.pos(j,1:3)=llh2xyz(Result_KGPS(i,2:4).*[pi/180,pi/180,1]);
end
for i=1:length(Result_KGPS),ENUEr_spp(i,:)=xyz2enu(Result.spp.pos(i,1:3)',Result2.float.pos(i,1:3)')';,end
for i=1:length(Result_KGPS),ENUEr_ppp(i,:)=xyz2enu(Result.float.pos(i,1:3)',Result2.float.pos(i,1:3)')';,end


function DATA=readkgps(file)

i=0;
DATA(1:10000,1:4)=NaN;
fp=fopen(file,'rt');						% �t�@�C���I�[�v��
while 1
	i=i+1;

	temp=fgetl(fp);							% 1�s�擾
	if temp==-1, break, end

	data=str2num(temp);						% �������琔���ɕϊ�

	lat=data(2)+data(3)/60+data(4)/3600;	% �x���b����x�ɕϊ�
	lon=data(5)+data(6)/60+data(7)/3600;	% �x���b����x�ɕϊ�

	DATA(i,:)=[data(1) lat lon data(8)];	% ����,�ܓx,�o�x,���x���i�[
end
DATA=DATA(find(~isnan(DATA(:,1))),:);		% NaN�����O
fclose(fp);
