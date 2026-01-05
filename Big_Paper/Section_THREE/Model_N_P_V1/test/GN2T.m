clear; clc; close all;

%% ========== 1. 定义已知模型 ==========

% ----- 辨识得到的 G -----
% G = (1 - 1.121 z^-1 - 0.6524 z^-2 + 0.7732 z^-3) /
%     (1 - 2.832 z^-1 + 2.67 z^-2 - 0.8381 z^-3 + 0.2761 z^-6 - 0.7182 z^-7 + 0.6169 z^-8 - 0.1748 z^-9)
G_num = [1, -1.121, -0.6524, 0.7732];  % z^0 到 z^-3
G_den = [1, -2.832, 2.67, -0.8381, 0, 0, 0.2761, -0.7182, 0.6169, -0.1748]; % 到 z^-9
G = filt(G_num, G_den);

% ----- 控制器 KZQ -----
kzq_num = [0.8541, -1.4616, 0.6076] * 1.5;  % 乘以1.5
kzq_den = [1, -1];
KZQ = filt(kzq_num, kzq_den);

% ----- 扰动模型 N -----
N_num = [1, 0.821];
N_den = [1, -0.8899];
N = filt(N_num, N_den);

% ----- 标称对象模型 T_nominal (理论值) -----
d_nominal = 6;
T_nom_num = [zeros(1, d_nominal), 0.2155];
T_nom_den = [1, -0.9418];
T_nominal = filt(T_nom_num, T_nom_den);

%% ========== 2. 从 G 反推 T_est ==========

% 理论公式: T = (N - G) / (G * KZQ)
T_est_raw = (N - G) / (G * KZQ);

disp('=== 原始估计的 T_est_raw (可能高阶) ===');
T_est_raw

%% ========== 3. 简化模型 ==========

% 最小实现（去除可对消的零极点，忽略小增益模态）
T_est_min = minreal(T_est_raw, 1e-5);  % 容差 1e-5

disp('=== 简化后的 T_est_min ===');
T_est_min

%% ========== 4. 结构化拟合：假设 T 为一阶 + 6步延迟 ==========

d_assumed = 6;           % 假设延迟为6
n_imp = 30;              % 脉冲响应长度

% 获取简化模型的脉冲响应
[y_imp, t_imp] = impulse(T_est_min, n_imp);
t_imp = t_imp(:); y_imp = y_imp(:);

% 绘制脉冲响应，检查延迟
figure;
stem(t_imp, y_imp, 'filled', 'MarkerSize', 4);
hold on;
xline(d_assumed, '--r', 'Assumed Delay = 6');
xlabel('Sample k');
ylabel('Impulse Response');
title('Impulse Response of Estimated T_{est}');
grid on;
legend('T_{est, minreal}', 'Location', 'best');

% 提取 k >= d_assumed 的响应用于拟合
idx_start = d_assumed + 1;
if idx_start > length(y_imp)
    error('Impulse response too short for delay assumption.');
end

y_fit = y_imp(idx_start:end);
k_fit = (0:length(y_fit)-1)';

% 去除接近零的点（避免 log(0)）
threshold = max(abs(y_fit)) * 1e-3;
valid = abs(y_fit) > threshold;

if sum(valid) < 3
    warning('Not enough valid points for fitting. Using raw first value.');
    b0_est = y_fit(1);
    a_est  = 0.9; % fallback
else
    % 对 log(y) 线性拟合: log(y) = log(b0) + k * log(a)
    p = polyfit(k_fit(valid), log(abs(y_fit(valid))), 1);
    a_est = exp(p(1));          % 极点（动态）
    b0_est = exp(p(2));         % k = d 时刻的脉冲幅值
end

% 构造结构化估计模型: T(z) = b0 * z^{-d} / (1 - a z^{-1})
T_est_struct = filt([zeros(1, d_assumed), b0_est], [1, -a_est]);

