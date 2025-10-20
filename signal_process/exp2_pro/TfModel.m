clc;
%% 1. 定义传递函数
num = 5;                      % 分子多项式：5
den = [1e-8, 3e-4, 1];        % 分母多项式：1e-8 s² + 3e-4 s + 1
sys = tf(num, den);           % 创建传递函数模型

%% 2. 频率响应分析（1kHz ~ 50kHz）
f_start = 1e3;
f_end = 50e3;
N = 100; % 步长 100Hz，点数 500
f = f_start:N:f_end;%生成频率向量
omega = 2*pi*f; % 转换为角频率 ω = 2πf

% 调用 bode 函数，返回线性幅度 mag (V/V) 和相位 phase (度)
[mag, phase] = bode(sys, omega);

% 去除多余维度
mag = squeeze(mag);           
phase = squeeze(phase); 

%% 3. 绘制幅频和相频特性曲线

figure('Name', '幅频和相频特性分析');

% --- 子图 1: 幅频特性 (线性刻度) ---
subplot(2, 1, 1); % 分为 2 行 1 列，选择第 1 个
plot(f, mag, 'b-', 'LineWidth', 1.5);  
xlabel('频率 (Hz)');
ylabel('幅度增益 (V/V)');
title('滤波器的幅频特性');
grid on;

% --- 子图 2: 相频特性 (角度刻度) ---
subplot(2, 1, 2); % 分为 2 行 1 列，选择第 2 个
plot(f, phase, 'r-', 'LineWidth', 1.5); 
xlabel('频率 (Hz)');
ylabel('相位 (度)');
title('滤波器的相频特性');
grid on;

%用delta函数测出这个滤波器的响应
%% ========================================================================
%  基于冲激响应的二阶系统信号处理
%  作者：AI Assistant
%  功能：通过delta函数获取系统响应，实现任意信号的系统输出预测
% =========================================================================

clear; clc; close all;

%% 1. 参数设置
fs = 204800;           % 采样率 (Hz)
N = 2048;              % 采样点数
dt = 1/fs;             % 采样间隔
t = (0:N-1) * dt;      % 时间轴

% 频率分辨率
df = fs / N;           % 频率分辨率 = 100 Hz (204800/2048 = 100)
f = (0:N-1) * df;      % 频率轴

fprintf('采样参数:\n');
fprintf('  采样率: %d Hz\n', fs);
fprintf('  采样点数: %d\n', N);
fprintf('  频率分辨率: %.2f Hz (无频谱泄漏)\n', df);
fprintf('  时间窗长: %.4f ms\n\n', (N-1)*dt*1000);

%% 2. 构建二阶滤波器系统 (巴特沃斯低通滤波器)
% 参数设置
fc = 10000;            % 截止频率 10 kHz
wn = 2*pi*fc;          % 自然频率 (rad/s)
zeta = 0.707;          % 阻尼比 (临界阻尼 zeta=1, 欠阻尼 0<zeta<1)

% 连续系统传递函数: H(s) = wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
num_c = wn^2;
den_c = [1, 2*zeta*wn, wn^2];
sys_c = tf(num_c, den_c);

fprintf('二阶系统参数:\n');
fprintf('  截止频率: %d Hz\n', fc);
fprintf('  阻尼比: %.3f\n', zeta);
fprintf('  系统类型: 巴特沃斯低通滤波器\n\n');

% 转换为离散系统 (双线性变换)
sys_d = c2d(sys_c, dt, 'tustin');
[num_d, den_d] = tfdata(sys_d, 'v');

fprintf('离散系统差分方程系数:\n');
fprintf('  分子 b: [%.6f, %.6f, %.6f]\n', num_d);
fprintf('  分母 a: [%.6f, %.6f, %.6f]\n\n', den_d);

%% 3. 生成Delta函数（单位冲激）
delta = zeros(1, N);
delta(1) = 1;          % 单位冲激

output1 = AnaLPF(delta,1e6);
output2 = AnaLPF(delta,1e3);
% % 计算系统的冲激响应
% h = filter(num_d, den_d, delta);
% 
% fprintf('冲激响应计算完成\n');
% fprintf('  冲激响应长度: %d 点\n', length(h));
% fprintf('  冲激响应能量: %.6f\n\n', sum(h.^2));
% 
% %% 4. 生成任意测试信号（多频率复合信号）
% % 信号1: 5kHz正弦波 (通带内)
% f1 = 5000;
% A1 = 1.0;
% signal1 = A1 * sin(2*pi*f1*t);
% 
% % 信号2: 20kHz正弦波 (阻带内，应被滤除)
% f2 = 20000;
% A2 = 0.8;
% signal2 = A2 * sin(2*pi*f2*t);
% 
% % 信号3: 白噪声
% noise = 0.1 * randn(1, N);
% 
% % 复合输入信号
% x_input = signal1 + signal2 + noise;
% 
% fprintf('输入信号组成:\n');
% fprintf('  成分1: %.0f Hz 正弦波, 幅值 %.1f\n', f1, A1);
% fprintf('  成分2: %.0f Hz 正弦波, 幅值 %.1f\n', f2, A2);
% fprintf('  成分3: 白噪声, 标准差 0.1\n\n');
% 
% %% 5. 方法1：直接使用filter函数（验证用）
% y_direct = filter(num_d, den_d, x_input);
% 
% %% 6. 方法2：通过卷积计算（基于冲激响应）
% % 时域卷积
% y_conv = conv(x_input, h, 'same');  % 'same'保持长度一致
% 
% % 或频域卷积（更高效）
% X = fft(x_input);
% H_fft = fft(h);
% Y_fft = X .* H_fft;
% y_freq = real(ifft(Y_fft));
% 
% %% 7. 误差分析
% error_conv = y_direct - y_conv;
% error_freq = y_direct - y_freq;
% 
% fprintf('输出结果对比:\n');
% fprintf('  直接滤波 vs 时域卷积误差: %.2e (RMS)\n', rms(error_conv));
% fprintf('  直接滤波 vs 频域卷积误差: %.2e (RMS)\n\n', rms(error_freq));
% 
% %% 8. 频谱分析（使用窗函数避免泄漏）
% % 应用Hanning窗
% window = hann(N)';
% x_windowed = x_input .* window;
% y_windowed = y_direct .* window;
% 
% % FFT计算
% X_fft = fft(x_windowed) / N * 2;  % 单边幅度谱
% Y_fft = fft(y_windowed) / N * 2;
% 
% % 只取正频率部分
% idx_pos = 1:N/2;
% f_pos = f(idx_pos);
% X_mag = abs(X_fft(idx_pos));
% Y_mag = abs(Y_fft(idx_pos));
% 
% %% 9. 计算系统频率响应（理论值）
% [H_theory, f_theory] = freqz(num_d, den_d, N/2, fs);
% 
% %% ========================================================================
% %% 10. 结果可视化
% %% ========================================================================
% 
% figure('Color', 'w', 'Position', [100, 100, 1400, 900]);
% 
% % -------------------- 子图1: 冲激响应 --------------------
% subplot(3,3,1);
% plot(t*1000, h, 'b-', 'LineWidth', 1.5);
% grid on;
% xlabel('时间 (ms)');
% ylabel('幅值');
% title('系统冲激响应 h(t)');
% xlim([0, 1]);  % 只显示前1ms
% 
% % -------------------- 子图2: 系统频率响应 --------------------
% subplot(3,3,2);
% semilogx(f_theory, 20*log10(abs(H_theory)), 'r-', 'LineWidth', 2);
% hold on;
% xline(fc, 'k--', 'LineWidth', 1.5, 'Label', sprintf('f_c=%dHz', fc));
% grid on;
% xlabel('频率 (Hz)');
% ylabel('幅值 (dB)');
% title('系统频率响应 |H(f)|');
% xlim([100, fs/2]);
% 
% % -------------------- 子图3: 相位响应 --------------------
% subplot(3,3,3);
% semilogx(f_theory, angle(H_theory)*180/pi, 'm-', 'LineWidth', 2);
% grid on;
% xlabel('频率 (Hz)');
% ylabel('相位 (度)');
% title('系统相位响应 ∠H(f)');
% xlim([100, fs/2]);
% 
% % -------------------- 子图4: 输入信号时域 --------------------
% subplot(3,3,4);
% plot(t*1000, x_input, 'k-', 'LineWidth', 0.8);
% grid on;
% xlabel('时间 (ms)');
% ylabel('幅值');
% title('输入信号 x(t)');
% xlim([0, 1]);
% 
% % -------------------- 子图5: 输出信号时域 --------------------
% subplot(3,3,5);
% plot(t*1000, y_direct, 'b-', 'LineWidth', 1.2);
% hold on;
% plot(t*1000, y_conv, 'r--', 'LineWidth', 1);
% grid on;
% xlabel('时间 (ms)');
% ylabel('幅值');
% title('输出信号 y(t)');
% legend('直接滤波', '卷积结果', 'Location', 'best');
% xlim([0, 1]);
% 
% % -------------------- 子图6: 误差分析 --------------------
% subplot(3,3,6);
% semilogy(t*1000, abs(error_conv), 'g-', 'LineWidth', 1);
% grid on;
% xlabel('时间 (ms)');
% ylabel('绝对误差');
% title('卷积方法误差');
% xlim([0, 1]);
% 
% % -------------------- 子图7: 输入频谱 --------------------
% subplot(3,3,7);
% semilogy(f_pos/1000, X_mag, 'k-', 'LineWidth', 1.5);
% hold on;
% xline(f1/1000, 'b--', 'LineWidth', 1, 'Label', sprintf('%dkHz', f1/1000));
% xline(f2/1000, 'r--', 'LineWidth', 1, 'Label', sprintf('%dkHz', f2/1000));
% xline(fc/1000, 'g--', 'LineWidth', 1.5, 'Label', 'f_c');
% grid on;
% xlabel('频率 (kHz)');
% ylabel('幅值');
% title('输入信号频谱 |X(f)|');
% xlim([0, 50]);
% 
% % -------------------- 子图8: 输出频谱 --------------------
% subplot(3,3,8);
% semilogy(f_pos/1000, Y_mag, 'b-', 'LineWidth', 1.5);
% hold on;
% xline(fc/1000, 'g--', 'LineWidth', 1.5, 'Label', 'f_c');
% grid on;
% xlabel('频率 (kHz)');
% ylabel('幅值');
% title('输出信号频谱 |Y(f)|');
% xlim([0, 50]);
% 
% % -------------------- 子图9: 频谱对比 --------------------
% subplot(3,3,9);
% plot(f_pos/1000, 20*log10(X_mag), 'k-', 'LineWidth', 1, 'DisplayName', '输入');
% hold on;
% plot(f_pos/1000, 20*log10(Y_mag), 'b-', 'LineWidth', 1.5, 'DisplayName', '输出');
% plot(f_theory/1000, 20*log10(abs(H_theory)), 'r--', 'LineWidth', 1, 'DisplayName', '系统响应');
% grid on;
% xlabel('频率 (kHz)');
% ylabel('幅值 (dB)');
% title('频域对比');
% legend('Location', 'best');
% xlim([0, 50]);
% ylim([-80, 20]);
% 
% sgtitle('二阶系统冲激响应分析与信号处理', 'FontSize', 14, 'FontWeight', 'bold');
% 
% %% 11. 性能验证
% fprintf('========================================\n');
% fprintf('性能验证:\n');
% fprintf('========================================\n');
% 
% % 频率成分检测
% [pks_in, locs_in] = findpeaks(X_mag, 'MinPeakHeight', 0.1);
% [pks_out, locs_out] = findpeaks(Y_mag, 'MinPeakHeight', 0.01);
% 
% fprintf('输入信号主要频率成分:\n');
% for i = 1:length(locs_in)
%     fprintf('  f = %.0f Hz, A = %.3f\n', f_pos(locs_in(i)), pks_in(i));
% end
% 
% fprintf('\n输出信号主要频率成分:\n');
% for i = 1:length(locs_out)
%     fprintf('  f = %.0f Hz, A = %.3f\n', f_pos(locs_out(i)), pks_out(i));
% end
% 
% % 衰减计算
% atten_5k = 20*log10(Y_mag(f_pos == f1) / X_mag(f_pos == f1));
% atten_20k = 20*log10(Y_mag(f_pos == f2) / X_mag(f_pos == f2));
% 
% fprintf('\n频率衰减:\n');
% fprintf('  %d Hz: %.2f dB (通带，衰减小)\n', f1, atten_5k);
% fprintf('  %d Hz: %.2f dB (阻带，衰减大)\n', f2, atten_20k);
% 
% fprintf('\n频谱泄漏检验:\n');
% fprintf('  频率分辨率: %.0f Hz\n', df);
% fprintf('  是否为100Hz整数倍: %s\n', iif(mod(df, 100)==0, '是✓', '否✗'));
% 
% fprintf('========================================\n');
% 
% %% 12. 保存结果
% save('system_response.mat', 'h', 'sys_d', 'fs', 'N', 't', 'f');
% fprintf('\n冲激响应已保存至 system_response.mat\n');
% 
% %% ========================================================================
% %% 辅助函数
% %% ========================================================================
% function result = iif(condition, trueVal, falseVal)
%     if condition
%         result = trueVal;
%     else
%         result = falseVal;
%     end
% end
% 
% %% ========== 三滤波器级联系统分析 ==========
% clear; clc; close all;
% 
% %% 1. 定义系统参数
% fs = 50000;                          % 采样频率 50kHz（确保足够高）
% N = 4096;                            % 信号长度
% t = (0:N-1)' / fs;                   % 时间向量
% 
% % 定义三个滤波器传递函数
% % 滤波器1
% num1 = 5;
% den1 = [1e-8, 3e-4, 1];
% sys1 = tf(num1, den1);
% 
% % 滤波器2（示例：一阶低通）
% num2 = 1;
% den2 = [1e-4, 1];
% sys2 = tf(num2, den2);
% 
% % 滤波器3（示例：二阶带通）
% num3 = [1e-3, 0];
% den3 = [1e-6, 5e-4, 1];
% sys3 = tf(num3, den3);
% 
% % 级联系统（理论值）
% sys_total = sys1 * sys2 * sys3;
% 
% fprintf('========== 滤波器传递函数 ==========\n');
% fprintf('滤波器1: H1(s) = 5 / (1e-8*s² + 3e-4*s + 1)\n');
% fprintf('滤波器2: H2(s) = 1 / (1e-4*s + 1)\n');
% fprintf('滤波器3: H3(s) = (1e-3*s) / (1e-6*s² + 5e-4*s + 1)\n');
% fprintf('级联系统: H_total(s) = H1(s) * H2(s) * H3(s)\n');
% fprintf('====================================\n\n');
% 
