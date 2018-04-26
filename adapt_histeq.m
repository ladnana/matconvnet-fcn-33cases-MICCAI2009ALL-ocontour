clc;clear;

inputimagePath = 'H:\nana\data\33cases_MICCAI2009\shape-first_crop-mirror\';
outputimagesPath = 'H:\nana\data\33cases_MICCAI2009\clahe_shape\';

if ~exist(outputimagesPath) 
   mkdir(outputimagesPath); 
end

% img_path_list1 = dir([inputimagePath '*.mat']);%获取该文件夹中每个case的图像
img_path_list2 = dir([inputimagePath '*.dcm']);%获取该文件夹中每个case的图像

% for j = 1 :33
%     name = ['SCD00000' num2str(j,'%02d') '_20*.mat'];
%     img_path_list1 = dir([inputimagePath name]);%获取该文件夹中每个case的图像
%     img_num = length(img_path_list1);%获取每个case的图像数量
% 
%     for i = 1 : img_num
%         imagePath = img_path_list1(i).name;
%         I = load([inputimagePath imagePath]);
%         picture = I.picture;
%         figure(1);subplot(121);imshow(picture,[]);
% 
%         if j == 5
%             g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[8 8],'ClipLimit',0.001);
%         elseif j == 6
%             g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[12 12],'ClipLimit',0.003);
%         elseif j == 11 || j == 21
%             if i >= 4
%                 g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[4 4],'ClipLimit',0.01);
%             else
%                 g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[10 10],'ClipLimit',0.001);
%             end
%         elseif j == 20 || j == 25
%             g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[12 12],'ClipLimit',0.003);
%         elseif j == 27|| j == 28
%             g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[8 8],'ClipLimit',0.008);
%         elseif j == 29
%             g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[4 4],'ClipLimit',0.003);
%         else
%             g3 = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[8 8],'ClipLimit',0.005);
%         end
%         g3 = uint8(g3 * 255);
%         subplot(122);imshow(g3,[]);
%         
%         picture = g3;
%         new_name = [imagePath(1:length(imagePath)-4) '.mat']
%         save(fullfile(outputimagesPath,new_name),'picture');
% 
%         pause;
%     end
% end

for i = 1:length(img_path_list2)
    imagePath = img_path_list2(i).name;
    I2 = dicomread([inputimagePath imagePath]);
    figure(1);subplot(121);imshow(I2,[]);

    g3 = adapthisteq(double(I2)/ max(double(I2(:))), 'NumTiles', [8 8], 'ClipLimit', 0.005);      
    g3 = uint8(g3 * 255);
    subplot(122);imshow(g3,[]);
    new_name = [imagePath(1:length(imagePath)-4) '.dcm']
    dicomwrite(g3,fullfile(outputimagesPath,new_name));
%     pause;
end