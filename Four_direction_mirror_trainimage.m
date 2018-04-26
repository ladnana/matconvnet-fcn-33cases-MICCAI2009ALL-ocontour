clc;clear;

inputimagesPath = 'H:/nana/data/33cases_MICCAI2009/CropDCMImages-1+1.2+2+132+08+2shape/';
inputlabelsPath = 'H:/nana/data/33cases_MICCAI2009/CropSegmentationClass-1+1.2+2+132+08+2shape/';
mirrorimagesPath = 'H:/nana/data/33cases_MICCAI2009/CropDCMImages-1+1.2+2+132+08+2shape_allmirror/';
mirrorlabelsPath = 'H:/nana/data/33cases_MICCAI2009/CropSegmentationClass-1+1.2+2+132+08+2shape_allmirror/';

if ~exist(mirrorimagesPath) 
   mkdir(mirrorimagesPath); 
end
if ~exist(mirrorlabelsPath) 
   mkdir(mirrorlabelsPath); 
end

img_path_list = dir(inputimagesPath);%��ȡ���ļ�����ÿ��case��ͼ��

for i = 3:length(img_path_list)
    %create croped images
    if i > 155 && i < 825
        imagePath = img_path_list(i).name;
        I = load([inputimagesPath imagePath]);
        picture = I.picture;
        save(fullfile(mirrorimagesPath,imagePath),'picture');
        subplot(221);imshow(picture,[]);title([img_path_list(i).name 'ԭͼ']);
        
        picture = picture(end:-1:1,:);  %vertical mirror
        save(fullfile(mirrorimagesPath,['V-' imagePath]),'picture');
        subplot(222);imshow(picture,[]);title('��ֱ����');
        
        picture = I.picture;
        picture = picture(:,end:-1:1);     % horizontal mirror
        save(fullfile(mirrorimagesPath,['H-' imagePath]),'picture');
        subplot(223);imshow(picture,[]);title('ˮƽ����');
        
        picture = I.picture;
        picture = picture(end:-1:1,end:-1:1);     % horizontal mirror
        save(fullfile(mirrorimagesPath,['HV-' imagePath]),'picture');
        subplot(224);imshow(picture,[]);title('�ԽǾ���');
        
%         pause;
        
    else
        imagePath = img_path_list(i).name;
        I = dicomread([inputimagesPath imagePath]);
        dicomwrite(I,fullfile(mirrorimagesPath,imagePath));
        subplot(221);imshow(I,[]);title('ԭͼ');
        
        I1 = I(end:-1:1,:);
        dicomwrite(I1,fullfile(mirrorimagesPath,['V-' imagePath]));
        subplot(222);imshow(I1,[]);title('��ֱ����');
        
        I2 = I(:,end:-1:1);
        dicomwrite(I2,fullfile(mirrorimagesPath,['H-' imagePath]));
        subplot(223);imshow(I2,[]);title('ˮƽ����');
        
        I3 = I(end:-1:1,end:-1:1);
        dicomwrite(I3,fullfile(mirrorimagesPath,['HV-' imagePath]));
        subplot(224);imshow(I3,[]);title('�ԽǾ���');
%         pause;
        
    end    
    %create croped labels
    labelsPath = [imagePath(1:length(imagePath)-4) '.png'];
    [p,map] = imread([inputlabelsPath labelsPath]);
    imwrite(p,map,fullfile(mirrorlabelsPath,labelsPath));
    subplot(221);imshow(p,map);title('ԭͼ');
    
    p1 = p(end:-1:1,:);
    imwrite(p1,map,fullfile(mirrorlabelsPath,['V-' labelsPath]));
    subplot(222);imshow(p1,map);title('��ֱ����');
    
    p2 = p(:,end:-1:1);
    imwrite(p2,map,fullfile(mirrorlabelsPath,['H-' labelsPath]));
    subplot(223);imshow(p2,map);title('ˮƽ����');
    
    p3 = p(end:-1:1,end:-1:1);
    imwrite(p3,map,fullfile(mirrorlabelsPath,['HV-' labelsPath]));
    subplot(224);imshow(p3,map);title('�ԽǾ���');
%     pause;
    
    
end


