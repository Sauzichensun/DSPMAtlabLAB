function OutputSignal = AnaLPF(inputSignal, fs)
% ANALPF 模拟低通滤波器仿真（连续域精确计算）
%注意
% 传递函数: H(s) = 5/(1e-8 s² + 3e-4 s + 1)
% 输入:
%   inputSignal - 输入信号（一维向量）
%   fs          - 采样频率（Hz）
% 输出:
%   OutputSignal - 滤波后的信号（与输入数组长度相同）

    % ---- 参数检查 ----
    if nargin < 2
        error('必须提供 inputSignal 和 fs');
    end
    if ~isvector(inputSignal)
        error('inputSignal 必须是行或列向量');
    end

    % 确保是列向量便于处理
    inputSignal = inputSignal(:);

    % ---- 定义连续域传递函数 ----
    num = 5;                          % 分子系数
    den = [1e-8, 3e-4, 1];            % 分母系数
    sys_c = tf(num, den);             % 连续时间传递函数

    % ---- 生成时间向量 ----
    Ts = 1/fs;                        % 采样周期
    N = length(inputSignal);          % 样本点数
    t = (0:N-1)' * Ts;                 % 时间轴

    % ---- 连续系统响应计算 ----
    OutputSignal = lsim(sys_c, inputSignal, t); 

end
