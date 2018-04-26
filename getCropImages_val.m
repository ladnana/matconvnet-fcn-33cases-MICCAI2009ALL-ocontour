clc;clear;

cropimagesPath =  'H:/nana/data/33cases_MICCAI2009/ImagesCopy/';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/SegmentationClassCopy/';
bilinearCropImages = 'H:/nana/data/33cases_MICCAI2009/CropDCMImages_dcm';
bilinearCroplabelsPath = 'H:/nana/data/33cases_MICCAI2009/CropSegmentationClass_dcm';

ImagePrefix = 'SCD000';

colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;
% for i = [4,5,6,7,8,9,10,11,15,16,17,18,19,20,21,22,27,28,29,30,31,32,33,34,39,40,41,42,43,44]
for i = [1,2,3,12,13,14,23,24,25,26,35,36,37,38,45]
    name = strcat(ImagePrefix,num2str(i,'%02d'));
    name = strcat(name,'01_');
    name1 = strcat(name,'*.dcm');
    name2 = strcat(name,'*.png');
    img_path_list1 = dir(strcat(cropimagesPath,name1));%获取该文件夹中每个case的图像
    img_path_list2 = dir(strcat(croplabelsPath,name2));%获取该文件夹中每个case的图像
    img_num = length(img_path_list1);%获取每个case的图像数量
    for k = 1 : img_num
        labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
        picture = imread(labelsPath);
        picture = imcrop(picture,[64,64,127,127]);
        imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
        
        imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
        picture = dicomread(imagePath);
        picture = imcrop(picture,[64,64,127,127]);
        dicomwrite(picture,fullfile(bilinearCropImages,img_path_list1(k).name));
    end
end