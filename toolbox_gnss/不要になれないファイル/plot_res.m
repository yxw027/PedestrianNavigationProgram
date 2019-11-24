function plot_res(res,est_prm,dt,yl)
%-------------------------------------------------------------------------------
% Function : �c���v���b�g
% 
% [argin]
% res     : �c��(�\����; *.time:����, *.data:�c��)
% est_prm : �p�����[�^�ݒ�l(���莞��, �^�l�Ȃǂ𗘗p)
% dt      : X���̖ڐ���Ԋu
% yl      : Y���͈̔�
% 
% [argout]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Oct. 14, 2008
%-------------------------------------------------------------------------------

if nargin<3, dt=3600;, end

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
	set(gca,'Position',[0.109 0.171 0.812 0.669]);										% axes���w��ʒu�E�T�C�Y�ō쐬
	hold on
	for k=1:size(res.data,2)
		plot(res.time(:,4),res.data{j,k},'.-');											% �c���̃v���b�g
	end
	grid on
	box on
	last = round(max(res.time(:,4))/dt)*dt;												% X���͈͂̍ő�l
	if last<max(res.time(:,4)), last=max(res.time(:,4));, end							% X���͈͂̍ő�l
	if res.time(1,4)>900
		xlim([res.time(1,4),last]);														% X���͈̔�
	else
		xlim([0,last]);																	% X���͈̔�
	end
	ylim([-yl,yl]);																		% Y���͈̔�
	set(gca,'XTick',[0:dt:last]);														% X���̖ڐ���
	set(gca,'XTickLabel',{0:dt:last});													% X���ڐ���̃��x��
	set(gca,'YTick',[-yl:yl/5:yl]);														% Y���̖ڐ���
	xlabel('ToD [sec.]');																% X���̃��x��
	ylabel('Residual [m]');																% Y���̃��x��
	title(['Residual',' : ',TT]);														% �^�C�g��
end
