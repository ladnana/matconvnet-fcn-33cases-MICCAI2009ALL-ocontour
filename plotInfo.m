clc;clear;

expDir = 'data/fcn4s-500-MCCAI2009';
info = 'data/fcn4s-500-MCCAI2009/info.txt';
[names,iu1,iu2,pacc,macc] = textread(info, '%s %f %f %f %f') ;
X = [1,9;10,20;21,28;29,39;40,51;52,61;62,71;72,81;82,88;89,96;97,106;107,113;114,121;122,128;129,138;];%i=1:15
% X = [1,9;10,20;21,32;33,42;43,49;50,57;58,65;66,72;];%i=1:8
for i=1:15
    
    figure;
    plot(X(i,1):X(i,2),iu1(X(i,1):X(i,2)),'r-o');hold on;
    plot(X(i,1):X(i,2),iu2(X(i,1):X(i,2)),'g-o');hold on;
    plot(X(i,1):X(i,2),pacc(X(i,1):X(i,2)),'k-o');hold on;
    plot(X(i,1):X(i,2),macc(X(i,1):X(i,2)),'b-o');
    grid on;
    xlabel('切片');
    ylabel('iu,pacc,macc数值');
    temp = names(X(i,1));
    title(temp{1}(1:10));
    legend('iu1','iu2','pacc','macc',0);
    
end
[num,~] = size(names);
figure;
plot(1:num,iu1(:),'r-o');hold on;
plot(1:num,iu2(:),'g-o');hold on;
plot(1:num,pacc(:),'k-o');hold on;
plot(1:num,macc(:),'b-o');hold on;
grid on;
xlabel('切片');
ylabel('miu,pacc,macc数值');
title('全部病人切片')
legend('iu1','iu2','pacc','macc',0);