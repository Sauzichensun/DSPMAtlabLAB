function MagToFre = ScanFre(f_start,f_end)
%SCANFRE 此处显示有关此函数的摘要
% 扫频函数,对滤波器进行扫频
% f_start-起始扫描频率，f_end-终止扫描频率
% 扫描模型为AnaLPF
%   此处显示详细说明
DACFs = 1e6;
N = 10000;%确保有足够的周期达到稳态
MagToFre = zeros(1,(f_end-f_start)/100);
i=1;
for f=f_start:100:f_end
    t = 0:1/DACFs:(N-1)/DACFs;
    signal = 1*sin(2*pi*f*t);
    Dsignal(1:N) = signal;
    OutFilter = AnaLPF(Dsignal,DACFs);
    MagToFre(i) = max(abs(OutFilter(5000:end)))/1;
    i = i +1;
end

