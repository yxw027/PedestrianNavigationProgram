function [lim] = lc_lim(est_prm,timetag,LC,REJ)
%-------------------------------------------------------------------------------
% Function : ���`�����ɂ��T�C�N���X���b�v���o臒l�̌v�Z
% 
% [argin]
% est_prm : �ݒ�p�����[�^
% timetag : �^�C���^�O
% LC      : ���`�����i�[�z��
% REJ     : �X���b�v���o�q���i�[�z��
%
% [argout]
% lim     : 臒l
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Oct. 25, 2008
%-------------------------------------------------------------------------------
% �\���̂ŏ���, ���͈����̍팸
% January 20, 2010, T.Yanase
%-------------------------------------------------------------------------------

mag1=0;				% ���ϔ{��(LG�ȊO��0�ɂ���)
lc_int=[1:est_prm.cycle_slip.lc_int];

diff_lc.mp1 = diff(LC.mp1(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
diff_lc.mp2 = diff(LC.mp2(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
diff_lc.mw = diff(LC.mw(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
diff_lc.lgl = diff(LC.lgl(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.lgp = diff(LC.lgp(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.lg1 = diff(LC.lg1(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.lg2 = diff(LC.lg2(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.ionp = diff(LC.ionp(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));
% diff_lc.ionl = diff(LC.ionl(timetag-est_prm.cycle_slip.lc_int-1:timetag-1,:));

for j=1:61
	rej_epo.mp1 = find(REJ.mp1(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
	rej_epo.mp2 = find(REJ.mp2(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
	rej_epo.mw = find(REJ.mw(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
	rej_epo.lgl = find(REJ.lgl(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
% 	rej_epo.lgp = find(REJ.lgp(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
% 	rej_epo.lg1 = find(REJ.lg1(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
% 	rej_epo.lg2 = find(REJ.lg2(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);				% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
% 	rej_epo.ionp = find(REJ.ionp(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);			% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
% 	rej_epo.ionl = find(REJ.ionl(timetag-est_prm.cycle_slip.lc_int:timetag-1,j)==j);			% ���O�q�����X�g����q��j�̍s��ԍ��𒊏o
	nan_epo.mp1 = find(isnan(diff_lc.mp1(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
	nan_epo.mp2 = find(isnan(diff_lc.mp2(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
	nan_epo.mw = find(isnan(diff_lc.mw(:,j)));														% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
	nan_epo.lgl = find(isnan(diff_lc.lgl(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
% 	nan_epo.lgp = find(isnan(diff_lc.lgp(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
% 	nan_epo.lg1 = find(isnan(diff_lc.lg1(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
% 	nan_epo.lg2 = find(isnan(diff_lc.lg2(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
% 	nan_epo.ionp = find(isnan(diff_lc.ionp(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
% 	nan_epo.ionl = find(isnan(diff_lc.ionl(:,j)));													% ���`������NaN�̍s��ԍ��𒊏o (�G�|�b�N���������΍�)
	rej.mp1 = union(rej_epo.mp1,nan_epo.mp1);
	rej.mp2 = union(rej_epo.mp2,nan_epo.mp2);
	rej.mw = union(rej_epo.mw,nan_epo.mw);
	rej.lgl = union(rej_epo.lgl,nan_epo.lgl);
% 	rej.lgp = union(rej_epo.lgp,nan_epo.lgp);
% 	rej.lg1 = union(rej_epo.lg1,nan_epo.lg1);
% 	rej.lg2 = union(rej_epo,nan_epo);
% 	rej.ionp = union(rej_epo,nan_epo);
% 	rej.ionl = union(rej_epo,nan_epo);

	if length(rej.mp1)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
		a.mp1 = setdiff(lc_int,rej.mp1);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
		lim_a.mp1 = std(diff_lc.mp1(a.mp1,j),1);															% �W���΍�(�֐�)
		lim.mp1(1,j) = abs(mean(diff_lc.mp1(a.mp1,j)))*mag1 + lim_a.mp1*est_prm.cycle_slip.sd;				% ����*�{��+���U*�{��
	else
		lim.mp1(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
	end
	if length(rej.mp2)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
		a.mp2 = setdiff(lc_int,rej.mp2);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
		lim_a.mp2 = std(diff_lc.mp2(a.mp2,j),1);															% �W���΍�(�֐�)
		lim.mp2(1,j) = abs(mean(diff_lc.mp2(a.mp2,j)))*mag1 + lim_a.mp2*est_prm.cycle_slip.sd;				% ����*�{��+���U*�{��
	else
		lim.mp2(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
	end
	if length(rej.mw)<5																						% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
		a.mw = setdiff(lc_int,rej.mw);																		% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
		lim_a.mw = std(diff_lc.mw(a.mw,j),1);																% �W���΍�(�֐�)
		lim.mw(1,j) = abs(mean(diff_lc.mw(a.mw,j)))*mag1 + lim_a.mw*est_prm.cycle_slip.sd;					% ����*�{��+���U*�{��
	else
		lim.mw(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
	end
	if length(rej.lgl)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
		a.lgl = setdiff(lc_int,rej.lgl);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
		lim_a.lgl = std(diff_lc.lgl(a.lgl,j),1);															% �W���΍�(�֐�)
		lim.lgl(1,j) = abs(mean(diff_lc.lgl(a.lgl,j)))*1 + lim_a.lgl*est_prm.cycle_slip.sd;					% ����*�{��+���U*�{��
	else
		lim.lgl(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
	end
% 	if length(rej.lgp)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
% 		a.lgp = setdiff(lc_int,rej.lgp);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
% 		lim_a.lgp = std(diff_lc.lgp(a.lgp,j),1);															% �W���΍�(�֐�)
% 		lim.lgp(1,j) = abs(mean(diff_lc.lgp(a.lgp,j)))*mag1 + lim_a.lgp*est_prm.cycle_slip.sd;				% ����*�{��+���U*�{��
% 	else
% 		lim.lgp(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
% 	end
% 	if length(rej.lg1)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
% 		a.lg1 = setdiff(lc_int,rej.lg1);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
% 		lim_a.lg1 = std(diff_lc.lg1(a.lg1,j),1);															% �W���΍�(�֐�)
% 		lim.lg1(1,j) = abs(mean(diff_lc.lg1(a.lg1,j)))*mag1 + lim_a.lg1*est_prm.cycle_slip.sd;				% ����*�{��+���U*�{��
% 	else
% 		lim.lg1(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
% 	end
% 	if length(rej.lg2)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
% 		a.lg2 = setdiff(lc_int,rej.lg2);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
% 		lim_a.lg2 = std(diff_lc.lg2(a.lg2,j),1);															% �W���΍�(�֐�)
% 		lim.lg2(1,j) = abs(mean(diff_lc.lg2(a.lg2,j)))*mag1 + lim_a.lg2*est_prm.cycle_slip.sd;				% ����*�{��+���U*�{��
% 	else
% 		lim.lg2(1,j) = NaN;																					% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
% 	end
% 	if length(rej.ionp)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
% 		a.ionp = setdiff(lc_int,rej.ionp);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
% 		lim_a.ionp = std(diff_lc.ionp(a.ionp,j),1);															% �W���΍�(�֐�)
% 		lim.ionp(1,j) = abs(mean(diff_lc.ionp(a.ionp,j)))*mag1 + lim_a.ionp*est_prm.cycle_slip.sd;			% ����*�{��+���U*�{��
% 	else
% 		lim.ionp(1,j) = NaN;																				% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
% 	end
% 	if length(rej.ionl)<5																					% �q�����g�p���Ȃ��G�|�b�N��5�����Ȃ�臒l���o��
% 		a.ionl = setdiff(lc_int,rej.ionl);																	% lc_int�̗v�f�̒�����s�g�p�̗v�f�����O
% 		lim_a.ionl = std(diff_lc.ionl(a.ionl,j),1);															% �W���΍�(�֐�)
% 		lim.ionl(1,j) = abs(mean(diff_lc.ionl(a.ionl,j)))*mag1 + lim_a.ionl*est_prm.cycle_slip.sd;			% ����*�{��+���U*�{��
% 	else
% 		lim.ionl(1,j) = NaN;																				% �q�����g�p���Ȃ��G�|�b�N��5�ȏ�Ȃ�臒l���o���Ȃ�
% 	end
end
