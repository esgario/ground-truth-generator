% INPUT %
% rgb - imagem RGB
% intensity - número de vezes que aplica o filtro de média para suavizar os
% fios de cabelo. recomendado valores de 1 a 5
% OUTPUT %
% RGB - imagem sem cabelos

function img_rgb = RemoveHair(img_rgb)

% Original size
[rows,cols,~] = size(img_rgb);

% Filters
MeanFilter = ones(3,3)/9;
% LaplacianFilter = [ 2 2 2; 2 -16 2; 2 2 2 ];
LoG = [ 0 0 1 0 0; 0 1 2 1 0; 1 2 -16 2 1; 0 1 2 1 0; 0 0 1 0 0 ];

% Variables
se = strel('disk',5);
img_original = img_rgb;
n = 225; m = 300;
if rows ~= n & cols ~= m
    img_rgb = imresize(img_rgb,[225 300]);
end
threshold = 0.3;

% ----------------------------------------- %

% Convert img to gray scale
img_gray = rgb2gray(img_rgb);

% Generate the hair mask
Imask = imfilter(img_gray,LoG);
Imask = imfilter(Imask,MeanFilter);
Imask = im2bw(Imask,threshold);

% Inpainting (Fast Digital Image Inpainting)
Imask = imresize(Imask,[rows cols]);
% Imask(find(img_gray(:) > 100)) = 0;

% Morphological filter
% img_rgb = img_original;
% img_rgb = imdilate(img_rgb, se);
% img_rgb = imgaussfilt(img_rgb, 5);
% 
% index = find(Imask(:)==0);
% for i=0:2
%     img_rgb(index + rows*cols*i) = img_original(index + rows*cols*i);
% end

img_rgb = inpainting(img_original, Imask);

% PLOT
% subplot(221); imshow(img_original);
% subplot(222); imshow(Imask);
% subplot(223); imshow(img_rgb);
% subplot(224); imshow(img_gray);
% waitforbuttonpress;

function F = inpainting(I, Imask)

[rows,cols,~] = size(I);
F = I;

index = find(Imask(:)==1);
I(index) = 0;
I(rows*cols + index) = 0;
I(2*rows*cols + index) = 0;

s = 6;
for i=1:rows
    mi = -s+i;
    Mi = s+i;
    for j=1:cols
        mj = -s+j;
        Mj = s+j;
        if Imask(i,j) == 1
            if (i > s & j > s) & (i<=(rows-s) & j<=(cols-s))
                J = I(mi:Mi,mj:Mj,:);
                n = length(find(J(:,:,1)>0));
                F(i,j,:) = sum(sum(J))/n;
            else  
                J = I(max(mi,1):min(Mi,rows),max(mj,1):min(Mj,cols),:);
                n = length(find(J(:,:,1)>0));
                F(i,j,:) = sum(sum(J))/n;
            end
        end
    end
end

F = uint8(F);