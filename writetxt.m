clc;clear;

path = 'H:\nana\data\33cases_MICCAI2009\ImageSets\Main\icontour_train.txt';
inputimagesPath = 'H:\nana\data\33cases_MICCAI2009\CropSegmentationClass-1+1.2+2+132+08+2shape_allmirror\';

img_path_list = dir([inputimagesPath '*.png']);%获取该文件夹中每个case的图像
fid = fopen(path,'w');

% n = randperm(length(img_path_list));
for i = 1:length(img_path_list)
    name = img_path_list(i).name;
    fprintf(fid,'%s %d\n',name(1:length(name)-4),1);
end
fclose(fid);