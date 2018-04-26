x  = [100,300,500,500];
y  = [0.7184,0.7433,0.7524,0.7607];%meanIu 4s
y1 = [0.7598,0.7957,0.8041,0.8204];%iu1
y2 = [0.4046,0.4422,0.4606,0.4684];%iu2

plot(x(:),y(:),'r-.');hold on;
plot(x(:),y1(:),'g-.');hold on;
plot(x(:),y2(:),'b-.');hold on;

y  = [0.7370,0.7658,0.7744,0.7845];%meanIu 4s_add
y1 = [0.7772,0.8060,0.8168,0.8349];%iu1
y2 = [0.4426,0.4990,0.5134,0.5246];%iu2

plot(x(:),y(:),'r-o');hold on;
plot(x(:),y1(:),'g-o');hold on;
plot(x(:),y2(:),'b-o');hold on;

y  = [0.7553,0.7754,0.7633,0.7714];%meanIu 4s_crop
y1 = [0.8084,0.8146,0.8004,0.8155];%iu1
y2 = [0.4868,0.5398,0.5190,0.5249];%iu2

plot(x(:),y(:),'r-x');hold on;
plot(x(:),y1(:),'g-x');hold on;
plot(x(:),y2(:),'b-x');hold on;

y  = [0.7704,0.7917,0.7917,0.7937];%meanIu 4s_crop_add
y1 = [0.8086,0.8431,0.8494,0.8538];%iu1
y2 = [0.5308,0.5567,0.5493,0.5503];%iu2

plot(x(:),y(:),'r-*');hold on;
plot(x(:),y1(:),'g-*');hold on;
plot(x(:),y2(:),'b-*');hold on;
legend('miu','iu1','iu2','miu-add','iu1-add','iu2-add','miu-crop','iu1-crop','iu2-crop','miu-add-crop','iu1-add-crop','iu2-add-crop',0);