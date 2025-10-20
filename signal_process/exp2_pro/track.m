% 清理工作区
clear; clc; close all;

% 参数设置
fs = 204800;          % 采样频率: 204.8 kHz
f = 1000;             % 信号频率: 1 kHz
N = 2048;             % 采样点数
t = (0:N-1)/fs;       % 时间向量

% 生成带初始相位的正弦信号 (加入30度初始相位使结果更直观)
initial_phase = 30;   % 初始相位(度)
signal = sin(2*pi*f*t + initial_phase*pi/180);
subplot(2,4,1);
% 加窗处理减少频谱泄漏
window = hann(N);     % 使用汉宁窗
signal_windowed = signal .* window';


% FFT计算
fft_result = fft(signal_windowed);
mag = abs(fft_result);                % 幅度谱
phase = angle(fft_result) * 180/pi;   % 相位谱(转换为度)

% 计算频率轴
freq_axis = (0:N-1)*(fs/N);           % 频率轴(Hz)

% 找到1kHz信号的峰值位置
[~, k_pos] = max(mag(1:N/2));         % 正频率峰值索引
k_neg = N - k_pos + 1;                % 负频率峰值索引(共轭对称)

% 相位校正 - 解决相位跳变问题
phase_unwrapped = unwrap(angle(fft_result)) * 180/pi;

% 绘图
figure('Name','FFT相位谱分析','Position',[100 100 1000 600]);

% 子图1: 时域信号
subplot(2,2,1);
plot(t*1000, signal);  % 时间单位转换为毫秒
xlabel('时间 (ms)');
ylabel('幅度');
title('时域信号 (1 kHz 正弦波)');
grid on;
xlim([0 max(t)*1000]);

% 子图2: 幅度谱
subplot(2,2,2);
plot(freq_axis/1000, mag);  % 频率单位转换为kHz
xlabel('频率 (kHz)');
ylabel('幅度');
title('FFT幅度谱');
grid on;
xlim([0 fs/2/1000]);  % 只显示正频率到Nyquist频率

% 子图3: 原始相位谱
subplot(2,2,3);
plot(freq_axis/1000, phase, '.');
hold on;
plot(freq_axis(k_pos)/1000, phase(k_pos), 'ro', 'MarkerSize', 10);
plot(freq_axis(k_neg)/1000, phase(k_neg), 'bo', 'MarkerSize', 10);
text(freq_axis(k_pos)/1000+0.5, phase(k_pos), ...
    sprintf('+1kHz: %.1f°', phase(k_pos)), 'Color', 'r');
text(freq_axis(k_neg)/1000-2, phase(k_neg), ...
    sprintf('-1kHz: %.1f°', phase(k_neg)), 'Color', 'b');
xlabel('频率 (kHz)');
ylabel('相位 (度)');
title('原始相位谱');
grid on;
ylim([-200 200]);
xlim([0 fs/1000]);

% 子图4: 解缠绕后的相位谱
subplot(2,2,4);
plot(freq_axis/1000, phase_unwrapped, '.');
hold on;
plot(freq_axis(k_pos)/1000, phase_unwrapped(k_pos), 'ro', 'MarkerSize', 10);
plot(freq_axis(k_neg)/1000, phase_unwrapped(k_neg), 'bo', 'MarkerSize', 10);
text(freq_axis(k_pos)/1000+0.5, phase_unwrapped(k_pos), ...
    sprintf('+1kHz: %.1f°', phase_unwrapped(k_pos)), 'Color', 'r');
text(freq_axis(k_neg)/1000-2, phase_unwrapped(k_neg), ...
    sprintf('-1kHz: %.1f°', phase_unwrapped(k_neg)), 'Color', 'b');
xlabel('频率 (kHz)');
ylabel('相位 (度)');
title('解缠绕后的相位谱');
grid on;
xlim([0 fs/1000]);

% 调整子图布局
sgtitle('1 kHz 正弦信号的FFT相位谱分析');
tight_layout;
