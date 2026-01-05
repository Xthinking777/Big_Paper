function [var_u,var_sat_u,var_y,sat_percent]=sim_sat_lqg(kzq_set,n,p,alpha)
 for kzq_i=1:1:length(kzq_set)% λ 
    % 提取分子和分母
    [kzq_fenzi, kzq_fenmu] = tfdata(kzq_set(kzq_i), 'v');
    [T_fenzi, T_fenmu] = tfdata(p, 'v');%包含时延
    [N_fenzi, N_fenmu] = tfdata(n, 'v');
    sat_alpha=alpha;
    % 确保仿真模型已加载
    assignin('base', 'kzq_fenzi', kzq_fenzi);
    assignin('base', 'kzq_fenmu', kzq_fenmu);
    assignin('base', 'T_fenzi', T_fenzi);
    assignin('base', 'T_fenmu', T_fenmu);
    assignin('base', 'N_fenzi', N_fenzi);
    assignin('base', 'N_fenmu', N_fenmu);
    assignin('base', 'sat_alpha', sat_alpha);
    sim('Sat_Nonliner_3'); 
    %计算饱和度
    sat_num=0;
    sat_num_all=1000;
    for i=1:1:sat_num_all
        if(abs(u_k(i))>sat_alpha) 
            sat_num=sat_num+1;
        end
    end
    sat_percent(kzq_i)=sat_num/sat_num_all*100;
    %计算方差
    var_u(kzq_i)    =var(u_k)^0.5;%输入方差
    var_sat_u(kzq_i)=var(sat_u_k)^0.5;%饱和输入方差
    var_y(kzq_i)=var(y_k)^0.5;%输出方差
 end

end