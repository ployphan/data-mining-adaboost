function convert_objects()


% all folders inside the main directory must be tiles
folders = dir;

for f = 3:size(folders,1)
    
    % if file is not directory, jump to next file
    if ~folders(f).isdir, continue, end
    
    % move inside the directory
    cd([folders(f).name '\weka'])
    
    filename = [folders(f).name 'candidatesids.txt'];
    D1 = dlmread(filename,'\t',1,0);
    
    %     obj.index = D1(:,1);
    %     obj.BrightIndex = D1(:,2);
    %     obj.DarkIndex = D1(:,3);
    %     obj.PixMeanX = D1(:,4);
    %     obj.PixMeanY = D1(:,5);
    %     obj.PixDiameter = D1(:,6);
    %     obj.MeterMeanX = D1(:,7);
    %     obj.MeterMeanY = D1(:,8);
    %     obj.MeterDiameter = D1(:,9);
    %     obj.Longitude = D1(:,10);
    %     obj.Latitude = D1(:,11);
    %     obj.Angle = D1(:,12);
    
    filename = [folders(f).name 'candidatestest.arff'];
    D2 = dlmread(filename,',',21,0);
    
    %     obj.BrightLength = D2(:,1);
    %     obj.Distance = D2(:,2);
    %     obj.AreaRatio = D2(:,3);
    %     obj.BrightElongation = D2(:,4);
    %     obj.DarkElongation = D2(:,5);
    %     obj.BothElongation = D2(:,6);
    %     obj.Dissimilarity = D2(:,7);
    %     obj.Circularity = D2(:,8);
    %     obj.Hu1 = D2(:,9);
    %     obj.Hu2 = D2(:,10);
    %     obj.Hu3 = D2(:,11);
    %     obj.Hu4 = D2(:,12);
    %     obj.Hu5 = D2(:,13);
    %     obj.Hu6 = D2(:,14);
    %     obj.Hu7 = D2(:,15);
    %     obj.class = D2(:,16);
    
    for k = 1:size(D1,1)
        obj(k).index = D1(k,1);
        obj(k).BrightIndex = D1(k,2);
        obj(k).DarkIndex = D1(k,3);
        obj(k).PixMeanX = D1(k,4);
        obj(k).PixMeanY = D1(k,5);
        obj(k).PixDiameter = D1(k,6);
        obj(k).MeterMeanX = D1(k,7);
        obj(k).MeterMeanY = D1(k,8);
        obj(k).MeterDiameter = D1(k,9);
        obj(k).Longitude = D1(k,10);
        obj(k).Latitude = D1(k,11);
        obj(k).Angle = D1(k,12);
        obj(k).BrightLength = D2(k,1);
        obj(k).Distance = D2(k,2);
        obj(k).AreaRatio = D2(k,3);
        obj(k).BrightElongation = D2(k,4);
        obj(k).DarkElongation = D2(k,5);
        obj(k).BothElongation = D2(k,6);
        obj(k).Dissimilarity = D2(k,7);
        obj(k).Circularity = D2(k,8);
        obj(k).Hu1 = D2(k,9);
        obj(k).Hu2 = D2(k,10);
        obj(k).Hu3 = D2(k,11);
        obj(k).Hu4 = D2(k,12);
        obj(k).Hu5 = D2(k,13);
        obj(k).Hu6 = D2(k,14);
        obj(k).Hu7 = D2(k,15);
        obj(k).class = 9; % D2(:,16);
    end
    
    %     obj(1:size(D1,1)) = struct('index',D1(:,1),'BrightIndex',D1(:,2),'DarkIndex',D1(:,3),...
    %         'PixMeanX',D1(:,4),'PixMeanY',D1(:,5),'PixDiameter',D1(:,6),...
    %         'MeterMeanX',D1(:,7),'MeterMeanY',D1(:,8),'MeterDiameter',D1(:,9),...
    %         'Longitude',D1(:,10),'Latitude',D1(:,11),'Angle',D1(:,12),...
    %         'BrightLength',D2(:,1),'Distance',D2(:,2),'AreaRatio',D2(:,3),...
    %         'BrightElongation',D2(:,4),'DarkElongation',D2(:,5),'BothElongation',D2(:,6),...
    %         'Dissimilarity',D2(:,7),'Circularity',D2(:,8),'Hu1',D2(:,9),...
    %         'Hu2',D2(:,10),'Hu3',D2(:,11),'Hu4',D2(:,12),'Hu5',D2(:,13),...
    %         'Hu6',D2(:,14),'Hu7',D2(:,15),'class',9);
    
    % jump back to previous directory
    cd ..
    cd ..
    
    if ~isdir('..\..\conversion\')
        mkdir('..\..\conversion\')
    end
    
    str = ['..\..\conversion\' folders(f).name];
    
    save(str,'obj');
    
    fprintf(1,'>> objects for image %s were converted and saved\n',folders(f).name)
    
    % copyfile([folders(k).name '/input/' folders(k).name '.pgm'],'../images')
    % disp('>> image file was also copied')
    clear obj; %wei 01/08/2010 clear out the variable to be ready for the next candidate data file
    
end