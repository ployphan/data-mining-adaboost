function features = Haar_v2(ii,cx,cy,cr)


z = 1;

features = [];

npoints = 8;
theta = 0 : (2 * pi / npoints) : (2 * pi);

block_size = cr/4;

for k = 1:3
    
    r(k) = k*cr/4;
    
    circle_x = r(k) * cos(theta) + cx;
    circle_y = r(k) * sin(theta) + cy;
    
    for w = 1:npoints
        
        points = extract_block(ii,circle_x(w),circle_y(w),block_size);

        features(z,:) = get_feat_v2(points,block_size);
            
        z = z + 1;
    end
end

features = reshape(features,size(features,1)*size(features,2),1);

% features
% size(features), pause