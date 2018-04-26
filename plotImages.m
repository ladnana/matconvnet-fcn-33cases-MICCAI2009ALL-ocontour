sourcePath = 'data/33cases_MICCAI2009/Images/SCD0004001_0059.dcm';
groundTruthPath = 'data/33cases_MICCAI2009/SegmentationClass/SCD0004001_0059.png';
input1Path = 'data/fcn4s-500-33cases_MICCAI2009/processed_result/SCD0004001_0059.png';
input2Path = 'data/fcn4s-500-33cases_MICCAI2009/Segamentation_result_FCN4s_138_New_second/SCD0004001_0059.png';

source = dicomread(sourcePath) ;
groundTruth = imread(groundTruthPath);
input1 = imread(input1Path);
input2 = imread(input2Path);

sourceC = imcrop(source,[64,64,127,127]);
groundTruthC = imcrop(groundTruth,[64,64,127,127]);
temp1 = imcrop(input1,[64,64,127,127]);
temp2 = imcrop(input2,[64,64,127,127]);

inputI = temp1;
inputI(inputI==2)=0;
BWI = im2bw(inputI, graythresh(inputI));
BI = bwboundaries(BWI);
boundariesI = BI{1};

inputI2 = temp2;
inputI2(inputI2==2)=0;
BWI2 = im2bw(inputI2, graythresh(inputI2));
BI2 = bwboundaries(BWI2);
boundariesI2 = BI2{1};

inputI3 = groundTruthC;
inputI3(inputI3==2)=0;
BWI3 = im2bw(inputI3, graythresh(inputI3));
BI3 = bwboundaries(BWI3);
boundariesI3 = BI3{1};

figure;imshow(sourceC,[]);
hold on;plot(boundariesI(:,2),boundariesI(:,1),'r.','markersize',5);
hold on;plot(boundariesI3(:,2),boundariesI3(:,1),'g.','markersize',5);
figure;imshow(sourceC,[]);
hold on;plot(boundariesI2(:,2),boundariesI2(:,1),'r.','markersize',5);
hold on;plot(boundariesI3(:,2),boundariesI3(:,1),'g.','markersize',5);

inputO = temp1;
BWO = im2bw(inputO, graythresh(inputO));
BO = bwboundaries(BWO);
boundariesO = BO{1};

inputO2 = temp2;
BWO2 = im2bw(inputO2, graythresh(inputO2));
BO2 = bwboundaries(BWO2);
boundariesO2 = BO2{1};

inputO3 = groundTruthC;
BWO3 = im2bw(inputO3, graythresh(inputO3));
BO3 = bwboundaries(BWO3);
boundariesO3 = BO3{1};

figure;imshow(sourceC,[]);
hold on;plot(boundariesO(:,2),boundariesO(:,1),'b.','markersize',5);
hold on;plot(boundariesO3(:,2),boundariesO3(:,1),'g.','markersize',5);
figure;imshow(sourceC,[]);
hold on;plot(boundariesO2(:,2),boundariesO2(:,1),'b.','markersize',5);
hold on;plot(boundariesO3(:,2),boundariesO3(:,1),'g.','markersize',5);
