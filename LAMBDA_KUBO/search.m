function [can, Jall, ncan] = search(nh, U, D, m, chi2, maxcan)
%

% ˆø”
% •Ô–ß’l
%
% Reference: LGR12
% Ritsumeikan Univ. Dept of EEE.
% Y. Kubo, 17/Dec. 2007
%

%For Debug
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nh = [-0.25 1.8];
%m=2;
%Q = [4.6 1.2;
%     1.2 4.8];
%maxcan = 3;
%chi2 = 1.5;
%[U D] = ud(Q,m);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Jmin = 1e10;
Jmax = 1e10;
ncan = 0;
Jall = [];
can = [];
res = zeros(m+1,1);
theta2(m+1) = chi2;

for i = 1 : m - 1
    df(i) = D(i)/D(i+1);
end
df(m) = D(m);

i = m + 1;
while i > 1
    i = i - 1;
    mu(i) = U(i,i+1:m) * res(i+1:m);
    theta2(i) = df(i) * (theta2(i+1) - res(i+1)^2);
    theta(i) = sqrt(theta2(i));
    delta = nh(i) + mu(i) - theta(i);
    lim(i) = delta + 2 * theta(i);
    nc(i) = ceil(delta);
    if nc(i) > lim(i)
        [i nc res] = backtrack(i, m, nc, lim, res);
    else
        res(i) = nc(i) - nh(i) - mu(i);
    end
    if i == 1
        J = chi2 -(theta2(1) - res(1)^2)/D(1);
        while nc(1) <= lim(1)
            ncan = ncan + 1;
            [can, Jall, Jmin, Jmax] = savecan(J, Jall, Jmin, Jmax, nc, can, ncan, maxcan);
            nc(1) = nc(1) + 1;
            J = J + (2*res(1)+1)/D(1);
            res(1) = res(1)+1; 
        end
        [i nc res] = backtrack(i, m, nc, lim, res);
    end
end
