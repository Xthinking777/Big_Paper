function [ f_ya ] = fc1( y )%系统闭环脉冲响应求解程序
N=length(y);
% m1=armax(y,[20 20]);%A(q) y(t) = C(q) e(t)，其中设A为10阶；B为9阶；m1为AB模型且包含其信息
% e=resid(m1,y);%求序列y的残差
e = WN_estimation3(y(2:end)',100,19999,1,1); 
k = 1;n = 19999;
y=y(k:k+n-1,:); %对应于et1,et2的数据段
Y = y';

G = FCOR1(Y,e,1001);%FCOR算法估计闭环传递函数*一个积分算子

f_ya = [];

for i = 1 : size(G,3)
    f_ya = [f_ya G(1,1,i)];
end
f_ya = f_ya(2:end);

% Gd_Markov_est=get_diff(Gd_Markov_est_ARX);%差分，得到真正的G的估计
% Gd_Markov_est = Gd_Markov_est(:,:,2:end);%第一项为0，删去第一项
% e_var=var(e);%求残差方差
% e=e*(1/sqrt(e_var));
% f_ya = zeros(1, 1001); % 初始化输出数组
% for r=0:1000
%     f_ya(r+1)=y(r+1:end)'*e(1:end-r)/(N-r);%FCOR算法
% end
end