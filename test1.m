clear all;
clc;
%A=3.5;
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
