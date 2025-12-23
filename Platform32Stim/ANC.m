fs = 8000;
t = 0:1/fs:1;%1s的采样时间
N = length(t);

%纯净信号
s = sin(2*pi*440*t);%标准A音
%噪声源
v = randn(N,1);
%环境滤波器
h_env = [1,0.5,-0.2,0.1];
n = filter(h_env,1,v);
%混合信号
d = s' + n;%期望信号
%参考信号
x = v;%LMS输入信号


%初始化
M = 6;
w = zeros(M,1);
e = zeros(N,1);
y = zeros(N,1);%输出记录
mu = 0.001;
%LMS循环
% for n = M : N 
%     %提取输入向量
%     x_n = x(n:-1:n-M+1);
%     %计算输出
%     for i = 1:M
%         y(n) = y(n)+w(i)*x_n(i);
%     end
%     %计算误差  
%     e(n) = d(n) - y(n);
%     %更新权重
%     w = w + 2*mu*e(n)*x_n;
% end

%NLMS循环
eps_val = 1e-10;
M = 4;
w = zeros(M,1);
e = zeros(N,1);
y = zeros(N,1);%输出记录
mu = 0.01;
for n = M : N 
    %提取输入向量
    x_n = x(n:-1:n-M+1);
    %计算输出
    % for i = 1:M
    %     y(n) = y(n)+w(i)*x_n(i);
    y(n) = w' * x_n;
    
    %计算误差  
    e(n) = d(n) - y(n);
    %更新权重
    norm_x = x_n'*x_n;
    w = w + (mu/(norm_x + eps_val))*e(n)*x_n;
end

figure;
subplot(3,1,1); plot(s); title('原始纯净信号 (s)'); ylim([-2 2]);
subplot(3,1,2); plot(d); title('带噪混合信号 (d)'); ylim([-4 4]);
subplot(3,1,3); plot(e); title('LMS处理后的信号 (e)'); ylim([-2 2]);

%试听（如果你的电脑有声卡）
sound(d, fs); % 听听带噪声的
pause(1.5);
sound(e, fs); % 听听去噪后的