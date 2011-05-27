function parameters()


global param

%% GO

param.convert.go = false; % convert new objects
param.label.go = false; % label new objects
param.train.go = false; % new training set to be constructed
param.tr_train.go = false; % new transfer learning training set to be constructed
                          % only one of the parameters can be true at the
                          % same time: param.train.go & param.tr_train.go
param.tr_train_load.go = false; % load the latest transfer learning training set
                               % if param.tr_train.go = true,
                               % param.tr_train_load.go must be set to
                               % true too. 
param.test.go = false; % new test set to be constructed

param.feature.geom.go = false; % Geometric features
param.feature.haar.go = true; % Haar features
param.feature.hog.go = false; % HOG features

param.boost.go = true; % new classifier to be constructed
param.tr_boost.go = false; % new transfer learning classifier to be constructed
                          % only of the parameters can be true at the same
                          % time: param.boost.go & param.tr_boost.go
param.tr_classifier_load.go = false; % load the latest transfer learning classifier
                                    % if param.tr_boost.go = true,
                                    % param.tr_classifier_load.go must be
                                    % set to true too.
param.craters.go = true; % remove duplicates
param.compare.go = true; % compare the results to the ground truth


%% GENERAL PARAMETERS

param.time = datestr(now,30);
param.dratio = 2; % Ratio between window size of feature extraction and crater diameter
param.feature.block_sz = 48;
param.feature.method = 'bilinear'; % block rescale method

param.gt.path = '..\..\gt\global_gt.mat'; % ground truth filename


%% CONVERSION PARAMETERS

param.convert.path = '..\..\conversion\'; % conversion folder name


%% LABEL PARAMETERS

param.label.thresh_overlay = 0.25; % overlay with true crater to reject as false example

%% TRANSFER LEARNING PARAMETERS
param.tr.sz_dataset = 1; % size of transfer learning test set (number of images)
param.tr.sz_tp = 70; % size of tp per test set to be used as same distribution of the training set
                     % if 2 transfer learning test sets are used, the
                     % total TP = 2 * param.tr.sz_tp
param.tr.tn_ratio = 2; % the ratio between TN and TP in the same distribution of the training set
param.tr.tp_pt = 1; % percentage of total TP of the different distribution in the different distribution of the training set
param.tr.path = '..\..\history\tr_classf\'; % transfering learning classifier folder name
param.tr_train.path = '..\..\history\tr_trainset\'; % transfer learning training set folder name


% read transfer learning test set file sheet
[numeric, param.tr.filenames] = xlsread('filenames','tr_testset',strcat('A1:A',num2str(param.tr.sz_dataset)));


%% TRAIN PARAMETERS

param.train.dmin = 16; % diameter range of the study, dmin
param.train.dmax = 400; % diameter range of the study, dmax

param.train.sz_dataset = 1; % size of training set (number of images)
param.train.path = '..\..\history\trainset\'; % training set folder name

% read train set file sheet
[numeric, param.train.filenames] = xlsread('filenames','trainset',strcat('A1:A',num2str(param.train.sz_dataset)));


%% TEST PARAMETERS

param.test.dmin = 16; % diameter range of the study, dmin
param.test.dmax = 400; % diameter range of the study, dmax

param.test.sz_dataset = 6; % size of test set (number of images)
param.test.path = '..\..\history\testset\'; % test set folder name

% read test set file sheet
[numeric, param.test.filenames] = xlsread('filenames','testset',strcat('A1:A',num2str(param.test.sz_dataset)));


%% FEATURE PARAMETERS

param.feature.geom.t = 15; % number of geometric features

param.feature.haar.t = 121*(7+2); % number of haar features

param.feature.hog.hx = 1; % gradient x size for HOG
param.feature.hog.hy = 1; % gradient y size for HOG
param.feature.hog.trim = 0.3; % clipping for HOG
param.feature.hog.wcell = 16; % for HOG, note: it only permites diameters multiples of 3
param.feature.hog.nbins = 18; % perform nbins histograms

param.feature.hog.t = 18*9; % number of hog features

param.feature.pt = 1; % percentage of the total number of features to use (1 = 100%)
param.feature.T = param.feature.geom.go*param.feature.geom.t + param.feature.haar.go*param.feature.haar.t + param.feature.hog.go*param.feature.hog.t; % total number of features used


%% CLASSIFICATION PARAMETERS

param.boost.miu = 0.60; % threshold for classification

param.boost.path = '..\..\history\classf\'; % classifier folder name


%% CRATERS PARAMETERS

param.craters.d_erase = 0.50; % Erase ratio in diameter
param.craters.xy_erase = 0.50; % Erase ratio in position

param.craters.path = '..\..\history\craters\';


%% COMPARATIVE PARAMETERS

param.compare.d_tol = 0.50; % Detection tolerance in diameter
param.compare.xy_tol = 20; % Detection tolerance in position

param.compare.path = '..\..\history\compare\';