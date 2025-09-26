function Y = ADD_FFT(X)
%ADD_FFT 此处显示有关此函数的摘要
%同址计算FFT
%   此处显示详细说明
N = length(X);
k = 1;
while 2^k<N
    k = k +1;
end
X_New = [X zeros(2^k - N)];%补零操作
N = 2 ^ k;
bitWidth = log2(N);
idx = 0 : N-1;
idx_new = bitrevorder(idx)+1;
X_New = X_New(idx_new);%排序后的序列
halfsize = 1;
Y = X_New;
while halfsize<=N
    step = 2 * halfsize;
    W = exp((-1j*2*pi/N)*(0:1:step-1)); 
    for n=1:step:N
        idx1 = n:1:n+halfsize-1;
        idx2 = n+halfsize:1:n+step-1;
        a = Y(idx1);
        b = Y(idx2);
        Y(idx1) = a + W.*b;
        Y(idx2) = a - W.*b;
    end
    halfsize = 2 * halfsize;

end

