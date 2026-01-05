%% 模型估计
clear 
Data_Am=80000;%Amount of output data for close-loop system
Data_G=1000;%Closed loop impulse response truncated data

%% 定义模型

%算例3-------------------------------------------------------------
kzq_fenzi_3=[0.7249 -1.207 0.5186];
kzq_fenmu_3=[1 -1];
T_fenzi_3=[zeros(1,3) 0.6299];
T_fenmu_3=[1 -0.8899];
N_fenzi_3=[1 0];
N_fenmu_3=[1 -0.8899];
KZQ_3 = filt(kzq_fenzi_3,kzq_fenmu_3 ); 
T_3 = filt(T_fenzi_3,T_fenmu_3);
N_3 = filt(N_fenzi_3,N_fenmu_3);
d_3=3;
sat_alpha_set_3=[5 ];%2.05--10%  1.75--20%  ...0--100%
%-------------------------------------------------------------
%算例4 Liu delayed coking furnace of petrochemical process-------------------------------------------------------------
kzq_fenzi_liu=[0.724938684, -1.207371481, 0.518604416];
kzq_fenmu_liu=[1 -1];
T_fenzi_liu=[zeros(1,6) 0.2155];
T_fenmu_liu=[1 -0.9418];
N_fenzi_liu=[1 4.821];
N_fenmu_liu=[1 -0.8899];
KZQ_liu = filt(kzq_fenzi_3,kzq_fenmu_3 ); 
T_liu = filt(T_fenzi_3,T_fenmu_3);
N_liu = filt(N_fenzi_3,N_fenmu_3);
d_liu=3;
sat_alpha_set_liu=[1000 ];%2.05--10%  1.75--20%  ...0--100%


%% 选择模型
kzq_fenzi=kzq_fenzi_liu;
kzq_fenmu=kzq_fenmu_liu;
T_fenzi=T_fenzi_liu;
T_fenmu=T_fenmu_liu;
N_fenzi=N_fenzi_liu;
N_fenmu=N_fenmu_liu;
KZQ = KZQ_liu;
T = T_liu;
N = N_liu;
d = d_liu;
sat_alpha_set=sat_alpha_set_liu;
G=N/(1+T*KZQ);
%% 算例* 不同饱和度 simlink仿真(_________________________________________________
%初始化
Sat_percent=zeros(1,length(sat_alpha_set));
g_est=zeros(length(sat_alpha_set),1001);
var_u    =zeros(1,length(sat_alpha_set));
var_sat_u=zeros(1,length(sat_alpha_set));
var_y    =zeros(1,length(sat_alpha_set));
for sat_alpha_i=1:1:length(sat_alpha_set)%遍历饱和度
    sat_alpha=sat_alpha_set(sat_alpha_i);
    sim('Sat_Nonliner_Gao.mdl');%传入sat_alpha  *_fenzi  *_fenmu
    %计算饱和度
    sat_num=0;
    sat_num_all=1000;
    for i=1:1:sat_num_all
        if(abs(u_k(i))>sat_alpha_set(sat_alpha_i)) 
            sat_num=sat_num+1;
        end
    end
    Sat_percent(sat_alpha_i)=sat_num/sat_num_all*100;
    %计算仿真方差
    var_u(sat_alpha_i)    =var(u_k);%输入方差
    var_sat_u(sat_alpha_i)=var(sat_u_k);%饱和输入方差
    var_y(sat_alpha_i)=var(y_k);%输出方差
    % 仿真输出数据进行FCOR得到G_i 1000项
    g_est(sat_alpha_i,:)=fc(y_k(1:Data_Am));%Fcor
end
%% _________________________________________________

%% 采集仿真数据
% Sat_percent_1=Sat_percent;
% g_est_1=g_est;
% var_n_case_3=var(n_k).^0.5;
%1.方差
var_y_case_3=var_y.^0.5;
var_u_case_3=var_u.^0.5;
var_sat_u_case_3=var_sat_u.^0.5;
%2.饱和度
Sat_percent_3=Sat_percent;
%3.闭环脉冲响应
g_est_3=g_est;

%% 高鑫桐估计N
g_est_gxt=g_est_3;
for sat_percent_i=1:1:length(sat_alpha_set)
    N_order_case=2;%根据不同的N阶次修改
    N_gxt_est(sat_percent_i)=  estimate_N_Sxt(d,g_est_gxt(sat_percent_i,1:50),N_order_case);
    G_sat_est(sat_percent_i)=Tansfor(g_est_gxt(sat_percent_i,1:100)',0,12,30);
    T_gxt_est_temp=(N_gxt_est(sat_percent_i)-G_sat_est(sat_percent_i))/(KZQ*G_sat_est(sat_percent_i));
    imp_T_gxt_est_temp=impulse(T_gxt_est_temp);
    imp_T_gxt_est_temp(1:d)=zeros(1,d);
    T_order=1;%根据不同的T阶次修改
    T_gxt_est(sat_percent_i)=Tansfor(imp_T_gxt_est_temp(1:35),d,T_order,25);
end



T_i=impulse(T,1:50);
N_i=impulse(N,1:50);
T_est_i=impulse(T_gxt_est,1:50);
N_est_i=impulse(N_gxt_est,1:50);
figure;
% 绘制 N 的真实值与估计值
subplot(2,1,1);
plot(1:50, N_i, 'b', 'LineWidth', 1.5); hold on;
plot(1:50, N_est_i, 'r--', 'LineWidth', 1.5);
title('N 的脉冲响应：真实 vs 估计');
xlabel('时间步 (samples)');
ylabel('幅值');
legend('真实值', '估计值');
grid on;
ylim([min(N_i) - 0.1*(max(N_i)-min(N_i)), max(N_i) + 0.1*(max(N_i)-min(N_i))]);
% 绘制 T 的真实值与估计值
subplot(2,1,2);
plot(1:50, T_i, 'g', 'LineWidth', 1.5); hold on;
plot(1:50, T_est_i, 'm--', 'LineWidth', 1.5);
title('T 的脉冲响应：真实 vs 估计');
xlabel('时间步 (samples)');
ylabel('幅值');
legend('真实值', '估计值');
grid on;
ylim([min(T_i) - 0.1*(max(T_i)-min(T_i)), max(T_i) + 0.1*(max(T_i)-min(T_i))]);

sgtitle('系统脉冲响应对比图'); % 总标题（适用于 R2018b 及以上）