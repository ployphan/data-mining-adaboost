function [features] = get_feat(ii)


S = size(ii,1); % ii is a square


% EXTRACT SQUARE AREAS
% *************************************************************************

% top left
a1 = ii(1,1);
a2 = ii(1,S/2);
a3 = ii(S/2,1);
a4 = ii(S/2,S/2);

square_a = a4 + a1 - (a2 + a3);

% top right
b1 = ii(1,S/2+1);
b2 = ii(1,S);
b3 = ii(S/2,S/2+1);
b4 = ii(S/2,S);

square_b = b4 + b1 - (b2 + b3);

% bottom left
c1 = ii(S/2+1,1);
c2 = ii(S/2+1,S/2);
c3 = ii(S,1);
c4 = ii(S,S/2);

square_c = c4 + c1 - (c2 + c3);

% bottom right
d1 = ii(S/2+1,S/2+1);
d2 = ii(S/2+1,S);
d3 = ii(S,S/2+1);
d4 = ii(S,S);

square_d = d4 + d1 - (d2 + d3);

f1 = ii(1,1);
f2 = ii(1,S);
f3 = ii(S,1);
f4 = ii(S,S);

square_total = f4 + f1 - (f2 + f3);


% FEATURES
% *************************************************************************
% normalization [-1 1]...

% vertical bar
feature1 = square_a + square_c - (square_b + square_d);
feature1 = feature1*(2/(S*S));
% feature1 = feature1*(2/(255*S*S));

% horizontal bar
feature2 = square_a + square_b - (square_c + square_d);
feature2 = feature2*(2/(S*S));

% chess
feature3 = square_a + square_d - (square_b + square_c);
feature3 = feature3*(2/(S*S));

% individual squares
feature4 = square_total - 2*square_a;
feature5 = square_total - 2*square_b;
feature6 = square_total - 2*square_c;
feature7 = square_total - 2*square_d;

feature4 = feature4*(2/(S*S)) - 0.5;
feature5 = feature5*(2/(S*S)) - 0.5;
feature6 = feature6*(2/(S*S)) - 0.5;
feature7 = feature7*(2/(S*S)) - 0.5;

features = [feature1 feature2 feature3 feature4 feature5 feature6 feature7];