clc;
clear;

%=============================================================
% 读取声音数据
[X, Fs] = audioread("LPFVoice.wav");
N = length(X);

%=============================================================
% 升采样（插零法）
M = 2; % 升采样因子
Xd = zeros(M*N, 1);
interpoint = 1:M:M*N;
Xd(interpoint) = X;

%=============================================================
% 绘制原始信号的频谱
figure;
PlotSpectrumNorm(X, '原始频谱（归一化频率）');

%=============================================================
% 升采样后频谱
Xd_Ejw = fft(Xd);
hold on;
PlotSpectrumNorm(Xd, '插值后的频谱');

%=============================================================
% 频域低通滤波器设计（保留低频部分）
cut_index = floor(N/2); % 原始带宽对应的点数
LowBandLimit = zeros(M*N, 1);

% 保留从DC到cut_index的低频
LowBandLimit(1:cut_index) = M; 
% 保留对称高频
LowBandLimit(end-cut_index+2:end) = M;

% 应用频域滤波
Xd_Band_spec = fft(Xd) .* LowBandLimit;

%=============================================================
% 绘制限制频带信号的频谱
PlotSpectrumNorm(ifftshift(Xd_Band_spec), '限制频带后的频谱');
legend("原始频谱","插值后频谱","限制频带后的频谱");

%=============================================================
% IFFT 得到时域信号
Xd_Band = real(ifft(Xd_Band_spec));

figure;
PlotXn(Xd, '升采样插零信号（时域）');
hold on;
PlotXn(Xd_Band, '带限后的时域信号');

%=============================================================
% 降采样
L = 3; % 降采样因子
% 计算降采样后长度
new_len = floor(length(Xd_Band) / L);
% 等间隔取样
ExtractPoint = 1:L:(L*new_len);
Xl = Xd_Band(ExtractPoint);

%=============================================================
% 绘制抽取后信号的时域
figure;
PlotXn(Xl, '降采样后信号（时域）');

%=============================================================
% 绘制抽取后频谱
figure;
PlotSpectrumNorm(Xl, '降采样后信号的频谱');

%=============================================================
% ==== 自定义绘图函数 ====
function PlotSpectrumNorm(x, titleName)
    N = length(x);
    Xf = fftshift(fft(x));
    mag = abs(Xf) / N; % 幅值归一化
    f = linspace(-0.5, 0.5, N); % 归一化频率轴
    plot(f, mag, 'LineWidth', 1.2);
    xlabel('归一化频率 (\times \pi rad/sample)');
    ylabel('幅度');
    xticks([-0.5 -0.25 0 0.25 0.5]);
    xticklabels({'-\pi','-π/2','0','π/2','\pi'});
    grid on;
    title(titleName);
end

function PlotXn(x, titleName)
    plot(0:length(x)-1, x, 'LineWidth', 1.2);
    xlabel('样点');
    ylabel('幅值');
    title(titleName);
    grid on;
end
