function visualize_results(result)
% visualize_results(result)
% function that visualizes the TP, FP, FN on images
%
% Wei Ding
% Jan 2010


global param
nseg = 64;
theta = 0 : (2 * pi / nseg) : (2 * pi);
min_radius = 16 /2;


for img_n = 1:param.test.sz_dataset
    
    filename = param.test.filenames{img_n};
    
    img_filename = ['.\' filename '\input\' filename '.pgm'];
    img = imread(img_filename);
    
    img_sx = size(img,2);
    img_sy = size(img,1);
    
    clear tp_index fp_index fn_index db_index fn_obj_index tp fp fn db fn_obj
    tp_index=result(1,img_n).tp(:,3)>= min_radius;
    fp_index=result(1,img_n).fp(:,3)>= min_radius;
    fn_index=result(1,img_n).fn(:,3)>= min_radius;
    db_index=result(1,img_n).db(:,3)>= min_radius;
    fn_obj_index=result(1,img_n).fn_obj(:,3)>= min_radius;
    
    tp=result(1,img_n).tp(tp_index,:);
    fp=result(1,img_n).fp(fp_index,:);
    fn=result(1,img_n).fn(fn_index,:);
    db=result(1,img_n).db(db_index,:);
    fn_obj= result(1,img_n).fn_obj(fn_obj_index,:);
    
    
    %% Show results
    
    
    
    figure,
    imshow(img),
    % colormap(gray),
    daspect([1 1 1]),
    hold on,
    
    for ctp = 1:size(tp,1)
        
        pline_x = tp(ctp,3) * cos(theta) + tp(ctp,1);
        pline_y = tp(ctp,3) * sin(theta) + tp(ctp,2);
        
        plot(pline_x, pline_y, 'g-','LineWidth',2);
        
    end
    
    for cfp = 1:size(fp,1)
        
        pline_x = fp(cfp,3) * cos(theta) + fp(cfp,1);
        pline_y = fp(cfp,3) * sin(theta) + fp(cfp,2);
        
        plot(pline_x, pline_y, 'r-','LineWidth',2);
        
    end
    
    for cfn = 1:size(fn,1)
        
        pline_x = fn(cfn,3) * cos(theta) + fn(cfn,1);
        pline_y = fn(cfn,3) * sin(theta) + fn(cfn,2);
        
        plot(pline_x, pline_y, 'b-','LineWidth',2);
        
    end
    
    for cdb = 1:size(db,1)
        
        pline_x = db(cdb,3) * cos(theta) + db(cdb,1);
        pline_y = db(cdb,3) * sin(theta) + db(cdb,2);
        
        plot(pline_x, pline_y, 'y:','LineWidth',2);
        
    end
    
    for cfn_obj = 1:size(fn_obj,1)
        
        pline_x = fn_obj(cfn_obj,3) * cos(theta) + fn_obj(cfn_obj,1);
        pline_y = fn_obj(cfn_obj,3) * sin(theta) + fn_obj(cfn_obj,2);
        
        plot(pline_x, pline_y, 'c-','LineWidth',2);
        
    end
    
    hold off,
    %wei: save the classified test set figure
    %tp=green, fp=red,fn=blue,db=yellow(tp duplicates), cyan=fn_obj(# of GT not covered by candidates at all)
    print('-r300','-djpeg',[param.compare.path param.time filename]);
    
end


