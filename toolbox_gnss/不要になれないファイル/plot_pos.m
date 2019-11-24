function plot_pos(result,est_prm,mode,yl,dt)
%-------------------------------------------------------------------------------
% Function : ���茋�ʃv���b�g(ENU, 2D, 3D)
% 
% [argin]
% result  : ���茋�ʍ\����(*.time:����, *.pos:�ʒu)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% mode    : ���ʕ��@(1:SPP,2:PPP,3:DGPS,4:Relative(Float),5:Relative(Fix),6:VPPP)
% yl      : �v���b�g�͈�
% dt      : X���̖ڐ���Ԋu
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<4, yl=10;, dt=3600;, end
if nargin<5, dt=3600;, end

mode_name={'SPP','PPP','DGPS','Relative(Float)','Relative(Fix)','VPPP'};


% �^�l����Ƃ����e�������̌덷
%--------------------------------------------
for k=1:length(result.pos)
	result.pos(k,1:3)=xyz2enu(result.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
end
for n=1:3
	heikin(n) = mean(result.pos(find(~isnan(result.pos(:,n))),n));								% ����
	stdd(n) = std(result.pos(find(~isnan(result.pos(:,n))),n));									% �W���΍�
	rms(n)=sqrt(mean(result.pos(find(~isnan(result.pos(:,n))),n).^2));							% RMS
end

% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');

% ENU
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figure���w��ʒu�E�T�C�Y�ō쐬
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.109 0.171 0.812 0.669]);													% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
plot(result.time(:,4),result.pos(:,1:3),'.-');													% �v���b�g
grid on
box on
last = round(max(result.time(:,4))/dt)*dt;														% X���͈͂̍ő�l
if last<max(result.time(:,4)), last=max(result.time(:,4));, end									% X���͈͂̍ő�l
if result.time(1,4)>900
	xlim([result.time(1,4),last]);																% X���͈̔�
else
	xlim([0,last]);																				% X���͈̔�
end
ylim([-yl,yl]);																					% Y���͈̔�
set(gca,'XTick',[0:dt:last]);																	% X���̖ڐ���
set(gca,'XTickLabel',{0:dt:last});																% X���̖ڐ���̃��x��
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y���̖ڐ���
xlabel('ToD [sec.]');																			% X���̃��x��
ylabel('Position Error [m]');																	% Y���̃��x��
title(['Position Error - ',mode_name{mode},' : ',TT]);											% �^�C�g��
legend({'East','North','Up'});																	% �}��

text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.93,...
		sprintf('RMS:   E:%7.4f[m]  N:%7.4f[m]  U:%7.4f[m]',rms),...
		'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
		'Color','k','HorizontalAlignment','right');												% RMS
text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.84,...
		sprintf('STD:   E:%7.4f[m]  N:%7.4f[m]  U:%7.4f[m]',stdd),...
		'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
		'Color','k','HorizontalAlignment','right');												% �W���΍�
text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.75,...
		sprintf('MEAN:   E:%7.4f[m]  N:%7.4f[m]  U:%7.4f[m]',heikin),...
		'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
		'Color','k','HorizontalAlignment','right');												% ����



% 2D + UP
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figure���w��ʒu�E�T�C�Y�ō쐬
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.124 0.176 0.494 0.669]);													% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
plot(result.pos(:,1),result.pos(:,2),'.');														% �v���b�g
line([-10 10],[0 0],'Color','k');																% ���C��
line([0 0],[-10 10],'Color','k');																% ���C��
grid on
box on
axis square
xlim([-yl,yl]);																					% X���͈̔�
ylim([-yl,yl]);																					% Y���͈̔�
set(gca,'XTick',[-yl:yl/5:yl]);																	% X���̖ڐ���
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y���̖ڐ���
xlabel('East Error [m]');																		% X���̃��x��
ylabel('North Error [m]');																		% Y���̃��x��
title(['Horizontal Error - ',mode_name{mode},' : ',TT]);										% �^�C�g��
%
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);														% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.689 0.176 0.198 0.669]);													% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
plot(result.time(:,4)*0,result.pos(:,3),'.');													% �v���b�g
line([-10 10],[0 0],'Color','k');																% ���C��
line([0 0],[-10 10],'Color','k');																% ���C��
grid on
box on
xlim([-1,1]);																					% X���͈̔�
ylim([-yl,yl]);																					% Y���͈̔�
set(gca,'YTick',[-yl:yl/5:yl]);																	% Y���̖ڐ���
title(['Up Error - ',mode_name{mode}]);															% �^�C�g��


% % 2D + 3D
% %--------------------------------------------
% if 0
% 	figure
% 	subplot(1,2,[1])
% 	set(gca,'FontName','times','FontSize',16);
% 	hold on
% 	plot(result(:,2),result(:,3),'.')
% 	line([-10 10],[0 0],'Color','k');
% 	line([0 0],[-10 10],'Color','k');
% 	grid on
% 	box on
% 	axis square
% 	xlim([-yl,yl]);
% 	ylim([-yl,yl]);
% 	xlabel('East Error [m]');
% 	ylabel('North Error [m]');
% 
% 	if mode == 0
% 		title('Horizontal Error - SPP')
% 	elseif mode == 1
% 		title('Horizontal Error - PPP')
% 	elseif mode == 2
% 		title('Horizontal Error - Relative')
% 	elseif mode == 3
% 		title('Horizontal Error - VPPP')
% 	end
% 	%
% 	subplot(1,2,2)
% 	set(gca,'FontName','times','FontSize',16);
% 	hold on
% 	plot3(result(:,2),result(:,3),result(:,4),'.-')
% 	% line([-10 10],[0 0],[0 0],'Color','k');
% 	% line([0 0],[-10 10],[0 0],'Color','k');
% 	% line([0 0],[0 0],[-10 10],'Color','k');
% 	grid on
% 	box on
% 	axis square
% 	view([-30,25])
% 	xlim([-yl,yl]);
% 	ylim([-yl,yl]);
% 	zlim([-yl,yl]);
% 
% 	if mode == 0
% 		title('3D Error - SPP')
% 	elseif mode == 1
% 		title('3D Error - PPP')
% 	elseif mode == 2
% 		title('3D Error - Relative')
% 	elseif mode == 3
% 		title('3D Error - VPPP')
% 	end
% end


% ENU(�ʁX)
%--------------------------------------------
Yn={'East [m]','North [m]','Up [m]'};
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);								% figure���w��ʒu�E�T�C�Y�ō쐬
for n=1:3
	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);													% �t�H���g�̎�ށE�T�C�Y���w��
	if n==1
		set(gca,'Position',[0.109 0.668 0.812 0.259]);											% axes���w��ʒu�E�T�C�Y�ō쐬
	elseif n==2
		set(gca,'Position',[0.109 0.387 0.812 0.259]);											% axes���w��ʒu�E�T�C�Y�ō쐬
	elseif n==3
		set(gca,'Position',[0.109 0.107 0.812 0.259]);											% axes���w��ʒu�E�T�C�Y�ō쐬
	end
	hold on
	plot(result.time(:,4),result.pos(:,n),'.-');												% �v���b�g
	grid on
	box on
	last = round(max(result.time(:,4))/dt)*dt;													% X���͈͂̍ő�l
	if last<max(result.time(:,4)), last=max(result.time(:,4));, end								% X���͈͂̍ő�l
	if result.time(1,4)>900
		xlim([result.time(1,4),last]);															% X���͈̔�
	else
		xlim([0,last]);																			% X���͈̔�
	end
	ylim([-yl,yl]);																				% Y���͈̔�
	if n<3
		set(gca,'XTick',[0:dt:last]);															% X���̖ڐ���
		set(gca,'XTickLabel','');																% X���̖ڐ���̃��x��
	else
		set(gca,'XTick',[0:dt:last]);															% X���̖ڐ���
		set(gca,'XTickLabel',{0:dt:last});														% X���̖ڐ���̃��x��
		xlabel('ToD [sec.]');																	% X���̃��x��
	end
	set(gca,'YTick',[-yl:yl/5:yl]);																% Y���̖ڐ���
	ylabel(Yn{n});																				% Y���̃��x��
	if n==1
		title(['Position Error - ',mode_name{mode},' : ',TT]);									% �^�C�g��
	end

	text(result.time(1,4)+abs(result.time(1,4)-last)*0.99,-yl*0.79,...
			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin(n),stdd(n),rms(n)),...
			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
			'Color','k','HorizontalAlignment','right');											% ����, �W���΍�, RMS
end
