function varargout = MRIV(varargin)
% MRIV M-file for MRIV.fig
%      MRIV, by itself, creates a new MRIV or raises the existing
%      singleton*.
%
%      H = MRIV returns the handle to a new MRIV or the handle to
%      the existing singleton*.
%
%      MRIV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MRIV.M with the given input arguments.
%
%      MRIV('Property','Value',...) creates a new MRIV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MRIV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MRIV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MRIV

% Last Modified by GUIDE v2.5 06-Dec-2010 13:53:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MRIV_OpeningFcn, ...
                   'gui_OutputFcn',  @MRIV_OutputFcn, ...
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


% --- Executes just before MRIV is made visible.
function MRIV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MRIV (see VARARGIN)

% Choose default command line output for MRIV
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
axes(handles.logoview);
imshow('logo.png')


% UIWAIT makes MRIV wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MRIV_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in view3Dmri_button.
function view3Dmri_button_Callback(hObject, eventdata, handles)
% hObject    handle to view3Dmri_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view3Dmri;


% --- Executes on button press in allplot_button.
function allplot_button_Callback(hObject, eventdata, handles)
% hObject    handle to allplot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allplot;


% --- Executes on button press in rendering_button.
function rendering_button_Callback(hObject, eventdata, handles)
% hObject    handle to rendering_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Renderer;


% --- Executes on button press in movie_maker_button.
function movie_maker_button_Callback(hObject, eventdata, handles)
% hObject    handle to movie_maker_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moviemaker;


% --- Executes on button press in quit_button.
function quit_button_Callback(hObject, eventdata, handles)
% hObject    handle to quit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = get(0,'children');
close(h(mod(h,1)~=0));
% figurecount = length(findobj('Type','figure')); 




% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
help_message;


% --- Executes on mouse press over axes background.
function logoview_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to logoview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% web('http://kimchi.yonsei.ac.kr', '-new');


% --- Executes on button press in roi_tool.
function roi_tool_Callback(hObject, eventdata, handles)
% hObject    handle to roi_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_tool


