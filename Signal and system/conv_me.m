%一维卷积
p = [1,2,3,4,5];
q = [1,2,3,4,5,6];
res = conv(p,q);

maxLen = max(length(q),length(p));
minLen = min(length(q),length(p));

res2 = zeros(1,maxLen+minLen-1);

%matlab从1开始索引，信号需要移位，从结果层面想的
% for c = 0:maxLen+minLen-2
%     for k = 0:minLen-1
%         if c-k>=0 && c-k<=maxLen-1
%             res2(c+1) = res2(c+1)+p(k+1)*q(c-k+1);
%         end
%     end
% end

A = randi([1,10],1,10000);
B = randi([1,10],1,10000);

function C = ConvMe(A,B)
    C = zeros(1,length(A)+length(B)-1);
    %从本质上讲，卷积就是对输入序列进行操作
    for k = 1:length(A)
        C = C + [zeros(1,k-1),A(k)*B,zeros(1,length(A)-k)];
    end
end

timeconv_me = toc;%卷积时间
tic;
res3 = conv(A,B);
timeconv = toc;
