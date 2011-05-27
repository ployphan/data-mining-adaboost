function features = get_feat_v2(points,block_size)


block_area = block_size*block_size;

% EXTRACT SQUARE AREAS
% *************************************************************************

% top left
square_a = points(5) + points(1) - (points(2) + points(4));

% top right
square_b = points(6) + points(2) - (points(3) + points(5));

% bottom left
square_c = points(8) + points(4) - (points(5) + points(7));

% bottom right
square_d = points(9) + points(5) - (points(6) + points(8));

% entire block
square_total = points(9) + points(1) - (points(3) + points(7));

% vertical central stripe
stripe_v = points(21) + points(10) - (points(11) + points(20));

% horizontal central stripe
stripe_h = points(19) + points(12) - (points(15) + points(16));


% FEATURES
% *************************************************************************
% normalization [-1 1]...

% vertical bar
feature1 = square_a + square_c - (square_b + square_d);
feature1 = feature1*(2/block_area);

% other normalization alternative,
% feature1 = feature1*(2/(255*block_area));

% horizontal bar
feature2 = square_a + square_b - (square_c + square_d);
feature2 = feature2*(2/block_area);

% chess
feature3 = square_a + square_d - (square_b + square_c);
feature3 = feature3*(2/block_area);

% individual squares
feature4 = square_total - 2*square_a;
feature5 = square_total - 2*square_b;
feature6 = square_total - 2*square_c;
feature7 = square_total - 2*square_d;

feature4 = feature4*(2/block_area) - 0.5;
feature5 = feature5*(2/block_area) - 0.5;
feature6 = feature6*(2/block_area) - 0.5;
feature7 = feature7*(2/block_area) - 0.5;

% vertical bar
feature8 = square_total - 2*stripe_v;
feature8 = feature8*(2/block_area)-1/3;

% horizontal bar
feature9 = square_total - 2*stripe_h;
feature9 = feature9*(2/block_area)-1/3;

features = [feature1 feature2 feature3 feature4 feature5 feature6 feature7 feature8 feature9];