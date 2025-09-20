%对多采样速率改变中抽样后的信号恢复Xl
%以N=3对信号内插
clc;
function X_new=Inter(XOri,M)
N = length(XOri);
X_new = zeros(M*N,1);
origin_point = 1:M:M*N;
X_new(origin_point) = XOri;
end

function XEjwLimit = LimieBand(omiga,XEjw)
N = length(XEjw);
PassFilter = zeros(N,1);
PassFilter(1:floor(omiga*N/2/pi)) = 1;
PassFilter(floor(N-omiga*N/2/pi):N) = 1;
XEjwLimit = PassFilter .* XEjw;
end

XLM = Inter(Xl,3);
XLMEjw = fft(XLM);
%限制频带
X_BandLmit = LimieBand(pi/3,XLMEjw);

%绘制频谱
figure;
subplot(4,1,1);
PlotSpectrum(fft(Xl),"原信号频谱");
legend("原信号频谱");

subplot(4,1,2);
PlotSpectrum(XLMEjw,"上采样频谱");
legend("上采样频谱");

subplot(4,1,3);
PlotSpectrum(X_BandLmit,"限制频带后频谱");
legend("限制频带后的频谱");

%构建实际滤波器（FIR/IIR）


