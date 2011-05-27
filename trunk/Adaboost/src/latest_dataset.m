function [dataset_filename] = latest_dataset(path)


D = dir([path '*.mat']);

names = {};

for k = 1:size(D,1)
    names{k} = D(k,:).name;
end

if isempty(names)
    error('??? No dataset files found')
else
    names = sort(names);
end

% load the last one
dataset_filename = [path names{end}];