% function [ f_ya ] = fc( y )%系统闭环脉冲响应求解程序
% N=length(y);
% m1=armax(y,[20 20]);%A(q) y(t) = C(q) e(t)，其中设A为10阶；B为9阶；m1为AB模型且包含其信息
% e=resid(m1,y);%求序列y的残差
% close
% e_var=var(e.outputdata);%求残差方差
% e.outputdata=e.outputdata*(1/sqrt(e_var));
% for r=0:1000
%     f_ya(r+1)=y(r+1:end)'*e.outputdata(1:end-r)/(N-r);%FCOR算法
% end
% end

function [ f_ya ] = fc( y )%系统闭环脉冲响应求解程序
N=length(y);
m1=armax(y,[20 20]);%A(q) y(t) = C(q) e(t)，其中设A为10阶；B为9阶；m1为AB模型且包含其信息
e=resid(m1,y);%求序列y的残差
e_var=var(e);%求残差方差
e=e*(1/sqrt(e_var));
% f_ya=zeros(1:1000)';
for r=0:1000
    f_ya(r+1)=y(r+1:end)'*e(1:end-r)/(N-r);%FCOR算法
end
end