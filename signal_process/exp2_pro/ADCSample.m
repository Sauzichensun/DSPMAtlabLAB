function ADCSquence = ADCSample(Fs,N)
%ADCSAMPLE 此处显示有关此函数的摘要
%模拟单片机ADC采样
%FS-采样率 N-采样点数 ContinusSiganl-待采样信号 
%为避免输入序列对模拟信号表示的精度不够，产生DownSampling误差,函数内定义菜昂函数
%   此处显示详细说明
f = 1e3;
t = 0:1/Fs:(N-1)/Fs;
signalC = 1*sin(2*pi*f*t);
ADCSquence = signalC;

end

