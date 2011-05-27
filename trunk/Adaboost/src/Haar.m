function feature = Haar(img)


global param

s = [param.feature.block_sz/4 param.feature.block_sz/2 param.feature.block_sz/4+param.feature.block_sz/2 param.feature.block_sz];

% method to choose size intervals:
%
% L = min(size(img));
% 
% Lmin = L/3;
% Lmax = L;
% step = L/6;
% 
% n = 4;
% 
% alfa = (Lmax/Lmin)^(1/(n-1));
% 
% s(1) = Lmin;
% 
% for i = 1:n-1
%      s(i+1) = 2*floor(((alfa^i)*Lmin+1)/2);
% end

k = 0;

% integral image

% ii = integralImage(img,0,0);
ii = integralImage(img);

% w: window sizes
for w = 1:4
    step = s(w)/3;
    for i = 1:step:param.feature.block_sz-s(w)+1
        for j = 1:step:param.feature.block_sz-s(w)+1

            k = k + 1;

            features_2 = get_feat(ii(i:i+s(w)-1,j:j+s(w)-1));
            features_3 = get_feat3(ii(i:i+s(w)-1,j:j+s(w)-1));
            
            feature(k,:) = [features_2 features_3];
            
        end
    end
end

feature = reshape(feature,size(feature,1)*size(feature,2),1);

% features
% size(features), pause