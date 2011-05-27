function generate_results(craters)


global param

% nseg = 64;
% theta = 0 : (2 * pi / nseg) : (2 * pi);

tp_global = [];
fp_global = [];
fn_global = [];
fnobj_global = [];
db_global = [];


for img_n = 1:param.test.sz_dataset
    
    %% Extract quantities
    filename = param.test.filenames{img_n};
    
    img_filename = ['.\' filename '\input\' filename 's.pgm'];
    img = imread(img_filename);
    
    img_sx = size(img,2);
    img_sy = size(img,1);
    
    [tp,fp,fn,db,index_res,fn_obj,hh,hhtp] = extract_rates(filename,craters(img_n),img_sx,img_sy);
    
   
    fileprob=[param.prob.path filename 'hh.mat'];
    fileprobtp=[param.prob.path filename 'hhtp.mat'];
    save(fileprob,'hh');
    save(fileprobtp,'hhtp');
    
    
    %% Show results
    
    fprintf(1,'>> TRUES: (tp=%d / db=%d) FALSES: (fp=%d / fn=%d)\n',size(tp,1),size(db,1),size(fp,1),size(fn,1));
    
%     figure,
%     imshow(img),
%     % colormap(gray),
%     daspect([1 1 1]),
%     hold on,
%     
%     for ctp = 1:size(tp,1)
%         
%         pline_x = tp(ctp,3) * cos(theta) + tp(ctp,1);
%         pline_y = tp(ctp,3) * sin(theta) + tp(ctp,2);
%         
%         plot(pline_x, pline_y, 'g-','LineWidth',2);
%         
%     end
%     
%     for cfp = 1:size(fp,1)
%         
%         pline_x = fp(cfp,3) * cos(theta) + fp(cfp,1);
%         pline_y = fp(cfp,3) * sin(theta) + fp(cfp,2);
%         
%         plot(pline_x, pline_y, 'r-','LineWidth',2);
%         
%     end
%     
%     for cfn = 1:size(fn,1)
%         
%         pline_x = fn(cfn,3) * cos(theta) + fn(cfn,1);
%         pline_y = fn(cfn,3) * sin(theta) + fn(cfn,2);
%         
%         plot(pline_x, pline_y, 'b-','LineWidth',2);
%         
%     end
%     
%     for cdb = 1:size(db,1)
%         
%         pline_x = db(cdb,3) * cos(theta) + db(cdb,1);
%         pline_y = db(cdb,3) * sin(theta) + db(cdb,2);
%         
%         plot(pline_x, pline_y, 'y-','LineWidth',2);
%         
%     end
%     
%     for cfn_obj = 1:size(fn_obj,1)
%         
%         pline_x = fn_obj(cfn_obj,3) * cos(theta) + fn_obj(cfn_obj,1);
%         pline_y = fn_obj(cfn_obj,3) * sin(theta) + fn_obj(cfn_obj,2);
%         
%         plot(pline_x, pline_y, 'c-','LineWidth',2);
%         
%     end
%     
%     hold off,
%     
%     figure(param.test.sz_dataset+1),
%     subplot(2,3,img_n),
%     
%     for d = param.test.dmin:40
%         
%         % taking into consideration objects missing
%         n_fn_obj = sum(2*fn_obj(:,3) >= d);
%         
%         n_tp = sum(2*tp(:,3) >= d);
%         n_fp = sum(2*fp(:,3) >= d);
%         n_fn = sum(2*fn(:,3) >= d);
%         n_db = sum(2*db(:,3) >= d);
%         
%         n_fn = n_fn - n_fn_obj;
%         
%         dr = n_tp/(n_tp+n_fn);
%         fr = n_fp/(n_tp+n_fp);
%         bf = n_fp/n_tp;
%         qr = n_tp/(n_tp+n_fp+n_fn);
%         f_measure = 2*n_tp/(2*n_tp+n_fp+n_fn);
%         
%         dbr = n_db/(n_tp+n_fn+n_db);
%         
%         plot(d,dr*100,'ko',d,fr*100,'k.',d,bf*100,'k*',d,bf*100,d,qr*100,'kx',d,f_measure*100,'k^',d,dbr*100,'k.'),hold on,
%         
%         n_fn = sum(2*fn(:,3) >= d);
%         
%         dr = n_tp/(n_tp+n_fn);
%         fr = n_fp/(n_tp+n_fp);
%         bf = n_fp/n_tp;
%         qr = n_tp/(n_tp+n_fp+n_fn);
%         f_measure = 2*n_tp/(2*n_tp+n_fp+n_fn);
%         
%         dbr = n_db/(n_tp+n_fn+n_db);
%         
%         plot(d,dr*100,'go',d,fr*100,'y.',d,bf*100,'r*',d,bf*100,d,qr*100,'bx',d,f_measure*100,'c^',d,dbr*100,'k.'),hold on,
%         
%         set(gca,'YGrid','on')
%     end
%     
%     % legend('detection percentage','false (detection) percentage','branching factor','quality percentage'),
%     title(filename)
%     xlabel('diameter (px)'),
%     ylabel('percentage'),
%     
%     axis([param.test.dmin 40 0 100]),
%     
%     hold off,
    
    result(img_n).id = filename;
    result(img_n).index = index_res;
    result(img_n).tp = tp;
    result(img_n).fp = fp;
    result(img_n).fn = fn;
    result(img_n).fn_obj = fn_obj;
    result(img_n).db = db;
    
    % pause(1),
    
    tp_global = [tp_global; tp];
    fp_global = [fp_global; fp];
    fn_global = [fn_global; fn];
    fnobj_global = [fnobj_global; fn_obj];
    db_global = [db_global; db];
    
end


if ~isdir(param.compare.path)
    mkdir(param.compare.path)
end

% register filename with time
compare_filename = [param.compare.path param.time '.mat'];

save(compare_filename,'result');

fprintf(1,'>> result %s compared and saved\n',compare_filename);




% figure(param.test.sz_dataset+2),
% 
% for d = param.test.dmin:40
%     
%     % taking into consideration objects missing
%     n_fn_obj = sum(2*fnobj_global(:,3) >= d);
%     
%     n_tp = sum(2*tp_global(:,3) >= d);
%     n_fp = sum(2*fp_global(:,3) >= d);
%     n_fn = sum(2*fn_global(:,3) >= d);
%     n_db = sum(2*db_global(:,3) >= d);
%     
%     n_fn = n_fn - n_fn_obj;
%     
%     dr = n_tp/(n_tp+n_fn);
%     fr = n_fp/(n_tp+n_fp);
%     bf = n_fp/n_tp;
%     qr = n_tp/(n_tp+n_fp+n_fn);
%     f_measure = 2*n_tp/(2*n_tp+n_fp+n_fn);
%     
%     dbr = n_db/(n_tp+n_fn+n_db);
%     
%     plot(d,dr*100,'ko',d,fr*100,'k.',d,bf*100,'k*',d,bf*100,d,qr*100,'kx',d,f_measure*100,'k^',d,dbr*100,'k.'),hold on,
%     
%     n_fn = sum(2*fn_global(:,3) >= d);
%     
%     dr = n_tp/(n_tp+n_fn);
%     fr = n_fp/(n_tp+n_fp);
%     bf = n_fp/n_tp;
%     qr = n_tp/(n_tp+n_fp+n_fn);
%     f_measure = 2*n_tp/(2*n_tp+n_fp+n_fn);
%     
%     dbr = n_db/(n_tp+n_fn+n_db);
%     
%     plot(d,dr*100,'go',d,fr*100,'y.',d,bf*100,'r*',d,bf*100,d,qr*100,'bx',d,f_measure*100,'c^',d,dbr*100,'k.'),hold on,
%     
%     set(gca,'YGrid','on')
% end
% 
% % legend('detection percentage','false (detection) percentage','branching factor','quality percentage'),
% xlabel('diameter (px)'),
% ylabel('percentage'),
% 
% axis([param.test.dmin 40 0 100]),
% 
% hold off,
% 
% print('-r300','-djpeg',[param.compare.path param.time]);

