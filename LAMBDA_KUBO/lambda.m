function [ncheck Jzcheck] = lambda(Q,nh,m,fid)


%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [5.45 3.10 2.97]';
%m=3;
%Q = [6.290  5.978  0.544;
%     5.978  6.292  2.340;
%     0.544  2.340  6.288];
%[fid]=fopen('lambda.log','wt');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=2;                          % ’Tõ‹óŠÔ‚ÉŠÜ‚ß‚éŒó•â‚ÌÅ’áŒÂ”(p<=m+1)
maxcan = 2;                   % ‹L˜^‚·‚éŒó•â‚ÌÅ‘åŒÂ”
nhd = rem(nh,1);              % Ambiguity‚Ì®”•”•ª‚ğœ‚­
ndiff = nh - nhd;             % ®”•”•ª
[Un,Dn] = ud(Q,m);            % Q‚ğUDU^T•ª‰ğ‚·‚é
[Uz,Dz,zh,ZTi]=lamtrans(Un,Dn,nhd,m);   % –³‘ŠŠÖ‰»‚·‚é
[chi2] = chisetting(Uz, Dz, m, zh, p);  % ’Tõ‹óŠÔ‚Ì‘å‚«‚³‚ğŒˆ‚ß‚é
chi2 = chi2 + 1e-6;                     % ‹«ŠE‚ğŠÜ‚ñ‚Å’Tõ‚·‚é‚æ‚¤‚ÉChi^2‚ğ­‚µ‘å‚«‚­‚·‚é
[can, Jall, ncan] = search(zh, Uz, Dz, m, chi2, maxcan);    % ’Tõ
zcheck = can(1,:)';             % ‘æˆêŒó•â
Jzcheck = Jall(1);              % ‘æˆêŒó•â‚É‘Î‚·‚é•]‰¿ŠÖ”’l
ncheck = ZTi * zcheck + ndiff;  % ‘æˆêŒó•â‚ğ‹t•ÏŠ·‚·‚é
if fid ~= -1                    % LAMBDA–@‚ÌƒƒO‚ğo—Í
    savelamlog(fid,m,nh,nhd,ndiff,Q,Un,Dn,ZTi,zh,Uz,Dz,ncan,chi2,Jall,can);
end

%
%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%
%fid
%fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%
%


