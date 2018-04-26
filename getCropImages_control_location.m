clc;clear;

cropimagesPath =  'H:/nana/data/33cases_MICCAI2009/Images/';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/SegmentationClass-correctgt/';
bilinearCropImages = 'H:/nana/data/33cases_MICCAI2009/Crop_Iamges_control_location';
bilinearCroplabelsPath = 'H:/nana/data/33cases_MICCAI2009/Crop_SegmentationClass_control_location';

if ~exist(bilinearCropImages) 
   mkdir(bilinearCropImages); 
end
if ~exist(bilinearCroplabelsPath) 
   mkdir(bilinearCroplabelsPath); 
end

ImagePrefix1 = 'SCD00000';
ImageSuffix1 =[08,15,20];

ImagePrefix2 = 'SCD000';

allimg_path_list = dir(strcat(croplabelsPath,'*.png'));%获取该文件夹中所有png格式的图像  
allimg_num = length(allimg_path_list);%获取图像总数量   

colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;

centroid = zeros(1,2); 
centroid1 = zeros(1,2); 
centroid2 = zeros(1,2); 

%% deal mat image 
for i = 1:33
    name_i = strcat(ImagePrefix1,num2str(i,'%02d'));
    name_i = strcat(name_i,'_');
    for j = 1:20
        name = strcat(name_i,num2str(j,'%02d'));
        name1 = strcat(name,'*.mat');
        name2 = strcat(name,'*.png');
        img_path_list1 = dir(strcat(cropimagesPath,name1));%获取该文件夹中每个case的图像
        img_path_list2 = dir(strcat(croplabelsPath,name2));%获取该文件夹中每个case的图像
        img_num = length(img_path_list1);%获取每个case的图像数量
        for k = [1 2] %获取前两张图片求解质心
            imagePath = fullfile(croplabelsPath,img_path_list2(k).name);
            image = imread(imagePath);
            if k == 1
                centroid1 = Find_centroid(image);
%                 imshow(image,colormap);
%                 hold on
%                 plot(centroid1(2) ,centroid1(1), '*');
            else
                centroid2 = Find_centroid(image);
            end
        end
        centroid(1) = uint8((centroid1(1) + centroid2(1)) / 2);
        centroid(2) = uint8((centroid1(2) + centroid2(2)) / 2);
        for k = 1 : img_num 
            imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
            I = load(imagePath);
            picture = I.picture;
            randnum = round(-12 + (12-(-12))*rand);
            picture = imcrop(picture,[centroid(2)-64 + randnum,centroid(1)-64 + randnum,127,127]);
            filename = fullfile(bilinearCropImages,[name1 '.mat']);
            save(fullfile(bilinearCropImages,img_path_list1(k).name),'picture');
            
            labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
            picture = imread(labelsPath);
            picture = imcrop(picture,[centroid(2)-64 + randnum,centroid(1)-64 + randnum,127,127]);
            imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
            
         end
    end
end

%% deal dcm image 
% 
% for i = 1:45
%     name = strcat(ImagePrefix2,num2str(i,'%02d'));
%     name = strcat(name,'01_');
%     name1 = strcat(name,'*.dcm');
%     name2 = strcat(name,'*.png');
%     img_path_list1 = dir(strcat(cropimagesPath,name1));%获取该文件夹中每个case的图像
%     img_path_list2 = dir(strcat(croplabelsPath,name2));%获取该文件夹中每个case的图像
%     img_num = length(img_path_list1);%获取每个case的图像数量
%     for k = [1 2] %获取前两张图片求解质心
%         imagePath = fullfile(croplabelsPath,img_path_list2(k).name);
%         image = imread(imagePath);
%         if k == 1
%             centroid1 = Find_centroid(image);
% %             imshow(image,colormap);
% %             hold on
% %             plot(centroid1(2) ,centroid1(1), '*');
%         else
%             centroid2 = Find_centroid(image);
%         end
%     end
%     centroid(1) = uint8((centroid1(1) + centroid2(1)) / 2);
%     centroid(2) = uint8((centroid1(2) + centroid2(2)) / 2);
%     for k = 1 : img_num
%         labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
%         picture = imread(labelsPath);
%         picture = imcrop(picture,[centroid(2)-64,centroid(1)-64,127,127]);
%         imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
%     end
%     for k = 1 : img_num
%         imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
%         picture = dicomread(imagePath);
%         picture = imcrop(picture,[centroid(2)-64,centroid(1)-64,127,127]);
%         dicomwrite(picture,fullfile(bilinearCropImages,img_path_list1(k).name));
%     end
% end
