clear all;
i=16;
j=8000;
t=linspace(0,8,j);%0-6之间产生6000个点行矢量
fm=i/8;%基带信号频率，码元数为16时域长度为8，一个单位2码元
f1=8;
f2=6;
a=round(rand(1,i));%产生随机数组


st1=t;
for n=1:16
    if a(n)<1
        for m=j/i*(n-1)+i:j/i*n
            st1(m)=0;
        end
    else
        for m=j/i*(n-1)+1:j/i*n
            st1 (m)=1;
        end
    end
end
figure(1);
subplot(4,1,1);
plot(t,st1,'m');
title('baseband signal-------stl')
axis([0,6,-1,2]);

%基带信号求反码
st2=st1;
for n=1:j
    st2 (n)= ~st2(n);
end
subplot(4,1,2);
plot(t,st2,'m');
title('baseband signal inverse code---st2');
axis([0,6,-1,2]);

%载波信号时域波形
s1=cos(2*pi*f1*t);
s2=cos(2*pi*f2*t);
subplot(4,1,3);
plot(s1);
title('载波信号时域波形----1');
subplot(4,1,4);
plot(s2);
title('载波信号时域波形----2');

%调制开始
F1=st1.*s1;%载波1调制
F2=st2.*s2;%载波2调制
figure(2);
subplot(3,1,1);
plot(t,F1);
title('载波1调制后F1=s1*st1')
subplot(3,1,2);
plot(t,F2);
title('载波2调制后F2=s2*st2')
fsk=F1+F2;
subplot(3,1,3);
plot(t,fsk,'m');
title('2FSK信号时域波形');

%频谱分析
%FFT

[f,stl]=T2F(t,s1);
figure(3);
subplot(4,1,1);
plot(f,fsk,'r');
title('基带信号频谱')
axis([-10,10,-4,4])

[f,sf2]=T2F(t,s1);
figure(3);
subplot(4,1,2);
plot(f,sf2,'r');
title('载波1调制后信号频谱')
axis([-10,10,-4,4])

[f,sf3]=T2F(t,s2);
subplot(4,1,3);
plot(f,sf3,'r');
title('载波2调制后信号频谱')
axis([-10,10,-4,4])

[f,sf4]=T2F(t,fsk);
subplot(4,1,4);
plot(f,sf4,'r');
title=('2FSK信号频谱');
axis([-10,10,-4,4])


%相干解调
st1=fsk.*s1;%与载波1相乘
[f,sf1]=T2F(t,stl);%傅里叶变换
[t,st1]=LPF(f,sfl,2*fm);%低通滤波
figure(4);
subplot(4,1,1);
plot(t,stl);
title('信号与s1相乘后波形');
st2=fsk.*s1;%与载波2相乘
[f,sf2]=TF2(t,st2);%傅里叶变换
[t,st2]=lpf(f,sf2,2*fm);%低通滤波
figure(4);
subplot(4,1,2);
plot(t,st2);
title('信号与s2相乘后波形');

%抽样判决
for m=0;i-1;
    if st1(1,m*500+250)>st2(1,m*500+250)
        for j=m*500+1:(m+1)*500
            at (1,j)=1;
        end
    else
        for j=m*500+1;(m+1)*500;
            at(1,j)=0;
        end
    end
end
subplot(4,1,3);
plot(t,at,'m');
axis([0,6,-1,2]);
title('抽样判决后波形')

[f,sf4]=T2F(t,at);
figure(4);
subplot(4,1,4);
plot(f,sf4,'m');
title('解调后的频谱');
axis([-10,10,-4,4])