function varargout = ROI_tool(varargin)
%ROI_TOOL M-file for ROI_tool.fig
%      ROI_TOOL, by itself, creates a new ROI_TOOL or raises the existing
%      singleton*.
%
%      H = ROI_TOOL returns the handle to a new ROI_TOOL or the handle to
%      the existing singleton*.
%
%      ROI_TOOL('Property','Value',...) creates a new ROI_TOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ROI_tool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ROI_TOOL('CALLBACK') and ROI_TOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ROI_TOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_tool

% Last Modified by GUIDE v2.5 03-Dec-2010 22:21:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_tool_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before ROI_tool is made visible.
function ROI_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ROI_tool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROI_tool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_tool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function msg_box_Callback(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text9 as text
%        str2double(get(hObject,'String')) returns contents of text9 as a double


% --- Executes during object creation, after setting all properties.
function msg_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function result_box_Callback(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text9 as text
%        str2double(get(hObject,'String')) returns contents of text9 as a double


% --- Executes during object creation, after setting all properties.
function result_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Datalistbox.
function Datalistbox_Callback(hObject, eventdata, handles)
% hObject    handle to Datalistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Datalistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Datalistbox
global Color;
global Selected;
var_name = get(handles.Datalistbox,'String');
var_num = get(handles.Datalistbox,'Value');
Selected = evalin('base',cell2mat(var_name(var_num)));
if ~isreal(Selected)
    Selected = abs(Selected);
end
    
set(handles.color_tab,'Value',1);
if ndims(Selected) == 2
    set(handles.slice_ind_box,'enable','off');
    set(handles.msg_box,'String',[{'2D data is selected'},{' '} ,{['this data is ',num2str(size(Selected,1)),' by ',num2str(size(Selected,2)),' matrix']},{' '},{'Next step -> Define Slice index, scale, and color of image '}]);    
elseif ndims(Selected) ==3
    set(handles.slice_ind_box,'enable','on');
    set(handles.msg_box,'String',[{'3D data is selected.'},{' '},{['this data is ',num2str(size(Selected,1)),' by ',num2str(size(Selected,2)),' by ',num2str(size(Selected,3)),' matrix']},{' '},{'Next step -> Define Slice index, scale, and color of image '}]);    
else
    set(handles.slice_ind_box,'enable','on');
    dim_old = ndims(Selected);
    Selected = reshape(Selected,size(Selected,1),size(Selected,2),[]);
    set(handles.msg_box,'String',[{['This data is reshaped from ',num2str(dim_old),'D to 3D matrix']},{' '},{[num2str(size(Selected,1)),' by ',num2str(size(Selected,2)),' by ',num2str(size(Selected,3)) ]},{' '},{'Next step -> Define Slice index, scale, and color of image '}]);
end
max_val = max(reshape(Selected,1,[]));
min_val = min(reshape(Selected,1,[]));
set(handles.max_val_box,'String',num2str(max_val));
set(handles.min_val_box,'String',num2str(min_val));

ColorIndex = get(handles.color_tab,'Value');
Colorname = get(handles.color_tab,'String');
Color = cell2mat(Colorname(ColorIndex));

% --- Executes during object creation, after setting all properties.
function Datalistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Datalistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vars = evalin('base', 'who');
set(handles.Datalistbox,'string',vars);



function slice_ind_box_Callback(hObject, eventdata, handles)
% hObject    handle to slice_ind_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slice_ind_box as text
%        str2double(get(hObject,'String')) returns contents of slice_ind_box as a double


% --- Executes during object creation, after setting all properties.
function slice_ind_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_ind_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_val_box_Callback(hObject, eventdata, handles)
% hObject    handle to min_val_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_val_box as text
%        str2double(get(hObject,'String')) returns contents of min_val_box as a double


% --- Executes during object creation, after setting all properties.
function min_val_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_val_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_val_box_Callback(hObject, eventdata, handles)
% hObject    handle to max_val_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_val_box as text
%        str2double(get(hObject,'String')) returns contents of max_val_box as a double


% --- Executes during object creation, after setting all properties.
function max_val_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_val_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply_scale.
function apply_scale_Callback(hObject, eventdata, handles)
% hObject    handle to apply_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in apply_color.
function apply_color_Callback(hObject, eventdata, handles)
% hObject    handle to apply_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Color;
colormap(Color);
% set(handles.axes1,'colormap',Color);

% --- Executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Selected;
global Color;
Scale = [str2double(get(handles.min_val_box,'String')) str2double(get(handles.max_val_box,'String'))];
N_slice = str2num(get(handles.slice_ind_box,'String'));
h = imagesc(Selected(:,:,N_slice),Scale); colormap(Color);
set(handles.msg_box,'String',[{'Selected data has plotted'},{' '},{'Next step-> select ROI tool and set ROI'},{' '},{' ROI can be modified until double clicking left mouse button'}]);



% --- Executes on selection change in color_tab.
function color_tab_Callback(hObject, eventdata, handles)
% hObject    handle to color_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Color;
ColorIndex = get(handles.color_tab,'Value');
Colorname = get(handles.color_tab,'String');
Color = cell2mat(Colorname(ColorIndex));
% Hints: contents = get(hObject,'String') returns color_tab contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color_tab


% --- Executes during object creation, after setting all properties.
function color_tab_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in masking_button.
function masking_button_Callback(hObject, eventdata, handles)
% hObject    handle to masking_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Msked;
global Color;
Scale = [str2double(get(handles.min_val_box,'String')) str2double(get(handles.max_val_box,'String'))];
figure;imagesc(Msked,Scale);colormap(Color);axis image; axis off;

% --- Executes on button press in crop_button.
function crop_button_Callback(hObject, eventdata, handles)
% hObject    handle to crop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Msk;
global Msked;
global Color;
global crop_flag;
if crop_flag ~=0
    temp = sum(Msk,1);
    temp(temp==0)=[];
    x_len = temp(1);
    y_len = length(temp);
    Crop = Msked; Crop(Crop==0) = []; Crop = reshape(Crop,x_len,y_len);
    Scale = [str2double(get(handles.min_val_box,'String')) str2double(get(handles.max_val_box,'String'))];
    if crop_flag ==1
        figure;imagesc(Crop,Scale);colormap(Color);axis image; axis off;
    else   
        figure;plot(Crop);grid on; axis tight;
    end
else
    set(handles.result_box,'String',[{' '},{'Cropping tool only works in case of ''Line'' and ''Rect'' ROI'}]);
end




% --- Executes on button press in mask2var_button.
function mask2var_button_Callback(hObject, eventdata, handles)
% hObject    handle to mask2var_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function varname_box_Callback(hObject, eventdata, handles)
% hObject    handle to varname_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varname_box as text
%        str2double(get(hObject,'String')) returns contents of varname_box as a double


% --- Executes during object creation, after setting all properties.
function varname_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varname_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rect_button.
function rect_button_Callback(hObject, eventdata, handles)
% hObject    handle to rect_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
global Selected;
global Msk;
global Msked;
global Avg;
global Std;
global crop_flag;
crop_flag=1;
R = imrect;
wait(R);
Msk = createMask(R);
Msked = Selected(:,:,str2num(get(handles.slice_ind_box,'String'))).*Msk;
temp = reshape(Msked,1,[]);
temp(temp==0) = [];
Avg = mean(temp);
Std = std(temp);
NumPix = length(temp);
set(handles.result_box,'String',[{['      Number of pixels in ROI = ',num2str(NumPix)]},{' '},{['      Average = ',num2str(Avg)]},{['      Standard deviation = ',num2str(Std)]}]);


% --- Executes on button press in ellipse_button.
function ellipse_button_Callback(hObject, eventdata, handles)
% hObject    handle to ellipse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
global Selected;
global Msk;
global Msked;
global Avg;
global Std;
global crop_flag;
crop_flag=0;
R = imellipse;
wait(R);
Msk = createMask(R);
Msked = Selected(:,:,str2num(get(handles.slice_ind_box,'String'))).*Msk;
temp = reshape(Msked,1,[]);
temp(temp==0) = [];
Avg = mean(temp);
Std = std(temp);
NumPix = length(temp);
set(handles.result_box,'String',[{['      Number of pixels in ROI = ',num2str(NumPix)]},{' '},{['      Average = ',num2str(Avg)]},{['      Standard deviation = ',num2str(Std)]}]);



% --- Executes on button press in poly_button.
function poly_button_Callback(hObject, eventdata, handles)
% hObject    handle to poly_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
global Selected;
global Msk;
global Msked;
global Avg;
global Std;
global crop_flag;
crop_flag=0;
R = impoly;
wait(R);
Msk = createMask(R);
Msked = Selected(:,:,str2num(get(handles.slice_ind_box,'String'))).*Msk;
temp = reshape(Msked,1,[]);
temp(temp==0) = [];
Avg = mean(temp);
Std = std(temp);
NumPix = length(temp);
set(handles.result_box,'String',[{['      Number of pixels in ROI = ',num2str(NumPix)]},{' '},{['      Average = ',num2str(Avg)]},{['      Standard deviation = ',num2str(Std)]}]);


% --- Executes on button press in line_button.
function line_button_Callback(hObject, eventdata, handles)
% hObject    handle to line_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
global Selected;
global Msk;
global Msked;
global Avg;
global Std;
global crop_flag;
crop_flag=2;
R = imline;
wait(R);
Msk = createMask(R);
Msked = Selected(:,:,str2num(get(handles.slice_ind_box,'String'))).*Msk;
temp = reshape(Msked,1,[]);
temp(temp==0) = [];
Avg = mean(temp);
Std = std(temp);
NumPix = length(temp);
set(handles.result_box,'String',[{['      Number of pixels in ROI = ',num2str(NumPix)]},{' '},{['      Average = ',num2str(Avg)]},{['      Standard deviation = ',num2str(Std)]}]);


% --- Executes on button press in freehand_button.
function freehand_button_Callback(hObject, eventdata, handles)
% hObject    handle to freehand_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
global Selected;
global Msk;
global Msked;
global Avg;
global Std;
global crop_flag;
crop_flag=0;
R = imfreehand;
wait(R);
Msk = createMask(R);
Msked = Selected(:,:,str2num(get(handles.slice_ind_box,'String'))).*Msk;
temp = reshape(Msked,1,[]);
temp(temp==0) = [];
Avg = mean(temp);
Std = std(temp);
NumPix = length(temp);
set(handles.result_box,'String',[{['      Number of pixels in ROI = ',num2str(NumPix)]},{' '},{['      Average = ',num2str(Avg)]},{['      Standard deviation = ',num2str(Std)]}]);


% --- Executes on button press in del_button.
function del_button_Callback(hObject, eventdata, handles)
% hObject    handle to del_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
global Msk;
global Msked;
global Avg;
global Std;
delete(R);
clear Msk Msked Avg Std
