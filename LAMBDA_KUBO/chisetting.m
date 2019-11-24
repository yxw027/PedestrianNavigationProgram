function [chi2] = chisetting(U, D, m, nh, p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [-0.25 1.8];
%m=2;
%Q = [4.6 1.2;
%     1.2 4.8];
%%maxcan = 3;
%%chi2 = 1.5;
%[U D] = ud(Q,m);
%p = 2;      %­‚È‚­‚Æ‚àŠú‘Ò‚·‚éŒó•â”
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



res = zeros(m+1,1);

i = m + 1;
while i > 1
    i = i - 1;
    mu(i) = U(i,i+1:m) * res(i+1:m);
    nb(i) = nh(i) + mu(i);
    nc(i) = round(nb(i));
    res(i) = nc(i) - nb(i);
end
J = (1./D) * (res(1:m).^2);

for k = m : -1 : 1
    if res(k) < 0
        beta = 1;
    else
        beta = -1;
    end
    resnew = res;
    resnew(k) = res(k) + beta;
    j = k;
    while j > 1
        j = j - 1;
        mu(j) = U(j,j+1:m) * resnew(j+1:m);
        nb(j) = nh(j) + mu(j);
        nc(j) = round(nb(j));
        resnew(j) = nc(j) - nb(j);
    end
    Jk(k) = (1./D) * (resnew(1:m).^2);
end

J = sort([J Jk]);
chi2 = J(p);
%chi2 = J(p)+1e-6;
