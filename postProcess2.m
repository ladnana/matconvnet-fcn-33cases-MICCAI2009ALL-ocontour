clc;clear;

expDir = 'data/fcn8s-500-MCCAI2009';
inputDir = 'data/fcn8s-500-MCCAI2009/processed_result';
imdbPath = fullfile(expDir, 'imdb.mat') ;
resPath = fullfile(expDir, 'results_processed2_7.mat') ;

imdb = load(imdbPath) ;
val = find(imdb.images.set == 2 & imdb.images.segmentation) ;

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
    
    [X Y] = find(input == 1);
    P = input>0;
    input(P)=1;
    se = strel('sphere',7);
    L = imerode(input,se);
    M = imdilate(L,se);
    P = M>0;
	M(P)=2;
    for i = 1:numel(X)
        if(M(X(i),Y(i))==2)
            M(X(i),Y(i))=1;
        end
    end
    output = M;
    output = mod(output + 1, 256) ; % 0 = ignore, 1 = bkg
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
        
    diary(fullfile('data/fcn8s-500-MCCAI2009', 'info_processed2_7.txt')); 
    disp([name,' ',num2str(info.iu(2)),' ',num2str(info.iu(3)),' ',num2str(info.pacc),' ',num2str(info.macc)]);%edited by mR
    diary off;
    
    if ~exist(fullfile(expDir, 'processed_result2_7')) 
        mkdir(fullfile(expDir, 'processed_result2_7'));
    end
    imPath = fullfile(expDir, 'processed_result2_7', [name '.png']) ;
    imwrite((output-1),cmap,imPath,'png');
    
end

save(resPath, '-struct', 'info2') ;
