function [bin] = myhist(cmag,ctheta,nbins)

ndeg = pi/nbins;

scale = -pi/2:ndeg:pi/2;

for n = 1:nbins

    index = (ctheta >= scale(n)) & (ctheta < scale(n+1));

    bin(n) = sum(sum(index.*cmag));
    % bin_deg(n) = sum(sum(index));
end