function [c,ceq] = fitting_constraint(x,lqgxs)
    % 定义约束关系 x1 = 1 + 2*x2^2 + 3*x2^3
%     lqgxs=[-1.1185    2.8136   -2.4070    2.3057];
%     lqgxs=[-1.1816    2.9409   -2.4828    2.3177];
%     lqgxs=[-0.7319    2.0170   -1.8912    2.2011];
    %lqgxs=[-0.7319    2.0170   -1.8912    2.2011];
    c=[];
    ceq(1) = x(3) - (lqgxs(1)*x(4)^3+lqgxs(2)*x(4)^2+lqgxs(3)*x(4)+lqgxs(4));      
end