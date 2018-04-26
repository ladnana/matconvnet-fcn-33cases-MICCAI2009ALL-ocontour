clear;
clc;
close all;

OutputDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror/processed_result/';
Outputpath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror';
file_path =  'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror/segamentation_result/';% 图像文件夹路径
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有png格式的图像
img_num = length(img_path_list);%获取图像总数量

floder = OutputDir(length(Outputpath) + 2:length(OutputDir));
if ~exist(fullfile(Outputpath, floder)) 
   mkdir(fullfile(Outputpath, floder)); 
end

% A = imread(strcat(file_path,'SCD0000401_0040.png'));
% imshow(A);
for j = 1:img_num %逐一读取图像
    image_name = img_path_list(j).name;% 图像名
    [I,map] = imread(strcat(file_path,image_name));
    imshow(I,map);
    %     [I,map] = imread('SCD0003401_0100.png');
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
        if num>1
            %find the biggest area
            areas = zeros(1,num);
            for k=1:num
                areas(k) = sum(sum(L==k));
            end
            [~,ind]=max(areas);
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
            endocardium = imopen (endocardium, se2 );
            
        else
            epicardium = uint8(zeros(size(I)));
            epicardium ( find (I2==2) ) = 2;
        end
    end
    
%     A = double(endocardium);
%     B = double(epicardium);
%     imsize = size(A);
%     C = zeros(imsize);
%     C(find(A)) = 1;
%     C(find(B)) = 2;
%     I0 = uint8(C);  %为了保留图片做对比
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%extract ellipse from epocardium %%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     endocardium0 = endocardium;
%     E = edge(endocardium);
%     endoparams.minMajorAxis = 10;
%     endoparams.maxMajorAxis = 180;
%     endoparams.minAspectRatio = 0.8;
%     endoparams.randomize = 0;
%     endoparams.numBest = 1;
%     endobestFits = ellipseDetection(E, endoparams);
%     [vx, vy]  = ellipse(endobestFits(1,3),endobestFits(1,4),endobestFits(1,5)*pi/180,endobestFits(1,1),endobestFits(1,2),'w');
%     
%     sz = size(I);
%     [X,Y] = meshgrid(1:sz(1),1:sz(1));
%     IN = inpolygon (Y, X, vx, vy);
%     index = find (IN);
%     SolidCircle = zeros( size( endocardium ));
%     SolidCircle(sub2ind(size(SolidCircle), X(index),Y(index))) = 1;
%     endocardium = imdilate(SolidCircle,strel('disk',2));
%     
%     [r,c]= find( endocardium );
%     IN = inpolygon (c,r, vx, vy);
%     index = find (IN);
%     mask = zeros( size( endocardium ));
%     mask(sub2ind(size(mask), r(index), c(index))) = 1;
%     
%     endocardium = mask;
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%extract ellipse from epicardium %%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     epicardium0 = epicardium;
%     params.minMajorAxis = endobestFits(1,3)+5;
%     params.maxMajorAxis = 180;
%     params.minAspectRatio = 0.8;
%     params.randomize = 0;
%     params.numBest = 1;
%     %         LVregion = zeros( size(epicardium ));
%     %         LVregion( find((epicardium | imdilate(endomask,strel('disk',7))))) = 1;
%     LVregion = epicardium;
%     E = edge (LVregion, 'canny');
%     % if length(find(endocardium)) < 150
%     %     params.minAspectRatio = 0.9;
%     %     E( find(~(imdilate(epicardium,strel('disk',5)) | imdilate(endomask,strel('disk',7))))) = 0;
%     % else
%     %     E( find(~(imdilate(epicardium,strel('disk',1)) | imdilate(endomask,strel('disk',7))))) = 0;
%     % end
%     E( find ( imdilate(endocardium,strel('disk',3)))) = 0;
%     bestFits = ellipseDetection(E, params);
%     figure(4); imshow(I,[0 255]);  hold on;
%     [vx, vy]  = ellipse(bestFits(1,3),bestFits(1,4),bestFits(1,5)*pi/180,bestFits(1,1),bestFits(1,2),'w');
%     
% %     epicardium = imdilate(epicardium,strel('disk',1));
%     [r,c]= find( epicardium );
%     IN = inpolygon (c,r, vx, vy);
%     index = find (IN);
%     mask = zeros( size( epicardium ));
%     mask(sub2ind(size(mask), r(index), c(index))) = 1;
%     
%     epicardium = mask;
% 
%     %         %%%%%write auto segmentation results%%%%%%%%%%%
%     %         B = bwboundaries (endocardium);
%     %         if ~isempty (B)
%     %             endoB = fliplr(B{1});
%     %             autoIContoursFilename = [OutputDir1 'fcn4s_Eval-100-MCCAI2009-15\' caseName '\contours-auto\Auto2\IM-0001-' t(12:15) '-icontour-auto.txt'];
%     %             dlmwrite (autoIContoursFilename, endoB, ' ');
%     %         end
%     %         B = bwboundaries (epicardium);
%     %         if ~isempty (B)
%     %             epiB = fliplr(B{1});
%     %             autoOContoursFilename = [OutputDir1 'fcn4s_Eval-100-MCCAI2009-15\' caseName '\contours-auto\Auto2\IM-0001-' t(12:15) '-ocontour-auto.txt'];
%     %             dlmwrite (autoOContoursFilename, epiB, ' ');
%     %         end
    
    A = double(endocardium);
    B = double(epicardium);
    imsize = size(A);
    C = zeros(imsize);
    C(find(A)) = 1;
    C(find(B)) = 2;
    I = uint8(C);
%     diff = norm(double(I) - double(I0),2);
%     if(diff <= 5)
%         I = I0;
%     end
    image(I);
    imshow(I,map);
    pathfile = fullfile(OutputDir,image_name);
    imwrite(I,map,pathfile,'png');
end