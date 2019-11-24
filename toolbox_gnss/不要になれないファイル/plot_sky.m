function plot_sky2(OBS,result,est_prm)
%-------------------------------------------------------------------------------
% Function : Sky Plot
% 
% [argin]
% OBS     : �ϑ��f�[�^�\����(��: OBS.rov, OBS.ref)
%            **.ele : �p(�s:�G�|�b�N, ��:PRN)
%            **.azi : ���ʊp(�s:�G�|�b�N, ��:PRN)
% result  : ���茋�ʂ̍\����(��: Result.spp; �g�p����͉̂��L�̃t�B�[���h����)
%           �q���֘A�̍\����(result.prn)
%            (�Z���z�� 1: ���q��, 2: �g�p�q��, 3: �q�����Ȃ�(tod,all,used,dop), 4: ��q��)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 18, 2008
%-------------------------------------------------------------------------------

ele=OBS.ele;		% �p
azi=OBS.azi;		% ���ʊp

% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');

% Sky Plot
%--------------------------------------------
figure('Position',[(screen(3)-900)/2 (screen(4)-700)/2 900 700]);						% figure���w��ʒu�E�T�C�Y�ō쐬
axes('Parent',gcf);
set(gca,'FontName','times','FontSize',16);												% �t�H���g�̎�ށE�T�C�Y���w��
set(gca,'Position',[0.109 0.087 0.812 0.812]);											% axes���w��ʒu�E�T�C�Y�ō쐬
hold on
axis equal
% axis([-110 110 -110 110]);
axis([-95 95 -95 95]);
axis off
patch(90*sin(0:pi/36:2*pi),90*cos(0:pi/36:2*pi),'w','linestyle','none');				% �~�̍쐬(�w�i�͔�)

ele = ele*180/pi;
xpol = (90-ele).*sin(azi);																% X�̒l(sin�ɋp, ���ʊp�𗘗p)
ypol = (90-ele).*cos(azi);																% Y�̒l(cos�ɋp, ���ʊp�𗘗p)
pol = plot(xpol,ypol,'Color',[1,0.0,0],'LineWidth',2);									% skyplot(���q��)

xpol_use=xpol.*(result.prn{2}./result.prn{2});											% X�̒l(�g�p�q���̒��o)
ypol_use=ypol.*(result.prn{2}./result.prn{2});											% Y�̒l(�g�p�q���̒��o)
pol_use = plot(xpol_use,ypol_use,'Color',[0,0.0,1],'LineWidth',2);						% skyplot(�g�p�q��)

if size(result.prn,2)==4
xpol_ref=xpol.*(result.prn{4}./result.prn{4});											% X�̒l(��q���̒��o)
ypol_ref=ypol.*(result.prn{4}./result.prn{4});											% Y�̒l(��q���̒��o)
pol_ref = plot(xpol_ref,ypol_ref,'Color',[0,0.5,0],'LineWidth',2);						% skyplot(��q��)
end

% ���ʊp�̖ڐ���
%--------------------------------------------
label='NESW';
for k=0:30:330
	plot([0 90*sin(k*pi/180)],[0 90*cos(k*pi/180)],'Color','k','LineStyle',':');		% 30�x���Ƃɐ��v���b�g
	if mod(k,90)==0
		str=label(k/90+1);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,...
				'horizontal','center','FontSize',16,'FontWeight','bold');				% 90�x���Ƃɖڐ���(����)
	else
		str=num2str(k);
		text(95*sin(k*pi/180),95*cos(k*pi/180),str,...
				'horizontal','center','FontSize',12,'FontWeight','demi');				% 30�x���Ƃɖڐ���(����)
	end
end

% �p�̖ڐ���
%--------------------------------------------
for k=1:6
	if k~=6
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),...
				'LineStyle',':','LineWidth',0.1,'Color','k');							% 15�x���Ƃɓ_���v���b�g
	else
		line(15*k*cos(0:0.001:2*pi),15*k*sin(0:0.001:2*pi),...
				'LineStyle','-','LineWidth',0.1,'Color','k');							% �Ō�͐��v���b�g
	end
end
line((90-est_prm.mask)*cos(0:0.001:2*pi),(90-est_prm.mask)*sin(0:0.001:2*pi),...
			'LineStyle',':','LineWidth',0.1,'Color','r');								% �p�}�X�N�ɐԓ_���v���b�g
for k=0:30:90
	text(0,k,num2str(90-k),'HorizontalAlignment','center',...
			'FontSize',12,'FontWeight','demi','Color','k');								% 30�x���Ƃɖڐ���
end
text(0,90-est_prm.mask,int2str(est_prm.mask),'HorizontalAlignment','center',...
		'FontSize',12,'FontWeight','demi','Color','r');									% �p�}�X�N�̖ڐ���

title(['Sky Plot',' : ',TT],'fontname','times','FontSize',16);							% �^�C�g��
set(gca,'FontName','times');															% �t�H���g�̎�ނ��w��

% �q���ԍ��\������(�q���z�u�O���t�p)
%--------------------------------------------
inde(1:31)=NaN;
for i=1:31
% 	indm=min(find(~isnan(ele(:,i))));
	indm=max(find(~isnan(ele(:,i))));
	if ~isempty(indm)
		inde(i)=indm;
		text(xpol(indm,i),ypol(indm,i),['PRN',num2str(i)],...
				'FontSize',10,'horizontal','center','vertical','top');
	end
end
