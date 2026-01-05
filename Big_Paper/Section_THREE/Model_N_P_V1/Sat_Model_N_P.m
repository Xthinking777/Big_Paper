%% 模型估计
clear 
Data_Am=20000;%Amount of output data for close-loop system
Data_G=1000;%Closed loop impulse response truncated data

%% 选择模型
model=1;
if model==1%算例高鑫桐-----------------------------------------------------
    kzq_fenzi=[0.7249 -1.207 0.5186]; %控制器
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,3) 0.6299];      %对象模型
    T_fenmu=[1 -0.8899];
    N_fenzi=[1 0];                 %扰动模型
    N_fenmu=[1 -0.8899];
    d=3;                              %时延
    sat_alpha_set=100;
    n_order=1;
    t_order=1;
elseif model==2%算例Zhe Liu-----------------------------------------------------
    kzq_fenzi=[0.8541 -1.4616 0.6076]*3; %控制器 λ=0.3
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,6) 0.2155];      %对象模型
    T_fenmu=[1 -0.9418];
    %扰动模型 N(z) 是非最小相位 or 高增益，但 ARMA 无法准确捕捉分子动态 增益太大
    N_fenzi=[1 4.821];                 %扰动模型 0.821->T  4.821->N(当4.821求T会发散)
    N_fenmu=[1 -0.8899];
    d=6;  
    sat_alpha_set=100;
    n_order=1;
    t_order=1;

 elseif model==3%算例澎湃--------------------------------------------------
    d = 5;
    kzq_fenzi=[2.841 -4.406  1.749];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.2];
    T_fenmu=[1 -0.8];
    N_fenzi=[1 0];
    N_fenmu=[1 -0.1 -0.2];
    sat_alpha_set=100;
    n_order=2;
    t_order=1;
 elseif model==4%算例澎湃--------------------------------------------------
    d = 6;
    kzq_fenzi=[0.8305 -1.396  0.607];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 1];
    T_fenmu=[1 -0.8];
    N_fenzi=[1 0.6];
    N_fenmu=[1 0.1 -0.67 -0.025 0.105];
    sat_alpha_set=100;
    n_order=5;
    t_order=1;
end

KZQ = filt(kzq_fenzi,kzq_fenmu); 
T = filt(T_fenzi,T_fenmu);
N = filt(N_fenzi,N_fenmu);
G=N/(1+T*KZQ);

%% simlink仿真(_________________________________________________
sat_alpha=sat_alpha_set;
sim('Sat_Nonliner_3');%传入sat_alpha  *_fenzi  *_fenmu


%计算仿真方差
var_u    =var(u_k);%输入方差
var_y    =var(y_k);%输出方差
std_u    =sqrt(var_u);%输入标准差
std_y    =sqrt(var_y);%输出标准差
% 仿真输出数据进行FCOR得到G_i 1000项

g_est=fc(y_k(1:Data_Am));%Fcor
%修正LIU算例闭环脉冲响应
% if model==2
% g_est=est_g_i_LIU()';
% end

%% FCOR估计闭环脉冲响应_________________________________________________
length=47;
g_theo=impulse(G);
if model==2
   g_est(1:3) =g_theo(1:3);
end
figure;
plot(0:length-1,g_est(1:length),'b--',0:length-1,g_theo(1:length),'r-');
hold on;


%% 高鑫桐估计N  饱和P
g_est_gxt=g_est;
%g_est_gxt=g_theo';
N_order_case=n_order;%根据不同的N阶次修改
N_gxt_est=  estimate_N_Sxt(d,g_est_gxt(1:50),N_order_case);%时延 脉冲响应 模型阶次
G_sat_est=Tansfor(g_est_gxt(1:70)',0,9,50);%脉冲响应 时延 阶次 数据量λ
T_gxt_est_temp=(N_gxt_est-G_sat_est)/(KZQ*G_sat_est);
%MATLAB 没有自动约简，反而将所有极点/零点展开，导致 T_est 变成一个 高阶、病态、非最小实现 的模型。
%T_gxt_est_temp=(N-G)/(KZQ*G);
%T_gxt_est_temp= (N / G - 1) / KZQ;
imp_T_gxt_est_temp=impulse(T_gxt_est_temp);
imp_T_gxt_est_temp(1:d)=zeros(1,d);
T_order=t_order;%根据不同的T阶次修改
T_gxt_est=Tansfor(imp_T_gxt_est_temp(1:47),d,T_order,30);


%% 绘制脉冲响应对比图
% 设置时间点
t = 0:49; % 50个点

% 计算脉冲响应
imp_N = impulse(N, t);
imp_N_est = impulse(N_gxt_est, t);

imp_T = impulse(T, t);
imp_T_est = impulse(T_gxt_est, t);

% % 绘制N和N_gxt_est对比图
% figure;
% subplot(2,1,1);
% plot(t, imp_N, 'b-', 'LineWidth', 1.5, 'DisplayName', 'N');
% hold on;
% plot(t, imp_N_est, 'r--', 'LineWidth', 1.5, 'DisplayName', 'N_{gxt\_est}');
% xlabel('时间点');
% ylabel('幅值');
% title('N和N_{gxt\_est}脉冲响应对比');
% legend;
% grid on;

% % 绘制T和T_gxt_est对比图
% subplot(2,1,2);
% plot(t, imp_T, 'b-', 'LineWidth', 1.5, 'DisplayName', 'T');
% hold on;
% plot(t, imp_T_est, 'r--', 'LineWidth', 1.5, 'DisplayName', 'T_{gxt\_est}');
% xlabel('时间点');
% ylabel('幅值');
% title('T和T_{gxt\_est}脉冲响应对比');
% legend;
% grid on;



% 绘制N和N_gxt_est对比图（独立窗口1）
figure('Name', 'N脉冲响应对比', 'NumberTitle', 'off'); % 设置窗口名称，关闭默认编号
plot(t, imp_N, 'b-*', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '理论值');
hold on;
plot(t, imp_N_est, 'r-->', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '估计值');
xlabel('采样时间');
ylabel('幅值');
title('脉冲响应对比');
legend('Location', 'best'); % 自动选择最佳图例位置
box on; % 显示边框
set(gca, 'FontSize', 10); % 设置坐标轴字体大小

% 绘制T和T_gxt_est对比图（独立窗口2）
figure('Name', 'T脉冲响应对比', 'NumberTitle', 'off'); % 第二个独立窗口
plot(t, imp_T, 'b-<', 'LineWidth', 1,'MarkerSize', 4,'DisplayName', '理论值');
hold on;
plot(t, imp_T_gxt_est_temp(1:50), 'k--o', 'LineWidth', 1,'MarkerSize', 4, 'DisplayName', '估计值');
plot(t, imp_T_est, 'r--*', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '参数化估计值');
xlabel('采样时间');
ylabel('幅值');
title('脉冲响应对比');
legend('Location', 'best');
box on;
set(gca, 'FontSize', 10);


% t = 0:49; % 50个点
% imp_KZQ = impulse(KZQ, t);
% 
% plot(t,imp_KZQ);