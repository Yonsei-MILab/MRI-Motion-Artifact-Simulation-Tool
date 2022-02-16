function varargout = Renderer(varargin)
%RENDERER M-file for Renderer.fig
%      RENDERER, by itself, creates a new RENDERER or raises the existing
%      singleton*.
%
%      H = RENDERER returns the handle to a new RENDERER or the handle to
%      the existing singleton*.
%
%      RENDERER('Property','Value',...) creates a new RENDERER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Renderer_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      RENDERER('CALLBACK') and RENDERER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in RENDERER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Renderer

% Last Modified by GUIDE v2.5 24-Apr-2010 17:07:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Renderer_OpeningFcn, ...
                   'gui_OutputFcn',  @Renderer_OutputFcn, ...
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


% --- Executes just before Renderer is made visible.
function Renderer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Renderer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Renderer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Renderer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Data_list.
function Data_list_Callback(hObject, eventdata, handles)
% hObject    handle to Data_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Data_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Data_list
var_name = get(handles.Data_list,'String');
var_num = get(handles.Data_list,'Value');
Selected = evalin('base',cell2mat(var_name(var_num)));

if ndims(Selected)~=3
    set(handles.Rendering,'enable','off');
    set(handles.Crop_x,'enable','off');
    set(handles.Crop_y,'enable','off');
    set(handles.Crop_z,'enable','off');
    set(handles.Message_box,'String',['You should selected a 3-D data, this data is ',num2str(ndims(Selected)),'-D data']);    
else
    set(handles.Rendering,'enable','on');
    set(handles.Message_box,'String',[{'3D data is selected.'},{' '},{'Next step -> Define Crop range, colors, and especially Surface value'}]);
    Size = size(Selected);
    set(handles.Crop_x,'String',['1:',num2str(Size(2))]);
    set(handles.Crop_y,'String',['1:',num2str(Size(1))]);
    set(handles.Crop_z,'String',['1:',num2str(Size(3))]);
    if isreal(Selected) ==1
        hist(reshape(Selected,1,[]),20);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','w')
    else
        hist(reshape(abs(Selected),1,[]),20);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','w')
    end
end


% --- Executes during object creation, after setting all properties.
function Data_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Data_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Message_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Message_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in Load_data.
function Load_data_Callback(hObject, eventdata, handles)
% hObject    handle to Load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vars = evalin('base', 'who');
set(handles.Data_list,'string',vars);


% --- Executes on button press in Rendering.
function Rendering_Callback(hObject, eventdata, handles)
% hObject    handle to Rendering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Message_box,'String',['Rendering now']);    
var_name = get(handles.Data_list,'String');
var_num = get(handles.Data_list,'Value');
 
Selected = evalin('base',cell2mat(var_name(var_num)));

if get(handles.Crop_button,'Value') == 1
    Range_x = str2num(get(handles.Crop_x,'String'));
    Range_y = str2num(get(handles.Crop_y,'String'));
    Range_z = str2num(get(handles.Crop_z,'String'));
    Selected = Selected(Range_y,Range_x,Range_z);
end
Selected = flipdim(Selected,3);
IsoVal = str2double(get(handles.iso_surf_val,'String'));
ViewRatio = str2num(get(handles.Axes_ratio,'String'));
ViewAngle = str2num(get(handles.View_angle,'String'));

if get(handles.Color_button,'Value') == 1
    FColorIndex = get(handles.Color_tab_Face,'Value');
    FColorname = get(handles.Color_tab_Face,'String');
    FColor = cell2mat(FColorname(FColorIndex));
    EColorIndex = get(handles.Color_tab_Edge,'Value');
    EColorname = get(handles.Color_tab_Edge,'String');
    EColor = cell2mat(EColorname(EColorIndex));
else
    FColor = str2num(get(handles.RGB_Face,'String'));
    if get(handles.RGB_Edge,'String') == 'none'
        EColor = get(handles.RGB_Edge,'String');
    else
        EColor = str2num(get(handles.RGB_Edge,'String'));
    end
end
DoRender(Selected,IsoVal,FColor,EColor,ViewRatio,ViewAngle);



% Rendering(3D isosurface)
function DoRender(data,isoval,fcolor,ecolor,viewratio,viewangle)
if isreal(data) == 0
    data = abs(data);
end
maxval = max(max(max(data)));
minval = min(min(min(data)));
figure
axes('position',[0, 0, 1, 1]);
set(gca,'CLim',[minval maxval*2/3]);
p = patch(isosurface(data,isoval));
% p2 = patch(isocaps(data, isoval),'FaceColor','interp',...
%  'EdgeColor','none');
% colormap('gray')
isonormals(data,p);

if strcmp(fcolor,'none')||strcmp(fcolor,'flat')||strcmp(fcolor,'interp')
    if strcmp(ecolor,'none')
        set(p,'LineStyle','none');
    end
    if ~strcmp(fcolor,'none')
        aaa=get(p,'Vertices');
        cdata = aaa(:,3)';
        set(p,'FaceColor',fcolor,...
            'CData',cdata,...
            'CDataMapping','direct',...
            'EdgeColor',ecolor);
    end
else
    set(p,'FaceColor',fcolor,'EdgeColor',ecolor);
end
daspect(1./viewratio)
view(viewangle);
camlight
lighting phong
axis off
% alpha(.8)

global fig_current
fig_current= gcf;





function Axes_ratio_Callback(hObject, eventdata, handles)
% hObject    handle to Axes_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Axes_ratio as text
%        str2double(get(hObject,'String')) returns contents of Axes_ratio as a double


% --- Executes during object creation, after setting all properties.
function Axes_ratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function View_angle_Callback(hObject, eventdata, handles)
% hObject    handle to View_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of View_angle as text
%        str2double(get(hObject,'String')) returns contents of View_angle as a double


% --- Executes during object creation, after setting all properties.
function View_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to View_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function iso_surf_val_Callback(hObject, eventdata, handles)
% hObject    handle to iso_surf_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iso_surf_val as text
%        str2double(get(hObject,'String')) returns contents of iso_surf_val as a double


% --- Executes during object creation, after setting all properties.
function iso_surf_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iso_surf_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RGB_Face_Callback(hObject, eventdata, handles)
% hObject    handle to RGB_Face (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RGB_Face as text
%        str2double(get(hObject,'String')) returns contents of RGB_Face as a double


% --- Executes during object creation, after setting all properties.
function RGB_Face_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RGB_Face (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RGB_Edge_Callback(hObject, eventdata, handles)
% hObject    handle to RGB_Edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RGB_Edge as text
%        str2double(get(hObject,'String')) returns contents of RGB_Edge as a double


% --- Executes during object creation, after setting all properties.
function RGB_Edge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RGB_Edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Color_tab_Face.
function Color_tab_Face_Callback(hObject, eventdata, handles)
% hObject    handle to Color_tab_Face (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Color_tab_Face contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Color_tab_Face


% --- Executes during object creation, after setting all properties.
function Color_tab_Face_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Color_tab_Face (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Color_tab_Edge.
function Color_tab_Edge_Callback(hObject, eventdata, handles)
% hObject    handle to Color_tab_Edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Color_tab_Edge contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Color_tab_Edge


% --- Executes during object creation, after setting all properties.
function Color_tab_Edge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Color_tab_Edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Crop_x_Callback(hObject, eventdata, handles)
% hObject    handle to Crop_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Crop_x as text
%        str2double(get(hObject,'String')) returns contents of Crop_x as a double


% --- Executes during object creation, after setting all properties.
function Crop_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Crop_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Crop_y_Callback(hObject, eventdata, handles)
% hObject    handle to Crop_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Crop_y as text
%        str2double(get(hObject,'String')) returns contents of Crop_y as a double


% --- Executes during object creation, after setting all properties.
function Crop_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Crop_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Crop_z_Callback(hObject, eventdata, handles)
% hObject    handle to Crop_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Crop_z as text
%        str2double(get(hObject,'String')) returns contents of Crop_z as a double


% --- Executes during object creation, after setting all properties.
function Crop_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Crop_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in Crop_panel.
function Crop_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Crop_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'All_range_button'
        set(handles.Crop_x,'Enable','off');
        set(handles.Crop_y,'Enable','off');
        set(handles.Crop_z,'Enable','off');
    case 'Crop_button'        
        set(handles.Crop_x,'Enable','on');
        set(handles.Crop_y,'Enable','on');
        set(handles.Crop_z,'Enable','on');
    otherwise
        % Code for when there is no match.
end


% --- Executes when selected object is changed in Color_panel.
function Color_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Color_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'Color_button'
        set(handles.RGB_Face,'Enable','off');
        set(handles.RGB_Edge,'Enable','off');
        set(handles.Color_tab_Face,'Enable','on');
        set(handles.Color_tab_Edge,'Enable','on');
        set(handles.Message_box,'String',['Choose rendering Colors']);    
    case 'RGB_button'        
        set(handles.RGB_Face,'Enable','on');
        set(handles.RGB_Edge,'Enable','on');
        set(handles.Color_tab_Face,'Enable','off');
        set(handles.Color_tab_Edge,'Enable','off');
        set(handles.Message_box,'String',[{'Skin color value'},{''},{'-> about 1.0 0.8 0.8'},{''},{'You can put "none" at the Edge Color'}]);    
    otherwise
        % Code for when there is no match.
end


% --- Executes on button press in View_angles_button.
function View_angles_button_Callback(hObject, eventdata, handles)
% hObject    handle to View_angles_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fig_current
figure(fig_current)
view(str2num(get(handles.View_angle,'String')))
set(handles.Message_box,'String',['Change the view point as [Az el] = [',get(handles.View_angle,'String'),']']);    


% --- Executes on button press in Axes_ratio_button.
function Axes_ratio_button_Callback(hObject, eventdata, handles)
% hObject    handle to Axes_ratio_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fig_current
figure(fig_current)
daspect(1./str2num(get(handles.Axes_ratio,'String')))
set(handles.Message_box,'String',[{'Change the View Resolution'},{''},{'ex) 2 2 5 means 2 x 2 x 5 resolution'}]);


% --- Executes on button press in close_all.
function close_all_Callback(hObject, eventdata, handles)
% hObject    handle to close_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = get(0,'children');
h = h.*(mod(h,1)==0);
% figurecount = length(findobj('Type','figure')); 
close(h(h~=0))


% --- Executes on key press with focus on Axes_ratio and none of its controls.
function Axes_ratio_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Axes_ratio (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key, 'return')
    Axes_ratio_button_Callback(hObject, eventdata, handles)
end



% --- Executes on key press with focus on View_angle and none of its controls.
function View_angle_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to View_angle (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key, 'return')
   View_angles_button_Callback(hObject, eventdata, handles)
end
