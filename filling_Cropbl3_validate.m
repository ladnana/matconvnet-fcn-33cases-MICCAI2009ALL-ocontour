clear;
clc;
close all;

initlabelsPath = 'H:/nana/data/33cases_MICCAI2009/SegmentationClass/';
OutputDir = 'H:/nana/data/fcn4s-100-33cases_MICCAI2009_test/filling_result/';
Outputpath = 'H:/nana/data/fcn4s-100-33cases_MICCAI2009_test';
file_path =  'H:/nana/data/fcn4s-100-33cases_MICCAI2009_test/processed_result/' ;

if ~exist(fullfile(Outputpath, 'filling_result')) 
   mkdir(fullfile(Outputpath, 'filling_result'));
end

centroid = zeros(1,2); 
centroid1 = zeros(1,2); 
centroid2 = zeros(1,2); 

X=cell(30,1);
X{1, 1}='SCD0000401'; 
X{2, 1}='SCD0000501'; 
X{3, 1}='SCD0000601'; 
X{4, 1}='SCD0000701'; 
X{5, 1}='SCD0001501'; 
X{6, 1}='SCD0001601'; 
X{7, 1}='SCD0002101'; 
X{8, 1}='SCD0002201'; 
X{9, 1}='SCD0002701'; 
X{10,1}='SCD0002801';
X{11,1}='SCD0002901'; 
X{12,1}='SCD0003401'; 
X{13,1}='SCD0003901';
X{14,1}='SCD0004001'; 
X{15,1}='SCD0004101';

name = strcat(X{1,1},'*.png');
img_path_list1 = dir(strcat(file_path,name));
img_num = length(img_path_list1);
img_path_list2 = dir(strcat(initlabelsPath,name));
for k = [1 2] %获取前两张图片求解质心
    imagePath = fullfile(initlabelsPath,img_path_list2(k).name);
    image = imread(imagePath);
    if k == 1
        centroid1 = Find_centroid(image);
    else
        centroid2 = Find_centroid(image);
    end
end
centroid(1) = uint8((centroid1(1) + centroid2(1)) / 2);
centroid(2) = uint8((centroid1(2) + centroid2(2)) / 2);
for j = 2:img_num %逐一读取图像
    if j >= img_num -  2
        image_name = img_path_list1(j).name;% 图像名
        [I,map] = imread(strcat(file_path,image_name));
        I = padarray(I, [64 64]); %在A的周围扩展64个0
        [m,n] = size(I);
        picture1 = I(1:2:m,1:2:n);
        picture2 = padarray(picture1, [centroid(1)-65 centroid(2)-65],0,'pre'); %在128的左上角扩展（质心坐标-64-1）个0
        picture = padarray(picture2,[128-(centroid(1)-65) 128-(centroid(2)-65)],0,'post'); %在128的右下角扩展（128-(centroid(2)-65)）个0
        pathfile = fullfile(OutputDir,image_name);
        imshow(picture,map);
        imwrite(picture,map,pathfile,'png');
    else
        image_name = img_path_list1(j).name;% 图像名
        [I,map] = imread(strcat(file_path,image_name));
        picture1 = I;
        picture2 = padarray(picture1, [centroid(1)-65 centroid(2)-65],0,'pre'); %在128的左上角扩展（质心坐标-64-1）个0
        picture = padarray(picture2,[128-(centroid(1)-65) 128-(centroid(2)-65)],0,'post'); %在128的右下角扩展（128-(centroid(2)-65)）个0
        pathfile = fullfile(OutputDir,image_name);
        imshow(picture,map);
        imwrite(picture,map,pathfile,'png');
    end
end
