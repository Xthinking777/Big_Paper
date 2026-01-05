function [c,ceq] = fitting_constraint2(x)
    % 定义约束关系 x1 = 1 + 2*x2^2 + 3*x2^3
    %   lqgxs=[-15.4588    4.4258   -0.4965    0.1143];
        lqgxs=[-31.2270    7.6157   -0.6973    0.1175];
    %   lqgxs=[ -6.2712    2.5431   -0.3035    0.1113];
    c=[];
    ceq(1) = x(3) - (lqgxs(1)*x(4)^3+lqgxs(2)*x(4)^2+lqgxs(3)*x(4)+lqgxs(4));

end