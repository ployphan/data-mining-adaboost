function [tp,fp,fn,db,index_res,fn_obj,hh,hhtp] = extract_rates(filename,craters,img_sx,img_sy)

%% INITIALIZATION
% *************************************************************************

global param

gt = [];


%% GET GT
% *****************************************************************

if (~isempty(dir(param.gt.path)))
    
    load(param.gt.path)
    
    fprintf(1,'>> file %s was loaded\n',param.gt.path);
    
else
    error('ground-truth file does not exist');
    
end

gt = georef2pix(filename,gt);

% show_gt(filename,gt)

cx = round(gt(:,1));
cy = round(gt(:,2));
d = round(2*gt(:,3));
r_box = param.dratio.*round(2*gt(:,3))/2;
% d = param.dstep*round(gt(:,4).*(param.dratio)/(param.dstep));

% remove examples that hit the frame (or dmax < d < dmin)
ind = (d >= param.test.dmin) & (d <= param.test.dmax) & (cx+r_box<=img_sx) & (cy+r_box<=img_sy) & (cx-r_box > 0) & (cy-r_box > 0);

% before, we did this:
% ind = (cx<=size(img,2)) & (cy<=size(img,1)) & (cx > 0) & (cy > 0);

gt = gt(ind,:);

% sort in ascending order (of radius):
gt = sortrows(gt,3);

% show_gt(filename,gt)

%% LOAD CRATERS

locs = [craters.locs];
index = [craters.index];
hhimage=[craters.hhimage];

% sort in ascending order (of radius):
[locs,I] = sortrows(locs,3);
index = index(I);
hh=hhimage(I);

%% MATCH CRATERS WITH GT

% number of matches
p = 1;

% for each crater in the ground-truth
for v = 1:size(gt,1)
    
    x_gt = gt(v,1);
    y_gt = gt(v,2);
    r_gt = gt(v,3);
    
    if (2*r_gt < param.test.dmin-2*r_gt*param.compare.d_tol) || (2*r_gt > param.test.dmax+2*r_gt*param.compare.d_tol), continue, end,
    
    % for each crater detected
    for w = 1:size(locs,1)
        
        x_dt = locs(w,1);
        y_dt = locs(w,2);
        r_dt = locs(w,3);
        
        % if ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > (param.xy_tol+r_gt*0.2)^2) || (abs(r_gt-r_dt) > param.d_tol*r_gt) || match_ratio > 100, continue, end,
        if ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > r_gt^2) || ((x_gt-x_dt)^2 + (y_gt-y_dt)^2 > (param.compare.xy_tol)^2) || (abs(r_gt-r_dt) > param.compare.d_tol*max(r_gt,r_dt)), continue, end,
        
        % match_index has all the indexes of gt craters that where
        % detected: gt(v) / dt(w)
        
        match_ratio = 1/(abs(x_gt-x_dt) + abs(y_gt-y_dt) + 2*abs(r_gt-r_dt));
        
        match(p,:) = [v w match_ratio];
        p = p + 1;
        
    end
end

match = sortrows(match,-3);
[unused,I] = unique(match(:,1),'first');
unique_match = match(I,:);


%% EXTRACT QUANTITIES

% detections
index_tp = ismember(1:size(locs,1),unique_match(:,2));

dups = setdiff(match,unique_match,'rows');
index_db = ismember(1:size(locs,1),dups(:,2));

index_fp = ~(index_tp | index_db);

% ground-truth
index_fn = ~(ismember(1:size(gt,1),match(:,1)));

% index of each crater with the appropriate label
index_res = [index(index_tp) true(sum(index_tp),1); index(index_fp) false(sum(index_fp),1); index(index_db) 2*true(sum(index_db),1)];


% dlmwrite([filename '.txt'],[index(index_tp)' locs(index_tp,:) features(index_tp,:) true(sum(index_tp),1); index(index_fp)' locs(index_fp,:) features(index_fp,:) false(sum(index_fp),1)],'delimiter',' ')

tp = locs(index_tp,:);
fp = locs(index_fp,:);
hhtp=hh(index_tp);
hh=hh(index_fp);

db = locs(index_db,:);

fn = gt(index_fn,1:3);


%% MATCH OBJECTS WITH GT

clear match

load([param.convert.path filename '.mat']);

[unused, order] = sort([obj(:).PixDiameter]);
obj = obj(order);

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

% ground-truth
index_fn_obj = ~(ismember(1:size(gt,1),match(:,1)));

fn_obj = gt(index_fn_obj,1:3);
