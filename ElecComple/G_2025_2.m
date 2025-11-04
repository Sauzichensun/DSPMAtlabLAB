clc;
close;

%%
f_osc = 100e6;
num = 3.94784176043574e9;
den = [1,8.8857534006821e4,3.94784176043574e9];

sys_filter = tf(num,den);
%从模拟滤波器转为离散滤波器

SysDiscrete = c2d(sys_filter,1/f_osc,'tustin');
%离散化后的滤波器系数
[DiscreteNum,DiscreteDen] = tfdata(SysDiscrete,'v');

%% 基于扫频信号，幅频相频特性的重建方法
f_dac = 1e6;
f_start = 1e3;
f_end = 500e3;
step = 200;
mag = zeros(1,(f_end-f_start)/step+1);
phase = zeros(1,(f_end-f_start)/step+1);

% 扫频得到相频和幅频特征
k = 1;
for f_signal=f_start:200:f_end
OutDacSignal = DACOut(f_signal,2,1e6);
AfterFilter = filter(DiscreteNum,DiscreteDen,OutDacSignal);
N = length(AfterFilter);
AnaFilterSignal = AfterFilter;
n = 1:16384;
f_adc = 1.6384e6;
M = f_osc/f_adc;
ADCFilterSignal = AnaFilterSignal(floor(M*n));
fftAnalysis = fft(ADCFilterSignal);
[maxvalue,idx] = max(abs(fftAnalysis));
mag(k) = maxvalue*2/length(fftAnalysis);
fftAngleSpec = angle(fft(ADCFilterSignal));
phase(k) = fftAngleSpec(idx);
k=k+1;
end

x = 1:length(mag);
axisx = (x-1)*200+1e3;
figure;
stem(axisx,mag);
title('滤波器幅频响应');
figure;
stem(axisx,phase);
title('滤波器相位响应');

f_signal = 1e3 ;
t = 0:1/f_osc:(1638400-1)/f_osc;%100M示波器采样20个周期
%模拟信号
RandomSignal = 1*sin(2*pi*f_signal*t)+0.5*sin(2*pi*f_signal*2*t+pi/3)+...
0.3*sin(2*pi*f_signal*3*t)+0.3*sin(2*pi*f_signal*10*t+pi/4);%正弦波信号

%ADC采样信号
ts = 0:1/f_adc:(16384-1)/f_adc;%1.6384M ADC采样16384点
ADCsignal = 1*sin(2*pi*f_signal*ts)+0.5*sin(2*pi*f_signal*2*ts+pi/3)+...
    0.3*sin(2*pi*f_signal*3*ts)+0.3*sin(2*pi*f_signal*10*ts+pi/4);

fftAnalyzieRandomSignal = fft(ADCsignal);
%通过阈值的方法找有效频率分量
thred = 0.001;
MagRandom = abs(fftAnalyzieRandomSignal)*2/16384;
PhaseRanom = angle(fftAnalyzieRandomSignal);
figure;
stem(MagRandom);
title('输入信号幅度谱');
figure;
stem(PhaseRanom);
title('输入信号相位谱');

ValidFre = zeros(1,100);
ValidMag = zeros(1,100);%分量实际幅度乘上滤波器对改频率成分的衰减
ValidPha = zeros(1,100);%分量实际相位加上经过滤波器后的相移


k=1;
for i=1:length(MagRandom)/2
if MagRandom(i)>thred
    ValidFre(k) = (i-1)*f_adc/length(MagRandom);
    FilterfftIdx = (ValidFre(k)-1e3)/200+1;
    ValidMag(k) = MagRandom(i)*mag(FilterfftIdx);
    ValidPha(k) = PhaseRanom(i)+pi/2+phase(FilterfftIdx)+pi/2;%相较于cos的相移
    k = k+1;
end
end

figure;
stem(ValidMag);
title('输入信号有效幅度');
figure;
stem(ValidPha);
title('输入信号有效相位');
figure;
stem(ValidFre);
title('输入信号有效频率');

t = 0:1/f_dac:(16384-1)/f_dac;
FianlOutSignal = ValidMag(1)*sin(2*pi*ValidFre(1)*t+ValidPha(1));
k = 2;
while ValidFre(k)~=0
    FianlOutSignal = FianlOutSignal +ValidMag(k)*sin(2*pi*ValidFre(k)*t+ValidPha(k));
k = k +1;
end    

L = f_osc / f_dac;
DACFianlOutSignal = kron(FianlOutSignal,ones(1,L));
idealOut = filter(DiscreteNum,DiscreteDen,RandomSignal);
figure;
plot(DACFianlOutSignal);
hold on;
plot(idealOut);
hold off;
legend('DAC','ideal');
title('输出对比');

