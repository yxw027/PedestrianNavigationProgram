function jd = ymd2juliday99(ymd)

% time = [Y,M,D,hh,mm,ss]

Y  = ymd(1);
M  = ymd(2);
D  = ymd(3);

jd = floor(30.6001*(M+1+12*(M<3))) ...
     + floor(365.25*(Y-(M<3))) ...
     + D ...
     + 1720982;
