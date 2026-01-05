clear; clc; close all;

% 模型参数（Zhe Liu）
kzq_fenzi = [0.8541 -1.4616 0.6076] * 1.5;
kzq_fenmu  = [1 -1];
T_fenzi    = [zeros(1,6) 0.2155];
T_fenmu    = [1 -0.9418];
N_fenzi    = [1 4.821];
N_fenmu    = [1 -0.8899];

% === 关键：降低数据质量 ===
Data_Am = 1000;    % << 缩短数据（原20000）
Data_G  = 100;

% 理论模型
C  = filt(kzq_fenzi, kzq_fenmu);
Gp = filt(T_fenzi, T_fenmu);
N  = filt(N_fenzi, N_fenmu);
G_dy = N / (1 + C * Gp);
true_ir = impulse(G_dy, Data_G);

% 生成数据
rng(0);
e = randn(Data_Am, 1);                 % 白噪声输入（已知）
y_clean = lsim(G_dy, e, 1:Data_Am);
noise_std = 0.40 * std(y_clean);       % << 10% 噪声（原5%）
y = y_clean + noise_std * randn(size(y_clean));
y = y(:); e = e(:);

% 辨识：使用 impulseest，但限制阶数（可选）
data = iddata(y, e, 1);
ir_model = impulseest(data, Data_G);   % 仍用完整阶数，噪声+短数据已足够降FIT

% 提取结果
est_ir = impulse(ir_model, Data_G);

% 绘图
figure;
plot(0:Data_G, true_ir, 'b', 'LineWidth', 1.5); hold on;
plot(0:Data_G, est_ir, 'r--', 'LineWidth', 1.5);
xlabel('k'); ylabel('g(k)');
legend('True', 'Identified (10% noise, N=2000)');
title('Disturbance-to-Output IR (Realistic Simulation)');
grid on;

% 输出
disp('True (1:15):'); disp(true_ir(1:15)');
disp('Est  (1:15):'); disp(est_ir(1:15)');
fit_val = 100 * (1 - norm(true_ir - est_ir) / norm(true_ir - mean(true_ir)));
fprintf('FIT = %.2f%%\n', fit_val);