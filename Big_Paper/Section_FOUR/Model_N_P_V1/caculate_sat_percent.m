%% 模型估计
clear 
Data_Am=20000;%Amount of output data for close-loop system
Data_G=1000;%Closed loop impulse response truncated data

%% 选择模型
model=4;
if model==1%算例一澎湃--------------------------------------------------
    d = 5;
    kzq_fenzi=[2.841 -4.406  1.749];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.2];
    T_fenmu=[1 -0.8];
    N_fenzi=[1 0];
    N_fenmu=[1 -0.1 -0.2];
    sat_alpha_set=2.5;%  2.5-50%  3.9-30%   4.9-20%  5.4-15% 6.4-10%  10-0%
    n_order=2;
    t_order=1;

 elseif model==2%算例二澎湃--------------------------------------------------
    d = 6;
    kzq_fenzi=[0.8305 -1.396  0.607];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 1];
    T_fenmu=[1 -0.8];
    N_fenzi=[1 0.6];
    N_fenmu=[1 0.1 -0.67 -0.025 0.105];
    sat_alpha_set=1.38;%  0.8-50%   1.05-40%   1.38-30%  1.85-20%  2.5-10%  5-0%
    n_order=5;
    t_order=1;
  elseif model==3%算例三澎湃--------------------------------------------------
    d = 3;
    kzq_fenzi=[6.533 -9.236  3.357];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.1];
    T_fenmu=[1 -0.8];
    N_fenzi=[1 0];
    N_fenmu=[1 -0.5 ];
    sat_alpha_set=30;%8-30%  9.8-20%  11.9-10%  30-0%
    n_order=1;
    t_order=1;
  elseif model==4%算例四澎湃--------------------------------------------------
    d = 3;
    kzq_fenzi=[6.286 -8.814  3.163];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.1];
    T_fenmu=[1 -0.8];
    N_fenzi=[0.1 0];
    N_fenmu=[1 -0.3 -0.1 ];
    sat_alpha_set=0.87;%  0.87-30%  0.96-20%  1.15-10%
    n_order=2;
    t_order=1;
end

KZQ = filt(kzq_fenzi,kzq_fenmu); 
T = filt(T_fenzi,T_fenmu);
N = filt(N_fenzi,N_fenmu);
G=N/(1+T*KZQ);

%% simlink仿真(_________________________________________________
sat_alpha=sat_alpha_set;
sim('Sat_Nonliner_3');%传入sat_alpha  *_fenzi  *_fenmu

%截取一段数据计算饱和度
start_data_i=100;
data_length=100;
sat_num=0;
for i=start_data_i:1:(start_data_i+data_length)
if(abs(u_k(i))>sat_alpha)
    sat_num=sat_num+1;
end
end
sat_percent=sat_num/data_length*100;


sat_percent