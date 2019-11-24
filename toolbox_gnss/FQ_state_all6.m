function [F,Q]=FQ_state_all6(nx,dt,est_prm,mode,INS)
%-------------------------------------------------------------------------------
% Function : 状態遷移行列・システム雑音行列生成
% 
% [argin]
% nx       : 状態変数の次元
% dt       : 更新間隔[sec]
% est_prm  : パラメータ設定値
% mode     : 測位モード(1:Point用, 2:Relative用)
% 
% [argout]
% F : 状態遷移行列
% Q : システム雑音共分散行列
% 
% システム雑音で更新間隔を考慮するように修正
% 
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Feb. 25, 2009
%-------------------------------------------------------------------------------
% 電離層二重差推定時に対応
% January 24, 2010, T.Yanase
%-------------------------------------------------------------------------------

% F,Qの設定(mode 1:Point用, 3:VPPP用, 6:Relative DD用, 7:DGPS用)
%-------------------------------------------------------------------------------

switch mode
case 1
	F=blkdiag(F_state_u(est_prm,dt),F_state_t(est_prm,dt),1);									% F(受信機位置,受信機時計誤差)
	Q=blkdiag(Q_state_u(est_prm,dt),Q_state_t(est_prm,dt),est_prm.statemodel.std_walking);									% Q(受信機位置,受信機時計誤差)
    F(1,9) = INS(1);
    F(2,9) = INS(2);
    if find([3,4,5,6,7,8,9]==est_prm.obsmodel)
		if est_prm.statemodel.hw==1															% 受信機HWB
			F=blkdiag(F,eye(nx.b)*est_prm.statemodel.alpha_b);
			Q=blkdiag(Q,eye(nx.b)*est_prm.statemodel.std_dev_b^2);
		end
		if est_prm.statemodel.trop ~= 0														% 対流圏遅延
			switch est_prm.statemodel.trop
			case 1
				F=blkdiag(F,est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,est_prm.statemodel.std_dev_T^2*dt);
			case 2
				F=blkdiag(F,est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,est_prm.statemodel.std_dev_T^2*dt);
			case 3
				F=blkdiag(F,est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,2*est_prm.statemodel.std_dev_T^2*dt);
				F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_T)^2*dt);
			case 4
				F=blkdiag(F,est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,2*est_prm.statemodel.std_dev_T^2*dt);
				F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_T)^2*dt);
			end
		end
		if est_prm.statemodel.ion ~= 0														% 電離層遅延
			switch est_prm.statemodel.ion
			case 1
				F=blkdiag(F,est_prm.statemodel.alpha_i);
				Q=blkdiag(Q,est_prm.statemodel.std_dev_i^2*dt);
			case 2
				F=blkdiag(F,[1 dt;0 1]);
				Q=blkdiag(Q,[dt+dt^3/3 dt^2/2;dt^2/2 dt]*est_prm.statemodel.std_dev_i^2);
			case 3
				F=blkdiag(F,est_prm.statemodel.alpha_i);
				Q=blkdiag(Q,2*est_prm.statemodel.std_dev_i^2*dt);
				F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_i);
				Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_i)^2*dt);
			end
		end
		if est_prm.statemodel.amb==1														% 整数値バイアス
			F=blkdiag(F,eye(nx.n)*est_prm.statemodel.alpha_n);
			Q=blkdiag(Q,eye(nx.n)*est_prm.statemodel.std_dev_n^2);
		end
	end

case 3,% 要変更
	F=blkdiag(F_state_u(est_prm,dt),F_state_u(est_prm,dt));									% F(受信機位置)
	Q=blkdiag(Q_state_u(est_prm,dt),Q_state_u(est_prm,dt));									% Q(受信機位置)
	if est_prm.mode==1
		F=blkdiag(F,F_state_t(est_prm,dt));													% F(受信機時計誤差)
		Q=blkdiag(Q,Q_state_t(est_prm,dt));													% Q(受信機時計誤差)
		if est_prm.statemodel.hw==1															% 受信機HWB
			F=blkdiag(F,eye(2*nx.b)*est_prm.statemodel.alpha_b);
			Q=blkdiag(Q,eye(2*nx.b)*est_prm.statemodel.std_dev_b^2);
		end
		if est_prm.statemodel.trop ~= 0														% 対流圏遅延
			switch est_prm.statemodel.trop
			case 1
				F=blkdiag(F,est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,est_prm.statemodel.std_dev_T^2*dt);
			case 2
				F=blkdiag(F,est_prm.statemodel.alpha_T);
				Q=blkdiag(Q,est_prm.statemodel.std_dev_T^2*dt);
			end
		end
		if est_prm.statemodel.amb==1														% 整数値バイアス
			F=blkdiag(F,eye(nx.n)*est_prm.statemodel.alpha_n);
			Q=blkdiag(Q,eye(nx.n)*est_prm.statemodel.std_dev_n^2);
		end
	elseif est_prm.mode==2
		if est_prm.statemodel.hw==1															% 受信機HWB
			F=blkdiag(F,eye(nx.b)*est_prm.statemodel.alpha_b);
			Q=blkdiag(Q,eye(nx.b)*est_prm.statemodel.std_dev_b^2);
		end
		if est_prm.statemodel.amb==1														% 整数値バイアス
			F=blkdiag(F,eye(nx.n)*est_prm.statemodel.alpha_n);
			Q=blkdiag(Q,eye(nx.n)*est_prm.statemodel.std_dev_n^2);
		end
	end

case 6,
	F=F_state_u(est_prm,dt);																% F(受信機位置)
	Q=Q_state_u(est_prm,dt);																% Q(受信機位置)
	if est_prm.statemodel.trop ~= 0															% 対流圏遅延
		switch est_prm.statemodel.trop	% yanase
		case {1,2}
			F=blkdiag(F,est_prm.statemodel.alpha_T,est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,est_prm.statemodel.std_dev_T^2*dt,est_prm.statemodel.std_dev_T^2*dt);
		case 3
			F=blkdiag(F,est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,2*est_prm.statemodel.std_dev_T^2*dt);
			F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_T)^2*dt);
			F=blkdiag(F,est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,2*est_prm.statemodel.std_dev_T^2*dt);
			F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_T)^2*dt);
		case 4
			F=blkdiag(F,est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,2*est_prm.statemodel.std_dev_T^2*dt);
			F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_T)^2*dt);
			F=blkdiag(F,est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,2*est_prm.statemodel.std_dev_T^2*dt);
			F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_T);
			Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_T)^2*dt);
		end
	end
	if est_prm.statemodel.ion ~= 0															% 電離層遅延
		switch est_prm.statemodel.ion
		case {1,2,3,5}
			F=blkdiag(F,eye(nx.i)*est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,eye(nx.i)*est_prm.statemodel.std_dev_i^2*dt);
		case 4
			F=blkdiag(F,eye(4)*est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,eye(4)*(0.3*est_prm.statemodel.std_dev_i)^2*dt);
			F=blkdiag(F,eye(nx.i-4)*est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,eye(nx.i-4)*est_prm.statemodel.std_dev_i^2*dt);
% 			F=blkdiag(F,eye(nx.i-4)*est_prm.statemodel.alpha_i);
% 			Q=blkdiag(Q,eye(nx.i-4)*est_prm.statemodel.std_dev_i^2*dt);
% 			F=blkdiag(F,eye(4)*est_prm.statemodel.alpha_i);
% 			Q=blkdiag(Q,eye(4)*(0.3*est_prm.statemodel.std_dev_i)^2*dt);
		case 6
			F=blkdiag(F,[1 dt;0 1]);
			Q=blkdiag(Q,[dt+dt^3/3 dt^2/2;dt^2/2 dt]*est_prm.statemodel.std_dev_i^2);
			F=blkdiag(F,[1 dt;0 1]);
			Q=blkdiag(Q,[dt+dt^3/3 dt^2/2;dt^2/2 dt]*est_prm.statemodel.std_dev_i^2);
		case 7
			F=blkdiag(F,est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,2*est_prm.statemodel.std_dev_i^2*dt);
			F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_i)^2*dt);
			F=blkdiag(F,est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,2*est_prm.statemodel.std_dev_i^2*dt);
			F=blkdiag(F,eye(2)*est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,eye(2)*(0.3*est_prm.statemodel.std_dev_i)^2*dt);
		end
	end
	if est_prm.statemodel.amb == 1															% 整数値バイアス
		F=blkdiag(F,eye(nx.n)*est_prm.statemodel.alpha_n);
		Q=blkdiag(Q,eye(nx.n)*est_prm.statemodel.std_dev_n^2);
	end

case 7,
	F=F_state_u(est_prm,dt);																% F(受信機位置)
	Q=Q_state_u(est_prm,dt);																% Q(受信機位置)
	if est_prm.statemodel.trop ~= 0															% 対流圏遅延
		F=blkdiag(F,est_prm.statemodel.alpha_T,est_prm.statemodel.alpha_T);
		Q=blkdiag(Q,est_prm.statemodel.std_dev_T^2*dt,est_prm.statemodel.std_dev_T^2*dt);
	end
	if est_prm.statemodel.ion ~= 0															% 電離層遅延
		switch est_prm.statemodel.ion
		case {1,2,3,4}
			F=blkdiag(F,eye(nx.i)*est_prm.statemodel.alpha_i);
			Q=blkdiag(Q,eye(nx.i)*est_prm.statemodel.std_dev_i^2*dt);
		case 5
			F=blkdiag(F,[1 dt;0 1]);
			Q=blkdiag(Q,[dt+dt^3/3 dt^2/2;dt^2/2 dt]*est_prm.statemodel.std_dev_i^2);
			F=blkdiag(F,[1 dt;0 1]);
			Q=blkdiag(Q,[dt+dt^3/3 dt^2/2;dt^2/2 dt]*est_prm.statemodel.std_dev_i^2);
		end
	end
end



%-------------------------------------------------------------------------------
% 以下, サブルーチン

% 移動体のモデル(状態遷移)
%--------------------------------------------
function F = F_state_u(est_prm,dt)

alpha_u=est_prm.statemodel.alpha_u;
alpha_v=est_prm.statemodel.alpha_v;
alpha_a=est_prm.statemodel.alpha_a;
alpha_j=est_prm.statemodel.alpha_j;
model=est_prm.statemodel.pos;

switch model
case 0, F=fcomb(alpha_u, alpha_u, alpha_u);
case 1, F=fcomb(F_velo(alpha_v,dt), F_velo(alpha_v,dt), F_velo(alpha_v,dt));
case 2, F=fcomb(F_singer(alpha_a,dt), F_singer(alpha_a,dt), F_singer(alpha_a,dt));
case 3, F=fcomb(F_jerk(alpha_j,dt), F_jerk(alpha_j,dt), F_jerk(alpha_j,dt));
case 4, F=fcomb(alpha_u, alpha_u, alpha_u);
case 5, F=fcomb(F_singer(alpha_a,dt), F_singer(alpha_a,dt), F_velo(alpha_v,dt));
case 10, F=fcomb(F_velo(alpha_v,dt), F_velo(alpha_v,dt), F_velo(alpha_v,dt));
end


%	状態遷移行列   velo
%--------------------------------------------
function [Ft] = F_velo(alpha,dt)

f12 = ( 1 - exp( - alpha * dt ) ) / alpha;
f22 = exp( - alpha * dt );
Ft = [1 f12;  0 f22];


%	状態遷移行列   singer
%--------------------------------------------
function [Ft] = F_singer(alpha,dt)

f12 = dt;
f13 = ( - 1 + alpha * dt + exp( -alpha * dt ) ) / alpha^2;
f23 = ( 1 - exp( -alpha * dt ) ) / alpha;
f33 = exp( -alpha * dt );
Ft = [1 f12 f13;  0 1 f23;  0 0 f33];


%	状態遷移行列   jerk モデル
%--------------------------------------------
function [Ft] = F_jerk(alpha,dt)

f13 = (1/2) * dt^2;
f14 = ( 1 / (2*alpha^3) ) * ( 2 - 2 * alpha * dt  + alpha^2 * dt^2 - 2 * exp( - alpha * dt ) );
f24 = ( 1 / alpha^2 ) * ( - 1 + alpha * dt + exp( - alpha * dt ) );
f34 = ( 1 / alpha ) * ( 1 - exp( - alpha * dt ) );
f44 = exp( - alpha * dt );
Ft = [1 dt f13 f14;  0 1 dt f24;  0 0 1 f34;  0 0 0 f44];


% 移動体のモデル(システム雑音)
%--------------------------------------------
function Q = Q_state_u(est_prm,dt)

alpha_u=est_prm.statemodel.alpha_u;
alpha_v=est_prm.statemodel.alpha_v;
alpha_a=est_prm.statemodel.alpha_a;
alpha_j=est_prm.statemodel.alpha_j;
std_dev_u=est_prm.statemodel.std_dev_u;
std_dev_vx=est_prm.statemodel.std_dev_vx;
std_dev_vy=est_prm.statemodel.std_dev_vy;
std_dev_vz=est_prm.statemodel.std_dev_vz;
std_dev_a=est_prm.statemodel.std_dev_a;
std_dev_j=est_prm.statemodel.std_dev_j;
model=est_prm.statemodel.pos;

switch model
case 0, Q=qcomb(std_dev_u^2, std_dev_u^2, std_dev_u^2);
case 1, Q=qcomb(Q_velo(alpha_v,dt,std_dev_vx), Q_velo(alpha_v,dt,std_dev_vy), Q_velo(alpha_v,dt,std_dev_vz));
case 2, Q=qcomb(Q_singer(alpha_a,dt,std_dev_a), Q_singer(alpha_a,dt,std_dev_a), Q_singer(alpha_a,dt,std_dev_a));
case 3, Q=qcomb(Q_jerk(alpha_j,dt,std_dev_j), Q_jerk(alpha_j,dt,std_dev_j), Q_jerk(alpha_j,dt,std_dev_j));
case 4, Q=qcomb(std_dev_u^2, std_dev_u^2, std_dev_u^2);
case 5, Q=qcomb(Q_singer(alpha_a,dt,std_dev_a), Q_singer(alpha_a,dt,std_dev_a), Q_velo(alpha_v,dt,std_dev_v));
end


%	システム雑音共分散行列   velo
%--------------------------------------------
function [Qt] = Q_velo(alpha,dt,std_dev)

q11 = ( 1 / ( 2 * alpha^3 ) ) * ( - 3 + 2 * alpha * dt + 4 * exp( - alpha * dt ) - exp( - 2 * alpha * dt ) );
q12 = ( 1 / ( 2 * alpha^2 ) ) * ( 1 - 2 * exp( - alpha * dt ) + exp( - 2 * alpha * dt ) );
q22 = ( 1 / ( 2 * alpha ) ) * ( 1 - exp( - 2 * alpha * dt ) );
Qt = [q11 q12;  q12 q22];
Qt=2 * alpha * (std_dev)^2*Qt;

%	システム雑音共分散行列   singer
%--------------------------------------------
function [Qt] = Q_singer(alpha,dt,std_dev)

q11 = ( 1 / ( 2 * alpha^5 ) ) * ( 1 - exp( -2 * alpha * dt) + 2 * alpha * dt + 2 * alpha^3 * dt^3 / 3 - 2 * alpha^2 * dt^2 - 4 * alpha * dt * exp( -alpha * dt) );
q12 = ( 1 / ( 2 * alpha^4 ) ) * ( exp( -2 * alpha * dt ) + 1 - 2 * exp( -alpha * dt ) + 2 * alpha * dt * exp( -alpha * dt ) - 2 * alpha * dt + alpha^2 * dt^2 );
q13 = ( 1 / ( 2 * alpha^3 ) ) * ( 1 - exp( -2 * alpha * dt ) - 2 * alpha * dt * exp( -alpha * dt ) );
q22 = ( 1 / ( 2 * alpha^3 ) ) * ( 4 * exp( -alpha * dt ) - 3 - exp( -2 * alpha * dt) + 2 * alpha * dt );
q23 = ( 1 / ( 2 * alpha^2 ) ) * ( exp( -2 * alpha * dt ) + 1 - 2 * exp( -alpha * dt ) );
q33 = ( 1 / ( 2 * alpha ) ) * ( 1 - exp( -2 * alpha * dt ) );
Qt = [q11 q12 q13;  q12 q22 q23;  q13 q23 q33];
Qt=2 * alpha * (std_dev)^2*Qt;


%	システム雑音共分散行列   jerk
%--------------------------------------------
function [Qt] = Q_jerk(alpha,dt,std_dev)

q11 = ( 1 / ( 2 * alpha^7 ) ) * ( - 3 + 2 * alpha * dt - 2 * alpha^2 * dt^2 + 4 * alpha^3 * dt^3 / 3 - alpha^4 * dt^4 / 2 + alpha^5 * dt^5 / 10 + 4 * exp( - alpha * dt ) + 2 * alpha^2 *dt^2 * exp( - alpha * dt ) - exp( - 2 * alpha * dt ) );
q12 = ( 1 / ( 2 * alpha^6 ) ) * ( 1 - 2 * alpha * dt + 2 * alpha^2 * dt^2 - alpha^3 * dt^3 + exp( - 2 * alpha * dt ) + alpha^2 * dt^2 * exp( - alpha * dt ) + alpha^4 * dt^4 / 4 - 2 * exp( - alpha * dt ) + 2 * alpha * dt * exp( - alpha * dt ) ); 
q13 = ( 1 / ( 2 * alpha^5 ) ) * ( - 3 + 2 * alpha * dt - alpha^2 * dt^2 + alpha^3 * dt^3 /3 + 4 * exp( - alpha * dt ) + alpha^2 * dt^2 * exp( - alpha * dt ) - exp( - 2 * alpha * dt ) );
q14 = ( 1 / ( 2 * alpha^4 ) ) * ( 1 - 2 * exp( - alpha * dt ) - alpha^2 * dt^2 * exp( - alpha * dt ) + exp( - 2 * alpha * dt ) );
q22 = ( 1 / ( 2 * alpha^5 ) ) * ( 1 + 2 * alpha * dt - 2 * alpha^2 * dt^2 + 2 * alpha^3 * dt^3 / 3 - 4 * alpha * dt * exp( - alpha * dt ) - exp( - 2 * alpha * dt ) );
q23 = ( 1 / ( 2 * alpha^4 ) ) * ( 1 - 2 * alpha * dt + alpha^2 * dt^2 + 2 * alpha * dt * exp( - alpha * dt ) - 2 * exp( - alpha * dt ) + exp( - 2 * alpha * dt ) ) ;
q24 = ( 1 / ( 2 * alpha^3 ) ) * ( 1 - 2 * alpha * dt * exp( - alpha * dt ) - exp( - 2 * alpha * dt ) );
q33 = ( 1 / ( 2 * alpha^3 ) ) * ( - 3 + 2 * alpha * dt + 4 * exp( - alpha * dt ) - exp( - 2 * alpha * dt ) );
q34 = ( 1 / ( 2 * alpha^2 ) ) * ( 1 - 2 * exp( - alpha * dt ) + exp( - 2 * alpha * dt ) );
q44 = ( 1 / ( 2 * alpha   ) ) * ( 1 - exp( - 2 * alpha * dt ) );
Qt = [q11 q12 q13 q14;  q12 q22 q23 q24;  q13 q23 q33 q34;  q14 q24 q34 q44];
Qt=2 * alpha * (std_dev)^2*Qt;


% 受信機時計誤差のモデル(状態遷移)
%--------------------------------------------
function F=F_state_t(est_prm,dt)

if est_prm.statemodel.dt==0								% 受信機時計誤差
	F=est_prm.statemodel.alpha_t;
elseif est_prm.statemodel.dt==1
	F=[1 dt;0 1];
end


% 受信機時計誤差のモデル(システム雑音)
%--------------------------------------------
function Q=Q_state_t(est_prm,dt)

% sb=est_prm.statemodel.std_dev_tb^2;					% バイアス成分の分散(4e-19)
% sd=est_prm.statemodel.std_dev_td^2;					% ドリフト成分の分散(15e-19)
if est_prm.statemodel.dt==0								% 受信機時計誤差
	Q=est_prm.statemodel.std_dev_t^2;
% 	Q=sb;
elseif est_prm.statemodel.dt==1
	Q=[dt+dt^3/3 dt^2/2;dt^2/2 dt]*est_prm.statemodel.std_dev_t^2;

% 	C=299792458;							% 光速
% 	sb=4e-19*C;
% 	sd=15e-19*C;
% 	Q=[sb*dt+sd*dt^3/3 sd*dt^2/2;sd*dt^2/2 sd*dt];
end


% XYZのモデルの結合 --- 状態遷移行列
%--------------------------------------------
function Ft=fcomb(Ftx,Fty,Ftz)

dimx=length(Ftx); dimy=length(Fty); dimz=length(Ftz);

indx=[]; indy=[]; indz=[]; ind=1:dimx+dimy+dimz;
for i=1:max([dimx,dimy,dimz])
	if i<=dimx, indx=[indx ind(1)]; ind(1)=[];, end
	if i<=dimy, indy=[indy ind(1)]; ind(1)=[];, end
	if i<=dimz, indz=[indz ind(1)]; ind(1)=[];, end
end

for i=1:dimx, Ft(indx(i),indx(i:end))=Ftx(i,i:end);, end
for i=1:dimy, Ft(indy(i),indy(i:end))=Fty(i,i:end);, end
for i=1:dimz, Ft(indz(i),indz(i:end))=Ftz(i,i:end);, end


% XYZのモデルの結合 --- システム雑音行列
%--------------------------------------------
function Qt=qcomb(Qtx,Qty,Qtz)

dimx=length(Qtx); dimy=length(Qty); dimz=length(Qtz);

indx=[]; indy=[]; indz=[]; ind=1:dimx+dimy+dimz;
for i=1:max([dimx,dimy,dimz])
	if i<=dimx, indx=[indx ind(1)]; ind(1)=[];, end
	if i<=dimy, indy=[indy ind(1)]; ind(1)=[];, end
	if i<=dimz, indz=[indz ind(1)]; ind(1)=[];, end
end

for i=1:dimx, Qt(indx(i),indx(i:end))=Qtx(i,i:end); Qt(indx(i:end),indx(i))=Qtx(i,i:end);, end
for i=1:dimy, Qt(indy(i),indy(i:end))=Qty(i,i:end); Qt(indy(i:end),indy(i))=Qty(i,i:end);, end
for i=1:dimz, Qt(indz(i),indz(i:end))=Qtz(i,i:end); Qt(indz(i:end),indz(i))=Qtz(i,i:end);, end


