function varargout = GTgenerate(varargin)
% GTGENERATE MATLAB code for GTgenerate.fig 15176
%      GTGENERATE, by itself, creates a new GTGENERATE or raises the existing
%      singleton*.
%
%      H = GTGENERATE returns the handle to a new GTGENERATE or the handle to
%      the existing singleton*.
%5
%      GTGENERATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GTGENERATE.M with the given input arguments.
%
%      GTGENERATE('Property','Value',...) creates a new GTGENERATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GTgenerate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GTgenerate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GTgenerate

% Last Modified by GUIDE v2.5 14-Oct-2018 10:19:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GTgenerate_OpeningFcn, ...
                   'gui_OutputFcn',  @GTgenerate_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GTgenerate is made visible.
function GTgenerate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GTgenerate (see VARARGIN)

% Choose default command line output for GTgenerate
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GTgenerate wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global file_GT file path path_files segmenting;
file_GT = '';
file = '';
path = '';
path_files = [];
segmenting = false;

set(handles.text_log,'string','');

try
    fp = fopen('path.dat','r');
    path_aux = fscanf(fp, '%c');
    fclose(fp);
    if length(path_aux) > 2
        if path_aux(end) == '\'
            path = [ path_aux ];
        else
            path = [ path_aux '\' ];
        end
    else
        path = pwd; path = [ path '\Images\' ];
    end
    path_files = dir(path);
    file = path_files(3).name;
    loadImg(handles);
catch
    axes(handles.axes1);
    imshow(double(ones(225,300)));

    axes(handles.axes2);
    imshow(double(ones(225,300)));
    
    axes(handles.axes3);
    imshow(double(ones(225,300)));
end

% --- Outputs from this function are returned to the command line.
function varargout = GTgenerate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)
% hObject    handle to savebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global path file file_GT GT;

if length(file_GT)>0
    if 7~=exist([path 'ROI\'],'dir')
        mkdir([path 'ROI']);
    end
    imwrite(GT, file_GT);
    set(handles.text_log,'string','Salvo com sucesso!');
elseif length(file)>0
    if 7~=exist([path 'ROI\'],'dir')
        mkdir([path 'ROI']);
    end
    imwrite(GT, [path 'ROI\' file(1:end-4) '_segmentation.png']);
    set(handles.text_log,'string','Salvo com sucesso!');
end

% --- Executes on button press in prevnextbtn.
function prevnextbtn_Callback(hObject, eventdata, handles)
% hObject    handle to prevnextbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file path_files idx;

set(handles.text_log,'string','');

if length(file) < 1
    return
end

if strcmp(hObject.String,'<')
    for i=idx-1:-1:3
        if strcmp(path_files(i).name(end-2:end),'jpg') | strcmp(path_files(i).name(end-2:end),'png') | strcmp(path_files(i).name(end-2:end),'bmp')
            idx = i;
            file = path_files(i).name;
            loadImg(handles);
            break;
        end
    end
else
    for i=idx+1:size(path_files,1)
        if strcmp(path_files(i).name(end-2:end),'jpg') | strcmp(path_files(i).name(end-2:end),'png') | strcmp(path_files(i).name(end-2:end),'bmp')
            idx = i;
            file = path_files(i).name;
            loadImg(handles);
            break;
        end
    end
end

function originalbox_Callback(hObject, eventdata, handles)
% hObject    handle to originalbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of originalbox as text
%        str2double(get(hObject,'String')) returns contents of originalbox as a double


% --- Executes during object creation, after setting all properties.
function originalbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to originalbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function gtbox_Callback(hObject, eventdata, handles)
% hObject    handle to gtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gtbox as text
%        str2double(get(hObject,'String')) returns contents of gtbox as a double


% --- Executes during object creation, after setting all properties.
function gtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadbtn.
function loadbtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file path path_files;

% [file_aux, path_aux] = uigetfile({'*.*','All Files (*.*)'},'File Selector');
[file_aux, path_aux] = uigetfile(fullfile(path,'*.*'),'File Selector');
% 
if length(path_aux) > 1
    fp = fopen('path.dat','w');
    fprintf(fp, '%s', path_aux);
    fclose(fp);
end

if file_aux ~= 0
    file = file_aux;
    path = path_aux;
    path_files = dir(path);
    loadImg(handles);
end

% --- Executes on button press in segmentbtn.
function segmentbtn_Callback(hObject, eventdata, handles)
% hObject    handle to segmentbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global path file GT segmenting;

if segmenting == true
    return
end

segmenting = true;

set(handles.text_log,'string','');
axes(handles.axes1);

try
    I = imread([path file]);
    imshow(I);
end

if strcmp(hObject.String,'Mão livre')
    h = imfreehand;
elseif strcmp(hObject.String,'Polígono')
    h = impoly;
else
    GT = mySegmentationMethod(I, handles);
end

if ~strcmp(hObject.String,'Pontos')
    if length(h)
        GT = createMask(h);
        delete(h);
        imshow(I);
        plotSegmentImage(I,GT,handles);
    end
else
    imshow(I);
    plotSegmentImage(I,GT,handles);
end

segmenting = false;

function mouseMove (object, eventdata)

C = get (gca, 'CurrentPoint');
title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);


function imgIndex()

global file path_files idx;

idx = -1;
for i=1:size(path_files,1)
    if strcmp(path_files(i).name,file)
        idx = i;
        break;
    end
end

function loadImg(handles)

global path file file_GT GT;
file_GT = '';

cla(handles.axes1);
cla(handles.axes2);

set(handles.img_name,'string',file);

imgIndex();

axes(handles.axes1);

I = imread([path file]);
imshow(I);

gt_plot_ok = false;

try
    GT = imread([path 'ROI\' file(1:end-4) '_segmentation.bmp']);
    file_GT = [path 'ROI\' file(1:end-4) '_segmentation.bmp'];
    plotSegmentImage(I, GT, handles);
    gt_plot_ok = true;
end

try
    GT = imread([path 'ROI\' file(1:end-4) '_segmentation.jpg']);
    file_GT = [path 'ROI\' file(1:end-4) '_segmentation.jpg'];
    plotSegmentImage(I, GT, handles);
    gt_plot_ok = true;
end

try
    GT = imread([path 'ROI\' file(1:end-4) '_segmentation.png']);
    file_GT = [path 'ROI\' file(1:end-4) '_segmentation.png'];
    plotSegmentImage(I, GT, handles);
    gt_plot_ok = true;
end

if gt_plot_ok == false
    axes(handles.axes2);
    imshow(zeros(225,300));
    axes(handles.axes3);
    imshow(zeros(225,300));
end

function plotSegmentImage(I, GT, handles)

g = 1.5;

axes(handles.axes2);

[rows,cols,~] = size(I);
SR = uint8(zeros(rows,cols,3));

R = I(:,:,1); G = I(:,:,2); B = I(:,:,3);
R(find(GT==0)) = R(find(GT==0))/g;
G(find(GT==0)) = G(find(GT==0))/g;
B(find(GT==0)) = B(find(GT==0))/g;
SR(:,:,1) = R; SR(:,:,2) = G; SR(:,:,3) = B;

imshow(SR);

axes(handles.axes3);
imshow(GT);

function GT = mySegmentationMethod(J, handles)

[rows,cols,~] = size(J);

I = imresize(J, [225 300]);
p = [rows cols]./[225 300];

% I = imresize(J, [450 600]);
% p = [rows cols]./[450 600];

% Variables
label = []; k = 0; pxIndex = [];
c = 1;
while 1
    [xi, yi, but] = ginput(1);
    if ~isequal(but, 1) & ~isequal(but, 3)
        break
    end
    
    k = k + 1;
    pxIndex(1,k) = round(xi/p(2));
    pxIndex(2,k) = round(yi/p(1));

    if but == 1 
        label = [ label 1 ];
        color = 'r.';
    elseif but == 3
        label = [ label 0 ];
        color = 'b.';
    else
        break;
    end
    
    if pxIndex(1,k) > 300 | pxIndex(1,k) < 0 | pxIndex(2,k) > 225 | pxIndex(2,k) < 0
        break;
    end
    
    if k < size(pxIndex,2)
        pts = pxIndex(:, 1:k);
    else
        pts = pxIndex;
    end
    pts = int16(fliplr(pts'));
    
    % Segmentation process ------------------------------------------------- %
    
    if sum(label) > 0
        [SR] = SupervisedSegmentation(I, 'NN', get(handles.sliderSeg,'Value')/50, [ pts label' ]);
        SR = imresize(SR,[rows cols]);
        [B,L] = bwboundaries(SR,'noholes');

        imshow(J); hold on;
        for kk = 1:length(B)
            boundary = B{kk};
            plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 1.5)
        end
    else
        imshow(J); hold on;
    end
    
    ifore = find(label==1); iback = find(label==0);
    plot(round(pts(ifore,2)*p(2)),round(pts(ifore,1)*p(1)),'.r','MarkerSize',15);
    plot(round(pts(iback,2)*p(2)),round(pts(iback,1)*p(1)),'.b','MarkerSize',15);
end

hold off;

GT = SR;


% --- Executes on slider movement.
function sliderSeg_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


sliderVal = get(hObject,'Value');

set(handles.text_perc, 'string', sprintf('%.1f%%',sliderVal));


% --- Executes during object creation, after setting all properties.
function sliderSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
