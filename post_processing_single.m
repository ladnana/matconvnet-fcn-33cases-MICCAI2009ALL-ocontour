clear;
clc;
close all;
pathfile = 'SCD0004001_0100.png';
[I,map] = imread(pathfile);
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

A = double(endocardium);
B = double(epicardium);
imsize = size(A);
C = zeros(imsize);
C(find(A)) = 1;
C(find(B)) = 2;
I0 = uint8(C);  %为了保留图片做对比

% extract contours
B = bwboundaries (endocardium);
% if isempty (B)
%     continue;
% end
endoB = B{1};
B = bwboundaries (epicardium);
epiB = B{1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%extract ellipse from epocardium %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
endocardium0 = endocardium;
E = edge(endocardium);
endoparams.minMajorAxis = 10;
endoparams.maxMajorAxis = 180;
endoparams.minAspectRatio = 0.8;
endoparams.randomize = 0;
endoparams.numBest = 1;
endobestFits = ellipseDetection(E, endoparams);
[vx, vy]  = ellipse(endobestFits(1,3),endobestFits(1,4),endobestFits(1,5)*pi/180,endobestFits(1,1),endobestFits(1,2),'w');

sz = size(I);
[X,Y] = meshgrid(1:sz(1),1:sz(1)); 
IN = inpolygon (Y, X, vx, vy);
index = find (IN);
SolidCircle = zeros( size( endocardium ));
SolidCircle(sub2ind(size(SolidCircle), X(index),Y(index))) = 1;
endocardium = imdilate(SolidCircle,strel('disk',5));

[r,c]= find( endocardium );
IN = inpolygon (c,r, vx, vy);
index = find (IN);
mask = zeros( size( endocardium ));
mask(sub2ind(size(mask), r(index), c(index))) = 1;

endocardium = mask;

% se=strel('disk',4);%圆盘型结构元素
% epicardium = imopen(epicardium,se);
% epicardium = imclose(epicardium,se);
%%%%%%%%%%%%%%%%%%%%tensor voting%%%%%%%%%%%%%%%%%%%%%%%%
%tensor voting to guess the missing parts int epicardium
        
% if caseSlice > 1
    tensor_region = [1,1,size(I)];
    
    tmp_epi = zeros(size(epicardium));
    tmp_epi( find (epicardium==2)) = 1;
    local_epi = imcrop( tmp_epi, tensor_region);
    figure(2);  subplot(221); imshow(local_epi);
    
    T = read_dot_edge_file(epicardium);
    [e1,e2,l1,l2] = convert_tensor_ev(T);
    
    % Run the tensor voting framework
    stats = regionprops( endocardium, 'MajorAxisLength', 'MinorAxisLength' );
    radius = round((stats.MinorAxisLength + stats.MajorAxisLength)/4);
    sigma = radius/3;
    T = find_features(l1,sigma);
    
    % Threshold un-important data that may create noise in the
    % output.
    [e1,e2,l1,l2] = convert_tensor_ev(T);
    z = l1-l2;
    l1(z<0.3) = 0;
    l2(z<0.3) = 0;
    
    local_z = imcrop(z, tensor_region);
    figure(2); subplot(222); imshow(local_z,[]);  title('stick tensor');
    
    % Run a local maxima algorithm on it to extract curves
    T = convert_tensor_ev(e1,e2,l1,l2);
    clear  tensorvote;
    re = calc_ortho_extreme(T,radius,pi/8);
    [L,num] = bwlabel( re );
    if num > 1
        re = bwareaopen (  re, 20);
    end
    
    local_re = imcrop(re, tensor_region);
    figure(2);  subplot(223), imshow(local_re);  title('TV extrem');
    
    % dilate the extreme
    [ tensorvote(:,1) , tensorvote(:,2) ] = find ( re );
    dist  =HausdroffDist (tensorvote, endoB,1);
    expandre = imdilate ( re, strel('disk', round(dist/2)));
    local_expandre = imcrop(expandre, tensor_region);
    figure(2);  subplot(224); imshow(local_expandre);
    epicardium( find(expandre) ) = 2;
    
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%extract ellipse from epicardium %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epicardium0 = epicardium;
params.minMajorAxis = endobestFits(1,3)+5;
params.maxMajorAxis = 180;
params.minAspectRatio = 0.8;
params.randomize = 0;
params.numBest = 1;
%         LVregion = zeros( size(epicardium ));
%         LVregion( find((epicardium | imdilate(endomask,strel('disk',7))))) = 1;
LVregion = epicardium;
E = edge (LVregion, 'canny');
% if length(find(endocardium)) < 150
%     params.minAspectRatio = 0.9;
%     E( find(~(imdilate(epicardium,strel('disk',5)) | imdilate(endomask,strel('disk',7))))) = 0;
% else
%     E( find(~(imdilate(epicardium,strel('disk',1)) | imdilate(endomask,strel('disk',7))))) = 0;
% end
E( find ( imdilate(endocardium,strel('disk',3)))) = 0;
bestFits = ellipseDetection(E, params);
figure(4); imshow(I,[0 255]);  hold on;
[vx, vy]  = ellipse(bestFits(1,3),bestFits(1,4),bestFits(1,5)*pi/180,bestFits(1,1),bestFits(1,2),'w');

[r,c]= find( epicardium );
IN = inpolygon (c,r, vx, vy);
index = find (IN);
mask = zeros( size( epicardium ));
mask(sub2ind(size(mask), r(index), c(index))) = 1;

epicardium = mask;

% if length( find(mask) ) < length( find(epicardium) )  * 0.7
%     mask = epicardium;
% end

%         %%%%%write auto segmentation results%%%%%%%%%%%
%         B = bwboundaries (endocardium);
%         if ~isempty (B)
%             endoB = fliplr(B{1});
%             autoIContoursFilename = [OutputDir1 'fcn4s_Eval-500-MCCAI2009-15\' caseName '\contours-auto\Auto2\IM-0001-' t(12:15) '-icontour-auto.txt'];
%             dlmwrite (autoIContoursFilename, endoB, ' ');
%         end
%         B = bwboundaries (epicardium);
%         if ~isempty (B)
%             epiB = fliplr(B{1});
%             autoOContoursFilename = [OutputDir1 'fcn4s_Eval-500-MCCAI2009-15\' caseName '\contours-auto\Auto2\IM-0001-' t(12:15) '-ocontour-auto.txt'];
%             dlmwrite (autoOContoursFilename, epiB, ' ');
%         end

A = double(endocardium);
B = double(epicardium);
imsize = size(A);
C = zeros(imsize);
C(find(A)) = 1;
C(find(B)) = 2;
C = uint8(C);
diff = norm(double(C) - double(I0),2);
if(diff > 10)
    I = C;
else
%     A = double(endocardium0);
%     B = double(epicardium0);
%     I = zeros(size(A));
%     I(find(A)) = 1;
%     I(find(B)) = 2;
%     I = uint8(I);
      I = I0;
end
image(I);
imshow(I,map);
imwrite(I,map,strcat('1_',pathfile),'png');
