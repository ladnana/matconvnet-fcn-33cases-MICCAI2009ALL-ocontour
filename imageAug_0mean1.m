clc;clear;

inputimagePath = 'H:/nana/data/33cases_MICCAI2009/2009-dcm/';
OutputimagesPath = 'H:/nana/data/33cases_MICCAI2009/2009-dcm-0mean1/';

if ~exist(OutputimagesPath) 
   mkdir(OutputimagesPath); 
end

img_path_list = dir([inputimagePath '*.dcm']);%��ȡ���ļ�����ÿ��case��ͼ��

for i = 1:length(img_path_list)
    %create croped images
    imagePath = img_path_list(i).name;
    I = dicomread([inputimagePath imagePath]);
    subplot(121);imshow(I,[]);
    
    I = double(I);
    tsubI = (I - mean(I(:)))/std(I(:),0,1);
    tsubI( find(tsubI>3)) = 3;
    tsubI( find(tsubI<-3)) = -3;
    tsubI = (tsubI+3)/6;
    tsubI = imadjust( tsubI, [min(tsubI(:)) max(tsubI(:))], [0 1]);
    tsubI = uint8(tsubI * 255);
    subplot(122);imshow(tsubI,[]);
    title('���ֵ��һ');
    image_name = imagePath;
    idx = strfind(image_name,'_');
    num = image_name(idx-4:idx-1);
    if str2num(num) == 4201 || str2num(num) == 3401 || str2num(num) == 1901 || str2num(num) == 4001
        tsubI = rot90(tsubI,3);
    end
%      pause;
    dicomwrite(tsubI,fullfile(OutputimagesPath,imagePath));
end
