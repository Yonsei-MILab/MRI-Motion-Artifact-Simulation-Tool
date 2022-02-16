function varargout = customize(varargin)
% CUSTOMIZE MATLAB code for customize.fig
%      CUSTOMIZE, by itself, creates a new CUSTOMIZE or raises the existing
%      singleton*.
%
%      H = CUSTOMIZE returns the handle to a new CUSTOMIZE or the handle to
%      the existing singleton*.
%
%      CUSTOMIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CUSTOMIZE.M with the given input arguments.
%
%      CUSTOMIZE('Property','Value',...) creates a new CUSTOMIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before customize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to customize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help customize

% Last Modified by GUIDE v2.5 11-Feb-2020 20:32:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @customize_OpeningFcn, ...
                   'gui_OutputFcn',  @customize_OutputFcn, ...
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


% --- Executes just before customize is made visible.
function customize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to customize (see VARARGIN)

% Choose default command line output for customize
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes customize wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = customize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motion;
global trajec;

% Get default command line output from handles structure
varargout{1} = handles.output;
%varargout{2} = get(trajec);
%varargout{3} = get(motion);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)    %% 트레젝토리 매트릭스 가져오기
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trajec;

startingFolder = 'C:\Users\Seullee\Desktop\motion_simul';
if ~exist(startingFolder,'dir')
    startingFolder = pwd;
end
defaultfilename = fullfile(startingFolder, '*.mat');
[filename, path] = uigetfile(defaultfilename,'File Selector');
if filename == 0   % user clicked the cancel
    return;
end
name_t = strcat(path, filename);
input  = load(name_t);
fieldname = fieldnames(input);
if size(fieldname) == 0   % cancel
    return;
else 
    trajec = getfield(input,fieldname{1,1});
end

set(handles.text4, 'String', name_t);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)   % 모션 매트릭스 가져오기
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motion;

startingFolder = 'C:\Users\Seullee\Desktop\motion_simul';
if ~exist(startingFolder,'dir')
    startingFolder = pwd;
end
defaultfilename = fullfile(startingFolder, '*.mat');
[filename, path] = uigetfile(defaultfilename,'File Selector');
if filename == 0   % user clicked the cancel
    return;
end
name_m = strcat(path, filename);
input  = load(name_m);
fieldname = fieldnames(input);
if size(fieldname) == 0   % cancel
    return;
else 
    motion = getfield(input,fieldname{1,1});
end
set(handles.text5, 'String', name_m);




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)   %% 오케이 버튼
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global motion;
global trajec;

assignin('base','motion',motion);
assignin('base','trajec',trajec);
closereq();