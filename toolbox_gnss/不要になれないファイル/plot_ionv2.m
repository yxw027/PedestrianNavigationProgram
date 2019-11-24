function plot_ionv2(LC,result,est_prm,dt)
%-------------------------------------------------------------------------------
% Function : �d���w�x���ϓ��p�v���b�g
% 
% [argin]
% LC      : ���`�����\����
% result  : ���茋�ʍ\����(*.dion 1-31:Ionosphere delay)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% dt      : X���̖ڐ���Ԋu
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

ionsd=LC.rov.ionl-LC.ref.ionl;
ionsd_lcv(1:length(ionsd),1:31)=NaN;
IONsd_estv(1:length(ionsd),1:31)=NaN;

for prn=1:31
	% SD�d���w�x���ϓ�(LC)
	%--------------------------------------------
	i=find(~isnan(ionsd(:,prn)));														% NaN�ȊO�̃C���f�b�N�X
	if ~isempty(i)
		j=find(diff(i)>30);																% �C���f�b�N�X�̍���30���傫������(�����_�̒T��)
		arc=[]; off=[]; arcs=[]; arce=[];
		for k=1:length(j)
			arc(k)=i(j(k)+1);															% �����_
		end
		arcs=[i(1),arc];																% �����J�n�_(��������)
		arce=[arc-1,i(end)];															% �����I���_(��������)
		for ii=1:length(arcs)
			A=ionsd(arcs(ii):arce(ii),prn);												% �����͈͂Ŏ��o��
			off=mean(A(find(~isnan(A))));												% �o�C�A�X����
			ionsd_lcv(arcs(ii):arce(ii),prn)=ionsd(arcs(ii):arce(ii),prn)-off;			% �ϓ�����
		end
	end

	% SD�d���w�x���ϓ�(Estimate)
	%--------------------------------------------
	i=find(~isnan(result.dion(:,prn)));													% NaN�ȊO�̃C���f�b�N�X
	if ~isempty(i)
		j=find(diff(i)>30);																% �C���f�b�N�X�̍���30���傫������(�����_�̒T��)
		arc=[]; off=[]; arcs=[]; arce=[];
		for k=1:length(j)
			arc(k)=i(j(k)+1);															% �����_
		end
		arcs=[i(1),arc];																% �����J�n�_(��������)
		arce=[arc-1,i(end)];															% �����I���_(��������)
		for ii=1:length(arcs)
			A=result.dion(arcs(ii):arce(ii),prn);										% �����͈͂Ŏ��o��
			off=mean(A(find(~isnan(A))));												% �o�C�A�X����
			IONsd_estv(arcs(ii):arce(ii),prn)=result.dion(arcs(ii):arce(ii),prn)-off;	% �ϓ�����
		end
	end
end


% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');

% �v���b�g
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);						% figure���w��ʒu�E�T�C�Y�ō쐬
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.109 0.513 0.812 0.37]);											% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
plot(result.time(:,4),ionsd_lcv,'.-');													% SD�d���w�x���ϓ�(LC)�̃v���b�g
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;												% X���͈͂̍ő�l
if last<max(result.time(:,4)), last=max(result.time(:,4));, end							% X���͈͂̍ő�l
if result.time(1,4)>900
	xlim([result.time(1,4),last]);														% X���͈͂̍ő�l
else
	xlim([0,last]);																		% X���͈͂̍ő�l
end
% ylim([-0.6,0.8]);																		% Y���͈̔�
ylim([-1,1]);																			% Y���͈̔�
set(gca,'XTick',[0:dt:last]);															% X���̖ڐ���
% set(gca,'XTickLabel',{0:dt:last});													% X���̖ڐ���̃��x��
set(gca,'XTickLabel','');																% X���̃��x��
% xlabel('ToD [sec.]');																	% X���̃��x��
ylabel('LC[m]');																		% Y���̃��x��
title(['Ionospheric Delay Variation','(SD)',' : ',TT]);									% �^�C�g��

% �v���b�g
%--------------------------------------------
% figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.109 0.113 0.812 0.37]);											% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
plot(result.time(:,4),IONsd_estv,'.-');													% SD�d���w�x���ϓ�(Estimate)�̃v���b�g
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;												% X���͈͂̍ő�l
if last<max(result.time(:,4)), last=max(result.time(:,4));, end							% X���͈͂̍ő�l
if result.time(1,4)>900
	xlim([result.time(1,4),last]);														% X���͈͂̍ő�l
else
	xlim([0,last]);																		% X���͈͂̍ő�l
end
% ylim([-0.6,0.8]);																		% Y���͈̔�
ylim([-1,1]);																			% Y���͈̔�
set(gca,'XTick',[0:dt:last]);															% X���̖ڐ���
set(gca,'XTickLabel',{0:dt:last});														% X���̖ڐ���̃��x��
xlabel('ToD [sec.]');																	% X���̃��x��
ylabel('Estimate[m]');																	% Y���̃��x��
% title(['Ionospheric Delay Variation','(Estimate)',' : ',TT]);							% �^�C�g��
