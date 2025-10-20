%系统辨识
%滤波器类型辨别
clc;
[max_value,max_index] = max(gain);
[min_value,min_index] = min(gain);
Epsilion_factor = 0.3;%绝对阈值，可以考虑采用相对阈值的方法
degradation=0;
enhance = 0;
i=0;
if(gain(1)*Epsilion_factor>min_value)
fprintf("LPF 或者 BSF\n");
end
if(gain(1)*Epsilion_factor<min_value)
    fprintf("HPF 或者 BSP\n");
    i=1;
end
%具体判断低通还是带通
bsp = 0;
if(i==0)
for x = min_index:length(gain)
if(gain(x)*Epsilion_factor>min_value)
    bsp = 1;
end
end
if(bsp)
    fprintf("BSP");
else
    fprintf("LPF");
end
end

%具体判断高通还是带通
bpf=0;
if(i==1)
for x = max_index:length(gain)
if(gain(x)<Epsilion_factor*max_value)
    bpf = 1;
end
end
if(bpf)
    fprintf("BPF");
else
    fprintf("HPF");
end
end


function judgeFilter(sys, f_start, f_end, N)
% 自动判定滤波器类型（包含扫描不足检测）
% sys     : MATLAB传递函数 tf 对象（连续或离散）
% f_start : 扫频起始频率(Hz)
% f_end   : 扫频结束频率(Hz)
% N       : 扫频点数

    % -------- 扫频幅相特性 --------
    f = logspace(log10(f_start), log10(f_end), N); % 对数间隔扫频
    [mag, phase] = bode(sys, 2*pi*f);
    mag = squeeze(mag);
    phase = squeeze(phase);
    
    low_gain = mag(1);
    high_gain = mag(end);
    diff_db = 20*log10(high_gain/low_gain);

    % 检查中间是否有峰谷
    [pks, ~] = findpeaks(mag);
    [vals, ~] = findpeaks(-mag);

    % -------- 基于幅频 + 相频的初步判断 --------
    if ~isempty(pks) && max(pks) > max([low_gain, high_gain]) * 1.05
        type_basic = 'Band-pass';
    elseif ~isempty(vals) && max(-vals) < min([low_gain, high_gain]) * 0.95
        type_basic = 'Band-stop';
    elseif diff_db < 1 && abs(max(phase) - min(phase)) > 30
        type_basic = 'All-pass';
    elseif diff_db < 1
        type_basic = 'Flat/Unknown';
    elseif diff_db <= -3
        type_basic = 'Low-pass';
    elseif diff_db >= 3
        type_basic = 'High-pass';
    else
        type_basic = 'Unknown';
    end

    % 扫描不足判定：
    scan_warning = false;
    if strcmp(type_basic, 'Flat/Unknown')
        scan_warning = true;
    end

    % -------- 时域辅助分析 --------
    fs_time = 10 * f_end;         % 时域仿真采样频率
    t = 0:1/fs_time:0.05;         % 仿真时间
    % 阶跃响应
    step_resp = lsim(sys, ones(size(t)), t);
    % 脉冲响应
    impulse_signal = zeros(size(t));
    impulse_signal(1) = 1;
    impulse_resp = lsim(sys, impulse_signal, t);

    % 阶跃 & 脉冲特征
    step_slope = step_resp(2) - step_resp(1); % 初始速度
    impulse_peak = max(abs(impulse_resp));

    % -------- 再次修正判断 --------
    type_final = type_basic;
    if scan_warning
        % 如果阶跃很平滑且没有尖峰 → 低通
        if impulse_peak < 5 * mean(abs(impulse_resp))
            type_final = 'Likely Low-pass (but scan range too low)';
        else
            type_final = 'Likely High-pass (but scan range too low)';
        end
    end

    % -------- 输出结果 --------
    fprintf('初步幅频判定: %s\n', type_basic);
    if scan_warning
        fprintf('⚠️ 扫描范围可能不足，结果不可靠\n');
    end
    fprintf('综合判定: %s\n', type_final);

    % -------- 绘制幅频特性 --------
    figure('Name','幅频特性');
    semilogx(f, mag, 'LineWidth', 1.5);
    xlabel('频率 (Hz)');
    ylabel('线性幅值');
    grid on;
    title('幅频特性');

    % -------- 绘制相频特性 --------
    figure('Name','相频特性');
    semilogx(f, phase, 'LineWidth', 1.5);
    xlabel('频率 (Hz)');
    ylabel('相位 (度)');
    grid on;
    title('相频特性');

    % -------- 绘制阶跃 & 脉冲响应 --------
    figure('Name','时域响应');
    subplot(2,1,1);
    plot(t, step_resp, 'b', 'LineWidth', 1.2);
    xlabel('时间(s)');
    ylabel('幅值');
    title('阶跃响应');
    grid on;

    subplot(2,1,2);
    plot(t, impulse_resp, 'r', 'LineWidth', 1.2);
    xlabel('时间(s)');
    ylabel('幅值');
    title('脉冲响应');
    grid on;
end
judgeFilter();

%