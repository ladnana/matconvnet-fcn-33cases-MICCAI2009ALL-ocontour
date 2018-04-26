clear;
clc;
close all;

OutputDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009_adam_60-1_1lr_3phases_128_4loss-o/filling_result/';
Outputpath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009_adam_60-1_1lr_3phases_128_4loss-o';
file_path =  'H:/nana/data/fcn4s-500-33cases_MICCAI2009_adam_60-1_1lr_3phases_128_4loss-o/processed_result/'
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有png格式的图像  
img_num = length(img_path_list);%获取图像总数量   

floder = OutputDir(length(Outputpath) + 2:length(OutputDir));
if ~exist(fullfile(Outputpath, floder)) 
   mkdir(fullfile(Outputpath, floder)); 
end
    
 for j = 1:img_num %逐一读取图像  
     image_name = img_path_list(j).name;% 图像名  
     [I,map] = imread(strcat(file_path,image_name)); 
     [m,n] = size(I);
%      I = I(1:2:m,1:2:n);
%      b = padarray(I, [64 64]); 
    idx = strfind(image_name,'_');
    num = image_name(idx-4:idx-1);
%     if str2num(num) == 4201 || str2num(num) == 3401 || str2num(num) == 1901 || str2num(num) == 4001
%         I = rot90(I,1);
%     end
%     if str2num(num) == 1901
%         b = uint8(zeros(256));
%         b(80:80+127,64:64+127) = I;
%     elseif str2num(num) == 3401
%         b = uint8(zeros(256));
%         b(24:24+127,50:50+127) = I;
%     else
        a = padarray(I, [63 63]); %在A的周围扩展63个0
        b = padarray(a,[2 2],'replicate','post');
%     end
     pathfile = fullfile(OutputDir,image_name); 
     imshow(b,map);
     imwrite(b,map,pathfile,'png');
 end
