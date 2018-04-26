clc;clear;

expDir = 'data/fcn4s-500-33cases_MICCAI2009/Points2';
inDir = 'E:\mR\大学\学习\毕业设计\IMAGE SEG\Fully Convolutional Networks for Semantic Segmentation\MCCAI2009\challenge_validation';%challenge_validation challenge_online

X=cell(30,1);
X{1, 1}='SCD0000401'; X{1, 2}='SC-HF-I-05';
X{2, 1}='SCD0000501'; X{2, 2}='SC-HF-I-06';
X{3, 1}='SCD0000601'; X{3, 2}='SC-HF-I-07';
X{4, 1}='SCD0000701'; X{4, 2}='SC-HF-I-08';
X{5, 1}='SCD0001501'; X{5, 2}='SC-HF-NI-07';
X{6, 1}='SCD0001601'; X{6, 2}='SC-HF-NI-11';
X{7, 1}='SCD0002101'; X{7, 2}='SC-HF-NI-31';
X{8, 1}='SCD0002201'; X{8, 2}='SC-HF-NI-33';
X{9, 1}='SCD0002701'; X{9, 2}='SC-HYP-06';
X{10,1}='SCD0002801'; X{10,2}='SC-HYP-07';
X{11,1}='SCD0002901'; X{11,2}='SC-HYP-08';
X{12,1}='SCD0003401'; X{12,2}='SC-HYP-37';
X{13,1}='SCD0003901'; X{13,2}='SC-N-05';
X{14,1}='SCD0004001'; X{14,2}='SC-N-06';
X{15,1}='SCD0004101'; X{15,2}='SC-N-07';
X{16, 1}='SCD0000801'; X{16, 2}='SC-HF-I-09';
X{17, 1}='SCD0000901'; X{17, 2}='SC-HF-I-10';
X{18, 1}='SCD0001001'; X{18, 2}='SC-HF-I-11';
X{19, 1}='SCD0001101'; X{19, 2}='SC-HF-I-12';
X{20, 1}='SCD0001701'; X{20, 2}='SC-HF-NI-12';
X{21, 1}='SCD0001801'; X{21, 2}='SC-HF-NI-13';
X{22, 1}='SCD0001901'; X{22, 2}='SC-HF-NI-14';
X{23, 1}='SCD0002001'; X{23, 2}='SC-HF-NI-15';
X{24, 1}='SCD0003001'; X{24, 2}='SC-HYP-09';
X{25,1}='SCD0003101'; X{25,2}='SC-HYP-10';
X{26,1}='SCD0003201'; X{26,2}='SC-HYP-11';
X{27,1}='SCD0003301'; X{27,2}='SC-HYP-12';
X{28,1}='SCD0004201'; X{28,2}='SC-N-09';
X{29,1}='SCD0004301'; X{29,2}='SC-N-10';
X{30,1}='SCD0004401'; X{30,2}='SC-N-11';

for i=1:15
    display(['Processing: ' X{i,2}]);
    manualDir = fullfile(inDir,X{i,2});
    expLabelsDir = fullfile(expDir,X{i,2},'contours-manual\IRCCI-expert');
    expImagesDir = fullfile(expDir,X{i,2},'DICOM');
    if ~exist(expLabelsDir) 
        mkdir(expLabelsDir);
    end
    if ~exist(expImagesDir) 
        mkdir(expImagesDir);
    end
    for j=1:300
        labelPath = fullfile(manualDir,'3D_20frames_all_points',['IM-0001-', fillZero(j, 4)]);
        labelPath1 = [labelPath '-icontour-manual.txt'];
        labelPath2 = [labelPath '-ocontour-manual.txt'];
        labelPath3 = [labelPath '-p1contour-manual.txt'];
        labelPath4 = [labelPath '-p2contour-manual.txt'];
        
        imagePathP = fullfile(manualDir,'3D_20frames_all_points',['CAP_', X{i,1} ,'_MR__hrt_raw_']);
        imagePath = [imagePathP num2str(j) '.dcm'];
        if exist(labelPath1, 'file')&& exist(labelPath2, 'file')
            labels1 = fullfile(expLabelsDir,['IM-0001-', fillZero(j, 4),'-icontour-manual.txt']);
            copyfile(labelPath1,labels1);
            labels2 = fullfile(expLabelsDir,['IM-0001-', fillZero(j, 4),'-ocontour-manual.txt']);
            copyfile(labelPath2,labels2);
        end
%         if exist(labelPath2, 'file')
%             labels2 = fullfile(expLabelsDir,['IM-0001-', fillZero(j, 4),'-ocontour-manual.txt']);
%             copyfile(labelPath2,labels2);
%         end
        if exist(labelPath3, 'file')
            labels3 = fullfile(expLabelsDir,['IM-0001-', fillZero(j, 4),'-p1contour-manual.txt']);
            copyfile(labelPath3,labels3);
        end
        if exist(labelPath4, 'file')
            labels4 = fullfile(expLabelsDir,['IM-0001-', fillZero(j, 4),'-p2contour-manual.txt']);
            copyfile(labelPath4,labels4);
        end
        if exist(imagePath, 'file')
            images =  fullfile(expImagesDir,['IM-0001-', fillZero(j, 4),'.dcm']);
            copyfile(imagePath,images);
        end        
    end
    
end
