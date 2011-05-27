function create_log2(train,result,non_craters)

global param

for k = 1:param.test.sz_dataset
    
    % log file '.csv' with the parameters,
    fid = fopen([param.compare.path 'log_' result(k).id '.csv'],'a');
    
    %% parameters
    
    fprintf(fid,'%s,%d,',param.time,param.dratio); % general parameters
    fprintf(fid,'%d,%s,%4.2f,%d,',param.feature.block_sz,param.feature.method,param.feature.tt,param.feature.T); % general features
    fprintf(fid,'%d,%d,',param.feature.geom.t,param.feature.geom.go); % features geom
    fprintf(fid,'%d,%d,',param.feature.haar.t,param.feature.haar.go); % features haar
    fprintf(fid,'%d,%d,%4.2f,%d,%d,%d,%d,',param.feature.hog.hx,param.feature.hog.hy,param.feature.hog.trim,param.feature.hog.wcell,param.feature.hog.nbins,param.feature.hog.t,param.feature.hog.go); % features hog
    fprintf(fid,'%d,%d,%d,%4.2f,%s,',param.train.dmin,param.train.dmax,param.train.k_nn,param.train.thresh_std,param.train.type); % train
    fprintf(fid,'%d,%d,',param.test.dmin,param.test.dmax); % test
    fprintf(fid,'%4.2f,',param.boost.miu); % boost
    fprintf(fid,'%4.2f,%4.2f,',param.craters.d_erase,param.craters.xy_erase); % craters
    fprintf(fid,'%4.2f,%d,',param.compare.d_tol,param.compare.xy_tol); % compare
    
    %% training set
    
    %fprintf(fid,'%d,%d,',train.ds.pos,train.ds.neg);
    fprintf(fid,'%d,%d,',train.pos,train.neg);
    
    %% results
    tp = result(k).tp;
    fp = result(k).fp;
    fn = result(k).fn;
    fnobj = result(k).fn_obj;
    tn=size(non_craters(k).index,1)-sum(2*fn(:,3)>=param.test.dmin,1);
    db = result(k).db;
    
     fprintf(fid,'%d,%d,%d,%d,%d,%d\n',(size(tp,1)+size(db,1)),size(fp,1),sum(2*fn(:,3)>=param.test.dmin,1),sum(2*fnobj(:,3)>=param.test.dmin,1),tn,size(db,1));
    % fprintf(fid,'%d,%d,%d,%d,%d\n',sum((2*tp(:,3)>=16)&(2*tp(:,3)<=40),1),sum((2*fp(:,3)>=16)&(2*fp(:,3)<=40),1),sum((2*fn(:,3)>=16)&(2*fn(:,3)<=40),1),sum((2*fnobj(:,3)>=16)&(2*fnobj(:,3)<=40),1),sum((2*db(:,3)>=16)&(2*db(:,3)<=40),1));
    %fprintf(fid,'%d,%d,%d,%d,%d\n',sum(2*tp(:,3)>=16,1),sum(2*fp(:,3)>=16,1),sum(2*fn(:,3)>=16,1),sum(2*fnobj(:,3)>=16,1),sum(2*db(:,3)>=16,1));

    fclose(fid);

end