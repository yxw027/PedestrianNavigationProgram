function plot_rtk(result,result_test,est_prm)
%-------------------------------------------------------------------------------
% Function : ���Α��ʗp���茋�ʃv���b�g(ENU, 2D, 3D)
% 
% [argin]
% result  : ���茋�ʍ\����(*.{float/fix}.time:����, *.{float/fix}.pos:�ʒu)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% yl      : �v���b�g�͈�
% dt      : X���̖ڐ���Ԋu
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------
% 
% if nargin<4, dt=3600;, end


% �^�l����Ƃ����e�������̌덷
%--------------------------------------------
result1=result.spp;
result2=result.float;
result3=result.fix;

for k=1:length(result1.pos)
	result1.pos(k,7:9)=xyz2enu(result1.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
	result2.pos(k,7:9)=xyz2enu(result2.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
	result3.pos(k,7:9)=xyz2enu(result3.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
end


% �^�l����Ƃ����e�������̌덷
%--------------------------------------------
result_test1=result_test.spp;
result_test2=result_test.float;
result_test3=result_test.fix;

for k=1:length(result_test1.pos)
	result_test1.pos(k,7:9)=xyz2enu(result_test1.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
	result_test2.pos(k,7:9)=xyz2enu(result_test2.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
	result_test3.pos(k,7:9)=xyz2enu(result_test3.pos(k,1:3)',est_prm.rovpos);								% ENU�ɕϊ�
end


% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];


% % XYZ
% %--------------------------------------------
screen=get(0,'screensize');
% figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figure���w��ʒu�E�T�C�Y�ō쐬
% 
% % plot3(result1.pos(:,1), result1.pos(:,2), result1.pos(:,3),'g.')
% % hold on
% plot3(result2.pos(:,1), result2.pos(:,2), result2.pos(:,3),'b.')
% hold on
% plot3(result3.pos(:,1), result3.pos(:,2), result3.pos(:,3),'r*')
% grid on
% box on
% 
% xlim([min(result2.pos(:,1)),max(result2.pos(:,1))]);															% X���͈̔�
% set(gca,'XTick',[min(result2.pos(:,1)):1000:max(result2.pos(:,1))]);											% X���̖ڐ���
% ylim([min(result2.pos(:,2)),max(result2.pos(:,2))]);															% Y���͈̔�
% set(gca,'YTick',[min(result2.pos(:,2)):1000:max(result2.pos(:,2))]);											% Y���̖ڐ���
% zlim([min(result2.pos(:,3)),max(result2.pos(:,3))]);															% Z���͈̔�
% set(gca,'ZTick',[min(result2.pos(:,3)):1000:max(result2.pos(:,3))]);											% Z���̖ڐ���


% LLH
%--------------------------------------------
figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figure���w��ʒu�E�T�C�Y�ō쐬

% plot3(result1.pos(:,4), result1.pos(:,5), result1.pos(:,6),'g.')
% hold on
plot3(result2.pos(:,4), result2.pos(:,5), result2.pos(:,6),'b+')
hold on
plot3(result3.pos(:,4), result3.pos(:,5), result3.pos(:,6),'r+')
hold on
% plot3(result_test1.pos(:,7), result_test1.pos(:,8), result_test1.pos(:,9),'y.')
% hold on
plot3(result_test2.pos(:,4), result_test2.pos(:,5), result_test2.pos(:,6),'c+')
hold on
plot3(result_test3.pos(:,4), result_test3.pos(:,5), result_test3.pos(:,6),'m+')
grid on
box on

% xlim([30,40]);															% X���͈̔�
set(gca,'XTick',[min(result1.pos(:,4)):0.001:max(result1.pos(:,4))]);											% X���̖ڐ���
% ylim([135,136]);															% Y���͈̔�
set(gca,'YTick',[min(result1.pos(:,5)):0.001:max(result1.pos(:,5))]);											% Y���̖ڐ���
% zlim([175,180]);															% Z���͈̔�
set(gca,'ZTick',[min(result1.pos(:,6)):0.1:max(result1.pos(:,6))]);												% Z���̖ڐ���



% x,y�m�����\�����ԍ���
%--------------------------------------------
for i=1:length(result1.pos)
kyori(i,1)=norm(result2.pos(i,4:5));
kyori(i,2)=norm(result_test2.pos(i,4:5));
end
jikansa(:,1)=diff(kyori(:,1));
jikansa(:,2)=diff(kyori(:,2));
figure
plot(jikansa(:,1),'b')
hold on
plot(jikansa(:,2),'r')

bibun(:,1)=diff(kyori(:,1),2);
bibun(:,2)=diff(kyori(:,2),2);
figure
plot(bibun(:,1),'b')
hold on
plot(bibun(:,2),'r')



% �������m�����\�����ԍ���
%--------------------------------------------
for i=1:length(result1.pos)
kyori(i,3)=norm(result2.pos(i,6));
kyori(i,4)=norm(result_test2.pos(i,6));
end
jikansa(:,3)=diff(kyori(:,3));
jikansa(:,4)=diff(kyori(:,4));
figure
plot(jikansa(:,3),'b')
hold on
plot(jikansa(:,4),'r')

bibun(:,3)=diff(kyori(:,3),2);
bibun(:,4)=diff(kyori(:,4),2);
figure
plot(bibun(:,3),'b')
hold on
plot(bibun(:,4),'r')


% % x,y�e���������ԍ���
% %--------------------------------------------
% jikansa(:,5:6)=diff(result2.pos(:,1:2));
% figure
% plot(jikansa(:,5),'b')
% hold on
% plot(jikansa(:,6),'r')
% 
% bibun(:,5:6)=diff(result2.pos(:,1:2),2);
% bibun(:,7:8)=diff(result_test2.pos(:,1:2),2);
% figure
% plot(bibun(:,5:6),'b')
% hold on
% plot(bibun(:,7:8),'r')


% �����e���������ԍ���
%--------------------------------------------
figure
plot(result2.pos(:,6),'b.')
hold on
plot(result_test2.pos(:,6),'r.')




% % ENU
% %--------------------------------------------
% figure('Position',[(screen(3)-700)/2 (screen(4)-700)/2 700 700]);								% figure���w��ʒu�E�T�C�Y�ō쐬
% 
% plot3(result1.pos(:,7), result1.pos(:,8), result1.pos(:,9),'g.')
% hold on
% plot3(result2.pos(:,7), result2.pos(:,8), result2.pos(:,9),'b.')
% hold on
% plot3(result3.pos(:,7), result3.pos(:,8), result3.pos(:,9),'r*')
% grid on
% box on
% 
% xlim([min(result2.pos(:,7)),max(result2.pos(:,7))]);															% X���͈̔�
% set(gca,'XTick',[min(result2.pos(:,7)):1000:max(result2.pos(:,7))]);											% X���̖ڐ���
% ylim([min(result2.pos(:,8)),max(result2.pos(:,8))]);															% Y���͈̔�
% set(gca,'YTick',[min(result2.pos(:,8)):1000:max(result2.pos(:,8))]);											% Y���̖ڐ���
% zlim([min(result2.pos(:,9)),max(result2.pos(:,9))]);															% Z���͈̔�
% set(gca,'ZTick',[min(result2.pos(:,9)):1000:max(result2.pos(:,9))]);											% Z���̖ڐ���
% 
% title(['Position RTK',TT]);	% �^�C�g��
% 		title(['Position Error - Relative',' : ',TT,sprintf('  Fix rate: %3.f%%',fix_rate)]);	% �^�C�g��
% 	legend({'Float','Fix'});																	% �}��



