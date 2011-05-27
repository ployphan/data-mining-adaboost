clear, clc,

folders = dir;
% all folders inside the main directory must be important!

for k = 3:size(folders,1)
    
    % if file is not directory, jump to next file
    if ~folders(k).isdir, continue, end
    
    % move inside the directory
    cd([folders(k).name '\weka'])
    
    filename = [folders(k).name 'candidatesids.txt'];
        
    L = dlmread(filename,'\t',1,0);
    
    index = L(:,1);
    PixMeanX = L(:,4);
    PixMeanY = L(:,5);
    PixDiameter = L(:,6);
    
    cdt = [index PixMeanX PixMeanY PixDiameter];
    
    str = ['..\..\label\' folders(k).name '_cdt'];
    
    % jump back to previous directory
    cd ..
    cd ..
    
    save(str,'cdt')
    
    fprintf(1,'>> candidates for image %s were saved\n',folders(k).name)
    
    % copyfile([folders(k).name '/input/' folders(k).name '.pgm'],'../images')
    % disp('>> image file was also copied')
    
end