clc;clear;

imdbPath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009_128_1.25dimension/imdb.mat';
cropimagesPath = 'H:/nana/data/33cases_MICCAI2009/bilinearImages_dealinitimage';
croplabelsPath = 'H:/nana/data/33cases_MICCAI2009/bilinearSegmentationClass_2';

imdb = load(imdbPath) ;
colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;
sz = find(imdb.images.segmentation) ;

for i = 757:numel(sz)
    %create croped images
    if i < 757 
        imagePath = sprintf(imdb.paths.image2, imdb.images.name{i}) ;
        I = load(imagePath);
        picture = I.picture;
        picture = imresize(picture,2,'bilinear');
        [m,n] = size(picture);
        for j = 2 : m - 1 
            for k = 2 : n - 1
                logical = picture(j-1:j+1,k-1:k+1);
                if ~all(logical(:)) && picture(j,k) == 1
                    picture(j,k) = 2;
                end
            end
        end
%         picture = imcrop(picture,[64,64,127,127]);
        filename = fullfile(cropimagesPath,[imdb.images.name{i} '.mat']);
        save(fullfile(cropimagesPath,[imdb.images.name{i} '.mat']),'picture');
    else
        imagePath = sprintf(imdb.paths.image, imdb.images.name{i}) ;
        I = dicomread(imagePath);
%         t = imcrop(I,[64,64,127,127]);
        t = imresize(I,2,'bilinear');
        [m,n] = size(t);
        for j = 2 : m - 1
            for k = 2 : n - 1
                logical = t(j-1:j+1,k-1:k+1);
                if ~all(logical(:)) && t(j,k) == 1
                    t(j,k) = 2;
                end
            end
        end
        dicomwrite(final_output2,fullfile(cropimagesPath,[imdb.images.name{i} '.dcm']));
    end    
    %create croped labels
    labelsPath = sprintf(imdb.paths.classSegmentation, imdb.images.name{i}) ;
    I2 = imread(labelsPath);
%     t2 = imcrop(I2,[64,64,127,127]);
    t2 = imresize(I2,2,'bilinear');
    [m,n] = size(t2);
    for j = 2 : m - 1
        for k = 2 : n - 1
            logical = t2(j-1:j+1,k-1:k+1);
            if ~all(logical(:)) && t2(j,k) == 1
                t2(j,k) = 2;
            end
        end
    end
    imwrite(t2,colormap,fullfile(croplabelsPath,[imdb.images.name{i} '.png']));
end
