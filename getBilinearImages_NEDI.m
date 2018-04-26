clc;clear;

imdbPath = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009_128_1.25dimension/imdb.mat';
cropimagesPath = 'H:/nana/data/33cases_MICCAI2009/bilinearImages_dealinitimage';

imdb = load(imdbPath) ;
colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;
sz = find(imdb.images.segmentation) ;

for i = 1:numel(sz)
    %create croped images
     if i < 757 
        imagePath = sprintf(imdb.paths.image2, imdb.images.name{i}) ;
        I = load(imagePath);
        final_output2 = NEDI(I.picture);
        picture = final_output2;
        filename = fullfile(cropimagesPath,[imdb.images.name{i} '.mat']);
        save(fullfile(cropimagesPath,[imdb.images.name{i} '.mat']),'picture');
    else
        imagePath = sprintf(imdb.paths.image, imdb.images.name{i}) ;
        I = dicomread(imagePath);
        final_output2 = NEDI(I);
        dicomwrite(final_output2,fullfile(cropimagesPath,[imdb.images.name{i} '.dcm']));
    end    
end
