clear 
Data_Am=20000;%Amount of output data for close-loop system
Data_G=1000;%Closed loop impulse response truncated data

sim_time=5;
KZQ_set(1:sim_time,1:3)=zeros(5,3);

KZQ_set(1,1:3)=[0.7249 -1.207 0.5186];%初始控制器 P(21.7%)LQG曲线上 λ=0.5
for sim_time_i=1:1:sim_time

kzq_fenzi=KZQ_set(sim_time_i,1:3);
%% 仿真计算实际方差  估算N P 
kzq_fenmu=[1 -1];
d=3; 
T_fenzi=[zeros(1,d) 0.6299];      %对象模型
T_fenmu=[1 -0.8899];
N_fenzi=[1 0];                 %扰动模型
N_fenmu=[1 -0.8899];
sat_alpha_set=1;%饱和度21%  
n_order=1;
t_order=1;

KZQ = filt(kzq_fenzi,kzq_fenmu); 
T = filt(T_fenzi,T_fenmu);
N = filt(N_fenzi,N_fenmu);
G=N/(1+T*KZQ);

sat_alpha=sat_alpha_set;
sim('Sat_Nonliner_3');%传入sat_alpha  *_fenzi  *_fenmu

%截取一段数据计算饱和度
start_data_i=100;
data_length=1000;
sat_num=0;
for i=start_data_i:1:(start_data_i+data_length)
if(abs(u_k(i))>sat_alpha)
    sat_num=sat_num+1;
end
end
sat_percent=sat_num/data_length*100;
Sat_Percent_set(sim_time_i)=sat_percent;

%计算仿真方差
var_u    =var(u_k);%输入方差
var_y    =var(y_k);%输出方差
std_u    =sqrt(var_u);%输入标准差
std_y    =sqrt(var_y);%输出标准差
Sim_Std_set(sim_time_i,1:2)=[std_y std_u];
% 仿真输出数据进行FCOR得到G_i 1000项
g_est=fc(y_k(1:Data_Am));%Fcor

%% 高鑫桐估计N  饱和P
g_est_gxt=g_est;
%g_est_gxt=g_theo';
N_order_case=n_order;%根据不同的N阶次修改
N_gxt_est=  estimate_N_Sxt(d,g_est_gxt(1:50),N_order_case);%时延 脉冲响应 模型阶次
G_sat_est=Tansfor(g_est_gxt(1:70)',0,9,50);%脉冲响应 时延 阶次 数据量λ（数据量越大越精确 一般是阶数的3倍就够）
T_gxt_est_temp=(N_gxt_est-G_sat_est)/(KZQ*G_sat_est);
%T_gxt_est_temp=(N-G)/(KZQ*G);
%T_gxt_est_temp= (N / G - 1) / KZQ;
imp_T_gxt_est_temp=impulse(T_gxt_est_temp);
imp_T_gxt_est_temp(1:d)=zeros(1,d);
length_imp_T=length(imp_T_gxt_est_temp);
if length_imp_T<50
    imp_T_gxt_est_temp(length_imp_T+1:50)=zeros(1,50-length_imp_T);
end
T_order=t_order;%根据不同的T阶次修改
T_gxt_est=Tansfor(imp_T_gxt_est_temp(1:50),d,T_order,15);

%% LQG计算最优方差和控制器
Lmd_Set = [1];  
LQG_3D = LQG_FPID(N_gxt_est, T_gxt_est, d, Lmd_Set);
KZQ_set(sim_time_i+1,1:3)=[LQG_3D(1,4:6)];
LQG_Std_set(sim_time_i,1:2)=LQG_3D(2:3);

end