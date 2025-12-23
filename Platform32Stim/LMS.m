clc;
clear;
close;

N = 1000;
M = 16;
mu = 0.001;

%产生信号
x1 = randn(N/2,1);
x2 = 10*randn(N/2,1);
x = [x1;x2];%添加信号突变

% x = 10*randn(N,1);%激励信号，高斯白噪声
h_true = randn(M,1);%未知系统的真值(目标预测的系数)
d = filter(h_true,1,x) + 0.01*randn(N,1);%期望信号 = 真实输出 + 观测噪声

%初始化
w = zeros(M,1);
e = zeros(N,1);
y = zeros(N,1);%输出记录

%LMS循环
for n = M : N 
    %提取输入向量
    x_n = x(n:-1:n-M+1);

    %计算输出
    for i = 1:M
        y(n) = y(n)+w(i)*x_n(i);
    end
    %计算误差
    
    e(n) = d(n) - y(n);
    %更新权重
    w = w + 2*mu*e(n)*x_n;


end

figure;
plot(10*log10(e.^2)); % 转化为 dB 尺度
grid on;
title('LMS 算法的学习曲线');
xlabel('迭代次数 (n)');
ylabel('平方误差 (dB)');

figure;
stem(h_true, 'r', 'LineWidth', 1.5); hold on;
stem(w, 'b--', 'LineWidth', 1.5);
legend('真实系数 (h\_true)', 'LMS估计系数 (w)');
title('系统辨识结果对比');


w = zeros(M,1);
e = zeros(N,1);
y = zeros(N,1);%输出记录

%NLMS
mu = 0.5;
eps_val = 1e-10;
for n = M : N 
    %提取输入向量
    x_n = x(n:-1:n-M+1);

    %计算输出
    for i = 1:M
        y(n) = y(n)+w(i)*x_n(i);
    end
    %计算误差
    e(n) = d(n) - y(n);
    %更新权重
    norm_x = x_n'*x_n;
    w = w + (mu/(norm_x + eps_val))*e(n)*x_n;
end

figure;
plot(10*log10(e.^2)); % 转化为 dB 尺度
grid on;
title('NLMS 算法的学习曲线');
xlabel('迭代次数 (n)');
ylabel('平方误差 (dB)');

figure;
stem(h_true, 'r', 'LineWidth', 1.5); hold on;
stem(w, 'b--', 'LineWidth', 1.5);
legend('真实系数 (h\_true)', 'NLMS估计系数 (w)');
title('系统辨识结果对比');
