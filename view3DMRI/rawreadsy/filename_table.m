function varargout = filename_table(varargin)
% FILENAME_TABLE M-file for filename_table.fig
%      FILENAME_TABLE, by itself, creates a new FILENAME_TABLE or raises the existing
%      singleton*.
%
%      H = FILENAME_TABLE returns the handle to a new FILENAME_TABLE or the handle to
%      the existing singleton*.
%
%      FILENAME_TABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILENAME_TABLE.M with the given input arguments.
%
%      FILENAME_TABLE('Property','Value',...) creates a new FILENAME_TABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before filename_table_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to filename_table_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help filename_table

% Last Modified by GUIDE v2.5 05-Apr-2011 21:45:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @filename_table_OpeningFcn, ...
                   'gui_OutputFcn',  @filename_table_OutputFcn, ...
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


% --- Executes just before filename_table is made visible.
function filename_table_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to filename_table (see VARARGIN)

% Choose default command line output for filename_table
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes filename_table wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = filename_table_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
