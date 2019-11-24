function output_nmea(file,data)
%-------------------------------------------------------------------------------
% Function : NMEA�t�H�[�}�b�g�o��
% 
% [argin]
% file : �t�@�C����
% data : n�~9 �G�|�b�N���� (Y,M,D,H,M,S, lat,lon,Ell.H, num_sat, dop)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: July 3, 2008
%-------------------------------------------------------------------------------

% NaN�����O
%--------------------------------------------
i=find(~isnan(data.pos(:,1)));

% TIME
%--------------------------------------------
time=data.time(i,5:10);

% POSITION
%--------------------------------------------
pos=data.pos(i,4:6);
h=geoidh(pos(1,1:2));

% No. of Sat
%--------------------------------------------
num=data.prn{3}(i,3);

% DOP
%--------------------------------------------
dop=data.prn{3}(i,4);

% POSITION NMEA�p�ɕϊ�
%--------------------------------------------
dd=floor(pos(:,1:2));																% �x 
ss=((pos(:,1:2)-dd))*60;															% �� 
mm=floor(ss);																		% ��(��������)
ss=ss-mm;																			% ��(�����_�ȉ��̕���)

% ���[�J���^�C��
%--------------------------------------------
ltime(:,1) = time(:,4)+9;
ltime(:,2) = time(:,5);
ltime(find(ltime(:,1)>24),1) = ltime(find(ltime(:,1)>24),1)-24;


% �t�@�C���o��
%--------------------------------------------

% $GPGGA,m1,m2,N,m3,E,d1,d2,f1,f2,M,f3,M,f4,d3*cc
%--------------------------------------------
% m1: hh:mm:ss �ϑ�����(UTC)
% m2: NN nn.nnnnnn[N] �k��NN�xnn.nnnnnn��
% m3: EE ee.eeeeee[E] ���oEE�xee.eeeeee��
% d1: ���ʏ󋵁@0�F���ʗ��p�s�@1:SPS, 2:DGPS, 3:PPS, 4:RTK, 5:Float RTK, ...
% d2: �g�p�q����
% f1: �������ʌ덷(HDOP)
% f2: �������ʌ덷[m]
% f3: �W�I�C�h��[m] 

% $GPZDA,f1,d1,d2,d3,d4,d5*cc
%--------------------------------------------
% f1: ���ʎ���(UTC)�@12:35:19.00 �� 123519.00
% d1: ��(UTC)
% d2: ��(UTC)
% d3: �N(UTC)
% d4: ��(���[�J������)
% d5: ��(���[�J������)
% cc: checksum

% �t�@�C���I�[�v��
%--------------------------------------------
fp=fopen(file,'w');

for n=1:size(pos,1)

	% $GPGGA,m1,m2,N,m3,E,d1,d2,f1,f2,M,f3,M,f4,d3*cc
	%--------------------------------------------
	m1=sprintf('%02d%02d%05.2f',time(n,4),time(n,5),time(n,6));								% �����̏o�̓t�H�[�}�b�g
	m2=sprintf('%02d%02d.%06.0f',dd(n,1),mm(n,1),ss(n,1)*1e6);								% �ܓx�̏o�̓t�H�[�}�b�g
	m3=sprintf('%03d%02d.%06.0f',dd(n,2),mm(n,2),ss(n,2)*1e6);								% �o�x�̏o�̓t�H�[�}�b�g
	d1=sprintf('%1d',1);																	% ���ʏ󋵂̏o�̓t�H�[�}�b�g
	d2=sprintf('%02d',num(n,1));															% �g�p�q�����̏o�̓t�H�[�}�b�g
	f1=sprintf('%2.1f',dop(n,1));															% �������ʌ덷�̏o�̓t�H�[�}�b�g
	f2=sprintf('%07.2f',pos(n,3));															% �������ʌ덷�̏o�̓t�H�[�}�b�g
	f3=sprintf('%04.1f',pos(n,3));															% �W�I�C�h���̏o�̓t�H�[�}�b�g

	gpgga=sprintf('$GPGGA,%s,%s,N,%s,E,%s,%s,%s,%s,M,%s,M,,',m1,m2,m3,d1,d2,f1,f2,f3);		% GPGGA�̏o�̓t�H�[�}�b�g
	checksum=nmeachecksum(gpgga);															% GPGGA��checksum
	fprintf(fp,'%s*%s\n',gpgga,checksum);													% GPGGA���t�@�C���ɏo��

	% $GPZDA,f1,d1,d2,d3,d4,d5*cc
	%--------------------------------------------
	f1=sprintf('%02d%02d%05.2f',time(n,4),time(n,5),time(n,6));								% �����̏o�̓t�H�[�}�b�g
	d1=sprintf('%02d',time(n,3));															% ���̏o�̓t�H�[�}�b�g
	d2=sprintf('%02d',time(n,2));															% ���̏o�̓t�H�[�}�b�g
	d3=sprintf('%4d',time(n,1));															% �N�̏o�̓t�H�[�}�b�g
	d4=sprintf('%02d',ltime(n,1));															% ��(���[�J������)�̏o�̓t�H�[�}�b�g
	d5=sprintf('%02d',ltime(n,2));															% ��(���[�J������)�̏o�̓t�H�[�}�b�g

	gpzda=sprintf('$GPZDA,%s,%s,%s,%s,%s,%s',f1,d1,d2,d3,d4,d5);							% GPZDA�̏o�̓t�H�[�}�b�g
	checksum=nmeachecksum(gpzda);															% GPZDA��checksum
	fprintf(fp,'%s*%s\n',gpzda,checksum);													% GPZDA���t�@�C���ɏo��

end
fclose('all');



%-------------------------------------------------------------------------------
% �ȉ�, �T�u���[�`��

% checksum�����߂�֐�
%--------------------------------------------
function checksum = nmeachecksum(NMEA_String)

checksum = 0;

% see if string contains the * which starts the checksum and keep string
% upto * for generating checksum
NMEA_String = strtok(NMEA_String,'*');

NMEA_String_d = double(NMEA_String);													% convert characters in string to double values
for count = 2:length(NMEA_String)														% checksum calculation ignores $ at start
	checksum = bitxor(checksum,NMEA_String_d(count));									% checksum calculation
	checksum = uint16(checksum);														% make sure that checksum is unsigned int16
end

% convert checksum to hex value
checksum = double(checksum);
checksum = dec2hex(checksum);

% add leading zero to checksum if it is a single digit, e.g. 4 has a 0
% added so that the checksum is 04
if length(checksum) == 1
	checksum = strcat('0',checksum);
end
