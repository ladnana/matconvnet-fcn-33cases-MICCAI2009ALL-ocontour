clc;clear;

cropimagesPath =  'H:/nana/data/33cases_MICCAI2009-256/Crop_CentroidIamges_128/';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009-256/Crop_CentroidSegmentationClass_128/';
bilinearCropImages = 'H:/nana/data/33cases_MICCAI2009-256/Crop_CentroidIamgesbl3_128';
bilinearCroplabelsPath = 'H:/nana/data/33cases_MICCAI2009-256/Crop_CentroidSegmentationClassbl3_128';

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
    for j = 1:20
        name = strcat(name_i,num2str(j,'%02d'));
        name1 = strcat(name,'*.mat');
        name2 = strcat(name,'*.png');
        img_path_list1 = dir(strcat(cropimagesPath,name1));%获取该文件夹中每个case的图像
        img_path_list2 = dir(strcat(croplabelsPath,name2));%获取该文件夹中每个case的图像
        img_num = length(img_path_list1);%获取每个case的图像数量
        for k = 1 : img_num %读取图像的最后3张
            if k >= img_num -  2
                labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
                picture = imread(labelsPath);
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
                imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
            else %不作处理
                labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
                picture = imread(labelsPath);
                imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
            end
        end
         for k = 1 : img_num %读取图像的最后3张
            if k >= img_num -  2
                imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
                I = load(imagePath);
                picture = imresize(I.picture,2,'bilinear');
%                 final_output2 = NEDI(I.picture);
%                 picture = final_output2;
                if i == 6 || i == 9 || i == 11 || i == 32
                    picture = imcrop(picture,[65,86,127,127]);
                else
                    picture = imcrop(picture,[65,65,127,127]);
                end
                filename = fullfile(bilinearCropImages,[name1 '.mat']);
                save(fullfile(bilinearCropImages,img_path_list1(k).name),'picture');
            else %不作处理,复制到当前文件夹
                imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
                I = load(imagePath);
                picture = I.picture;
                filename = fullfile(bilinearCropImages,[name1 '.mat']);
                save(fullfile(bilinearCropImages,img_path_list1(k).name),'picture');
            end
         end
    end
end

%% deal dcm image 
% for i = 1:45
%     name = strcat(ImagePrefix2,num2str(i,'%02d'));
%     name = strcat(name,'01_');
%     name1 = strcat(name,'*.dcm');
%     name2 = strcat(name,'*.png');
%     img_path_list1 = dir(strcat(cropimagesPath,name1));%获取该文件夹中每个case的图像
%     img_path_list2 = dir(strcat(croplabelsPath,name2));%获取该文件夹中每个case的图像
%     img_num = length(img_path_list1);%获取每个case的图像数量
%     for k = 1 : img_num %读取图像的最后3张
%         if k >= img_num -  2
%             labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
%             picture = imread(labelsPath);
%             picture = imresize(picture,2,'bilinear');
%             [m,n] = size(picture);
%             for l = 2 : m - 1
%                 for t = 2 : n - 1
%                     logical = picture(l-1:l+1,t-1:t+1);
%                     if ~all(logical(:)) && picture(l,t) == 1
%                         picture(l,t) = 2;
%                     end
%                 end
%             end
%             if i == 13 
%                 picture = imcrop(picture,[56,89,127,127]);
%             elseif i == 42
%                 picture = imcrop(picture,[65,81,127,127]);
%             elseif i == 23
%                 picture = imcrop(picture,[33,65,127,127]);
%             else
%                 picture = imcrop(picture,[65,65,127,127]);
%             end
%             imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
%         else %不作处理
%             labelsPath = fullfile(croplabelsPath,img_path_list2(k).name);
%             picture = imread(labelsPath);
%             imwrite(picture,colormap,fullfile(bilinearCroplabelsPath,img_path_list2(k).name),'png');
%         end
%     end
%     for k = 1 : img_num     %读取图像的最后3张
%         if k >= img_num -  2
%             imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
%             I = dicomread(imagePath);
%             picture = imresize(I,2,'bilinear');
% %             final_output2 = NEDI(I);
% %             picture = final_output2;
%             if i == 13 
%                 picture = imcrop(picture,[56,89,127,127]);
%             elseif i == 42
%                 picture = imcrop(picture,[65,81,127,127]);
%             elseif i == 23
%                 picture = imcrop(picture,[33,65,127,127]);
%             else
%                 picture = imcrop(picture,[65,65,127,127]);
%             end
%             dicomwrite(picture,fullfile(bilinearCropImages,img_path_list1(k).name));
%         else %不作处理,复制到当前文件夹
%             imagePath = fullfile(cropimagesPath,img_path_list1(k).name);
%             picture = dicomread(imagePath);
%             dicomwrite(picture,fullfile(bilinearCropImages,img_path_list1(k).name));
%         end
%     end
% end

