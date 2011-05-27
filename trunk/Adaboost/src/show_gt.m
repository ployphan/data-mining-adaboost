function show_gt(filename,gt)

img_filename = ['.\' filename '\input\' filename 's.pgm'];
img = imread(img_filename);

figure,
imshow(img),
colormap(gray),
daspect([1 1 1]),

nseg = 64;
S = 'b-';

hold on,
for i=1:size(gt,1)

    x=gt(i,1);
    y=gt(i,2);
    r=gt(i,3);

    theta = 0 : (2 * pi / nseg) : (2 * pi);
    pline_x = r * cos(theta) + x;
    pline_y = r * sin(theta) + y;

    plot(pline_x, pline_y, S);

end
hold off,

pause