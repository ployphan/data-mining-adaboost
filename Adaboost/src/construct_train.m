function construct_train()


%% INITIALIZATION
% *************************************************************************

global param


%% CONSTRUCT TRAIN SET
% *****************************************************************
for img_n = 1:param.train.sz_dataset
    
    filename = param.train.filenames{img_n};
    
    %% REMOVE TRUE EXAMPLES THAT HIT FRAME
    % *****************************************************************
    
    img_filename = ['.\' filename '\input\' filename 's.pgm']; 
    img = single(imread(img_filename));
    
    examples_filename = ['..\..\conversion\' filename '.mat'];
    
    present = dir(examples_filename);
    
    if (~isempty(present))
        
        load(examples_filename)
        
        fprintf(1,'>> file %s was loaded\n',examples_filename);
    else
        error('object file does not exist');
        
    end
    
    obj_index = [obj.index];
    obj_cx = [obj.PixMeanX];
    obj_cy = [obj.PixMeanY];
    % obj_d = param.dstep*round(param.dratio.*[obj.PixDiameter]/param.dstep);
    obj_d = [obj.PixDiameter];
    obj_r_box = param.dratio.*[obj.PixDiameter]/2;
    obj_class = [obj.class];
    
    % remove examples that hit the frame (or dmax < d < dmin)
    index = (obj_d >= param.train.dmin) & (obj_d <= param.train.dmax) & (obj_cx+obj_r_box<=size(img,2)) & (obj_cy+obj_r_box<=size(img,1)) & (obj_cx-obj_r_box > 0) & (obj_cy-obj_r_box > 0);
    
    obj_index = obj_index(index);
    obj_cx = obj_cx(index);
    obj_cy = obj_cy(index);
    obj_r = obj_r_box(index);
    obj_class = obj_class(index);
    
    
    %% EXTRACT HAAR-LIKE FEATURES FOR TRAIN SET (TRUE EXAMPLES)
    % *****************************************************************
    
    positive = obj_class == true;
    
    pos_index = obj_index(positive);
    pos_cx = obj_cx(positive);
    pos_cy = obj_cy(positive);
    pos_r = obj_r(positive);
    
    if size(pos_index,2) == 0
        error('>> no (true) objects available for this search range')
    end

    % for Haar,
    % ii = integralImage_v2(img);
    
    % for HOG,
    [gradX,gradY] = gradient(img,param.feature.hog.hx,param.feature.hog.hy);
    
    mag = sqrt(gradX.^2 + gradY.^2);
    
    theta = atan(gradY./gradX);
    
    clear gradX gradY
    
    % for all positive examples
    for i = 1:size(pos_index,2)
        
        % Geometric features
        if param.feature.geom.go
            
            features_geom = [obj(pos_index(i)).BrightLength; obj(pos_index(i)).Distance;...
                obj(pos_index(i)).AreaRatio; obj(pos_index(i)).BrightElongation;...
                obj(pos_index(i)).DarkElongation; obj(pos_index(i)).BothElongation;...
                obj(pos_index(i)).Dissimilarity; obj(pos_index(i)).Circularity;...
                obj(pos_index(i)).Hu1; obj(pos_index(i)).Hu2; obj(pos_index(i)).Hu3; ...
                obj(pos_index(i)).Hu4; obj(pos_index(i)).Hu5; obj(pos_index(i)).Hu6;...
                obj(pos_index(i)).Hu7];
            
        else
            features_geom = [];
        end
        
        % Haar-like features
        if param.feature.haar.go
            
            block = img(pos_cy(i)-pos_r(i)+1:pos_cy(i)+pos_r(i),pos_cx(i)-pos_r(i)+1:pos_cx(i)+pos_r(i));
            block = block_resize(block);
            features_haar = Haar(block);
            % features_haar = Haar_v2(ii,pos_cx(i),pos_cy(i),pos_r(i));

        else
            features_haar = [];
        end
        
        % Histogram of gradients
        if param.feature.hog.go
            
            mblock = mag(pos_cy(i)-pos_r(i)+1:pos_cy(i)+pos_r(i),pos_cx(i)-pos_r(i)+1:pos_cx(i)+pos_r(i));
            mtheta = theta(pos_cy(i)-pos_r(i)+1:pos_cy(i)+pos_r(i),pos_cx(i)-pos_r(i)+1:pos_cx(i)+pos_r(i));
            
            mblock = block_resize(mblock);
            mtheta = block_resize(mtheta);
            
            features_hog = HOG(mblock,mtheta,param.feature.hog.wcell);
            
        else
            features_hog = [];
        end
        
        features(:,i) = [features_geom; features_haar; features_hog];
        
        y(i) = true;
        
    end
    
    locations = [pos_cx' pos_cy' pos_r'];
    index = pos_index';
    
    np = length(y);
    
    fprintf(1,'>> %d true examples loaded\n',np);
    
    
    %% EXTRACT HAAR-LIKE FEATURES FOR TRAIN SET (FALSE EXAMPLES)
    % *****************************************************************
    
    negative = obj_class == false;
    
    neg_index = obj_index(negative);
    neg_cx = obj_cx(negative);
    neg_cy = obj_cy(negative);
    neg_r = obj_r(negative);
    
    if size(neg_index,2) == 0
        error('>> no (false) objects available for this search range')
    end
    
    if size(neg_index,2) >= 2*size(pos_index,2)
        
        % choose examples randomly
        % rand_index = unique(randi(size(neg_index,2),size(neg_index,2),1));
        % neg_index = neg_index(:,rand_index(1:2*size(pos_index,2)));
        
        rand_index = randperm(size(neg_index,2));
        rand_index = sort(rand_index(1:2*size(pos_index,2)));
        neg_index = neg_index(:,rand_index);
        
    end
    
    for i = 1:size(neg_index,2)
        
        % Geometric features
        if param.feature.geom.go
            
            features_geom = [obj(neg_index(i)).BrightLength; obj(neg_index(i)).Distance;...
                obj(neg_index(i)).AreaRatio; obj(neg_index(i)).BrightElongation;...
                obj(neg_index(i)).DarkElongation; obj(neg_index(i)).BothElongation;...
                obj(neg_index(i)).Dissimilarity; obj(neg_index(i)).Circularity;...
                obj(neg_index(i)).Hu1; obj(neg_index(i)).Hu2; obj(neg_index(i)).Hu3; ...
                obj(neg_index(i)).Hu4; obj(neg_index(i)).Hu5; obj(neg_index(i)).Hu6;...
                obj(neg_index(i)).Hu7];
            
        else
            features_geom = [];
        end
        
        % Haar-like features
        if param.feature.haar.go
            
            block = img(neg_cy(i)-neg_r(i)+1:neg_cy(i)+neg_r(i),neg_cx(i)-neg_r(i)+1:neg_cx(i)+neg_r(i));
            block = block_resize(block);
            features_haar = Haar(block);
            % features_haar = Haar_v2(ii,neg_cx(i),neg_cy(i),neg_r(i));
            
        else
            features_haar = [];
        end
        
        % Histogram of gradients
        if param.feature.hog.go
            
            mblock = mag(neg_cy(i)-neg_r(i)+1:neg_cy(i)+neg_r(i),neg_cx(i)-neg_r(i)+1:neg_cx(i)+neg_r(i));
            mtheta = theta(neg_cy(i)-neg_r(i)+1:neg_cy(i)+neg_r(i),neg_cx(i)-neg_r(i)+1:neg_cx(i)+neg_r(i));
            
            mblock = block_resize(mblock);
            mtheta = block_resize(mtheta);
            
            features_hog = HOG(mblock,mtheta,param.feature.hog.wcell);
            
            % clip = features_hog > trim; % sum(clip(:));
            % features_hog(clip) = trim;
            % feature = feature./trim;
            % clear clip
            
        else
            features_hog = [];
        end
        
        features(:,i+np) = [features_geom; features_haar; features_hog];
        
        y(i+np) = false;
        
    end
    
    locations = [locations; neg_cx' neg_cy' neg_r'];
    
    index = [index; neg_index'];
    
    fprintf(1,'>> %d false examples loaded\n',i);
    
    
    % SHOW TRAIN SET
    % *****************************************************************
    
    figure, imshow(img,[]), hold on,
    for k = 1:length(y)
        
        if y(k)
            rectangle('Position',[locations(k,1)-locations(k,3), locations(k,2)-locations(k,3), 2*locations(k,3), 2*locations(k,3)],'EdgeColor','g'),
        else
            rectangle('Position',[locations(k,1)-locations(k,3), locations(k,2)-locations(k,3), 2*locations(k,3), 2*locations(k,3)],'EdgeColor','b'),
        end
        
    end
    
    pause(1), close all,
    
    %% RECORD DATA
    train(img_n).id = filename;
    train(img_n).x = features';
    train(img_n).y = y';
    train(img_n).locs = locations;
    train(img_n).pos = length(pos_index);
    train(img_n).neg = length(neg_index);
    train(img_n).index = index;
    
    clear features locations y
    
end

%% FINAL COUNTS

% tpos = 0;
% tneg = 0;
% 
% for k = 1:param.train.sz_dataset
%     tpos = tpos + train(k).pos;
%     tneg = tneg + train(k).neg;
% end
% 
% param.train.total_pos = tpos;
% param.train.total_neg = tneg;

%% SAVE DATA

if ~isdir(param.train.path)
    mkdir(param.train.path)
end

% register filename with timestamp
trainset_filename = [param.train.path param.time '.mat'];

save(trainset_filename,'train');

fprintf(1,'>> (obj) training set %s generated and saved\n',trainset_filename);
