function [et,Coeff]=WN_estimation3(yt,p,n,k,ny)     %辅助变量法
%数据y，p为过去窗口的大小，k为数据起始点，N为过去数据长度
b=2*p;Yp=zeros(ny*p,n);
y=[zeros(ny,b) yt];  %防止因N过大k过小而导致超出矩阵的搜索
for i=1:p
    Yp((i-1)*ny+1:i*ny,:)=y(:,k-p+i+b-1:k-p+i+b-1+n-1);
end
Yf=y(:,k+b:k+b-1+n);
% if rank(Yp)==size(Yp,1)
%     disp("行满秩")
% end
Coeff=(Yf*Yp')/(Yp*Yp');
et=Yf-Coeff*Yp;            %推荐用这种写法，因为有优先消去N，计算速度快
% y_new=zeros(ny,n+p);
% for i=1:n
%     for j=1:p
%         Y_new((j-1)*ny+1:j*ny,:)=y_new(:,i+j-1);
%     end
%     y_new(:,p+i)=Coeff*Y_new+et(:,i);
% end
% y_new=y_new(:,p+1:end);
end