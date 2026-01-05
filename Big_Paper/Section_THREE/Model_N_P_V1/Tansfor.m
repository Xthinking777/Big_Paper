function [eT]=Tansfor(est_T,d,Class,Lemma)
class=Class;%阶数n
lemma=Lemma;%取λ+n做计算  λ+n<总数据量 
est_Td=est_T(d+1:end);
fin=[];
for i=1:class
tempfin=est_Td(i+1:i+lemma);
fin=[fin tempfin];
end
fin2=-est_Td(class+2:class+lemma+1);
fin1=est_Td(1:class+1);
A=pinv(fin'*fin)*fin'*fin2;
theta=toeplitz([1;flipud(A)]);
theta=tril(theta);
B=theta*fin1;
eT=filt(B',[1 flipud(A)'])*filt([zeros(1,d) 1],1);
end
%%函数功能 由脉冲响应得到传递函数
% 输入参数：
% est_T: 系统的脉冲响应数据
% d: 时延参数
% Class: 系统阶数n
% Lemma: 用于计算的样本数 λ+n
% 输出：
% eT: 估计的传递函数输出