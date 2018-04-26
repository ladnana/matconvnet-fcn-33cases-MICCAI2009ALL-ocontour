clc;clear;

imdbPath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132+20+08-i_1_2scaleLoss_newscaleshape-1_25+2/imdb.mat';
imdbPath2 = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132+20+08-i_1_2scaleLoss_newscaleshape-1_25+2-dealimage/imdb.mat';
OutputimagesPath = 'H:/nana/data/33cases_MICCAI2009/clahe_dealimage';

if ~exist(OutputimagesPath) 
   mkdir(OutputimagesPath); 
end

imdb = load(imdbPath) ;
imdb2 = load(imdbPath2) ;
train = find(imdb.images.set == 1 & imdb.images.segmentation ) ;
train2 = find(imdb2.images.set == 1 & imdb2.images.segmentation ) ;
for i = 1 : numel(train)
    if i < 403 ||(i > 657 && i < 925)
        disp([imdb.images.name{train(i)},'.mat']);
        imagePath = sprintf(imdb.paths.image2, imdb.images.name{train(i)}) ;
        I = load(imagePath);
        picture = I.picture;
        subplot(121);imshow(picture,[]);
        title('未处理过的原图')
        
        imagePath2 = sprintf(imdb2.paths.image2, imdb2.images.name{train2(i)}) ;
        I2 = load(imagePath2);
        picture2 = I2.picture;
        subplot(122);imshow(picture2,[]);
        title('自适应直方图均衡处理');
        
        pause;
    else
        disp([imdb.images.name{train(i)} '.dcm']);
        imagePath = sprintf(imdb.paths.image, imdb.images.name{train(i)}) ;
        I = dicomread(imagePath);
        subplot(121);imshow(I,[]);
        title('未处理过的原图')

        imagePath2 = sprintf(imdb2.paths.image, imdb2.images.name{train2(i)}) ;
        I2 = dicomread(imagePath2);
        subplot(122);imshow(I2,[]);
        title('自适应直方图均衡处理');
        
        pause;
    end
end

val = find(imdb.images.set == 2 & imdb.images.segmentation ) ;
val2 = find(imdb2.images.set == 2 & imdb2.images.segmentation ) ;
for i = 1:numel(val)
    disp([imdb.images.name{train(i)} '.dcm']);
    imagePath = sprintf(imdb.paths.image, imdb.images.name{val(i)}) ;
    I = dicomread(imagePath);
    subplot(121);imshow(I,[]);
    title('未处理过的原图');
    
    imagePath2 = sprintf(imdb2.paths.image, imdb2.images.name{val2(i)}) ;
    I2 = dicomread(imagePath2);
    subplot(122);imshow(I2,[]);
    title('自适应直方图均衡处理');
    
    pause;
end

