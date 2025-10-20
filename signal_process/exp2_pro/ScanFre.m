function [MagToFre,PhaseToFre] = ScanFre(f_start,f_end)
%SCANFRE 此处显示有关此函数的摘要
% 扫频函数,对滤波器进行扫频
% f_start-起始扫描频率，f_end-终止扫描频率
% 扫描模型为AnaLPF
%   此处显示详细说明
DACFs = 204800;
NPoints = floor((f_end-f_start)/100);
MagToFre = zeros(NPoints,1);
PhaseToFre = zeros(NPoints,1);
i=1;
for f=f_start:100:f_end
    t = 0:1/DACFs:100/f;%100个周期，确保足够时间达到稳态
    signal = 1*sin(2*pi*f*t);
    OutFilter = AnaLPF(signal,DACFs);
    MagToFre(i) = max(abs(OutFilter(floor(length(OutFilter)/2):end)))/1;
    
    i = i +1;
end

