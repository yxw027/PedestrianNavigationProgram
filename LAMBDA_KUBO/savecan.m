function [can, Jall, Jmin, Jmax] = savecan(J, Jall, Jmin, Jmax, nc, can, ncan, maxcan)

if (ncan <= maxcan) | (maxcan == 0)
    Jall = [Jall; J];
    can = [can; nc];
    [Jall order] = sort(Jall);
    can = can(order,:);
    Jmin = Jall(1);
    Jmax = Jall(ncan);
elseif J < Jmax
    Jall(maxcan) = J;
    can(maxcan, :) = nc;
    [Jall order] = sort(Jall);
    can = can(order, :);
    Jmin = Jall(1);
    Jmax = Jall(maxcan);
end






