clc;clear;

InputimagesPath =  'H:/nana/data/33cases_MICCAI2009/Images/';
InputlabelsPath = 'H:/nana/data/33cases_MICCAI2009/SegmentationClass-correctgt-i/';
Outputimagespath = 'H:/nana/data/33cases_MICCAI2009/CropDCMImages-i-resize-mirror2.0-control_location';
OutputlabelsPath = 'H:/nana/data/33cases_MICCAI2009/CropSegmentationClass-i-resize-mirror2.0-control_location';

ImagePrefix1 = 'SCD00000';
ImagePrefix2 = 'SCD000';

centroid = zeros(1,2); 
centroid1 = zeros(1,2); 
centroid2 = zeros(1,2); 

if ~exist(Outputimagespath) 
   mkdir(Outputimagespath); 
end
if ~exist(OutputlabelsPath) 
   mkdir(OutputlabelsPath); 
end
ImagePrefix = 'SCD00000';
ImageSuffix =[08,20];


for i = 1 : 33
    name_i = [ImagePrefix num2str(i,'%02d') '_'];
    for j = 1:length(ImageSuffix)
        name = [name_i num2str(ImageSuffix(j),'%02d')];
        name1 = [name '*.mat'];
        name2 = [name '*.png'];
        img_path_list1 = dir(strcat(InputimagesPath,name1));%获取该文件夹中每个case的图像
        img_path_list2 = dir(strcat(InputlabelsPath,name2));%获取该文件夹中每个case的图像
        img_num = length(img_path_list1);%获取每个case的图像数量
        for k = [1 2] %获取前两张图片求解质心
            imagePath = fullfile(InputlabelsPath,img_path_list2(k).name);
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
            %%mat
            imagePath = fullfile(InputimagesPath,img_path_list1(k).name);
            I = load(imagePath);
            picture = I.picture;
            randnum = round(-12 + (12-(-12))*rand);
            picture = imcrop(picture,[centroid(2)-64 + randnum,centroid(1)-64 + randnum,127,127]);
            %         picture = imcrop(picture,[64,64,127,127]);
            save(fullfile(Outputimagespath,img_path_list1(k).name),'picture');
            
            picture = picture(end:-1:1,:);  %vertical mirror
            save(fullfile(Outputimagespath,['V-' img_path_list1(k).name]),'picture');
            
            picture = I.picture;
            picture = imresize(picture,1.5);     %Scale
            picture = imcrop(picture,[centroid(2) * 1.5 - 64,centroid(1) * 1.5 - 64,127,127]);
            save(fullfile(Outputimagespath,['S-' img_path_list1(k).name]),'picture');
            
            picture = picture(end:-1:1,:);  %Scale + vertical mirror
            save(fullfile(Outputimagespath,['SV-' img_path_list1(k).name]),'picture');
            
            picture = I.picture;
            picture = imresize(picture,2.0);     %Scale
            if i == 1
                picture = imcrop(picture,[centroid(2) * 2.0 - 64,centroid(1) * 1.9 - 64,127,127]);
            elseif i == 9
                picture = imcrop(picture,[centroid(2) * 2.0 - 64,centroid(1) * 2.1 - 64,127,127]);
            elseif i == 11
                if k <= 5
                    picture = imcrop(picture,[centroid(2) * 2.1 - 64,centroid(1) * 2.0 - 64,127,127]);
                else
                    picture = imcrop(picture,[centroid(2) * 2.1 - 64,centroid(1) * 2.1 - 64,127,127]);
                end
            elseif i == 4 && (k == 3 || k == 4)
                picture = imcrop(picture,[centroid(2) * 2.1 - 64,centroid(1) * 1.9 - 64,127,127]);
            else
                picture = imcrop(picture,[centroid(2) * 2.0 - 64,centroid(1) * 2.0 - 64,127,127]);
            end
            save(fullfile(Outputimagespath,['S2-' img_path_list1(k).name]),'picture');
            
            picture = picture(end:-1:1,:);  %Scale + vertical mirror
            save(fullfile(Outputimagespath,['SV2-' img_path_list1(k).name]),'picture');
            
            %%png
            labelsPath = fullfile(InputlabelsPath,img_path_list2(k).name);
            [P,map] = imread(labelsPath);
            subP = imcrop(P,[centroid(2)-64 + randnum,centroid(1)-64 + randnum,127,127]);
            %         subP = imcrop(P,[64,64,127,127]);
            imwrite(subP,map,fullfile(OutputlabelsPath,img_path_list2(k).name),'png');
            
            VP = subP(end:-1:1,:);
            imwrite(VP,map,fullfile(OutputlabelsPath,['V-' img_path_list2(k).name]),'png');
            
            SP = imresize(P,1.5);     %Scale
            SP = imcrop(SP,[centroid(2) * 1.5 - 64,centroid(1) * 1.5 - 64,127,127]);
            imwrite(SP,map,fullfile(OutputlabelsPath,['S-' img_path_list2(k).name]),'png');
            
            SVP = SP(end:-1:1,:);
            imwrite(SVP,map,fullfile(OutputlabelsPath,['SV-' img_path_list2(k).name]),'png');
            
            SP = imresize(P,2.0);     %Scale
            if i == 1
                SP = imcrop(SP,[centroid(2) * 2.0 - 64,centroid(1) * 1.9 - 64,127,127]);
            elseif i == 9
                SP = imcrop(SP,[centroid(2) * 2.0 - 64,centroid(1) * 2.1 - 64,127,127]);
            elseif i == 11
                if k <= 5
                    SP = imcrop(SP,[centroid(2) * 2.1 - 64,centroid(1) * 2.0 - 64,127,127]);
                else
                    SP = imcrop(SP,[centroid(2) * 2.1 - 64,centroid(1) * 2.1 - 64,127,127]);
                end
            elseif i == 4 && (k == 3 || k == 4)
                SP = imcrop(SP,[centroid(2) * 2.1 - 64,centroid(1) * 1.9 - 64,127,127]);
            else
                SP = imcrop(SP,[centroid(2) * 2.0 - 64,centroid(1) * 2.0 - 64,127,127]);
            end
            imwrite(SP,map,fullfile(OutputlabelsPath,['S2-' img_path_list2(k).name]),'png');
            
            SVP = SP(end:-1:1,:);
            imwrite(SVP,map,fullfile(OutputlabelsPath,['SV2-' img_path_list2(k).name]),'png');
        end
    end
end

% %% deal dcm image 
% for i = [1,2,3,12,13,14,23,24,25,26,35,36,37,38,45]
%     name = [ImagePrefix2 num2str(i,'%02d') '01_'];
%     name1 = [name '*.dcm'];
%     name2 = [name '*.png'];
%     img_path_list1 = dir(strcat(InputimagesPath,name1));%获取该文件夹中每个case的图像
%     img_path_list2 = dir(strcat(InputlabelsPath,name2));%获取该文件夹中每个case的图像
%     img_num = length(img_path_list1);%获取每个case的图像数量
%     for k = [1 2] %获取前两张图片求解质心
%         imagePath = fullfile(InputlabelsPath,img_path_list2(k).name);
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
%     
%     for k = 1 : img_num
%         %%dcm
%         imagePath = fullfile(InputimagesPath,img_path_list1(k).name);
%         I = dicomread(imagePath);
%         subI = imcrop(I,[64,64,127,127]);
%         dicomwrite(subI,fullfile(Outputimagespath,img_path_list1(k).name));
%         
%         VI = subI(end:-1:1,:);
%         dicomwrite(VI,fullfile(Outputimagespath,['V-' img_path_list1(k).name]));
%         
%         SI = imresize(I,1.2);     %Scale
%         SI = imcrop(SI,[centroid(2) * 1.2 - 64,centroid(1) * 1.2 - 64,127,127]);
%         dicomwrite(SI,fullfile(Outputimagespath,['S-' img_path_list1(k).name]));
%         
%         SVI = SI(end:-1:1,:);
%         dicomwrite(SVI,fullfile(Outputimagespath,['SV-' img_path_list1(k).name]));
%         
%         %%png 
%         labelsPath = fullfile(InputlabelsPath,img_path_list2(k).name);
%         [P,map] = imread(labelsPath);
%         subP = imcrop(P,[64,64,127,127]);
%         imwrite(subP,map,fullfile(OutputlabelsPath,img_path_list2(k).name),'png');
%         
%         VP = subP(end:-1:1,:);
%         imwrite(VP,map,fullfile(OutputlabelsPath,['V-' img_path_list2(k).name]),'png');
%         
%         SP = imresize(P,1.2);     %Scale
%         SP = imcrop(SP,[centroid(2) * 1.2 - 64,centroid(1) * 1.2 - 64,127,127]);
%         imwrite(SP,map,fullfile(OutputlabelsPath,['S-' img_path_list2(k).name]),'png');
%         
%         SVP = SP(end:-1:1,:);
%         imwrite(SVP,map,fullfile(OutputlabelsPath,['SV-' img_path_list2(k).name]),'png');
%         
%     end
%     
% end
% 
% 
% for i = [4,5,6,7,8,9,10,11,15,16,17,18,19,20,21,22,27,28,29,30,31,32,33,34,39,40,41,42,43,44]
%     name = [ImagePrefix2 num2str(i,'%02d') '01_'];
%     name1 = [name '*.dcm'];
%     name2 = [name '*.png'];
%     img_path_list1 = dir(strcat(InputimagesPath,name1));%获取该文件夹中每个case的图像
%     img_path_list2 = dir(strcat(InputlabelsPath,name2));%获取该文件夹中每个case的图像
%     img_num = length(img_path_list1);%获取每个case的图像数量
%     for k = 1 : img_num
%         imagePath = fullfile(InputimagesPath,img_path_list1(k).name);
%         I = dicomread(imagePath);
%         subI = imcrop(I,[64,64,127,127]);
%         dicomwrite(subI,fullfile(Outputimagespath,img_path_list1(k).name));
%         
%         labelsPath = fullfile(InputlabelsPath,img_path_list2(k).name);
%         [P,map] = imread(labelsPath);
%         subP = imcrop(P,[64,64,127,127]);
%         imwrite(subP,map,fullfile(OutputlabelsPath,img_path_list2(k).name),'png');
%         
%     end
% end
