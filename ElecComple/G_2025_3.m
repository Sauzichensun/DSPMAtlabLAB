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


