function ymd = juliday2ymd(jd)

%jd = juliday([2008,5,10,10,11,12.344])
%%jd = juliday([2008,1,10,10,11,12.344])
%%jd = ymd2juliday([2007,11,3])
%jd = juliday([2008,2,29,10,11,12.344])
%time = [2008 2 29 1 2 3]
%jd = juliday(time);



% a = jd - 1720995 + 13;
% Y = floor(a/365.25);
% 
% b = floor(jd - ymd2juliday99([Y,3,1])) + 1;
% if b <= 0
%     b = floor(jd - ymd2juliday99([Y-1,3,1])) + 1;
%     Y = Y - 1;
% end
% number = [0,31,61,92,122,153,184,214,245,275,306,337];
% i=1;
% while((i<13)&(b>number(i)))
%     i=i+1;
% end
% M = i + 1;
% D = b - number(i-1);
% if M>12
%     M = M - 12;
% end
% if M==1 | M==2
%     Y = Y + 1;
% end
% ymd = [Y,M,D];

a = jd - 1720995 + 13;
Y = fix(a/365.25);

b = fix(jd - ymd2juliday99([Y,3,1])) + 1;
if b <= 0
    b = fix(jd - ymd2juliday99([Y-1,3,1])) + 1;
    Y = Y - 1;
end
number = [0,31,61,92,122,153,184,214,245,275,306,337];
i=1;
while((i<13)&(b>number(i)))
    i=i+1;
end
M = i + 1;
D = b - number(i-1);
if M>12
    M = M - 12;
end
if M==1 | M==2
    Y = Y + 1;
end
ymd = [Y,M,D];

