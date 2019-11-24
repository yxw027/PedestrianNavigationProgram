function [chi2,rej,bb] = lc_chi2r2(timetag,LC,LC_r,sigma,b,Vb,Gb,common)
%-------------------------------------------------------------------------------
% Function : ���`�����̃J�C��挟��(�A���G�|�b�N)���x�����
% 
% [argin]
% timetag : timetag
% LC     : ���`�����z��(�����ł͕��U��p����-*.mp1_va, *.mp2_va...)
% LC_r   : ���`�����z��(���O�q���r���ς�)
% sigma  : 臒l(�㑤�m���_)
% b      : �ő厩�R�x
% Vb     : �ϑ��G���ϊ��s��
% Gb     : �����։��s��
% common : ���ʉq��
%
% [argout]
% chi2   : �J�C���l
% rej    : ���O�q��
% bb     : ���R�x
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Dec. 21, 2009
%-------------------------------------------------------------------------------
% �\���̂ŏ���, ���͈����̍팸
% January 21, 2010, T.Yanase
%-------------------------------------------------------------------------------

[r_lc.mp1, c_lc.mp1] = size(LC_r.mp1);
[r_lc.mp2, c_lc.mp2] = size(LC_r.mp2);
[r_lc.mw, c_lc.mw] = size(LC_r.mw);
[r_lc.lgl, c_lc.lgl] = size(LC_r.lgl);

rej.mp1(1:c_lc.mp1) =NaN;
rej.mp2(1:c_lc.mp2) =NaN;
rej.mw(1:c_lc.mw) =NaN;
rej.lgl(1:c_lc.lgl) =NaN;

chi2.mp1(1:c_lc.mp1) = NaN;
chi2.mp2(1:c_lc.mp2) = NaN;
chi2.mw(1:c_lc.mw) = NaN;
chi2.lgl(1:c_lc.lgl) = NaN;

bb.mp1(1:c_lc.mp1) = NaN;
bb.mp2(1:c_lc.mp2) = NaN;
bb.mw(1:c_lc.mw) = NaN;
bb.lgl(1:c_lc.lgl) = NaN;
rej_out.mp1 = [];
rej_out.mp2 = [];
rej_out.mw = [];
rej_out.lgl = [];

if timetag<=b											% ���`�����̃G�|�b�N�ԍ����v�Z
	diff_lc.mp1 = diff(LC_r.mp1(1:timetag,:));						% timetag<=�ő厩�R�x
	diff_lc.mp2 = diff(LC_r.mp2(1:timetag,:));						% timetag<=�ő厩�R�x
	diff_lc.mw = diff(LC_r.mw(1:timetag,:));						% timetag<=�ő厩�R�x
	diff_lc.lgl = diff(LC_r.lgl(1:timetag,:));						% timetag<=�ő厩�R�x
else
	diff_lc.mp1 = diff(LC_r.mp1(timetag-b:timetag,:));				% timetag>�ő厩�R�x
	diff_lc.mp2 = diff(LC_r.mp2(timetag-b:timetag,:));				% timetag>�ő厩�R�x
	diff_lc.mw = diff(LC_r.mw(timetag-b:timetag,:));				% timetag>�ő厩�R�x
	diff_lc.lgl = diff(LC_r.lgl(timetag-b:timetag,:));				% timetag>�ő厩�R�x
end

[r_d.mp1, c_d.mp1] = size(diff_lc.mp1);
[r_d.mp2, c_d.mp2] = size(diff_lc.mp2);
[r_d.mw, c_d.mw] = size(diff_lc.mw);
[r_d.lgl, c_d.lgl] = size(diff_lc.lgl);

for n=common											% �e�q�����Ɍv�Z
	i_nan.mp1 = find(isnan(diff_lc.mp1(:,n)), 1, 'last' );			% �Ō��NaN�̃C���f�b�N�X�𒊏o
	i_nan.mp2 = find(isnan(diff_lc.mp2(:,n)), 1, 'last' );			% �Ō��NaN�̃C���f�b�N�X�𒊏o
	i_nan.mw = find(isnan(diff_lc.mw(:,n)), 1, 'last' );			% �Ō��NaN�̃C���f�b�N�X�𒊏o
	i_nan.lgl = find(isnan(diff_lc.lgl(:,n)), 1, 'last' );			% �Ō��NaN�̃C���f�b�N�X�𒊏o
	if isempty(i_nan.mp1)
		i_nan.mp1 = 0;
	end
	if i_nan.mp1~=r_d.mp1
		d = diff_lc.mp1(i_nan.mp1+1:r_d.mp1,n);						% NaN���܂܂���NaN����̃f�[�^�݂̂��g�p
		bb.mp1(n) = length(d);
		dd = flipud(d);
		chi2.mp1(n) = dd'*Gb(b-bb.mp1(n)+1:b,b-bb.mp1(n)+1:b)'*inv(Vb(b-bb.mp1(n)+1:b,b-bb.mp1(n)+1:b)*2*LC.mp1_va(timetag,n))*Gb(b-bb.mp1(n)+1:b,b-bb.mp1(n)+1:b)*dd;		% ���蓝�v��
		if chi2.mp1(n)>sigma.mp1(bb.mp1(n))							% �J�C2�挟��
			rej_out.mp1 = [rej_out.mp1 n];							% ���O�q���ǉ�
		end
		d=[];, dd=[];				% ������
	end
	if isempty(i_nan.mp2)
		i_nan.mp2 = 0;
	end
	if i_nan.mp2~=r_d.mp2
		d = diff_lc.mp2(i_nan.mp2+1:r_d.mp2,n);						% NaN���܂܂���NaN����̃f�[�^�݂̂��g�p
		bb.mp2(n) = length(d);
		dd = flipud(d);
		chi2.mp2(n) = dd'*Gb(b-bb.mp2(n)+1:b,b-bb.mp2(n)+1:b)'*inv(Vb(b-bb.mp2(n)+1:b,b-bb.mp2(n)+1:b)*2*LC.mp2_va(timetag,n))*Gb(b-bb.mp2(n)+1:b,b-bb.mp2(n)+1:b)*dd;		% ���蓝�v��
		if chi2.mp2(n)>sigma.mp2(bb.mp2(n))							% �J�C2�挟��
			rej_out.mp2 = [rej_out.mp2 n];							% ���O�q���ǉ�
		end
		d=[];, dd=[];				% ������
	end
	if isempty(i_nan.mw)
		i_nan.mw = 0;
	end
	if i_nan.mw~=r_d.mw
		d = diff_lc.mw(i_nan.mw+1:r_d.mw,n);						% NaN���܂܂���NaN����̃f�[�^�݂̂��g�p
		bb.mw(n) = length(d);
		dd = flipud(d);
		chi2.mw(n) = dd'*Gb(b-bb.mw(n)+1:b,b-bb.mw(n)+1:b)'*inv(Vb(b-bb.mw(n)+1:b,b-bb.mw(n)+1:b)*2*LC.mw_va(timetag,n))*Gb(b-bb.mw(n)+1:b,b-bb.mw(n)+1:b)*dd;		% ���蓝�v��
		if chi2.mw(n)>sigma.mw(bb.mw(n))							% �J�C2�挟��
			rej_out.mw = [rej_out.mw n];							% ���O�q���ǉ�
		end
		d=[];, dd=[];				% ������
	end
	if isempty(i_nan.lgl)
		i_nan.lgl = 0;
	end
	if i_nan.lgl~=r_d.lgl
		d = diff_lc.lgl(i_nan.lgl+1:r_d.lgl,n);						% NaN���܂܂���NaN����̃f�[�^�݂̂��g�p
		bb.lgl(n) = length(d);
		dd = flipud(d);
		chi2.lgl(n) = dd'*Gb(b-bb.lgl(n)+1:b,b-bb.lgl(n)+1:b)'*inv(Vb(b-bb.lgl(n)+1:b,b-bb.lgl(n)+1:b)*2*LC.lgl_va(timetag,n))*Gb(b-bb.lgl(n)+1:b,b-bb.lgl(n)+1:b)*dd;		% ���蓝�v��
		if chi2.lgl(n)>sigma.lgl(bb.lgl(n))							% �J�C2�挟��
			rej_out.lgl = [rej_out.lgl n];							% ���O�q���ǉ�
		end
		d=[];, dd=[];				% ������
	end
end
rej.mp1(rej_out.mp1)=rej_out.mp1;
rej.mp2(rej_out.mp2)=rej_out.mp2;
rej.mw(rej_out.mw)=rej_out.mw;
rej.lgl(rej_out.lgl)=rej_out.lgl;



