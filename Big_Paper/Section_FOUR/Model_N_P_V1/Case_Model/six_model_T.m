%% 1. FOLPD  (文献结构 + 随机阶跃扰动)
d = 4;
P_fenzi=[zeros(1,d) 0.09516];
P_fenmu=[1 -0.9048];
N_fenzi=[0.05 -0.04917];
N_fenmu=[1 -1];
KZQ = filt([1.20 -1.85 0.70],[1 -1]);   % 新PID，稳定

%% 2. Unstable-FOLPD  (文献结构 + 一阶有色)
d = 3;
P_fenzi=[zeros(1,d) 0.1052];
P_fenmu=[1 -1.105];
N_fenzi=[0.04877];
N_fenmu=[1 -0.9512];
KZQ = filt([1.35 -2.10 0.80],[1 -1]);

%% 3. IPD  (文献结构 + 一阶有色)
d = 6;
P_fenzi=[zeros(1,d) 1];
P_fenmu=[1 -1];
N_fenzi=[0.0323];
N_fenmu=[1 -0.9672];
KZQ = filt([0.48 -0.70 0.25],[1 -1]);

%% 4. FOLIPD  (文献结构 + 一阶有色)
d = 6;
P_fenzi=[zeros(1,d-1) 0.2838 0.0903];
P_fenmu=[1 -1.6065 0.6065];
N_fenzi=[0.0237];
N_fenmu=[1 -0.9608];
KZQ = filt([0.65 -1.00 0.38],[1 -1]);

%% 5. SOSPD  (文献结构 + 随机阶跃)
d = 5;
P_fenzi=[zeros(1,d) 0.0099 0.0181];
P_fenmu=[1 -1.7235 0.7408];
N_fenzi=[0.03 -0.0297];
N_fenmu=[1 -1];
KZQ = filt([0.90 -1.40 0.53],[1 -1]);

%% 6. I2PD  (文献结构 + 一阶有色)
d = 6;
P_fenzi=[zeros(1,d-1) 0.5 0.5];
P_fenmu=[1 -2 1];
N_fenzi=[0.000487];
N_fenmu=[1 -0.9753];
KZQ = filt([0.08 -0.12 0.045],[1 -1]);

P = filt(P_fenzi,P_fenmu);
N = filt(N_fenzi,N_fenmu);
KZQ = filt([0.08 -0.12 0.045],[1 -1]);
G = N/(1+P*KZQ);