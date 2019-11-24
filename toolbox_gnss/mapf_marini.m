function [md,mw]=mapf_marini(time,pos,ele)
%-------------------------------------------------------------------------------
% Function : 対流圏遅延 マッピング関数 marini
% 
% [argin]
% time : 時刻[Y,M,D,H,M,S]
% pos  : XYZ(ECEF)[m]
% ele  : 仰角[rad]
% 
% [argout]
% md : dry マッピング関数
% mw : wet マッピング関数
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: February 2, 2008
%-------------------------------------------------------------------------------

pos = xyz2llh(pos(1:3));														% llhに変換

T=15.0-6.5E-3*pos(3)+273.16; 													% temperture(K)

ad=[1.2320+0.0139*cos(pos(1))-0.0209*pos(3)+0.00215*(T-283)]*1e-3;
bd=[3.1612+0.1600*cos(pos(1))-0.0331*pos(3)+0.00206*(T-283)]*1e-3;
cd=[71.244+4.2930*cos(pos(1))-0.1490*pos(3)-0.00210*(T-283)]*1e-3;
aw=[0.5830+0.0110*cos(pos(1))-0.0520*pos(3)+0.00140*(T-283)]*1e-3;
bw=[1.4020+0.1020*cos(pos(1))-0.1010*pos(3)+0.00200*(T-283)]*1e-3;
cw=[45.850+1.9100*cos(pos(1))-1.2900*pos(3)+0.01500*(T-283)]*1e-3;

md=(1+ad./(1+bd./(1+cd)))./(sin(ele)+ad./(sin(ele)+bd./(sin(ele)+cd)));
mw=(1+aw./(1+bw./(1+cw)))./(sin(ele)+aw./(sin(ele)+bw./(sin(ele)+cw)));
