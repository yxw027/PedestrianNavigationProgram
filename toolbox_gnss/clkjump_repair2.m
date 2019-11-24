function [data,dtr,ttime,clk_jump,dtr_o,jump_width_all]=clkjump_repair2(ttime,data,dtr,dtr_o,jump_width_all,Rec_type)
%-------------------------------------------------------------------------------
% Function : clock jump �̌��o�E�C��
%--------------------------------------------
% |dtr�̃G�|�b�N�ԍ�| > 0.5ms �� ��тƔ���
% dtr�̃G�|�b�N�ԍ����ѕ��Ƃ�ms�P�ʂɊۂ߂�
% ����, �ϑ��f�[�^, dtr �����ѕ������Z
%--------------------------------------------
% 
% [argin]
% ttime          : �␳�O����(year month day hour minute sec)
% data           : �␳�O�ϑ��f�[�^
% dtr            : �P�Ƒ��ʂŋ��߂���M�@���v�덷(���G�|�b�N)
% dtr_o          : �P�Ƒ��ʂŋ��߂���M�@���v�덷(�O�G�|�b�N)
% jump_width_all : �W�����v���̗ݐϒl[sec]
% Rec_type       : ��M�@�^�C�v
% 
% [argout]
% data           : �␳�ς݊ϑ��f�[�^
% dtr            : �␳�ςݎ�M�@���v�덷
% ttime          : �␳�ςݎ���(year month day hour minute sec)
% clk_jump       : �W�����v�t���O
% dtr_o          : �P�Ƒ��ʂŋ��߂���M�@���v�덷(���G�|�b�N) --- ���̃G�|�b�N�p
% jump_width_all : �W�����v���̗ݐϒl[sec]
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 03, 2008
%-------------------------------------------------------------------------------

% �萔(�O���[�o���ϐ�)
%--------------------------------------------
% global C f1 f2 lam1 lam2 OMGE MUe FF

%--- �萔
%--------------------------------------------
C=299792458;							% ����
f1=1.57542e9;  lam1=C/f1;				% L1 ���g�� & �g��
f2=1.22760e9;  lam2=C/f2;				% L2 ���g�� & �g��

OMGE=7.2921151467e-5;					% WGS-84 �̗p�n����]�p���x [rad/s]
MUe=3.986005e14;						% WGS-84 �̒n�S�d�͒萔 [m^3s^{-2}]
FF=-4.442807633e-10;					% ���Θ_�Ɋւ���덷�␳�W��

% clock jump �̌��o
%--------------------------------------------
clk_jump = 0;											% jump flag
if isempty(dtr_o)										% 1�G�|�b�N��
	jump_width_all = 0;									% �W�����v���̗ݐϒl�̏����l
else													% 2�G�|�b�N�ȍ~
	dtr_td = (dtr - dtr_o)*(1e+3);						% ��M�@���v�덷�̃G�|�b�N�ԍ�(msec)
	if abs(dtr_td) > 0.5								% �W�����v���o(�G�|�b�N�ԍ���Βl��0.5msec�ȏ�)
		clk_jump = 1;									% �W�����v�t���O
		jump_width = round(dtr_td(end,1))*(1e-3);		% �W�����v��(sec)
		jump_width_all = jump_width_all + jump_width;	% �W�����v���̗ݐϒl(sec)
	end
end
dtr_o = dtr;											% ���̃G�|�b�N�̂���


% clock jump �̏C��
%--------------------------------------------
if ~isempty(findstr(char(Rec_type),'TRIMBLE 5700'))
	% TRIMBLE 5700�d�l(NETRS �͏C���s�v)
	% Timetag offset & �[�������ɔ�т�����
	%--------------------------------------------
	data(:,2) = data(:,2) - C*jump_width_all;			% CA
	data(:,6) = data(:,6) - C*jump_width_all;			% PY
	data(:,1) = data(:,1);								% L1
	data(:,5) = data(:,5);								% L2
	ttime(6) = ttime(6) - jump_width_all;				% ���������C��
	dtr = dtr - jump_width_all;							% ��M�@���v�덷���C��
end
if ~isempty(findstr(char(Rec_type),'TPS LEGACY'))
	% Topcon TPS LEGACY�d�l
	% Timetag offset & �[������ & �����g�ʑ��ɔ�т�����
	%--------------------------------------------
	data(:,2) = data(:,2) - C*jump_width_all;			% CA
	data(:,6) = data(:,6) - C*jump_width_all;			% PY
	data(:,1) = data(:,1) - f1*jump_width_all;			% L1
	data(:,5) = data(:,5) - f2*jump_width_all;			% L2
	ttime(6) = ttime(6) - jump_width_all;				% ���������C��
	dtr = dtr - jump_width_all;							% ��M�@���v�덷���C��
end
if ~isempty(findstr(char(Rec_type),'U-BLOX'))
	% U-BLOX�d�l
	% Timetag offset & �[�������ɔ�т�����
	%--------------------------------------------
	data(:,2) = data(:,2) - C*jump_width_all;			% CA
	data(:,6) = data(:,6) - C*jump_width_all;			% PY
	data(:,1) = data(:,1);								% L1
	data(:,5) = data(:,5);								% L2
	ttime(6) = ttime(6) - jump_width_all;				% ���������C��
	dtr = dtr - jump_width_all;							% ��M�@���v�덷���C��
end
