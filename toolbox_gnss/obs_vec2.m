function Y=obs_vec(freq,wave,data,prn,obsmodel,est_prm)
%-------------------------------------------------------------------------------
% Function : �ϑ��ʂ̍쐬
% 
% [argin]
% freq      : ���g���̍\����(*.g1, *.g2, *.r1, *.r2)
% wave      : �g���̍\����(*.g1, *.g2, *.r1, *.r2)
% data      : �ϑ��f�[�^
% prn       : �q��PRN�ԍ�(�\����)
% obs_model : �ϑ����f��
% est_prm   : �ݒ�p�����[�^
% 
% [argout]
% Y         : �ϑ��ʃx�N�g��
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Dec. 18, 2007
%-------------------------------------------------------------------------------
% GLONASS�̎��g��, �g���̕ω��ɑΉ�
% Aug 03, 2009, T.Yanase
%-------------------------------------------------------------------------------

switch obsmodel
case 0,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���)
	Y = data(:,2);

case 1,		% PY �R�[�h�[������
	Y = data(:,6);

case 2,		% ionfree �ϑ���(2���g�[������)
	Y = [data(:,2) data(:,6)]*[f1^2; -f2^2]/(f1^2-f2^2);

case 3,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1 �����g�ʑ�
	Y1=[]; Y_g2=[]; Y_r2=[];
	Y1 = data(:,2);
	if est_prm.n_nav ==1
		Y_g2 = wave.g1*data(1:length(prn.rov.vg),1);
	end
	if est_prm.g_nav ==1
		Y_r2 = wave.r1.*data(length(prn.rov.vg)+1:end,1);
	end
	Y = [Y1; Y_g2; Y_r2];

case 4,		% ionfree �ϑ���(1���g�[������ & �����g)
	Y_g=[]; Y_r=[];
	if est_prm.n_nav ==1
		Y_g = 0.5*(data(1:length(prn.rov.vg),2) + wave.g1*data(1:length(prn.rov.vg),1));
	end
	if est_prm.g_nav ==1
		Y_r = 0.5*(data(length(prn.rov.vg)+1:end,2) + wave.r1.*data(length(prn.rov.vg)+1:end,1));
	end
	Y = [Y_g; Y_r];

case 5,		% ionfree �ϑ���(2���g�����g)
	Y_g=[]; Y_r=[];
	if est_prm.n_nav ==1
		Y_g = [wave.g1*data(1:length(prn.rov.vg),1) wave.g2*data(1:length(prn.rov.vg),5)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
	end
	if est_prm.g_nav ==1
		Y_r = (wave.r1.*data(length(prn.rov.vg)+1:end,1).*freq.r1.^2 - wave.r2.*data(length(prn.rov.vg)+1:end,5).*freq.r2.^2)./(freq.r1.^2-freq.r2.^2);
	end
	Y = [Y_g; Y_r];

case 6,		% CA,PY �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1,L2 �����g�ʑ�
	Y1=[]; Y_g2=[]; Y_r2=[]; Y3=[]; Y_g4=[]; Y_r4=[];
	Y1 = data(:,2);
	if est_prm.n_nav ==1
		Y_g2 = wave.g1*data(1:length(prn.rov.vg),1);
		Y_g4 = wave.g2*data(1:length(prn.rov.vg),5);
	end
	Y3 = data(:,6);
	if est_prm.g_nav ==1
		Y_r2 = wave.r1.*data(length(prn.rov.vg)+1:end,1);
		Y_r4 = wave.r2.*data(length(prn.rov.vg)+1:end,5);
	end
	Y = [Y1; Y3; Y_g2; Y_r2; Y_g4; Y_r4];

case 7,		% ionfree �ϑ���(2���g�[������ & �����g)
	Y_g1=[];, Y_g2=[];, Y_r1=[];, Y_r2=[];
	if est_prm.n_nav ==1
		Y_g1 = 0.5*(data(1:length(prn.rov.vg),2) + wave.g1*data(1:length(prn.rov.vg),1));
		Y_g2 = 0.5*(data(1:length(prn.rov.vg),6) + wave.g2*data(1:length(prn.rov.vg),5));
	end
	if est_prm.g_nav ==1
		Y_r1 = 0.5*(data(length(prn.rov.vg)+1:end,2) + wave.r1.*data(length(prn.rov.vg)+1:end,1));
		Y_r2 = 0.5*(data(length(prn.rov.vg)+1:end,6) + wave.r2.*data(length(prn.rov.vg)+1:end,5));
	end
	Y = [Y_g1; Y_r1; Y_g2; Y_r2];

case 8,		% ionfree �ϑ���(2���g�[������ & �����g)
	Y_g1=[];, Y_g2=[];, Y_r1=[];, Y_r2=[];
	if est_prm.n_nav ==1
		Y_g1 = [data(1:length(prn.rov.vg),2) data(1:length(prn.rov.vg),6)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
		Y_g2 = [wave.g1*data(1:length(prn.rov.vg),1) wave.g2*data(1:length(prn.rov.vg),5)]*[freq.g1^2; -freq.g2^2]/(freq.g1^2-freq.g2^2);
	end
	if est_prm.g_nav ==1
		Y_r1 = (data(length(prn.rov.vg)+1:end,2).*freq.r1.^2 - data(length(prn.rov.vg)+1:end,6).*freq.r2.^2)./(freq.r1.^2-freq.r2.^2);
		Y_r2 = (wave.r1.*data(length(prn.rov.vg)+1:end,1).*freq.r1.^2 - wave.r2.*data(length(prn.rov.vg)+1:end,5).*freq.r2.^2)./(freq.r1.^2-freq.r2.^2);
	end
	Y = [Y_g1; Y_r1; Y_g2; Y_r2];

case 9,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���) & L1,L2 �����g�ʑ�
	Y_g1=[];, Y_g2=[];, Y_g3=[];, Y_r1=[];, Y_r2=[]; Y_r3=[];
	if est_prm.n_nav ==1
		Y_g1 = data(1:length(prn.rov.vg),2);
		Y_g2 = wave.g1*data(1:length(prn.rov.vg),1);
		Y_g3 = wave.g2*data(1:length(prn.rov.vg),5);
	end
	if est_prm.g_nav ==1
		Y_r1 = data(length(prn.rov.vg)+1:end,2);
		Y_r2 = wave.r1.*data(length(prn.rov.vg)+1:end,1);
		Y_r3 = wave.r2.*data(length(prn.rov.vg)+1:end,5);
	end
	Y = [Y_g1; Y_r1; Y_g2; Y_r2; Y_g3; Y_r3];
case 10,		% CA �R�[�h�[������(�o�C�A�X�␳�ɂ��P1�ɑ���)
	Y = data(:,2);
end
