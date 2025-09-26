clear;clc;
%相位跟踪
%输入vi

f=50;           %Hz
w= 2*pi*f;      %输入角速度
T= 1/10e3;      %采样周期
vg = 6;         %输入电压最大值
Voffset =0.1;
phase=5*pi/2;   

t=0:T:0.5;

vi = zeros(size(t));
vi(1)=vg*sin(w*t(1)+phase);
vo = zeros(size(t));
vo(1)=0;

err_pd=0;%鉴相器输出信号
old_err_pd =0;%前一步鉴相器输出信号
v_err =0;%估计电压信号
elecTheta =0;%当前交流源角度输出
old_elecTheta =0;%前一个交流源角度输出
v_lowpass =0;%滤波器输出
old_v_lowpass =0;%前一个滤波器输出
wg =0;%估算角速度


pll_damping =0.707;%滤波器阻尼
pll_wn = 2*pi*15;%滤波器带宽
pll_kp =2*pll_damping*pll_wn/vg;
pll_Ti =pll_damping/pll_wn;

for i = 2:numel(t)
    %增加的扰动
    if i==2.5e3
        phase = 7*pi/2;
    end
    
    %输入信号
    vi(i)= vg*cos(w*t(i)+ phase);
    
    %估计的电压信号
    v_err = cos(elecTheta);
    
    %鉴相器计算
    err_pd = vi(i)*v_err;
    
    %低通滤波器计算
    v_lowpass = old_v_lowpass + (pll_kp+pll_kp*T/pll_Ti)*err_pd - pll_kp*old_err_pd;
    old_err_pd = err_pd;
    old_v_lowpass = v_lowpass;
    
    %加入前馈补偿
    wg = v_lowpass + w;
    
    %积分
    elecTheta = old_elecTheta + T*wg;
    old_elecTheta = elecTheta;
    
    %输出
    vo(i) = vg*sin(elecTheta) +Voffset;
    
end

subplot(1,1,1);
plot(t,vi,'b',t,vo,'r');


