function savelamlog(fid,m,nh,nhd,ndiff,Q,Un,Dn,ZTi,zh,Uz,Dz,ncan,chi2,Jall,can)
% LAMBDAñ@ÇÃÉçÉOÇãLò^Ç∑ÇÈ

% 
% 
% Y. Kubo  15/Jan., 2008
%

fprintf(fid,'original float ambiguity\n');
fprintf(fid,'%12.3f\n', nh);
fprintf(fid,'\n');
fprintf(fid,'reduced float ambiguity\n');
fprintf(fid,'%12.3f\n', nhd);
fprintf(fid,'\n');
fprintf(fid,'original Q\n');
for i = 1 : m
    for j = 1 : m
        fprintf(fid,'%8.4f ', Q(i,j));
    end
    fprintf(fid,'\n');
end
fprintf(fid,'\n');
fprintf(fid,'original U\n');
for i = 1 : m
    for j = 1 : m
        fprintf(fid,'%8.4f ', Un(i,j));
    end
    fprintf(fid,'\n');
end
fprintf(fid,'\n');
fprintf(fid,'original D\n');
fprintf(fid,'%8.3f\n', Dn);
fprintf(fid,'\n');
fprintf(fid,'Z^T\n');
ZT = inv(ZTi);
for i = 1 : m
    for j = 1 : m
        fprintf(fid,'%4d ', ZT(i,j));
    end
    fprintf(fid,'\n');
end
fprintf(fid,'\n');
fprintf(fid,'transformed reduced float ambiguity\n');
fprintf(fid,'%12.3f\n', zh);
fprintf(fid,'\n');
Qz = Uz*diag(Dz)*Uz';
fprintf(fid,'transformed Qz\n');
for i = 1 : m
    for j = 1 : m
        fprintf(fid,'%8.4f ', Qz(i,j));
    end
    fprintf(fid,'\n');
end
fprintf(fid,'\n');
fprintf(fid,'transformed U\n');
for i = 1 : m
    for j = 1 : m
        fprintf(fid,'%8.4f ', Uz(i,j));
    end
    fprintf(fid,'\n');
end
fprintf(fid,'\n');
fprintf(fid,'transformed D\n');
fprintf(fid,'%8.3f\n', Dz);
fprintf(fid,'\n');

fprintf(fid,'%4d candidats found in search space of Chi^2=%6.3f\n', ncan, chi2);
fprintf(fid,'     J of best     = %8.4f\n', Jall(1));
fprintf(fid,'     J of 2nd best = %8.4f\n', Jall(2));
fprintf(fid,'\n');

fprintf(fid,'fixed transformed reduced ambiguity (z_check)\n');
fprintf(fid,'%12d\n', can(1,:)');
fprintf(fid,'\n');

fprintf(fid,'fixed ambiguity (n_check)\n');
fprintf(fid,'%12d\n', (ZTi * can(1,:)' + ndiff));
fprintf(fid,'\n');

fprintf(fid,'2nd-best fixed transformed reduced ambiguity\n');
fprintf(fid,'%12d\n', can(2,:)');
fprintf(fid,'\n');

fprintf(fid,'2nd-best fixed ambiguity\n');
fprintf(fid,'%12d\n', (ZTi * can(2,:)' + ndiff));
fprintf(fid,'\n');
fprintf(fid,'*************************************************************\n\n');
