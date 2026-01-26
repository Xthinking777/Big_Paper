%% LQG_FPID 多模型对比分析
clear; clc; close all;

% 初始化绘图窗口
figure('Name', '多模型 LQG—PID 结果对比', 'Color', 'w');
hold on; grid on; box on;
xlabel('X 轴 (LQG_3D(:,3))');
ylabel('Y 轴 (LQG_3D(:,2))');
title('不同模型 LQG—PID 结果对比');

% 定义颜色和线型（区分不同模型）
colors = lines(4);          % 4种颜色
line_styles = {'-', '--', '-.', ':'}; % 4种线型
model_labels = {'模型1 (饱和度0%)', '模型2 (饱和度10%)', '模型3 (饱和度20%)', '模型4 (饱和度30%)', '模型5 (饱和度0%)', '模型6 (饱和度21.7%)', '模型7 (饱和度21.7%)'};

% 遍历所有model_np (1-4)
for model_np = 38:38
    % 根据model_np配置参数
    if model_np == 1 %澎湃 算例一
        d = 5;  
        T_fenzi = [zeros(1,d)  0.2];%对象模型 饱和度0%
        T_fenmu = [1 -0.8];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.1  -0.2];
        Lmd_Set = [0  0.5  1  5  15 50 100];
        %Lmd_Set = [0  1.7183  6.3891  19.0855  53.5982 147.4132];%ln(1+λ)=0 1 2 3 4 5
    elseif model_np == 2%澎湃 算例一
        d = 5;  
        T_fenzi = [zeros(1,d)  0.1787  -0.00376];%对象模型 饱和度10%
        T_fenmu = [1 -0.8064];
        N_fenzi = [1 0.02273];                
        N_fenmu = [1 -0.1375  -0.2051 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 3%澎湃 算例一
        d = 5;  
        T_fenzi = [zeros(1,d)  0.1583 -0.003779];%对象模型 饱和度20%
        T_fenmu = [1 -0.8063];
        N_fenzi = [1 0.03523];                
        N_fenmu = [1 -0.1583  -0.2084 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 4%澎湃 算例一
        d = 5;  
        T_fenzi = [zeros(1,d)  0.1392  -0.004026];%对象模型 饱和度30%
        T_fenmu = [1 -0.8078];
        N_fenzi = [1 0.04241];                
        N_fenmu = [1 -0.1704  -0.2102 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 5%高 算例一 理论
        d = 3;  
        T_fenzi = [zeros(1,d)  0.6299 ];%对象模型
        T_fenmu = [1 -0.8899];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 6%高 算例一  初始控制器
        d = 3;  
        T_fenzi = [zeros(1,d)  0.4676 -0.009845];%对象模型 饱和度21%  
        T_fenmu = [1 -0.8994];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
   elseif model_np == 7%高 算例一  λ=0
        d = 3;  
        T_fenzi = [zeros(1,d)  0.3527 -0.006112];%对象模型 
        T_fenmu = [1 -0.89558955];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 8%高 算例一  λ=0.5
        d = 3;  
        T_fenzi = [zeros(1,d)  0.4987 -0.01126];%对象模型 19.4%
        T_fenmu = [1 -0.8971];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 18%高 算例一  λ=0.5
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5059 -0.01156];%对象模型 18.4%
        T_fenmu = [1 -0.8968];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 28%高 算例一  λ=0.5
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5062 -0.01058];%对象模型 18%
        T_fenmu = [1 -0.8954];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
    elseif model_np == 38%高 算例一  λ=0.5
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5067 -0.01083];%对象模型 17.8%
        T_fenmu = [1 -0.8956];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
   elseif model_np == 9%高 算例一  λ=1
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5616 -0.01714];%对象模型 饱和度9%  λ=1  
        T_fenmu = [1 -0.9002];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
   elseif model_np == 19%高 算例一 λ=1 二次循环
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5702 -0.0178];%对象模型 饱和度8%  λ=1  
        T_fenmu = [1 -0.9001];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
   elseif model_np == 29%高 算例一 λ=1 三次循环
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5715 -0.02024];%对象模型 饱和度7.7%  λ=1  
        T_fenmu = [1 -0.9];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];   
   elseif model_np == 39%高 算例一 λ=1 四次循环
        d = 3;  
        T_fenzi = [zeros(1,d)  0.5715 -0.02016];%对象模型 饱和度7.6%  λ=1  
        T_fenmu = [1 -0.9001];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100]; 
   elseif model_np == 10%高 算例一  λ=5
        d = 3;  
        T_fenzi = [zeros(1,d)  0.6224 -0.04691];%对象模型 
        T_fenmu = [1 -0.9083];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
   elseif model_np == 11%高 算例一  λ=15
        d = 3;  
        T_fenzi = [zeros(1,d)  0.6187 -0.09957];%对象模型 饱和度0%  λ=15  0.0804 -0.0966 0.0163     0.0909160633925799	-0.109337166733092	0.0185211936942477
        T_fenmu = [1 -0.913];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];
   elseif model_np == 12%高 算例一  λ=50
        d = 3;  
        T_fenzi = [zeros(1,d)  0.6457 -0.258];%对象模型 饱和度0%  λ=15  0.0804 -0.0966 0.0163     0.0909160633925799	-0.109337166733092	0.0185211936942477
        T_fenmu = [1 -0.8496];
        N_fenzi = [1 0];                
        N_fenmu = [1 -0.8899 ];
        Lmd_Set = [0  0.5  1  5  15 50 100];  
    end

    % 构造传递函数
    T = filt(T_fenzi, T_fenmu);
    N = filt(N_fenzi, N_fenmu);

    % 运行LQG_FPID并获取结果
    fprintf('正在运行 model_np = %d ...\n', model_np);
    LQG_3D = LQG_FPID(N, T, d, Lmd_Set);

    % 绘制当前模型的结果（用不同颜色+线型区分）
    plot(LQG_3D(:,3), LQG_3D(:,2), ...
         'Color', colors(mod(model_np-1,4)+1,:), ...
         'LineStyle', line_styles{mod(model_np-1,4)+1}, ...
         'LineWidth', 1.5, ...
         'DisplayName', model_labels{mod(model_np-1,7)+1});
end

% 图例设置（自动找最优位置）
legend('Location', 'best', 'FontSize', 9);


