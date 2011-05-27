function construct_test()

%% INITIALIZATION
% *************************************************************************

global param


%% CONSTRUCT TEST SET
% *****************************************************************
for img_n = 1:param.test.sz_dataset
    
    filename = param.test.filenames{img_n};
    
    %% REMOVE TRUE EXAMPLES THAT HIT FRAME
    % *****************************************************************
    
    img_filename = ['.\' filename '\input\' filename 's.pgm'];
    img = single(imread(img_filename));
    
    examples_filename = ['..\..\conversion\' filename '.mat'];
    
    present = dir(examples_filename);
    
    if (~isempty(present))
        
        load(examples_filename)
        
        load_msg = sprintf('>> file %s was loaded',examples_filename);
        disp(load_msg);
    else
        error('object file does not exist');
        
    end
    
    obj_index = [obj.index];
    obj_cx = [obj.PixMeanX];
    obj_cy = [obj.PixMeanY];
    % obj_d = param.dstep*round(param.dratio.*[obj.PixDiameter]/param.dstep);
    obj_d = [obj.PixDiameter];
    obj_r_box = param.dratio.*[obj.PixDiameter]/2;
    
    % remove examples that hit the frame (or dmax < d < dmin)
    index = (obj_d >= param.test.dmin) & (obj_d <= param.test.dmax) & (obj_cx+obj_r_box<=size(img,2)) & (obj_cy+obj_r_box<=size(img,1)) & (obj_cx-obj_r_box > 0) & (obj_cy-obj_r_box > 0);
    
    obj_index = obj_index(index);
    obj_cx = obj_cx(index);
    obj_cy = obj_cy(index);
    obj_r = obj_r_box(index);
    
    if size(obj_index,1) == 0
        error('>> no objects available for this search range')
    end
    
    % for Haar,
    % ii = integralImage_v2(img);
    
    % for HOG,
    [gradX,gradY] = gradient(img,param.feature.hog.hx,param.feature.hog.hy);
    
    mag = sqrt(gradX.^2 + gradY.^2);
    
    theta = atan(gradY./gradX);
    
    clear gradX gradY
    
    % for all objects
    for i = 1:size(obj_index,2)
        
        % Geometric features
        if param.feature.geom.go
            
            features_geom = [obj(obj_index(i)).BrightLength; obj(obj_index(i)).Distance;...
                obj(obj_index(i)).AreaRatio; obj(obj_index(i)).BrightElongation;...
                obj(obj_index(i)).DarkElongation; obj(obj_index(i)).BothElongation;...
                obj(obj_index(i)).Dissimilarity; obj(obj_index(i)).Circularity;...
                obj(obj_index(i)).Hu1; obj(obj_index(i)).Hu2; obj(obj_index(i)).Hu3; ...
                obj(obj_index(i)).Hu4; obj(obj_index(i)).Hu5; obj(obj_index(i)).Hu6;...
                obj(obj_index(i)).Hu7];
            
        else
            features_geom = [];
        end
        
        % Haar-like features
        if param.feature.haar.go
            
            block = img(obj_cy(i)-obj_r(i)+1:obj_cy(i)+obj_r(i),obj_cx(i)-obj_r(i)+1:obj_cx(i)+obj_r(i));
            block = block_resize(block);
            features_haar = Haar(block);
            % features_haar = Haar_v2(ii,obj_cx(i),obj_cy(i),obj_r(i));
            
        else
            features_haar = [];
        end
        
        % Histogram of gradients
        if param.feature.hog.go
            
            mblock = mag(obj_cy(i)-obj_r(i)+1:obj_cy(i)+obj_r(i),obj_cx(i)-obj_r(i)+1:obj_cx(i)+obj_r(i));
            mtheta = theta(obj_cy(i)-obj_r(i)+1:obj_cy(i)+obj_r(i),obj_cx(i)-obj_r(i)+1:obj_cx(i)+obj_r(i));
            
            mblock = block_resize(mblock);
            mtheta = block_resize(mtheta);
            
            features_hog = HOG(mblock,mtheta,param.feature.hog.wcell);
            
        else
            features_hog = [];
        end
        
        features(:,i) = [features_geom; features_haar; features_hog];
    end
    
    locations = [obj_cx' obj_cy' obj_r'];
    index = obj_index';
    
    % SHOW TRAIN SET
    % *****************************************************************
    
    figure, imshow(img,[]), hold on,
    for k = 1:length(index)
        
        rectangle('Position',[locations(k,1)-locations(k,3), locations(k,2)-locations(k,3), 2*locations(k,3), 2*locations(k,3)],'EdgeColor','r'),
        
    end
    
    pause(1), close all,
    
    %% RECORD DATA
    test(img_n).id = filename;
    test(img_n).x = features';
    test(img_n).locs = locations;
    test(img_n).index = index;
    
    clear features locations
    
end

%% SAVE DATA

if ~isdir(param.test.path)
    mkdir(param.test.path)
end

% register filename with timestamp
testset_filename = [param.test.path param.time '.mat'];

save(testset_filename,'test');

fprintf(1,'>> test set %s generated and saved\n',testset_filename);
