function varargout = help_message(varargin)
% HELP_MESSAGE M-file for help_message.fig
%      HELP_MESSAGE, by itself, creates a new HELP_MESSAGE or raises the existing
%      singleton*.
%
%      H = HELP_MESSAGE returns the handle to a new HELP_MESSAGE or the handle to
%      the existing singleton*.
%
%      HELP_MESSAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELP_MESSAGE.M with the given input arguments.
%
%      HELP_MESSAGE('Property','Value',...) creates a new HELP_MESSAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before help_message_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to help_message_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help help_message

% Last Modified by GUIDE v2.5 26-Apr-2010 17:20:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @help_message_OpeningFcn, ...
                   'gui_OutputFcn',  @help_message_OutputFcn, ...
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


% --- Executes just before help_message is made visible.
function help_message_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to help_message (see VARARGIN)

% Choose default command line output for help_message
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
message = importdata('help_message.txt');
set(handles.help_message,'String',message);

% UIWAIT makes help_message wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = help_message_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function help_message_CreateFcn(hObject, eventdata, handles)
% hObject    handle to help_message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in help_message.
function help_message_Callback(hObject, eventdata, handles)
% hObject    handle to help_message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns help_message contents as cell array
%        contents{get(hObject,'Value')} returns selected item from help_message


