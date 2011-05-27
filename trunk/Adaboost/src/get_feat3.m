function features = get_feat3(ii)

S = size(ii,1); % ii is a square

% EXTRACT STRIPE AREAS

% VERTICAL
% *************************************************************************

% vertical left stripe
a1 = ii(1,1);
a2 = ii(1,S/3);
a3 = ii(S,1);
a4 = ii(S,S/3);

stripe_a = a4 + a1 - (a2 + a3);

% vertical central stripe
b1 = ii(1,S/3+1);
b2 = ii(1,2*S/3);
b3 = ii(S,S/3+1);
b4 = ii(S,2*S/3);

stripe_b = b4 + b1 - (b2 + b3);

% vertical right stripe
c1 = ii(1,2*S/3+1);
c2 = ii(1,S);
c3 = ii(S,2*S/3+1);
c4 = ii(S,S);

stripe_c = c4 + c1 - (c2 + c3);

% HORIZONTAL
% *************************************************************************

% horizontal top stripe
d1 = ii(1,1);
d2 = ii(1,S);
d3 = ii(S/3,1);
d4 = ii(S/3,S);

stripe_d = d4 + d1 - (d2 + d3);

% horizontal central stripe
e1 = ii(S/3+1,1);
e2 = ii(S/3+1,S);
e3 = ii(2*S/3,1);
e4 = ii(2*S/3,S);

stripe_e = e4 + e1 - (e2 + e3);

% horizontal bottom stripe
f1 = ii(2*S/3+1,1);
f2 = ii(2*S/3+1,S);
f3 = ii(S,1);
f4 = ii(S,S);

stripe_f = f4 + f1 - (f2 + f3);


% f1 = ii(1,1);
% f2 = ii(1,S);
% f3 = ii(S,1);
% f4 = ii(S,S);
% 
% square_total = f4 + f1 - (f2 + f3);


% FEATURES
% *************************************************************************
% normalization [-1 1]...

% vertical bar
feature1 = (stripe_a + stripe_c) - stripe_b;
feature1 = feature1*(2/(S*S))-1/3;
% feature1 = feature1*(2/(255*S*S));

% horizontal bar
feature2 = (stripe_d + stripe_f) - stripe_e;
feature2 = feature2*(2/(S*S))-1/3;

features = [feature1 feature2];