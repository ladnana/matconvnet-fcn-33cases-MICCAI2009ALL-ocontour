clear;
clc;
close all;

OutputDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror/processed_result2/';
Outputpath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror';
file_path =  'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror/segamentation_result2/';% 图像文件夹路径
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有png格式的图像
img_num = length(img_path_list);%获取图像总数量

if ~exist(OutputDir) 
   mkdir(OutputDir); 
end

% A = imread(strcat(file_path,'SCD0000401_0040.png'));
% imshow(A);
for j = 1: img_num%逐一读取图像
    image_name = img_path_list(j).name;% 图像名
    [I,map] = imread(strcat(file_path,image_name));
    imshow(I,map);
    I_i = uint8(zeros(size(I)));
    I_o = uint8(zeros(size(I)));
    I_i ( find (I==1) ) = 1;
    I_o ( find (I==2) ) = 2;
    
    for i = [1 2]
        % delete small regions
        if i ==1
            I = I_i;
        else
            I = I_o;
        end
        [L,num]  = bwlabel ( I, 8);
        if num > 1
            %find the biggest area
            areas = zeros(1,num);
            for k=1:num
                areas(k) = sum(sum(L==k));
            end
            if i == 1
                [~,ind] = min(areas);
%                 ind = 2;
            else
                [~,ind] = max(areas);
            end
%              [~,ind]=max(areas);
            %set redundant area value 0
            index = find ( L == ind );
        else
            index = find( I );
        end
        
        I2 = uint8(zeros(size(I)));
        I2(index) = I(index) ;
        
        if i == 1
            endocardium = uint8(zeros(size(I)));
            endocardium ( find (I2==1) ) = 1;
            %%%%%%%%%%%%%%%%%%%%%
            if length(find(I2==1)) < 500
                areaTh = 0;
                se2 = strel('disk',1);
            else
                areaTh = 50;
                se2 = strel( 'disk',5);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%processing endocardium%%%%%%%%%%%%%%%%%%%%%%
            %delete small parts
            endocardium = bwareaopen (endocardium, areaTh);
            %fill holes
            endocardium = imfill (endocardium,'hole');
            %cut small corners
%             endocardium = imopen (endocardium, se2 );
            
        else
            epicardium = uint8(zeros(size(I)));
            epicardium ( find (I2==2) ) = 2;
            
        end
    end
    
    A = double(endocardium);
    B = double(epicardium);
    imsize = size(A);
    C = zeros(imsize);
    C(find(A)) = 1;
    C(find(B)) = 2;
    I0 = uint8(C);  %为了保留图片做对比
    image(I0);
    imshow(I0,map);
    pathfile = fullfile(OutputDir,image_name);
    imwrite(I0,map,pathfile,'png');
%     
end