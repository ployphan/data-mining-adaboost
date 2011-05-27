close all, clear all, clc,

%% General initialization
%**************************************************************************

parameters;

global param

%% Convert candidates
%**************************************************************************

if param.convert.go
    
    convert_objects;
    
end

%% Label candidates
% *********************************************************************

if param.label.go
    
    label_objects;
    
end


%% Contruct transfer learning or regular training set
% *********************************************************************

if param.tr_train.go % construct transfer learning training set
    
    construct_tr_train;
    
elseif param.train.go % construct regular training set
    
    construct_train;
    
end

%% Load latest training set or transfer learning training set
% *********************************************************************

if param.tr_train_load.go % load transfer learning training set
    
    dataset_filename = latest_dataset(param.tr_train.path);
    
    load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);
    
else % load regular training set
    
    dataset_filename = latest_dataset(param.train.path);
    
    load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);
    
end

%% Construct test set
% *********************************************************************

if param.test.go
    
    construct_test;
    
end


%% Load latest test set
% *********************************************************************

dataset_filename = latest_dataset(param.test.path);

load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);


%% Construct transfer learining or regular Boost classifier
% *********************************************************************
if param.tr_boost.go % build transfer learning boost classifier
    
    TrBoost(train,test);
    
elseif param.boost.go % build regular boost classifier

    Boost(train,test);
    
end


%% Load latest transfer learning or regular Classifier
% *********************************************************************
if param.tr_classifier_load.go % load transfer learning classifier
    
    dataset_filename = latest_dataset(param.tr.path);
    
    load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);
    
else % load regular classifier

    dataset_filename = latest_dataset(param.boost.path);

    load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);

end

%% Remove duplicates
% *********************************************************************

if param.craters.go

    remove_rept(test,boost_classf);
    
end


%% Load latest test set (with no duplications)
% *********************************************************************

dataset_filename = latest_dataset(param.craters.path);

load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);


%% Compare results with the ground truth
% *********************************************************************

if param.compare.go

    generate_results(craters);

end


%% Load latest result
% *********************************************************************

dataset_filename = latest_dataset(param.compare.path);

load(dataset_filename), fprintf(1,'>> file %s loaded\n',dataset_filename);


%% Create log file
% *********************************************************************

create_log(train,result);