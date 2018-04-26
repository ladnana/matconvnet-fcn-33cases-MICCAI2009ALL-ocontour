clc;clear;

imdbPath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_20-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror/imdb.mat';
cropimagesPath = 'H:/nana/data/33cases_MICCAI2009/CropDCMImages-i-123+132+up-scaledown-middleshape+HVmirror-clahe';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/CropSegmentationClass-i+123+132+up-scaledown-middleshape+HVmirror';

if ~exist(cropimagesPath) 
   mkdir(cropimagesPath); 
end
if ~exist(croplabelsPath) 
   mkdir(croplabelsPath); 
end

imdb = load(imdbPath) ;
colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;
size = find(imdb.images.set == 1 & imdb.images.segmentation) ;

for i = 1:numel(size)
    %create croped images
%     if i < 403 ||(i > 657 && i < 925) || (i > 1047 && i < 1135)
%         imagePath = sprintf(imdb.paths.image2, imdb.images.name{size(i)}) ;
%         I = load(imagePath);
%         picture = I.picture;
%         save(fullfile(cropimagesPath,[imdb.images.name{size(i)} '.mat']),'picture');
%         picture = picture(end:-1:1,:);  %vertical mirror
%         save(fullfile(cropimagesPath,[strcat('V-',imdb.images.name{size(i)}) '.mat']),'picture');
% %         picture = I.picture;
% %         picture = picture(:,end:-1:1);     % horizontal mirror
% %         save(fullfile(cropimagesPath,[strcat('H-',imdb.images.name{size(i)}) '.mat']),'picture');
%     else
        imagePath = sprintf(imdb.paths.image, imdb.images.name{size(i)}) ;
        I = dicomread(imagePath);
        dicomwrite(I,fullfile(cropimagesPath,[imdb.images.name{size(i)} '.dcm']));
        I1 = I(end:-1:1,:);
        dicomwrite(I1,fullfile(cropimagesPath,[strcat('V-',imdb.images.name{size(i)}) '.dcm']));
        I2 = I(:,end:-1:1);
        dicomwrite(I2,fullfile(cropimagesPath,[strcat('H-',imdb.images.name{size(i)}) '.dcm']));
%     end    
    %create croped labels
    labelsPath = sprintf(imdb.paths.classSegmentation, imdb.images.name{size(i)}) ;
    p = imread(labelsPath);
    imwrite(p,colormap,fullfile(croplabelsPath,[imdb.images.name{size(i)} '.png']));
    p1 = p(end:-1:1,:);
    imwrite(p1,colormap,fullfile(croplabelsPath,[strcat('V-',imdb.images.name{size(i)}) '.png']));
    p2 = p(:,end:-1:1);
    imwrite(p2,colormap,fullfile(croplabelsPath,[strcat('H-',imdb.images.name{size(i)}) '.png']));
end

val = find(imdb.images.set == 2 & imdb.images.segmentation) ;
for i = 1:numel(val)
    imagePath = sprintf(imdb.paths.image, imdb.images.name{val(i)}) ;
    I = dicomread(imagePath);
    dicomwrite(I,fullfile(cropimagesPath,[imdb.images.name{val(i)} '.dcm']));
    labelsPath = sprintf(imdb.paths.classSegmentation, imdb.images.name{val(i)}) ;
    p = imread(labelsPath);
    imwrite(p,colormap,fullfile(croplabelsPath,[imdb.images.name{val(i)} '.png']));
end

