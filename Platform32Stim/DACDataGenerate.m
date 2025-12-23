% 清理工作区和命令行窗口
clear;
clc;
close;

% --- 用户可配置参数 ---
waveform_freq = 50000;          % 信号频率 (Hz)，例如 1000 Hz (1 kHz)
peak_to_peak = 1;            % 信号峰峰值 (V)，例如 3.3V
dac_resolution = 12;           % STM32 DAC 分辨率 (bits)
dac_vref = 3.3;                % STM32 Vref (V)

% --- DAC/系统参数 (与你的STM32设置对应) ---
dac_trigger_freq = 1e6;        % DAC 触发频率 (Hz)，即1 MHz

% --- 核心计算 ---
% 计算数字化的峰值
digital_peak = 2^dac_resolution - 1;
% 计算信号的幅度值（以Vref为基准）
amplitude = peak_to_peak / 2;
% 将模拟幅度转换为 DAC 码值
digital_amplitude = (amplitude / dac_vref) * digital_peak;
% 计算一个波形周期所需的点数
points_per_cycle = dac_trigger_freq / waveform_freq;

n = 0:points_per_cycle;
dac_wave_float = amplitude*(sin(2*pi*waveform_freq/dac_trigger_freq*n)+1);
dac_wave_code = dac_wave_float/dac_vref*digital_peak;

%32输出与测量真实信号
fft_signal = abs(fft(dac_wave_code));
plot(dac_wave_code);