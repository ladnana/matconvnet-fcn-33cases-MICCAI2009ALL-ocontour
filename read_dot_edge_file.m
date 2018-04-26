function [ T ] = read_dot_edge_file( contours )
%READ_DOT_EDGE_FILE reads in the file and outputs a tensor
%   field based on the  input.  
%
[h,w ] = size( contours);

[r1,c1] = find( contours ); %epicardium
[r,c] = find( contours ==2); 
n = length ( r );

crow = mean ( r1 );
ccol = mean ( c1 );
buf = zeros( n, 3);
buf(:,1) = r;
buf(:,2) = c;
buf(:,3) = atan2(-r+crow, c-ccol) * 180 / pi;
index = find ( buf(:,3) <0);
buf(index,3) = 360+ buf(index,3);
    
T = zeros(h,w,2,2);
    
%     figure(1); plot(h+1-buf(:,1),buf(:,2),'go');
%buf(:,1), buf(:,2) are cordinate,  buf(:,3) is normal angle in degree
    for i=1:n
        x = cos(buf(i,3)*pi/180 + 90*pi/180);
        y = sin(buf(i,3)*pi/180 + 90*pi/180);
        T(buf(i,1),buf(i,2),1,1) = x^2;
        T(buf(i,1),buf(i,2),1,2) = x*y;
        T(buf(i,1),buf(i,2),2,1) = x*y;
        T(buf(i,1),buf(i,2),2,2) = y^2;
%         figure(1); hold on; plot(h+1-buf(i,1),buf(i,2),'ro');
%         text(h+1-buf(i,1),buf(i,2), num2str(buf(i,3)));
%         pause;
    end
end