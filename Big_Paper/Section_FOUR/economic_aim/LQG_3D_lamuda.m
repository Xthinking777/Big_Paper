% 1. 数据导入与预处理（z维度取log(1+z)变换）
z_original = LQG_3D(:,1);          % 原始z维度数据
z = log(1 + z_original);           % z维度log(1+z)变换（避免log(0/负数)）
x = LQG_3D(:,3);                   % x轴：输入标准差
y = LQG_3D(:,2);                   % y轴：输出标准差

% ------------- 异常值检查 -------------
if min(z_original) < -1
    warning('原始z值< -1，已偏移至-1+1e-6');
    z_original(z_original < -1) = -1 + 1e-6;
    z = log(1 + z_original);
end

% 2. 二元三次多项式拟合（y = f(x,z)）
model_fun = @(b, X) ...
    b(1) + b(2)*X(:,1) + b(3)*X(:,2) + ...          % 一次项
    b(4)*X(:,1).^2 + b(5)*X(:,1).*X(:,2) + b(6)*X(:,2).^2 + ...  % 二次项
    b(7)*X(:,1).^3 + b(8)*X(:,1).^2.*X(:,2) + b(9)*X(:,1).*X(:,2).^2 + b(10)*X(:,2).^3;  % 三次项

initial_b = rand(10,1);
fit_data = [x, z];
lm_model = fitnlm(fit_data, y, model_fun, initial_b);
b_fit = lm_model.Coefficients.Estimate;  % 拟合系数

% 3. 定义拟合函数（输入x/z_log，输出拟合y）
fit_y = @(x_var, z_log_var) ...
    b_fit(1) + b_fit(2)*x_var + b_fit(3)*z_log_var + ...
    b_fit(4)*x_var^2 + b_fit(5)*x_var*z_log_var + b_fit(6)*z_log_var^2 + ...
    b_fit(7)*x_var^3 + b_fit(8)*x_var^2*z_log_var + b_fit(9)*x_var*z_log_var^2 + b_fit(10)*z_log_var^3;

% 4. 目标参数与加权系数定义
x_target = 0.3239;  % 目标x值
y_target = 1.1385;  % 目标y值
w_x = 1;            % x逼近权重（可调整，越大越优先逼近x）
w_y = 1;            % y逼近权重（可调整，越大越优先逼近y）

% 5. 同时逼近x和y的目标函数（核心）
% 优化变量：vars = [x_var, z_log_var]
% 目标函数：w_x*(x - x_target)^2 + w_y*(fit_y(x,z) - y_target)^2
obj_fun = @(vars) ...
    w_x * (vars(1) - x_target).^2 + ...       % x与目标的偏差
    w_y * (fit_y(vars(1), vars(2)) - y_target).^2;  % y与目标的偏差

% 6. 优化求解（约束x和z_log在数据范围内）
x_range = [min(x), max(x)];
z_log_range = [min(z), max(z)];
initial_guess = [x_target, mean(z)];  % 初始猜测（优先靠近目标x）
options = optimoptions('fmincon', ...
    'Display','off', ...         % 关闭迭代显示
    'MaxFunctionEvaluations',1e4, ...
    'TolFun',1e-8, ...          % 精度控制
    'TolX',1e-8);

[opt_vars, total_res] = fmincon(obj_fun, initial_guess, [], [], [], [], ...
    [x_range(1), z_log_range(1)], ...  % 下界
    [x_range(2), z_log_range(2)], ...  % 上界
    [], options);

% 7. 提取最优结果并还原
x_opt = opt_vars(1);                % 最优x（逼近0.3239）
z_log_opt = opt_vars(2);            % 最优log(1+z)
z_original_opt = exp(z_log_opt) - 1;% 还原为原始z值
y_opt = fit_y(x_opt, z_log_opt);    % 最优y（逼近1.1385）

% 计算单独偏差（评估逼近效果）
x_res = (x_opt - x_target).^2;      % x偏差平方
y_res = (y_opt - y_target).^2;      % y偏差平方

% 8. 结果输出（清晰排版）
fprintf('==================== 同时逼近x/y目标结果 ====================\n');
fprintf('目标值：x=%.4f，y=%.4f\n', x_target, y_target);
fprintf('------------------------------------------------------------\n');
fprintf('最优x值（逼近目标）：%.4f，x偏差平方：%.6f\n', x_opt, x_res);
fprintf('最优log(1+z)值：%.4f\n', z_log_opt);
fprintf('最优原始z值：%.4f\n', z_original_opt);
fprintf('最优y值（逼近目标）：%.4f，y偏差平方：%.6f\n', y_opt, y_res);
fprintf('总加权残差平方和：%.6f\n', total_res);
fprintf('------------------------------------------------------------\n');
fprintf('（权重：w_x=%.1f，w_y=%.1f）\n', w_x, w_y);

% 9. 三维可视化验证
figure('Color','w','Position',[100,100,1000,700]);
% 生成拟合曲面网格
[X_grid, Z_log_grid] = meshgrid(linspace(min(x),max(x),50), linspace(min(z),max(z),50));
X_flat = X_grid(:); Z_log_flat = Z_log_grid(:);
Y_fit = b_fit(1) + b_fit(2)*X_flat + b_fit(3)*Z_log_flat + ...
    b_fit(4)*X_flat.^2 + b_fit(5)*X_flat.*Z_log_flat + b_fit(6)*Z_log_flat.^2 + ...
    b_fit(7)*X_flat.^3 + b_fit(8)*X_flat.^2.*Z_log_flat + b_fit(9)*X_flat.*Z_log_flat.^2 + b_fit(10)*Z_log_flat.^3;
Y_fit = reshape(Y_fit, size(X_grid));

% % 绘图
% % 拟合曲面（半透明红色）
% surf(X_grid, Z_log_grid, Y_fit, 'FaceAlpha',0.6, 'EdgeColor','none', 'FaceColor','r', 'DisplayName','拟合曲面');
% hold on;
% % 原始数据点（蓝色三角）
% plot3(x, z, y, 'b<', 'MarkerSize',6, 'LineWidth',1, 'DisplayName','原始数据');
% % 同时逼近x/y的最优z点（黑色星号，突出显示）
% plot3(x_opt, z_log_opt, y_opt, 'k*', 'MarkerSize',8, 'LineWidth',2, ...
%     'DisplayName',sprintf('同时逼近(σ_u=%.4f,σ_y=%.4f)的最优λ',x_target,y_target));
% % 理想目标点（参考，灰色叉号）
% plot3(x_target, log(1+0.65), y_target, 'go', 'MarkerSize',8, 'LineWidth',2, 'DisplayName','理想目标点');
% 
% % 图形美化
% xlabel('输入标准差','FontSize',15, 'FontWeight','bold');
% ylabel('log(1+λ维度参数)','FontSize',15, 'FontWeight','bold');
% zlabel('输出标准差','FontSize',15, 'FontWeight','bold');
% title(sprintf('LQG三维拟合曲线（双目标最小二乘逼近）'), ...
%     'FontSize',16, 'FontWeight','bold');
% legend('Location','best','FontSize',11);
% grid on;
% view(45,30);  % 调整视角（可改为view(3)看正三维）
% colormap(jet);
% colorbar;
% lighting gouraud;  % 曲面光照效果

% 绘图前先计算颜色映射（基于Y_fit值实现渐变）
Y_normalized = (Y_fit - min(Y_fit(:))) / (max(Y_fit(:)) - min(Y_fit(:))); % 归一化Y值用于颜色映射
% 拟合曲面（渐变配色+半透明+优化光照）
surf(X_grid, Z_log_grid, Y_fit, ...
    'CData', Y_normalized, ...          % 基于Y值映射颜色（核心：实现渐变）
    'FaceAlpha', 0.7, ...               % 调整透明度（0.7更通透）
    'EdgeColor', 'none', ...            % 隐藏边缘线，避免干扰
    'FaceLighting', 'gouraud', ...      % 平滑光照，增强渐变质感
    'AmbientStrength', 0.4, ...         % 环境光强度
    'DiffuseStrength', 0.8, ...         % 漫反射强度
    'SpecularStrength', 0.2, ...        % 镜面反射强度
    'DisplayName', '拟合曲面');
hold on;
colormap(parula); % 渐变配色（parula/rainbow/jet可选，parula更柔和）
% 若需自定义红-橙-黄渐变，替换为：
%colormap(linspace([1 0 0],[1 1 0],256)); % 红→橙→黄渐变

% 原始数据点（蓝色三角，增强对比度）
plot3(x, z, y, 'k<', ...
    'MarkerSize',6, ...
    'LineWidth',1, ...
    'MarkerFaceColor', 'b', ... % 填充三角颜色，更醒目
    'DisplayName','原始数据');

% 同时逼近x/y的最优z点（黑色星号，突出显示）
plot3(x_opt, z_log_opt, y_opt, 'r*', ...
    'MarkerSize',8, ...
    'LineWidth',2, ...
    'MarkerFaceColor', 'k', ... % 填充星号颜色
    'DisplayName',sprintf('同时逼近(σ_u=%.4f,σ_y=%.4f)的最优λ',x_target,y_target));

% 理想目标点（参考，绿色圆圈）
plot3(x_target, log(1+0.65), y_target, 'go', ...
    'MarkerSize',6, ...
    'LineWidth',2, ...
    'MarkerFaceColor', 'g', ... % 填充圆圈颜色
    'DisplayName','理想目标点');

% 图形美化（增强渐变可视化）
xlabel('输入标准差','FontSize',15, 'FontWeight','bold');
ylabel('log(1+λ维度参数)','FontSize',15, 'FontWeight','bold');
zlabel('输出标准差','FontSize',15, 'FontWeight','bold');
title('LQG三维拟合曲线（双目标最小二乘逼近）','FontSize',16, 'FontWeight','bold');

% 图例优化（避免颜色混淆）
legend('Location','best','FontSize',11,'Box','on');

grid on;
view(45,30);  % 调整视角
colorbar('Location','eastoutside','FontSize',10); % 颜色条外置，不遮挡图形
lighting gouraud;  % 全局平滑光照
alpha(0.7); % 全局透明度（与曲面一致）
camlight right; % 右侧补光，增强渐变层次感
material dull; % 材质哑光，避免过度反光