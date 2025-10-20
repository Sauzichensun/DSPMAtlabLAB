% 分析扫频得到的增益gain和实际增益mag
figure;
f_start = 1e3;
f_end = 50e3;
step = 100;
x = f_start:step:f_end;

% 绘制原始增益曲线
subplot(2,1,1);  % 创建2行1列的子图，当前为第1个
plot(x, gain);
hold on;
plot(x, mag);
legend("ActualGain", "TheoreticalGain");
grid on;
title("增益对比图");
xlabel("频率 (Hz)");
ylabel("增益");

% 计算残差 (实际值 - 理论值)
residual = gain - mag;

% 绘制残差图
subplot(2,1,2);  % 当前为第2个子图
plot(x, residual, 'r');  % 用红色曲线绘制残差
grid on;
title("残差图 (ActualGain - TheoreticalGain)");
xlabel("频率 (Hz)");
ylabel("残差");

% 调整子图布局
sgtitle("增益分析与残差可视化");  % 总标题
