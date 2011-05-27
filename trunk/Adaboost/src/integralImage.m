function [ii]=integralImage(i)

ii=zeros(size(i));

for x=1:size(i,1)
    for y=1:size(i,2)
        ii(x,y) = sum(sum(i(1:x,1:y)));
    end
end

