function varargout = moviemaker(varargin)
%MOVIEMAKER M-file for moviemaker.fig
%      MOVIEMAKER, by itself, creates a new MOVIEMAKER or raises the existing
%      singleton*.
%
%      H = MOVIEMAKER returns the handle to a new MOVIEMAKER or the handle to
%      the existing singleton*.
%
%      MOVIEMAKER('Property','Value',...) creates a new MOVIEMAKER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to moviemaker_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MOVIEMAKER('CALLBACK') and MOVIEMAKER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MOVIEMAKER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help moviemaker

% Last Modified by GUIDE v2.5 29-Apr-2010 13:24:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @moviemaker_OpeningFcn, ...
                   'gui_OutputFcn',  @moviemaker_OutputFcn, ...
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


% --- Executes just before moviemaker is made visible.
function moviemaker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for moviemaker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.capture_check_rend,'enable','off');


% UIWAIT makes moviemaker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = moviemaker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function save_file_name_Callback(hObject, eventdata, handles)
% hObject    handle to save_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_file_name as text
%        str2double(get(hObject,'String')) returns contents of save_file_name as a double


% --- Executes during object creation, after setting all properties.
function save_file_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function message_box_Callback(hObject, eventdata, handles)
% hObject    handle to message_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of message_box as text
%        str2double(get(hObject,'String')) returns contents of message_box as a double


% --- Executes during object creation, after setting all properties.
function message_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to message_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sel_renderingbox.
function sel_renderingbox_Callback(hObject, eventdata, handles)
% hObject    handle to sel_renderingbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sel_renderingbox
set(handles.run_moviemaker,'enable','on');
if get(hObject,'value') == 1
    set(handles.fig_num,'enable','on');    
    set(handles.Az_from,'enable','on');
    set(handles.Az_to,'enable','on');
    set(handles.el_from,'enable','on');
    set(handles.el_to,'enable','on');
    set(handles.left_rend,'enable','on');
    set(handles.bottom_rend,'enable','on');
    set(handles.width_rend,'enable','on');
    set(handles.height_rend,'enable','on');
    
    set(handles.sel_databox,'value',0);

    set(handles.datalist,'enable','off');    
    set(handles.crop_checkbox,'enable','off');
    set(handles.range_x,'enable','off');
    set(handles.range_y,'enable','off');
    set(handles.range_z,'enable','off');
    set(handles.dim_z,'enable','off');
    set(handles.dim_y,'enable','off');
    set(handles.dim_x,'enable','off');
    set(handles.color_tab,'enable','off');
    set(handles.scale_min,'enable','off');
    set(handles.scale_max,'enable','off');
end


% --- Executes on button press in sel_databox.
function sel_databox_Callback(hObject, eventdata, handles)
% hObject    handle to sel_databox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sel_databox
if get(hObject,'value') == 1
    set(handles.datalist,'enable','on');    
    set(handles.crop_checkbox,'enable','on');
    if get(handles.crop_checkbox,'value')==1    
        set(handles.range_x,'enable','on');
        set(handles.range_y,'enable','on');
        set(handles.range_z,'enable','on');
    else
        set(handles.range_x,'enable','off');
        set(handles.range_y,'enable','off');
        set(handles.range_z,'enable','off');
    end

    set(handles.dim_z,'enable','on');
    set(handles.dim_y,'enable','on');
    set(handles.dim_x,'enable','on');
    set(handles.sel_renderingbox,'value',0);
    set(handles.color_tab,'enable','off');
    set(handles.scale_min,'enable','off');
    set(handles.scale_max,'enable','off');
    
    vars = evalin('base', 'who');
    set(handles.datalist,'string',vars);

    set(handles.fig_num,'enable','off');
    set(handles.Az_from,'enable','off');
    set(handles.Az_to,'enable','off');
    set(handles.el_from,'enable','off');
    set(handles.el_to,'enable','off');
    set(handles.capture_check_rend,'enable','off');
    set(handles.left_rend,'enable','off');
    set(handles.bottom_rend,'enable','off');
    set(handles.width_rend,'enable','off');
    set(handles.height_rend,'enable','off');
    
end


% --- Executes on button press in run_moviemaker.
function run_moviemaker_Callback(hObject, eventdata, handles)
% hObject    handle to run_moviemaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.sel_renderingbox,'Value')==1
    %figure number
    h_num = str2num(get(handles.fig_num,'string'));
    %sel current image as selected figure number
    gcf = h_num;
    %get capture range
    range = [str2num(get(handles.left_rend,'String'));str2num(get(handles.bottom_rend,'String'));str2num(get(handles.width_rend,'String'));str2num(get(handles.height_rend,'String'))];
    
    az_start = str2num(get(handles.Az_from,'String'));
    az_end = str2num(get(handles.Az_to,'String'));
    el_start = str2num(get(handles.el_from,'String'));
    el_end = str2num(get(handles.el_to,'String'));
    az_leng = abs(az_start - az_end);
    el_leng = abs(el_start - el_end);
    leng = round(max(az_leng,el_leng))+1;
    
    for n = 1:leng;
        view([az_start + (n-1)/leng*az_leng, el_start + (n-1)/leng*el_leng] )
        M(n) = getframe(gcf,range);
    end
    movie2avi(M,get(handles.save_file_name,'String'));
else % get(handles.sel_databox,'Value')==1
    
%     Scale = [str2double(get(handles.scale_min,'String')) str2double(get(handles.scale_max,'String'))];
%     ColorIndex = get(handles.color_tab,'Value');
%     Colorname = get(handles.color_tab,'String');
%     Color = cell2mat(Colorname(ColorIndex));
%     var_name = get(handles.Datalistbox,'String');
%     var_num = get(handles.Datalistbox,'Value');
%     Selected = evalin('base',cell2mat(var_name(var_num)));
    var_name = get(handles.datalist,'String');
    var_num = get(handles.datalist,'Value');
    Selected = evalin('base',cell2mat(var_name(var_num)));
    Dir = [get(handles.dim_y,'Value') get(handles.dim_x,'Value') get(handles.dim_z,'Value')];
    if get(handles.crop_checkbox,'Value') == 1
        Selected = Selected(str2num(get(handles.range_y,'String')),str2num(get(handles.range_x,'String')),str2num(get(handles.range_z,'String')));
    end
    if Dir(1) == 1
        Selected = permute(Selected,[3 1 1]);
    elseif Dir(2) ==1
        Selected = permute(Selected,[3 1 2]);
    else % Dir(3) == 1
        Selected = Selected;
    end
    Selected = abs(Selected);
    Size = size(Selected);
    Selected = Selected/max(max(max(Selected)))*255; % normalize
    Selected = uint8(Selected)+1;
    map = (0:1/double(max(max(max(Selected)))):1)';
    map = repmat(map,1,3);
    Selected_res = zeros(Size(1),Size(2),1,Size(3));
    Selected_res(:,:,1,:) = Selected;
    Selected_movie = immovie(Selected_res,map);
    movie2avi(Selected_movie,get(handles.save_file_name,'String'));
end
% --- Executes on selection change in datalist.
function datalist_Callback(hObject, eventdata, handles)
% hObject    handle to datalist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns datalist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from datalist

var_name = get(handles.datalist,'String');
var_num = get(handles.datalist,'Value');
Selected = evalin('base',cell2mat(var_name(var_num)));    
if ndims(Selected)~=3

else
    Size = size(Selected);
    set(handles.run_moviemaker,'enable','on')
    set(handles.range_x,'String',['1:',num2str(Size(2))]);
    set(handles.range_y,'String',['1:',num2str(Size(1))]);
    set(handles.range_z,'String',['1:',num2str(Size(3))]);    
end

% --- Executes during object creation, after setting all properties.
function datalist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datalist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in crop_checkbox.
function crop_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to crop_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of crop_checkbox
if get(hObject,'value')==1    
    set(handles.range_x,'enable','on');
    set(handles.range_y,'enable','on');
    set(handles.range_z,'enable','on');
else
    set(handles.range_x,'enable','off');
    set(handles.range_y,'enable','off');
    set(handles.range_z,'enable','off');
end

function fig_num_Callback(hObject, eventdata, handles)
% hObject    handle to fig_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fig_num as text
%        str2double(get(hObject,'String')) returns contents of fig_num as a double


% --- Executes during object creation, after setting all properties.
function fig_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in capture_check_rend.
function capture_check_rend_Callback(hObject, eventdata, handles)
% hObject    handle to capture_check_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of capture_check_rend



function left_rend_Callback(hObject, eventdata, handles)
% hObject    handle to left_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of left_rend as text
%        str2double(get(hObject,'String')) returns contents of left_rend as a double


% --- Executes during object creation, after setting all properties.
function left_rend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bottom_rend_Callback(hObject, eventdata, handles)
% hObject    handle to bottom_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bottom_rend as text
%        str2double(get(hObject,'String')) returns contents of bottom_rend as a double


% --- Executes during object creation, after setting all properties.
function bottom_rend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bottom_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function width_rend_Callback(hObject, eventdata, handles)
% hObject    handle to width_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_rend as text
%        str2double(get(hObject,'String')) returns contents of width_rend as a double


% --- Executes during object creation, after setting all properties.
function width_rend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function height_rend_Callback(hObject, eventdata, handles)
% hObject    handle to height_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height_rend as text
%        str2double(get(hObject,'String')) returns contents of height_rend as a double


% --- Executes during object creation, after setting all properties.
function height_rend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height_rend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Az_from_Callback(hObject, eventdata, handles)
% hObject    handle to Az_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Az_from as text
%        str2double(get(hObject,'String')) returns contents of Az_from as a double


% --- Executes during object creation, after setting all properties.
function Az_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Az_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function el_from_Callback(hObject, eventdata, handles)
% hObject    handle to el_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of el_from as text
%        str2double(get(hObject,'String')) returns contents of el_from as a double


% --- Executes during object creation, after setting all properties.
function el_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to el_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Az_to_Callback(hObject, eventdata, handles)
% hObject    handle to Az_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Az_to as text
%        str2double(get(hObject,'String')) returns contents of Az_to as a double


% --- Executes during object creation, after setting all properties.
function Az_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Az_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function el_to_Callback(hObject, eventdata, handles)
% hObject    handle to el_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of el_to as text
%        str2double(get(hObject,'String')) returns contents of el_to as a double


% --- Executes during object creation, after setting all properties.
function el_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to el_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function range_x_Callback(hObject, eventdata, handles)
% hObject    handle to range_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of range_x as text
%        str2double(get(hObject,'String')) returns contents of range_x as a double


% --- Executes during object creation, after setting all properties.
function range_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to range_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function range_y_Callback(hObject, eventdata, handles)
% hObject    handle to range_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of range_y as text
%        str2double(get(hObject,'String')) returns contents of range_y as a double


% --- Executes during object creation, after setting all properties.
function range_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to range_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function range_z_Callback(hObject, eventdata, handles)
% hObject    handle to range_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of range_z as text
%        str2double(get(hObject,'String')) returns contents of range_z as a double


% --- Executes during object creation, after setting all properties.
function range_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to range_z (see GCBO)
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

% Hints: contents = cellstr(get(hObject,'String')) returns color_tab contents as cell array
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



function scale_min_Callback(hObject, eventdata, handles)
% hObject    handle to scale_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_min as text
%        str2double(get(hObject,'String')) returns contents of scale_min as a double


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
