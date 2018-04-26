clc;clear;

expDir = 'data/fcn4s-500-33cases_MICCAI2009';
inputDir = 'data/fcn4s-500-33cases_MICCAI2009/processed_result';
imdbPath = fullfile(expDir, 'imdb.mat') ;
resPath = fullfile(expDir, 'results_processedF_.mat') ;

imdb = load(imdbPath) ;
val = find(imdb.images.set == 2 & imdb.images.segmentation) ;

N=3;
cmap = zeros(N,3);
cmap(2,1) = 1;
cmap(3,3) = 1;

se = strel('sphere',10);
se2 = strel('sphere',15);
se3 = strel('sphere',20);

for i=1:numel(val)
    
    imId = val(i) ;
    name = imdb.images.name{imId} ;
    inputPath = fullfile(inputDir, [name '.png']) ;
    labelsPath = sprintf(imdb.paths.classSegmentation, name) ;
    
    display(['Processing: ' name]);
    
    input = imread(inputPath);
    anno = imread(labelsPath) ;
    
    input_i = input;
    input_i(input_i==2)=0;
    
    b = im2bw(input, graythresh(input));
    b1 = im2bw(input_i, graythresh(input_i));
    
%     fc=imclose(b,se);
%     fc2=imclose(b,se2);
    fc3=imclose(b,se3);

%     fc3_o1=imopen(fc3,se);
%     fc3_o2=imopen(fc3,se2);
    fc3_o3=imopen(fc3,se3);

%     figure;imshow(fc3_o1,[]);
%     figure;imshow(fc3_o2,[]);
%     figure;imshow(fc3_o3,[]);

%     fo1_1=imopen(b1,se);
    fo1_2=imopen(b1,se2);
%     fo1_3=imopen(b1,se3);

%     figure;imshow(fo1_1,[]);
%     figure;imshow(fo1_2,[]);
%     figure;imshow(fo1_3,[]);

    [x1 y1]=find(fo1_2==1);
    [x2 y2]=find(fc3_o3==1);

    output=uint8(zeros(256,256));
    for i=1:numel(x2)
       output(x2(i),y2(i))=2;
    end

    for i=1:numel(x1)
       output(x1(i),y1(i))=1;
    end
    
%     temp = bwmorph(output,'remove');%È¡±ß½ç
    
    if ~exist(fullfile(expDir, 'processed_resultF')) 
        mkdir(fullfile(expDir, 'processed_resultF'));
    end
    imPath = fullfile(expDir, 'processed_resultF', [name '.png']) ;
    imwrite(output,cmap,imPath,'png');


%     figure;
%     subplot(2,2,1) ;
%     imshow(input,[]);
%     
%     subplot(2,2,2) ;
%     imshow(output,[]);
%     
%     subplot(2,2,3) ;
%     imshow(anno,[]);

end






