function output = my_xcorr2d(A, B)
% MY_XCORR2D 手动实现二维互相关操作，与 conv2 行为完全一致。
%   output = my_xcorr2d(A, B)
%   函数根据输入矩阵的尺寸自动识别图像和卷积核，并执行全模式互相关。

% 获取两个输入矩阵的尺寸
[rows_A, cols_A] = size(A);
[rows_B, cols_B] = size(B);

% 自动识别哪个是图像，哪个是卷积核。
% 约定俗成：尺寸较小的矩阵作为卷积核。
if (rows_A * cols_A) < (rows_B * cols_B)
    image = B;
    kernel = A;
else
    image = A;
    kernel = B;
end

% 获取图像和卷积核的尺寸
[image_rows, image_cols] = size(image);
[kernel_rows, kernel_cols] = size(kernel);

%卷积核反转
kernel_flip = zeros(kernel_rows,kernel_cols);
for i=1:kernel_rows
    for j=1:kernel_cols
        kernel_flip(i,j) = kernel(kernel_rows-i+1,kernel_cols-j+1);
    end
end

% --- 核心互相关计算 ---

% 1. 计算输出矩阵的尺寸（全模式）
output_rows = image_rows + kernel_rows - 1;
output_cols = image_cols + kernel_cols - 1;
output = zeros(output_rows, output_cols);

% 2. 遍历输出矩阵的每一个像素
for i = 1:output_rows
    for j = 1:output_cols
        current_sum = 0;
        
        % 3. 遍历卷积核的每一个元素
        for k = 1:kernel_rows
            for l = 1:kernel_cols
                % 计算在图像中的对应位置，注意这里没有反转
                image_row_idx = i-kernel_rows+1+k-1;
                image_col_idx = j-kernel_cols+1+l-1;

                % 4. 检查索引是否在图像的有效范围内
                if image_row_idx >= 1 && image_row_idx <= image_rows && ...
                   image_col_idx >= 1 && image_col_idx <= image_cols
                    image_element = image(image_row_idx, image_col_idx);
                    kernel_element = kernel_flip(k, l); % 直接使用原始 kernel
                    current_sum = current_sum + image_element * kernel_element;
                end
            end
        end
        % 5. 将累加结果赋值给输出矩阵
        output(i, j) = current_sum;
    end
end

end

% 你的测试矩阵
A = [1, 2, 3; 4, 5, 6]; % 2x3
B = [1, 2, 3, 4, 5, 6;
     9, 4, 7, 8, 9, 1;
     1, 5, 8, 4, 6, 9]; % 3x6

% 使用内置 conv2 函数，默认执行全模式互相关
C_conv2 = conv2(A, B);

% 使用我们手动实现的函数
% M_xcorr = my_xcorr2d(A, B);
% 
% disp('conv2(B, A) 的结果:');
% disp(C_conv2);
% disp('--------------------------------');
% disp('my_xcorr2d(A, B) 的结果:');
% disp(M_xcorr);
% disp('--------------------------------');
% disp('两个结果是否完全相等？');
% disp(isequal(C_conv2, M_xcorr));

A = double(imread("Lenna.bmp"));
kernelB = [1/9,1/9,1/9;
    1/9,1/9,1/9;
    1/9,1/9,1/9;];

kernelC = [-1/9,-1/9,-1/9;
    -1/9,8/9,-1/9;
    -1/9,-1/9,-1/9;];

image2 = conv2(A,kernelC);
image2 = rescale(image2,0,255);
imwrite(uint8(image2),"LennaConv.bmp")

%逆卷积函数
X = randi([1,20],3,4);
Y = randi([1,20],5,7);
H = deconv(X,Y);