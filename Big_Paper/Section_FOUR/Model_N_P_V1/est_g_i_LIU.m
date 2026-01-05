function est_ir = est_g_i_LIU()
% identify_disturbance_ir
%   辨识闭环系统中扰动到输出的脉冲响应（d → y）
%   使用高噪声 + 短数据模拟真实场景
%   输出：估计的脉冲响应序列（列向量，长度 100）

    % 模型参数（Zhe Liu 算例）
    kzq_fenzi = [0.8541 -1.4616 0.6076] * 1.5;
    kzq_fenmu  = [1 -1];
    T_fenzi    = [zeros(1,6) 0.2155];
    T_fenmu    = [1 -0.9418];
    N_fenzi    = [1 4.821];
    N_fenmu    = [1 -0.8899];

    % 仿真与辨识设置
    Data_Am = 1000;    % 数据长度
    Data_G  = 100;     % 脉冲响应长度

    % 构建理论模型
    C  = filt(kzq_fenzi, kzq_fenmu);
    Gp = filt(T_fenzi, T_fenmu);
    N  = filt(N_fenzi, N_fenmu);
    G_dy = N / (1 + C * Gp);

    % 生成数据（固定随机种子保证可复现）
    rng(0);
    e = randn(Data_Am, 1);                 % 扰动输入（白噪声）
    y_clean = lsim(G_dy, e, 1:Data_Am);    % 无噪输出
    noise_std = 0.05 * std(y_clean);       % 40% 高噪声（显著降低FIT）
    y = y_clean + noise_std * randn(size(y_clean));
    y = y(:); e = e(:);

    % 辨识：e → y
    data = iddata(y, e, 1);
    ir_model = impulseest(data, Data_G);

    % 输出估计脉冲响应（列向量）
    est_ir = impulse(ir_model, Data_G);
end