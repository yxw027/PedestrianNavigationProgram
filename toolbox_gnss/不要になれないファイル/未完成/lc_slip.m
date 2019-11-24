function [s1, s2, lgl_sa, mw_sa, mp1_sa, mp2_sa] = lc_slip(LC, V, CHI2, timetag, rej)
%-------------------------------------------------------------------------------
% Function : サイクルスリップのスリップ量推定(線形結合)
% 
% [argin]
% LC    : 線形結合配列
% V     : 分散格納配列
% CHI2  : CHI2配列
% timetag : timetag
% rej   : サイクルスリップ検出衛星番号
%
% [argout]
% s1    : L1スリップ量
% s2    : L2スリップ量
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% Y.Ishimaru: Feb. 24, 2009

eval('slip_list')						% スリップ量適合表の取り込み

s1(1:32) = NaN; s2(1:32) = NaN;
lgl_sa(1:32) = NaN;
mw_sa(1:32) = NaN;
mp1_sa(1:32) = NaN;
mp2_sa(1:32) = NaN;

diff_lgl = diff(LC.lgl(timetag-1:timetag,:));
diff_mw = diff(LC.mw(timetag-1:timetag,:));
diff_mp1 = diff(LC.mp1(timetag-1:timetag,:));
diff_mp2 = diff(LC.mp2(timetag-1:timetag,:));

for i=1:length(rej)
% 	[lgl_s1, lgl_s2] = find(d_GF>diff_lgl(rej(i))-sqrt(CHI2.sigma.b_lgl*V.lgl_v(rej(i))) & d_GF<diff_lgl(rej(i))+sqrt(CHI2.sigma.b_lgl*V.lgl_v(rej(i))));
% 	[mw_s1, mw_s2]   = find(d_MW>diff_mw(rej(i))-sqrt(CHI2.sigma.b_mw*V.mw_v(rej(i))) & d_GF<diff_mw(rej(i))+sqrt(CHI2.sigma.b_mw*V.mw_v(rej(i))));
% 	[mp1_s1, mp1_s2] = find(d_MP1>diff_mp1(rej(i))-sqrt(CHI2.sigma.b_mp1*V.mp1_v(rej(i))) & d_GF<diff_mp1(rej(i))+sqrt(CHI2.sigma.b_mp1*V.mp1_v(rej(i))));
% 	[mp2_s1, mp2_s2] = find(d_MP2>diff_mp2(rej(i))-sqrt(CHI2.sigma.b_mp2*V.mp2_v(rej(i))) & d_GF<diff_mp2(rej(i))+sqrt(CHI2.sigma.b_mp2*V.mp2_v(rej(i))));
	
% 	[lgl_s1, lgl_s2] = find(d_GF>diff_lgl(rej(i))-2*V.lgl_v(rej(i)) & d_GF<diff_lgl(rej(i))+2*V.lgl_v(rej(i)));
% 	[mw_s1, mw_s2]   = find(d_MW>diff_mw(rej(i))-10*V.mw_v(rej(i)) & d_GF<diff_mw(rej(i))+10*V.mw_v(rej(i)));
% 	[mp1_s1, mp1_s2] = find(d_MP1>diff_mp1(rej(i))-10*V.mp1_v(rej(i)) & d_GF<diff_mp1(rej(i))+10*V.mp1_v(rej(i)));
% 	[mp2_s1, mp2_s2] = find(d_MP2>diff_mp2(rej(i))-10*V.mp2_v(rej(i)) & d_GF<diff_mp2(rej(i))+10*V.mp2_v(rej(i)));
	
	[lgl_s2a,lgl_s1a] = min(abs(d_GF-diff_lgl(rej(i))));
	[lgl_s2b,lgl_s2] = min(lgl_s2a);
	lgl_s1 = lgl_s1a(lgl_s2);

	[mw_s2a,mw_s1a] = min(abs(d_MW-diff_mw(rej(i))));
	[mw_s2b,mw_s2] = min(mw_s2a);
	mw_s1 = mw_s1a(mw_s2);
	
	[mp1_s2a,mp1_s1a] = min(abs(d_MP1-diff_mp1(rej(i))));
	[mp1_s2b,mp1_s2] = min(mp1_s2a);
	mp1_s1 = mp1_s1a(mp1_s2);
	
	[mp2_s2a,mp2_s1a] = min(abs(d_MP2-diff_mp2(rej(i))));
	[mp2_s2b,mp2_s2] = min(mp2_s2a);
	mp2_s1 = mp2_s1a(mp2_s2);
	
	lgl_s = 1000*(lgl_s1-1) + (lgl_s2-1);
	mw_s  = 1000*(mw_s1-1) + (mw_s2-1);
	mp1_s = 1000*(mp1_s1-1) + (mp1_s2-1);
	mp2_s = 1000*(mp2_s1-1) + (mp2_s2-1);
	
	lgl_sa(rej(i)) = lgl_s;
	mw_sa(rej(i)) = mw_s;
	mp1_sa(rej(i)) = mp1_s;
	mp2_sa(rej(i)) = mp2_s;
	
	s_a = intersect(lgl_s,mw_s);
	s_b = intersect(mp1_s,mp2_s);
	s   = intersect(s_a,s_b);
	
	if length(s)==1
		s1(rej(i)) = fix(s/1000);
		s2(rej(i)) = rem(s,1000);
	else
		s1(rej(i)) = NaN;
		s2(rej(i)) = NaN;
	end
	
end

% 作成中
