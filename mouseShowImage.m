function mouse_keypress_test()
clc
close all
clear all

inputDir = 'H:/nana/data/33cases_MICCAI2009/dealDCMImages128/';

                                
% set(gcf,'WindowButtonDownFcn',@ButttonDownFcn);
set(gcf,'windowkeypressfcn',@keypressfcn,'userdata',[inputDir,569]);
set(gcf,'windowkeyreleasefcn',@keyreleasefcn);

end


function keypressfcn(src,event)
    str = (get(gcf,'userdata'));
    inputDir = str(1:length(str)-1);
    i = double(str(length(str)));
    img_path_list = dir(strcat(inputDir,'*.dcm'));%获取该文件夹中所有dcm格式的图像  
    img_num = length(img_path_list);%获取图像总数量  
    name = img_path_list(i).name;
    display(['show: ' name]);
    I = dicomread(fullfile(inputDir, name));
    imshow(I,'DisplayRange',[]);
    title(name);
    if double(get(gcf,'CurrentCharacter')) == 30  %键盘的↑
        i = i - 1;
        if i < 1
            %信息对话框
            msgbox('这是第一张图片','提示','warn');
            return;
        end
    elseif double(get(gcf,'CurrentCharacter')) == 31 %键盘的↓
        i = i + 1;
        if i > img_num
            %信息对话框  
            msgbox('这是最后一张图片','提示','warn');  
            return;
        end
    end
    name = img_path_list(i).name;
    display(['show: ' name]);
    inputPath = fullfile(inputDir,name) ;
    I = dicomread(inputPath);
    imshow(I,'DisplayRange',[0 255]);
    title(name);
    set(gcf,'userdata',[inputDir,i]);
    
%     if isempty(pureStatus)
%         display(inputPath1);
%         display(inputPath2);
%         data_i = dlmread(inputPath1);
%         data_o = dlmread(inputPath2);
%         hold all;
%         plot(data_i(:,1),data_i(:,2),'g-',data_o(:,1),data_o(:,2),'r-');
%         display(fullfile(Imagedata, [name '.dcm']));
%         I = dicomread(fullfile(Imagedata, [name '.dcm']));
%         subplot(1,2,1);
%         imshow(I, 'DisplayRange',[]);
%         title(strcat(name,'.dcm'));
%     else
%         display(inputPath1);
%         data_i = dlmread(inputPath1);
%         hold all;
%         plot(data_i(:,1),data_i(:,2),'g-');
%         display(fullfile(Imagedata, [name '.dcm']));
%         I = dicomread(fullfile(Imagedata, [name '.dcm']));
%         subplot(1,2,1);
%         imshow(I, 'DisplayRange',[]);
%         title(strcat(name,'.dcm'));
%     end
end

function keyreleasefcn(src,event)

end