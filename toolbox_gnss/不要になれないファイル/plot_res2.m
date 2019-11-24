function plot_res2(res,OBS,est_prm,yl)
%-------------------------------------------------------------------------------
% Function : �c���v���b�g
% 
% [argin]
% res     : �c��(�\����; *.time:����, *.data:�c��)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% yl      : Y���͈̔�
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


% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');

% �c���̃v���b�g
%--------------------------------------------
for j=1:size(res.data,1)
	figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);					% figure���w��ʒu�E�T�C�Y�ō쐬
	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);											% �t�H���g�̎�ށE�T�C�Y���w��
% 	set(gca,'Position',[0.109 0.171 0.812 0.669]);										% axes���w��ʒu�E�T�C�Y�ō쐬
	set(gca,'Position',[0.109 0.55 0.812 0.35]);											% axes���w��ʒu�E�T�C�Y�ō쐬
	hold on
	for k=1:size(res.data,2)
		for i=1:31
			plot(OBS.ele(:,i)*180/pi,res.data{j,k}(:,i),'.');							% �c���̃v���b�g
		end
	end
	grid on
	box on
	last = 90;																			% X���͈͂̍ő�l
	xlim([0,last]);																		% X���͈̔�
	ylim([-yl,yl]);																		% Y���͈̔�
	set(gca,'XTick',[0:10:last]);														% X���̖ڐ���
	set(gca,'XTickLabel',{0:10:last});													% X���ڐ���̃��x��
	set(gca,'YTick',[-yl:yl/5:yl]);														% Y���̖ڐ���
	xlabel('Elevation [deg.]');															% X���̃��x��
	ylabel('Residual [m]');																% Y���̃��x��
	title(['Residual',' : ',TT]);														% �^�C�g��

	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);											% �t�H���g�̎�ށE�T�C�Y���w��
% 	set(gca,'Position',[0.109 0.171 0.812 0.669]);										% axes���w��ʒu�E�T�C�Y�ō쐬
	set(gca,'Position',[0.109 0.113 0.812 0.35]);											% axes���w��ʒu�E�T�C�Y�ō쐬
	hold on
	for k=1:size(res.data,2)
		for i=1:31
			plot(OBS.azi(:,i)*180/pi,res.data{j,k}(:,i),'.');							% �c���̃v���b�g
		end
	end
	grid on
	box on
	last = 180;																			% X���͈͂̍ő�l
	xlim([-last,last]);																	% X���͈̔�
	ylim([-yl,yl]);																		% Y���͈̔�
	set(gca,'XTick',[-last:30:last]);													% X���̖ڐ���
	set(gca,'XTickLabel',{-last:30:last});												% X���ڐ���̃��x��
	set(gca,'YTick',[-yl:yl/5:yl]);														% Y���̖ڐ���
	xlabel('Azimuth [deg.]');															% X���̃��x��
	ylabel('Residual [m]');																% Y���̃��x��
% 	title(['Residual',' : ',TT]);														% �^�C�g��
end
