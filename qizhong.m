clear all;
i=16;
j=8000;
t=linspace(0,8,j);%0-6֮�����6000������ʸ��
fm=i/8;%�����ź�Ƶ�ʣ���Ԫ��Ϊ16ʱ�򳤶�Ϊ8��һ����λ2��Ԫ
f1=8;
f2=6;
a=round(rand(1,i));%�����������


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

%�����ź�����
st2=st1;
for n=1:j
    st2 (n)= ~st2(n);
end
subplot(4,1,2);
plot(t,st2,'m');
title('baseband signal inverse code---st2');
axis([0,6,-1,2]);

%�ز��ź�ʱ����
s1=cos(2*pi*f1*t);
s2=cos(2*pi*f2*t);
subplot(4,1,3);
plot(s1);
title('�ز��ź�ʱ����----1');
subplot(4,1,4);
plot(s2);
title('�ز��ź�ʱ����----2');

%���ƿ�ʼ
F1=st1.*s1;%�ز�1����
F2=st2.*s2;%�ز�2����
figure(2);
subplot(3,1,1);
plot(t,F1);
title('�ز�1���ƺ�F1=s1*st1')
subplot(3,1,2);
plot(t,F2);
title('�ز�2���ƺ�F2=s2*st2')
fsk=F1+F2;
subplot(3,1,3);
plot(t,fsk,'m');
title('2FSK�ź�ʱ����');

%Ƶ�׷���
%FFT

[f,stl]=T2F(t,s1);
figure(3);
subplot(4,1,1);
plot(f,fsk,'r');
title('�����ź�Ƶ��')
axis([-10,10,-4,4])

[f,sf2]=T2F(t,s1);
figure(3);
subplot(4,1,2);
plot(f,sf2,'r');
title('�ز�1���ƺ��ź�Ƶ��')
axis([-10,10,-4,4])

[f,sf3]=T2F(t,s2);
subplot(4,1,3);
plot(f,sf3,'r');
title('�ز�2���ƺ��ź�Ƶ��')
axis([-10,10,-4,4])

[f,sf4]=T2F(t,fsk);
subplot(4,1,4);
plot(f,sf4,'r');
title=('2FSK�ź�Ƶ��');
axis([-10,10,-4,4])


%��ɽ��
st1=fsk.*s1;%���ز�1���
[f,sf1]=T2F(t,stl);%����Ҷ�任
[t,st1]=LPF(f,sfl,2*fm);%��ͨ�˲�
figure(4);
subplot(4,1,1);
plot(t,stl);
title('�ź���s1��˺���');
st2=fsk.*s1;%���ز�2���
[f,sf2]=TF2(t,st2);%����Ҷ�任
[t,st2]=lpf(f,sf2,2*fm);%��ͨ�˲�
figure(4);
subplot(4,1,2);
plot(t,st2);
title('�ź���s2��˺���');

%�����о�
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
title('�����о�����')

[f,sf4]=T2F(t,at);
figure(4);
subplot(4,1,4);
plot(f,sf4,'m');
title('������Ƶ��');
axis([-10,10,-4,4])