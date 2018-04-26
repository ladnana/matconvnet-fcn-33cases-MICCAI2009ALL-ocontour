[I,map] = imread('SCD0000001_0804.png');
[m,n] = size(I);
for j = 2 : m - 1
    for k = 2 : n - 1 
        logical = I(j-1:j+1,k-1:k+1);
        if ~all(logical(:)) && I(j,k) == 1
            I(j,k) = 2;
        end
    end
end
imwrite(I,map,'1.png');