% repeat tensor voting until contours enclosed
% use active contour model to modify endocardium
% decide if resegmentation is required, based  on the distance between
% detected ellipse and contours 

clear all;
close all;

% map=zeros(3,3);
% map(2,1)=1;
% map(3,3)=1;

pathName = 'H:\nana\';
[num, filename] = xlsread([pathName 'SCD_PatientData.xlsx']);
for i = 2: size( filename, 1) 
    param.SCname{i-1} = filename{i,1};
    param.caseName{i-1} = filename{i,2};
end

se = strel('square',80);
se1 = strel('disk' , 10);
se2 = strel('disk',5);
se3 = strel('disk',10);

phase = 1; %ES

%%%find all files in the path
fileFolder=fullfile([pathName 'Segamentation_result\']);
dirOutput=dir(fullfile(fileFolder,'*.png'));
segfileNames={dirOutput.name}';

endoAPD = zeros(1,size(segfileNames,1));
epiAPD = zeros(1,size(segfileNames,1));
startslice = 1 ;
oldcaseName = '';
lastArea = 9999;
caseSlice = 1;

shift_x = 64;
shift_y = 64;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for slice =1:size(segfileNames,1)
       
    %load mr data
    t = segfileNames{slice};
    index = ismember(param.SCname, t(1:10));
    caseName = param.caseName{index};
    
   
%     mrfilename = [pathName 'MICCAI2009\' caseName '\DICOM\IM-0001-' t(12:15) '.dcm'];
%     org_subI = dicomread(mrfilename);
%     subI = org_subI;
%     subI( find(subI>255)) = 255;
%     info = dicominfo (mrfilename);

    %load mannual contours
    mannualOContoursFilename = [pathName 'MICCAI2009\' caseName '\contours-manual\IRCCI-expert\IM-0001-' t(12:15) '-ocontour-manual.txt'];
    if  exist(mannualOContoursFilename, 'file')
        mannualEpi = importdata (mannualOContoursFilename);
        FlagOContour = 1;
    else
        FlagOContour = 0;
    end
    mannualIContoursFilename = [pathName 'MICCAI2009\' caseName '\contours-manual\IRCCI-expert\IM-0001-' t(12:15) '-icontour-manual.txt'];
    mannualEndo = importdata (mannualIContoursFilename);
    

        % original segmentation image
%         [orgI,map] = imread ([pathName 'Segamentation_result\' segfileNames{slice}]);
%         orgI = imcrop(orgI,[64,64,127,127]);
%         if (sum(orgI(:)) < 10 | sum(orgI(find(orgI==1))) < 10) continue; end
%         I = uint8(zeros( size( subI )));
%         I (shift_y:shift_y+127,shift_x:shift_x+127) = orgI;
%         
        %%% ground truth %%%
        [GroundTruth,map] = imread (['H:\nana\groundtruth-MICCAI2009\' segfileNames{slice}]);
%          
%          
%         [M,N] = size(I);
%         figure(1); subplot(221); imshow(I,map);  title( segfileNames{slice} );
%         hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
%         if FlagOContour
%             hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
%         end
%         figure(1); subplot(222); imshow(GroundTruth,map);  
%         hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
%         if FlagOContour
%             hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
%         end
        
        subI = zeros(256);
        [endox,endoy] = meshgrid(1:size(subI,2), 1:size(subI,1));
        IN = inpolygon (endox,endoy,mannualEndo(:,1), mannualEndo(:,2));
        endoindex = find (IN);
        yxGroundTruth = uint8(zeros( size( subI )));
        if FlagOContour
            [epix,epiy] = meshgrid(1:size(subI,2), 1:size(subI,1));
            IN = inpolygon (epix,epiy,mannualEpi(:,1), mannualEpi(:,2));
            epiindex = find (IN);
            yxGroundTruth(sub2ind(size(yxGroundTruth), epiy(epiindex), epix(epiindex))) = 2;
        end
        yxGroundTruth(sub2ind(size(yxGroundTruth), endoy(endoindex), endox(endoindex))) = 1;

         
        figure(2); imshow( subI,[]);
        figure(3);
        subplot(121); imshow( yxGroundTruth, map);  hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
        subplot(122); imshow( GroundTruth, map);  hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
        if FlagOContour
            subplot(121); hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
            subplot(122); hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
        end
        
        pause;
%         I = uint8(yxGroundTruth);
%         image(I);
%         pathfile = fullfile('H:\nana\groundtruth-MICCAI2009',t);
%         imwrite(I,map,pathfile,'png');
%         

        

%         %%%%%%%%%%%%%%%%%%%%initial processing%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%following is inital processing of cardium, including endocardium
%         %%%and  epicardium
%         
%         % delete small regions
%         [L,num]  = bwlabel ( I, 8);
%         if num>1
%             %find the biggest area
%             areas = zeros(1,num);
%             for k=1:num
%                 areas(k) = sum(sum(L==k));  
%             end
%             [~,ind]=max(areas);
%             %set redundant area value 0
%             index = find ( L == ind );
%         else
%             index = find( I );
%         end    
% 
%         I2 = uint8(zeros(size(I)));
%         I2(index) = I(index) ;
% 
%         %%%%%%%%%%%%%%%%%%%%%
%         if length(find(I2==1)) < 500 | caseSlice > 6
%             areaTh = 60;
%             se2 = strel('disk',3);
%         else
%             areaTh = 100;
%             se2 = strel( 'disk',10);
%         end
%         
%         
%         %processing endocardium
%         endocardium = uint8(zeros(size(I)));
%         endocardium ( find (I2==1) ) = 1;
%         %cut small corners
%         endocardium = imopen ( endocardium, se2 );
%         %delete small parts
%         endocardium = bwareaopen (  endocardium, areaTh);
%         %fill holes
%         endocardium = imfill (endocardium,'hole');
% %         %fill missing parts
% %         endocardium = imclose( endocardium, se3 );    
%         L = bwlabel( endocardium, 8);
%         STATS = regionprops(L,'Area');
%         label = 1; area = 0;
%         for idx = 1:size(STATS,1)
%             if STATS(idx).Area > area
%                 label = idx;
%                 area = STATS(idx).Area;
%             end
%         end
%         endocardium = uint8(zeros (size(endocardium)));
%         endocardium ( find (L== label) ) = 1;
%         figure(1); subplot(222); imshow(endocardium,map);  title( ['org+' num2str(slice)]);
%         
%         if sum( endocardium(:)) == 0 continue;  end
% 
%         %%%convex hull estimation in the endocardium, modify endocardium
%         [r,c] = find(endocardium);
%         if ~isempty(r)
%             k = convhull(c,r);
%             [x,y] = meshgrid(1:size(I2,2), 1:size(I2,1));
%             IN = inpolygon (x,y, c(k), r(k));
%             index = find (IN);
%             endocardium = uint8(zeros( size( I2 )));
%             endocardium(sub2ind(size(endocardium), y(index), x(index))) = 1;
%             figure(1); subplot(223); imshow( endocardium,map); title('endocardium after convexhull');
%         end
%         
%         endoAPD(slice) = calAPD (  endocardium ,mannualEndo) * info.PixelSpacing(1);
%         endoAPD(slice)  
% 
%      
%         %%%%%%%%%%%%%%%%%%Guess Ellipse in endocardium%%%%%%%%%%%%%%%
%         %%%% ellipse detection
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             state = regionprops( endocardium );
%             region  = round(state(1).BoundingBox+[-40,-40, 60, 60]);
%             subI = adjustIntesity (subI, endocardium);
%             
%             E = edge( subI, 'canny',0.1);
% %             tmp =  innerEllipse ( subI, endocardium );
%             if caseSlice <=3 % underseg
%                 E( find (~imdilate( endocardium, strel('disk',9))) ) = 0;
%                 E( find (imerode( endocardium, strel('disk',7))) ) = 0;
%             elseif caseSlice > 7  % overseg
%                 if length( find (endocardium)) > 200
%                     E( find (~ imdilate( endocardium, strel('disk',1))) ) = 0;
%                 else % too small
%                     E( find (~ imdilate( endocardium, strel('disk',3))) ) = 0;
%                 end
%             else %unsure
%                 E( find (~imdilate( endocardium, strel('disk',7))) ) = 0;
%                 E( find (imerode( endocardium, strel('disk',7))) ) = 0;
%             end
%             if length( find(E)) > 200 
%                 E = bwareaopen (  E, 4);
%                 E = decideEndoEpi( E, subI, endocardium, 1);
%                 E = bwareaopen (  E, 4);
%             end
%            
%             params.minMajorAxis = 2;
%             params.maxMajorAxis = 180;
%             params.minAspectRatio = 0.7;
%             params.randomize = 0;
%             params.numBest = 1;
%             params.uniformWeights = 0;
% 
%             endobestFits = ellipseDetection(E, params);
%             figure(3);     imshow(subI,[0 255]); hold on; 
%             [endovx, endovy]  = ellipse(endobestFits(1,3),endobestFits(1,4),endobestFits(1,5)*pi/180,endobestFits(1,1),endobestFits(1,2),'y');
% 
%         
%         %%% create ellipse mask
%             [x,y] = meshgrid(1:size(subI,2), 1:size(subI,1));
%             IN = inpolygon (x,y, endovx, endovy);
%             index = find (IN);
%             ellipse_mask = zeros( size( subI ));
%             ellipse_mask(sub2ind(size(ellipse_mask), y(index), x(index))) = 1;
%             ellipse_mask = imdilate( ellipse_mask,strel('disk',1));
%             B = bwboundaries (ellipse_mask);
%             ellipseB = B{1};
%             
%             
%             B = bwboundaries (endocardium);
%             endoB = B{1};
%             figure(1); subplot(223);  hold on;   title( ['org+' num2str(slice)]);
%             figure(3);  imshow(subI,[0 255]);
%             hold on; plot( endoB(:,2), endoB(:,1), 'r.', 'MarkerSize',2);
%             hold on; plot( ellipseB(:,2), ellipseB(:,1), 'g.', 'MarkerSize',2);


%         %%compare detected ellipse and the contour of endocardium
%         segFlag = 0;
%         dist = HausdroffDist (ellipseB, endoB,1);
%         ratio = length(find(endocardium & ellipse_mask))/ length( find(endocardium | ellipse_mask)) ;
%         ratioTH = 0.85; 
%         if ((dist > 6 & ratio < ratioTH ) | dist > 8 ) & caseSlice < 8 
% %         if ( dist > 8)
%             segFlag = 1;
%         elseif dist > 5 & caseSlice > 8  % overseg in last slices 
%             segFlag = 1;
%         end
%         
% %         ellipseStd = std2 ( subI(find (ellipse_mask)));
% %         if length( find ( ellipse_mask)) > 1000
% %             radius = 5;
% %         else
% %             radius = 1;
% %         end
% %         ellipseStd_inner = std2 ( subI(find (imerode(ellipse_mask,strel('disk',radius)))));
% %         if ellipseStd / ellipseStd_inner > 1.2  segFlag = 0; end %%over ellipse
% 
%         if innerEdge ( E, endovx, endovy , 5)  segFlag = 0;  end;  %% ellipse is over
%         if length( find( ellipse_mask)) <  length( find( endocardium))*0.9 segFlag = 0; end 
%         disp('ellipse fitting...');  endobestFits(1,6)
% 
%         
%         %%%%%%%%%%%%%%%%%%%Active Contours Model Segmentation%%%%%%%%
%         %%%use endocardium to be the initial contour
%         if segFlag  % resegementation
%             if caseSlice/numSlice > 4/5  & length(find(endocardium)) < 500 %small endocardium, return ellipse
%                 endocardium = ellipse_mask;
%             else
%             
%                 state = regionprops( endocardium );
%                 region  = round(state(1).BoundingBox+[-40,-40, 60, 60]);
%                 
%                 % modify subI
%                 tmp_cardium = zeros(size(endocardium));
%                 tmp_I2 = imdilate( I2, strel('disk', round(10--caseSlice*0.5)));
%                 tmp_cardium(find(endocardium | tmp_I2)) =1;
%                 tmp_subI = subI;
%                 tmp_subI(find(~tmp_cardium)) = 0;
%                 local_subI = imcrop(tmp_subI, region); 
%                 local_endocardium = imcrop( endocardium, region );
% %                 local_subI = adjustIntesity (local_subI, local_endocardium);
%                 figure(4); imshow(local_subI,[0 255]);
%                 
%                 smoothcoeff = 0.1;
%                 if strcmp(t(1:10),'SCD00000801')   smoothcoeff = 0.05;  end
%                 if strcmp(t(1:10),'SCD00001801')   smoothcoeff = 0.01;  end
%                 if strcmp(t(1:10),'SCD00003101')   smoothcoeff = 0.2;  end
%                 if strcmp(t(1:10),'SDC0004001')   smoothcoeff = 0.2;  end
%                 
%                 if length(find(endocardium)) < length( find( ellipse_mask)) *0.9  % underseg
%                     local_ACM_endocardium = AC_2D_MRI (local_subI, local_endocardium , 0.5, smoothcoeff);
%                 else
%                     [local_ACMmask] = decideReseg ( local_subI, local_endocardium, caseSlice);  % decide resegmentation using image information
%                     local_ACM_endocardium = AC_2D_MRI (local_subI, local_ACMmask , 0.5, smoothcoeff );
%                 end
%                 ACM_endocardium = zeros( size( endocardium ));
%                 if sum(local_ACM_endocardium(:))~=0
%                     ACM_endocardium( region(2):region(2)+region(4), region(1):region(1)+region(3) ) =  local_ACM_endocardium;
%                 else
%                     ACM_endocardium = ellipse_mask;
%                 end
%                 endocardium = ACM_endocardium ;
%             end
%         else  % similar, do nothing
%             disp('nothing done');
%         end
        
% 
%         if FlagOContour 
%         
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%processing epicardium
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%             if caseSlice == 1  firstSliceArea = length( find(endocardium)); end
% 
%             epicardium = uint8(zeros(size(I)));
%             mask = imdilate( endocardium, strel('disk',10));
%             epicardium ( find(I2 & mask )) = 1;
% 
%         %     %cut small corners
%             if length(find(endocardium)) > 500   se1 = strel('disk',10);  else  se1 = strel('disk',1); end
%             epicardium = imopen ( epicardium, se1);
%             %fill missing parts
%             epicardium = imclose( epicardium, se );
%             epicardium( find(epicardium) ) = 2;
%             epicardium( find(endocardium==1) ) = 1;
% 
%             figure(1); subplot(224); imshow( epicardium,map);  title('epicardium');
%             hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
%             hold on; plot(mannualEpi(:,1), mannualEpi(:,2),'g.','markersize',2); 
% 
%             % extract contours
%             B = bwboundaries (endocardium);
%             if isempty (B)
%                 continue;
%             end
%             endoB = B{1};
%             B = bwboundaries (epicardium);
%             epiB = B{1};
% 
%             %%%%%%%%%%%%%%%%%%%%tensor voting%%%%%%%%%%%%%%%%%%%%%%%%
%             %tensor voting to guess the missing parts int epicardium
%                 T = read_dot_edge_file(epicardium);
%                 [e1,e2,l1,l2] = convert_tensor_ev(T);
%                 figure(2); subplot(221); imshow(l1,[]);  colorbar; title('tensor L1');
% 
%                 % Run the tensor voting framework
%                 sigma = 5;  radius = 15; 
%                 T = find_features(l1,sigma);
% 
%                 % Threshold un-important data that may create noise in the
%                 % output.
%                 [e1,e2,l1,l2] = convert_tensor_ev(T);
%                 z = l1-l2;
%                 l1(z<0.3) = 0;
%                 l2(z<0.3) = 0;
% 
%                  % Run a local maxima algorithm on it to extract curves
%                 T = convert_tensor_ev(e1,e2,l1,l2);
%                 clear  tensorvote;
%                 re = calc_ortho_extreme(T,radius,pi/8);
%                 [L,num] = bwlabel( re );
%                 if num > 1 
%                     re = bwareaopen (  re, 20);
%                 end
%                 figure(2);  subplot(223), imshow(re);  title('TV extrem');
% 
%                 % dilate the extreme 
%                 [ tensorvote(:,1) , tensorvote(:,2) ] = find ( re );
%                 dist  =HausdroffDist (tensorvote, endoB,1);
%                 expandre = imdilate ( re, strel('disk', round(dist/2)));
%                 figure(2);  subplot(222); imshow(expandre);
%                 epicardium( find(expandre) ) = 2;
% 
%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            %%%%%%extract ellipse from epicardium %%%%%%%%%%%%%%%%%%%%%%%
%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             params.minMajorAxis = endobestFits(1,3)+5;
%             params.maxMajorAxis = 180;
%             params.minAspectRatio = 0.7;
%             params.randomize = 0;
%             params.numBest = 1;
%             LVregion = zeros( size(epicardium ));
%             LVregion( find(epicardium | imdilate(ellipse_mask,strel('disk',7)))) = 1;
%             E = edge (LVregion, 'canny');  
%             bestFits = ellipseDetection(E, params);
%             figure(1); subplot(222);  hold on; 
%             [vx, vy]  = ellipse(bestFits(1,3),bestFits(1,4),bestFits(1,5)*pi/180,bestFits(1,1),bestFits(1,2),'w');
%             [r,c]= find( epicardium );
%             IN = inpolygon (c,r, vx, vy);
%             index = find (IN);
%             mask = zeros( size( epicardium ));
%             mask(sub2ind(size(mask), r(index), c(index))) = 1;
% 
%             %modify mask based on the shape of endocardium
%             in_out_dist  = HausdroffDist ([vx vy], [endovx endovy],0);
%             if in_out_dist < 3  %expand mask of epicardium 
%                 mask( find(imdilate( ellipse_mask, strel('disk', round(dist))))) = 1;
%             end
% 
%             new_epicardium = zeros( size(epicardium));
%             new_epicardium( find(mask & epicardium == 2)) = 2;
%             epicardium = new_epicardium;
%             darkLevel = mean( subI( find( epicardium == 2)));
% 
% 
%             %show results
%             cardium = epicardium;
%             cardium( find(endocardium==1) ) = 1;
%             figure(2);  subplot(224); imshow(uint8(cardium),map);
%             figure(2); subplot(224); hold on; plot(mannualEndo(:,1), mannualEndo(:,2),'g.','markersize',2); 
%             figure(2); subplot(224);  hold on; plot(mannualEpi(:,1), mannualEpi(:,2), 'g.','markersize',2);
% 
% 
%             filename = [pathName 'Segamentation_result_New\' ,segfileNames{slice}];
%             imwrite( uint8(cardium), map, filename);
% 
%             % show detected contours
%             figure(3); imshow(subI,[]); 
%             B = bwboundaries (endocardium);        
%             if ~isempty (B)     
%                 endoB = fliplr(B{1});  
%                 figure(3); hold on; plot( endoB(:,1), endoB(:,2), 'r.','markersize',2);
%             end
%             B = bwboundaries (epicardium);        
%             if ~isempty (B)     
%                 epiB = fliplr(B{1});  
%                 figure(3);  hold on; plot( epiB(:,1), epiB(:,2), 'g.','markersize',2);
%             end
% 
%     %         
%     %         if caseSlice == 1
%     %             firstSliceStd = getFirstSliceStd (subI, endocardium, epicardium)
%     %         else
%     %             if decideEpiReseg (subI, endocardium, epicardium, firstSliceArea, firstSliceStd)
%     % %                 epiAPD(slice)
%     % %                 pause;
%     %                  figure(5); imshow( subI, [0, 255]);
%     %                  B = bwboundaries (epicardium);  epiB = B{1};
%     %                  hold on; plot( epiB(:,2), epiB(:,1),'r.','MarkerSize',1);
%     %                  [new_epicardium, new_epiB] = segEpicardium3( subI, double(endocardium), epicardium, endobestFits, slice);
%     %                  ; hold on; plot( new_epiB(:,2), new_epiB(:,1),'g.','MarkerSize',1);  
%     %                  epiAPD(slice) = calAPD ( new_epicardium ,mannualEpi) * info.PixelSpacing(2);
%     %                  disp('resegment epicardium...');
%     %                  [endoAPD(slice)           epiAPD(slice)]
%     %             end
%     %         end
%     
%         end
%         
% %         %%%%%write auto segmentation results%%%%%%%%%%%
% %         B = bwboundaries (endocardium);        
% %         if ~isempty (B)     
% %             endoB = fliplr(B{1});  
% %             autoIContoursFilename = [pathName 'fcn4s_Eval-500-MCCAI2009-30\' caseName '\contours-auto\Auto1\IM-0001-' t(12:15) '-icontour-auto.txt'];
% %             dlmwrite (autoIContoursFilename, endoB, ' ');
% %         end
% %         B = bwboundaries (epicardium);        
% %         if ~isempty (B)     
% %             epiB = fliplr(B{1});  
% %             autoOContoursFilename = [pathName 'fcn4s_Eval-500-MCCAI2009-30\' caseName '\contours-auto\Auto1\IM-0001-' t(12:15) '-ocontour-auto.txt'];
% %             dlmwrite (autoOContoursFilename, epiB, ' ');
% %         end
%         
%         %calculate APD
%         
%         endoAPD(slice) = calAPD (  endocardium ,mannualEndo) * info.PixelSpacing(1);
%         endoAPD(slice)
%         if FlagOContour 
%             epiAPD(slice) = calAPD ( epicardium ,mannualEpi) * info.PixelSpacing(2);
%             epiAPD(slice)
%         end
 
end 

% endoAPDmean = mean ( endoAPD( find(endoAPD~=0 )))
% epiAPDmean = mean ( epiAPD( find(epiAPD~=0 & epiAPD >0)))
% % save MICCAI2009results endoAPD epiAPD

