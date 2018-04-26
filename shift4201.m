clc;clear;

inputimagePath = 'H:/nana/data/33cases_MICCAI2009/1901-image/';
inputlabelsPath = 'H:/nana/data/33cases_MICCAI2009/1901-ground-i/';
cropimagesPath = 'H:/nana/data/33cases_MICCAI2009/1901-image_crop/';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/1901-ground-i_crop/';


if ~exist(cropimagesPath) 
   mkdir(cropimagesPath); 
end
if ~exist(croplabelsPath) 
   mkdir(croplabelsPath); 
end

img_path_list1 = dir([inputimagePath '*.dcm']);%获取该文件夹中每个case的图像
img_path_list2 = dir([inputlabelsPath '*.png']);%获取该文件夹中每个case的图像

for i = 1:length(img_path_list1)
    %create croped images
    imagePath = img_path_list1(i).name;
    I = dicomread([inputimagePath imagePath]);
    t = imcrop(I,[64,80,127,127]);
    g = adapthisteq(double(t)/ max(double(t(:))), 'NumTiles', [8 8], 'ClipLimit', 0.005);
    g = uint8(g * 255);
    dicomwrite(g,fullfile(cropimagesPath,imagePath));
 
    %create croped labels
    labelsPath = img_path_list2(i).name;
    [I2,map] = imread([inputlabelsPath labelsPath]);
    t2 = imcrop(I2,[64,80,127,127]);
    imwrite(t2,map,fullfile(croplabelsPath,labelsPath));
    
end