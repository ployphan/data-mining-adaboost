function plot_shapes(result)


sheet_testset = 'testset';

% read test set file sheet
[numeric, text] = xlsread('filenames',sheet_testset,strcat('A1:A',num2str(result(1).param.n_images)));

% WARNING!!!
% Header is not generic!! (this is only for tile3_25)

% ncols         1700
% nrows         1700
% xllcorner     -1885
% yllcorner     318900
% cellsize      12.5
% NODATA_value  0

header = {'ncols         1700'; 'nrows         1700'; 'xllcorner     -1885'; 'yllcorner     318900'; 'cellsize      12.5'; 'NODATA_value  -9999'};


%% ANALYZE EACH IMAGE IN TEST SET
for img_n = 1:result(1).param.n_images
    
    %% SHOW CANDIDATES
    filename = text{img_n};
    
    shapes_filename = strcat('.\shapes\',filename,'_shapes.mat');
    load(shapes_filename);
    
    load_msg = sprintf('>> file %s was loaded',shapes_filename);
    disp(load_msg);
    
    label = result(img_n).label_res;
    
    for k = 1:size(shapes,2)
        
        new_shapes = shapes(k).L;
        
        label_shapes = unique(new_shapes);
        stats = regionprops(new_shapes,'PixelIdxList');
        
        %% TRUE POSITIVES
        
        % write file header
        fid = fopen(['.\tp\' filename '_' num2str(k) '.txt'],'wt');
        for line = 1:size(header)
            fprintf(fid,[header{line} '\n']);
        end
        fclose(fid);
        
        index_tp = label(:,2) == 1;
        
        index_remove = setdiff(label_shapes,label(index_tp,1));

        new_shapes(new_shapes == 0) = -9999;

        for n = 2:size(index_remove,1)
            
            new_shapes(stats(index_remove(n)).PixelIdxList) = -9999;
        end
        
        dlmwrite(['.\tp\' filename '_' num2str(k) '.txt'],new_shapes,'-append','delimiter',' ')
        
        clear index_tp index_remove
        
        %% FALSE POSITIVES
        
        % write file header
        fid = fopen(['.\fp\' filename '_' num2str(k) '.txt'],'wt');
        for line = 1:size(header)
            fprintf(fid,[header{line} '\n']);
        end
        fclose(fid);
        
        new_shapes = shapes(k).L;
        
        index_fp = label(:,2) == 0;
        
        index_remove = setdiff(label_shapes,label(index_fp,1));
        
        new_shapes(new_shapes == 0) = -9999;
        
        for n = 2:size(index_remove,1)
            
            new_shapes(stats(index_remove(n)).PixelIdxList) = -9999;
        end
        
        dlmwrite(['.\fp\' filename '_' num2str(k) '.txt'],new_shapes,'-append','delimiter',' ')
        
    end
end