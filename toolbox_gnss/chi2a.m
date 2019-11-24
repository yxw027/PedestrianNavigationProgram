% x2a(n) : chi-squre distribution critical value -------------------------------
function x=x2a(n,a)

% set range of search
r=[0,10]; while a<x2q(n,r(2)), r(2)=r(2)*2; end

% binary search
while 1
    x=(r(1)+r(2))/2; p=x2q(n,x);
    if abs(p-a)<a*1E-5, break, elseif p<a, r(2)=x; else r(1)=x; end
end

% chi-square function ----------------------------------------------------------
function p=x2q(n,x), p=1-gammainc(x/2,n/2);
