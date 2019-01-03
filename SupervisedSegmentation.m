function [imgMask, pxIndex, pxLabel] = SupervisedSegmentation(imgOriginal_RGB, algorithm, algorithmArgs, inputPxIndex, imgPreprocessed)

%
% Versão modificada, sem etapa de preprocessamento
%

% Interactive Fuzzy KNN Segmentation 
% 
% Algorithm:
%   1. Read lesion points supplied by the expert
% Preprocessing steps
%   2. Remove hair
%   3. Converto to Lab color space
%   4. Illumination correction
%   5. Median filter
% Segmentation
%   6. Fuzzy KNN
% Postprocessing
%   7. Remove objects whose seeds doesn't belong to it.
%   8. Morphological operation: dilatation
%   9. Hole fill
% Return mask
% ---------------------------------------- %
% Input:
% I - Image
% Output:
% mask - Segmentation mask

[rows,cols,~] = size(imgOriginal_RGB);

% 1. Get input points
if nargin < 4
    [pxIndex, pxLabel] = readPoints(imgOriginal_RGB);
else
    pxIndex = inputPxIndex(:,1:2);
    pxLabel = inputPxIndex(:,end);
end

% Color space conversion
imgProcessed_LAB = rgb2lab(imgOriginal_RGB);

% 5. Normalizing
for i=1:3
    M = max(max(imgProcessed_LAB(:,:,i)));
    m = min(min(imgProcessed_LAB(:,:,i)));
    imgProcessed_LAB(:,:,i) = (M - imgProcessed_LAB(:,:,i))./(M - m);
end

for i=1:3
    imgProcessed_LAB(:,:,i) = medfilt2(imgProcessed_LAB(:,:,i),[5 5]);
end

% Pixels position information
[X,Y] = meshgrid(1:rows,1:cols); X = X'; Y = Y'; X = X(:); Y = Y(:);
pxIndexAux = double(pxIndex);
pxIndexAux = [ pxIndexAux(:,1) pxIndexAux(:,2) ];

% Seeds
colorSeed = zeros(length(pxLabel),3);
for j=1:length(pxLabel)
    colorSeed(j,:) = reshape(imgProcessed_LAB(pxIndex(j,1), pxIndex(j,2),:),[1 3]);
end

% SEGMENTATION -------------------------- %
featuresTrain = [ colorSeed pxIndexAux ];
featuresTest  = [ reshape(imgProcessed_LAB,[rows*cols 3]) X(:) Y(:) ];

switch (algorithm)
    case 'NN'
        [class] = NN(featuresTrain, pxLabel, featuresTest, [ rows cols ], algorithmArgs);
    case 'FKNN'
        [class, membership] = FuzzyKNN(featuresTrain, pxLabel, featuresTest, 3, [ rows cols ], algorithmArgs);
    case 'FCM'
        [class, membership] = FuzzyCM(featuresTrain, pxLabel, featuresTest, 3, [ rows cols ], algorithmArgs);
end
% 6. Creating mask
imgMask = double(class); % If use Weigthed KNN
imgMask = reshape(imgMask, [ rows cols ]);

% POSTPROCESSING -------------------------- %

% 7. Select objects with seeded pxs
CC = bwconncomp(imgMask); %
LM = labelmatrix(CC);
lesionPxIndex = pxIndex(find(pxLabel==1),:);
for i=1:size(lesionPxIndex, 1)
    imgMaskLabel(i) = LM(lesionPxIndex(i, 1), lesionPxIndex(i, 2));
end
imgMask = ismember(LM, imgMaskLabel);
imgMask = logical(imgMask);

% 8. morphological operation: Opening / Closing
SE = strel('disk', 5);
imgMask = imclose(imgMask, SE);
imgMask = imopen(imgMask, SE);

% 9. hole fill
imgMask = imfill(imgMask, 'holes');

% if algorithmArgs == 0.1
% % Creating heatmap based on fuzzy probabilities
% heatmap = sum(membership(:, find(pxLabel==1)), 2);
% heatmap = reshape(heatmap, [ rows cols ]);
% heatmap = imfilter(heatmap, ones(3,3)/9);
% 
% % Plot mask and heatmap
% figure(2);
% subplot(121); imshow(imgMask);
% subplot(122);
% imagesc(heatmap, [0 1]); 
% colorbar; colormap(jet(100));
% waitforbuttonpress;
% end

%% Fuzzy KNN
% ---------------------------------------------------------------------- %
function [classhypo, u] = FuzzyKNN(features_train, labels_train, features_test, m, imSize, L)

features_test = double(features_test);
features_train = double(features_train);

if L(1) ~= 0
    Dlab = pdist2(features_test(:,1:3),features_train(:,1:3),'euclidean')'; % Compute distances between train and dev vectors
    Dxy = pdist2(features_test(:,4:5),features_train(:,4:5),'euclidean')';
    D = Dlab + (L/norm(imSize)) * Dxy;
else
    D = pdist2(features_test(:,1:3),features_train(:,1:3),'euclidean')';
end

den = zeros(1,size(D,2));
for i=1:size(features_train,1)
    den = den + (D(i,:).^(-2/(m-1)));
end

den(find(den==inf)) = 10000;

u = zeros(size(features_test,1),size(features_train,1));
for i=1:size(features_train,1)
    u(:,i) = (D(i,:).^(-2/(m-1)))./den;
end

u(find(u==inf)) = 1;

% [values, ind] = max(u,[],2);
% classhypo = labels_train(ind);

alpha = 10;

% Weighted KNN
ifore = find(labels_train==1);
iback = find(labels_train==0);

w = zeros(size(u,1),2);

% A = mean(u(:,iback),2);
% B = mean(u(:,ifore),2);

A = sum((u(:,iback).^alpha)/length(iback), 2).^(1/alpha);
B = sum((u(:,ifore).^alpha)/length(ifore), 2).^(1/alpha);

den = A + B;
w(:,1) = A./den;
w(:,2) = B./den;

[values,classhypo] = max(w,[],2);
classhypo = classhypo - 1;

% -------------------------------------- %

%% Nearest Neighbor
% ---------------------------------------------------------------------- %
function [classhypo] = NN(features_train, labels_train, features_test, imSize, L)

features_test = double(features_test);
features_train = double(features_train);

if L(1) ~= 0
    Dlab = pdist2(features_test(:,1:3),features_train(:,1:3),'euclidean')'; % Compute distances between train and dev vectors
    Dxy = pdist2(features_test(:,4:5),features_train(:,4:5),'euclidean')';
    D = Dlab + (L/norm(imSize)) * Dxy;
else
    D = pdist2(features_test(:,1:3),features_train(:,1:3),'euclidean')';
end

if size(D,1) > 1
    [values, ind] = min(D);
    classhypo = labels_train(ind);
else
    classhypo = zeros(1, imSize(1) * imSize(2));
end
% -------------------------------------- %

function [classhypo, u] = FuzzyCM(features_train, labels_train, features_test, m, imSize, L)

features_test = double(features_test);
features_train = double(features_train);

D = pdist2(features_test(:,1:3),features_train(:,1:3),'euclidean')';

den = zeros(1,size(D,2));
for i=1:size(features_train,1)
    den = den + (D(i,:).^(-2/(m-1)));
end

den(find(den==inf)) = 10000;

u = zeros(size(features_test,1),size(features_train,1));
for i=1:size(features_train,1)
    u(:,i) = (D(i,:).^(-2/(m-1)))./den;
end

u(find(u==inf)) = 1;
[u,ind] = sort(u,2,'descend');

ind = labels_train(ind);
n_elem = max(round(size(ind,2)*L/100),1);
classhypo = zeros(size(ind,1),1);
classhypo(find(mean(double(ind(:,1:n_elem)),2) == 1)) = 1;

%% Read Points
% ---------------------------------------------------------------------- %
function [pxIndex, label] = readPoints(img)
%readPoints   Read manually-defined points from image

figure(1);
imshow(img);  % display image
hold on;        % and keep it there while we plot

% Variables
label = [];
k = 0;
pxIndex = [];

while 1
    [xi, yi, but] = ginput(1);      % get a point
    if ~isequal(but, 1) & ~isequal(but, 3)             % stop if not button 1
        break
    end
    
    k = k + 1;
    pxIndex(1,k) = xi;
    pxIndex(2,k) = yi;

    if but == 1 
        label = [ label 1 ];
        color = 'r.';
    elseif but == 3
        label = [ label 0 ];
        color = 'b.';
    end
    
    plot(xi, yi, color, 'MarkerSize', 15);         % first point on its own
end

hold off;
if k < size(pxIndex,2)
    pxIndex = pxIndex(:, 1:k);
end

pxIndex = int16(fliplr(pxIndex'));