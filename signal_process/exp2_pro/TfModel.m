clc;
%% 1. 定义传递函数
num = 5;                      % 分子多项式：5
den = [1e-8, 3e-4, 1];        % 分母多项式：1e-8 s² + 3e-4 s + 1
sys = tf(num, den);           % 创建传递函数模型


%% 2. 频率响应分析（100Hz ~ 3kHz）
f_start = 100;
f_end = 3e3;
N = 1000;
f = linspace(f_start,f_end,N);%生成频率向量
[mag,phase] = bode(sys,2*pi*f);% bode图输出的是线性刻度，参数需要omiga

mag = squeeze(mag);           % 去除多余维度，简化数据格式

%% 3. 绘制幅频特性曲线（线性刻度）
figure('Name', '幅频特性分析');
plot(f, mag, 'LineWidth', 1.5);  % 使用转换后的线性幅度值
xlabel('频率 (Hz)');
ylabel('幅度 (V/V)');
title('幅频特性（线性刻度）');
grid on;