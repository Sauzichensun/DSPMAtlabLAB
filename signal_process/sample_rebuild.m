%x(t)=0.3sin(2πt)+0.4cos(2.5πt+pi/4)+0.3cos(pi*t+pi/3)
%信号的采样与重建
%信号描述
%时间向量
t = -4:0.01:4;
signal = 0.3*sin(2*pi*t)+0.4*cos(2.5*pi*t+pi/4)+0.3*cos(pi*t+pi/3);

%绘制信号
figure;
plot(t,signal);
xlabel("Time(s)");
title("Origin Signal x(t)");
ylabel("Amplitude");


%Ts = 0.25采样
Ts = 0.25;
ts = -4:0.25:4;
sample_signal = 0.3*sin(2*pi*ts)+0.4*cos(2.5*pi*ts+pi/4)+0.3*cos(pi*ts+pi/3);
%绘制信号
hold on;
stem(ts,sample_signal);
xlabel("Time(s)");
title("Origin Signal x(t)");
ylabel("Amplitude");

%信号重建
x_re = zeros(1,801);

%执行插值运算
for i=1:801
for n=1:33
x_re(i) = x_re(i) + (sample_signal(n)*sin(pi*(t(i)-ts(n))/Ts))/(pi*(t(i)-ts(n))/Ts);
end
end

%绘制重建信号
plot(t,x_re);

%图例
legend("原始信号","采样信号","重建信号");

hold off;

%欠采样
Ts2 = 0.5;
ts2 = -4:0.5:4;
undersimple_signal = 0.3*sin(2*pi*ts2)+0.4*cos(2.5*pi*ts2+pi/4)+0.3*cos(pi*ts2+pi/3);
figure;
plot(t,signal);
xlabel("Time(s)");
title("Origin Signal x(t)");
ylabel("Amplitude");
hold on;
stem(ts2,undersimple_signal);

%重建信号
undersample_x_re = zeros(1,801);
for i=1:801
    for n=1:17
        undersample_x_re(i) = undersample_x_re(i) + undersimple_signal(n)*(sin(pi*(t(i)-ts2(n))/Ts2)/(pi*(t(i)-ts2(n))/Ts2));
    end
end

%绘制欠采样重建信号
plot(t,undersample_x_re);
legend("原始信号","采样序列值","欠采样重建信号");
hold off;