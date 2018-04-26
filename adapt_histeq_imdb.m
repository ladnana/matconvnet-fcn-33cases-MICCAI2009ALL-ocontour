clc;clear;

imdbPath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_20-1_2lr_2scaleLoss/imdb.mat';
OutputimagesPath = 'H:/nana/data/33cases_MICCAI2009/2009-dcm-clahe';

if ~exist(OutputimagesPath) 
   mkdir(OutputimagesPath); 
end

imdb = load(imdbPath) ;
train = find(imdb.images.set == 1 & imdb.images.segmentation ) ;
for i = 1 : numel(train)
%     if i < 403 ||(i > 657 && i < 925)
%         imagePath = sprintf(imdb.paths.image2, imdb.images.name{train(i)}) ;
%         I = load(imagePath);
%         picture = I.picture;
%         subplot(121);imshow(picture,[]);
%         title('未处理过的原图')
%         idx = strfind(imdb.images.name{train(i)},'_');
%         num1 = str2num(imdb.images.name{train(i)}(idx-2:idx-1));
%         num2 = str2num(imdb.images.name{train(i)}(idx+1:idx+2));
%         if num1 == 5
%             g = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[8 8],'ClipLimit',0.001);
%         elseif num1 == 6 
%             g = double(picture)/ max(double(picture(:)));
%         elseif num1 == 11
%             g = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[4 4],'ClipLimit',0.01);
%         elseif num1 == 20 || num1 == 25 
%             g = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[12 12],'ClipLimit',0.003);
%         elseif num1 == 27|| num1 == 28
%             g = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[6 6],'ClipLimit',0.008);
%         elseif num1 == 29 || num1 == 21 || num1 == 24 || num1 == 31
%             g = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[6 6],'ClipLimit',0.003);
%         else
%             g = adapthisteq(double(picture)/ max(double(picture(:))), 'NumTiles',[8 8],'ClipLimit',0.005);
%         end
%         g = uint8(g * 255);
%         subplot(122);imshow(g,[]);
%         title('自适应直方图均衡处理');
%         
%         picture = g;
%         disp([num2str(train(i)) ' ' imdb.images.name{train(i)} '.mat']);
%         save(fullfile(OutputimagesPath,[imdb.images.name{train(i)} '.mat']),'picture');
% %         pause;
%     else
        imagePath = sprintf(imdb.paths.image, imdb.images.name{train(i)}) ;
        I = dicomread(imagePath);
        subplot(121);imshow(I,[]);
        title('未处理过的原图')

        g = adapthisteq(double(I)/ max(double(I(:))), 'NumTiles', [8 8], 'ClipLimit', 0.005);
        g = uint8(g * 255);
        subplot(122);imshow(g,[]);
        title('自适应直方图均衡处理');
        
%         disp([num2str(train(i)) ' ' imdb.images.name{train(i)} '.dcm']);
%         dicomwrite(g,fullfile(OutputimagesPath,[imdb.images.name{train(i)} '.dcm']));
        pause;
%     end
end

val = find(imdb.images.set == 2 & imdb.images.segmentation ) ;
for i = 1:numel(val)
    imagePath = sprintf(imdb.paths.image, imdb.images.name{val(i)}) ;
    I = dicomread(imagePath);
    subplot(121);imshow(I,[]);
    title('未处理过的原图')
    
    g = adapthisteq(double(I)/ max(double(I(:))), 'NumTiles', [8 8], 'ClipLimit', 0.005);
    g = uint8(g * 255);
    subplot(122);imshow(g,[]);
    title('自适应直方图均衡处理');
    
    disp([num2str(val(i)) ' ' imdb.images.name{val(i)} '.dcm']);
    dicomwrite(g,fullfile(OutputimagesPath,[imdb.images.name{val(i)} '.dcm']));
%     pause;
end

