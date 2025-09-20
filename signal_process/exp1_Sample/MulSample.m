%对地低通滤波后的声音进行N=2的内插，即升采样
clc;
%读取声音数据
figrow = 4;
figclo = 1;
[X,Fs] = audioread("LPFVoice.wav");
%原始信号频谱
XEjw = abs(fft(X));

N = length(X);
%上采样内插器
M = 2;%定义增采样间隔
Xd = zeros(2*N,1);

interpoint = 1:M:M*N;
Xd(interpoint) = X; 

%内插后的频谱
Xd_Ejw = fft(Xd);

% %限制插值后的信号频带
% %创建滤波器
LowBandLimit = zeros(2*N,1);
LowBandLimit(1:floor(2*N/6)) = 2;
LowBandLimit(floor(10*N/6):2*N) = 2;
%抗镜像后的上采样频谱
Xd_BandEjw = LowBandLimit.*Xd_Ejw;

%抗镜像后恢复出的离散序列
Xd_Band = real(ifft(Xd_BandEjw));

%保存内插后的信号
audiowrite("UpSampleVoice.wav",Xd_Band,2*Fs);
% 
% %以M=3间隔进行下采样,即抽取
L = 3;%定义抽取间隔
Xl = zeros(floor(N*M/L),1);
ExtractPoint = 1:L:M*N;
Xl = Xd_Band(ExtractPoint);
XlEjw = fft(Xl);


%绘制频谱
figure;
subplot(4,1,1);
PlotSpectrum(fft(X),"原始频谱");
legend("原始频谱");

subplot(4,1,2);
PlotSpectrum(Xd_Ejw,"上采样频谱");
legend("上采样频谱");

subplot(4,1,3);
PlotSpectrum(Xd_BandEjw,"限制频带后的信号频谱");
legend("限制频带后的频谱");

subplot(4,1,4);
PlotSpectrum(XlEjw,"下采样频谱");
legend("下采样频谱");


figure;
subplot(3,1,1)
PlotXn(X);
legend("原始信号");

PlotXn(Xd);
legend("上采样信号");

PlotXn(Xd_Band);
legend("恢复后的内插信号");

