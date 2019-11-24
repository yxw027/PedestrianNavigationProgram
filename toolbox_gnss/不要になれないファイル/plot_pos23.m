function plot_pos23(result,est_prm,yl,dt)
%-------------------------------------------------------------------------------
% Function : ���Α��ʗp���茋�ʃv���b�g(ENU, 2D, 3D) Float, Fix�̌���
% 
% [argin]
% result  : ���茋�ʍ\����(*.{float/fix}.time:����, *.{float/fix}.pos:�ʒu)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% yl      : �v���b�g�͈�
% dt      : X���̖ڐ���Ԋu
% 
% [argout]
% 
% ���v�ʂ�Fix���𗘗p
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<4, dt=3600;, end

% Float����Fix��
%--------------------------------------------
result1=result.float;
result2=result.fix;

% Float����Fix��������
%--------------------------------------------
result3.pos=result.fix.pos;
index_float=find(isnan(result3.pos(:,1)));
index_fix=find(~isnan(result3.pos(:,1)));
result3.pos(index_float,1:3)=result1.pos(index_float,1:3);


% �^�l����Ƃ����e�������̌덷
%--------------------------------------------
for k=1:length(result1.pos)
	result1.pos(k,1:3)=xyz2enu(result1.pos(k,1:3)',est_prm.rovpos);									% ENU�ɕϊ�
	result2.pos(k,1:3)=xyz2enu(result2.pos(k,1:3)',est_prm.rovpos);									% ENU�ɕϊ�
	result3.pos(k,1:3)=xyz2enu(result3.pos(k,1:3)',est_prm.rovpos);									% ENU�ɕϊ�
end
for n=1:3
	heikin1(n) = mean(result1.pos(find(~isnan(result1.pos(:,n))),n));								% ����(Float��)
	stdd1(n) = std(result1.pos(find(~isnan(result1.pos(:,n))),n));									% �W���΍�(Float��)
	rms1(n)=sqrt(mean(result1.pos(find(~isnan(result1.pos(:,n))),n).^2));							% RMS(Float��)
	heikin2(n) = mean(result2.pos(find(~isnan(result2.pos(:,n))),n));								% ����(Fix��)
	stdd2(n) = std(result2.pos(find(~isnan(result2.pos(:,n))),n));									% �W���΍�(Fix��)
	rms2(n)=sqrt(mean(result2.pos(find(~isnan(result2.pos(:,n))),n).^2));							% RMS(Fix��)
	heikin3(n) = mean(result3.pos(find(~isnan(result3.pos(:,n))),n));								% ����(������)
	stdd3(n) = std(result3.pos(find(~isnan(result3.pos(:,n))),n));									% �W���΍�(������)
	rms3(n)=sqrt(mean(result3.pos(find(~isnan(result3.pos(:,n))),n).^2));							% RMS(������)
end

fix_rate=length(find(~isnan(result2.pos(:,1))))/length(result2.pos)*100;							% Fix��

baseline=norm(est_prm.rovpos-est_prm.refpos)/1e+3;													% �����

% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');


% ENU(�ʁX)
%--------------------------------------------
Yn={'East [m]','North [m]','Up [m]'};
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);									% figure���w��ʒu�E�T�C�Y�ō쐬
for n=1:3
	axes('Parent',gcf);
	set(gca,'FontName','times','FontSize',16);														% �t�H���g�̎�ށE�T�C�Y���w��
	if n==1
		set(gca,'Position',[0.109 0.668 0.812 0.259]);												% axes���w��ʒu�E�T�C�Y�ō쐬
	elseif n==2
		set(gca,'Position',[0.109 0.387 0.812 0.259]);												% axes���w��ʒu�E�T�C�Y�ō쐬
	elseif n==3
		set(gca,'Position',[0.109 0.107 0.812 0.259]);												% axes���w��ʒu�E�T�C�Y�ō쐬
	end
	hold on
% 	plot(result1.time(:,4),result1.pos(:,n),'.-r');
% 	plot(result1.time(:,4),result2.pos(:,n),'.-b');
	h1=plot(result1.time(:,4),result3.pos(:,n),'-','Color',[0.5,0.5,0.5]);							% ���C���v���b�g
	h2=plot(result1.time(index_float,4),result3.pos(index_float,n),'.r');							% Float���̓_�v���b�g
	h3=plot(result1.time(index_fix,4),result3.pos(index_fix,n),'.b');								% Fix���̓_�v���b�g
	grid on
	box on
	last = round(max(result1.time(:,4))/dt)*dt;														% X���͈͂̍ő�l
	if last<max(result1.time(:,4)), last=max(result1.time(:,4));, end								% X���͈͂̍ő�l
	if result1.time(1,4)>900
		xlim([result1.time(1,4),last]);																% X���͈̔�
	else
		xlim([0,last]);																				% X���͈̔�
	end
	ylim([-yl,yl]);																					% Y���͈̔�
	if n<3
		set(gca,'XTick',[0:dt:last]);																% X���̖ڐ���
		set(gca,'XTickLabel','');																	% X���̖ڐ���̃��x��
	else
		set(gca,'XTick',[0:dt:last]);																% X���̖ڐ���
		set(gca,'XTickLabel',{0:dt:last});															% X���̖ڐ���̃��x��
		xlabel('ToD [sec.]');																		% X���̃��x��
	end
	set(gca,'YTick',[-yl:yl/5:yl]);																	% Y���̖ڐ���
	ylabel(Yn{n});																					% Y���̖ڐ���
	if n==1
		title(['Position Error - Relative',' : ',TT,...
				sprintf('  BL: %5.1f[km]',baseline),sprintf('  Fix rate: %3.1f[%%]',fix_rate)]);	% �^�C�g��
	end
	legend([h2,h3],{'Float','Fix'});																% �}��

% 	text(result2.time(1,4)+abs(result2.time(1,4)-last)*0.99,-yl*0.82,...
% 			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin2(n),stdd2(n),rms2(n)),...
% 			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
% 			'Color','b','HorizontalAlignment','right');		% ��:[0.000 0.500 0.000]
% 	text(result1.time(1,4)+abs(result1.time(1,4)-last)*0.99,-yl*0.62,...
% 			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin1(n),stdd1(n),rms1(n)),...
% 			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
% 			'Color','r','HorizontalAlignment','right');		% ��:[0.000 0.500 0.000]
	text(result1.time(1,4)+abs(result1.time(1,4)-last)*0.99,-yl*0.82,...
			sprintf('MEAN:%7.4f[m]  STD:%7.4f[m]  RMS:%7.4f[m]',heikin2(n),stdd2(n),rms2(n)),...
			'FontName','times','FontSize',14,'FontWeight','normal','BackgroundColor','w',...
			'Color','k','HorizontalAlignment','right');												% ����, �W���΍�, RMS
end

% 2D + UP
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);									% figure���w��ʒu�E�T�C�Y�ō쐬
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);															% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.124 0.176 0.494 0.669]);														% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
% plot(result1.pos(:,1),result1.pos(:,2),'.r')
% plot(result2.pos(:,1),result2.pos(:,2),'.b')
h4=plot(result3.pos(:,1),result3.pos(:,2),'-','Color',[0.5,0.5,0.5]);								% ���C���v���b�g
h5=plot(result3.pos(index_float,1),result3.pos(index_float,2),'.r');								% Float���̓_�v���b�g
h6=plot(result3.pos(index_fix,1),result3.pos(index_fix,2),'.b');									% Fix���̓_�v���b�g
line([-10 10],[0 0],'Color','k');																	% ���C��
line([0 0],[-10 10],'Color','k');																	% ���C��
grid on
box on
axis square
xlim([-yl,yl]);																						% X���͈̔�
ylim([-yl,yl]);																						% Y���͈̔�
set(gca,'XTick',[-yl:yl/5:yl]);																		% X���̖ڐ���
set(gca,'YTick',[-yl:yl/5:yl]);																		% Y���̖ڐ���
xlabel('East Error [m]');																			% X���̃��x��
ylabel('North Error [m]');																			% Y���̃��x��

title('Horizontal Error - Relative');																% �^�C�g��
legend([h5,h6],{'Float','Fix'});																	% �}��
%
%
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);															% figure���w��ʒu�E�T�C�Y�ō쐬
set(gca,'Position',[0.689 0.176 0.198 0.669]);														% �t�H���g�̎�ށE�T�C�Y���w��
hold on
plot(result1.time(index_float,4)*0,result3.pos(index_float,3),'.r');								% Float���̓_�v���b�g
plot(result1.time(index_fix,4)*0,result3.pos(index_fix,3),'.b');									% Fix���̓_�v���b�g
line([-10 10],[0 0],'Color','k');																	% ���C��
line([0 0],[-10 10],'Color','k');																	% ���C��
grid on
box on
xlim([-1,1]);																						% X���͈̔�
ylim([-yl,yl]);																						% Y���͈̔�
set(gca,'YTick',[-yl:yl/5:yl]);																		% Y���̖ڐ���

title('Up Error - Relative');																		% �^�C�g��
legend({'Float','Fix'});																			% �}��
