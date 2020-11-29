
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%Author=[0x4b,0x57,0x48]%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;
%A=3.5;
f=2000;
fs=8*10^3;
T=1/fs;
w=2*pi*f;
t=0:0.00000001:0.008;
y=3.5*sin(w*t);% 语音信号
figure(1);
plot(t,y);
legend('原始语音信号');

n=1:200;% 抽样的个数0
fs=8*10^3;
T=1/fs;
Y(n)=1;%抽样脉冲幅值为1
figure(2)
stem(n,Y(n));
axis([0 50 0 1]);
xlabel('n');
ylabel(' 幅度 ');
legend(' 抽样脉冲信号 ');

n=1:100;
fs=8*10^3;
T=1/fs;
w=2*pi*f;
s=3.5*sin(w*n*T);
figure(3)
stem(n,s);% 时域抽样后的信号图
axis([0 100 -4 4]);
xlabel('n');
ylabel(' 幅度 ');
legend(' 时域抽样信号图 ');

f=n./(100*T);
y1=abs(fft(s));
figure(4)
plot(f,y1);
xlabel('f');
ylabel(' 幅频 ');
legend(' 抽样信号频谱 ');

%%%%
s1=s./max(s);% 归一化
s2=s1./(1/2048);


for i=1:100 %c 是 pcm码100*8
    y=s2(i);
    u=[0 0 0 0 0 0 0 0 ];
    if(y>0)% 极值码判断
        u(1)=1;
    else
        u(1)=0;
    end
    y=abs(y);
    if(y>=0&&y<16)% 段落码判断
        u(2)=0;
        u(3)=0;
        u(4)=0;
        step=1;
        st=0;
    elseif(y>=16&&y<32)
        u(2)=0;
        u(3)=0;
        u(4)=1;
        step=1;
        st=16;
    elseif(y>=32&&y<64)
        u(2)=0;
        u(3)=1;
        u(4)=0;
        step=2;
        st=32;
    elseif(y>=64&&y<128)
        u(2)=0;
        u(3)=1;
        u(4)=1;
        step=4;
        st=64;
    elseif(y>=128&&y<256)
        u(2)=1;
        u(3)=0;
        u(4)=0;
        step=8;
        st=128;
    elseif(y>=256&&y<512)
        u(2)=1;
        u(3)=0;
        u(4)=1;
        step=16;
        st=256;
    elseif(y>=512&&y<1024)
        u(2)=1;
        u(3)=1;
        u(4)=0;
        step=32;
        st=512;
    elseif(y>=1024&&y<=2048)
        u(2)=1;u(3)=1;
        u(4)=1;
        step=64;
        st=1024;
    end
    if(y<2048)% 段内码判断
        t=floor((y-st)/step);
        p=dec2bin(t,4)-48;
        u(5:8)=p(1:4);
    else
        u(5:8)=[1 1 1 1];
    end
    c(i,1:8)=u(1:8);
end

%%%%%%%%%%%%%%%%%%%%%%  pcm code%%%%%%%%%%%%%%%%%

m=c;%调制
m1=m.';
m1=reshape(m1,2,400);
m1=m1.';
m2=bi2de(m1,'left-msb');
m2(m2==0)=-1;
m2(m2==2)=-3;

c1=c.';
c7=c;
c1=reshape(c1,4,200);
c1=c1.';%c1=200*4, 前两行对应 c第一行
c2=encode(c1,7 ,4,'hamming/binary');%(7,4)hamming 信道编码 200*7
c3=encode(c7,15,8,'cyclic/binary');%(15,8) 循环码编码
tx1=c2;
tx1(tx1==0)=-1;
tx2=c3;
tx2(tx2==0)=-1;% 调制



figure(6);
stairs(tx1);
title('PCM 编码,(7,4)hamming');
axis([0 20 -0.1 1.1]);
xlabel('t(s)');
grid on;

errorbit=0;
dB=-25:5:25;
for q=1:11
    biterrors=0;
    biterrors1=0;
    biterrors2=0;
    r1=10.^(dB(q)/10);
    r1=0.5./(r1);
    sigma=sqrt(r1);% 标准差
    
    qq2=m2+sigma*randn(400,1);% 加噪声
    qq2((qq2>=0)&(qq2<2))=1;% 判决，解调
    qq2(qq2>=2)=3;
    qq2((qq2>=-2)&(qq2<0))=-1;
    qq2(qq2<-2)=-3;
    qq2(qq2==-3)=2;
    qq2(qq2==-1)=0;
    m3=de2bi(qq2,2,'left-msb');
    m3=m3.';
    m3=reshape(m3,8,100);
    m3=m3.';% 把m3变成 8行100列的矩阵
    errors=zeros(100,8);
    errors(m3~=c)=1;% 发现错误让 error 为1
    errors=reshape(errors,1,800);% 把矩阵变成 1行800列的矩阵
    biterrors=sum(errors);
    bit1(q)=biterrors/(100*8);
    rx1=tx1+sigma*randn(200,7);% 加噪声
    rx2=tx2+sigma*randn(100,15);% 加噪声
    rx1(rx1>=0)=1;
    rx1(rx1<0)=0;% 判决，解调
    rx2(rx2>=0)=1;
    rx2(rx2<0)=0;
    c22=decode(rx1,7,4,'hamming/binary');%hamming 信道译码 200*4
    c33=decode(rx2,15,8,'cyclic/binary');% 循环译码
    errors1=zeros(200,4);
    errors2=zeros(100,8);
    errors1(c22~=c1)=1;% 发现错误让其值为 1
    errors2(c33~=c7)=1;% 发现错误让其值为 1
    errors1=reshape(errors1,1,800); % 把矩阵变成 1行800列的矩阵
    errors2=reshape(errors2,1,800);% 把矩阵变成 1行800列的矩阵
    biterrors1=sum(errors1);% 统计错误
    biterrors2=sum(errors2);% 统计错误
    errorbit(q)=biterrors1/(100*8);
    errorbit2(q)=biterrors2/(100*8);% 误码率
end

figure(5)
semilogy(dB,errorbit,':ro');
hold
semilogy(dB,bit1,'--bs');
semilogy(dB,errorbit2,'-.g*');
grid;
legend(':ro 汉明 ','--bs 无信道编码 ','-.g* 循环码 ');
xlabel('dB');
ylabel(' 误码率 ')

figure(7)
f=2000;
fs=8*10^3;
T=1/fs;
w=2*pi*f;
t=0:0.00000001:0.008;
y=3.5*sin(w*t);% 语音信号
Signal_m=y;
subplot(2,1,1);
plot(t,Signal_m);
title('输入的原始信号');
grid;

%====================================================================
% >>>>>>>>>>>>>>>>>>>>>>PCM Encoding<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%====================================================================
Is = round(2048 * (Signal_m/10));	% Convert the data
Len = length(Is);			% Get the lenght of the Code vertor
Code = zeros(Len,8);
%---------------------------------The Polarity Code-----------------------------------
for i = 1:Len
	if(Is(i) > 0)
	Code(i,1) = 1;	
	end
end
%----------------------------------段落码----------------------------------
Signal = abs(Is);
for i = 1:Len
    sign_temp = Signal(i);
    for j = 0 : 7
        sign_temp = sign_temp / 2;
        if sign_temp < 8
            break;
        end
    end
    bin_temp = dec2bin(j,3);
    temp = num2str(bin_temp, 3);
  	Code(i,2) = bin2dec(temp(1));
	Code(i,3) = bin2dec(temp(2));
	Code(i,4) = bin2dec(temp(3));
end
% ---------------------------------段内码---------------------------------
Start_Level = [0,16,32,64,128,256,512,1024];				%段落起点电平
Quan_Interval = [1,1,2,4,8,16,32,64];					%段落量化间隔
ParagraphN = zeros(1,Len);
for i = 1:Len
	ParagraphN(i) = Code(i,2)*4 + Code(i,3)*2 + Code(i,4) + 1;	%确定在第几段,但这样是不行滴，中间会有问题
end

for i = 1:Len
	ZeltaLevel = Signal(i) - Start_Level(ParagraphN(i));		%减去其实电平之后的电压
	Cur_LHJG = Quan_Interval(ParagraphN(i));
	dec_temp = ZeltaLevel/Cur_LHJG;
	bin_temp = dec2bin(dec_temp,4);
	temp = num2str(bin_temp,4);
	Code(i,5) = bin2dec(temp(1));
	Code(i,6) = bin2dec(temp(2));
	Code(i,7) = bin2dec(temp(3));
	Code(i,8) = bin2dec(temp(4));
end
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>coding part<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Quan_Unit = zeros(1,Len);
Quan_Value = zeros(1,Len);
Mark = zeros(1,Len);
Signal_trans = zeros(1,Len);
for i = 1:Len
	ParagraphN(i) = Code(i,2)*4 + Code(i,3)*2 + Code(i,4) + 1;
	Quan_Unit(i) = Code(i,5)*8 + Code(i,6)*4 + Code(i,7)*2 + Code(i,8);
	Mark(i) = Start_Level(ParagraphN(i));
	Quan_Value(i) = Quan_Interval(ParagraphN(i));
	sign = 1;
	if(Code(i,1) == 0)
		sign = -1;
	end
	Signal_trans(i) = sign * (Mark(i) + Quan_Value(i) * Quan_Unit(i));
end
for i = 1:Len
	Signal_trans(i) = 10 * (Signal_trans(i)/2048);
end
subplot(2,1,2);
plot(t,Signal_trans);
title('PCM 还原后的信号');
grid;



