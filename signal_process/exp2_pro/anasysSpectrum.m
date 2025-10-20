%1.fft最多2048不然单片机不够
%2.采样率要够，这里最低频率为1e3，1e6的采样率一个周期1000个点，能采样两个周期，fft可以分析
%fft分析频谱
clc;
points = 2048;
fs = 204800;
f_main = zeros(1,(50e3-1e3)/200);
i = 1;
for f =1e3:200:50e3
signal_1 = ADCSample(f,fs,points);
sginal1_fft = fft(signal_1);
[~,f_main_indx] = max(sginal1_fft(1:points/2));%这里索引从一开始的
f_main(i) = fs*(f_main_indx-1)/points;
i = i+1;
end

% FFT不行因为没有系统的相位信息
%分频率衰减
%单一信号测试

injectSignal_1 = ADCSample(1e3,fs,2048);
injectSignal_2 = ADCSample(3e3,fs,2048);
injectSignal = injectSignal_1 + injectSignal_2;
fft_signal = abs(fft(injectSignal));
fft_signal_phase = angle(fft(injectSignal));

sginal2_fft = fft_signal;
for f = 1e3:100:50e3
fft_index = (f*points/fs)+1;
gain_index = (f-1e3)/100+1;
sginal2_fft(fft_index) = sginal2_fft(fft_index)*gain(gain_index);
sginal2_fft(2048-fft_index+1+1) = sginal2_fft(fft_index);
fprintf("fft_value = %f f = %d  gain = %f\n",sginal2_fft(fft_index),f,gain(gain_index));
end
fft_new_signal = sginal2_fft .* exp(1j*fft_signal_phase);
DACSignal = real(ifft(fft_new_signal));

