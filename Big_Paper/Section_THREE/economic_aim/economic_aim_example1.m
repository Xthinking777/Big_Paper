%经济指标 高4-1数值算例
% 创建样本数据
% y = sqrt([2.5435, 2.5572, 2.5655, 2.5785, 2.6138, 2.6287, 2.6442, 2.6599, 2.6968, 2.7115, 2.7260,2.7404, 2.7544, 2.7683, ...
%           2.8021, 2.8145, 2.8267, 2.8386, 2.8502, 2.8616, 2.8926, 3.0042, 3.1180, 3.2437, 3.3644, 3.3970]); % x轴上的点集
% x = sqrt([1.0524, 0.7663, 0.6408, 0.5548, 0.4889, 0.4416, 0.4033, 0.3716, 0.3441, 0.3216, 0.3021, 0.2848, 0.2695, 0.2558, ...
%          0.2434, 0.2323, 0.2223, 0.2130, 0.2045, 0.1966, 0.1892, 0.1374, 0.1065, 0.0865, 0.0730, 0.0610]); % y轴上对应的值
x=LQG_3D(:,3);%导入数据
y=LQG_3D(:,2);

% 使用polyfit函数进行拟合
coefficients = polyfit(x, y, 3);
% 输出拟合结果
disp('拟合系数：');
disp(coefficients);

% 生成新的x轴上的点集
new_x = linspace(min(x)*1, max(x), 100);
% 根据拟合结果计算对应的y轴上的值
new_y = polyval(coefficients, new_x);
 

%求解优化问题
%% 优化问题表达式
%P=cy*y-cu*u
%y=K*u
%-lower_y+z_alpha_y*vay(y)<=y<=upper_y-z_alpha_y*vay(y)
%-lower_u+z_alpha_u*vay(u)<=u<=upper_u-z_alpha_u*vay(u)
%vay(y)=f(var(u))

%初始化系数
K=6.0367;
z_alpha_y=1.96;
z_alpha_u=3;
lower_y=-10;
upper_y=10;
lower_u=-2.5;
upper_u=2.5;
cy=1;
cu=3;
var_y0=1.7996;
var_u0=0.8244;

% var_y0=1.665182;%λ=1.7
% var_u0=0.458513;


%% 固定方差约束
f=@(x)-cy*x(1)+cu*x(2)+0*x(3)+0*x(4);% y u var(y) var(u)
x0=[0 0 0 0];
    %不等式约束
   A = [ 1  0 z_alpha_y 0;
        -1  0 z_alpha_y 0;
         0  1 0         z_alpha_u;
         0 -1 0         z_alpha_u];
    b = [upper_y;
         -lower_y;
         upper_u;
         -lower_u];
     %等式约束
    Aeq = [1 -K 0 0;
           0  0      1 0
           0  0      0 1];
    beq = [0;
            var_y0;
            var_u0];
    VLB = [ -100; -100; 0; 0];
    VUB = [];
    zyj0=fmincon(f, x0, A, b, Aeq, beq, VLB, VUB,'',optimoptions('fmincon', 'Display', 'off'));%最优解 固定方差约束
%% 可变方差约束
f=@(x)-cy*x(1)+cu*x(2)+0*x(3)+0*x(4);% y u var(y) var(u)
x0=[0 0 0 0];
    %不等式约束
   A = [ 1  0 z_alpha_y 0;
        -1  0 z_alpha_y 0;
         0  1 0         z_alpha_u;
         0 -1 0         z_alpha_u];
    b = [upper_y;
         -lower_y;
         upper_u;
         -lower_u];
     %等式约束
    Aeq = [1 -K 0 0;
           ];
    beq = [0;
            ];
    VLB = [ -100; -100; 0; 0];
    VUB = [];
   %LGQ等式约束 
   %x(3)=lqgxs(1)*x(4)^3+lqgxs(2)*x(4)^2+lqgxs(3)*x(4)+lqgxs(4)
   %lqgxs = [-0.7319, 2.0170, -1.8912, 2.2011];
   lqgxs =coefficients;
   constraint_func = @(x) fitting_constraint(x, lqgxs);
   zyj=fmincon(f, x0, A, b, Aeq, beq, VLB, VUB,constraint_func,optimoptions('fmincon', 'Display', 'off'));%最优解 LQG拟合曲线约束

% 绘制原始数据点及拟合曲线
figure;
plot(x,y,'b<')
%scatter(x, y, 'filled', 'MarkerFaceColor', 'b'); 
hold on;
plot(new_x, new_y, 'r-');
% hold on;
plot(zyj(4), zyj(3), 'k*','MarkerSize', 10);%最优经济参数
plot(zyj0(4), zyj0(3), 'k.','MarkerSize', 20);%原最优经济参数
legend('原始数据', '拟合曲线','最优控制器参数','初始控制器参数','LineWidth',1);
title('LQG权衡曲线');
xlabel('输入标准差','fontsize',15);
ylabel('输出标准差','fontsize',15);
grid on;
fprintf("最优经济效益：");
P=zyj(1)-3*zyj(2);
disp(P);
zyj
fprintf("初始经济效益：");
P=zyj0(1)-3*zyj0(2);
disp(P);
zyj0

