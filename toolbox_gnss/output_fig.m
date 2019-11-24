function output_fig(fname,mode,handle)
%-------------------------------------------------------------------------------
% Function : figure�̃t�@�C���o�͊֐��E�E�EEPS,TIFF,EMF�ŕۑ�
%
% [argin]
% fname   : �o�̓t�@�C����
% mode    : �o�̓T�C�Y�ݒ�(0:�c�J�X�^��, 1:�c�t��, 2:���t��, 3:���t��+)
% handles : figure�̃n���h��
%
% [argout]
%
% �� mode�� "3" ����������---����̂��Ƃ��l�����Ă��邩��
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 31, 2007
%-------------------------------------------------------------------------------

if nargin<3, handle=get(0,'CurrentFigure');, end

set(handle, 'PaperPositionMode', 'manual');
set(handle, 'PaperUnits', 'centimeters');
if mode == 0
	set(handle, 'PaperPosition', [0 0 21 15]);
	set(handle, 'PaperOrientation', 'portrait');		% portrait:�c  landscape:��
elseif mode==1
	set(handle, 'PaperPosition', [0 0 21 29.68]);		% �t���T�C�Y(portrait:�c)
	set(handle, 'PaperOrientation', 'portrait');		% portrait:�c  landscape:��
elseif mode==2
	set(handle, 'PaperPosition', [0 0 29.68 21]);		% �t���T�C�Y(landscape:��)
	set(handle, 'PaperOrientation', 'landscape');		% portrait:�c  landscape:��
elseif mode==3
	set(handle, 'PaperPosition', [0 0 29.68 21]);		% �t���T�C�Y(landscape:��)
	set(handle, 'PaperOrientation', 'portrait');		% portrait:�c  landscape:��
end

set(handle, 'Renderer', 'painters');					% �����_�����O�@

set(gca, 'xtickmode','manual');							% ���W���͈̔͂Ɩڐ�(�X�N���[���Ɠ���)
set(gca, 'ytickmode','manual');							% ���W���͈̔͂Ɩڐ�(�X�N���[���Ɠ���)
set(gca, 'ztickmode','manual');							% ���W���͈̔͂Ɩڐ�(�X�N���[���Ɠ���)

print(handle,'-r300','-depsc2',fname)					% EPS Level2 Color
% print(handle,'-r300','-dtiff',fname)					% TIFF
print(handle,'-dmeta',fname)							% EMF

if mode==3
	set(handle, 'PaperOrientation', 'landscape');		% portrait:�c  landscape:��
end
saveas(handle,fname,'fig')								% figure�̕ۑ�