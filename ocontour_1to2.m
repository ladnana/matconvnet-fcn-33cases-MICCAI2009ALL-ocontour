clear;
clc;
close all;

OutputDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009_adam_60-1_1lr_3phases_128_4loss-o/segamentation_result_o/';
InputDir =  'H:/nana/data/fcn4s-500-33cases_MICCAI2009_adam_60-1_1lr_3phases_128_4loss-o/segamentation_result/';% ͼ���ļ���·��

if ~exist(OutputDir) 
   mkdir(OutputDir); 
end
colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;

% ImagePrefix = 'SCD00000';
% ImageSuffix =[08,15,20];
% 
% for j = 1 :33
%     name_i = [ImagePrefix num2str(j,'%02d') '_'];
%     for k = 1:length(ImageSuffix)
%         name = [name_i num2str(ImageSuffix(k),'%02d') '*.png'];
%         img_path_list = dir([InputDir name]);%��ȡ���ļ�����ÿ��case��ͼ��
%         img_num = length(img_path_list);%��ȡÿ��case��ͼ������
%         
%         for i = 1 : img_num
%             filename = fullfile(InputDir,img_path_list(i).name);
%             [I,map] = imread(filename);
%             I0 = uint8(zeros(size(I)));
%             I0(find(I == 1)) = 1;
%             image(I0);
%             imshow(I0,map);
%             pathfile = fullfile(OutputDir,img_path_list(i).name);
%             imwrite(I0,map,pathfile,'png');
%             
%         end
%     end
% end

img_path_list = dir([InputDir '*.png']);%��ȡ���ļ�����ÿ��case��ͼ��
img_num = length(img_path_list);%��ȡÿ��case��ͼ������

for i = 1 : img_num
    filename = fullfile(InputDir,img_path_list(i).name);
    I= imread(filename);
    I0 = uint8(zeros(size(I)));
    I0(find(I == 1)) = 2;
    image(I0);
    imshow(I0,colormap);
    pathfile = fullfile(OutputDir,img_path_list(i).name);
    imwrite(I0,colormap,pathfile,'png');
    
end


