function label_objects()


global param

% read all .mat files

files = dir([param.convert.path '*.mat']);

for k = 1:size(files,1)
    
    filename = files(k).name;
    
    load([param.convert.path filename]); %wei fixed on 01/08/2010
    
    %% LOAD GT
    % *****************************************************************
    
    gt = [];
    
    present = dir(param.gt.path);
    
    if (~isempty(present))
        
        gt_filename = strcat(param.gt.path); % wei added on 01/08/2010
        
        load(gt_filename);
        
        load_msg = sprintf('>> file %s was loaded',gt_filename);
        disp(load_msg);
    else
        error('ground-truth file does not exist');
        
    end
    
    gt = georef2pix(filename,gt);
    
    clear gt_filename present load_msg
    
    
    %% remove examples that hit the frame (or dmax < d < dmin)
    
    img_filename = ['.\' filename(1:end-4) '\input\' filename(1:end-4) '.pgm'];
    img = imread(img_filename);
    
    cx = round(gt(:,1));
    cy = round(gt(:,2));
    r = round(gt(:,3));
    
    % remove examples that hit the frame (or dmax < d < dmin)
    index = (cx<=size(img,2)) & (cy<=size(img,1)) & (cx > 0) & (cy > 0);
    
    gt = gt(index,:);
    
    % sort by radius
    gt = sortrows(gt,3);
    
    [unused, order] = sort([obj(:).PixDiameter]);
    obj = obj(order);
    
    % number of correct positive predictions
    p = 1;
    
    for v = 1:size(gt,1)
        
        x_gt = gt(v,1);
        y_gt = gt(v,2);
        r_gt = gt(v,3);
        
        if (2*r_gt < param.test.dmin-2*r_gt*param.compare.d_tol) || (2*r_gt > param.test.dmax+2*r_gt*param.compare.d_tol), continue, end,
        
        for w = 1:size(obj,2)
            
            x_dt = obj(w).PixMeanX;
            y_dt = obj(w).PixMeanY;
            r_dt = obj(w).PixDiameter/2;
            
            % if ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > (param.xy_tol+r_gt*0.2)^2) || (abs(r_gt-r_dt) > param.d_tol*r_gt) || match_ratio > 100, continue, end,
            if ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > r_gt^2) || ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > (param.compare.xy_tol)^2) || (abs(r_gt-r_dt) > param.compare.d_tol*max(r_gt,r_dt)), continue, end,
            
            % match_index has all the indexes of gt craters that where
            % detected: gt(v) / dt(w)
            
            match_ratio = 1/(abs(x_gt-x_dt) + abs(y_gt-y_dt) + 2*abs(r_gt-r_dt));
            
            match(p,:) = [v w match_ratio];
            p = p + 1;
            
        end
    end
    
    clear p x_gt y_gt r_gt x_dt y_dt r_dt match_ratio
    
    match = sortrows(match,-3);
    [B,I,J] = unique(match(:,1),'first');
    match = match(I,:);
    
    clear B J
    
    mask_tp = false(size(img));
    
    [x,y] = meshgrid(1:size(img,1),1:size(img,2));
    
    for i = 1:size(match,1)
        
        obj(match(i,2)).class = true;

        mask_tp = (x-obj(match(i,2)).PixMeanX).^2 + (y-obj(match(i,2)).PixMeanY).^2 <= (obj(match(i,2)).PixDiameter/2).^2 | mask_tp;
        
    end
    
    mask_fp = false(size(img));
    
    for i = setdiff(1:size(obj,2),match(:,2))
        
        % mask_fp(obj(i).PixMeanY-obj(i).PixDiameter/2+1:obj(i).PixMeanY+obj(i).PixDiameter/2,obj(i).PixMeanX-obj(i).PixDiameter/2+1:obj(i).PixMeanX+obj(i).PixDiameter/2) = true;
        
        mask_fp = (x-obj(i).PixMeanX).^2 + (y-obj(i).PixMeanY).^2 <= (obj(i).PixDiameter/2).^2;

        overlay = sum(sum(mask_fp.*mask_tp))/sum(mask_fp(:)) > param.label.thresh_overlay;
        
        if ~overlay, obj(i).class = false; end
    end
    
    str = ['..\..\conversion\' filename];
    
    save(str,'obj')
    
    fprintf(1,'>> objects for image %s were labeled and saved\n',filename(1:end-4));
    
    clear obj; %wei 01/08/2010 clear out the variable to be ready for the next candidate data file
    
end