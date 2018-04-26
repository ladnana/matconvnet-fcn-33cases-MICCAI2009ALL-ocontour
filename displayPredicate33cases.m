% repeat tensor voting until contours enclosed
% use active contour model to modify endocardium
% decide if resegmentation is required, based  on the distance between
% detected ellipse and contours 

clear all;
close all;

pathName = 'H:\nana\33cases\';
map=zeros(3,3);
map(2,1)=1;
map(3,3)=1;

%%% load spatial resolution
load ([pathName 'SpatialResolution.mat']);  % saved in SpatialResolution

%%%find all files in the path
fileFolder=fullfile([pathName '33_cardiac_data\']);
dirOutput=dir(fullfile(fileFolder,'*.mat'));
segfileNames={dirOutput.name}';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for patient = 1: size(segfileNames,1)
       
    %load mr data
    t = segfileNames{patient};
  
    %load mannual contours
    mannualOContoursFilename = [pathName 'manual_seg\manual_seg_32points_pat' num2str(patient) '.mat'];
    if  exist(mannualOContoursFilename, 'file')
        load (mannualOContoursFilename);
    end
    
    for time = 1:20
        for slice = 1:14
            
            sz = size(manual_seg_32points);
            if sz(1) < slice continue; end
            mannual = manual_seg_32points{slice,time}(:,:);
            if mannual < 0  continue; end
            
            mannualEndo = mannual(1:32,:);
            mannualEpi = mannual(34:65,:);

            %%% ground truth %%%
            [GroundTruth,map] = imread (['H:\nana\groundtruth-33case\' ...
                'SCD00000' num2str(patient,'%02d') '_' num2str(time,'%02d') num2str(slice,'%02d') '.png']);

            subI = zeros(256);

            [endox,endoy] = meshgrid(1:size(subI,2), 1:size(subI,1));
            IN = inpolygon (endox,endoy,mannualEndo(:,1), mannualEndo(:,2));
            endoindex = find (IN);
            yxGroundTruth = uint8(zeros( size( subI )));
            [epix,epiy] = meshgrid(1:size(subI,2), 1:size(subI,1));
            IN = inpolygon (epix,epiy,mannualEpi(:,1), mannualEpi(:,2));
            epiindex = find (IN);
            yxGroundTruth(sub2ind(size(yxGroundTruth), epiy(epiindex), epix(epiindex))) = 2;
            yxGroundTruth(sub2ind(size(yxGroundTruth), endoy(endoindex), endox(endoindex))) = 1;


            
            figure(3);
            subplot(121); imshow( yxGroundTruth, map);  hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
            subplot(122); imshow( GroundTruth, map);  hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
            subplot(121); hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
            subplot(122); hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
%               I = uint8(yxGroundTruth);
%               image(I);
%               image_name = ['SCD00000' num2str(patient,'%02d') '_' num2str(time,'%02d') num2str(slice,'%02d') '.png'];
%               
%               pathfile = fullfile('H:\nana\groundtruth-33case',image_name);
%               imwrite(I,map,pathfile,'png');

            pause;
        
        end
    end 
end

