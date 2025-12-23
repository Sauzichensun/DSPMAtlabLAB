clc;
clear;
% 参数定义
fs_dac = 10e3;       % DAC 采样率 1MHz
Ts = 1/fs_dac;        % 采样周期
f_sig = 500;          % 信号频率
dt = 1e-7;
t_sim = 0:dt:0.005; % 高密度时间轴 (模拟连续)

% 连续信号
signal = sin(2*pi*f_sig*t_sim);

%采样信号
t_sample = 0:Ts:0.005;
signal_sample = sin(2*pi*f_sig*t_sample);

%矩形函数h(t)

h_zoh = ones(1,round(Ts/dt));

%零阶插值结果
%采样信号映射到连续时间轴
signal_impluse = zeros(1,length(t_sim));
indices = round(t_sample/dt)+1;

% 防止索引越界
indices = indices(indices <= length(t_sim));
signal_impluse(indices) = signal_sample(1:length(indices));

% 零阶保持卷积（使用 'full' 保持长度一致）
signal_zoh = conv(signal_impluse, h_zoh);
signal_zoh = signal_zoh(1:length(t_sim));

figure;
plot(signal_zoh,Color='red');hold on;plot(signal,Color='blue');hold off;
grid on;

%传递函数
fc = 2e3;
%一阶RC滤波器
num = [1];
tau = 1/(2*pi*fc);
den =[tau,1];
sys_lf = tf(num,den);

[y_filtered, t_out] = lsim(sys_lf, signal_zoh, t_sim);

% 绘图对比
figure;
plot(t_sim, signal_zoh, 'b', 'LineWidth', 1); hold on;
plot(t_out, y_filtered, 'r', 'LineWidth', 2);
legend('DAC 输出 (阶梯波)', '滤波后信号');
xlabel('时间 (s)'); ylabel('电压 (V)');
title('低通滤波器对 DAC 信号的平滑效果');
grid on;

%二阶巴特沃斯滤波器
[b,a] = butter(2,2*pi*fc,'s');
sys_buffer = tf(b,a);

%二阶巴特沃斯滤波器输出
[y_butter,tout2] = lsim(sys_buffer,signal_zoh,t_sim);

%引入有源滤波器
%可控增益 阻抗隔离
%Sallen-Key二阶有源滤波器
wc = 2*pi*fc;
Q = 0.707;
sallen_key_num = wc*wc;
sallen_key_den = [1,wc/Q,wc*wc];
sallen_key_sys = tf(sallen_key_num,sallen_key_den,Name='Sallen_key-second-order');

[y_sallen,t_sallen] = lsim(sallen_key_sys,signal_zoh,t_sim);
% 绘图对比
figure;
plot(t_sim, signal_zoh, 'k:'); hold on;
plot(t_out, y_filtered, 'b', 'DisplayName', '一阶 LPF');
plot(tout2, y_butter, 'r', 'LineWidth', 1.5, 'DisplayName', '二阶巴特沃斯');
plot(t_sallen,y_sallen,'green','LineWidth', 1.5, 'DisplayName', '二阶sallen-key低通滤波器');
legend; title('不同阶数滤波器的对比');


% 定义不同的 Q 值
Q_list = [2.0, 0.707, 0.3];
colors = ['r', 'g', 'b'];
figure;
plot(t_sim, signal_zoh, 'k:', 'DisplayName', 'DAC Output'); hold on;

for i = 1:length(Q_list)
    Q_val = Q_list(i);
    % 构建传递函数
    num = wc^2;
    den = [1, wc/Q_val, wc^2];
    sys = tf(num, den);
    
    % 仿真
    y_out = lsim(sys, signal_zoh, t_sim);
    plot(t_sim, y_out, colors(i), 'LineWidth', 1.5, ...
         'DisplayName', ['Q = ', num2str(Q_val)]);
end

legend; title('不同 Q 值下的滤波器过冲现象'); grid on;


grpdelay();