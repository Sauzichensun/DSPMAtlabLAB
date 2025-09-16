%傅里叶变换编程
clear;
clc;

%创建时间轴
% t = linspace(-1,4,1000);
t = seconds(-1:0.01:4);
x_t = zeros(size(t));
x_t(t>=0 & t<=2)=1;
figure;
plot(t,x_t,"LineWidth",2);
