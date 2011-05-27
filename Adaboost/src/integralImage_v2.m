function [ii]=integralImage_v2(img)


ii=zeros(size(img));

for line_x = 1:size(img,2)
    ii(1,line_x) = sum(img(1,1:line_x));
end

for line_y = 2:size(img,1)
    ii(line_y,1) = sum(img(1:line_y,1));
end


for x = 2:size(img,2)
    for y = 2:size(img,1)
        
        ii(y,x) = double(img(y,x)) + ii(y-1,x) + ii(y,x-1) - ii(y-1,x-1);
        
    end
end