function varargout = view2Dmotion(varargin)
% view2Dmotion MATLAB code for view2Dmotion.fig
%      view2Dmotion, by itself, creates a new view2Dmotion or raises the existing
%      singleton*.
%
%      H = view2Dmotion returns the handle to a new view2Dmotion or the handle to
%      the existing singleton*.
%
%      view2Dmotion('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in view2Dmotion.M with the given input arguments.
%
%      view2Dmotion('Property','Value',...) creates a new view2Dmotion or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view2Dmotion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view2Dmotion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view2Dmotion

% Last Modified by GUIDE v2.5 23-Mar-2021 17:53:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view2Dmotion_OpeningFcn, ...
                   'gui_OutputFcn',  @view2Dmotion_OutputFcn, ...
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



% --- Executes just before view2Dmotion is made visible.
function view2Dmotion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view2Dmotion (see VARARGIN)

% Choose default command line output for view2Dmotion
handles.output = hObject;
addpath ./view3DMRI
addpath ./ffts
% 
%%% Í∏∞Î≥∏ ?å¨?? ?ù¥ÎØ∏Ï? Î°úÎìú
a = imread('phan.png');
axes(handles.axes1);
imshow(a);
b = imread('phan_m.png');
axes(handles.axes2);
imshow(b);


%%% motion type
set(handles.uibuttongroup5,'selectedob',[])
set(handles.radiobutton13,'Enable','off') 
set(handles.radiobutton14,'Enable','off')
set(handles.radiobutton15,'Enable','off')
set(handles.radiobutton39,'Enable','off')


%%% axis
set(handles.uibuttongroup6,'selectedob',[])
set(handles.checkbox1,'Enable','off')
set(handles.checkbox2,'Enable','off')
set(handles.checkbox3,'Enable','off')
set(handles.checkbox4,'Enable','off')
set(handles.checkbox5,'Enable','off')
set(handles.checkbox6,'Enable','off')

% motion strength
set(handles.uibuttongroup10,'selectedob',[])
set(handles.radiobutton25,'Enable','off')
set(handles.radiobutton35,'Enable','off')
set(handles.radiobutton36,'Enable','off')


set(handles.slider7,'Enable','off')
set(handles.slider8,'Enable','off')


set(handles.uibuttongroup2,'selectedob',[]);   %% choose input data, trajectory group
set(handles.uibuttongroup4,'selectedob',[]);
set(handles.radiobutton11,'Enable','off');


set(handles.edit7,'String','0');
set(handles.edit6,'String','0');

set(handles.uibuttongroup7,'selectedob',[])  %% diff map / output group
set(handles.radiobutton27,'Enable','off')
set(handles.radiobutton26,'Enable','off')

% finish setting
set(handles.uibuttongroup8, 'selectedob',[])  %% sudden motion
set(handles.radiobutton38, 'Enable','off');
set(handles.radiobutton28, 'Enable','off');
set(handles.radiobutton29, 'Enable','off');
set(handles.edit8,'Enable','off');

bgClr = get(hObject, 'Color');
set(handles.axes9,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'XColor',bgClr,'YColor',bgClr);   %% motion ÏßÑÌñâÎ∞?
set(handles.axes11,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'XColor',bgClr,'YColor',bgClr);   %% ?ñ¥?îå?ùº?ù¥ ÏßÑÌñâÎ∞?
set(handles.axes13,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'XColor',bgClr,'YColor',bgClr);  % motion generating bar


% phase encoding direction
set(handles.radiobutton31,'Value',0);
set(handles.radiobutton32,'Value',0);

%%%%%%%%%%%%%% motion scenario %%%%%%%%%%%%%%
global m_scen

m_scen = struct;

m_scen.ap.type = 'X';
m_scen.rl.type = 'X';
m_scen.is.type = 'X';
m_scen.yaw.type = 'X';
m_scen.pitch.type = 'X';
m_scen.roll.type = 'X';

m_scen.ap.strength = 'X';
m_scen.rl.strength = 'X';
m_scen.is.strength = 'X';
m_scen.yaw.strength = 'X';
m_scen.pitch.strength = 'X';
m_scen.roll.strength = 'X';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view2Dmotion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view2Dmotion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)    %%  Ω∫ƒµ
global motion;
global trajec;
global input_image;
set(handles.text22, 'String','Please wait...');
tr = str2double(get(handles.edit3,'String'));
scantime = get(handles.edit4, 'String');

if contains(scantime,'*')
    x1_1 = strsplit(scantime,'*');
    x1_2 = 1;
    for i = 1:size(x1_1,2)
        x1_2 = x1_2 * str2double(x1_1{1,i});
    end
    scantime = x1_2;
else
    scantime = str2double(scantime);
end
scantime = ceil(scantime);

[x,~,z] = size(input_image);

xq = 0:tr/1000:scantime-tr/1000;
for i = 1:6
    motion_new(:,i) = interp1(motion(:,i),xq,'pchip');
end
motion = motion_new;
% xx = 0;
% x = x*z;
% y = 4;
% axes(handles.axes3);
% plot(motion_new(:,1))
% xlim([xx x])
% ylim([(-1)*y y])
% axes(handles.axes4);
% plot(motion_new(:,2))
% xlim([xx x])
% ylim([(-1)*y y])
% axes(handles.axes5);
% plot(motion_new(:,3))
% xlim([xx x])
% ylim([(-1)*y y])
% axes(handles.axes6);
% plot(motion_new(:,4))
% xlim([xx x])
% ylim([(-1)*y y])
% axes(handles.axes7);
% plot(motion_new(:,5))
% xlim([xx x])
% ylim([(-1)*y y])
% axes(handles.axes8);
% plot(motion_new(:,6))
% xlim([xx x])
% ylim([(-1)*y y])
% 
%%%%%%%%%%%%%% sudden motion %%%%%%%%%%%%%%%%
% motion = y;
motion_sudden = motion;
% su = get(handles.popupmenu1,'Value');  
[xx,~,zz] = size(input_image);
[xm,~] = size(motion);
% if su == 6
    if get(handles.radiobutton28,'Value')
        
%         for i = 1:zz
%             ran = randi([1 10],1);
%             ran1 = randi([1 size(input_image,1)], 1);
%             if xx - ran1 < ran
%                 i
%                 motion_sudden(xx*(i)-ran:xx*(i),:) = motion(xx*(i)-ran:xx*(i),:);
%             else 
%                 i
%                 motion_sudden(xx*(i-1)+ran1:xx*(i-1)+ran1+ran,:) = motion(xx*(i-1)+ran1:xx*(i-1)+ran1+ran,:);
%             end
%         end
        jj = 1;
        while jj <= zz
            sudden_gae = randi([0 2],1) + 1;  % sudden Í∞úÏàò

            sudden = randi([xx*(jj-1)+1 xx*(jj)], 1,sudden_gae);  % sudden ?ì§?ñ¥Í∞? ?úÑÏπ?
            sudden_range = randi([4 6], 1, sudden_gae);  % sudden range
            for i = 1:sudden_gae

                if sudden(i)-round(sudden_range(i)/2) < 1
                    sudden(i) = sudden(i) + round(sudden_range(i)/2) +1;
                end
                sudden_peak = randi(([sudden(i)-round(sudden_range(i)/2) sudden(i)+round(sudden_range(i)/2)]),1); % sudden peak position
                sudden_hight = randi([-1 2],1) * random('Normal',0,0.9);
                if sudden_hight == 0
                    sudden_hight = random('Normal',0,1);
                elseif sudden_hight < 0 
                    sudden_hight = sudden_hight - random('Normal',0,0.9);
                elseif sudden_hight > 0
                    sudden_hight = sudden_hight + random('Normal',0,0.9);
                end

                for ll = 1:6
                    if max(motion(:,ll)) ~= 0              
                        if ll == 3
%                             sudden_hight = sudden_hight/5;
                        end
                        motion_sudden(sudden(i)-round(sudden_range(i)/2):sudden_peak,ll) = linspace(motion(sudden(i)-round(sudden_range(i)/2)-1,ll),motion(sudden(i)-round(sudden_range(i)/2)-1,ll)+sudden_hight,sudden_peak-(sudden(i)-round(sudden_range(i)/2))+1);
                        motion_sudden(sudden_peak:sudden(i)+round(sudden_range(i)/2),ll) = linspace(motion(sudden(i)-round(sudden_range(i)/2)-1,ll)+sudden_hight,motion(sudden(i)-round(sudden_range(i)/2)-1,ll)+random('Normal',0,0.25),(sudden(i)+round(sudden_range(i)/2))-sudden_peak+1);                        
                    end
                end
            end
            jj = jj+1;
        end
        
            
    
    
    elseif get(handles.radiobutton29,'Value')
        edit8 = get(handles.edit8,'String');
        slices = strsplit(edit8, ',');
        for jj = 1:size(slices,2)
            slice = str2double(slices{1,jj});
%             ran = randi([1 10], 1);
%             ran1 = randi([1 size(input_image,1)], 1);
%             if xx - ran1 < ran
%                 motion_sudden(xx*(slice)-ran:xx*(slice),:) = motion(xx*(slice)-ran:xx*(slice),:);
%             else 
%                 motion_sudden(xx*(slice-1)+ran1:xx*(slice-1)+ran1+ran,:) = motion(xx*(slice-1)+ran1:xx*(slice-1)+ran1+ran,:);
%             end

            sudden_gae = randi([0 2],1) + 1;  % sudden Í∞úÏàò
            sudden = randi([xx*(slice-1)+1 xx*(slice)], 1,sudden_gae);  % sudden ?ì§?ñ¥Í∞? ?úÑÏπ?
            sudden_range = randi([4 6], 1, sudden_gae);  % sudden range
            for i = 1:sudden_gae
                if sudden(i)-round(sudden_range(i)/2) < 1
                    sudden(i) = sudden(i) + round(sudden_range(i)/2) +1;
                end
                sudden_peak = randi(([sudden(i)-round(sudden_range(i)/2) sudden(i)+round(sudden_range(i)/2)]),1); % sudden peak position
                sudden_hight = randi([-1 2],1) * random('Normal',0,0.9);
                if sudden_hight == 0
                    sudden_hight = random('Normal',0,1);
                elseif sudden_hight < 0 
                    sudden_hight = sudden_hight - random('Normal',0,0.9);
                elseif sudden_hight > 0
                    sudden_hight = sudden_hight + random('Normal',0,0.9);
                end
                
                for ll = 1:6
                    if max(motion(:,ll)) ~= 0
                        if ll == 3
                            sudden_hight = sudden_hight/5;
                        end
                        motion_sudden(sudden(i)-round(sudden_range(i)/2):sudden_peak,ll) = linspace(motion(sudden(i)-round(sudden_range(i)/2)-1,ll),motion(sudden(i)-round(sudden_range(i)/2)-1,ll)+sudden_hight,sudden_peak-(sudden(i)-round(sudden_range(i)/2))+1);
                        motion_sudden(sudden_peak:sudden(i)+round(sudden_range(i)/2),ll) = linspace(motion(sudden(i)-round(sudden_range(i)/2)-1,ll)+sudden_hight,motion(sudden(i)-round(sudden_range(i)/2)-1,ll)+random('Normal',0,0.25),(sudden(i)+round(sudden_range(i)/2))-sudden_peak+1);                      
                    end
                end
            end           
        end
        
    end 
    motion = motion_sudden;
% end



set(handles.text22, 'String', 'Done!');

assignin('base','motion',motion);
assignin('base','trajec',trajec);
set(handles.radiobutton28, 'Enable','off');
set(handles.radiobutton29, 'Enable','off');
set(handles.radiobutton38, 'Enable','off');
set(handles.edit8,'Enable','off');
disp(get(handles.radiobutton28,'Value'))


% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.     %% customize
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motion;
global trajec;

customize


% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)     %% Î™®ÏÖò ?Ñ†?Éù 
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.   # æÓ«√∂Û¿Ã
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global input_image;
global motion;
global trajec;
global output;
global output_kspace;

set(handles.text23,'String','Please wait...');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output = zeros(size(input_image));
[ay,ax,az] = size(input_image);
kp = zeros(size(input_image));

probar = uint8(ones(1,az,3)*255); % progressbar
axes(handles.axes11);
image(probar);axis off;

fov_y = str2double(get(handles.edit15,'String'));
fov_x = str2double(get(handles.edit16,'String'));

res_y = str2double(get(handles.edit18, 'String'));
res_x = str2double(get(handles.edit19, 'String'));

if fov_y~= ay
    motion(:,1) = motion(:,1)/res_y;
    fov_y
    ay
end
if fov_x~= ax
    motion(:,1) = motion(:,1)/res_x;
end

%%%%%%%%%%%%%%%%%% phase encoding direction %%%%%%%%%%%%%%%%%%%%%%%
input_image_flip = zeros(size(input_image));
if get(handles.radiobutton32, 'Value')
    for zz = 1:az
        input_image_flip(:,:,zz) = imrotate(input_image(:,:,zz),90);
        kp(:,:,zz) = fft2c(input_image_flip(:,:,zz));
    end 
else
    for zz = 1:az
        kp(:,:,zz) = fft2c(input_image(:,:,zz));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


trajma = trajec;
for zz = 1:az
    % zero means no motion
    motma = zeros(ay,6);
    % MOTION
    motma(:,:) = motion(ay*(zz-1)+1:ay*(zz-1)+ay,:);
    
%     zz
   % for ee = 1:ae
    ksma = kp(:,:,zz); % k-space data
    pad = 0; % no padding

    [ output_kdata ] = motion_simul( ksma, trajma, motma);
    output_tmp = ifft2c(output_kdata);
    output_kspace(:,:,zz) = output_kdata;
    output(:,:,zz) = output_tmp;
    %end
     probar(:,zz,1) = 0;  % red
     probar(:,zz,2) = 51;    % green
     probar(:,zz,3) = 153;    % blue  
     axes(handles.axes11);
     image(probar); axis off;
end

%%%%%%%%%%%%%%%%%% phase encoding direction %%%%%%%%%%%%%%%%%%%%%%%
if get(handles.radiobutton32, 'Value')
    for i = 1:az
        output(:,:,i) = imrotate(output(:,:,i),-90);
        output_kspace(:,:,i) = imrotate(output_kspace(:,:,i),-90);
    end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



[t_x,t_y]= size(motma);
for i = 1:t_x
    if motma(i,1) ~=0
        break;
    elseif motma(i,2) ~=0
        break;
    elseif motma(i,3) ~=0
        break;
    elseif motma(i,4) ~=0
        break;
    elseif motma(i,5) ~=0
        break;
    elseif motma(i,6) ~=0
        break;
    end
end
za = round(i/ay);
if za >= az
    za = az-1;
end
assignin('base','output',output);
%[filename, path] = uigetfile('*.jpg','File Selector');
%name = strcat(path, filename);
%a = imread(name);
%set(handles.edit1,'string',name);
set(handles.slider7,'Enable','on');
set(handles.slider7,'min',1);
set(handles.slider7,'max',size(output,3));
set(handles.slider7,'Sliderstep',[1/(size(output,3)-1), 10/(size(output,3)-1)]);
set(handles.slider7,'Value',round(size(output,3)/2));
axes(handles.axes2);
imagesc(abs(output(:,:,round(size(output,3)/2)))); axis off; colormap gray;
set(handles.edit2,'String',round(size(output,3)/2))
set(handles.radiobutton26, 'Enable','on');
set(handles.radiobutton27, 'Enable','on');
set(handles.uibuttongroup7,'selectedob',[])
set(handles.text23,'String','End!');

% phase encoding direction
% set(handles.radiobutton31,'Value',0);
% set(handles.radiobutton32,'Value',0);


% Ï≤òÏùå ?Ñ∏?åÖ
set(handles.text21,'String','')
set(handles.text22,'String','')
axes(handles.axes9);
slide = uint8(ones(1,7,3)*255);
image(slide); axis off;




% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)  %% save
global output

filter = {'*.mat';'*.slx';'*.m';'*.*'};
[file, path] = uiputfile(filter);
if isequal(file,0) || isequal(path,0)
   return;
else
   save(fullfile(path,file),'output');
end
% evalin('base','clearvars -except input_image') ¥Ÿ ªË¡¶
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.         % load the file
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image;
get_ks =  get(handles.radiobutton8, 'Value');   % user clicked phantom
if get_ks
    startingFolder = pwd;
    if ~exist(startingFolder,'dir')
        startingFolder = pwd;
    end
    defaultfilename = fullfile(startingFolder, '*.mat');
    [filename, path] = uigetfile(defaultfilename,'File Selector');
    if filename == 0   % user clicked the cancel
        return;
    end
    name = strcat(path, filename);
    input  = load(name);
    fieldname = fieldnames(input);
    if size(fieldname) == 0   % cancel
        return;
    else 
        input_ks = getfield(input,fieldname{1,1});
    end
    input_image = ifft2c(input_ks);
    [~, ~, z] = size(input_image);
    axes(handles.axes1);
    if length(size(input_image)) == 3
        if ~isreal(input_image)
            imagesc(abs(input_image(:,:,round(z/2)))); axis off; colormap gray;
        else
            imagesc(input_image(:,:,round(z/2))); axis off; colormap gray;
        end
    else 
        if ~isreal(input_image)
            imagesc(abs(input_image)); axis off; colormap gray;
        else
            imagesc(input_image); axis off; colormap gray;
        end
    end
    set(handles.slider8,'Enable','on');
    set(handles.slider8,'min',1);
    set(handles.slider8,'max',size(input_image,3));
    set(handles.slider8,'Sliderstep',[1/(size(input_image,3)-1), 10/(size(input_image,3)-1)]);
    set(handles.slider8,'Value',round(size(input_image,3)/2));
    set(handles.edit1,'String',round(size(input_image,3)/2));
else
    startingFolder = pwd;
    if ~exist(startingFolder,'dir')
        startingFolder = pwd;
    end
    defaultfilename = fullfile(startingFolder, '*.mat');
    [filename, path] = uigetfile(defaultfilename,'File Selector');
    if filename == 0   % user clicked the cancel
        return;
    end
    name = strcat(path, filename);
    input  = load(name);
    fieldname = fieldnames(input);
    if size(fieldname) == 0   % cancel
        return;
    else 
        input_image = getfield(input,fieldname{1,1});
    end
    [~, ~, z] = size(input_image);
    axes(handles.axes1);
    if length(size(input_image)) == 3
        if ~isreal(input_image)
            imagesc(abs(input_image(:,:,round(z/2)))); axis off; colormap gray;
        else
            imagesc(input_image(:,:,round(z/2))); axis off; colormap gray;
        end
    else 
        if ~isreal(input_image)
            imagesc(abs(input_image)); axis off; colormap gray;
        else
            imagesc(input_image); axis off; colormap gray;
        end
    end
    set(handles.slider8,'Enable','on');
    set(handles.slider8,'min',1);
    set(handles.slider8,'max',size(input_image,3));
    set(handles.slider8,'Sliderstep',[1/(size(input_image,3)-1), 10/(size(input_image,3)-1)]);
    set(handles.slider8,'Value',round(size(input_image,3)/2));
    set(handles.edit1,'String',round(size(input_image,3)/2));
end

assignin('base','input_image',input_image);
[x,y,z] = size(input_image);  % display input size
set(handles.text29,'String',strcat(num2str(x),'X',num2str(y),'X',num2str(z)),'Foreground','blue', 'Fontsize',11);



% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)    %% 
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)   %% ?å¨??
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)   %% trajectory
global trajec;
global input_image;

% [x,~,z] = size(input_image);
% trajec = zeros(x*z,2);
% for i = 1:z
%     trajec(x*(i-1)+1:x*i, 1) = i;
%     trajec(x*(i-1)+1:x*i, 2) = 1:1:x;
% end
[x,~,z] = size(input_image);
trajec= 1:x;
trajec = trajec';
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10



% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles) 
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11


% --------------------------------------------------------------------
function view2Dmotion_Callback(hObject, eventdata, handles)
% hObject    handle to view2Dmotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)      %%%% clear
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear -except m_scen')
clear all -except m_scen

% --- Executes during object creation, after setting all properties.
function uibuttongroup5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% motion type %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in radiobutton16.
function radiobutton13_Callback(hObject, eventdata, handles)   % periodic
% hObject    handle to radiobutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen

if get(handles.checkbox1, 'Value')
    m_scen.ap.type = "Periodic (Continuous)";
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.type = "Periodic (Continuous)";
end
if get(handles.checkbox3, 'Value')
    m_scen.is.type = "Periodic (Continuous)";
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.type = "Periodic (Continuous)";
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.type = "Periodic (Continuous)";
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.type = "Periodic (Continuous)";
end


print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);






% Hint: get(hObject,'Value') returns toggle state of radiobutton16

% --- Executes on button press in radiobutton16.
function radiobutton14_Callback(hObject, eventdata, handles)    % linear
% hObject    handle to radiobutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen
        
if get(handles.checkbox1, 'Value')
    m_scen.ap.type = "Linear (Continuous)";
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.type = "Linear (Continuous)";
end
if get(handles.checkbox3, 'Value')
    m_scen.is.type = "Linear (Continuous)";
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.type = "Linear (Continuous)";
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.type = "Linear (Continuous)";
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.type = "Linear (Continuous)";
end


print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);



% Hint: get(hObject,'Value') returns toggle state of radiobutton16

% --- Executes on button press in radiobutton39.
function radiobutton39_Callback(hObject, eventdata, handles) % non-linear
% hObject    handle to radiobutton39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen

if get(handles.checkbox1, 'Value')
    m_scen.ap.type = "Nonlinear (Continuous)";
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.type = "Nonlinear (Continuous)";
end
if get(handles.checkbox3, 'Value')
    m_scen.is.type = "Nonlinear (Continuous)";
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.type = "Nonlinear (Continuous)";
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.type = "Nonlinear (Continuous)";
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.type = "Nonlinear (Continuous)";
end


print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);

% Hint: get(hObject,'Value') returns toggle state of radiobutton39


% --- Executes on button press in radiobutton16.
function radiobutton15_Callback(hObject, eventdata, handles)  % sudden
% hObject    handle to radiobutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen

if get(handles.checkbox1, 'Value')
    m_scen.ap.type = "Sudden";
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.type = "Sudden";
end
if get(handles.checkbox3, 'Value')
    m_scen.is.type = "Sudden";
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.type = "Sudden";
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.type = "Sudden";
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.type = "Sudden";
end


print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);

% Hint: get(hObject,'Value') returns toggle state of radiobutton16

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Motion type %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% motion strength %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in radiobutton25.
function radiobutton25_Callback(hObject, eventdata, handles)   %%% No motion ( motion type : 1 )
% hObject    handle to radiobutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen
        
if get(handles.checkbox1, 'Value')
    m_scen.ap.type = 'X';
    m_scen.ap.strength = 'X';
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.type = 'X';
    m_scen.rl.strength = 'X';
end
if get(handles.checkbox3, 'Value')
    m_scen.is.type = 'X';
    m_scen.is.strength = 'X';
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.type = 'X';
    m_scen.yaw.strength = 'X';
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.type = 'X';
    m_scen.pitch.strength = 'X';
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.type = 'X';
    m_scen.roll.strength = 'X';
end

print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);
    
% Hint: get(hObject,'Value') returns toggle state of radiobutton25


% --- Executes on button press in radiobutton35.
function radiobutton35_Callback(hObject, eventdata, handles) % moderate motion ( motion type : 2 )
% hObject    handle to radiobutton35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen
        
if get(handles.checkbox1, 'Value')
    m_scen.ap.strength = "Moderate";
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.strength = "Moderate";
end
if get(handles.checkbox3, 'Value')
    m_scen.is.strength = "Moderate";
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.strength = "Moderate";
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.strength = "Moderate";
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.strength = "Moderate";
end


print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);

% Hint: get(hObject,'Value') returns toggle state of radiobutton35



% --- Executes on button press in radiobutton36.
function radiobutton36_Callback(hObject, eventdata, handles)  % Severe motion ( motion type : 2 )
% hObject    handle to radiobutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global m_scen
        
if get(handles.checkbox1, 'Value')
    m_scen.ap.strength = "Severe";
end
if get(handles.checkbox2, 'Value')
    m_scen.rl.strength = "Severe";
end
if get(handles.checkbox3, 'Value')
    m_scen.is.strength = "Severe";
end
if get(handles.checkbox4, 'Value')
    m_scen.yaw.strength = "Severe";
end
if get(handles.checkbox5, 'Value')
    m_scen.pitch.strength = "Severe";
end
if get(handles.checkbox6, 'Value')
    m_scen.roll.strength = "Severe";
end


print_scenario = "A-P translation : "+ m_scen.ap.type + " - " + m_scen.ap.strength + newline + 'R-L translation : '+ m_scen.rl.type + " - " + m_scen.rl.strength + newline + 'I-S translation : '+ m_scen.is.type + ...
    " - " + m_scen.is.strength + newline + 'Yaw rotation : ' + m_scen.yaw.type + " - " + m_scen.yaw.strength + newline + 'Pitch rotation : ' + m_scen.pitch.type + " - " + m_scen.pitch.strength + newline + 'Roll rotation : ' + ...
    m_scen.roll.type + " - " + m_scen.roll.strength;
set(handles.text45,'String',print_scenario);

% Hint: get(hObject,'Value') returns toggle state of radiobutton36

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)    % Motion graph
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global motion;

xx = abs(str2double(get(handles.edit11,'String')));
x = abs(str2double(get(handles.edit7,'String')));
y = abs(str2double(get(handles.edit6,'String')));

if x == 0
    x = size(motion,1);
end
if y == 0
    y = max(motion,[],'all')+2;
end

axes(handles.axes3);
plot(motion(:,1))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes4);
plot(motion(:,2))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes5);
plot(motion(:,3))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes6);
plot(motion(:,4))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes7);
plot(motion(:,5))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes8);
plot(motion(:,6))
xlim([xx x])
ylim([(-1)*y y])
set(handles.text21,'String','');



% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)   %% ?ù∏?íã?Ç¨Ïß? ?ä¨?ùº?ù¥?çî
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image
%set(handles.slider5,'WindowButtonMotionFcn',@mouseMove);
%set(handles.slider5,'windowscrollWheelFcn', {@scrollfunc,gca});
%j = findobj(handles.slider5);
%j.MouseWheelMovedCallbak = 'disp(clock)';
%set(handles.slider5,'MouseWheelMovedCallback','disp(clock)');

temp = round(get(handles.slider8,'Value'));
axes(handles.axes1);
imagesc(abs(input_image(:,:,temp))); colormap gray; axis off;
set(handles.edit1,'String',temp);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)   %% ?ïÑ?õÉ?íã ?Ç¨Ïß? ?ä¨?ùº?ù¥?çî
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global output
global input_image

diff = abs(input_image-output);

temp1 = round(get(handles.slider7,'Value'));
if get(handles.radiobutton26,'Value')
    axes(handles.axes2);
    imagesc(diff(:,:,temp1)); colormap gray; axis off;
    set(handles.edit2,'String',temp1);
else
    axes(handles.axes2);
    imagesc(abs(output(:,:,temp1))); colormap gray; axis off;
    set(handles.edit2,'String',temp1);
end



% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





function edit1_Callback(hObject, eventdata, handles)        % ?ù∏?íã ?Ç¨Ïß? ?ä¨?ùº?ù¥?ìú ?Öç?ä§?ä∏
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image;
slide = str2double(get(handles.edit1,'String'));
axes(handles.axes1);
imagesc(abs(input_image(:,:,slide))); colormap gray; axis off;
set(handles.slider8,'Value',slide);


% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)   %% ?ïÑ?õÉ?íã ?ä¨?ùº?ù¥?ìú ?Öç?ä§?ä∏
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global output;
global input_image;

diff = abs(input_image) - abs(output);
slide = str2double(get(handles.edit2,'String'));

if get(handles.radiobutton26,'Value')
    axes(handles.axes2);
    imagesc(abs(diff(:,:,slide))); colormap gray; axis off;
else
    axes(handles.axes2);
    imagesc(abs(output(:,:,slide))); colormap gray; axis off;
end
set(handles.slider7,'Value',slide);
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)    %% ?ù∏?íã?Ç¨Ïß? 3?îîÎ∑∞Ïñ¥
view3Dmri
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton19.
function radiobutton19_Callback(hObject, eventdata, handles)   %%% A-P ?ä∏?ûú?ä§?†à?ù¥?Öò
% hObject    handle to radiobutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton19


% --- Executes on button press in radiobutton20.
function radiobutton20_Callback(hObject, eventdata, handles)   %%% R-L ?ä∏?ûú?ä§?†à?ù¥?Öò
% hObject    handle to radiobutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton20


% --- Executes on button press in radiobutton21.
function radiobutton21_Callback(hObject, eventdata, handles)   %%% I-S ?ä∏?ûú?ä§?†à?ù¥?Öò
% hObject    handle to radiobutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton21


% --- Executes on button press in radiobutton22.
function radiobutton22_Callback(hObject, eventdata, handles)   %%% ?ïº?ò§
% hObject    handle to radiobutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton22


% --- Executes on button press in radiobutton23.
function radiobutton23_Callback(hObject, eventdata, handles)   %%% ?îºÏπ?
% hObject    handle to radiobutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton23


% --- Executes on button press in radiobutton24.
function radiobutton24_Callback(hObject, eventdata, handles)   %%% Î°?
% hObject    handle to radiobutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton24


% --- Executes on button press in radiobutton26.
function radiobutton26_Callback(hObject, eventdata, handles)    %% ?îî?îÑÎß?
% hObject    handle to radiobutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global output
global input_image

diff = abs(input_image) - abs(output);
slide = round(get(handles.slider7,'Value'));
edit = str2double(get(handles.edit2, 'String'));
if slide ~= edit
    slide = edit;
end

axes(handles.axes2)
imagesc(abs(diff(:,:,slide))); axis off; colormap gray;
set(handles.slider7,'Enable','on');
set(handles.slider7,'min',1);
set(handles.slider7,'max',size(diff,3));
set(handles.slider7,'Sliderstep',[1/(size(diff,3)-1), 10/(size(diff,3)-1)]);

% Hint: get(hObject,'Value') returns toggle state of radiobutton26


% --- Executes on button press in radiobutton27.
function radiobutton27_Callback(hObject, eventdata, handles)    %% ?ïÑ?õÉ?íã
% hObject    handle to radiobutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global output


slide = round(get(handles.slider7,'Value'));
edit = str2double(get(handles.edit2, 'String'));
if slide ~= edit
    slide = edit;
end

axes(handles.axes2)
imagesc(abs(output(:,:,slide))); axis off; colormap gray;
set(handles.slider7,'Enable','on');
set(handles.slider7,'min',1);
set(handles.slider7,'max',size(output,3));
set(handles.slider7,'Sliderstep',[1/(size(output,3)-1), 10/(size(output,3)-1)]);


% Hint: get(hObject,'Value') returns toggle state of radiobutton27



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)   %%%% RMSE and SSIM
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image
global output
%%%%%% RMSE
[xx,yy,zz] = size(input_image);

RMSE = zeros(1,zz);
SSIM = zeros(1,zz);
PSNR = zeros(1,zz);
for i = 1:zz
    mask=abs(input_image(:,:,i));mask(mask<mean(mask(:))*.5)=0;mask(mask>0)=1;
    mask=medfilt2(medfilt2(mask,[17 17]),[17 17]);
%     RMSE(i) = sqrt(sum(abs(abs(input_image(:,:,i)).*mask-abs(output(:,:,i))).*mask,'all')./(sum(mask,'all')));
RMSE(i) = sqrt(sum(abs((input_image(:,:,i)).*mask-abs(output(:,:,i)).^2).*mask,'all')./(sum(mask,'all')));
    SSIM(i) = ssim(abs(output(:,:,i)).*mask,abs(input_image(:,:,i)).*mask);
    PSNR(i) = psnr(abs(output(:,:,i)).*mask,abs(input_image(:,:,i)).*mask);
end
sli = get(handles.edit9, 'String');
sli = str2double(sli);
set(handles.text31,'String',RMSE(sli));
set(handles.text35,'String',SSIM(sli));
set(handles.text50,'String',PSNR(sli));



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles) %% motion view
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global motion_para;
disp(motion_para)

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)    % same motion to multiple input data
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image
global output
global motion
global trajec


dname = uigetdir(pwd);
files = dir(dname);

q = 0;
file_n = cell(length(files),1);
for i = 1:length(files)
    if ~isempty(strfind(files(i).name,'mat'))
        q = q+1;
        file_n(q,1) = {files(i).name};
    end
end

probar = uint8(ones(1,q,3)*255); % progressbar

for j = 1:q  % the number of input files
    %%%%%%%%%%%% load the file %%%%%%%%%%%%
    name = strcat(dname, '\',file_n{j,1});
    input  = load(name);
    fieldname = fieldnames(input);
    if size(fieldname) == 0   % cancel
        return;
    else 
        input_image = getfield(input,fieldname{1,1});
    end
    [~, ~, z] = size(input_image);
    axes(handles.axes1);
    if length(size(input_image)) == 3
        if ~isreal(input_image)
            imagesc(abs(input_image(:,:,round(z/2)))); axis off; colormap gray;
        else
            imagesc(input_image(:,:,round(z/2))); axis off; colormap gray;
        end
    else 
        if ~isreal(input_image)
            imagesc(abs(input_image)); axis off; colormap gray;
        else
            imagesc(input_image); axis off; colormap gray;
        end
    end
    
    
    
    %%%%%%%%%%%% Apply the motion %%%%%%%%%%%%
    output = zeros(size(input_image));
    [ay,ax,az] = size(input_image);
    kp = zeros(size(input_image));
    
    
    %%%%%%%%%%%%%%%%%% phase encoding direction %%%%%%%%%%%%%%%%%%%%%%%
    input_image_flip = zeros(size(input_image));
    if get(handles.radiobutton32, 'Value')
        for zz = 1:az
            input_image_flip(:,:,zz) = imrotate(input_image(:,:,zz),90);
            kp(:,:,zz) = fft2c(input_image_flip(:,:,zz));
        end 
    else
        for zz = 1:az
            kp(:,:,zz) = fft2c(input_image(:,:,zz));
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    trajma = trajec;
    for zz = 1:az
        % zero means no motion
        motma = zeros(ay,6);
        % MOTION
        motma(:,:) = motion(ay*(zz-1)+1:ay*(zz-1)+ay,:);

        ksma = kp(:,:,zz); % k-space data
        pad = 0; % no padding

        [ output_kdata ] = motion_simul( ksma, trajma, motma);
        output_tmp = ifft2c(output_kdata);
        output(:,:,zz) = output_tmp;
    end

% 
%     [t_x,t_y]= size(motma);
%     for i = 1:t_x
%         if motma(i,1) ~=0
%             break;
%         elseif motma(i,2) ~=0
%             break;
%         elseif motma(i,3) ~=0
%             break;
%         elseif motma(i,4) ~=0
%             break;
%         elseif motma(i,5) ~=0
%             break;
%         elseif motma(i,6) ~=0
%             break;
%         end
%     end
%     za = round(i/ay);
%     if za >= az
%         za = az-1;
%     end

    %%%%%%%%%%%%%%%%%% phase encoding direction %%%%%%%%%%%%%%%%%%%%%%%
    if get(handles.radiobutton32, 'Value')
        for i = 1:az
            output(:,:,i) = imrotate(output(:,:,i),-90);
        end 
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    set(handles.slider7,'Enable','on');
    set(handles.slider7,'min',1);
    set(handles.slider7,'max',size(output,3));
    set(handles.slider7,'Sliderstep',[1/(size(output,3)-1), 10/(size(output,3)-1)]);
    set(handles.slider7,'Value',round(size(output,3)/2));
    axes(handles.axes2);
    imagesc(abs(output(:,:,round(size(output,3)/2)))); axis off; colormap gray;
    set(handles.edit2,'String',round(size(output,3)/2))
    set(handles.radiobutton26, 'Enable','on');
    set(handles.radiobutton27, 'Enable','on');
    set(handles.uibuttongroup7,'selectedob',[])
    set(handles.text23,'String','End!');
    

    %%%%%%%%%%%% Save the output image %%%%%%%%%%%%

    name = strcat(dname, '\motion corrupted_', file_n{j,1});
    save(name,'output');
    
    probar(:,j,1) = 209;  % red
    probar(:,j,2) = 178;    % green
    probar(:,j,3) = 255;    % blue
    axes(handles.axes13);
    image(probar); axis off;
end
pause(2);
probar(:,:,:) = 255;    % blue
axes(handles.axes13);
image(probar); axis off;

% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motion;
filter = {'*.mat';'*.slx';'*.m';'*.*'};
[file, path] = uiputfile(filter);
if isequal(file,0) || isequal(path,0)
   return;
else
   save(fullfile(path,file),'motion');
end

function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)   % parameters set button
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% motion type
set(handles.uibuttongroup5,'selectedob',[])
set(handles.radiobutton13,'Enable','on') 
set(handles.radiobutton14,'Enable','on')
set(handles.radiobutton15,'Enable','on')
set(handles.radiobutton39,'Enable','on')

%%% axis
set(handles.uibuttongroup6,'selectedob',[])
set(handles.checkbox1,'Enable','on')
set(handles.checkbox2,'Enable','on')
set(handles.checkbox3,'Enable','on')
set(handles.checkbox4,'Enable','on')
set(handles.checkbox5,'Enable','on')
set(handles.checkbox6,'Enable','on')

% motion strength
set(handles.uibuttongroup10,'selectedob',[])
set(handles.radiobutton25,'Enable','on')
set(handles.radiobutton35,'Enable','on')
set(handles.radiobutton36,'Enable','on')


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)  % motion create ≈©∏Æø°¿Ã∆Æ
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% finish setting

global motion
global m_scen
global input_image

tr = str2double(get(handles.edit3,'String'));
scantime= get(handles.edit4,'String');

if contains(scantime,'*')
    x1_1 = strsplit(scantime,'*');
    x1_2 = 1;
    for i = 1:size(x1_1,2)
        x1_2 = x1_2 * str2double(x1_1{1,i});
    end
    scantime = x1_2;
else
    scantime = str2double(scantime);
end
scantime = ceil(scantime);

motion = motion_para(size(input_image,3), m_scen, tr, ceil(scantime));

xx = 0;
x = scantime;
y = max(motion,[],'all');

if y > 2
    y = y + 2;
else 
    y = 4;
end


axes(handles.axes3);
plot(motion(:,1))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes4);
plot(motion(:,2))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes5);
plot(motion(:,3))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes6);
plot(motion(:,4))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes7);
plot(motion(:,5))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes8);
plot(motion(:,6))
xlim([xx x])
ylim([(-1)*y y])

set(handles.uibuttongroup8, 'selectedob',[])  %% Active additional abrupt motion
set(handles.radiobutton38, 'Enable','on');
set(handles.radiobutton28, 'Enable','on');
set(handles.radiobutton29, 'Enable','on');
set(handles.edit8,'Enable','off');


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)  % k-space save
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global output_kspace

filter = {'*.mat';'*.slx';'*.m';'*.*'};
[file, path] = uiputfile(filter);
if isequal(file,0) || isequal(path,0)
   return;
else
   save(fullfile(path,file),'output_kspace');
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)  %% here
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global motion
global m_scen
global input_image

tr = str2double(get(handles.edit3,'String'));
scantime= get(handles.edit4,'String');

if contains(scantime,'*')
    x1_1 = strsplit(scantime,'*');
    x1_2 = 1;
    for i = 1:size(x1_1,2)
        x1_2 = x1_2 * str2double(x1_1{1,i});
    end
    scantime = x1_2;
else
    scantime = str2double(scantime);
end
scantime = ceil(scantime);

% motion = motion_para(size(input_image,3), m_scen, tr, ceil(scantime));




motion = zeros(scantime,6);

for ll = 1:2
    for gg = 1:72
    gae = randi([5 10]);
    res = zeros(scantime,1);
    whe = randi([5 scantime],1,gae);
    for i = 1:gae
        ho = randi([1 4], 1);
        if whe(i)+ho > scantime
            ho = scantime-whe(i);
        end
        for j = 1:ho
            res(whe(i)+j-1) = res(whe(i)+j-2)+random('Normal',0,1);
        end
    end
    end
    motion(:,ll) = res;
end

for ll = 4:5
    for gg = 1:72
    gae = randi([5 10]);
    res = zeros(scantime,1);
    whe = randi([5 scantime],1,gae);
    for i = 1:gae
        ho = randi([1 4], 1);
        if whe(i)+ho > scantime
            ho = scantime-whe(i);
        end
        for j = 1:ho
            res(whe(i)+j-1) = res(whe(i)+j-2)+random('Normal',0,1);
        end
    end
    end
    motion(:,ll) = res;
end



xx = 0;
x = scantime;
y = max(motion,[],'all');

if y > 2
    y = y + 2;
else 
    y = 4;
end


axes(handles.axes3);
plot(motion(:,1))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes4);
plot(motion(:,2))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes5);
plot(motion(:,3))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes6);
plot(motion(:,4))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes7);
plot(motion(:,5))
xlim([xx x])
ylim([(-1)*y y])
axes(handles.axes8);
plot(motion(:,6))
xlim([xx x])
ylim([(-1)*y y])

set(handles.uibuttongroup8, 'selectedob',[])  %% Active additional abrupt motion
set(handles.radiobutton38, 'Enable','on');
set(handles.radiobutton28, 'Enable','on');
set(handles.radiobutton29, 'Enable','on');
set(handles.edit8,'Enable','off');
