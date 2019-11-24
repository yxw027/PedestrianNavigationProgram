clear all
close all

Nc = 90;                        % ��肽���F�̐�
% A = colormap(colorcube(Nc));    % colorcube��ς��邱�ƂŁA�F��ȑg�ݍ��킹�̐F������B
A = colormap(jet(Nc));          % �ڂ����� help colormap ���Q��


% �o�����F��\�������Ă݂�B
colorbar;hold on
for t = 1:Nc
    plot(t,t,'.','Color',A(t,:));
end


% ==== Memo ====
%% A : (matrix) data matrix, size Nc x 3   Nc�F
%%
