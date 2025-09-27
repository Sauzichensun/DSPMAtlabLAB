f = 20e3;
Fs = 1e6;
TCircle = 1000;
t = 0:1/Fs:TCircle*Fs/f/Fs;%1000个周期

signal_test = 1*sin(2*pi*f*t);%测试信号
figure;
plot(t,signal_test);
title("测试模拟信号");

%离散化序列
N = length(t);
DiscreteSignal(1:N) = signal_test;
figure;
plot((0:N-1),DiscreteSignal);
title("测试离散化后的信号");

Analogout = AnaLPF(DiscreteSignal,Fs);
hold on;
plot((0:N-1),Analogout);
title("经过模拟滤波器输出后的信号");



