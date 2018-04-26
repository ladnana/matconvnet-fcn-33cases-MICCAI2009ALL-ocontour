clear;
clc;
close all;

OutputDir = 'H:/nana/data/fcn4s-100-33cases_MICCAI2009_128bilinear256_dealedge/down_result/';
Outputpath = 'H:/nana/data/fcn4s-100-33cases_MICCAI2009_128bilinear256_dealedge';
file_path =  'H:/nana/data/fcn4s-100-33cases_MICCAI2009_128bilinear256_dealedge/processed_result/'
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有png格式的图像  
img_num = length(img_path_list);%获取图像总数量   

if ~exist(fullfile(Outputpath, 'down_result')) 
   mkdir(fullfile(Outputpath, 'down_result'));
end
    
 for j = 1:img_num %逐一读取图像  
     image_name = img_path_list(j).name;% 图像名  
     [I,map] = imread(strcat(file_path,image_name));
     [m,n] = size(I);
     b = I(1:2:m,1:2:n);
%      b = downsample(m, 2);
%      a = padarray(I, [63 63]); %在A的周围扩展63个0
%      b = padarray(a,[2 2],'replicate','post');
     pathfile = fullfile(OutputDir,image_name); 
     imshow(b,map);
     imwrite(b,map,pathfile,'png');
 end