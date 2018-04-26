clc;clear;

cropimagesPath =  'H:/nana/data/33cases_MICCAI2009/ImagesCopy/';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/SegmentationClassCopy/';
bilinearCropImages = 'H:/nana/data/33cases_MICCAI2009/CropDCMImages_double';
bilinearCroplabelsPath = 'H:/nana/data/33cases_MICCAI2009/CropSegmentationClass_double';

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
for i = 1 :33
    name_i = strcat(ImagePrefix1,num2str(i,'%02d'));
    name_i = strcat(name_i,'_');
    for j = 1:3
        name = strcat(name_i,num2str(ImageSuffix1(j),'%02d'));
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
            else
                centroid2 = Find_centroid(image);
            end
        end
        centroid(1) = uint8((centroid1(1) + centroid2(1)) / 2);
        centroid(2) = uint8((centroid1(2) + centroid2(2)) / 2);
        for k = 1 : img_num %读取图像的最后3张
            if k >= img_num -  2
                labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
                picture = imread(labelsPath);
                picture = imcrop(picture,[centroid(2)-64,centroid(1)-64,127,127]);
                picture = imresize(picture,2,'bilinear');
                [m,n] = size(picture);
                for l = 2 : m - 1
                    for t = 2 : n - 1
                        logical = picture(l-1:l+1,t-1:t+1);
                        if ~all(logical(:)) && picture(l,t) == 1
                            picture(l,t) = 2;
                        end
                    end
                end
                if i == 6 || i == 9 || i == 11 || i == 22 || i == 32
                    picture = imcrop(picture,[65,86,127,127]);
                elseif i == 4
                    picture = imcrop(picture,[81,65,127,127]);
                else
                    picture = imcrop(picture,[65,65,127,127]);
                end
                tempname = strcat('1_',img_path_list2(k).name);
                imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,tempname),'png');
            else %下采样成128
                labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
                picture = imread(labelsPath);
                [m,n] = size(picture);
                picture = picture(1:2:m,1:2:n);
                tempname = strcat('1_',img_path_list2(k).name);
                imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,tempname),'png');
            end
        end
         for k = 1 : img_num %读取图像的最后3张
            if k >= img_num -  2
                imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
                I = load(imagePath);
                picture = I.picture;
                picture = imcrop(picture,[centroid(2)-64,centroid(1)-64,127,127]);
                picture = imresize(picture,2,'bilinear');
%                 final_output2 = NEDI(I.picture);
%                 picture = final_output2;
                if i == 6 || i == 9 || i == 11 || i == 32
                    picture = imcrop(picture,[65,86,127,127]);
                else
                    picture = imcrop(picture,[65,65,127,127]);
                end
                filename = fullfile(bilinearCropImages,[name1 '.mat']);
                tempname = strcat('1_',img_path_list1(k).name);
                save(fullfile(bilinearCropImages,tempname),'picture');
            else %下采样成128
                imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
                I = load(imagePath);
                picture = I.picture;
                [m,n] = size(picture);
                picture = picture(1:2:m,1:2:n);
                filename = fullfile(bilinearCropImages,[name1 '.mat']);
                tempname = strcat('1_',img_path_list1(k).name);
                save(fullfile(bilinearCropImages,tempname),'picture');
            end
         end
    end
end

%% deal dcm image 
for i = [1,2,3,12,13,14,23,24,25,26,35,36,37,38,45]
    name = strcat(ImagePrefix2,num2str(i,'%02d'));
    name = strcat(name,'01_');
    name1 = strcat(name,'*.dcm');
    name2 = strcat(name,'*.png');
    img_path_list1 = dir(strcat(cropimagesPath,name1));%获取该文件夹中每个case的图像
    img_path_list2 = dir(strcat(croplabelsPath,name2));%获取该文件夹中每个case的图像
    img_num = length(img_path_list1);%获取每个case的图像数量
    for k = [1 2] %获取前两张图片求解质心
        imagePath = fullfile(croplabelsPath,img_path_list2(k).name);
        image = imread(imagePath);
        if k == 1
            centroid1 = Find_centroid(image);
        else
            centroid2 = Find_centroid(image);
        end
    end
    centroid(1) = uint8((centroid1(1) + centroid2(1)) / 2);
    centroid(2) = uint8((centroid1(2) + centroid2(2)) / 2);
    for k = 1 : img_num %读取图像的最后2张
        if k >= img_num -  2
            labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
            picture = imread(labelsPath);
            picture = imcrop(picture,[centroid(2)-64,centroid(1)-64,127,127]);
            picture = imresize(picture,2,'bilinear');
            [m,n] = size(picture);
            for l = 2 : m - 1
                for t = 2 : n - 1
                    logical = picture(l-1:l+1,t-1:t+1);
                    if ~all(logical(:)) && picture(l,t) == 1
                        picture(l,t) = 2;
                    end
                end
            end
            if i == 13 
                if k == img_num -  2
                    picture = imcrop(picture,[58,74,127,127]);
                else
                    picture = imcrop(picture,[56,81,127,127]);
                end
            elseif i == 42
                picture = imcrop(picture,[65,81,127,127]);
            elseif i == 23
                picture = imcrop(picture,[33,65,127,127]);
            elseif i == 24 || i == 38 || i == 45
                if k == img_num -  2 && i == 24
                    picture = imcrop(picture,[73,48,127,127]);
                else
                    picture = imcrop(picture,[50,65,127,127]);
                end
            else
                picture = imcrop(picture,[65,65,127,127]);
            end
            tempname = strcat('1_',img_path_list2(k).name);
            imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,tempname),'png');
        else %下采样成128
            labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
            picture = imread(labelsPath);
            [m,n] = size(picture);
            picture = picture(1:2:m,1:2:n);
            tempname = strcat('1_',img_path_list2(k).name);
            imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,tempname),'png');
        end
    end
    for k = 1 : img_num     %读取图像的最后2张
        if k >= img_num -  2
            imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
            I = dicomread(imagePath);
            picture = imcrop(I,[centroid(2)-64,centroid(1)-64,127,127]);
            picture = imresize(picture,2,'bilinear');
            if i == 13
                if k == img_num -  2
                    picture = imcrop(picture,[58,74,127,127]);
                else
                    picture = imcrop(picture,[56,81,127,127]);
                end
            elseif i == 42
                picture = imcrop(picture,[65,81,127,127]);
            elseif i == 23
                picture = imcrop(picture,[33,65,127,127]);
            elseif i == 24 || i == 38 || i == 45
                if k == img_num -  2 && i == 24
                    picture = imcrop(picture,[73,48,127,127]);
                else
                    picture = imcrop(picture,[50,65,127,127]);
                end
            else
                picture = imcrop(picture,[65,65,127,127]);
            end
            tempname = strcat('1_',img_path_list1(k).name);
            dicomwrite(picture,fullfile(bilinearCropImages,tempname));
        else %下采样成128
            imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
            picture = dicomread(imagePath);
            [m,n] = size(picture);
            picture = picture(1:2:m,1:2:n);
            tempname = strcat('1_',img_path_list1(k).name);
            dicomwrite(picture,fullfile(bilinearCropImages,tempname));
        end
    end
end

