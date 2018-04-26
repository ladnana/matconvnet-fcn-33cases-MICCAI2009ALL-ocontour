
Outputpath = 'H:/nana/data/fcn4s-100-33cases_MICCAI2009_test/';

colormap=zeros(3,3);
colormap(2,1)=1;
colormap(3,3)=1;

X=cell(30,1);
X{1, 1}='SCD0000401'; 
X{2, 1}='SCD0000501'; 
X{3, 1}='SCD0000601'; 
X{4, 1}='SCD0000701'; 
X{5, 1}='SCD0001501'; 
X{6, 1}='SCD0001601'; 
X{7, 1}='SCD0002101'; 
X{8, 1}='SCD0002201'; 
X{9, 1}='SCD0002701'; 
X{10,1}='SCD0002801';
X{11,1}='SCD0002901'; 
X{12,1}='SCD0003401'; 
X{13,1}='SCD0003901';
X{14,1}='SCD0004001'; 
X{15,1}='SCD0004101';

for k = 1 :15
    file_path = fullfile(Outputpath,X{k});
    mat_path_list = dir(strcat(file_path,'*.mat'));
    mat_num = length(mat_path_list);
    for i = 1 : mat_num
        Outputs = fullfile(file_path, mat_path_list(i).name(1:end-4));
        if ~exist(Outputs)
            mkdir(Outputs);
        end
        mat_file = fullfile(file_path, mat_path_list(i).name);
        m = load(mat_file);
        temp = m.temp;
        sz = size(temp);
        width = sz(1);
        pad = width / 16;
        if sz(end) == 64 || sz(end) == 128
            mul = 8;
        elseif sz(end) == 256 || sz(end) == 512
            mul = 16;
        elseif sz(end) == 4096
            mul = 64;
        end
        if pad < 1
            pad = 1;
        end
        w = width + pad;
        if sz(end)~= 3
            %         big = uint8(zeros(mul * w,(sz(end)/mul) * w));
            big = uint8(zeros((sz(end)/mul) * w,mul * w));
        else
            %         big = uint8(zeros(3 * w,w));
            big = uint8(zeros(w,3 * w));
        end
        for j = 1 : sz(end)
            I = temp(:,:,j);
            I = uint8(Normalize(I));
            name = strcat(num2str(j),'.png');
            l =  mod(j,mul);
            n =  fix(j / mul);
            %         if sz(end) ~= 3
            %             subplot(l,8,j); imshow(I,[]);
            %         elseif sz(end) == 3
            %             subplot(1,3,j); imshow(I,[]);
            %         end
            fillimage = padarray(I,[pad pad],255,'post');
            if( l == 0)
                l = mul;
                n = n - 1;
            end
            %         big((l - 1) * w + 1:l * w,n * w + 1:(n + 1) * w) = fillimage;
            big(n * w + 1:(n + 1) * w,(l - 1) * w + 1:l * w) = fillimage;
            imwrite(I,fullfile(Outputs,name),'png');
        end
        big = padarray(big,[pad pad],255,'pre');
        name = strcat(mat_path_list(i).name(1:end-4),'.png');
        imwrite(big,fullfile(Outputs, name),'png');
        %     saveas(gca,fullfile(Outputs, mat_path_list(i).name(1:end-4)),'png')
        %     if(strcmp(mat_path_list(i).name,'pool1')
        %         for k = 1 : 64
        % %             l =  mod(k,8)
        % %             n =  int(k / 8) + 1;
        %             subplot(8,8,k); imshow(fullfile(Outputs,name),'png')
        %     end
    end
end

function OutImg = Normalize(InImg)  
    ymax=255;ymin=0;
    xmax = max(max(InImg)); %求得InImg中的最大值
    xmin = min(min(InImg)); %求得InImg中的最小值
    OutImg = round((ymax-ymin)*(InImg-xmin)/(xmax-xmin) + ymin); %归一化并取整
end  