%按时间抽取FFT
function Y = DIT_FFT(X)
N = length(X);
if N==2
    Y = zeros(2,1);
    Y(1) = X(1) + X(2);
    Y(2) = X(1) - X(2);
    return;
end
%补零操作
k = 1;
while 2^k<N
    k = k + 1;
end
X_New = [X zeros(2^k-N,1)];
%序列长度更新
N = 2^k;
%分奇偶序列递归计算
Xodd = X_New(2:2:end);
XEven = X_New(1:2:end);
Y = zeros(N,1);
Yeven = DIT_FFT(XEven);
Yodd = DIT_FFT(Xodd);

W = exp((-1j*2*pi/N)*(0:1:N/2-1));
Y(1:1:N/2) = Yeven + Yodd .* W';
Y(N/2+1:end) = Yeven - Yodd .* W';

end
