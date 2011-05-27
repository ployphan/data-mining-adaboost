function create_log(train,result,non_craters)

global param

% log file '.csv' with the parameters,
fid = fopen([param.compare.path 'log.csv'],'a');

%% parameters

fprintf(fid,'%s,%d,',param.time,param.dratio); % general parameters
fprintf(fid,'%d,%s,%4.2f,%d,',param.feature.block_sz,param.feature.method,param.feature.tt,param.feature.T); % general features
fprintf(fid,'%d,%d,',param.feature.geom.t,param.feature.geom.go); % features geom
fprintf(fid,'%d,%d,',param.feature.haar.t,param.feature.haar.go); % features haar
fprintf(fid,'%d,%d,%4.2f,%d,%d,%d,%d,',param.feature.hog.hx,param.feature.hog.hy,param.feature.hog.trim,param.feature.hog.wcell,param.feature.hog.nbins,param.feature.hog.t,param.feature.hog.go); % features hog
fprintf(fid,'%d,%d,%d,%4.2f,%s,',param.train.dmin,param.train.dmax,param.train.k_nn,param.train.thresh_std,param.train.type); % train
fprintf(fid,'%d,%d,',param.test.dmin,param.test.dmax); % test
fprintf(fid,'%4.3f,',param.boost.miu); % boost % wei 01/09/2010 keep 3 digits after the decimal point
fprintf(fid,'%4.2f,%4.2f,',param.craters.d_erase,param.craters.xy_erase); % craters
fprintf(fid,'%4.2f,%d,',param.compare.d_tol,param.compare.xy_tol); % compare

%% training set

%fprintf(fid,'%d,%d,',train.ds.pos,train.ds.neg);
fprintf(fid,'%d,%d,',train.pos,train.neg);

%% results

tp_global = [];
fp_global = [];
fn_global = [];
fnobj_global = [];
db_global = [];
tn_global=0;

for k = 1:param.test.sz_dataset

    tp_global = [tp_global; result(k).tp];
    fp_global = [fp_global; result(k).fp];
    fn_global = [fn_global; result(k).fn];
    fnobj_global = [fnobj_global; result(k).fn_obj];
    
    tn_global=size(non_craters(k).index,1)+tn_global;
    db_global = [db_global; result(k).db];
    
    
end
tn_global=tn_global-sum(2*fn_global(:,3)>=param.test.dmin,1);
 fprintf(fid,'%d,%d,%d,%d,%d,%d\n',(size(tp_global,1)+size(db_global,1)),size(fp_global,1),sum(2*fn_global(:,3)>=param.test.dmin,1),sum(2*fnobj_global(:,3)>=param.test.dmin,1),tn_global,size(db_global,1));
%fprintf(fid,'%d,%d,%d,%d,%d\n',sum(2*tp_global(:,3)>=16,1),sum(2*fp_global(:,3)>=16,1),sum(2*fn_global(:,3)>=16,1),sum(2*fnobj_global(:,3)>=16,1),sum(2*db_global(:,3)>=16,1));
%fprintf(fid,'%d,%d,%d,%d,%d\n',sum(2*tp_global(:,3)>40,1),sum(2*fp_global(:,3)>40,1),sum(2*fn_global(:,3)>40,1),sum(2*fnobj_global(:,3)>40,1),sum(2*db_global(:,3)>40,1));

fclose(fid);
