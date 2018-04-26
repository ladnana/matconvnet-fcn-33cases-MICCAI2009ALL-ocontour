function output = fillZero(input, bit)

n = input;
sum = 0;
while n ~= 0
    sum = sum + 1;
    n = floor(n/10);
end
sum = bit - sum;
output = '';
while sum ~= 0
    output = strcat(output, '0');
    sum = sum - 1;
end
output = [output, num2str(input)];
end

