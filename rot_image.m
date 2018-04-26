clc;clear;

inputimagePath = 'H:/nana/data/33cases_MICCAI2009/1901+3401+4001+4201-image/';
inputlabelsPath = 'H:/nana/data/33cases_MICCAI2009/1901+3401+4001+4201-ground/';
cropimagesPath = 'H:/nana/data/33cases_MICCAI2009/1901+3401+4001+4201-image_rot/';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/1901+3401+4001+4201-ground_rot/';


if ~exist(cropimagesPath) 
   mkdir(cropimagesPath); 
end
if ~exist(croplabelsPath) 
   mkdir(croplabelsPath); 
end

img_path_list1 = dir([inputimagePath '*.dcm']);%��ȡ���ļ�����ÿ��case��ͼ��
img_path_list2 = dir([inputlabelsPath '*.png']);%��ȡ���ļ�����ÿ��case��ͼ��

for i = 1:length(img_path_list1)
    %create croped images
    imagePath = img_path_list1(i).name;
    I = dicomread([inputimagePath imagePath]);
    t = rot90(I,3);%��ʱ��ת270��;
    dicomwrite(t,fullfile(cropimagesPath,imagePath));
 
    %create croped labels
    labelsPath = img_path_list2(i).name;
    [I2,map] = imread([inputlabelsPath labelsPath]);
    t2 = rot90(I2,3);%��ʱ��ת270��;
    imwrite(t2,map,fullfile(croplabelsPath,labelsPath));
    
end