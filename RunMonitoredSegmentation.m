
% -------------------------------------------------- ISBI 2017
% img_path = 'Datasets/ISIC-2017_Test_Data';
% gt_path  = 'Datasets/ISIC-2017_Test_Part1_GroundTruth';
% -------------------------------------------------- PH2
% img_path = 'Datasets/PH2_All_Data';
% gt_path  = 'Datasets/PH2_All_Data_GroundTruth';
% -------------------------------------------------- PAD
img_path = 'Datasets/PAD_Dataset';
gt_path  = 'Datasets/PAD_Dataset_GroundTruth';

Files = dir(img_path);
Files_GT = dir(gt_path);
% -------------------------------------------------------------- %


%% MAIN LOOP

c = 1;
% i = 70;
i = 1;

% Read lesion image
I = imread(sprintf('%s/%s',img_path,Files(i+2).name));

if ReduceIMG
    n = 525; m = 700;
    I = imresize(I,[n m]);
end

% Read lesion ground truth mask
if length(gt_path)>0
    % GT = im2bw(imread(sprintf('%s/%s',gt_path,Files_GT(i+2).name)));
    GT = imread(sprintf('%s/%s',gt_path,Files_GT(i+2).name));
    GT = imresize(GT,[n m]);
end

figure(2);
imshow(GT);

% ------------------------------------------------------------------ %
I = imresize(I,[225 300]);

% Show Image
figure(1); imshow(I); hold on;

% Variables
label = []; k = 0; pxIndex = [];
c = 1;
while 1
    [xi, yi, but] = ginput(1);
    if ~isequal(but, 1) & ~isequal(but, 3)
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
    
    if k < size(pxIndex,2)
        pts = pxIndex(:, 1:k);
    else
        pts = pxIndex;
    end
    pts = int16(fliplr(pts'));
    
    % Segmentation process ------------------------------------------------- %
    [SR] = SupervisedSegmentation(I, 'KNN', 0.5001, [ pts label' ]);
    [B,L] = bwboundaries(imresize(SR,[225 300]),'noholes');
    SR = imresize(SR,[n m]);

    % Validation measures ----------------------------------------- %
    EM(c,:) = EvaluationMetrics(SR,GT,'ISIC');
    fprintf('%d - SE:%.4f, SP:%.4f, Acc:%.4f, JA:%.4f, DC:%.4f\n',c,EM(c,1),EM(c,2),EM(c,3),EM(c,4),EM(c,5)); c = c + 1;
    
    imshow(I);
    for kk = 1:length(B)
        boundary = B{kk};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 1.5)
    end
    
    ifore = find(label==1); iback = find(label==0);
    plot(pts(ifore,2),pts(ifore,1),'.r','MarkerSize',15);
    plot(pts(iback,2),pts(iback,1),'.b','MarkerSize',15);
end

hold off;
