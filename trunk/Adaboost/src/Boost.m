function [classf] = Boost(train,test)

%% INITIALIZATION
% *************************************************************************

global param

x = [];
y = [];

pos = 0;
neg = 0;

%  train set
for k = 1:param.train.sz_dataset
    
    % x = [x train(k).x(:,1:param.feature.T)'];
    x = [x [train(k).x]'];
    y = [y train(k).y'];
    
    pos = train(k).pos + pos;
    neg = train(k).neg + neg;
    
end

% number of blocks
n = pos + neg;

fprintf(1,'>> train set has %d blocks: %d positive and %d negative examples\n',n,pos,neg);

% theta
step_theta = 1;
theta = sort(x,2); %1st dimension = features; 2nd dimension = instances


tt = param.feature.tt;
fprintf(1,'>> %d features selected for training the classifier \n',tt);

% weights

% positive reinforcement
index_pos = find(y);
m = length(index_pos);

% negative reinforcement
index_neg = find(~y);
l = length(index_neg);


% initialize weights for all positive and negative training examples
w = zeros(1,n);
w(index_pos) = 1/(2*m);
w(index_neg) = 1/(2*l);

clear index_pos index_neg m l

%% TRAIN
% *************************************************************************
fprintf(1,'>> trainning will commence\n');

for boostloop = 1:tt
    
    % error for each candidate feature
    clear err_min err_init h;
    err_init = 1;
    err_min = err_init*ones(param.feature.T,1);

    % search for the best feature
    for t = 1:param.feature.T

        for par = -1:2:1

            for n_theta = 1:step_theta:n

                for i = 1:n

                    % HUMMMMM....
                    h(i) = par*x(t,i) < par*theta(t,n_theta);

                end

                % calculate error
                e = abs(h-y);
                err = sum(w.*e);
                
                % each weak classifier must be at least better than random
                % guessing
                % find minimum error
                if (err < err_min(t)) && (err < 0.5)
                    err_min(t) = err;
                    e_min(t,:) = e;
                    local_parameters(t,:) = [par theta(t,n_theta)];
                end

                % break if error is null
                %if err_min(t) == 0
                    %break;
                %end
            end
        end
    end

    % min_err = minimum error
    % min_ind = which feature (a.k.a. weak classifier) produces minimum error?
    [min_err,min_ind]=min(err_min);
    % keep the index of the selected best features
    ind(boostloop) = min_ind;
    % update weights
    % min_err is supposed to be < 0.5, hence beta < 1
    beta(boostloop) = min_err/(1-min_err);
    % alfa for each selected best weak classifier
    alfa(boostloop) = log(1/beta(boostloop));
    % parameters: p (sign) and theta for the selected best weak classifier 
    parameters(boostloop,:) = local_parameters(min_ind,:);
    % for each training instance, modify its weight for next iteration
    % e=0, the instance is classified correctly, its weight w is decreased
    % e=1, the instance is classified incorrectly, its weight is unchanged
    w = w.*(beta(boostloop).^(1-e_min(min_ind,:)));
    % normalise weights
    w = w./sum(w);
    % record misclassified examples
    err_example(boostloop,:)=e_min(min_ind,:);
    % record the minimum error for each boost iteration
    boost_err(boostloop)=min_err;
end;


clear x y h beta


%% TEST
% *************************************************************************

test_sz = param.test.sz_dataset;

% initialization
    
par = parameters(:,1)';
theta = parameters(:,2);
    
HH = [];
C = [];

% test set
for k = 1:test_sz
    
    % x = test(k).x(:,1:param.feature.T)';
    x = [test(k).x]';
    
    fprintf(1,'>> test will commence on image %s\n',test(k).id);
    
    % best weak classifiers
    for t = 1:tt
        selected_ind=ind(t);
        h(t,:) = par(t)*x(selected_ind,:) < par(t).*theta(t);
        
    end
    
    % discriminant function
    HH_aux = alfa*h;
    HH = [HH HH_aux];
    
    % strong classifier
    C = [C HH_aux >= param.boost.miu*sum(alfa)];
    
    clear x h
end



classf.err_example = err_example; %for each interation, misclassified examples
classf.min_err = boost_err; %for each iteration, the minimum error of the best weak classifier
classf.discriminant = HH;
classf.classifier = C;
classf.alfa = alfa;
classf.theta = theta;
classf.par = par;
classf.best = ind;

fprintf(1,'>> classifier generated\n');

%% Save classifier

if ~isdir(param.boost.path)
    mkdir(param.boost.path)
end

classf_filename = [param.boost.path param.time '.mat'];

save(classf_filename,'classf');
