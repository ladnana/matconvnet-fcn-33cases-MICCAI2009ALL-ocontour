I1 = dicomread('SCD0000101_0059_128.dcm');
I2 = dicomread('SCD0000101_0059_256b1.dcm');
I3 = dicomread('SCD0000101_0059_256b2.dcm');
I4 = dicomread('SCD0000101_0059_256b3.dcm');
I5 = dicomread('SCD0000101_0059_256init.dcm');

subplot(2,3,1);imshow(I1,[]);title(128);
subplot(2,3,2); imshow(I2,[]); title('256b1');
subplot(2,3,3); imshow(I3,[]); title('256b2');
subplot(2,3,4); imshow(I4,[]); title('256b3');
subplot(2,3,5); imshow(I5,[]); title('256init');