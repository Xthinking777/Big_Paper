%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 步骤1：初始化参数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

% 核心参数
Ts = 0.1;               % 采样时间（关键：所有离散模块统一）
simTime = 1000;         % 仿真时长（秒），保证足够数据量
nSample = simTime/Ts;   % 采样点数

% 理论模型参数
kzq_fenzi = 1.5*[0.8541 -1.4616 0.6076]; % 控制器分子
kzq_fenmu = [1 -1];                      % 控制器分母
T_fenzi = [zeros(1,6) 0.2155];           % 对象P(T)分子
T_fenmu = [1 -0.9418];                   % 对象P(T)分母
N_fenzi = [1 4.821];                     % 扰动N分子
N_fenmu = [1 -0.8899];                   % 扰动N分母

% 生成输入信号（持续激励）
r = zeros(1, nSample);   % 辨识N时参考输入设为0；辨识P时可改为randn(1,nSample)
w = randn(1, nSample);   % 扰动输入（白噪声，持续激励）

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 步骤2：自动生成Simulink模型（修复参数格式错误）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modelName = 'kzq_ident_model';
new_system(modelName);  % 创建新模型
open_system(modelName); % 打开模型

% ------------- 添加核心模块 -------------
% 1. 输入模块（扰动w、参考输入r）
% Constant模块：SampleTime必须为字符向量，Value也需字符格式
add_block('simulink/Sources/Constant', [modelName '/r'], ...
    'Value', '0', ...                  % 参考输入设为0（字符格式）
    'SampleTime', num2str(Ts));        % 采样时间转为字符格式
% Random Number模块：SampleTime同样转字符
add_block('simulink/Sources/Random Number', [modelName '/w'], ...
    'Mean', '0', ...
    'Variance', '1', ...
    'SampleTime', num2str(Ts));

% 2. 传递函数模块（控制器KZQ、对象T、扰动N）
% Discrete Transfer Fcn：分子/分母需字符格式，SampleTime转字符
add_block('simulink/Discrete/Discrete Transfer Fcn', [modelName '/KZQ'], ...
    'Numerator', mat2str(kzq_fenzi), ...
    'Denominator', mat2str(kzq_fenmu), ...
    'SampleTime', num2str(Ts));
add_block('simulink/Discrete/Discrete Transfer Fcn', [modelName '/T'], ...
    'Numerator', mat2str(T_fenzi), ...
    'Denominator', mat2str(T_fenmu), ...
    'SampleTime', num2str(Ts));
add_block('simulink/Discrete/Discrete Transfer Fcn', [modelName '/N'], ...
    'Numerator', mat2str(N_fenzi), ...
    'Denominator', mat2str(N_fenmu), ...
    'SampleTime', num2str(Ts));

% 3. 求和模块（SampleTime转字符）
add_block('simulink/Signal Routing/Sum', [modelName '/Sum1'], ...
    'Inputs', '+-', ...
    'SampleTime', num2str(Ts)); % r - y
add_block('simulink/Signal Routing/Sum', [modelName '/Sum2'], ...
    'Inputs', '+-', ...
    'SampleTime', num2str(Ts)); % KZQ*error - N*w

% 4. 输出模块（To Workspace，保存数据）
add_block('simulink/Sinks/To Workspace', [modelName '/y_out'], ...
    'VariableName', 'y_data', ...
    'SaveFormat', 'Array', ...
    'SampleTime', num2str(Ts));
add_block('simulink/Sinks/To Workspace', [modelName '/w_out'], ...
    'VariableName', 'w_data', ...
    'SaveFormat', 'Array', ...
    'SampleTime', num2str(Ts));
add_block('simulink/Sinks/To Workspace', [modelName '/u_out'], ...
    'VariableName', 'u_data', ...
    'SaveFormat', 'Array', ...
    'SampleTime', num2str(Ts));

% ------------- 连接模块 -------------
% Sum1: r → +, y → -
add_line(modelName, 'r/1', 'Sum1/1');
add_line(modelName, 'y_out/1', 'Sum1/2');

% Sum1 → KZQ → u_out → Sum2+
add_line(modelName, 'Sum1/1', 'KZQ/1');
add_line(modelName, 'KZQ/1', 'u_out/1');
add_line(modelName, 'KZQ/1', 'Sum2/1');

% w → N → Sum2-
add_line(modelName, 'w/1', 'N/1');
add_line(modelName, 'N/1', 'Sum2/2');

% Sum2 → T → y_out
add_line(modelName, 'Sum2/1', 'T/1');
add_line(modelName, 'T/1', 'y_out/1');

% w → w_out（保存扰动输入）
add_line(modelName, 'w/1', 'w_out/1');

% ------------- 设置仿真参数 -------------
set_param(modelName, 'StopTime', num2str(simTime));
set_param(modelName, 'Solver', 'discrete'); % 离散求解器，避免步长问题
set_param(modelName, 'FixedStep', num2str(Ts)); % 固定步长，与采样时间一致

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 步骤3：运行仿真并采集数据
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim(modelName); % 运行仿真

% 提取数据（确保维度匹配）
y = y_data(:);   % 系统输出
w = w_data(:);   % 扰动输入
u = u_data(:);   % 控制器输出
t = 0:Ts:(length(y)-1)*Ts; % 时间轴

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 步骤4：辨识扰动模型N（N = G*(1+T*KZQ)，G = y/w (r=0时)）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4.1 辨识闭环扰动传递函数G
data_G = iddata(y, w, Ts);  % 输出y，输入w
data_G = detrend(data_G);   % 去趋势，消除直流偏置

% 自动筛选最优阶次（分母1-3，分子1-10）
V = struc(data_G, 1:3, 1:10, 0);
[best_order, ~] = selstruc(V, 0); % AIC准则选阶次
na_G = best_order(1);
nb_G = best_order(2);
model_G = arx(data_G, [na_G nb_G 0]); % ARX辨识G

% 4.2 构造1+T*KZQ，反推N
KZQ_tf = tf(kzq_fenzi, kzq_fenmu, Ts);
T_tf = tf(T_fenzi, T_fenmu, Ts);
denominator_tf = 1 + T_tf*KZQ_tf;
denominator_tf = minreal(denominator_tf); % 简化传递函数

% 计算辨识的N
model_N = model_G * denominator_tf;
model_N = minreal(model_N); % 简化N

% 4.3 理论N模型
N_tf = tf(N_fenzi, N_fenmu, Ts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 步骤5：辨识对象模型P（即T，P = y/u (w=0时)）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 重新生成无扰动的仿真数据（w=0）
set_param([modelName '/w'], 'Variance', '0'); % 扰动置0（字符格式）
sim(modelName); 
y_p = y_data(:);   % 无扰动输出
u_p = u_data(:);   % 控制器输出

% 5.1 辨识P
data_P = iddata(y_p, u_p, Ts);
data_P = detrend(data_P);

% 自动选阶次
V_P = struc(data_P, 1:3, 1:10, 0);
[best_order_P, ~] = selstruc(V_P, 0);
na_P = best_order_P(1);
nb_P = best_order_P(2);
model_P = oe(data_P, [na_P nb_P 0]); % 输出误差法，适配非最小相位

% 5.2 理论P模型（即T）
P_tf = T_tf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 步骤6：验证辨识结果（时域对比+误差分析）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6.1 扰动模型N验证
y_N_theory = lsim(N_tf, w, t);    % 理论N输出
y_N_ident = lsim(model_N, w, t); % 辨识N输出

figure('Name','N模型验证');
plot(t, y_N_theory, 'b-', 'LineWidth',1.5); hold on;
plot(t, y_N_ident, 'r--', 'LineWidth',1.5);
xlabel('时间 (s)'); ylabel('输出');
legend('理论N输出','辨识N输出'); grid on;
err_N = mean(abs(y_N_theory - y_N_ident));
title(sprintf('扰动模型N验证（平均绝对误差：%.4f）', err_N));

% 6.2 对象模型P验证
y_P_theory = lsim(P_tf, u_p, t);    % 理论P输出
y_P_ident = lsim(model_P, u_p, t); % 辨识P输出

figure('Name','P模型验证');
plot(t, y_P_theory, 'b-', 'LineWidth',1.5); hold on;
plot(t, y_P_ident, 'r--', 'LineWidth',1.5);
xlabel('时间 (s)'); ylabel('输出');
legend('理论P输出','辨识P输出'); grid on;
err_P = mean(abs(y_P_theory - y_P_ident));
title(sprintf('对象模型P验证（平均绝对误差：%.4f）', err_P));

% 6.3 打印辨识模型参数
fprintf('\n================= 辨识结果 =================\n');
fprintf('【扰动模型N】\n');
fprintf('理论分子：%s\n', num2str(N_fenzi));
fprintf('辨识分子：%s\n', num2str(model_N.Numerator{1}));
fprintf('理论分母：%s\n', num2str(N_fenmu));
fprintf('辨识分母：%s\n', num2str(model_N.Denominator{1}));

fprintf('\n【对象模型P】\n');
fprintf('理论分子：%s\n', num2str(T_fenzi));
fprintf('辨识分子：%s\n', num2str(model_P.Numerator{1}));
fprintf('理论分母：%s\n', num2str(T_fenmu));
fprintf('辨识分母：%s\n', num2str(model_P.Denominator{1}));

fprintf('\n平均绝对误差：N=%.4f，P=%.4f\n', err_N, err_P);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 清理（可选）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close_system(modelName, 0); % 关闭Simulink模型（0=不保存）
% delete([modelName '.slx']); % 删除模型文件