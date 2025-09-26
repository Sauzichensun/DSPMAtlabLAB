f = 20e3;
Fs = 1e6;
TCircle = 1000;
t = 0:1/Fs:TCircle*Fs/f/Fs;%1000个周期
signal = 1*sin(2*pi*f*t);
figure;
plot(t,signal);
%离散化序列
N = length(t);
DiscreteSignal(1:N) = signal;
figure;
plot((0:N-1),DiscreteSignal);
Y = AnaLPF(DiscreteSignal,Fs);
figure;
plot((0:N-1),Y);

