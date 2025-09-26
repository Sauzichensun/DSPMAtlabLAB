clear;
clc;
%快速傅里叶变换
function Y = FFTNew(X)
%长度为2直接计算    
N = length(X);
if N==2
    Y = zeros(1,N);
    Y(1) = X(1)+X(2);
    Y(2) = X(1)-X(2);
    return;
else
    k=1;
    while 2^k<N
        k = k+1;
    end
    M = [X zeros(1,2^k-N)];%补零操作
    N = 2^k;
    X_even = M(1:2:end);%偶数项序列
    X_odd = M(2:2:end);%奇数项序列
    Y_even = FFTNew(X_even);
    Y_odd = FFTNew(X_odd);
    
    W = exp((-1j*2*pi/N)*(0:1:N/2-1));
    Y = zeros(1,N);

    Y(1:N/2) = Y_even + Y_odd.*W;
    Y(N/2+1:N) = Y_even - Y_odd.*W;    
end
end

%DFT
function Y = DFTNew(X)
N = length(X);
Y = zeros(1,N);
for i=1:N
    temp_sum=0;
    for k=1:N
        temp_sum = temp_sum + X(k)*exp(-1j*2*pi/N*(i-1)*(k-1));
    Y(i)=temp_sum;
    end
end
end

%非迭代FFT
function Y = FFT_iter(X)
N = length(X)
nbits = log2(N);
idx = 0:N-1;
rev = bitrevorder(idx+1);
X = X(rev);%前N/2为偶数项序列，后半部分为奇数项序列
Y = X;
%蝶形运算
halfSize = 1;
while halfSize<N
    step = 2*halfSize;
    W = exp(-1j*2*pi/(step)*(0:halfSize-1));

    for n=1:step:N
        idx1 = n:(n+halfSize-1);
        idx2 = n+halfSize : (n+step-1);  % 后半部分
        a = Y(idx1);
        b = Y(idx2);
        t = W .* b;
        Y(idx1) = a+t;
        Y(idx2) = a-t;
    end
    halfSize = step;
end
end

X = randi([1,20],[1,2^12]);
%我的fft
tic;
Y_FFTNEW = FFT_iter(X);
time_FFTiter = toc();
tic;
Y_DITFFT = FFTNew(X);
time_FFTDIT = toc();
%matlab fft
tic;
res_stan = fft(X);
time_fft =toc();

