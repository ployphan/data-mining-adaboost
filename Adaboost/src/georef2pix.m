function gt_ref = georef2pix(filename,gt)

a = str2double(filename(5));
b = str2double(filename(7:8));

% in pixels, for the right tile,
x = gt(:,1) - 1500*(a-1);
y = gt(:,2) - 1500*(b-24);

gt_ref = [x y gt(:,3)];

end