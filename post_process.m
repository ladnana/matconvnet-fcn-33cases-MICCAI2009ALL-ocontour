 % delete small regions
        [L,num]  = bwlabel ( I, 8);
        if num>1
            %find the biggest area
            areas = zeros(1,num);
            for k=1:num
                areas(k) = sum(sum(L==k));  
            end
            [~,ind]=max(areas);
            %set redundant area value 0
            index = find ( L == ind );
        else
            index = find( I );
        end    

        I2 = uint8(zeros(size(I)));
        I2(index) = I(index) ;
        
        endocardium = uint8(zeros(size(I)));
        endocardium ( find (I2==1) ) = 1;
        epicardium = uint8(zeros(size(I)));
        epicardium ( find (I2==2) ) = 2;


        %%%%%%%%%%%%%%%%%%%%%
        if length(find(I2==1)) < 500            areaTh = 0;
            se2 = strel('disk',1);
        else
            areaTh = 50;
            se2 = strel( 'disk',10);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%processing endocardium%%%%%%%%%%%%%%%%%%%%%%
        %delete small parts
        endocardium = bwareaopen (  endocardium, areaTh);
        %fill holes
        endocardium = imfill (endocardium,'hole');
        %cut small corners
        endocardium = imopen ( endocardium, se2 );