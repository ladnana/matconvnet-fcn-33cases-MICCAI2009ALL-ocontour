
% Hausdroff distance between two point sets

function Hdist=HausdroffDist(scene,pos,flag)

dist=0;
ddd=8;
dist = zeros( 1, size(scene, 1));
if isempty (dist) 
    Hdist = 0; 
else

    for i=1:size(scene,1)
        p=scene(i,:);
        xmin=p(1,1)-ddd;
        xmax=p(1,1)+ddd;
        ymin=p(1,2)-ddd;
        ymax=p(1,2)+ddd;
        A=find( xmin<pos(:,1)&pos(:,1)<xmax & ymin<pos(:,2) & pos(:,2)<ymax  );  %  
        d=sqrt((pos(A(:),1)-p(1,1)).^2+ (pos(A(:),2)-p(1,2)).^2 );

        if size(d,1)~=0
            dist(i) = dist(i)+min(d(:));
        end
    end
    
    if flag
        Hdist = max(dist);
    else
        Hdist = min(dist);
    end
end