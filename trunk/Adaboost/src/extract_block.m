function points = extract_block(ii,cx,cy,r)

m = r/3;

% first line corresponds to the 9 points of a 4 block square
xi = [cx-r, cx, cx+r, cx-r, cx, cx+r, cx-r, cx, cx+r,...
    cx-m, cx+m, cx-r, cx-m, cx+m, cx+r, cx-r, cx-m, cx+m, cx+r, cx-m, cx+m];

yi = [cy-r, cy-r, cy-r, cy, cy, cy, cy+r, cy+r, cy+r,...
    cy-r, cy-r, cy-m, cy-m, cy-m, cy-m, cy+m, cy+m, cy+m, cy+m, cy+r, cy+r];

% Method by default is Bilinear interpolation
points = interp2(ii,xi,yi);