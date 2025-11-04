clc;
close all;
clear;
%% 说明
% 如果信号是个方波，由于这个代码用的滤波器是低通滤波器，所以高次谐波基本被抑制，看不出来，可以换滤波器，修改传递函数
% 如果经过离散化的模拟滤波器收敛太慢，可以增加点数，就可以看到收敛后的波形了

% 构建一个模拟滤波器
% num = 5;
% den = [1e-8,3e-4,1];

% 另一个滤波器
num = 3.94784176043574e9;
den = [1,8.8857534006821e4,3.94784176043574e9];

sys_filter = tf(num,den);
poles = pole(sys_filter)/2/pi;
zero_s = zero(sys_filter);

%% 模拟滤波器电压增益曲线（线性幅值）
%关于这个系统的增益与极点的关系还需要进一步学习，根据zero-pole能够大致推断出这个曲线应该是什么样子吗？

[mag, phase, w] = bode(sys_filter);
mag = squeeze(mag);           % 序列化电压增益（倍数）
w_hz = w / (2*pi);             % rad/s --> Hz

figure;
semilogx(w_hz, mag, 'LineWidth', 2);
grid on;
xlabel('频率 (Hz)');
ylabel('电压增益 (倍)');
title('模拟滤波器频率响应（电压增益）');
% 在图中标注极点位置
hold on;
for k = 1:length(poles)
    fc = abs(real(poles(k)));   % 频率取绝对值
    % 画竖线
    plot([fc fc], ylim, '--r');
    text(fc,max(mag)*0.2*k,...
        sprintf('极点:%d=%.1f Hz',k,fc));

end
hold off;

%%
%定义示波器采样率
f_osc = 100e6;
fs = 1.6384e6;%1.6384M采样率->1638400HZ

%%
%从模拟滤波器转为离散滤波器

SysDiscrete = c2d(sys_filter,1/f_osc,'tustin');
%离散化后的滤波器系数
[DiscreteNum,DiscreteDen] = tfdata(SysDiscrete,'v');

%%
%生成一个1k-50k(step:200)的矩形波（duty：10%-50% step:5%）
f_square = 10e3;
duty = 50;
t = 0:1/f_osc:200/f_square;
signal_square = square(2*pi*f_square*t,50)+1;

%生成一个1k-50k(step:200)的三角波
f_tri = 10e3;
t = 0:1/f_osc:20/f_tri;
duty_tri = 0.5;
signal_tri = sawtooth(2*pi*f_tri*t,duty_tri)+1;

%% 利用单位脉冲得到系统函数的单位冲击响应

%生成一个delta单位冲击序列
M = f_osc/fs;
deltan = [1 zeros(1, M*16384-1)];

%得到滤波器的单位脉冲响应hn就是滤波器的频率响应
hnConsec = filter(DiscreteNum,DiscreteDen,deltan);
n = (1:16384);

% 直接抽取，相当ADC采样,但是不包括抗混叠
% hnDiscre = M*hnConsec(floor(M*n));

%使用重采样函数，包括抗混叠
hnDiscre = M*resample(hnConsec,fs,f_osc);

%离散化后的滤波器系数
figure;
plot(hnDiscre);
title('单位冲击序列');
figure;
stem(abs(fft(hnDiscre)));
title('单位脉冲频率响应');


%% 当测试信号为正弦信号时

%信号源生成一个1k-50k(step:200)的正弦信号
f_signal = 1e3 ;
t = 0:1/f_osc:(16384-1)/fs;%100M示波器采样20个周期
signal = 1*sin(2*pi*f_signal*t)+0.5*sin(2*pi*f_signal*2*t+pi/3)+...
0.3*sin(2*pi*f_signal*3*t)+0.3*sin(2*pi*f_signal*10*t+pi/4);%正弦波信号

%信号源生成一个1k-50k(step:200)的方波信号
%signal = square(2*pi*f_signal*t)+1;


%ADC采样正弦信号
ts = 0:1/fs:(16384-1)/fs;%1.6384M ADC采样16384点
ADCsignal = 1*sin(2*pi*f_signal*ts)+0.5*sin(2*pi*f_signal*2*ts+pi/3)+...
    0.3*sin(2*pi*f_signal*3*ts)+0.3*sin(2*pi*f_signal*10*ts+pi/4);
%ADCsignal = square(2*pi*f_signal*ts)+1;



% 注入信号发生器信号检验离散系统
OutFilterSignal = filter(DiscreteNum,DiscreteDen,signal);

% 处理器需要做的
N = length(ADCsignal)+length(hnDiscre)-1;
ADCsignal_fft = fft(ADCsignal,N);
hn_fft = fft(hnDiscre,N);
OutDACSignal_fft = ADCsignal_fft .* hn_fft;
OutDACSignal = ifft(OutDACSignal_fft);


%零阶保持DAC输出
OutDACSignal_zoh = interp1(ts, OutDACSignal(1:16384),t, 'previous', 'extrap');

figure;
plot(OutFilterSignal);
hold on;
plot(OutDACSignal_zoh);
legend('模拟滤波器输出','离散系统重建输出');



