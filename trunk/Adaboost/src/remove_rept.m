function remove_rept(test,classf)



%% INITIALIZATION
% *************************************************************************

global param

HH = classf.discriminant;
C = classf.classifier;

craters = test;

% counter
m = 1;

first_testset = 1;

%% ANALYZE EACH IMAGE IN TEST SET
for img_n = 1:param.test.sz_dataset
    
    %% SHOW CANDIDATES
    % filename = text{img_n};
    
    % img_filename = ['.\' filename '\input\' filename '.pgm'];
    % img = single(imread(img_filename));
    
    % test set
    last_testset = size(test(img_n).x,1) + first_testset - 1;
    
    locs = test(img_n).locs;
    locs(:,3) = locs(:,3)/(param.dratio);
    
    index = test(img_n).index;
    % show_candidates(img,locs,'g');
    
    features = test(img_n).x;
    
    % just the ones that had positive feedback
    ind = find(C(first_testset:last_testset));
    
    HH_image = HH(first_testset:last_testset);
    
    % again, the ones that had positive feedback
    HH_image = HH_image(ind);
    locs = locs(ind,:);
    index = index(ind);
    features = features(ind,:);
    
    % sort in descending order (of radius):
    [locs,I] = sortrows(locs,-3);
    HH_image = HH_image(I);
    index = index(I);
    features = features(I,:);
    
    first_testset = last_testset + 1;
    
    minimum = [];
    
    % show_candidates(img,locs,'b');
    
    %% REMOVE DUPLICATES
    % REMOVE DUPLICATES
    for a = 1:size(locs,1)
        
        if intersect(a,minimum), continue, end
        
        % candidate radius
        cx_a = locs(a,1);
        cy_a = locs(a,2);
        r_a = locs(a,3);
        
        if (2*r_a < param.test.dmin - 2*r_a*param.compare.d_tol) || (2*r_a > param.test.dmax + 2*r_a*param.compare.d_tol)
            % if (2*r_a < param.test.dmin - 3*r_a) || (2*r_a > param.test.dmax + 3*r_a)
            minimum(m) = a;
            m = m + 1;
            continue;
        end
        
        for b = a+1:size(locs,1)
            
            if intersect(b,minimum), continue, end
            
            cx_b = locs(b,1);
            cy_b = locs(b,2);
            r_b = locs(b,3);
            
            if (2*r_b < param.test.dmin - 2*r_b*param.compare.d_tol) || (2*r_b > param.test.dmax + 2*r_b*param.compare.d_tol)
                % if (2*r_b < param.test.dmin - 3*r_b) || (2*r_b > param.test.dmax + 3*r_b)
                minimum(m) = b;
                m = m + 1;
                continue;
            end
            
            % if ((cx_b-cx_a)^2 + (cy_b-cy_a)^2 > max(r_b,r_a)^2) || ((cx_b-cx_a)^2 + (cy_b-cy_a)^2 > (param.craters.xy_erase*max(r_b,r_a))^2) || (abs(r_b-r_a) > param.craters.d_erase*max(r_b,r_a)), continue, end,
            
            if (abs(r_b-r_a) <= param.craters.d_erase*r_a) && ((cx_b-cx_a)^2+(cy_b-cy_a)^2 <= (param.craters.xy_erase*r_a)^2)
                
                % show_candidates(img,[cx_b cy_b r_b]);
                % show_candidates_a(img,[cx_a cy_a r_a]);
                
                [value,ind] = min([HH_image(a) HH_image(b)]);
                
                if (ind == 1) % && ((abs(r_b-r_a) <= param.compare.d_tol*r_a) && ((cx_b-cx_a)^2+(cy_b-cy_a)^2 <= (param.compare.xy_tol*r_a)^2))
                    minimum(m) = a;
                elseif (ind == 2) % && ((abs(r_b-r_a) <= param.compare.d_tol*r_a) && ((cx_b-cx_a)^2+(cy_b-cy_a)^2 <= (param.compare.xy_tol*r_a)^2))
                    minimum(m) = b;
                end
                
                m = m + 1;
            end
        end
    end
    
    setdiff_index = setdiff(1:size(locs,1),minimum);
    locs = locs(setdiff_index,:);
    HH_image = HH_image(setdiff_index);
    index = index(setdiff_index);
    features = features(setdiff_index,:);
    
    clear minimum
    
    fprintf(1,'>> %d craters have been reported in image %s\n',size(locs,1),test(img_n).id);
    
     
    craters(img_n).locs = locs;
    craters(img_n).index = index;
    craters(img_n).x = features;
    craters(img_n).hhimage=HH_image';
    
end

%% SHOW TEST SET RESULTS
% *********************************************************************

% show_candidates(img,locs,'r');

% pause,

%% SAVE TEST SET

if ~isdir(param.craters.path)
    mkdir(param.craters.path)
end

% register filename with timestamp
cratersset_filename = [param.craters.path param.time '.mat'];

save(cratersset_filename,'craters');
