clear all
close all

Nc = 90;                        % 作りたい色の数
% A = colormap(colorcube(Nc));    % colorcubeを変えることで、色んな組み合わせの色が作れる。
A = colormap(jet(Nc));          % 詳しくは help colormap を参照


% 出来た色を表示させてみる。
colorbar;hold on
for t = 1:Nc
    plot(t,t,'.','Color',A(t,:));
end


% ==== Memo ====
%% A : (matrix) data matrix, size Nc x 3   Nc色
%%
