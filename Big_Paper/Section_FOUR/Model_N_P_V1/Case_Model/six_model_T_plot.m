close all; clear; clc;

% ===================== 系统参数（使用结构体提高可读性） =====================

% 系统1: FOLPD (一阶加纯滞后)
sys1.P_num = [zeros(1,6) 1];      % P(z) = z^{-4} / (1 - 0.8z^{-1})
sys1.P_den = [1 -0.8];
sys1.N_num = [1 -0.2];                 % N(z) = 0.2 / (1 - 0.9z^{-1})  一阶惯性扰动，时间常数较大（0.9接近1），衰减较慢
sys1.N_den = [1 -0.4 -0.17 0.06]; %(1-0.3)(1+0.4)(1-0.5)
sys1.KZQ_num = [0.5 -0.75 0.28];  % Kp = 0.5, Ki = 0.75, Kd = 0.28
sys1.KZQ_den = [1 -1];
sys1.name = 'FOLPD';

% 系统2: IPD (积分加纯滞后) - 增大幅值并加快收敛
sys2.P_num = [zeros(1,6) 0.5];    % P(z) = 0.5z^{-6} / (1 - z^{-1})
sys2.P_den = [1 -1];              % 积分环节：极点z=1
sys2.N_num = 0.15;                % 适中扰动幅值
sys2.N_den = [1 -0.85];           % 较快衰减的扰动
sys2.KZQ_num = [0.8 -1.3 0.5];    % 调整PID参数，平衡响应
sys2.KZQ_den = [1 -1];
sys2.name = 'IPD';

% 系统3: Unstable-FOLPD (不稳定一阶加纯滞后)
sys3.P_num = [zeros(1,3) 0.2];    % P(z) = 0.2z^{-3} / (1 - 1.1z^{-1})
sys3.P_den = [1 -1.1];            % 不稳定极点 1.1 > 1
sys3.N_num = 0.05;                % N(z) = 0.05 / (1 - 0.9z^{-1})
sys3.N_den = [1 -0.9];
sys3.KZQ_num = [4.5 -7.2 2.8];    % 强PID补偿不稳定对象
sys3.KZQ_den = [1 -1];
sys3.name = 'Unstable-FOLPD';

% 系统4: I2PD (双重积分加纯滞后) - 完整无遗漏（仅改数值，解决发散，保留所有原结构）
sys4.P_num = [zeros(1,3) 0.1];  % 仅修改：增益降至0.0008（抵消5拍滞后的强不稳定性）
sys4.P_den = [1 -2 1];            % 保持不变：双重积分分母
sys4.N_num = 0.1;               % 仅修改：扰动幅值降至0.005（避免干扰稳定）
sys4.N_den = [1 -0.9];            % 完全保留原参数：快速衰减扰动分母，无任何修改
sys4.KZQ_num = [2.5 -4.5 2.0];    % 仅修改：PID参数优化（强阻尼，避免发散）
sys4.KZQ_den = [1 -1];            % 保持不变：PID控制器分母
sys4.name = 'I2PD';

% 系统5: FOLIPD (一阶积分加纯滞后)
% sys5.P_num = [zeros(1,2) 1 0.5];    % P(z) = 0.3z^{-5} / [(1 - z^{-1})(1 - 0.8z^{-1})]
% sys5.P_den = [1 -1.7 0.7];        % (1 - z^{-1})(1 - 0.8z^{-1}) = 1 - 1.8z^{-1} + 0.8z^{-2}
% sys5.N_num = [1 -0.9];                % N(z) = 0.12 / (1 - 0.88z^{-1})
% sys5.N_den = [1 -1.7 0.7];
% sys5.KZQ_num = [1.08 -2 0.86]*0.01;  % PID控制器
% sys5.KZQ_den = [1 -1];
sys5.P_num = [zeros(1,5) 0.3];    % P(z) = 0.3z^{-5} / [(1 - z^{-1})(1 - 0.8z^{-1})]
sys5.P_den = [1 -1.8 0.8];        % (1 - z^{-1})(1 - 0.8z^{-1}) = 1 - 1.8z^{-1} + 0.8z^{-2}
sys5.N_num = [0.12];                % N(z) = 0.12 / (1 - 0.88z^{-1})
sys5.N_den = [1 -0.88];
sys5.KZQ_num = [0.4 -0.68 0.29];  % PID控制器
sys5.KZQ_den = [1 -1];
sys5.name = 'FOLIPD';

% 系统6: SOSPD (二阶加纯滞后)
% 当前P_den = [1 -1.5 0.6] 已经是二阶系统，保持原状
sys6.P_num = [zeros(1,7) 4.679 4.337]*0.001; % P(z) = (0.15z^{-5} + 0.1z^{-6}) / (1 - 1.5z^{-1} + 0.6z^{-2})
sys6.P_den = [1 -1.81 0.8187];
sys6.N_num = [0.07889 -0.07463];          % N(z) = (0.08 - 0.06z^{-1}) / (1 - 0.8z^{-1})
sys6.N_den = [1 -1.8465 0.8465];
sys6.KZQ_num = [23.6 -44.7 21.3];      % PID控制器
sys6.KZQ_den = [1 -1];
sys6.name = 'SOSPD';


% 所有系统集合
sys_params = {sys1, sys2, sys3, sys4, sys5, sys6};

impulse_points = 200;

% ===================== 主循环 =====================
for idx = 1:length(sys_params)
    % 提取系统参数
    sys = sys_params{idx};
    sys_name = sys.name;
    P_num = sys.P_num;
    P_den = sys.P_den;
    N_num = sys.N_num;
    N_den = sys.N_den;
    KZQ_num = sys.KZQ_num;
    KZQ_den = sys.KZQ_den;
    
    % ========== 计算闭环系统传递函数 ==========
    % 1. 计算 P*KZQ
    P_KZQ_num = conv(P_num, KZQ_num);
    P_KZQ_den = conv(P_den, KZQ_den);
    
    % 2. 计算 1 + P*KZQ
    max_len = max(length(P_KZQ_den), length(P_KZQ_num));
    temp_den = [P_KZQ_den, zeros(1, max_len - length(P_KZQ_den))];
    temp_num = [P_KZQ_num, zeros(1, max_len - length(P_KZQ_num))];
    sum_PK_num = temp_den + temp_num;
    sum_PK_den = P_KZQ_den;
    
    % 3. 计算闭环传递函数 G = N / (1 + P*KZQ)
    G_num = conv(N_num, sum_PK_den);
    G_den = conv(N_den, sum_PK_num);
    
    % ========== 绘制脉冲响应 ==========
    figure('Name', sprintf('系统%d：%s', idx, sys_name), ...
           'Position', [100, 100, 1200, 800]);
    t = 1:impulse_points+1; % impulse_points个点
    % 子图1: 被控对象P的脉冲响应
    subplot(3, 1, 1);
    P_temp=filt(P_num,P_den);
    imp_P=impulse(P_temp,t);
    plot(t, imp_P, 'b-', 'LineWidth', 1.5);
    title(sprintf('%s - 被控对象P(z)', sys_name), 'FontSize', 12);
    xlabel('采样步数'); 
    ylabel('幅值'); 
    grid on;
    
    % 子图2: 扰动N的脉冲响应
    subplot(3, 1, 2);
    N_temp=filt(N_num,N_den);
    imp_N=impulse(N_temp,t);
    plot(t, imp_N, 'r-', 'LineWidth', 1.5);
    title(sprintf('%s - 扰动N(z)', sys_name), 'FontSize', 12);
    xlabel('采样步数'); 
    ylabel('幅值'); 
    grid on;
    
    % 子图3: 闭环系统G的脉冲响应
    subplot(3, 1, 3);
    G_temp=filt(G_num,G_den);
    imp_G=impulse(G_temp,t);
    plot(t, imp_G, 'g-', 'LineWidth', 1.5);
    title(sprintf('%s - 闭环系统G(z)', sys_name), 'FontSize', 12);
    xlabel('采样步数'); 
    ylabel('幅值'); 
    grid on;
end