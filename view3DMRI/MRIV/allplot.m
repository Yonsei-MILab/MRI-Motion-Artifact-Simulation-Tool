function varargout = allplot(varargin)
% ALLPLOT M-file for allplot.fig
%      ALLPLOT, by itself, creates a new ALLPLOT or raises the existing
%      singleton*.
%
%      H = ALLPLOT returns the handle to a new ALLPLOT or the handle to
%      the existing singleton*.
%
%      ALLPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALLPLOT.M with the given input arguments.
%
%      ALLPLOT('Property','Value',...) creates a new ALLPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before allplot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to allplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help allplot

% Last Modified by GUIDE v2.5 24-Apr-2010 12:59:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @allplot_OpeningFcn, ...
                   'gui_OutputFcn',  @allplot_OutputFcn, ...
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


% --- Executes just before allplot is made visible.
function allplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to allplot (see VARARGIN)

% Choose default command line output for allplot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes allplot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = allplot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in dir_z.
function dir_z_Callback(hObject, eventdata, handles)
% hObject    handle to dir_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dir_z


% --- Executes on button press in dir_x.
function dir_x_Callback(hObject, eventdata, handles)
% hObject    handle to dir_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of dir_x


% --- Executes on button press in dir_y.
function dir_y_Callback(hObject, eventdata, handles)
% hObject    handle to dir_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dir_y


function slice_range_start_Callback(hObject, eventdata, handles)
% hObject    handle to slice_range_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slice_range_start as text
%        str2double(get(hObject,'String')) returns contents of
%        slice_range_start as a double


% --- Executes during object creation, after setting all properties.
function slice_range_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_range_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scale_tag_Callback(hObject, eventdata, handles)
% hObject    handle to scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_tag as text
%        str2double(get(hObject,'String')) returns contents of scale_tag as a double


% --- Executes during object creation, after setting all properties.
function scale_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_img_inrow_Callback(hObject, eventdata, handles)
% hObject    handle to num_img_inrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_img_inrow as text
%        str2double(get(hObject,'String')) returns contents of num_img_inrow as a double


% --- Executes during object creation, after setting all properties.
function num_img_inrow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_img_inrow (see GCBO)
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
global Selected;
global Dir;
var_name = get(handles.Datalistbox,'String');
var_num = get(handles.Datalistbox,'Value');
Selected = evalin('base',cell2mat(var_name(var_num)));
if ~isreal(Selected)
    Selected = abs(Selected);
end
    
set(handles.color_tab,'Value',1);
if ndims(Selected)~=3
    set(handles.pushbutton1,'enable','off');
    set(handles.scale_max,'enable','off');
    set(handles.scale_min,'enable','off');
    set(handles.slice_range_start,'enable','off');
    set(handles.slice_range_end,'enable','off');
    set(handles.num_img_inrow,'enable','off');
    set(handles.color_tab,'enable','off');
    set(handles.Message_box,'String',['You should selected a 3-D data, this data is ',num2str(ndims(Selected)),'-D data']);    
else
    set(handles.pushbutton1,'enable','on');
    set(handles.scale_max,'enable','on');
    set(handles.scale_min,'enable','on');
    set(handles.slice_range_start,'enable','on');
    set(handles.slice_range_end,'enable','on');
    set(handles.num_img_inrow,'enable','on');
    set(handles.color_tab,'enable','on');
    set(handles.Message_box,'String',[{'3D data is selected.'},{' '},{'Next step -> Define Slice range, Scale, and # of slices in a row '}]);    
    Dir = [get(handles.dir_y,'Value') get(handles.dir_x,'Value') get(handles.dir_z,'Value')];
    leng =size(Selected,find(Dir,1));
    max_val = max(max(max((Selected))));
    min_val = min(min(min((Selected))));
    set(handles.scale_max,'String',num2str(max_val));
    set(handles.scale_min,'String',num2str(min_val));
    set(handles.slice_range_start,'String',num2str(1));
    set(handles.slice_range_end,'String',num2str(leng));
end



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



function slice_range_end_Callback(hObject, eventdata, handles)
% hObject    handle to slice_range_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slice_range_end as text
%        str2double(get(hObject,'String')) returns contents of slice_range_end as a double
% set(handles.Message_box,'String',['Input the end of slice number you want to plot']);    


% --- Executes during object creation, after setting all properties.
function slice_range_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_range_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scale_min_Callback(hObject, eventdata, handles)
% hObject    handle to scale_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_min as text
%        str2double(get(hObject,'String')) returns contents of scale_min as a double
% set(handles.Message_box,'String',['Input a minimum scale value']);    


% --- Executes during object creation, after setting all properties.
function scale_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scale_max_Callback(hObject, eventdata, handles)
% hObject    handle to scale_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_max as text
%        str2double(get(hObject,'String')) returns contents of scale_max as a double
% set(handles.Message_box,'String',['Input a Maximum scale value']);    


% --- Executes during object creation, after setting all properties.
function scale_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% var_name = get(handles.Datalistbox,'String');
% var_num = get(handles.Datalistbox,'Value');
% Selected = evalin('base',cell2mat(var_name(var_num)));
global Selected;
global Dir;
Dir = [get(handles.dir_y,'Value') get(handles.dir_x,'Value') get(handles.dir_z,'Value')];
Range = [str2double(get(handles.slice_range_start,'String')) : str2double(get(handles.slice_range_end,'String'))];
Scale = [str2double(get(handles.scale_min,'String')) str2double(get(handles.scale_max,'String'))];
Cols = str2double(get(handles.num_img_inrow,'String'));
ColorIndex = get(handles.color_tab,'Value');
Colorname = get(handles.color_tab,'String');
Color = cell2mat(Colorname(ColorIndex));
Res = str2num(get(handles.Resolution,'String'));
PlottingAll(Selected,Dir,Cols,Res,Scale,Range,Color);



% --- Executes on button press in Load_data.
function Load_data_Callback(hObject, eventdata, handles)
% hObject    handle to Load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vars = evalin('base', 'who');
set(handles.Datalistbox,'string',vars);



% ------------ Plotting function
function PlottingAll(im,dir,col,res,scale,range,color)
N = length(range);
if ~isreal(im)
    im = abs(im);
end
Margin = 0.005;
row = ceil(N/col);
Width = (1-(col+1)*Margin)/col;
Height = (1-(row+1)*Margin)/row;

figure;
title(im);
for n = 1:N
    subplot('position', [Margin + (Width+Margin)*mod(n-1,col), 1 - (Height+Margin)*ceil(n/col)  , Width, Height] )
    % y-direction
    if dir(1) ==1
        imshow(squeeze(im(range(n),:,:))',scale);
        daspect(1./[res(2) res(3) res(1)])
    end
    % x-direction
    if dir(2) ==1
        imshow(squeeze(im(:,range(n),:)),scale);
        daspect(1./[res(3) res(1) res(2)])
    end
    % z-direction
    if dir(3) ==1
        imshow(squeeze(im(:,:,range(n))),scale);
        daspect(1./[res(1) res(2) res(3)])
    end
end
colormap(color);




function Message_box_Callback(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text9 as text
%        str2double(get(hObject,'String')) returns contents of text9 as a double


% --- Executes during object creation, after setting all properties.
function Message_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color_tab.
function color_tab_Callback(hObject, eventdata, handles)
% hObject    handle to color_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes when selected object is changed in Viewpoint.
function Viewpoint_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Viewpoint 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global Selected
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'dir_x'
        leng = size(Selected,2);
    case 'dir_y'
        leng = size(Selected,1);
    case 'dir_z'
        leng = size(Selected,3);
    otherwise
        % Code for when there is no match.
end
set(handles.slice_range_start,'String','1');
set(handles.slice_range_end,'String',num2str(leng));



function Resolution_Callback(hObject, eventdata, handles)
% hObject    handle to Resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Resolution as text
%        str2double(get(hObject,'String')) returns contents of Resolution as a double


% --- Executes during object creation, after setting all properties.
function Resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
