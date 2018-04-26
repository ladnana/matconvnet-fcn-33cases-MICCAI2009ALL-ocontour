clear;
clc;
close all;
imdbPath = 'data/fcn4s-100-33cases_MICCAI2009_128/imdb.mat';

OutputDir = 'data/33cases_MICCAI2009/ReduceMImages/';
Outputpath = 'data/33cases_MICCAI2009/';
file_path =  'data/33cases_MICCAI2009/CropDCMImages/'

if ~exist(fullfile(Outputpath, 'ReduceMImages')) 
   mkdir(fullfile(Outputpath, 'ReduceMImages'));
end

imdb = load(imdbPath) ;
colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;
size = find(imdb.images.segmentation) ;   

 for i = 1:numel(size)
    if i < 757 
        imagePath = sprintf(imdb.paths.image2, imdb.images.name{i}) ;
        I = load(imagePath);
        picture = I.picture;
        picture = padarray(picture, [63 63]);
        picture = padarray(picture,[2 2],'replicate','post');
%         filename = fullfile(cropimagesPath,[imdb.images.name{i} '.mat']);
        save(fullfile(OutputDir,[imdb.images.name{i} '.mat']),'picture');
    else
        imagePath = sprintf(imdb.paths.image, imdb.images.name{i}) ;
        I = dicomread(imagePath);
        t = padarray(I, [63 63]);
        t = padarray(t,[2 2],'replicate','post');
        dicomwrite(t,fullfile(OutputDir,[imdb.images.name{i} '.dcm']));
    end
 end