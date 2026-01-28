%% 模型估计
close all; clear; clc;
Data_Am=20000;%Amount of output data for close-loop system
Data_G=1000;%Closed loop impulse response truncated data

%% 选择模型
model=1;
jifen_N=0;%N是否有积分
if model==1% FOLPD (一阶加纯滞后) 高 第三章 算例1--------------------------------------------------
    d = 6;
    kzq_fenzi=[0.725 -1.21 0.519];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 1];
    T_fenmu=[1 -0.8];
    N_fenzi=[1 -0.2];
    N_fenmu=[1 -1.4 0.23 0.23 -0.06];
    sat_alpha_set=100;%  0.87-30%  0.96-20%  1.15-10%
    t_order=1;%一阶
    jifen_N=1;%N是否有积分
elseif model==2% IPD--------------------------------------------------
    d = 6;
    kzq_fenzi=[0.8 -1.3 0.5];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.5];
    T_fenmu=[1 -1];
    N_fenzi=[0.15];
    N_fenmu=[1 -0.85];
    sat_alpha_set=100;%  0.87-30%  0.96-20%  1.15-10%
    t_order=1;
elseif model==3%Unstable-FOLPD (不稳定一阶加纯滞后)--------------------------------------------------
    d = 3;
    kzq_fenzi=[4.5 -7.2 2.8];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.2];
    T_fenmu=[1 -1.1];
    N_fenzi=[0.05];
    N_fenmu=[1 -0.9];
    sat_alpha_set=100;%  0.87-30%  0.96-20%  1.15-10%
    t_order=1;%一阶
elseif model==4%I2PD (双重积分加纯滞后)--------------------------------------------------
    d = 3;
    kzq_fenzi=[2.5 -4.5 2.0];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.1];
    T_fenmu=[1 -2 1];
    N_fenzi=[0.1];
    N_fenmu=[1 -0.9];
    sat_alpha_set=100;%  0.87-30%  0.96-20%  1.15-10%
    t_order=2;%一阶
elseif model==5%FOLIPD (一阶积分加纯滞后)--------------------------------------------------
    d = 5;
    kzq_fenzi=[0.4 -0.68 0.29];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 0.3];
    T_fenmu=[1 -1.8 0.8];
    N_fenzi=[0.12];
    N_fenmu=[1 -0.88];
    sat_alpha_set=100;%  0.87-30%  0.96-20%  1.15-10%
    t_order=3;
elseif model==51%FOLIPD (一阶积分加纯滞后) 朱宁 第三章算例四（发散）-----------------------------   
    d = 2;
    kzq_fenzi=[1.08 -2 0.86]*0.01;
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 1 0.5];
    T_fenmu=[1 -1.7 0.7];
    % N_fenzi=[1 -0.9];
    % N_fenmu=[1 -1.7 0.7];
    N_fenzi=[1 ];
    N_fenmu=[1 -0.8];
    sat_alpha_set=100;%  0.87-30%  0.96-20%  1.15-10%
    t_order=1;
    jifen_N=1;%N是否有积分
elseif model==6%SOSPD (二阶加纯滞后)高 第三章 算例三--------------------------------------------------
    d = 7;
    kzq_fenzi=[23.6 -44.7 21.3];
    kzq_fenmu=[1 -1];
    T_fenzi=[zeros(1,d) 4.679 4.377]*0.001;
    T_fenmu=[1 -1.81 0.8187];
    N_fenzi=[0.07889 -0.07463];
    N_fenmu=[1 -1.8465 0.8465];
    jifen_N=1;%有积分环节
    sat_alpha_set=100;
    n_order=1;
    t_order=3;%一阶
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
data_length=1000;
sat_num=0;
for i=start_data_i:1:(start_data_i+data_length)
if(abs(u_k(i))>sat_alpha)
    sat_num=sat_num+1;
end
end
sat_percent=sat_num/data_length*100;


%计算仿真方差
var_u    =var(u_k);%输入方差
var_y    =var(y_k);%输出方差
std_u    =sqrt(var_u);%输入标准差
std_y    =sqrt(var_y);%输出标准差
% 仿真输出数据进行FCOR得到G_i 1000项

g_est=fc(y_k(1:Data_Am));%Fcor

%% FCOR估计闭环脉冲响应_________________________________________________
length_G=50;
g_theo=impulse(G);
length_G=min(length_G,length(g_theo));

% 绘制G_i和g_est对比图（独立窗口1）
figure('Name', 'G脉冲响应对比', 'NumberTitle', 'off'); % 设置窗口名称，关闭默认编号
plot(0:length_G-1, g_theo(1:length_G), 'b->', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '理论值');
hold on;
plot(0:length_G-1, g_theo(1:length_G), 'r-->', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '估计值');
xlabel('采样时间');
ylabel('幅值');
title('脉冲响应对比');
legend('Location', 'best'); % 自动选择最佳图例位置
box on; % 显示边框
set(gca, 'FontSize', 10); % 设置坐标轴字体大小


%% 高鑫桐估计N  饱和P

denG = G.den{1};               % 分母系数向量（按z^{-1}升幂排列）
order_denG = length(denG) - 1; % 分母阶数
G_sat_est=Tansfor(g_est(1:100)',0,order_denG,50);

if jifen_N==0   %默认无积分
    jifen=1;
    g_est_gxt=g_est;
elseif jifen_N==1%有积分环节
    jifen=filt(1,[1 -1]);
    %G_sat_est_de_jifen=G_sat_est/jifen;%去除积分
    G_sat_est_de_jifen=G/jifen;%去除积分(效果不好用理论值)
    g_est_gxt=impulse(G_sat_est_de_jifen);
end

N_gxt_est_temp=  estimate_N_xxq(d,g_est_gxt(1:50),N_fenzi,N_fenmu)*jifen;%时延 脉冲响应 模型阶次  N=[x1 x2]/[1+x3+x4+...]
%G_sat_est=Tansfor(g_est_gxt(1:70)',0,9,50);%脉冲响应 时延 阶次 数据量λ（数据量越大越精确 一般是阶数的3倍就够）
T_gxt_est_temp=(N_gxt_est_temp-G_sat_est)/(KZQ*G_sat_est);
%T_gxt_est_temp=(N_gxt_est_temp-G)/(KZQ*G);
imp_T_gxt_est_temp=impulse(T_gxt_est_temp);
imp_T_gxt_est_temp(1:d)=zeros(1,d);
length_imp_T=length(imp_T_gxt_est_temp);
if length_imp_T<50
    imp_T_gxt_est_temp(length_imp_T+1:50)=zeros(1,50-length_imp_T);
end
T_order=t_order;%根据不同的T阶次修改
T_gxt_est=Tansfor(imp_T_gxt_est_temp(1:50),d,T_order,15);


%% 绘制脉冲响应对比图
% 设置时间点
t = 0:99; % 50个点

% 计算脉冲响应
N_gxt_est = simplify_tf_small_coeff(N_gxt_est_temp, 2e-3);%去除接近0项 约0
imp_N = impulse(N, t);
imp_N_est = impulse(N_gxt_est, t);

imp_T = impulse(T, t);
imp_T_alpha=imp_T.*(1-sat_percent*0.01);%理论*饱和修正系数
imp_T_est = impulse(T_gxt_est, t);

% 绘制N和N_gxt_est对比图（独立窗口1）
figure('Name', 'N脉冲响应对比', 'NumberTitle', 'off'); % 设置窗口名称，关闭默认编号
plot(t, imp_N, 'b->', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '理论值');
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
plot(t, imp_T, 'b->', 'LineWidth', 1,'MarkerSize', 4,'DisplayName', '理论值');
hold on;
plot(t, imp_T_alpha, 'b-->', 'LineWidth', 1,'MarkerSize', 4,'DisplayName', '饱和理论值');
%plot(t, imp_T_gxt_est_temp(1:50), 'k--o', 'LineWidth', 1,'MarkerSize', 4, 'DisplayName', '非参数化估计值');
plot(t, imp_T_est, 'r-->', 'LineWidth', 1, 'MarkerSize', 4,'DisplayName', '参数化估计值');
xlabel('采样时间');
ylabel('幅值');
title('脉冲响应对比');
legend('Location', 'best');
box on;
set(gca, 'FontSize', 10);