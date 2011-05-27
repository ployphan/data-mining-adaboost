function [v] = HOG(bmag,btheta,wcell)


global param

h = 1;

for cx = 1:wcell:size(bmag,1)
    for cy = 1:wcell:size(btheta,2)
        
        bin(h,:) = myhist(bmag(cx:cx+wcell-1,cy:cy+wcell-1),btheta(cx:cx+wcell-1,cy:cy+wcell-1),param.feature.hog.nbins);
        h = h + 1;
    end
end

% perform L2-norm
v = bin(:);

if sum(v(:))

    v = v./sqrt(sum(v.^2));

end

% % perform L1-norm
% v = abs(bin(:));
% 
% if sum(v(:))
% 
%     v = v./sum(v(:));
% 
% end