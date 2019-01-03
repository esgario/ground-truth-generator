function [ Y ] = IlluminationCorrection( J )

[rows,cols] = size(J);
n = rows; m = cols;
V = imresize(J,[n m]);

% LAB color space normalizing
V_normalized = V/100;

%% Otsu
level = graythresh(V_normalized);
BW = im2bw(V_normalized,level);
Z = double(BW(:));

%% Regression
ii = find(Z==1);
[X1,X2] = meshgrid(1:m,1:n);
X = [ones(size(X1(ii))) X1(ii) X2(ii) X1(ii).*X2(ii) X1(ii).^2 X2(ii).^2];

P = regress(V(ii),X);
Y = P(1) + P(2)*X1 + P(3)*X2 + P(4)*X1.*X2 + P(5)*(X1.^2) + P(6)*(X2.^2);

% plot3(X1,X2,V,'*b'); hold on;
% mesh(X1,X2,Y); hold off;
% waitforbuttonpress;

Y = imresize(Y,[rows cols]);
Y = J - Y + mean(Y(:));
