function construct_train_rand()


%% INITIALIZATION
% *************************************************************************

global param

gt = [];


%% CONSTRUCT TRAIN SET
% *****************************************************************
for img_n = 1:param.train.sz_dataset
    
    filename = param.train.filenames{img_n};
    
    img_filename = ['.\' filename '\input\' filename 's.pgm'];
    img = single(imread(img_filename));
    
    img_sx = size(img,2);
    img_sy = size(img,1);
    
    
    %% GET GT
    % *****************************************************************
    
    if (~isempty(dir(param.gt.path)))
        
        load(param.gt.path)
        
        fprintf(1,'>> file %s was loaded\n',param.gt.path);
        
    else
        error('ground-truth file does not exist');
        
    end
    
    gt = georef2pix(filename,gt);
    
    
    %% REMOVE TRUE EXAMPLES THAT HIT FRAME
    % *****************************************************************
    
    cx = round(gt(:,1));
    cy = round(gt(:,2));
    d = round(param.dratio.*2*gt(:,3));
    % d = param.dstep*round(2*gt(:,4).*(param.dratio)/(param.dstep));
    
    % remove examples that hit the frame (or dmax < d < dmin)
    ind = (d >= param.test.dmin) & (d <= param.test.dmax) & (cx+d/2<=img_sx) & (cy+d/2<=img_sy) & (cx-d/2 > 0) & (cy-d/2 > 0);
    
    gt = gt(ind,:);
    
    
    %% EXTRACT HAAR-LIKE FEATURES FOR TRAIN SET (TRUE EXAMPLES)
    % *****************************************************************
    
    cx = round(gt(:,1));
    cy = round(gt(:,2));
    r = round(param.dratio.*gt(:,3));
    
    if size(cx,1) == 0
        error('>> no ground-truth available for this search range')
    end
    
    % for HOG,
    [gradX,gradY] = gradient(img,param.feature.hog.hx,param.feature.hog.hy);
    
    mag = sqrt(gradX.^2 + gradY.^2);
    
    theta = atan(gradY./gradX);
    
    clear gradX gradY

    % initiate mask for overlay
    mask_tp = false(img_sy,img_sx);
    [x,y] = meshgrid(1:img_sx,1:img_sy);
    
    % for all selected gt craters
    for i = 1:size(cx,1)
        
        % Geometric features
        
        % there is no correspondance with the objects so there cannot be
        % any geometric features
        
        % Haar-like features
        if param.feature.haar.go
            
            block = img(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i));
            
            block = block_resize(block);
            
            features_haar = Haar(block);
            
        else
            features_haar = [];
        end
        
        % Histogram of gradients
        if param.feature.hog.go
            
            mblock = mag(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i));
            mtheta = theta(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i));
            
            mblock = block_resize(mblock);
            mtheta = block_resize(mtheta);
            
            features_hog = HOG(mblock,mtheta,param.feature.hog.wcell);
            
        else
            features_hog = [];
        end
        
        features(:,i) = [features_haar; features_hog];
        
        class(i) = true;
        
        mask_tp = (x-cx(i)).^2 + (y-cy(i)).^2 <= (r(i)/param.dratio).^2 | mask_tp;
        % mask_tp(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i)) = true;
    end
    
    locations = [cx cy r];
    
    np = length(class);
    
    fprintf(1,'>> %d true examples loaded\n',np);
    
    clear gt index coord rand_index block cx cy r
    
    
    %% EXTRACT HAAR-LIKE FEATURES FOR TRAIN SET (FALSE EXAMPLES)
    % *****************************************************************
    
    cx = [];
    cy = [];
    r = [];
    
    nn = 0;
    
    % initiate mask for false examples
    mask_fp = false(img_sy,img_sx);
    
    while nn < 2*np
        
        aux_r = round((param.train.dmin + (param.train.dmax-param.train.dmin).*rand(param.train.k_nn,1))/2);
        aux_cx = round(1 + (img_sx-1).*rand(param.train.k_nn,1));
        aux_cy = round(1 + (img_sy-1).*rand(param.train.k_nn,1));
        
        % remove examples that hit the frame
        index = (aux_cx+aux_r<=img_sx) & (aux_cy+aux_r<=img_sy) & (aux_cx-aux_r > 0) & (aux_cy-aux_r > 0);
        coord = find(index);
        
        aux_cx = aux_cx(coord);
        aux_cy = aux_cy(coord);
        aux_r = aux_r(coord);
        
        aux_nn = size(aux_r,1);
        
        % remove examples that intersect more than thresh_overlay with
        % true examples
        for i = 1:aux_nn
            
            mask_fp = (x-aux_cx(i)).^2 + (y-aux_cy(i)).^2 <= (aux_r(i)).^2;
            %mask_rand = false(img_sy,img_sx);
            %mask_rand(aux_cy(i)-aux_r(i)+1:aux_cy(i)+aux_r(i),aux_cx(i)-aux_r(i)+1:aux_cx(i)+aux_r(i)) = true;
            
            overlay(i) = sum(sum(mask_fp.*mask_tp))/sum(mask_fp(:)) < param.label.thresh_overlay;
            
            aux_block = img(aux_cy(i)-aux_r(i)+1:aux_cy(i)+aux_r(i),aux_cx(i)-aux_r(i)+1:aux_cx(i)+aux_r(i));
            st_desv(i) = std(aux_block(:)) > param.train.thresh_std;
        end
        
        fprintf(1,'>> %d overlay rejection, %d std rejection\n',sum(~overlay),sum(~st_desv));
        
        admit = overlay & st_desv;
        
        coord = find(admit);
        
        cx = [cx; aux_cx(coord)];
        cy = [cy; aux_cy(coord)];
        r = [r; aux_r(coord)];
        
        nn = size(r,1);
        clear overlay st_desv
        
        fprintf(1,'>> %d false examples randomly selected (out of %d)\n',nn,2*np);
    end
    
    clear index coord aux_cx aux_cy aux_r aux_nn
    
    for i = 1:size(cx,1)
        
        % haar-like features
        if param.feature.haar.go
            
            block = img(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i));
            
            block = block_resize(block);
            
            features_haar = Haar(block);
            
        else
            features_haar = [];
        end
        
        % histogram of gradients
        if param.feature.hog.go
            
            mblock = mag(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i));
            mtheta = theta(cy(i)-r(i)+1:cy(i)+r(i),cx(i)-r(i)+1:cx(i)+r(i));
            
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
        
        features(:,i+np) = [features_haar; features_hog];
        
        class(i+np) = false;
        
    end
    
    locations = [locations; cx cy r];
    
    fprintf(1,'>> %d false examples randomly selected\n',nn);
    
    clear rand_index block d i mask mask_rand cx cy r
    
    
    % SHOW TRAIN SET
    % *****************************************************************
    
    figure, imshow(img,[]), hold on,
    for k = 1:length(class)
        
        if class(k)
            rectangle('Position',[locations(k,1)-locations(k,3), locations(k,2)-locations(k,3), 2*locations(k,3), 2*locations(k,3)],'EdgeColor','g'),
        else
            rectangle('Position',[locations(k,1)-locations(k,3), locations(k,2)-locations(k,3), 2*locations(k,3), 2*locations(k,3)],'EdgeColor','b'),
        end
        
    end
    
    pause(1), close all,
    
    index_pos = find(class);
    index_neg = find(~class);
    
    %% RECORD DATA
    train(img_n).id = filename;
    train(img_n).x = features';
    train(img_n).y = class'; %[true(length(index_pos),1); false(length(index_neg),1)];
    train(img_n).locs = locations;
    train(img_n).pos = length(index_pos);
    train(img_n).neg = length(index_neg);
    
    clear features locations class
    
end

%% SAVE DATA

if ~isdir(param.train.path)
    mkdir(param.train.path)
end

% register filename with timestamp
trainset_filename = [param.train.path param.time '.mat'];

save(trainset_filename,'train');

fprintf(1,'>> (rand) training set %s generated and saved\n',trainset_filename);
