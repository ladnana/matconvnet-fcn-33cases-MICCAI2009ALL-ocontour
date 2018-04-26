        %%%%%%%%%%%%%%%%%%%%tensor voting%%%%%%%%%%%%%%%%%%%%%%%%
        %tensor voting to guess the missing parts int epicardium
        if caseSlice > 1
            tensor_region = [96,96,64,64];

            tmp_epi = zeros(size(epicardium));
            tmp_epi( find (epicardium==2)) = 1;
            local_epi = imcrop( tmp_epi, tensor_region);
            figure(2);  subplot(221); imshow(local_epi);

            T = read_dot_edge_file(epicardium);
            [e1,e2,l1,l2] = convert_tensor_ev(T);

            % Run the tensor voting framework
            stats = regionprops( endocardium, 'MajorAxisLength', 'MinorAxisLength' ); 
            radius = round((stats.MinorAxisLength + stats.MajorAxisLength)/4);
            sigma = radius/3;
            T = find_features(l1,sigma);

            % Threshold un-important data that may create noise in the
            % output.
            [e1,e2,l1,l2] = convert_tensor_ev(T);
            z = l1-l2;
            l1(z<0.3) = 0;
            l2(z<0.3) = 0;
            
            local_z = imcrop(z, tensor_region);
            figure(2); subplot(222); imshow(local_z,[]);  title('stick tensor');
            
             % Run a local maxima algorithm on it to extract curves
            T = convert_tensor_ev(e1,e2,l1,l2);
            clear  tensorvote;
            re = calc_ortho_extreme(T,radius,pi/8);
            [L,num] = bwlabel( re );
            if num > 1 
                re = bwareaopen (  re, 20);
            end
            
            local_re = imcrop(re, tensor_region);
            figure(2);  subplot(223), imshow(local_re);  title('TV extrem');
            
            % dilate the extreme 
            [ tensorvote(:,1) , tensorvote(:,2) ] = find ( re );
            dist  =HausdroffDist (tensorvote, endoB,1);
            expandre = imdilate ( re, strel('disk', round(dist/2)));
            local_expandre = imcrop(expandre, tensor_region);
            figure(2);  subplot(224); imshow(local_expandre);
            epicardium( find(expandre) ) = 2;

           
        end
