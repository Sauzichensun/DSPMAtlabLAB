clc;
%语音信号处理
%voice语音信号

%加载语音信号
%x为离散信号向量 fs为采样率
[x,Fs] = audioread('voice.wav');%x为二维向量分为左声道和右声道
voiceLeft = x(:,1);
voiceRight = x(:,2);
N = length(voiceRight);
%计算频谱
Xejw = fft(voiceRight);
XejwAmp = abs(Xejw);
%频率绘制
fs = 0:2*pi/(N-1):2*pi;%归一化角频率轴
f = (0:N-1)*(Fs/N);%连续频率轴
figure;
plot(f,XejwAmp);
legend("连续轴频谱");
%由于FFT的对对称性，所以修改刻度,绘制单边谱
xlim([0,Fs/2]);


%处理音频信号
%创建理想低通滤波器，截止频率为2*pi/3
LowpassHz = zeros(N,1);
LowpassHz(floor(1:(N-1)*1/6))=1;%确保索引是整数
LowpassHz(end-length(floor(1:(N-1)*1/6))+1:end)=1;

LowPassXejw = LowpassHz.*Xejw;%不仅包括幅度信息还要有相位信息
LowPassVoice = real(ifft(LowPassXejw));

%保存低通滤波器处理后的信号
audiowrite("exp1_Sample/LPFVoice.wav",LowPassVoice,Fs);



