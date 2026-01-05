
% 创建样本数据
y = sqrt([4.7732
4.8133
4.8747
4.9723
5.0158
5.0678
5.1307
5.1775
5.2364
5.2881
5.3471
5.4073
5.4530
5.5177
5.5682
5.6225
5.6694
5.7039
5.7513
5.7971
5.8588

]); % x轴上的点集
x = sqrt([4.2102
3.3948
2.8560
2.3161
1.9949
1.7336
1.5280
1.3784
1.1651
1.0210
0.9163
0.8267
0.7279
0.6794
0.6166
0.5720
0.5236
0.4618
0.4311
0.4057
0.3632
]); % y轴上对应的值
bs=0.043;
y=bs*y;
x=bs*x;
% scatter(x, y, 'filled', 'MarkerFaceColor', 'b'); hold on;
% plot(x,y)
 
% 设置多项式次数（这里选取二次）
n =3;
 
% 使用polyfit函数进行拟合
coefficients = polyfit(x, y, n);
 
% 输出拟合结果
disp('拟合系数：');
disp(coefficients);
 
% 生成新的x轴上的点集
new_x = linspace(min(x)*0.9, max(x)*1, 100);
%  new_x = linspace(0, max(x)*1, 100);
% 根据拟合结果计算对应的y轴上的值
new_y = polyval(coefficients, new_x);
 
% 绘制原始数据点及拟合曲线

f=@(x)-x(1)+0*x(2)+0*x(3)+0*x(4);
x0=[0 0 0 0];
    A = [1 0  2.576 0;
        -1 0  2.576 0;
         0 1  0     3;
         0 -1 0     3;
         %0 0  1     0
         ];
    b = [1;
         0;
         0.85;
         0.15;
        % 0.1010
         ];
    Aeq = [1 -1.08 0 0];
    beq = [0];
    VLB = [-100; -100; 0; 0];
    VUB = [];
zyj=fmincon(f, x0, A, b, Aeq, beq, VLB, VUB,'fitting_constraint2');
figure;
% plot(x,y,'b<')
scatter(x, y, 'filled', 'MarkerFaceColor', 'b'); 
hold on;
plot(new_x, new_y, 'r-');
hold on;
plot(zyj(4), zyj(3), 'k*');
legend('原始数据', '拟合曲线','LineWidth',1);
title('LQG权衡曲线');
xlabel('输入标准差','fontsize',15);
ylabel('输出标准差','fontsize',15);
grid on;
zyj
coefficients
