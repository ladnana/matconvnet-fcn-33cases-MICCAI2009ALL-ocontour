clear;
clc;
close all;

OutputDir = 'H:/nana/data/33cases_MICCAI2009/dealDCMImages128-1/';
Outputpath = 'H:/nana/data/33cases_MICCAI2009';
InputDir =  'H:/nana/data/33cases_MICCAI2009/CropDCMImages/';
img_path_list = dir(strcat(InputDir,'*.dcm'));%获取该文件夹中所有dcm格式的图像  
img_num = length(img_path_list);%获取图像总数量  

floder = OutputDir(length(Outputpath) + 2:length(OutputDir));
if ~exist(fullfile(Outputpath, floder)) 
   mkdir(fullfile(Outputpath, floder)); 
end
    
 for j = 1:img_num %逐一读取图像  
     image_name = img_path_list(j).name;% 图像名  
     I = dicomread(strcat(InputDir,image_name)); 
%      figure;imshow(I,'DisplayRange',[]);
%      a = max(I(:));
%      if j == 75 || j == 76 || j - 583 <= 3 || img_num - j <= 3 || j - 91 <= 5
%          I = I / (a / 1000 + 0.5);
%      elseif a > 1000
%          I = I / (a / 1000);
%      end
     I(I > 255) = 255;
%        I1 = 255 * (I - min(I(:)))/(max(I(:)) - min(I(:)));
%      b = max(I(:));
       I = uint8(I);
%      c = max(I(:));
%      I = imadjust(I,[double(min(I(:)/255)),1],[0,1]);
%      I(I > 255) = 255;
%      b = max(I(:));
%      imshow(I,'DisplayRange',[]);
     dicomwrite(I,fullfile(OutputDir,image_name));
%      [m,n] = size(I);
% %      I = I(1:2:m,1:2:n);
% %      b = padarray(I, [64 64]); 
%      a = padarray(I, [63 63]); %在A的周围扩展63个0
%      b = padarray(a,[2 2],'replicate','post');
%      pathfile = fullfile(OutputDir,image_name); 
%      imshow(b,map);
%      imwrite(b,map,pathfile,'png');
 end