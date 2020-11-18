clear;
clc;
T=0.0005;
t=-0.01:T:0.01;
fs=2000;
sdt=1/fs;
t1=-0.01:sdt:0.01;
xt=cos(2*pi*30*t)+sin(2*pi*120*t);
st=cos(2*pi*30*t1)+sin(2*pi*120*t1);
max = max(abs(st));

% 原始信号
figure;
subplot(2,1,1);plot(t,xt);title('原始信号');
grid on;
subplot(2,1,2);stem(t1,st,'.');title('抽样信号');
grid on;
% PCM 编码
pcm_encode = PCMcoding(xt);

figure;
stairs(pcm_encode);
axis([0 20 -0.1 1.1]);
title('PCM 编码');
grid on;

% PCM 译码
pcm_decode = PCMdecoding(pcm_encode, max);

figure;
subplot(2,1,1);plot(t, pcm_decode);
title('PCM 译码');grid on;

subplot(2,1,2);plot(t,xt);
title('原始信号');grid on;

% 计算失真度
da=0; 
for i=1:length(t)
    dc=(st(i)-pcm_decode(i))^2/length(t);
    da=da+dc;
end
fprintf('失真度是：%.6f\n',da);














