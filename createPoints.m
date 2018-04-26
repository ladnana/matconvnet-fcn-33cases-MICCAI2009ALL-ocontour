clc;clear;

expDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror';
inputDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009-123+132-i_50-1_2lr_4scaleLoss+2upshape+2.0-1.5-1_3dshape+2mshape-HVmirror/filling_result';
imdbPath = fullfile(expDir, 'imdb.mat') ;
% resPath = fullfile(expDir, 'results_processed.mat') ;

imdb = load(imdbPath) ;
val = find(imdb.images.set == 2 & imdb.images.segmentation) ;

X=cell(30,2);
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

for j=1:numel(val)
   
    imId = val(j) ;
    name = imdb.images.name{imId} ;
    display(['Processing: ' name]);
    inputPath = fullfile(inputDir, [name '.png']) ;
    prefix = name(1:10);
    suffix = name(12:15);
    index = find(strcmp(X , prefix));
    if ~isempty(index)
        folder = X{index,2};
        outputPathPrefix = fullfile(expDir,'Points',folder,'contours-auto','Auto1') ;
        if ~exist(outputPathPrefix) 
            mkdir(outputPathPrefix);
        end
        purePath = 'H:/nana/data/icontour_pure.txt' ;
        pureNames = textread(purePath, '%s') ;
        pureStatus = find(strcmp(pureNames,name));
        
        outputPath1 = fullfile(outputPathPrefix,['IM-0001-' suffix '-icontour-auto.txt']);
        outputPath2 = fullfile(outputPathPrefix,['IM-0001-' suffix '-ocontour-auto.txt']);

        saveResults=1;
        input = imread(inputPath);

        if ~isempty(pureStatus)
            %only get icontour boundaries
            inputI = input;
            inputI(inputI==2)=0;
            BWI = im2bw(inputI, graythresh(inputI));
            BI = bwboundaries(BWI);
            [num,~]=size(BI);
            if num == 1
                boundariesI = BI{1};
            elseif num>1
                max_index=1;
                [max_size,~]=size(BI{1});
                for i=2:num
                    [sizei,~]=size(BI{i});
                    if sizei>max_size
                        max_size=sizei;
                        max_index=i;
                    end
                end
                boundariesI = BI{max_index};
            else
                saveResults=0;
            end
            
            %save only icontour boundaries
            if saveResults==1

                [numi,~]=size(boundariesI);
                fidi=fopen(outputPath1,'w');
                for i=1:numi
                    fprintf(fidi,'%g %g\n',boundariesI(i,2),boundariesI(i,1));%21or12
                end
                fclose(fidi); 
                %show results
                figure(100) ;clf ;
                imshow(input,[]);
                hold on;plot(boundariesI(:,2),boundariesI(:,1),'r.');
                title(name);
            end
            
        else
            %get icontour boundaries
            inputI = input;
            inputI(inputI==2)=0;
            BWI = im2bw(inputI, graythresh(inputI));
            BI = bwboundaries(BWI);
            [num,~]=size(BI);
            if num == 1
                boundariesI = BI{1};
            elseif num>1
                max_index=1;
                [max_size,~]=size(BI{1});
                for i=2:num
                    [sizei,~]=size(BI{i});
                    if sizei>max_size
                        max_size=sizei;
                        max_index=i;
                    end
                end
                boundariesI = BI{max_index};
            else
                saveResults=0;
            end

            %get ocontour boundaries
            inputO = input;
            BWO = im2bw(inputO, graythresh(inputO));
            BO = bwboundaries(BWO);
            [num2,~]=size(BO);
            if num2 == 1
                boundariesO = BO{1};
            elseif num2>1
                max_index=1;
                [max_size,~]=size(BO{1});
                for i=2:num2
                    [sizei,~]=size(BO{i});
                    if sizei>max_size
                        max_size=sizei;
                        max_index=i;
                    end
                end
                boundariesO = BO{max_index};
            else
                saveResults=0;
            end

            %save icontour&ocontour boundaries
            if saveResults==1

                [numi,~]=size(boundariesI);
                fidi=fopen(outputPath1,'w');
                for i=1:numi
                    fprintf(fidi,'%g %g\n',boundariesI(i,2),boundariesI(i,1));%21or12
                end
                fclose(fidi);

                [numo,~]=size(boundariesO);
                fido=fopen(outputPath2,'w');
                for i=1:numo
                    fprintf(fido,'%g %g\n',boundariesO(i,2),boundariesO(i,1));%21or12
                end
                fclose(fido);
                
                %show results
                figure(100) ;clf ;
                imshow(input,[]);
                hold on;plot(boundariesI(:,2),boundariesI(:,1),'r.');
                hold on;plot(boundariesO(:,2),boundariesO(:,1),'b.');
                title(name);

            end
        end
    end
end
