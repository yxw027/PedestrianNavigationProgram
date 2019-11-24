function [x,P]=humanstateadjust(Kalx_f, KalP_f, Kalx_p, KalP_p, INS, truestep)
%•à•‚Ì”’l‚ÉˆÙí‚ğ—ˆ‚µ‚»‚¤‚È‚ç‚±‚ê‚ÅC³‚·‚é
Kalx_p(1:3) = Kalx_f(1:3) + 0.69*INS(1:3)';
Kalx_p(9) = truestep;
x = Kalx_p;
%KalP_p(1:3,1:3) = KalP_f(1:3,1:3);
KalP_p = KalP_f;
KalP_p(1:3,1:3) = [0.01,0.01,0.01;0.01,0.01,0.01;0.01,0.01,0.01];
KalP_p(9) = 0.01;
P = KalP_p;
fprintf(',STATEADJ');
end