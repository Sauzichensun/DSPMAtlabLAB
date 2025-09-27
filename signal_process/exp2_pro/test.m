clc;
f = 1e3;
%模拟单片机采样
fs = 1e6;
Samplepoints = 100000;
ADCSampleSquency = ADCSample(fs,Samplepoints);
plot((0:Samplepoints-1),ADCSampleSquency);
%设置y轴刻度范围
ylim([-2,2]);
grid on;
gain = ScanFre(1e3,50e3);
out = AnaLPF(ADCSampleSquency,1e6);
