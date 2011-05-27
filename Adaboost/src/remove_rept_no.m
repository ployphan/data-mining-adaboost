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
