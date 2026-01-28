function estN = estimate_N_xxq(d, Gm, N_theory_num, N_theory_den)
% ESTIMATE_N_XXQ 估计系统模型的参数（专用版：支持理论分子1项/2项，理论分母首项为1）
% 输入:
%   d            - 系统的阶数或延迟
%   Gm           - 系统模型相关的矩阵或向量
%   N_theory_num - 理论N模型的分子系数，格式：[a0]（1项）或 [a0 a1]（2项）
%   N_theory_den - 理论N模型的分母系数，格式：[1 b1 b2...]（首项必须为1）
% 输出:
%   estN         - 估计得到的SISO离散系统模型

% ------------- 校验输入格式（核心：适配分子1项/2项）-------------
% 1. 校验分子项数（仅允许1项或2项）
if ~(length(N_theory_num) == 1 || length(N_theory_num) == 2)
    error('理论分子系数N_theory_num仅支持1项或2项！格式为[a0] 或 [a0 a1]');
end

% 2. 校验分母首项为1
if N_theory_den(1) ~= 1
    error('理论分母系数N_theory_den首项必须为1！请先归一化分母系数');
end

% ------------- 适配分子格式，统一转为2项（核心改造点）-------------
% 逻辑：1项分子补0转为2项 [a0, 0]，2项分子直接保留，保证x0结构统一
if length(N_theory_num) == 1
    N_num_adapted = [N_theory_num(1), 0]; % 1项补0，匹配后续 [x(1) x(2)] 逻辑
    disp('检测到理论分子为1项，已自动补0转为2项格式');
else
    N_num_adapted = N_theory_num; % 2项直接保留
end

% ------------- 从适配后的分子构造优化初始值x0 -------------
% x0结构：[适配后分子a0, 适配后分子a1, 分母b1, 分母b2, ...]，结构统一无歧义
x0 = [N_num_adapted, N_theory_den(2:end)];

% ------------- 优化配置（保持原有性能）-------------
options = optimoptions('fmincon', 'Display', 'iter', 'TolFun', 1e-6);
lb = -5 * ones(size(x0)); % 参数下界
ub = 5 * ones(size(x0)); % 参数上界

% ------------- 定义目标函数并执行优化 -------------
etha = @(x) ethaF(x, d, Gm);
[x_opt, J_opt] = fmincon(etha, x0, [], [], [], [], lb, ub, [], options);

% ------------- 输出优化结果（方便调试）-------------
disp('优化得到的最优参数向量x_opt：');
disp(x_opt);
disp('最优目标函数值J_opt：');
disp(J_opt);

% ------------- 由最优参数构造估计模型（使用适配后的分子格式）-------------
estN = filt([x_opt(1) x_opt(2)], [1 x_opt(3:end)]);

end

% ------------- 目标函数ethaF（保持不变，已兼容统一的2项分子格式）-------------
function J = ethaF(x, d, Gm)
    % 计算Gm的延迟算子
    Glag = LagOp(Gm);
    % 由参数x构造估计模型（分子统一为2项，兼容1项补0后的格式）
    estN = filt([x(1) x(2)], [1 x(3:end)]);
    % 计算估计模型的脉冲响应
    estNm = impulse(estN);
    % 计算脉冲响应的延迟算子
    estNlag = LagOp(estNm);
    % 计算延迟算子比值并转换为矩阵
    ethalag = estNlag / Glag;
    etham = cell2mat(toCellArray(ethalag))';
    % 目标函数：误差平方和
    J = (etham(1) - 1).^2 + sum(etham(2:d).^2);
end