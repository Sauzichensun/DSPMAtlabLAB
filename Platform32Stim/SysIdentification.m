clc;
close;
clear;
%定义系统函数
%一阶低通滤波器H(s)=a/(s+a)---a为截止频率（角频率）
a = 200;
num = a;
den = [1 a];
fs = 8000;%采样率
sys_tf = tf(num,den);
%HS离散化后是一个IIR滤波器系统
sys_d = c2d(sys_tf,1/fs,'tustin'); %离散系统

%% 绘制伯德图
figure('Color','white','Position',[100 100 1000 600]);

% 子图1：连续系统伯德图
subplot(2,1,1);
bode(sys_tf);
title('连续系统 H(s) = 100/(s+100) 伯德图');
grid on;

% 子图2：离散系统伯德图
subplot(2,1,2);
bode(sys_d);
title(['离散系统（Tustin） 采样率 fs=' num2str(fs) 'Hz 伯德图']);
grid on;
%%参数定义
t = 0:1/fs:1.5;
N = length(t);
%白噪声

x = randn(N,1);
% 获取离散系统的分子分母系数（用于产生期望信号）
[num, den] = tfdata(sys_d, 'v');
d = filter(num,den,x);%期望输出信号
M = 200;

w =zeros(M,1);
e = zeros(N,1);
y = zeros(N,1);
mu = 0.1;
eps_cal = 1e-10;

for n = M:N
    x_n = x(n:-1:n-M+1);
    for i = 1:M
        y(n) = y(n) + w(i)*x_n(i);
    end
    norm_x = x_n'*x_n;
    e(n) = d(n) - y(n);
    w = w + (mu/(norm_x+eps_cal))*e(n)*x_n;
end

% --- 结果可视化 ---
figure;
subplot(2,1,1);
stem(w, 'MarkerSize', 2); title('辨识出的 FIR 系数 (w)');
grid on;

% 关键对比：对比频率响应
[H_est, f] = freqz(w, 1, 512, fs);
[H_true, ~] = freqz(sys_d.Numerator{1}, sys_d.Denominator{1}, 512, fs);

subplot(2,1,2);
plot(f, 20*log10(abs(H_true)), 'r', 'LineWidth', 2); hold on;
plot(f, 20*log10(abs(H_est)), 'b--', 'LineWidth', 1.5);
title('幅频响应对比 (True vs Estimated)');
ylabel('幅度 (dB)'); xlabel('频率 (Hz)');
legend('真实系统 H(z)', 'LMS辨识系统');


%二阶模型
fn = 500;
wn = 2*pi*fn;
zeta = 0.2;
v = 0.1 * randn(N, 1);%加入10%的噪声

num_s = wn^2;
den_s = [1 2*zeta*wn wn^2];
sys_s = tf(num_s,den_s);
sys_d = c2d(sys_s,1/fs,'tustin');
[num_z,den_z] = tfdata(sys_d,'v');
d = filter(num_z,den_z,x);%期望输出信号
M = 512;

w =zeros(M,1);
e = zeros(N,1);
y = zeros(N,1);
mu = 0.5;
eps_cal = 1e-10;

for n = M:N
    x_n = x(n:-1:n-M+1);
    for i = 1:M
        y(n) = y(n) + w(i)*x_n(i);
    end
    norm_x = x_n'*x_n;
    e(n) = d(n) - y(n);
    w = w + (mu/(norm_x+eps_cal))*e(n)*x_n;
end

% --- 结果可视化 ---
figure;
subplot(2,1,1);
stem(w, 'MarkerSize', 2); title('辨识出的 FIR 系数 (w)');
grid on;

% 关键对比：对比频率响应
[H_est, f] = freqz(w, 1, 512, fs);
[H_true, ~] = freqz(num_z, den_z, 512, fs);

subplot(2,1,2);
plot(f, 20*log10(abs(H_true)), 'r', 'LineWidth', 2); hold on;
plot(f, 20*log10(abs(H_est)), 'b--', 'LineWidth', 1.5);
title('幅频响应对比 (True vs Estimated)');
ylabel('幅度 (dB)'); xlabel('频率 (Hz)');
legend('真实系统 H(z)', 'LMS辨识系统');

figure;
plot(10*log10(e.^2 + 1e-12)); % 观察误差下降曲线
title('学习曲线 (MSE in dB)');
xlabel('迭代次数'); ylabel('误差能量 (dB)');

