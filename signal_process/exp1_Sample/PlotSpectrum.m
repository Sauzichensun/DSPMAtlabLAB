function PlotSpectrum(Xejw,title_plot)
%PLOTSPECTRUM 此处显示有关此函数的摘要
%   此处显示详细说明
% Xejw 
%绘制频谱
N = length(Xejw);
t = (-N/2:N/2-1)*2*pi/N;
plot(t,abs(fftshift(Xejw)));
xlabel("频率")
ylabel("幅度");
title(title_plot);
grid on;
end

