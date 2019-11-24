function output_fig(fname,mode,handle)
%-------------------------------------------------------------------------------
% Function : figureのファイル出力関数・・・EPS,TIFF,EMFで保存
%
% [argin]
% fname   : 出力ファイル名
% mode    : 出力サイズ設定(0:縦カスタム, 1:縦フル, 2:横フル, 3:横フル+)
% handles : figureのハンドル
%
% [argout]
%
% ※ modeは "3" がおすすめ---印刷のことも考慮しているから
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 31, 2007
%-------------------------------------------------------------------------------

if nargin<3, handle=get(0,'CurrentFigure');, end

set(handle, 'PaperPositionMode', 'manual');
set(handle, 'PaperUnits', 'centimeters');
if mode == 0
	set(handle, 'PaperPosition', [0 0 21 15]);
	set(handle, 'PaperOrientation', 'portrait');		% portrait:縦  landscape:横
elseif mode==1
	set(handle, 'PaperPosition', [0 0 21 29.68]);		% フルサイズ(portrait:縦)
	set(handle, 'PaperOrientation', 'portrait');		% portrait:縦  landscape:横
elseif mode==2
	set(handle, 'PaperPosition', [0 0 29.68 21]);		% フルサイズ(landscape:横)
	set(handle, 'PaperOrientation', 'landscape');		% portrait:縦  landscape:横
elseif mode==3
	set(handle, 'PaperPosition', [0 0 29.68 21]);		% フルサイズ(landscape:横)
	set(handle, 'PaperOrientation', 'portrait');		% portrait:縦  landscape:横
end

set(handle, 'Renderer', 'painters');					% レンダリング法

set(gca, 'xtickmode','manual');							% 座標軸の範囲と目盛(スクリーンと同じ)
set(gca, 'ytickmode','manual');							% 座標軸の範囲と目盛(スクリーンと同じ)
set(gca, 'ztickmode','manual');							% 座標軸の範囲と目盛(スクリーンと同じ)

print(handle,'-r300','-depsc2',fname)					% EPS Level2 Color
% print(handle,'-r300','-dtiff',fname)					% TIFF
print(handle,'-dmeta',fname)							% EMF

if mode==3
	set(handle, 'PaperOrientation', 'landscape');		% portrait:縦  landscape:横
end
saveas(handle,fname,'fig')								% figureの保存