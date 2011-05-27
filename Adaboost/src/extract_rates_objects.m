function extract_rates_objects()

% read all .mat files
files = dir('..\..\conversion\*.mat');

nseg = 64;
show_figs = true;

for k = 1:size(files,1)
    
    filename = files(k).name;
    
    load(filename);
    
    %% LOAD GT
    % *****************************************************************
    
    gt = [];
    
    gt_filename = strcat('..\..\gt\global_gt.mat');
    
    present = dir(gt_filename);
    
    if (~isempty(present))
        
        load(gt_filename)
        
        load_msg = sprintf('>> file %s was loaded',gt_filename);
        disp(load_msg);
    else
        error('ground-truth file does not exist');
        
    end
    
    gt = georef2pix(filename,gt);
    
    clear gt_filename present load_msg
    
    
    %% remove examples that hit the frame (or dmax < d < dmin)
    
    img_filename = ['.\' filename '\input\' filename '.pgm'];
    img = imread(img_filename);
    
    cx = round(gt(:,1));
    cy = round(gt(:,2));
    r = round(gt(:,3));
    
    % remove examples that hit the frame (or dmax < d < dmin)
    index = (cx<=size(img,2)) & (cy<=size(img,1)) & (cx > 0) & (cy > 0);
    
    gt = [cx(index) cy(index) r(index)];
    
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
        
        if (2*r_gt < param.dmin-2*r_gt*param.d_tol) || (2*r_gt > param.dmax+2*r_gt*param.d_tol), continue, end,
        
        for w = 1:size(obj.index,1)
            
            x_dt = obj(w).PixMeanX;
            y_dt = obj(w).PixMeanY;
            r_dt = obj(w).PixDiameter/2;
            
            % if ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > (param.xy_tol+r_gt*0.2)^2) || (abs(r_gt-r_dt) > param.d_tol*r_gt) || match_ratio > 100, continue, end,
            if ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > r_gt^2) || ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > (param.xy_tol)^2) || (abs(r_gt-r_dt) > param.d_tol*max(r_gt,r_dt)), continue, end,
            
            % match_index has all the indexes of gt craters that where
            % detected: gt(v) / dt(w)
            
            error_abs_xy = sqrt((x_gt-x_dt)^2 + (y_gt-y_dt)^2);
            
            error_abs_r = r_gt-r_dt;
            error_rel_r = 100*(r_gt-r_dt)/r_gt;
            
            errors(p,:) = [r_gt error_abs_xy error_abs_r error_rel_r];
            
            match_ratio = 1/(abs(x_gt-x_dt) + abs(y_gt-y_dt) + 2*abs(r_gt-r_dt));
            
            match_index(p,:) = [v w match_ratio];
            p = p + 1;
            
        end
    end
    
    [sort_match,Ind] = sortrows(match_index,-3);
    errors = errors(Ind,:);
    [B,I,J] = unique(sort_match(:,1),'first');
    match_index_unique = sort_match(I,:);
    
    % detections
    index_dt = 1:size(cdt,1);
    index_tp = ismember(index_dt,match_index_unique(:,2));
    
    [doubles_index,I] = setdiff(sort_match,match_index_unique,'rows');
    
    index_db = ismember(index_dt,doubles_index(:,2));
    
    index_fp = ~(index_tp | index_db);
    
    % ground-truth
    index_gt = 1:size(gt,1);
    index_aux = ismember(index_gt,match_index_unique(:,1));
    index_fn = (~index_aux') & (2*gt(:,3) >= param.dmin) & (2*gt(:,3) <= param.dmax);
    
    % global rates
    global_res = [cdt(index_tp,:) zeros(sum(index_tp),1); cdt(index_fp,:) ones(sum(index_fp),1); false(sum(index_fn),1) gt(index_fn,1:2) 2*gt(index_fn,3) 2*ones(sum(index_fn),1); cdt(index_db,:) 3*ones(sum(index_db),1)];
    clear index_aux
    
    cdt_tp = cdt(index_tp,:);
    cdt_db = cdt(index_db,:);
    cdt_fp = cdt(index_fp,:);
    dt_fn = gt(index_fn,1:3);
    
    if show_figs
        
        figure,
        imshow(img),
        daspect([1 1 1]),
        hold on,
        
    end
    
    theta = 0 : (2 * pi / nseg) : (2 * pi);
    
    tp = 0;
    fp = 0;
    fn = 0;
    db = 0;
    
    r_tp = [];
    r_fp = [];
    r_fn = [];
    r_db = [];
    
    for c = 1:size(global_res,1)
        
        x_res    = global_res(c,2);
        y_res    = global_res(c,3);
        r_res    = global_res(c,4)/2;
        flag_res = global_res(c,5);
        
        pline_x = r_res * cos(theta) + x_res;
        pline_y = r_res * sin(theta) + y_res;
        
        if flag_res == 0
            
            L = 'g';
            tp = tp + 1;
            r_tp(tp) = r_res;
            
        elseif flag_res == 1
            
            L = 'r';
            fp = fp + 1;
            r_fp(fp) = r_res;
            
        elseif flag_res == 2
            
            L = 'b';
            fn = fn + 1;
            r_fn(fn) = r_res;
            
        elseif flag_res == 3
            
            L = 'y';
            db = db + 1;
            r_db(db) = r_res;
            
        else
            disp('>> unknown result...')
        end
        
        if show_figs, plot(pline_x, pline_y, strcat(L,'-'),'LineWidth',2); end
    end
    
    disp('>>'), disp('>> RESULTS FOR THE SEARCH RANGE REQUESTED:'),
    str01 = sprintf('>> TRUES: (tp=%d) FALSES: (fp=%d / fn=%d)',tp,fp,fn);
    disp(str01),
    
    dr = tp/(tp+fn);
    fr = fp/(tp+fp);
    bf = fp/tp;
    qr = tp/(tp+fp+fn);
    f_measure = 2*tp/(2*tp+fp+fn);
    
    str02 = sprintf('>> f-measure %.5g, detection percentage %.5g,  branching factor %.5g, quality percentage %.5g', f_measure, dr, bf, qr);
    disp(str02),
    
    clear str00 str01 str02
    
    
    %**************************************************
    
    
    
    pos_train = dt_tp;
    neg_train = dt_fp;
    
    save([filename(1:end-8) '_pos_train.mat'],'pos_train')
    save([filename(1:end-8) '_neg_train.mat'],'neg_train')
    
    %     dlmwrite([filename(1:end-8) '.txt'],[dt_tp true(size(dt_tp,1),1); dt_fp false(size(dt_fp,1),1); dt_db 2*ones(size(dt_db,1),1)],'delimiter',' ');
    %
    %     print('-r600','-djpeg',filename(1:end-8))
end