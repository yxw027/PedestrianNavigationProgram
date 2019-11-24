function [i nc res] = backtrack(i, m, nc, lim, res)


j = i + 1;
while j <= m
    a = nc(j) + 1;
    if  a <= lim(j)
        nc(j) = a;
        res(j) = res(j) + 1;
        i = j;
        break;
    end
    j = j + 1;
end
%finish = 1;
