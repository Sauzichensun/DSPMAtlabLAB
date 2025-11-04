clc;
clear;
close;
%生成信号
f_signal = [1e3,2e3,3e3,4e3];
f_s = 1.6384e6;

t = 0:1/f_s:(16384-1)/f_s;
signal = 1.0*cos(2*pi*f_signal(1)*t) + 0.2*cos(2*pi*f_signal(2)*t)+...
0.02*cos(2*pi*f_signal(3)*t) + 0.01*cos(2*pi*f_signal(4)*t);

%绘制信号
figure;
plot(t,signal);
title('Time Domain Signal');
xlabel('Time (s)');
ylabel('Amplitude');

%FFT分析信号频谱
N = length(signal);
Y = fft(signal,N);
Magt = abs(Y/N);
Phase = angle(Y);

%绘制信号频谱
f = f_s*(0:(N/2))/N;
figure;
stem(f,Magt(1:floor(N/2+1)));
title('Signal Spectrum');
xlabel('Frequency (f)');
ylabel('|P1(f)|');
figure;
stem(f,Phase(1:floor(N/2+1)));
title('Signal Phase Spectrum');
xlabel('Frequency (f)');
ylabel('Phase P1(f)');

figure;
OutDacSignal = DACOut(1e3,2,1e6);
stem(OutDacSignal);

figure;


