clc;clear;

expDir = 'data/fcn4s-500-33cases_MICCAI2009';
inputDir = 'data/fcn4s-500-33cases_MICCAI2009/segamentation_result';
imdbPath = fullfile(expDir, 'imdb.mat') ;
resPath = fullfile(expDir, 'results_processed.mat') ;

imdb = load(imdbPath) ;
val = find(imdb.images.set == 2 & imdb.images.segmentation) ;
%setup colormap
N=3;
cmap = zeros(N,3);
cmap(2,1) = 1;
cmap(3,3) = 1;

confusion = zeros(3) ;
confusion2 = zeros(3) ;

for i=1:numel(val)
    
    imId = val(i) ;
    name = imdb.images.name{imId} ;
    inputPath = fullfile(inputDir, [name '.png']) ;
    labelsPath = sprintf(imdb.paths.classSegmentation, name) ;
    
    input = imread(inputPath);
    anno = imread(labelsPath) ;
    lb = single(anno) ;
    lb = mod(lb + 1, 256) ; % 0 = ignore, 1 = bkg
    
    [L, num] = bwlabel(input,8);
    output = input;
    
    if num>1
        %find the biggest area
        areas = zeros(1,num);
        for k=1:num
            areas(k) = sum(sum(L==k));  
        end
        
        [~,ind]=max(areas);
      
        %set redundant area value 0
        for l=1:num
            if l ~= ind
                [x,y] = find(L == l);
                for j=1:numel(x)
                    output(x(j),y(j))=0;    
                end
            end
        end
        
    end
    output = mod(output + 1, 256) ; % 0 = ignore, 1 = bkg
    % Accumulate errors
    ok = lb > 0 ;
    confusion2 = confusion2 + accumarray([lb(ok),output(ok)],1,[3 3]) ;%edited by mR
    confusion = accumarray([lb(ok),output(ok)],1,[3 3]) ;%edited by mR
    clear info ;
    clear info2 ;
    [info.iu, info.miu, info.pacc, info.macc] = getAccuracies(confusion) ;
    [info2.iu, info2.miu, info2.pacc, info2.macc] = getAccuracies(confusion2) ;%edited by mR
    fprintf('IU ') ;
    fprintf('%4.1f ', 100 * info.iu) ;
    fprintf('\n meanIU: %5.2f pixelAcc: %5.2f, meanAcc: %5.2f\n', ...
            100*info.miu, 100*info.pacc, 100*info.macc) ;
        
%     diary(fullfile('data/fcn2s-500-33cases_MICCAI2009', 'info_processed.txt')); 
%     disp([name,' ',num2str(info.iu(2)),' ',num2str(info.iu(3)),' ',num2str(info.pacc),' ',num2str(info.macc)]);%edited by mR
%     diary off;
    
    if ~exist(fullfile(expDir, 'processed_result')) 
        mkdir(fullfile(expDir, 'processed_result'));
    end
    imPath = fullfile(expDir, 'processed_result', [name '.png']) ;
    imwrite((output-1),cmap,imPath,'png');
    
end

save(resPath, '-struct', 'info2') ;