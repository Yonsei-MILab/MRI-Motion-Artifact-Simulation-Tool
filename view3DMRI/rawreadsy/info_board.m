function varargout = info_board(varargin)
%INFO_BOARD M-file for info_board.fig
%      INFO_BOARD, by itself, creates a new INFO_BOARD or raises the existing
%      singleton*.
%
%      H = INFO_BOARD returns the handle to a new INFO_BOARD or the handle to
%      the existing singleton*.
%
%      INFO_BOARD('Property','Value',...) creates a new INFO_BOARD using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to info_board_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      INFO_BOARD('CALLBACK') and INFO_BOARD('CALLBACK',hObject,...) call the
%      local function named CALLBACK in INFO_BOARD.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help info_board

% Last Modified by GUIDE v2.5 07-Dec-2009 01:27:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @info_board_OpeningFcn, ...
                   'gui_OutputFcn',  @info_board_OutputFcn, ...
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


% --- Executes just before info_board is made visible.
function info_board_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for info_board
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes info_board wait for user response (see UIRESUME)
% uiwait(handles.figure_info);


% --- Outputs from this function are returned to the command line.
function varargout = info_board_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% varargout{2} = handles;



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
