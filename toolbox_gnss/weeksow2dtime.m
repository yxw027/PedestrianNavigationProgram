function dtime = weeksow2dtime(weeksow)

% week = weeksow(1);
% sow = weeksow(2);
% dow = floor(sow/86400);
% jd = 2444245 + 7*week + dow;
% ymd = juliday2ymd(jd);
% 
% a = sow - 86400*dow;
% hh = floor(a/3600);
% b = a - 3600*hh;
% mm = floor(b/60);
% ss = b - 60*mm;
% 
% dtime = [ymd hh mm ss];



week = weeksow(1);
sow = weeksow(2);
dow = fix(sow/86400);
jd = 2444245 + 7*week + dow;
ymd = juliday2ymd(jd);

a = sow - 86400*dow;
hh = fix(a/3600);
b = a - 3600*hh;
mm = fix(b/60);
ss = b - 60*mm;

dtime = [ymd hh mm ss];
