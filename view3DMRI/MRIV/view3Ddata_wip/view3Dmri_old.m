function varargout = view3Dmri(varargin)

% VIEW3DMRI M-file for view3Dmri.fig
%      VIEW3DMRI, by itself, creates a new VIEW3DMRI or raises the existing
%      singleton*.
%
%      H = VIEW3DMRI returns the handle to a new VIEW3DMRI or the handle to
%      the existing singleton*.
%
%      VIEW3DMRI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW3DMRI.M with the given input arguments.
%
%      VIEW3DMRI('Property','Value',...) creates a new VIEW3DMRI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view3Dmri_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view3Dmri_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view3Dmri

% Last Modified by GUIDE v2.5 23-Oct-2009 09:38:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view3Dmri_OpeningFcn, ...
                   'gui_OutputFcn',  @view3Dmri_OutputFcn, ...
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


% --- Executes just before view3Dmri is made visible.
function view3Dmri_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view3Dmri (see VARARGIN)

% Choose default command line output for view3Dmri
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% initialize

% ---- Below is an example of getting all object properties ---------
% ---- but, no use --------------------------------------------------
% guide_setting = struct('fname',[],'fv',[]);
% guide_setting.fname = fieldnames(handles);
% lf = length(guide_setting.fname);
% 
% guide_setting.fv = cell(lf,1);
% for k=1:lf
%     guide_setting.fv{k} = eval(['get(','handles.',guide_setting.fname{k},');']);
% end
% ---------------------------------------------------------------------
global Gv3DenLarged_imH;
global Gv3Dres;

% -- select initial figure number at once
Gv3DenLarged_imH = struct('init_fig_index',randi([1000,20000]),'opened_fig_indic',[]);

%-------------------- set figure size --- modified at 2009.10.31 -----------------
set(handles.figure1,'position',[0.15 0.1 0.7 0.8])

set(handles.figure1,'WindowButtonDownFcn',@mybuttondown)
set(handles.figure1,'CloseRequestFcn',@my_closefcn)

set(handles.uipanel1,'position',[0.001,0.042,0.499,0.484])
set(handles.uipanel2,'position',[0.501,0.042,0.499,0.484])
set(handles.uipanel3,'position',[0.001,0.516,0.499,0.484])
set(handles.uipanel4,'position',[0.501,0.516,0.499,0.484])

%------ to avoid Matlab GUIDE error according to its version
%------ make toolbar that has user defined callback func.
if isempty(findobj(handles.uitoolbar1,'tag','uipushtool_open'))
    clrmenu     % Add colormap menu to figure window - see help

    
    uipushtool_open = uipushtool(handles.uitoolbar1,...
        'CData',iconRead(fullfile(matlabroot,'toolbox\matlab\icons\opendoc.mat')),...
        'tag','uipushtool_open',...
        'tooltipstring','Open Files',...
        'ClickedCallback',{@uipushtool_open_ClickedCallback,handles});
    
    uipushtool_save = uipushtool(handles.uitoolbar1,...
        'CData',iconRead('file_save.png'),...
        'tag','uipushtool_save',...
        'tooltipstring','Save all loaded data to .mat file',...
        'ClickedCallback',{@uipushtool_save_ClickedCallback,handles});
    
    % change order to locate most left
    oldOrder = allchild(handles.uitoolbar1);
    newOrder = circshift(oldOrder,-2);
    set(handles.uitoolbar1,'Children',newOrder);
    
    uipushtool_importWorkVar = uipushtool(handles.uitoolbar1,...
        'CData',iconRead('linkproduct.png'),...
        'tag','uipushtool_importWorkVar',...
        'tooltipstring','Import base workspace variable',...
        'Separator','on',...
        'ClickedCallback',{@menu_impvar_Callback,handles});
    
end


% set(handles.uipushtool_open,'ClickedCallback',{@uipushtool_open_ClickedCallback,handles});
% uipushtool('ClickedCallback',@uipushtool_save_ClickedCallback);


Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

set(handles.edit_y_res,'string','1.0');
set(handles.edit_x_res,'string','1.0');
set(handles.edit_z_res,'string','1.0');

initializing(handles)

read_logfile;

%------------------------------------------------------

% UIWAIT makes view3Dmri wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view3Dmri_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_open_cpx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open_cpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


pushbutton_openPHcpx_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_open_mat_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dres;

read_logfile;

default_filepath = Gv3Dimage_spec.filepath;
if ~isempty(Gv3Dimage_spec.filename) && strcmp(Gv3Dimage_spec.type,'mat')
    if iscell(Gv3Dimage_spec.filename)
        default_filepath = [default_filepath,Gv3Dimage_spec.filename{1}];
    else
        default_filepath = [default_filepath,Gv3Dimage_spec.filename];
    end
end

[filename,filepath] = uigetfile({'*.mat','MAT-files (*.mat)'},...
    'Open Matlab file',default_filepath,...
    'MultiSelect', 'on');

if isequal(filename,0)
    disp('Files are not selected');
    return;
end

% save filepath neither didn't open file
Gv3Dimage_spec.filepath = filepath;
write_logfile;


initializing(handles)
Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

if ~iscell(filename)
    
    try
        disp('Loading .mat file...')
        % ------- extract one data from .mat file ------------------------------
        data = load([filepath filename]);   % save in struct
        var_name = sort(fieldnames(data));    % get variable name in struct to cell
        
        set(handles.listbox_var,'string',var_name);
        if length(var_name)>1
            set(handles.pushbutton_var,'enable','on');
        end
        
        
        % ----------------------------------------------------------------------
        disp('Done!!')

        Gv3Dimage_spec.data = data;
        Gv3Dimage_spec.filename = filename;
%         Gv3Dimage_spec.filepath = filepath;

        clear data;

        change_var(hObject, eventdata, handles)
        
    catch %ME
%         disp(ME)
%         disp(ME.stack(1))
%         disp(ME.message)
%         if ~isempty(strfind(ME.message,'HELP MEMORY'))
%             errordlg('Out of Memory','Loading Error','modal');
%         end
    end
    
    
    
else
    filename = sort(filename);
    
    ns = length(filename);
    
    ny_vec = zeros(ns,1);
    nx_vec = zeros(ns,1);
    
    check_reformat = 0;
    
    num_slice = 0;
    for n=1:ns
        try
            disp('Loading .mat file...')
            % ------- extract one data from .mat file ------------------------------
            data = load([filepath filename{n}]);   % save in struct
%             data = uiimport([filepath filename{n}]);
            var_name = sort(fieldnames(data));    % get variable name in struct to cell
            im = eval(['data.',var_name{1}]);   % save file data to 'im'
            % ----------------------------------------------------------------------
            disp('Done!!')

            [ny,nx,nz] = size(im);

            if nz==1
                num_slice = num_slice+1;
                Gv3Dimage_spec.filename{num_slice} = filename{num_slice};
                Gv3Dimage_spec.image_data{num_slice} = im;
                
                Gv3Dimage_spec.data{num_slice} = data;
                
                % save Ny and Nx
                ny_vec(num_slice) = ny;
                nx_vec(num_slice) = nx;
                
                check_reformat = 1;
                
                Gv3Dimage_spec.is3D = 0;
                Gv3Dimage_spec.ns = num_slice;
            end

        catch %ME
%             disp(ME)
%             disp(ME.stack(1))
%             disp(ME.message)
%             if ~isempty(strfind(ME.message,'HELP MEMORY'))
%                 errordlg('Out of Memory','Loading Error','modal');
%             end
%             break;
        end
    end
    
    clear im
        
    if check_reformat
        % check ny_vec
        isSameNy = sum(ny_vec==ny_vec(1))/num_slice;
        % check nx_vec
        isSameNx = sum(nx_vec==nx_vec(1))/num_slice;
        
        % make multi-slice to 3D data
        if isSameNy==1 && isSameNx==1
            im = zeros(ny_vec(1),nx_vec(1),num_slice);
            
            for z = 1:num_slice
                im(:,:,z) = Gv3Dimage_spec.image_data{z};
            end
            
            Gv3Dimage_spec.nx = nx_vec(1);
            Gv3Dimage_spec.ny = ny_vec(1);
            Gv3Dimage_spec.nz = num_slice;
            
            Gv3Dimage_spec.is3D = 1;
            Gv3Dimage_spec.image_data = im;
            Gv3Dimage_spec.filename = Gv3Dimage_spec.filename{1};
            
            Gv3Dimage_spec.selected_var = 'multiSlice';
            
            Gv3Dimage_spec.data = im;
            
            clear im
        end
    end


end

% save filepath neither didn't open file
Gv3Dimage_spec.filepath = filepath;

plot_image(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uipushtool_save_ClickedCallback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


my_closefcn

% --------------------------------------------------------------------
function uipushtool_open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


menu_open_mat_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function uipushtool_save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;

read_logfile;

if iscell(Gv3Dimage_spec.filename) && Gv3Dimage_spec.is3D == 0
    
    for n=1:Gv3Dimage_spec.ns
        if isempty(strfind(Gv3Dimage_spec.filename{n},'.mat'))
            Gv3Dimage_spec.filename{n} = [Gv3Dimage_spec.filename{n},'.mat'];
        end

        var_name = sort(fieldnames(Gv3Dimage_spec.data{n}));    % get variable name in struct to cell
        
        eval(['Gv3Dimage_spec.data{n}.',var_name{1},...
            '=Gv3Dimage_spec.image_data{n};']);
        data = Gv3Dimage_spec.data{n};

        disp('Saving to .mat file...')
        save([Gv3Dimage_spec.filepath,Gv3Dimage_spec.filename{n}],...
            '-struct','data'); % save structure field not support
        disp('File saved in path = ')
        disp([' ',Gv3Dimage_spec.filepath])
    end
    
else
    if isempty(strfind(Gv3Dimage_spec.filename,'.mat'))
        Gv3Dimage_spec.filename = [Gv3Dimage_spec.filename,'.mat'];
    end

    if Gv3Dimage_spec.is3D
        eval(['Gv3Dimage_spec.data.',Gv3Dimage_spec.selected_var,...
            '=Gv3Dimage_spec.image_data;']);
    else
        eval(['Gv3Dimage_spec.data.',Gv3Dimage_spec.selected_var,...
            '=Gv3Dimage_spec.image_data{1};']);
    end
    
    data = Gv3Dimage_spec.data;

    disp('Saving to .mat file...')
    
    
    [filename, pathname] = uiputfile('*.mat','Save current data as' ,...
        [Gv3Dimage_spec.filepath,Gv3Dimage_spec.filename]);
    
    if isequal(filename,0) || isequal(pathname,0)
        pathname = Gv3Dimage_spec.filepath;
        filename = Gv3Dimage_spec.filename;
    else
        Gv3Dimage_spec.filepath = pathname;
    end
    
    
    save([pathname,filename],...
        '-struct','data'); % save structure field not support
    
    disp('File saved in path = ')
    disp([' ',pathname])
end

if ~isempty(Gv3Dimage_spec.filepath)
    write_logfile;
end

% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


msgbox({'MRI 3D Data Viewer ver.8.2',...
    'WIP version;;;',...
    'GUI made by cefca (Sang-Young Zho).',...
    'Last Modified at 2009.10.31'},'About..','modal');


function my_closefcn(hObject, eventdata, handles)

global Gv3Dimage_spec;

try
    if ~isempty(Gv3Dimage_spec.filepath)
        write_logfile;
    end
catch
end

fprintf('\n\nExit from : view3Dmri.\n\n')

fclose all;
munlock
closereq


% --- Executes on button press in pushbutton_ax1next.
function pushbutton_ax1next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax1next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;

if Gv3Dimage_spec.is3D
    max_index = Gv3Dimage_spec.nz;
else
    max_index = Gv3Dimage_spec.ns;
end
    
if Gv3Dslice_index.xy == max_index
    Gv3Dslice_index.xy = 1;
else
    Gv3Dslice_index.xy = Gv3Dslice_index.xy+1;
end

plot_xyview(handles)

% --- Executes on button press in pushbutton_ax1prev.
function pushbutton_ax1prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax1prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;

if Gv3Dimage_spec.is3D
    max_index = Gv3Dimage_spec.nz;
else
    max_index = Gv3Dimage_spec.ns;
end
    
if Gv3Dslice_index.xy == 1
    Gv3Dslice_index.xy = max_index;
else
    Gv3Dslice_index.xy = Gv3Dslice_index.xy-1;
end

plot_xyview(handles)

% --- Executes on button press in pushbutton_ax3next.
function pushbutton_ax3next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax3next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;

if Gv3Dslice_index.xz == Gv3Dimage_spec.ny
    Gv3Dslice_index.xz = 1;
else
    Gv3Dslice_index.xz = Gv3Dslice_index.xz+1;
end

plot_xzview(handles)

% --- Executes on button press in pushbutton_ax3prev.
function pushbutton_ax3prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax3prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;

if Gv3Dslice_index.xz == 1
    Gv3Dslice_index.xz = Gv3Dimage_spec.ny;
else
    Gv3Dslice_index.xz = Gv3Dslice_index.xz-1;
end

plot_xzview(handles)

% --- Executes on button press in pushbutton_ax2next.
function pushbutton_ax2next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax2next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;

if Gv3Dslice_index.yz == Gv3Dimage_spec.nx
    Gv3Dslice_index.yz=1;
else
    Gv3Dslice_index.yz = Gv3Dslice_index.yz+1;
end

plot_yzview(handles)

% --- Executes on button press in pushbutton_ax2prev.
function pushbutton_ax2prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax2prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Gv3Dimage_spec;
global Gv3Dslice_index;

if Gv3Dslice_index.yz == 1
    Gv3Dslice_index.yz = Gv3Dimage_spec.nx;
else
    Gv3Dslice_index.yz = Gv3Dslice_index.yz-1;
end

plot_yzview(handles)


% --- Executes on button press in pushbutton_openPHcpx.
function pushbutton_openPHcpx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_openPHcpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;
% global seleted_panel;
global Gv3Dres;

%% read ascii file

read_logfile;

default_filepath = Gv3Dimage_spec.filepath;
if ~isempty(Gv3Dimage_spec.filename) && strcmp(Gv3Dimage_spec.type,'cpx')
    default_filepath = [default_filepath,Gv3Dimage_spec.filename,'.list'];
end

[temp filepath] = uigetfile({'cpx*.list','List files (*.list)'},...
    'Open Philips cpx data',default_filepath);

if isequal(temp,0)
    disp('Files are not selected');
    return;
end

% save filepath neither didn't open file
Gv3Dimage_spec.filepath = filepath;
write_logfile;

initializing(handles)
Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

filename = temp(1:length(temp)-5);


%--------- get List data
fid = fopen([filepath filename '.list'],'r');
list = fread(fid,5*1024,'char');   % A = fread(fid, count, precision)
fclose(fid);

list = char(list');

%% extract info from header (list)
sep_text = ' : ';

%--------------------------- find Scan name
text_scanname = 'Scan name';
scanname = findAsc(list,text_scanname,sep_text);

%--------------------------- find nx
text_nx = 'X-resolution';
nx = str2double(findAsc(list,text_nx,sep_text));

%--------------------------- find ny
text_ny = 'Y-resolution';
ny = str2double(findAsc(list,text_ny,sep_text));

%--------------------------- find nz
text_nz = 'Z-resolution';
nz = str2double(findAsc(list,text_nz,sep_text));

%--------------------------- find ns
text_ns = 'number_of_locations';
ns = str2double(findAsc(list,text_ns,sep_text));

%--------------------------- find vec info
text_datavecinfo = ['# typ mix   dyn   card  echo  loca  chan  extr1 extr2 ',...
    'y     z     n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  size   offset',...
    char(13),char(10),...
    '# --- ----- ----- ----- ----- ----- ----- ----- ----- ',...
    '----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ------ ------',...
    char(13),char(10),'#',char(13),char(10)];

sep_datavecinfo = 'STD ';

hdr_datavecinfo = ['mix   dyn   card  echo  loca  chan  extr1 extr2 ',...
    'y     z     n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  size   offset'];
first_datavecinfo = findAsc(list,text_datavecinfo,sep_datavecinfo);

hdr_datavec = mystrtok(hdr_datavecinfo,' ',0);
first_datavec = mystrtok(first_datavecinfo,' ',1);

byte_offset = first_datavec(strcmp(hdr_datavec,{'offset'}));

if isempty(nz)   % if no 'Z-resolution' info
    is3D=0;
    text_3D = '2D data';
    offset = first_datavec(strcmp(hdr_datavec,{'loca'}));
else
    is3D=1;
    text_3D = '3D data';
    offset = first_datavec(strcmp(hdr_datavec,{'z'}));
end

%% view info and save spec

% do not make cell array of string !!
% which make code complicate
info_list = strvcat([filename,'.list'],...
    [text_scanname,sep_text,scanname],...
    [text_nx,sep_text,num2str(nx)],...
    [text_ny,sep_text,num2str(ny)],...
    [text_nz,sep_text,num2str(nz)],...
    [text_ns,sep_text,num2str(ns)],...
    ['Data Type = ',text_3D]);

Gv3Dimage_spec.filename = filename;
Gv3Dimage_spec.filepath = filepath;
Gv3Dimage_spec.scanname = scanname;
Gv3Dimage_spec.nx = nx;
Gv3Dimage_spec.ny = ny;
Gv3Dimage_spec.nz = nz;
Gv3Dimage_spec.ns = ns;
Gv3Dimage_spec.is3D = is3D;
Gv3Dimage_spec.offset = offset;
Gv3Dimage_spec.type = 'cpx';

set(handles.listbox_info,'string',info_list);

%% load image and plot it

fid=fopen([filepath filename '.data'],'r','ieee-le');

if fid==-1
    errordlg(['No [',filename,'.data','] file.'],'File error','modal');
    return;
end

if is3D
    try
        disp('Reading whole 3D data...') 
        data = readPHcpx(filepath,filename,nx,ny,nz,ns,is3D,1,offset);
        Gv3Dimage_spec.image_data = data;
        disp('Done~!!')
    catch %ME
%         disp(ME)
%         disp(ME.stack(1))
%         disp(ME.message)
%         if ~isempty(strfind(ME.message,'HELP MEMORY'))
%             errordlg('Out of Memory','Loading Error','modal');
%         end
    end
    
    set(handles.pushbutton_ax1prev,'enable','on');
    set(handles.pushbutton_ax1next,'enable','on');
    set(handles.pushbutton_ax2prev,'enable','on');
    set(handles.pushbutton_ax2next,'enable','on');
    set(handles.pushbutton_ax3prev,'enable','on');
    set(handles.pushbutton_ax3next,'enable','on');

else
    
    if ns>1
        set(handles.pushbutton_ax1prev,'enable','on');
        set(handles.pushbutton_ax1next,'enable','on');
        
        set(handles.text_xyindex,'enable','on');
    end

end

% seleted_panel = 'uipanel1';   % no use

set(handles.pushbutton_resetindex,'enable','on');
set(handles.figure1,'KeyPressFcn',{@mykeypress,handles})
set(handles.pushbutton_save2mat,'enable','on');

write_logfile;

set(handles.checkbox_viewphase,'enable','on')
set(handles.checkbox_max2axes,'enable','on');

if Gv3Dimage_spec.is3D
    set(handles.checkbox_mip_xy,'enable','on');
    set(handles.checkbox_mip_yz,'enable','on');
    set(handles.checkbox_mip_xz,'enable','on');
    
    set(handles.pushbutton_chxy,'enable','on');
    set(handles.pushbutton_chyz,'enable','on');
    set(handles.pushbutton_chzx,'enable','on');
    
    set(handles.pushbutton_flz,'enable','on');
    set(handles.pushbutton_flx,'enable','on');
    set(handles.pushbutton_fly,'enable','on');
    
    set(handles.text_xyindex,'enable','on');
    set(handles.text_yzindex,'enable','on');
    set(handles.text_xzindex,'enable','on');
    
    set(handles.checkbox_max2axes,'enable','on');
    
    Gv3Dslice_index.xy = round(Gv3Dimage_spec.nz/2);
    Gv3Dslice_index.yz = round(Gv3Dimage_spec.nx/2);
    Gv3Dslice_index.xz = round(Gv3Dimage_spec.ny/2);
    
    set(handles.slider_max,'enable','on')
%------------ do not attempt following - complicate -------------
% else
%     set(handles.pushbutton_flx,'enable','on');
%     set(handles.pushbutton_fly,'enable','on');
%     
%     set(handles.pushbutton_chxy,'enable','on');
%-------------------------------------------------
end

plot_xyzview(handles)


% --- Executes on button press in pushbutton_resetindex.
function pushbutton_resetindex_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_resetindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dslice_index;
global Gv3Dimage_spec;


if Gv3Dimage_spec.is3D
    Gv3Dslice_index.xy = round(Gv3Dimage_spec.nz/2);
    Gv3Dslice_index.yz = round(Gv3Dimage_spec.nx/2);
    Gv3Dslice_index.xz = round(Gv3Dimage_spec.ny/2);
else
    Gv3Dslice_index = struct('xy',1,'yz',1,'xz',1);
end
plot_xyzview(handles)

% --- Executes on selection change in listbox_info.
function listbox_info_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_info contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info


% --- Executes during object creation, after setting all properties.
function listbox_info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plot_xyview(handles)


global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global Gv3Dcur_max_Intensity;
global Gv3Disphase;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global Gv3Dres;

try
    % -- plot x-y view
    axes(handles.axes1);
    if Gv3Dimage_spec.is3D
        if Gv3Dchk_mip.xy
            temp = Gv3Dimage_spec.mip.xy;
        else
            temp = Gv3Dimage_spec.image_data(:,:,Gv3Dslice_index.xy);
        end
    else

        switch Gv3Dimage_spec.type
            case 'cpx'
                temp = readPHcpx(Gv3Dimage_spec.filepath,Gv3Dimage_spec.filename,...
                    Gv3Dimage_spec.nx,Gv3Dimage_spec.ny,Gv3Dimage_spec.nz,...
                    Gv3Dimage_spec.ns,Gv3Dimage_spec.is3D,Gv3Dslice_index.xy,Gv3Dimage_spec.offset);
                Gv3Dimage_spec.image_data = temp;
            case 'mat'
                change_info(handles)
                temp = Gv3Dimage_spec.image_data{Gv3Dslice_index.xy};
        end
    end

    [r,c] = size(temp);

    if ischar(temp) || iscellstr(temp)

        %         temp_h = plot(1);
        %         set(gca,'Visible','on','XTick',[],'YTick',[]);
        %         delete(temp_h);
        %         text(0.05,0.2,{'text :',temp},...
        %             'fontsize',18,'BackgroundColor','white',...
        %             'Interpreter','none');
        axis off;
        set(handles.listbox_textbox,'string',temp);
        set(handles.listbox_textbox,'Visible','on');
        set(handles.text_toplistbox,'Visible','on');

    else
        if r>1 && c>1
            if Gv3Disphase
                temp = angle(temp);
            end            
            if isempty(Gv3Dcur_max_Intensity)
                mrimagef(temp,[],1);
            else
                if isreal(temp)
                    min_clim = min(temp(:));
                else
                    min_clim = min(mag(temp(:)));
                end
%                 mrimagef(temp,[min_clim,...
%                     min(max(mag(temp(:))),Gv3Dcur_max_Intensity)],1);
                mrimagef(temp,[min_clim,...
                    Gv3Dcur_max_Intensity],1);
            end
            daspect([Gv3Dres.y Gv3Dres.x 1])
            
            if Gv3Daxes_normal.xy
                axis normal;
            end
            set(handles.text_xyindex,'string',Gv3Dslice_index.xy);

        elseif r==1 && c==1
            temp_h = plot(1);
            set(gca,'Visible','on','XTick',[],'YTick',[]);
            delete(temp_h);
            text(0.1,0.5,{'single data :',num2str(temp)},...
                'fontsize',18,'BackgroundColor','white',...
                'Interpreter','none');
        else
            plot(temp,'b.-'); % why this become gray when didn't specify the color?
            grid on;
            set(handles.axes1,'Visible','on');
            %     set(handles.axes1,'ActivePositionProperty','outerposition');
        end

        %-- mini plot x-y
        axes(handles.axes4);
        mrimagef(temp,[],1);
        enableAxesmove(handles.axes4, handles)

        Gv3Daxes_data.xy = temp;
        set(handles.pushbutton_enla1,'enable','on');
    end
    
    if Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap)
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(Gv3DcurCmap)
    else
        colormap gray
    end

catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
%     disp('Selected data can not plottable...')
end

function plot_yzview(handles)


global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global Gv3Dcur_max_Intensity;
global Gv3Disphase;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global Gv3Dres;

try
    if Gv3Dimage_spec.is3D
        % -- plot y-z view
        axes(handles.axes2);
        
        if Gv3Dchk_mip.yz
            temp = Gv3Dimage_spec.mip.yz;
        else
            temp = Gv3Dimage_spec.image_data(:,Gv3Dslice_index.yz,:);
            temp = permute(temp,[1 3 2]);
        end
        
        if Gv3Disphase
            temp = angle(temp);
        end
        if isempty(Gv3Dcur_max_Intensity)
            mrimagef(temp,[],1);
        else
            if isreal(temp)
                min_clim = min(temp(:));
            else
                min_clim = min(mag(temp(:)));
            end
%             mrimagef(temp,[min_clim,...
%                 min(max(mag(temp(:))),Gv3Dcur_max_Intensity)],1);
            mrimagef(temp,[min_clim,...
                Gv3Dcur_max_Intensity],1);
        end

        daspect([Gv3Dres.y Gv3Dres.z 1])
        
        if Gv3Daxes_normal.yz
            axis normal;
        end
        set(handles.text_yzindex,'string',Gv3Dslice_index.yz);

        Gv3Daxes_data.yz = temp;
        set(handles.pushbutton_enla2,'enable','on');

        %-- mini plot y-z
        axes(handles.axes5);
        mrimagef(temp,[],1);
        enableAxesmove(handles.axes5, handles)
    end
    
    if Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap)
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(Gv3DcurCmap)
    else
        colormap gray
    end
    
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
%     disp('Selected data can not plottable...')
end

function plot_xzview(handles)


global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global Gv3Dcur_max_Intensity;
global Gv3Disphase;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global Gv3Dres;

try
    if Gv3Dimage_spec.is3D

        % -- plot x-z view
        axes(handles.axes3);
        if Gv3Dchk_mip.xz
            temp = Gv3Dimage_spec.mip.xz;
        else
            temp = Gv3Dimage_spec.image_data(Gv3Dslice_index.xz,:,:);
            temp = permute(temp,[3 2 1]);
        end
        
        % NOTE : left-top corner is always (1,1)
%         temp = flipud(temp);
        if Gv3Disphase
            temp = angle(temp);
        end
        if isempty(Gv3Dcur_max_Intensity)
            mrimagef(temp,[],1);
        else
            if isreal(temp)
                min_clim = min(temp(:));
            else
                min_clim = min(mag(temp(:)));
            end
%             mrimagef(temp,[min_clim,...
%                 min(max(mag(temp(:))),Gv3Dcur_max_Intensity)],1);
            mrimagef(temp,[min_clim,...
                Gv3Dcur_max_Intensity],1);
        end
        
        daspect([Gv3Dres.z Gv3Dres.x 1])
        
        if Gv3Daxes_normal.xz
            axis normal;
        end
        set(handles.text_xzindex,'string',Gv3Dslice_index.xz);

        Gv3Daxes_data.xz = temp;
        set(handles.pushbutton_enla3,'enable','on');

        %-- mini plot x-z
        axes(handles.axes6);
        mrimagef(temp,[],1);
        enableAxesmove(handles.axes6, handles)
    end
    
    if Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap)
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(Gv3DcurCmap)
    else
        colormap gray
    end
    
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
%     disp('Selected data can not plottable...')
end

function plot_xyzview(handles)
% 
% some comment :
% when using key_press_func, seperate plot func executes much faster
% 

set(handles.checkbox_axis1,'enable','on')
set(handles.checkbox_axis2,'enable','on')
set(handles.checkbox_axis3,'enable','on')

plot_xyview(handles)
plot_yzview(handles)
plot_xzview(handles)

set_imageSizeEqual(handles)


function initializing(handles)



global Gv3Dimage_spec;
global num_keypressed;


Gv3Dimage_spec = struct('filename',[],'filepath','../',...
    'scanname',[],'is3D',1,...
    'nx',[],'ny',[],'nz',[],'ns',[],...
    'offset',0,'type',[],...
    'image_data',[],'data',[],'selected_var',[],...
    'mip',[]);


% ------------ don't forget this line !! --------------------
num_keypressed = 0;

set(handles.listbox_info,'string','Information');
set(handles.listbox_var,'string','Variable Name');
set(handles.listbox_var,'Value',1)

set(handles.pushbutton_save2mat,'enable','off');
set(handles.pushbutton_var,'enable','off');
% set(handles.pushbutton_close_enla,'enable','off');

set(handles.figure1,'KeyPressFcn',[])

set(handles.axes4,'ButtonDownFcn',{@axesmove,handles})
set(handles.axes5,'ButtonDownFcn',{@axesmove,handles})
set(handles.axes6,'ButtonDownFcn',{@axesmove,handles})

clear_axes(handles)


function mybuttondown(hObject, eventdata)


global seleted_panel;

ht = handle(hittest(hObject));
seleted_panel = get(ancestor(ht,'uipanel'),'tag');

% disp([seleted_panel,' selected'])


function mykeypress(hObject, eventdata, handles)


global Gv3Dimage_spec;
global seleted_panel;
global num_keypressed;

% ---------------------------------------------------
% to avoid algorithm halt due to lot of key pressing,
% below code prevent this.
% and before return this func, following line should be added.
% : num_keypressed=num_keypressed-1;
% ---------------------------------------------------
num_keypressed=num_keypressed+1;

if num_keypressed > 1 %------ not much difference above 1
    num_keypressed=num_keypressed-1;
    return;
end
% ---------------------------------------------------

% ---------------------------------------------------
% for detail,
% see help -> Uicontrol Properties -> KeyPressFcn
% ---------------------------------------------------

if strcmp(eventdata.Key,'rightarrow')
    
    switch seleted_panel
        case 'uipanel1'
            pushbutton_ax1next_Callback(handles.pushbutton_ax1next,...
                eventdata, handles)
        case 'uipanel2'
            if Gv3Dimage_spec.is3D
                pushbutton_ax2next_Callback(handles.pushbutton_ax2next,...
                    eventdata, handles)
            end
        case 'uipanel3'
            if Gv3Dimage_spec.is3D
                pushbutton_ax3next_Callback(handles.pushbutton_ax3next,...
                    eventdata, handles)
            end
    end
end

if strcmp(eventdata.Key,'leftarrow')
    
    switch seleted_panel
        case 'uipanel1'
            pushbutton_ax1prev_Callback(handles.pushbutton_ax1prev,...
                eventdata, handles)
        case 'uipanel2'
            if Gv3Dimage_spec.is3D
                pushbutton_ax2prev_Callback(handles.pushbutton_ax2prev,...
                    eventdata, handles)
            end
        case 'uipanel3'
            if Gv3Dimage_spec.is3D
                pushbutton_ax3prev_Callback(handles.pushbutton_ax3prev,...
                    eventdata, handles)
            end
    end
end

if strcmp(eventdata.Character,'+')
    menu_miniCmap_Brighten_Callback(hObject, eventdata, handles)
end

if strcmp(eventdata.Character,'-')
    menu_miniCmap_Darken_Callback(hObject, eventdata, handles)
end

% ------------ don't forget this line !! --------------------
num_keypressed=num_keypressed-1;



function write_logfile


global Gv3Dimage_spec;

fid = fopen(['./' 'Logfile.log'],'w');

%------- prevent error when closing after 'clear all'
try
    filepath = Gv3Dimage_spec.filepath;
catch
    filepath =[];
end

log_content = ['3D mri path = ',filepath,...
    char(13),char(10),...   % carrige return and newline
    ];

if fid~=-1
    fwrite(fid,char(log_content),'char');
    fclose(fid);
end


function read_logfile


global Gv3Dimage_spec;

fid = fopen(['./' 'Logfile.log'],'r');

if fid~=-1
    log_cont = fread(fid,'char');
    fclose(fid);

    % Input strings must have one row.
    log_cont = char(log_cont');
    
    try
        view3Dmri_filepath = findAsc(log_cont,'3D mri path',' = ');
    catch
        view3Dmri_filepath = Gv3Dimage_spec.filepath;
    end

    if isdir(view3Dmri_filepath)
        Gv3Dimage_spec.filepath = view3Dmri_filepath;
    end

end


% --------------------------------------------------------------------
function menu_simhelp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_simhelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


helpdlg({'Does not consider about Multi-coil Data',...
    'and only works on Philips CPX Data Sets',...
    'in current version.',...
    'Also works on 2D data.'},'Notice');


% --- Executes on button press in pushbutton_save2mat.
function pushbutton_save2mat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save2mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global Gv3Dimage_spec;
global Gv3Dslice_index;

data = Gv3Dimage_spec.image_data;

if Gv3Dimage_spec.is3D
    text_flag = '_3D';
else
    s = Gv3Dslice_index.xy;

    if s<10
        add0 = '00';
    elseif s<100
        add0 = '0';
    else
        add0 = '';
    end

    text_flag = ['_',add0,num2str(s),'th_slice'];
end

disp('Saving to .mat file...')

save([Gv3Dimage_spec.filepath,Gv3Dimage_spec.filename,...
    '_[',Gv3Dimage_spec.scanname,']',...
    text_flag,'_image','.mat'],'data'); % save structure field not support

disp('File saved!')


% --------------------------------------------------------------------
function change_info(handles)


global Gv3Dimage_spec;
global Gv3Dslice_index;

text_nx = 'X-resolution';
text_ny = 'Y-resolution';
text_nz = 'Z-resolution';
text_ns = 'total # of Slice';
sep_text = ' : ';

nx = Gv3Dimage_spec.nx;
ny = Gv3Dimage_spec.ny;
nz = Gv3Dimage_spec.nz;
ns = Gv3Dimage_spec.ns;

if Gv3Dimage_spec.is3D
    text_3D = '3D data';
    filename = Gv3Dimage_spec.filename;
    
else
    text_3D = '2D data';
    if Gv3Dimage_spec.ns>1
        try
            filename = Gv3Dimage_spec.filename{Gv3Dslice_index.xy};
            [ny,nx] = size(Gv3Dimage_spec.image_data{Gv3Dslice_index.xy});
        catch
            filename = Gv3Dimage_spec.filename;
            [ny,nx] = size(Gv3Dimage_spec.image_data);
        end
    else
        filename = Gv3Dimage_spec.filename;
    end
end

% do not make cell array of string !!
% which make code complicate
info_list = strvcat(filename,...
    [],...
    [text_nx,sep_text,num2str(nx)],...
    [text_ny,sep_text,num2str(ny)],...
    [text_nz,sep_text,num2str(nz)],...
    [text_ns,sep_text,num2str(ns)],...
    ['Data Type = ',text_3D]);

set(handles.listbox_info,'string',info_list);


% --- Executes on selection change in listbox_var.
function listbox_var_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_var contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_var


% --- Executes during object creation, after setting all properties.
function listbox_var_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_var.
function pushbutton_var_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


change_var(hObject, eventdata, handles)

function change_var(hObject, eventdata, handles)


global Gv3Dimage_spec;
global Gv3Dslice_index;

Gv3Dimage_spec.image_data = [];

index_selected = get(handles.listbox_var,'Value');
if length(index_selected) > 1
    errordlg('You must select one variables','Incorrect Selection','modal')
else
    selected_var = index_selected(1);
end 

var_name = sort(fieldnames(Gv3Dimage_spec.data));    % get variable name in struct to cell

im = eval(['Gv3Dimage_spec.data.',var_name{selected_var}]);   % save file data to 'im'
Gv3Dimage_spec.selected_var = var_name{selected_var};

[ny,nx,nz] = size(im);

Gv3Dimage_spec.nx = nx;
Gv3Dimage_spec.ny = ny;

if nz==1
    Gv3Dimage_spec.image_data{1} = im;
    Gv3Dimage_spec.is3D = 0;
    Gv3Dimage_spec.ns = 1;
    Gv3Dimage_spec.nz = nz;
else
    Gv3Dimage_spec.image_data = im;
    Gv3Dimage_spec.is3D = 1;
    Gv3Dimage_spec.nz = nz;
end

clear im;

clear_axes(handles)

plot_image(hObject, eventdata, handles)



function plot_image(hObject, eventdata, handles)


global Gv3Dimage_spec;
global Gv3Dslice_index;

if isempty(Gv3Dimage_spec.filename)
    return;
end

set(handles.pushbutton_flz,'enable','on');
set(handles.pushbutton_flx,'enable','on');
set(handles.pushbutton_fly,'enable','on');

if Gv3Dimage_spec.is3D
    set(handles.pushbutton_ax1prev,'enable','on');
    set(handles.pushbutton_ax1next,'enable','on');
    set(handles.pushbutton_ax2prev,'enable','on');
    set(handles.pushbutton_ax2next,'enable','on');
    set(handles.pushbutton_ax3prev,'enable','on');
    set(handles.pushbutton_ax3next,'enable','on');
    
    set(handles.checkbox_mip_xy,'enable','on');
    set(handles.checkbox_mip_yz,'enable','on');
    set(handles.checkbox_mip_xz,'enable','on');
    
    set(handles.pushbutton_chxy,'enable','on');
    set(handles.pushbutton_chyz,'enable','on');
    set(handles.pushbutton_chzx,'enable','on');
    
    set(handles.text_xyindex,'enable','on');
    set(handles.text_yzindex,'enable','on');
    set(handles.text_xzindex,'enable','on');
    
    set(handles.checkbox_max2axes,'enable','on');
    
    Gv3Dslice_index.xy = round(Gv3Dimage_spec.nz/2);
    Gv3Dslice_index.yz = round(Gv3Dimage_spec.nx/2);
    Gv3Dslice_index.xz = round(Gv3Dimage_spec.ny/2);
        
else
    set(handles.pushbutton_chxy,'enable','on');
    
    set(handles.pushbutton_flz,'enable','off');
    
    if Gv3Dimage_spec.ns>1
        set(handles.pushbutton_ax1prev,'enable','on');
        set(handles.pushbutton_ax1next,'enable','on');
        
        set(handles.text_xyindex,'enable','on');
    end

end

Gv3Dimage_spec.type = 'mat';

set(handles.checkbox_viewphase,'enable','on')


set(handles.slider_max,'enable','on')

set(handles.menu_save,'enable','on');
% set(handles.uipushtool_save,'enable','on');
set(findobj(handles.figure1,'tag','uipushtool_save'),'enable','on');

set(handles.pushbutton_resetindex,'enable','on');
set(handles.figure1,'KeyPressFcn',{@mykeypress,handles})

write_logfile;

change_info(handles)
plot_xyzview(handles)


function clear_axes(handles)
% copy from initializing function
%

global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global max_Intensity;
global Gv3Dcur_max_Intensity;
global Gv3Disphase;
global ismax2axes;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global apply_Gv3DcurCmap2enlarged;
% global Gv3Dres;

Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);

% Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

% set(handles.edit_y_res,'string','1.0');
% set(handles.edit_x_res,'string','1.0');
% set(handles.edit_z_res,'string','1.0');

Gv3Dslice_index = struct('xy',1,'yz',1,'xz',1);
Gv3Daxes_data = struct('xy',[],'yz',[],'xz',[]);
Gv3Daxes_normal = struct('xy',0,'yz',0,'xz',0);
Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

max_Intensity = [];
Gv3Dcur_max_Intensity = [];

Gv3DcurCmap = [];
Gv3Dapply_curCmap2all = 1;
set(handles.menu_miniCmap_apply2all,'Checked','on');
apply_Gv3DcurCmap2enlarged = 1;
set(handles.menu_miniCmap_apply2enlarged,'Checked','on');

Gv3Disphase = 0;
ismax2axes = 0;

set(handles.checkbox_max2axes,'enable','off');
set(handles.checkbox_max2axes,'Value',0)

set(handles.checkbox_viewphase,'enable','off');
set(handles.checkbox_viewphase,'Value',0)

set(handles.pushbutton_resetMax,'enable','off');
set(handles.slider_max,'enable','off')
set(handles.slider_max,'Value',1)

set(handles.checkbox_axis1,'Value',0)
set(handles.checkbox_axis2,'Value',0)
set(handles.checkbox_axis3,'Value',0)

set(handles.checkbox_axis1,'enable','off')
set(handles.checkbox_axis2,'enable','off')
set(handles.checkbox_axis3,'enable','off')

set(handles.checkbox_mip_xy,'enable','off');
set(handles.checkbox_mip_yz,'enable','off');
set(handles.checkbox_mip_xz,'enable','off');

set(handles.checkbox_mip_xy,'Value',0);
set(handles.checkbox_mip_yz,'Value',0);
set(handles.checkbox_mip_xz,'Value',0);

set(handles.pushbutton_enla1,'enable','off');
set(handles.pushbutton_enla2,'enable','off');
set(handles.pushbutton_enla3,'enable','off');

set(handles.pushbutton_ax1prev,'enable','off');
set(handles.pushbutton_ax1next,'enable','off');
set(handles.pushbutton_ax2prev,'enable','off');
set(handles.pushbutton_ax2next,'enable','off');
set(handles.pushbutton_ax3prev,'enable','off');
set(handles.pushbutton_ax3next,'enable','off');
set(handles.pushbutton_resetindex,'enable','off');

set(handles.pushbutton_chxy,'enable','off');
set(handles.pushbutton_chyz,'enable','off');
set(handles.pushbutton_chzx,'enable','off');

set(handles.pushbutton_flz,'enable','off');
set(handles.pushbutton_flx,'enable','off');
set(handles.pushbutton_fly,'enable','off');

set(handles.text_xyindex,'enable','off');
set(handles.text_yzindex,'enable','off');
set(handles.text_xzindex,'enable','off');

set(handles.menu_save,'enable','off');
set(findobj(handles.figure1,'tag','uipushtool_save'),'enable','off');

set(handles.text_xyindex,'string',[]);
set(handles.text_yzindex,'string',[]);
set(handles.text_xzindex,'string',[]);

% set(handles.axes1,'position',[0.025,0.15,0.95,0.83])
% set(handles.axes2,'position',[0.025,0.15,0.95,0.83])
% set(handles.axes3,'position',[0.025,0.15,0.95,0.83])

set(handles.listbox_textbox,'Value',1);
set(handles.listbox_textbox,'Visible','off');
set(handles.text_toplistbox,'Visible','off');

%-- below 2 lines excute all of codes below return;
set(findobj(handles.figure1,'type','axes'),...
    'Visible','on','XTick',[],'YTick',[],...
    'xlim',[0 1],'ylim',[0 1])
delete(cell2mat(get(findobj(handles.figure1,'type','axes'),'children')))

return;

set(handles.axes1,'Visible','on','XTick',[],'YTick',[]);
set(handles.axes2,'Visible','on','XTick',[],'YTick',[]);
set(handles.axes3,'Visible','on','XTick',[],'YTick',[]);

delete(get(handles.axes1,'children'))
delete(get(handles.axes2,'children'))
delete(get(handles.axes3,'children'))
delete(get(handles.axes4,'children'))
delete(get(handles.axes5,'children'))
delete(get(handles.axes6,'children'))


% --- Executes on button press in pushbutton_enla1.
function pushbutton_enla1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enla1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3DenLarged_imH;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global Gv3Dcur_max_Intensity;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global apply_Gv3DcurCmap2enlarged;
global Gv3Dres;

check_enLarged_index

[r,c] = size(Gv3Daxes_data.xy);

if r>1 && c>1
    if isempty(Gv3Dcur_max_Intensity)
        mrimage(Gv3Daxes_data.xy,[],Gv3DenLarged_imH.init_fig_index+1);
    else
%         mrimage(Gv3Daxes_data.xy,[min(mag(Gv3Daxes_data.xy(:))),...
%             min(max(mag(Gv3Daxes_data.xy(:))),Gv3Dcur_max_Intensity)],...
%             Gv3DenLarged_imH.init_fig_index+1);
        
        if isreal(Gv3Daxes_data.xy(:))
            min_intensity = min(Gv3Daxes_data.xy(:));
        else
            min_intensity = min(mag(Gv3Daxes_data.xy(:)));
        end
        mrimage(Gv3Daxes_data.xy,[min_intensity,...
            Gv3Dcur_max_Intensity],...
            Gv3DenLarged_imH.init_fig_index+1);
    end

    daspect([Gv3Dres.y Gv3Dres.x 1])
    
    if Gv3Daxes_normal.xy
        axis normal;
    end
    
    if apply_Gv3DcurCmap2enlarged % always follow current colormap if this bit is set
        localCmap = get(handles.figure1,'Colormap'); % fig is figure handle or use gcf
        colormap(localCmap)
    elseif Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap) % or follow global colormap
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(Gv3DcurCmap)
    end
    
    if Gv3Dchk_mip.xy
        title({['filename : ',Gv3Dimage_spec.filename,' '],...
            ['varable : ',Gv3Dimage_spec.selected_var,', ',...
            'x-y MIP image']},'Interpreter','none');
    else
        if iscell(Gv3Dimage_spec.filename)
            title({['filename : ',Gv3Dimage_spec.filename{Gv3Dslice_index.xy},' '],...
%                 ['varable : ',Gv3Dimage_spec.selected_var,' '],...
                [num2str(Gv3Dslice_index.xy),' th x-y slice']},'Interpreter','none');
        else
            title({['filename : ',Gv3Dimage_spec.filename,' '],...
                ['varable : ',Gv3Dimage_spec.selected_var,', ',...
                num2str(Gv3Dslice_index.xy),' th x-y slice']},'Interpreter','none');
        end
    end
else
    figure(Gv3DenLarged_imH.init_fig_index+1);
    plot(Gv3Daxes_data.xy,'b.-'); % why this become gray when didn't specify the color?
    grid on;
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var]},'Interpreter','none');
end

%-------------------- set figure size -- modified at 2009.10.31 ------------
screen_size = get(0,'ScreenSize');
set(gcf,'position',[screen_size(3)*0.2 screen_size(4)*0.2 screen_size(3)*0.6 screen_size(4)*0.6])
% -------------------------------------------------------------------------

Gv3DenLarged_imH.opened_fig_indic = ...
    [Gv3DenLarged_imH.opened_fig_indic;Gv3DenLarged_imH.init_fig_index+1];

set(handles.pushbutton_close_enla,'enable','on');

% --- Executes on button press in pushbutton_enla2.
function pushbutton_enla2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enla2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3DenLarged_imH;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global Gv3Dcur_max_Intensity;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global apply_Gv3DcurCmap2enlarged;
global Gv3Dres;

check_enLarged_index

if isempty(Gv3Dcur_max_Intensity)
    mrimage(Gv3Daxes_data.yz,[],Gv3DenLarged_imH.init_fig_index+1);
else
%     mrimage(Gv3Daxes_data.yz,[min(mag(Gv3Daxes_data.yz(:))),...
%         min(max(mag(Gv3Daxes_data.yz(:))),Gv3Dcur_max_Intensity)],...
%         Gv3DenLarged_imH.init_fig_index+1);
    if isreal(Gv3Daxes_data.yz(:))
        min_intensity = min(Gv3Daxes_data.yz(:));
    else
        min_intensity = min(mag(Gv3Daxes_data.yz(:)));
    end
    mrimage(Gv3Daxes_data.yz,[min_intensity,...
        Gv3Dcur_max_Intensity],...
        Gv3DenLarged_imH.init_fig_index+1);
end

daspect([Gv3Dres.y Gv3Dres.z 1])

if Gv3Daxes_normal.yz
    axis normal;
end

if apply_Gv3DcurCmap2enlarged % always follow current colormap if this bit is set
    localCmap = get(handles.figure1,'Colormap'); % fig is figure handle or use gcf
    colormap(localCmap)
elseif Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap) % or follow global colormap
    % set(new_fig,'Colormap',mycmap) % -- example
    colormap(Gv3DcurCmap)
end


if Gv3Dchk_mip.yz
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        'y-z MIP image']},'Interpreter','none');
else
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        num2str(Gv3Dslice_index.yz),' th y-z slice']},'Interpreter','none');
end

%-------------------- set figure size -- modified at 2009.10.31 ------------
screen_size = get(0,'ScreenSize');
set(gcf,'position',[screen_size(3)*0.2 screen_size(4)*0.2 screen_size(3)*0.6 screen_size(4)*0.6])
% -------------------------------------------------------------------------


Gv3DenLarged_imH.opened_fig_indic = ...
    [Gv3DenLarged_imH.opened_fig_indic;Gv3DenLarged_imH.init_fig_index+1];

set(handles.pushbutton_close_enla,'enable','on');


% --- Executes on button press in pushbutton_enla3.
function pushbutton_enla3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enla3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3DenLarged_imH;
global Gv3Daxes_data;
global Gv3Daxes_normal;
global Gv3Dchk_mip;
global Gv3Dcur_max_Intensity;
global Gv3DcurCmap;
global Gv3Dapply_curCmap2all;
global apply_Gv3DcurCmap2enlarged;
global Gv3Dres;

check_enLarged_index

if isempty(Gv3Dcur_max_Intensity)
    mrimage(Gv3Daxes_data.xz,[],Gv3DenLarged_imH.init_fig_index+1);
else
%     mrimage(Gv3Daxes_data.xz,[min(mag(Gv3Daxes_data.xz(:))),...
%         min(max(mag(Gv3Daxes_data.xz(:))),Gv3Dcur_max_Intensity)],...
%         Gv3DenLarged_imH.init_fig_index+1);
    if isreal(Gv3Daxes_data.xz(:))
        min_intensity = min(Gv3Daxes_data.xz(:));
    else
        min_intensity = min(mag(Gv3Daxes_data.xz(:)));
    end
    mrimage(Gv3Daxes_data.xz,[min_intensity,...
        Gv3Dcur_max_Intensity],...
        Gv3DenLarged_imH.init_fig_index+1);
end

daspect([Gv3Dres.z Gv3Dres.x 1])

if Gv3Daxes_normal.xz
    axis normal;
end

if apply_Gv3DcurCmap2enlarged % always follow current colormap if this bit is set
    localCmap = get(handles.figure1,'Colormap'); % fig is figure handle or use gcf
    colormap(localCmap)
elseif Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap) % or follow global colormap
    % set(new_fig,'Colormap',mycmap) % -- example
    colormap(Gv3DcurCmap)
end

if Gv3Dchk_mip.xz
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        'x-z MIP image']},'Interpreter','none');
else
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        num2str(Gv3Dslice_index.xz),' th x-z slice']},'Interpreter','none');
end

%-------------------- set figure size -- modified at 2009.10.31 ------------
screen_size = get(0,'ScreenSize');
set(gcf,'position',[screen_size(3)*0.2 screen_size(4)*0.2 screen_size(3)*0.6 screen_size(4)*0.6])
% -------------------------------------------------------------------------


Gv3DenLarged_imH.opened_fig_indic = ...
    [Gv3DenLarged_imH.opened_fig_indic;Gv3DenLarged_imH.init_fig_index+1];

set(handles.pushbutton_close_enla,'enable','on');

% --- Executes on button press in pushbutton_close_enla.
function pushbutton_close_enla_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close_enla (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Gv3DenLarged_imH;

for n=1:length(Gv3DenLarged_imH.opened_fig_indic)
    if ishandle(Gv3DenLarged_imH.opened_fig_indic(n))
        close(Gv3DenLarged_imH.opened_fig_indic(n));
    end
end

Gv3DenLarged_imH.init_fig_index = Gv3DenLarged_imH.opened_fig_indic(1)-1;
Gv3DenLarged_imH.opened_fig_indic = [];

set(handles.pushbutton_close_enla,'enable','off');

function check_enLarged_index

global Gv3DenLarged_imH;

% ------------ check valid fiugre handle
temp = zeros(length(Gv3DenLarged_imH.opened_fig_indic),1);

for n=1:length(Gv3DenLarged_imH.opened_fig_indic)
    if ishandle(Gv3DenLarged_imH.opened_fig_indic(n))
        temp(n) = Gv3DenLarged_imH.opened_fig_indic(n);
    end
end
Gv3DenLarged_imH.opened_fig_indic = temp(temp>0);
%---------------------------------------

if ~isempty(Gv3DenLarged_imH.opened_fig_indic)
    Gv3DenLarged_imH.init_fig_index = ...
        Gv3DenLarged_imH.opened_fig_indic(length(Gv3DenLarged_imH.opened_fig_indic));
end


% --- Executes on button press in checkbox_axis1.
function checkbox_axis1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axis1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_axis1
global Gv3Daxes_normal;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Daxes_normal.xy = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Daxes_normal.xy = 0;
end

plot_xyview(handles)

% --- Executes on button press in checkbox_axis2.
function checkbox_axis2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axis2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_axis2
global Gv3Daxes_normal;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Daxes_normal.yz = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Daxes_normal.yz = 0;
end

plot_yzview(handles)

% --- Executes on button press in checkbox_axis3.
function checkbox_axis3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axis3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_axis3
global Gv3Daxes_normal;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Daxes_normal.xz = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Daxes_normal.xz = 0;
end

plot_xzview(handles)


% --- Executes on button press in checkbox_mip_yz.
function checkbox_mip_yz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mip_yz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mip_yz
global Gv3Dimage_spec;
global Gv3Dchk_mip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_mip.yz = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_mip.yz = 0;
end

if isempty(Gv3Dimage_spec.mip.yz)
    disp('processing MIP...')
    Gv3Dimage_spec.mip.yz = MIP(Gv3Dimage_spec.image_data,2);
    disp('Done!!')
end

plot_yzview(handles)


% --- Executes on button press in checkbox_mip_xy.
function checkbox_mip_xy_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mip_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mip_xy
global Gv3Dimage_spec;
global Gv3Dchk_mip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_mip.xy = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_mip.xy = 0;
end

if isempty(Gv3Dimage_spec.mip.xy)
    disp('processing MIP...')
    Gv3Dimage_spec.mip.xy = MIP(Gv3Dimage_spec.image_data,3);
    disp('Done!!')
end

plot_xyview(handles)

% --- Executes on button press in checkbox_mip_xz.
function checkbox_mip_xz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mip_xz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mip_xz
global Gv3Dimage_spec;
global Gv3Dchk_mip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_mip.xz = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_mip.xz = 0;
end

if isempty(Gv3Dimage_spec.mip.xz)
    disp('processing MIP...')
    Gv3Dimage_spec.mip.xz = MIP(Gv3Dimage_spec.image_data,1);
    disp('Done!!')
end

plot_xzview(handles)


% --- Executes on selection change in listbox_textbox.
function listbox_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_textbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_textbox


% --- Executes during object creation, after setting all properties.
function listbox_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_test_Callback(hObject, eventdata, handles)
% hObject    handle to menu_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_chxy.
function pushbutton_chxy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Dchk_mip;

try
    if Gv3Dimage_spec.is3D
        Gv3Dimage_spec.image_data = permute(Gv3Dimage_spec.image_data,[2 1 3]);
        Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);
        
        Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

        set(handles.checkbox_mip_xy,'Value',0);
        set(handles.checkbox_mip_yz,'Value',0);
        set(handles.checkbox_mip_xz,'Value',0);

        [ny,nx,nz] = size(Gv3Dimage_spec.image_data);

        Gv3Dimage_spec.nx = nx;
        Gv3Dimage_spec.ny = ny;
        Gv3Dimage_spec.nz = nz;
        
        Gv3Dslice_index.xy = min(nz,Gv3Dslice_index.xy);
        Gv3Dslice_index.yz = min(nx,Gv3Dslice_index.yz);
        Gv3Dslice_index.xz = min(ny,Gv3Dslice_index.xz);

    else
        for n=1:Gv3Dimage_spec.ns
            Gv3Dimage_spec.image_data{n} = permute(Gv3Dimage_spec.image_data{n},[2 1 3]);
            
            [ny,nx] = size(Gv3Dimage_spec.image_data{n});

            Gv3Dimage_spec.nx = nx;
            Gv3Dimage_spec.ny = ny;            
        end
    end
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     if ~isempty(strfind(ME.message,'HELP MEMORY'))
%         disp(' ')
%         disp('Not enough memory. Cannot rotate image.')
%         disp('Try to use stand-alone application.')
%     end
end

plot_image(hObject, eventdata, handles)

% --- Executes on button press in pushbutton_chyz.
function pushbutton_chyz_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chyz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Dchk_mip;

try
    Gv3Dimage_spec.image_data = permute(Gv3Dimage_spec.image_data,[3 2 1]);
    Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);   
    
    Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

    set(handles.checkbox_mip_xy,'Value',0);
    set(handles.checkbox_mip_yz,'Value',0);
    set(handles.checkbox_mip_xz,'Value',0);

    [ny,nx,nz] = size(Gv3Dimage_spec.image_data);

    Gv3Dimage_spec.nx = nx;
    Gv3Dimage_spec.ny = ny;
    Gv3Dimage_spec.nz = nz;

    Gv3Dslice_index.xy = min(nz,Gv3Dslice_index.xy);
    Gv3Dslice_index.yz = min(nx,Gv3Dslice_index.yz);
    Gv3Dslice_index.xz = min(ny,Gv3Dslice_index.xz);

catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     if ~isempty(strfind(ME.message,'HELP MEMORY'))
%         disp(' ')
%         disp('Not enough memory. Cannot rotate image.')
%         disp('Try to use stand-alone application.')
%     end
end

plot_image(hObject, eventdata, handles)

% --- Executes on button press in pushbutton_chzx.
function pushbutton_chzx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chzx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;
global Gv3Dslice_index;
global Gv3Dchk_mip;

try
    Gv3Dimage_spec.image_data = permute(Gv3Dimage_spec.image_data,[1 3 2]);
    Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);
    
    Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

    set(handles.checkbox_mip_xy,'Value',0);
    set(handles.checkbox_mip_yz,'Value',0);
    set(handles.checkbox_mip_xz,'Value',0);
    
    [ny,nx,nz] = size(Gv3Dimage_spec.image_data);

    Gv3Dimage_spec.nx = nx;
    Gv3Dimage_spec.ny = ny;
    Gv3Dimage_spec.nz = nz;
    
    Gv3Dslice_index.xy = min(nz,Gv3Dslice_index.xy);
    Gv3Dslice_index.yz = min(nx,Gv3Dslice_index.yz);
    Gv3Dslice_index.xz = min(ny,Gv3Dslice_index.xz);
    
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     if ~isempty(strfind(ME.message,'HELP MEMORY'))
%         disp(' ')
%         disp('Not enough memory. Cannot rotate image.')
%         disp('Try to use stand-alone application.')
%     end
end

plot_image(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_flz.
function pushbutton_flz_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;
global Gv3Dchk_mip;
global Gv3Dslice_index;

try
    Gv3Dimage_spec.image_data = flipdim(Gv3Dimage_spec.image_data,3);
    Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);
    
    Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

    set(handles.checkbox_mip_xy,'Value',0);
    set(handles.checkbox_mip_yz,'Value',0);
    set(handles.checkbox_mip_xz,'Value',0);
    
    Gv3Dslice_index.xy = Gv3Dimage_spec.nz - Gv3Dslice_index.xy +1;
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     if ~isempty(strfind(ME.message,'HELP MEMORY'))
%         disp(' ')
%         disp('Not enough memory. Cannot rotate image.')
%         disp('Try to use stand-alone application.')
%     end
end

plot_image(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_flx.
function pushbutton_flx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;
global Gv3Dchk_mip;
global Gv3Dslice_index;

try
    if Gv3Dimage_spec.is3D
        Gv3Dimage_spec.image_data = flipdim(Gv3Dimage_spec.image_data,2);
        Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);
        
        Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

        set(handles.checkbox_mip_xy,'Value',0);
        set(handles.checkbox_mip_yz,'Value',0);
        set(handles.checkbox_mip_xz,'Value',0);
        
        Gv3Dslice_index.yz = Gv3Dimage_spec.nx - Gv3Dslice_index.yz +1;
    else
        for n=1:Gv3Dimage_spec.ns
            Gv3Dimage_spec.image_data{n} = flipdim(Gv3Dimage_spec.image_data{n},2);
        end
    end
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     if ~isempty(strfind(ME.message,'HELP MEMORY'))
%         disp(' ')
%         disp('Not enough memory. Cannot rotate image.')
%         disp('Try to use stand-alone application.')
%     end
end

plot_image(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_fly.
function pushbutton_fly_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;
global Gv3Dchk_mip;
global Gv3Dslice_index;

try
    if Gv3Dimage_spec.is3D
        Gv3Dimage_spec.image_data = flipdim(Gv3Dimage_spec.image_data,1);
        Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);
        
        Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);

        set(handles.checkbox_mip_xy,'Value',0);
        set(handles.checkbox_mip_yz,'Value',0);
        set(handles.checkbox_mip_xz,'Value',0);
        
        Gv3Dslice_index.xz = Gv3Dimage_spec.ny - Gv3Dslice_index.xz +1;
    else
        for n=1:Gv3Dimage_spec.ns
            Gv3Dimage_spec.image_data{n} = flipdim(Gv3Dimage_spec.image_data{n},1);
        end
    end
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     if ~isempty(strfind(ME.message,'HELP MEMORY'))
%         disp(' ')
%         disp('Not enough memory. Cannot rotate image.')
%         disp('Try to use stand-alone application.')
%     end
end

plot_image(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_copyfig_Callback(hObject, eventdata, handles)
% hObject    handle to menu_copyfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
%     print(gcf, '-dmeta');
    print(gcf, '-dbitmap');
catch
%     print(gcf, '-dbitmap');
end

% --------------------------------------------------------------------
function menu_copyfig_meta_Callback(hObject, eventdata, handles)
% hObject    handle to menu_copyfig_meta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    print(gcf, '-dmeta');
%     print(gcf, '-dbitmap');
catch
    print(gcf, '-dbitmap');
end

% --------------------------------------------------------------------
function menu_impvar_Callback(hObject, eventdata, handles)
% hObject    handle to menu_impvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;

% import variable names of base workspace
vars = evalin('base', 'who');

if ~isempty(vars)
    pathname = Gv3Dimage_spec.filepath;     % save path before initializing
    
    initializing(handles)

    set(handles.listbox_var,'string',vars);
    if length(vars)>1
        set(handles.pushbutton_var,'enable','on');
    end

    value = cell(length(vars),1);

    % save value of variables
    for n=1:length(vars)
        value{n} = evalin('base',vars{n});
    end

    % make it to struct
    Gv3Dimage_spec.data = cell2struct(value,vars,1);

    Gv3Dimage_spec.filename = 'Base Workspace';
    Gv3Dimage_spec.filepath = pathname;
%     Gv3Dimage_spec.type = 'baseWS';
    
    change_var(hObject, eventdata, handles)
end


% --- Executes on slider movement.
function slider_max_Callback(hObject, eventdata, handles)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global Gv3Dimage_spec;
global max_Intensity;
global Gv3Dcur_max_Intensity;

max_Intensity_percent = get(hObject,'Value');

if Gv3Dimage_spec.is3D

    if ~(iscell(Gv3Dimage_spec.image_data) ||...
            ischar(Gv3Dimage_spec.image_data) ||...
            iscellstr(Gv3Dimage_spec.image_data))
        if isempty(max_Intensity)
            disp('Finding maximum intensity...')
            drawnow
            max_Intensity = max(mag(Gv3Dimage_spec.image_data(:)));
            
            %------- not good
%             disp('Finding mean and standard deviation of intensity...')
%             max_Intensity = mean(mag(Gv3Dimage_spec.image_data(:)))...
%                 +2*std(mag(Gv3Dimage_spec.image_data(:)))
            %------------------
            disp('Done.')
        end
    end
else
    if ~(iscell(Gv3Dimage_spec.image_data{1}) ||...
            ischar(Gv3Dimage_spec.image_data{1}) ||...
            iscellstr(Gv3Dimage_spec.image_data{1}))
        [r,c] = size(Gv3Dimage_spec.image_data{1});
        if r>1 && c>1 && isempty(max_Intensity)
            max_Intensity = zeros(Gv3Dimage_spec.ns,1);

            disp('Finding maximum intensity...')
            drawnow
            for n=1:Gv3Dimage_spec.ns
                max_Intensity(n) = max(mag(Gv3Dimage_spec.image_data{n}(:)));
            end            
            max_Intensity = max(max_Intensity(n));
            disp('Done.')
        end
    end
end

% ---------------------------------------------------
% to avoid algorithm halt due to lot of slide move,
% set below property of slider
% 
% BusyAction      'cancel'
% Interruptible     'off'
% ---------------------------------------------------

if ~isempty(max_Intensity)
    Gv3Dcur_max_Intensity = max_Intensity*max_Intensity_percent;
    set(handles.pushbutton_resetMax,'enable','on');
    plot_xyzview(handles)
else
    set(handles.slider_max,'Value',1)
end

% --- Executes during object creation, after setting all properties.
function slider_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_resetMax.
function pushbutton_resetMax_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_resetMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Gv3Dcur_max_Intensity;

Gv3Dcur_max_Intensity = [];

set(handles.slider_max,'Value',1)
set(handles.pushbutton_resetMax,'enable','off');
plot_image(hObject, eventdata, handles)


% --- Executes on button press in checkbox_viewphase.
function checkbox_viewphase_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_viewphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_viewphase
global Gv3Disphase;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Disphase = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Disphase = 0;
end

plot_xyzview(handles)


% --- Executes on button press in checkbox_max2axes.
function checkbox_max2axes_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_max2axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_max2axes
global ismax2axes;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    ismax2axes = 1;
else
	% Checkbox is not checked-take approriate action
    ismax2axes = 0;
end

% wip....
% plot_xyzview(handles)



function set_imageSizeEqual(handles)

global ismax2axes;
global Gv3Dimage_spec;


if ismax2axes && Gv3Dimage_spec.is3D
    get(handles.axes1,'DataAspectRatio')
    get(handles.axes2,'DataAspectRatio')
    get(handles.axes3,'DataAspectRatio')

    xy_pos = get(handles.axes1,'Position');
    yz_pos = get(handles.axes2,'Position');
    xz_pos = get(handles.axes3,'Position');
    
    xy_Opos = get(handles.axes1,'OuterPosition');
    yz_Opos = get(handles.axes2,'OuterPosition');
    xz_Opos = get(handles.axes3,'OuterPosition');
    
    xy_pos_width_height = xy_pos(3:4);
    yz_pos_width_height = yz_pos(3:4);
    xz_pos_width_height = xz_pos(3:4);
    
    xy_size_min = min(xy_pos_width_height);
    yz_size_min = min(yz_pos_width_height);
    xz_size_min = min(xz_pos_width_height);
    
    if xy_size_min < yz_size_min
        mid_minPlane = xy_size_min;
        if mid_minPlane < xz_size_min;
            min_minPlane = 'xy';
        else
            min_minPlane = 'xz';
        end
    else
        mid_minPlane = yz_size_min;
        if mid_minPlane < xz_size_min;
            min_minPlane = 'yz';
        else
            min_minPlane = 'xz';
        end
    end

%     set(handles.axes1,'PlotBoxAspectRatio',[1 1 1])
%     set(handles.axes2,'PlotBoxAspectRatio',[1 1 1])
%     set(handles.axes3,'PlotBoxAspectRatio',[1 1 1])
%     
% %     set(gca,'DataAspectRatio',[2 1 1])
% axis(handles.axes1,'equal')
% axis(handles.axes2,'equal')
% axis(handles.axes3,'equal')

    % -- wip...
    switch min_minPlane
        case 'xy'
            set(handles.axes2,'position',[yz_pos(1:2) xy_pos(3:4)]);
            set(handles.axes3,'position',[xz_pos(1:2) xy_pos(3:4)]);
        case 'yz'
            set(handles.axes1,'position',[xy_pos(1:2) yz_pos(3:4)]);
            set(handles.axes3,'position',[xz_pos(1:2) yz_pos(3:4)]);
        case 'xz'
            set(handles.axes1,'position',[xy_pos(1:2) xz_pos(3:4)]);
            set(handles.axes2,'position',[yz_pos(1:2) xz_pos(3:4)]);
    end

    
    
end


% --------------------------------------------------------------------
function menu_cmap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_cmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% just start colormap editor せせ
colormapeditor

% --------------------------------------------------------------------
function menu_miniCmap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_miniCmap_apply2all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_apply2all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dapply_curCmap2all;

if strcmp(get(hObject, 'Checked'),'on')
    set(hObject,'Checked','off');
    Gv3Dapply_curCmap2all = 0;
else 
    set(hObject,'Checked','on');
    Gv3Dapply_curCmap2all = 1;
    plot_xyzview(handles) % only set current colormap when checked
end


% --------------------------------------------------------------------
function menu_miniCmap_gray64_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_gray64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormap(gray(64))

% --------------------------------------------------------------------
function menu_miniCmap_color_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormap jet % default is jet(64)

% --------------------------------------------------------------------
function menu_miniCmap_gray256_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_gray256 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormap(gray(256))

% --------------------------------------------------------------------
function menu_miniCmap_remember_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_remember (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3DcurCmap;

Gv3DcurCmap = get(handles.figure1,'Colormap'); % fig is figure handle or use gcf


% --------------------------------------------------------------------
function menu_exWS_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3Dimage_spec;

if isempty(Gv3Dimage_spec.data)
    return;
end

disp('Exporting to Base Workspace...')

var_name = sort(fieldnames(Gv3Dimage_spec.data));    % get variable name in struct to cell

for n=1:length(var_name)
    eval(['assignin(''base'',var_name{n},Gv3Dimage_spec.data.',var_name{n},')']);
end

disp('Done..;')

% --------------------------------------------------------------------
function menu_miniCmap_Brighten_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_Brighten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

brighten(.1) % see help

% --------------------------------------------------------------------
function menu_miniCmap_Darken_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_Darken (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

brighten(-.1) % see help

% --------------------------------------------------------------------
function menu_miniCmap_inversion_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_inversion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormap(flipud(colormap)) % from clrmenu


% --------------------------------------------------------------------
function menu_miniCmap_apply2enlarged_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_apply2enlarged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global apply_Gv3DcurCmap2enlarged;

if strcmp(get(hObject, 'Checked'),'on')
    set(hObject,'Checked','off');
    apply_Gv3DcurCmap2enlarged = 0;
else 
    set(hObject,'Checked','on');
    apply_Gv3DcurCmap2enlarged = 1;
end


% --------------------------------------------------------------------
function menu_miniCmap_clear_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Gv3DcurCmap;

Gv3DcurCmap = [];

colormap(gray(64))


% --- Executes on button press in pushbutton_wholeView.
function pushbutton_wholeView_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_wholeView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1,'position',[0.001,0.042,0.499,0.484])
set(handles.uipanel2,'position',[0.501,0.042,0.499,0.484])
set(handles.uipanel3,'position',[0.001,0.516,0.499,0.484])
set(handles.uipanel4,'position',[0.501,0.516,0.499,0.484])

set(handles.uipanel1,'Visible','on')
set(handles.uipanel2,'Visible','on')
set(handles.uipanel3,'Visible','on')
set(handles.uipanel4,'Visible','on')

set(handles.uipanel1,'FontSize',8)
set(handles.uipanel2,'FontSize',8)
set(handles.uipanel3,'FontSize',8)

% --- Executes on button press in pushbutton_panel_zx.
function pushbutton_panel_zx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_panel_zx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1,'Visible','off')
set(handles.uipanel2,'Visible','off')
set(handles.uipanel3,'Visible','on')
set(handles.uipanel4,'Visible','off')

set(handles.uipanel3,'position',[0.001,0.042,0.998,0.96])
set(handles.uipanel3,'FontSize',12)


% --- Executes on button press in pushbutton_panel_yx.
function pushbutton_panel_yx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_panel_yx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1,'Visible','on')
set(handles.uipanel2,'Visible','off')
set(handles.uipanel3,'Visible','off')
set(handles.uipanel4,'Visible','off')

set(handles.uipanel1,'position',[0.001,0.042,0.998,0.96])
set(handles.uipanel1,'FontSize',12)

% --- Executes on button press in pushbutton_panel_yz.
function pushbutton_panel_yz_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_panel_yz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1,'Visible','off')
set(handles.uipanel2,'Visible','on')
set(handles.uipanel3,'Visible','off')
set(handles.uipanel4,'Visible','off')

set(handles.uipanel2,'position',[0.001,0.042,0.998,0.96])
set(handles.uipanel2,'FontSize',12)



%------ i want delete this not-using function ばば



function text_xzindex_Callback(hObject, eventdata, handles)
% hObject    handle to text_xzindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_xzindex as text
%        str2double(get(hObject,'String')) returns contents of text_xzindex as a double
global Gv3Dimage_spec;
global Gv3Dslice_index;

user_entry = str2double(get(hObject,'string'));

% if isnan(user_entry)
%  errordlg('You must enter a numeric value','Bad Input','modal')
%  return
% end

% Proceed with callback...
try
    if ~isnan(user_entry) && user_entry>0 && user_entry<=Gv3Dimage_spec.ny
        Gv3Dslice_index.xz = user_entry;
        plot_xzview(handles)
    else
        set(handles.text_xzindex,'string',Gv3Dslice_index.xz);
    end
catch
end

function text_xyindex_Callback(hObject, eventdata, handles)
% hObject    handle to text_xyindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_xyindex as text
%        str2double(get(hObject,'String')) returns contents of text_xyindex as a double
global Gv3Dimage_spec;
global Gv3Dslice_index;

user_entry = str2double(get(hObject,'string'));

% if isnan(user_entry)
%  errordlg('You must enter a numeric value','Bad Input','modal')
%  return
% end

% Proceed with callback...
try
    if Gv3Dimage_spec.is3D
        xy_max = Gv3Dimage_spec.nz;
    else
        xy_max = Gv3Dimage_spec.ns;
    end
    
    if ~isnan(user_entry) && user_entry>0 && user_entry<=xy_max
        Gv3Dslice_index.xy = user_entry;
        plot_xyview(handles)
    else
        set(handles.text_xyindex,'string',Gv3Dslice_index.xy);
    end
catch
end


function text_yzindex_Callback(hObject, eventdata, handles)
% hObject    handle to text_yzindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_yzindex as text
%        str2double(get(hObject,'String')) returns contents of text_yzindex as a double
global Gv3Dimage_spec;
global Gv3Dslice_index;

user_entry = str2double(get(hObject,'string'));

% if isnan(user_entry)
%  errordlg('You must enter a numeric value','Bad Input','modal')
%  return
% end

% Proceed with callback...
try
    if ~isnan(user_entry) && user_entry>0 && user_entry<=Gv3Dimage_spec.nx
        Gv3Dslice_index.yz = user_entry;
        plot_yzview(handles)
    else
        set(handles.text_yzindex,'string',Gv3Dslice_index.yz);
    end
catch
end


% --- Executes during object creation, after setting all properties.
function text_xzindex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_xzindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_xyindex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_xyindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_yzindex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_yzindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_y_res_Callback(hObject, eventdata, handles)
% hObject    handle to edit_y_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_y_res as text
%        str2double(get(hObject,'String')) returns contents of edit_y_res as a double
global Gv3Dres;

user_entry = str2double(get(hObject,'string'));

% Proceed with callback...
try
    
    if ~isnan(user_entry) && user_entry>0
        Gv3Dres.y = user_entry;
        plot_xyzview(handles)
    else
        set(handles.edit_y_res,'string','1.0');
    end
catch
end


% --- Executes during object creation, after setting all properties.
function edit_y_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_y_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_x_res_Callback(hObject, eventdata, handles)
% hObject    handle to edit_x_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_x_res as text
%        str2double(get(hObject,'String')) returns contents of edit_x_res as a double
global Gv3Dres;

user_entry = str2double(get(hObject,'string'));

% Proceed with callback...
try
    
    if ~isnan(user_entry) && user_entry>0
        Gv3Dres.x = user_entry;
        plot_xyzview(handles)
    else
        set(handles.edit_x_res,'string','1.0');
    end
catch
end


% --- Executes during object creation, after setting all properties.
function edit_x_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_x_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_z_res_Callback(hObject, eventdata, handles)
% hObject    handle to edit_z_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_z_res as text
%        str2double(get(hObject,'String')) returns contents of edit_z_res as a double
global Gv3Dres;

user_entry = str2double(get(hObject,'string'));

% Proceed with callback...
try
    
    if ~isnan(user_entry) && user_entry>0
        Gv3Dres.z = user_entry;
        plot_xyzview(handles)
    else
        set(handles.edit_z_res,'string','1.0');
    end
catch
end


% --- Executes during object creation, after setting all properties.
function edit_z_res_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_z_res (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_axisOn_Callback(hObject, eventdata, handles)
% hObject    handle to menu_axisOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
axis on
axes(handles.axes2);
axis on
axes(handles.axes3);
axis on


% --------------------------------------------------------------------
function menu_axisOff_Callback(hObject, eventdata, handles)
% hObject    handle to menu_axisOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
axis off
axes(handles.axes2);
axis off
axes(handles.axes3);
axis off


