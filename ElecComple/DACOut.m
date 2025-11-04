% 由于Blinear的Td=100M,所以需要对输出频率为1M的DAC进行生采样，可以使用0阶，实际dac内部也是采用这种方式
%定义一个DAC模块(16384点-1M，通过0阶到100M) 带双极性
function DACSignal = DACOut(f,peak,f_dac)
f_osc=100e6;
t = 0:1/f_dac:(16384-1)/f_dac;     
DAC1M = (peak/2)*sin(2*pi*f*t);
%升采样，0阶保持插值法
L = f_osc / f_dac;

DACSignal = kron(DAC1M,ones(1,L));
end