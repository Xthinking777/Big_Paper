function estN = estimate_N_Sxt(d, Gm, pcase)

    % estimate_N: 估计系统模型的参数
    % 输入:
    %   d - 系统的阶数或延迟
    %   Gm - 系统模型相关的矩阵或向量
    %   pcase - 用于选择不同初始参数的案例编号

    % 根据不同的pcase选择不同的初始参数向量x0  N=[1+x(1)]/[(1+x(2)+x(3)+...]
    switch pcase
        case 1
            x0 = [4.8  -0.4]; % 初始化参数
        case 2
            x0 = [0 -0.1 -0.2]; % 初始化参数
        case 3
            x0 = [-0.02 -0.7 -0.03 0]; % 初始化参数  分子：x(1)  分母(d-1个)：x(2) x(3) x(4)...
        case 4
            x0 = [-0.02 -0.7 -0.03 0 0]; % 初始化参数  分子：x(1)  分母(d-1个)：x(2) x(3) x(4)...
        case 5
            x0 = [0.6 0.1 -0.67 -0.025 0.105]; % 初始化参数  分子：x(1)  分母(d-1个)：x(2) x(3) x(4)...
    end

    % 设置优化选项
    options = optimoptions('fmincon', 'Display', 'iter', 'TolFun', 1e-6);
    % 设置参数向量的下界和上界
    lb = -5 * ones(size(x0));
    ub = 5 * ones(size(x0));
    
    % 定义目标函数
    etha = @(x) ethaF(x, d, Gm);
    % 执行优化，找到使目标函数最小的参数向量x_opt
    [x_opt, J_opt] = fmincon(etha, x0, [], [], [], [], lb, ub, [], options);

    % 输出优化后的参数向量
    x_opt
    % 输出最优目标函数值
    J_opt

    % 使用优化后的参数向量计算估计的系统模型
    estN = filt([1 x_opt(1)], [1 x_opt(2:end)]);

end

function J = ethaF(x, d, Gm)

    % ethaF: 目标函数，用于评估参数向量x的性能
    % 输入:
    %   x - 参数向量
    %   d - 系统的阶数或延迟
    %   Gm - 系统模型相关的矩阵或向量

    % 计算Gm的拉普拉斯算子
    Glag = LagOp(Gm);
    % 使用参数向量x计算估计的系统模型estN
    estN = filt([1 x(1)], [1 x(2:end)]);
    % 计算estN的脉冲响应
    estNm = impulse(estN);
    % 计算estNm的拉普拉斯算子
    estNlag = LagOp(estNm);
    % 计算estNlag和Glag的比值
    ethalag = estNlag / Glag;
    % 将ethalag转换为矩阵形式
    etham = cell2mat(toCellArray(ethalag))';
    % 计算目标函数值J，它是误差的平方和    
    J = (etham(1) - 1).^2 + sum(etham(2:d).^2);

end










