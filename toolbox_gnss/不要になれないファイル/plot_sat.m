function plot_sat(result,est_prm,dt)
%-------------------------------------------------------------------------------
% Function : �q���֘A�v���b�g
% 
% [argin]
% result  : ���茋�ʂ̍\����(��: Result.spp; �g�p����͉̂��L�̃t�B�[���h����)
%           �q���֘A�̍\����(result.prn)
%            (�Z���z�� 1: ���q��, 2: �g�p�q��, 3: �q�����Ȃ�(tod,all,used,dop), 4: ��q��)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% dt      : ���x���̊Ԋu(ToD)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 18, 2008
%-------------------------------------------------------------------------------

if nargin==1, dt=3600;, end

% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');

% �q�����̕ω�
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);					% figure���w��ʒu�E�T�C�Y�ō쐬
axes('Parent',gcf);																	
set(gca,'FontName','times','FontSize',12);											% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.109 0.668 0.812 0.259]);										% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
plot(result.prn{3}(:,1),result.prn{3}(:,2),'color','r');							% ���q�����̃v���b�g
plot(result.prn{3}(:,1),result.prn{3}(:,3),'color','b');							% �g�p�q�����̃v���b�g
ylabel('No. of Satellites');														% Y���̃��x��
mm = min(result.prn{3}(:,3));														% �g�p�q�����̍ŏ��l
nn = max(result.prn{3}(:,2));														% ���q�����̍ő�l
last = round(max(result.prn{3}(:,1))/dt)*dt;										% X���͈̔͂̍ő�l
if last<max(result.prn{3}(:,1)), last=max(result.prn{3}(:,1));, end					% X���͈̔͂̍ő�l
if result.prn{3}(1,1)>900
	xlim([result.prn{3}(1,1),last]);												% X���͈̔�
else
	xlim([0,last]);																	% X���͈̔�
end
ylim([mm-1,nn+2]);																	% Y���͈̔�
set(gca,'YTick',[mm-1:1:nn+2]);														% Y���̖ڐ���
set(gca,'XTick',[0:dt:last]);														% X���̖ڐ���
set(gca,'XTickLabel',{0:dt:last});													% X���̖ڐ���̃��x��
title(['Satellites',' : ',TT],'fontname','times','FontSize',16);					% �^�C�g��
legend({'Visible','Used'},'Orientation','horizontal');								% �}��
grid on
box on
set(gca,'FontName','times','FontSize',11);											% �t�H���g�̎�ށE�T�C�Y���w��

% �e�q���ɂ��Ă̕ω�
%--------------------------------------------
axes('Parent',gcf);																	
set(gca,'FontName','times','FontSize',12);											% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.109 0.087 0.812 0.539]);										% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
h1=plot(result.prn{3}(:,1),result.prn{1},'LineWidth',4,'color','r');				% ���q��PRN�̃v���b�g
h2=plot(result.prn{3}(:,1),result.prn{2},'LineWidth',4,'color','b');				% ���q��PRN�̃v���b�g
if size(result.prn,2)==4
	h3=plot(result.prn{3}(:,1),result.prn{4},'LineWidth',4,'color',[0,0.5,0]);		% ��q��PRN�̃v���b�g
end
xlabel('ToD [sec.]');																% X���̃��x��
ylabel('PRN')																		% Y���̃��x��
last = round(max(result.prn{3}(:,1))/dt)*dt;										% X���͈̔͂̍ő�l
if last<max(result.prn{3}(:,1)), last=max(result.prn{3}(:,1));, end					% X���͈̔͂̍ő�l
if result.prn{3}(1,1)>900
	xlim([result.prn{3}(1,1),last]);												% X���͈̔�
else
	xlim([0,last]);																	% X���͈̔�
end
ylim([0,32]);																		% Y���͈̔�
set(gca,'XTick',[0:dt:last]);														% X���̖ڐ���
set(gca,'XTickLabel',{0:dt:last});													% X���̖ڐ���̃��x��
set(gca,'ytick',[1:31]);															% X���̖ڐ���
set(gca,'YDir','reverse');															% X���̖ڐ���̔��]
grid on
box on
set(gca,'FontName','times','FontSize',11);											% �t�H���g�̎�ށE�T�C�Y���w��

if size(result.prn,2)==4
	legend([h1(1),h2(1),h3(1)],{'Visible','Used','Ref'},...
			'Orientation','horizontal','Location','SouthEast');						% �}��
else
	legend([h1(1),h2(1)],{'Visible','Used'},...
			'Orientation','horizontal','Location','SouthEast');						% �}��
end
