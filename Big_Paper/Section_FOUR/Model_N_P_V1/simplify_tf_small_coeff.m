function [tf_simplified] = simplify_tf_small_coeff(tf_original, tol)
% SIMPLIFY_TF_SMALL_COEFF （SISO专用）剔除离散传递函数中接近0的小系数项，返回简化后的传递函数
% 输入参数：
%   tf_original - 原始SISO离散传递函数对象（tf类型，变量推荐为z^-1）
%   tol         - 容差阈值，绝对值小于该阈值的系数会被剔除（可选，默认值1e-4）
% 输出参数：
%   tf_simplified - 剔除小系数后的SISO简化传递函数对象（保持与原始格式一致）

% ------------- 处理可选参数（默认容差）-------------
if nargin < 2 || isempty(tol)
    tol = 1e-4; % 默认容差，覆盖题目中的0.0001159
end

% ------------- 校验输入有效性（SISO+tf类型）-------------
if ~isa(tf_original, 'tf')
    error('输入参数 tf_original 必须是 Matlab tf 传递函数对象！');
end
if size(tf_original) ~= [1 1]
    error('该函数仅支持SISO传递函数，请输入单输入单输出的tf对象！');
end

% ------------- 提取SISO传递函数的分子、分母系数（解决numden报错核心）-------------
% 方法：先将传递函数转为多项式形式，再提取系数（避免直接numden的格式问题）
[num_coeff, den_coeff] = tfdata(tf_original, 'v'); % 'v' 表示返回列向量/行向量（数值数组，无细胞数组）

% ------------- 筛选系数（剔除小系数）-------------
% 1. 分子筛选：直接保留绝对值大于容差的项
num_simplified = num_coeff(abs(num_coeff) > tol);

% 2. 分母筛选：强制保留常数项（z^0），再筛选其他项（避免传递函数失效）
den_simplified = den_coeff(1); % 保留分母常数项（核心，不可删除）
if length(den_coeff) > 1
    den_other = den_coeff(2:end); % 提取z^-1及更高阶项
    den_other_simplified = den_other(abs(den_other) > tol); % 筛选小系数
    den_simplified = [den_simplified, den_other_simplified]; % 合并系数
end

% ------------- 重新构造SISO简化传递函数 -------------
Ts = tf_original.Ts; % 保留原始采样时间
var_name = get(tf_original, 'Variable'); % 保留原始变量格式（z^-1）
tf_simplified = tf(num_simplified, den_simplified, Ts, 'Variable', var_name);

end