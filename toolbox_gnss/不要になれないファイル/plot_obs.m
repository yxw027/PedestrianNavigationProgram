function plot_obs(OBS,dtr_all,est_prm,prn,dt)
%-------------------------------------------------------------------------------
% Function : �ϑ��f�[�^�v���b�g(�␳�O�ƕ␳��̔�r)
% 
% [argin]
% OBS         : �ϑ��f�[�^�\����(*.time:����, *.{ca,py,ph1,ph2,etc}:�ϑ��f�[�^)
% dtr_all     : ��M�@���v�덷(1:�␳�O,2:�␳��)
% est_prm     : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% prn         : �q��PRN�ԍ�
% dt          : X���̖ڐ���Ԋu
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<5, dt=3600;, end

% ����J�n�E�I������
%--------------------------------------------
TT=[datestr(datenum(est_prm.stime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS'),' - ',...
	datestr(datenum(est_prm.etime,'yyyy/mm/dd/HH/MM/SS'),'yyyy/mm/dd HH:MM:SS')];

% �X�N���[���T�C�Y�擾
%--------------------------------------------
screen=get(0,'screensize');

pt=round(length(OBS.time)/180);				% �v���b�g�Ԋu(�Ԉ�������)

% 1:OBS(raw,corrected), 2:clock error(raw,corrected)
%--------------------------------------------
Yn={'CA [m]','PY [m]','L1 [cycle]','L2 [cycle]'};
field1={'ca','py','ph1','ph2'};
field2={'ca_cor','py_cor','ph1_cor','ph2_cor'};
for m=1:4
	ax=[];
	figure('Position',[(screen(3)-900)/2 (screen(4)-600)/2 900 600]);					% figure���w��ʒu�E�T�C�Y�ō쐬
	for n=1:2
		ax(n)=axes('Parent',gcf);
		set(gca,'FontName','times','FontSize',16);										% �t�H���g�̎�ށE�T�C�Y���w��
		if n==1
			set(gca,'Position',[0.109 0.387 0.812 0.259*2+0.022]);						% axes���w��ʒu�E�T�C�Y�ō쐬
		elseif n==2
			set(gca,'Position',[0.109 0.107 0.812 0.259]);								% axes���w��ʒu�E�T�C�Y�ō쐬
		end
		hold on
		if n==1
			plot(OBS.time(:,4),OBS.(field1{m})(:,prn),'.-','Color',[0.7,0.7,0.7]);		% OBS(raw)�̃v���b�g
			plot(OBS.time(1:pt:end,4),OBS.(field2{m})(1:pt:end,prn),'.-b');				% OBS(corrected)�̃v���b�g
		elseif n==2
			plot(OBS.time(:,4),dtr_all(:,1),'.-','Color',[0.7,0.7,0.7]);				% clock error(raw)�̃v���b�g
			plot(OBS.time(1:pt:end,4),dtr_all(1:pt:end,2),'.-b');						% clock error(corrected)�̃v���b�g
		end
		grid on
		box on
		last = round(max(OBS.time(:,4))/dt)*dt;											% X���͈͂̍ő�l
		if last<max(OBS.time(:,4)), last=max(OBS.time(:,4));, end						% X���͈͂̍ő�l
		if OBS.time(1,4)>900
			xlim([OBS.time(1,4),last]);													% X���͈̔�
		else
			xlim([0,last]);																% X���͈̔�
		end
	% 	ylim([-yl,yl]);																	% Y���͈̔�
		if n<2
			set(gca,'XTick',[0:dt:last]);												% X���̖ڐ���
			set(gca,'XTickLabel','');													% X���̖ڐ���̃��x��
		else
			set(gca,'XTick',[0:dt:last]);												% X���̖ڐ���
			set(gca,'XTickLabel',{0:dt:last});											% X���̖ڐ���̃��x��
			xlabel('ToD [sec.]');														% X���̃��x��
		end
% 		set(gca,'YTick',[-yl:yl/5:yl]);													% Y���̖ڐ���
		if n==1
			ylabel(Yn{m});																% Y���̃��x��
			title(['Observation Data ',sprintf('(PRN%02d)',prn),' : ',TT]);				% �^�C�g��
			legend({'Raw','Corrected'});												% �}��
		else
			ylabel('clock error [sec]');												% Y���̃��x��
		end
	end
% 	linkaxes(ax,'x');
end