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

% Last Modified by GUIDE v2.5 23-Jul-2011 18:15:40

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

%  - 2011.03.30
munlock save_struct, clear save_struct

% -- select initial figure number at once
Gv3DenLarged_imH = struct('init_fig_index',randi([1000,20000]),'opened_fig_indic',[]);

%-------------------- set figure size --- modified at 2009.10.31 -----------------
% set(handles.figure1,'position',[0.15 0.1 0.7 0.8])
% - modified at 2011.03.30
set(handles.figure1,'position',[0.15 0.2 0.6 0.7])


%--------- turn off all matlab supported uitoggletool
% see putdowntext (e.g.,) putdowntext('pan',handles.uitoggletool_pan)
% --- this should exist on openeing, clear_axes,initializing
% --- added at 2010.04.23
zoom(handles.figure1,'off')
pan(handles.figure1,'off')
datacursormode(handles.figure1,'off')

set(handles.figure1,'WindowButtonMotionFcn',@mybuttonMotion)
set(handles.figure1,'WindowButtonDownFcn',{@mybuttondown,handles})
set(handles.figure1,'CloseRequestFcn',{@my_closefcn,handles})

set(handles.uipanel1,'position',[0.001,0.042,0.499,0.484])
set(handles.uipanel2,'position',[0.501,0.042,0.499,0.484])
set(handles.uipanel3,'position',[0.001,0.516,0.499,0.484])
set(handles.uipanel4,'position',[0.501,0.516,0.499,0.484])

% --- added at 2010.04.24
% Gv3DinitAxisPos = [0.05 0.15 0.90 0.83];
% - modified at 2011.03.30
Gv3DinitAxisPos = [0.05 0.15 0.8 0.8];
set(handles.axes1,'position',Gv3DinitAxisPos)
set(handles.axes2,'position',Gv3DinitAxisPos)
set(handles.axes3,'position',Gv3DinitAxisPos)

%------ to avoid Matlab GUIDE error according to its version
%------ make toolbar that has user defined callback func.
if isempty(findobj(handles.uitoolbar1,'tag','uipushtool_open'))
    clrmenu     % Add colormap menu to figure window - see help

    
%         'CData',iconRead(fullfile(matlabroot,'toolbox\matlab\icons\opendoc.mat')),...
    uipushtool_open = uipushtool(handles.uitoolbar1,...
        'CData',iconRead('file_open.png'),...
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


% save struct - 2011.03.30
save_struct('Gv3DenLarged_imH',Gv3DenLarged_imH)
save_struct('Gv3Dres',Gv3Dres)
save_struct('Gv3DinitAxisPos',Gv3DinitAxisPos)

initializing(hObject, eventdata, handles)

%  load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

Gv3Dimage_spec.filepath = read_logfile(Gv3Dimage_spec.filepath);
% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

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

% -- added at 2011.07.26
set(handles.menu_open_mat,'enable','off')
set(findobj(handles.uitoolbar1,'tag','uipushtool_open'),'enable','off')


%  load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

Gv3Dimage_spec.filepath = read_logfile(Gv3Dimage_spec.filepath);
% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

default_filepath = Gv3Dimage_spec.filepath;
if ~isempty(Gv3Dimage_spec.filename) && strcmp(Gv3Dimage_spec.type,'mat')
    if iscell(Gv3Dimage_spec.filename)
        default_filepath = [default_filepath,Gv3Dimage_spec.filename{1}(1:end-4)];
    else
        default_filepath = [default_filepath,Gv3Dimage_spec.filename(1:end-4)];
    end
end

[filename,filepath] = uigetfile({'*.mat','MAT-files (*.mat)'},...
    'Open Matlab file',default_filepath,...
    'MultiSelect', 'on');

if isequal(filename,0)
    disp('Files are not selected');
    
    % -- added at 2011.07.26
    set(handles.menu_open_mat,'enable','on')
    set(findobj(handles.uitoolbar1,'tag','uipushtool_open'),'enable','on')

    return;
end

%-- remove automatically added '.mat'
% -- added at 2010.04.19
if ~iscell(filename)
    index_jum_mat = strfind(filename,'.mat');
    if length(index_jum_mat)>1
        filename(index_jum_mat(2):end) = [];
    end
end


% save filepath neither didn't open file
Gv3Dimage_spec.filepath = filepath;
write_logfile(Gv3Dimage_spec);
% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

initializing(hObject, eventdata, handles)
%  load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

Gv3Dimage_spec.filepath = filepath;

Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

set(handles.edit_y_res,'string','1.0');
set(handles.edit_x_res,'string','1.0');
set(handles.edit_z_res,'string','1.0');


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

        clear data;
        % save struct - 2011.03.30
        save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
        save_struct('Gv3Dres',Gv3Dres)

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
    filename = sort(filename).';
    ns = length(filename);

    
    % ------------ add at 2011.04.07
    % --- load filename_table handle to close  - 2011.04.05
    hf_mytable = getappdata(handles.figure1,'hf_mytable');    
    if isempty(hf_mytable) || ~ishandle(hf_mytable)
        
        %  figure pos = [0.15 0.2 0.6 0.7]
        hf_mytable = figure('Units','normalized','Position',[0.76 0.5 0.2 0.4]);
        
        % --- save filename_table handle to close  - 2011.04.07
        setappdata(handles.figure1,'hf_mytable',hf_mytable)
    end
    uitable('parent',hf_mytable,'Units','normalized','Position',[0.05 0.05 0.9 0.9],...
        'Data', filename,...
        'ColumnName', {'Loaded File Name'},...
        'ColumnFormat', {'char'},...
        'ColumnWidth',{300},...
        'ColumnEditable', false);
    % focus figure
    figure(hf_mytable)
    % --------------------------
    
    
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
        try
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
                Gv3Dimage_spec.filename = ['Allslices_',Gv3Dimage_spec.filename{1}];
                
                Gv3Dimage_spec.selected_var = 'multiSlice';
                
                Gv3Dimage_spec.data = [];
                Gv3Dimage_spec.data.multiSlice = im;
                
                clear im
            end
        catch
            disp('FAILED: cannot reformat images')
        end
    end

    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dres',Gv3Dres)

    plot_image(hObject, eventdata, handles)

end

fclose('all');

% -- added at 2011.07.26
set(handles.menu_open_mat,'enable','on')
set(findobj(handles.uitoolbar1,'tag','uipushtool_open'),'enable','on')



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

% -- added at 2011.07.26
set(handles.menu_save,'enable','off')
set(findobj(handles.uitoolbar1,'tag','uipushtool_save'),'enable','off')

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec=mystruct.Gv3Dimage_spec;

Gv3Dimage_spec.filepath = read_logfile(Gv3Dimage_spec.filepath);

if iscell(Gv3Dimage_spec.filename) && Gv3Dimage_spec.is3D == 0
    
    user_ans = questdlg({'Save data to current files.';'Continue ?'},'modal');
    if ~strcmp(user_ans,'Yes')
        disp('Stopped.')
        
        % -- added at 2011.07.26
        set(handles.menu_save,'enable','on')
        set(findobj(handles.uitoolbar1,'tag','uipushtool_save'),'enable','on')

        return;
    end

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

    
    if isequal(filename,0)
        disp('Save canceled.')
        
        % -- added at 2011.07.26
        set(handles.menu_save,'enable','on')
        set(findobj(handles.uitoolbar1,'tag','uipushtool_save'),'enable','on')
        
        return;
    end
    
    Gv3Dimage_spec.filepath = pathname;
    
    
    save([pathname,filename],...
        '-struct','data'); % save structure field not support
    
    disp('File saved in path = ')
    disp([' ',pathname])
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

write_logfile(Gv3Dimage_spec);

% -- added at 2011.07.26
set(handles.menu_save,'enable','on')
set(findobj(handles.uitoolbar1,'tag','uipushtool_save'),'enable','on')



% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


msgbox({'MRI 3D Data Viewer ver.10.4',...
    'still WIP ;;;',...
    'GUI made by cefca (Sang-Young Zho).',...
    ' ',...
    ' - improved index line',...
    'Last Modified at 2010.04.25',...
    ' - fix various bugs',...
    'Last Modified at 2010.07.20',...
    'Last Modified at 2010.12.04',...
    ' - adjust enlarged figure size',...
    'Last Modified at 2011.02.10',...
    ' - remove global variables',...
    'Last Modified at 2011.03.30',...
    ' - show loaded file names',...
    'Last Modified at 2011.03.30',...
    ' - fast indexing (T_T)',...
    'Last Modified at 2011.07.23',...
    ' - reset 3D view after file loading or importing',...
    'Last Modified at 2011.07.25',...
    ' - disable button when open or save file',...
    'Last Modified at 2011.07.26',...
    ' ',...
    '@copyright Sang-Young Zho, Medical Imaging Lab, Yonsei University'},'About..','modal');


function my_closefcn(hObject, eventdata, handles)

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec=mystruct.Gv3Dimage_spec;

write_logfile(Gv3Dimage_spec);

% --- close filename_table - 2011.04.07
hf_mytable = getappdata(handles.figure1,'hf_mytable');
if ishandle(hf_mytable)
    close(hf_mytable)
end

fprintf('\n\nExit from : view3Dmri.\n\n')

fclose all;
munlock
%  - 2011.03.30
munlock save_struct, clear save_struct
closereq


% --- Executes on button press in pushbutton_ax1next.
function pushbutton_ax1next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax1next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec=mystruct.Gv3Dimage_spec;
Gv3Dslice_index=mystruct.Gv3Dslice_index;

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


% save struct - 2011.03.30
% save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

plot_xyview(handles)

% --- Executes on button press in pushbutton_ax1prev.
function pushbutton_ax1prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax1prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec=mystruct.Gv3Dimage_spec;
Gv3Dslice_index=mystruct.Gv3Dslice_index;


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

% save struct - 2011.03.30
% save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

plot_xyview(handles)

% --- Executes on button press in pushbutton_ax3next.
function pushbutton_ax3next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax3next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec=mystruct.Gv3Dimage_spec;
Gv3Dslice_index=mystruct.Gv3Dslice_index;


if Gv3Dslice_index.xz == Gv3Dimage_spec.ny
    Gv3Dslice_index.xz = 1;
else
    Gv3Dslice_index.xz = Gv3Dslice_index.xz+1;
end


% save struct - 2011.03.30
% save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

plot_xzview(handles)

% --- Executes on button press in pushbutton_ax3prev.
function pushbutton_ax3prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax3prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;


if Gv3Dslice_index.xz == 1
    Gv3Dslice_index.xz = Gv3Dimage_spec.ny;
else
    Gv3Dslice_index.xz = Gv3Dslice_index.xz-1;
end

% save struct - 2011.03.30
% save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

plot_xzview(handles)

% --- Executes on button press in pushbutton_ax2next.
function pushbutton_ax2next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax2next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;


if Gv3Dslice_index.yz == Gv3Dimage_spec.nx
    Gv3Dslice_index.yz=1;
else
    Gv3Dslice_index.yz = Gv3Dslice_index.yz+1;
end

% save struct - 2011.03.30
% save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

plot_yzview(handles)

% --- Executes on button press in pushbutton_ax2prev.
function pushbutton_ax2prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ax2prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;

if Gv3Dslice_index.yz == 1
    Gv3Dslice_index.yz = Gv3Dimage_spec.nx;
else
    Gv3Dslice_index.yz = Gv3Dslice_index.yz-1;
end

% save struct - 2011.03.30
% save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

plot_yzview(handles)


% --- Executes on button press in pushbutton_openPHcpx.
function pushbutton_openPHcpx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_openPHcpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% -- added at 2011.07.26
set(handles.menu_open_cpx,'enable','off')
set(handles.pushbutton_openPHcpx,'enable','off')


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;

%% read ascii file

Gv3Dimage_spec.filepath = read_logfile(Gv3Dimage_spec.filepath);
% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

default_filepath = Gv3Dimage_spec.filepath;
if ~isempty(Gv3Dimage_spec.filename) && strcmp(Gv3Dimage_spec.type,'cpx')
    default_filepath = [default_filepath,Gv3Dimage_spec.filename,'.list'];
end

[temp filepath] = uigetfile({'cpx*.list','List files (*.list)'},...
    'Open Philips cpx data',default_filepath);

if isequal(temp,0)
    disp('Files are not selected');
    
    % -- added at 2011.07.26
    set(handles.menu_open_cpx,'enable','on')
    set(handles.pushbutton_openPHcpx,'enable','on')

    return;
end

% save filepath neither didn't open file
Gv3Dimage_spec.filepath = filepath;
write_logfile(Gv3Dimage_spec);

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

initializing(hObject, eventdata, handles)
% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

set(handles.edit_y_res,'string','1.0');
set(handles.edit_x_res,'string','1.0');
set(handles.edit_z_res,'string','1.0');

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

write_logfile(Gv3Dimage_spec);

set(handles.checkbox_viewphase,'enable','on')
set(handles.checkbox_matchAllaxes,'enable','on');

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
    
    set(handles.checkbox_matchAllaxes,'enable','on');
    
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


% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)
save_struct('Gv3Dres',Gv3Dres)

% -- added at 2011.07.26
set(handles.menu_open_cpx,'enable','on')
set(handles.pushbutton_openPHcpx,'enable','on')


plot_xyzview(handles)

% --- Executes on button press in pushbutton_resetindex.
function pushbutton_resetindex_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_resetindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;


if Gv3Dimage_spec.is3D
    Gv3Dslice_index.xy = round(Gv3Dimage_spec.nz/2);
    Gv3Dslice_index.yz = round(Gv3Dimage_spec.nx/2);
    Gv3Dslice_index.xz = round(Gv3Dimage_spec.ny/2);
else
    Gv3Dslice_index = struct('xy',1,'yz',1,'xz',1);
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

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
%
% remove axes() using 'parent' property - 2011.07.23


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Daxes_data = mystruct.Gv3Daxes_data;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;
Gv3Disphase = mystruct.Gv3Disphase;
Gv3DcurCmap = mystruct.Gv3DcurCmap;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;
Gv3Dres = mystruct.Gv3Dres;
Gv3DaxesOn = mystruct.Gv3DaxesOn;

try
    % -- plot x-y view
    if Gv3Dimage_spec.is3D
        if Gv3Dchk_mip.xy
            temp = Gv3Dimage_spec.mip.xy;
        elseif Gv3Dchk_minip.xy
            temp = Gv3Dimage_spec.minip.xy;
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
        set(handles.listbox_textbox,'string',temp,'parent',handles.axes1);
        set(handles.listbox_textbox,'Visible','on','parent',handles.axes1);
        set(handles.text_toplistbox,'Visible','on','parent',handles.axes1);

    else
        if r>1 && c>1
            if Gv3Disphase
                temp = angle(temp);
            end            
            if Gv3Disphase || isempty(Gv3Dcur_Intensity.max)
                mrimagef(handles.axes1,temp,[],1);
            else
%                 if isreal(temp)
%                     min_clim = min(temp(:));
%                 else
%                     min_clim = min(mag(temp(:)));
%                 end

%                 mrimagef(temp,[min_clim,...
%                     min(max(mag(temp(:))),Gv3Dcur_max_Intensity)],1);
                mrimagef(handles.axes1,temp,[Gv3Dcur_Intensity.min,...
                    Gv3Dcur_Intensity.max],1);
            end
            daspect(handles.axes1,[Gv3Dres.y Gv3Dres.x 1])
            
            if Gv3DaxesOn
                axis(handles.axes1,'on');
            end
            
            if Gv3Daxes_normal.xy
                axis(handles.axes1,'normal');
            end
            set(handles.text_xyindex,'string',Gv3Dslice_index.xy);

        elseif r==1 && c==1
            temp_h = plot(handles.axes1,1);
            set(handles.axes1,'Visible','on','XTick',[],'YTick',[]);
            delete(temp_h);
            text(0.1,0.5,{'single data :',num2str(temp)},...
                'fontsize',18,'BackgroundColor','white',...
                'Interpreter','none','parent',handles.axes1);
        else
            plot(temp,'b.-'); % why this become gray when didn't specify the color?
            grid on;
            set(handles.axes1,'Visible','on');
            %     set(handles.axes1,'ActivePositionProperty','outerposition');
        end

        
        
        %-- mini plot x-y
        mrimagef(handles.axes4,temp,[],1);
        enableAxesmove(handles.axes4, handles)
        

        Gv3Daxes_data.xy = temp;
        set(handles.pushbutton_enla1,'enable','on');
    end
    
    if Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap)
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(handles.axes1,Gv3DcurCmap)
    else
        colormap(handles.axes1,'gray')
    end
    
    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dslice_index',Gv3Dslice_index)
    save_struct('Gv3Daxes_data',Gv3Daxes_data)
    save_struct('Gv3Daxes_normal',Gv3Daxes_normal)
    save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
    save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
    save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)
    save_struct('Gv3Disphase',Gv3Disphase)
    save_struct('Gv3DcurCmap',Gv3DcurCmap)
    save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)
    save_struct('Gv3Dres',Gv3Dres)
    save_struct('Gv3DaxesOn',Gv3DaxesOn)

    my_plot_index_Line(handles,handles.axes1)
    drawnow

catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
%     disp('Selected data can not plottable...')
end


function plot_yzview(handles)
%
% remove axes() using 'parent' property - 2011.07.23


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Daxes_data = mystruct.Gv3Daxes_data;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;
Gv3Disphase = mystruct.Gv3Disphase;
Gv3DcurCmap = mystruct.Gv3DcurCmap;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;
Gv3Dres = mystruct.Gv3Dres;
Gv3DaxesOn = mystruct.Gv3DaxesOn;

try
    if Gv3Dimage_spec.is3D
        % -- plot y-z view
        
        if Gv3Dchk_mip.yz
            temp = Gv3Dimage_spec.mip.yz;
        elseif Gv3Dchk_minip.yz
            temp = Gv3Dimage_spec.minip.yz;
        else
            temp = Gv3Dimage_spec.image_data(:,Gv3Dslice_index.yz,:);
            temp = permute(temp,[1 3 2]);
        end
        
        if Gv3Disphase
            temp = angle(temp);
        end
        if Gv3Disphase || isempty(Gv3Dcur_Intensity.max)
            mrimagef(handles.axes2,temp,[],1);
        else
%             if isreal(temp)
%                 min_clim = min(temp(:));
%             else
%                 min_clim = min(mag(temp(:)));
%             end
            
%             mrimagef(temp,[min_clim,...
%                 min(max(mag(temp(:))),Gv3Dcur_max_Intensity)],1);
            mrimagef(handles.axes2,temp,[Gv3Dcur_Intensity.min,...
                Gv3Dcur_Intensity.max],1);
        end

        daspect(handles.axes2,[Gv3Dres.y Gv3Dres.z 1])
        
        if Gv3DaxesOn
            axis(handles.axes2,'on');
        end
        
        if Gv3Daxes_normal.yz
            axis(handles.axes2,'normal');
        end
        set(handles.text_yzindex,'string',Gv3Dslice_index.yz);

        Gv3Daxes_data.yz = temp;
        set(handles.pushbutton_enla2,'enable','on');

        
        %-- mini plot y-z
        mrimagef(handles.axes5,temp,[],1);
        enableAxesmove(handles.axes5, handles)
        
    end
    
    if Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap)
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(handles.axes2,Gv3DcurCmap)
    else
        colormap(handles.axes2,'gray')
    end
    
    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dslice_index',Gv3Dslice_index)
    save_struct('Gv3Daxes_data',Gv3Daxes_data)
    save_struct('Gv3Daxes_normal',Gv3Daxes_normal)
    save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
    save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
    save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)
    save_struct('Gv3Disphase',Gv3Disphase)
    save_struct('Gv3DcurCmap',Gv3DcurCmap)
    save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)
    save_struct('Gv3Dres',Gv3Dres)
    save_struct('Gv3DaxesOn',Gv3DaxesOn)
    
    my_plot_index_Line(handles,handles.axes2)
    drawnow
    
catch %ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
%     disp('Selected data can not plottable...')
end


function plot_xzview(handles)
%
% remove axes() using 'parent' property - 2011.07.23


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Daxes_data = mystruct.Gv3Daxes_data;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;
Gv3Disphase = mystruct.Gv3Disphase;
Gv3DcurCmap = mystruct.Gv3DcurCmap;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;
Gv3Dres = mystruct.Gv3Dres;
Gv3DaxesOn = mystruct.Gv3DaxesOn;

try
    if Gv3Dimage_spec.is3D

        % -- plot x-z view

        if Gv3Dchk_mip.xz
            temp = Gv3Dimage_spec.mip.xz;
        elseif Gv3Dchk_minip.xz
            temp = Gv3Dimage_spec.minip.xz;
        else
            temp = Gv3Dimage_spec.image_data(Gv3Dslice_index.xz,:,:);
            temp = permute(temp,[3 2 1]);
        end
        
        % NOTE : left-top corner is always (1,1)
%         temp = flipud(temp);
        if Gv3Disphase
            temp = angle(temp);
        end
        if Gv3Disphase || isempty(Gv3Dcur_Intensity.max)
            mrimagef(handles.axes3,temp,[],1);
        else
%             if isreal(temp)
%                 min_clim = min(temp(:));
%             else
%                 min_clim = min(mag(temp(:)));
%             end
            
%             mrimagef(temp,[min_clim,...
%                 min(max(mag(temp(:))),Gv3Dcur_max_Intensity)],1);
            mrimagef(handles.axes3,temp,[Gv3Dcur_Intensity.min,...
                Gv3Dcur_Intensity.max],1);
        end
        
        daspect(handles.axes3,[Gv3Dres.z Gv3Dres.x 1])
        
        if Gv3DaxesOn
            axis(handles.axes3,'on');
        end
                
        if Gv3Daxes_normal.xz
            axis(handles.axes3,'normal');
        end
        set(handles.text_xzindex,'string',Gv3Dslice_index.xz);

        Gv3Daxes_data.xz = temp;
        set(handles.pushbutton_enla3,'enable','on');

        
        %-- mini plot x-z
        mrimagef(handles.axes6,temp,[],1);
        enableAxesmove(handles.axes6, handles)
        
    end
    
    if Gv3Dapply_curCmap2all && ~isempty(Gv3DcurCmap)
        % set(new_fig,'Colormap',mycmap) % -- example
        colormap(handles.axes2,Gv3DcurCmap)
    else
        colormap(handles.axes2,'gray')
    end
    
    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dslice_index',Gv3Dslice_index)
    save_struct('Gv3Daxes_data',Gv3Daxes_data)
    save_struct('Gv3Daxes_normal',Gv3Daxes_normal)
    save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
    save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
    save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)
    save_struct('Gv3Disphase',Gv3Disphase)
    save_struct('Gv3DcurCmap',Gv3DcurCmap)
    save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)
    save_struct('Gv3Dres',Gv3Dres)
    save_struct('Gv3DaxesOn',Gv3DaxesOn)
    
    my_plot_index_Line(handles,handles.axes3)
    drawnow
    
    
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

set_imageSizeEqual(handles)

plot_xyview(handles)
plot_yzview(handles)
plot_xzview(handles)



function initializing(hObject, eventdata, handles)

global num_keypressed;


Gv3Dimage_spec = struct('filename',[],'filepath','../',...
    'scanname',[],'is3D',0,...
    'nx',[],'ny',[],'nz',[],'ns',[],...
    'offset',0,'type',[],...
    'image_data',[],'data',[],'selected_var',[],...
    'mip',[],'minip',[]);


% ------------ don't forget this line !! --------------------
num_keypressed = 0;

set(handles.listbox_info,'string','Information');
set(handles.listbox_var,'string','Variable Name');
set(handles.listbox_var,'Value',1)

set(handles.pushbutton_save2mat,'enable','off');
set(handles.pushbutton_var,'enable','off');
% set(handles.pushbutton_close_enla,'enable','off');


%--------- turn off all matlab supported uitoggletool
% see putdowntext (e.g.,) putdowntext('pan',handles.uitoggletool_pan)
% --- this should exist on openeing, clear_axes,initializing
% --- added at 2010.04.23
zoom(handles.figure1,'off')
pan(handles.figure1,'off')
datacursormode(handles.figure1,'off')


set(handles.figure1,'KeyPressFcn',[])

set(handles.axes4,'ButtonDownFcn',{@axesmove,handles})
set(handles.axes5,'ButtonDownFcn',{@axesmove,handles})
set(handles.axes6,'ButtonDownFcn',{@axesmove,handles})

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

% added at 2011.07.25
pushbutton_wholeView_Callback(hObject, eventdata, handles)

clear_axes(handles)


function mybuttonMotion(hObject, eventdata)
% added at 2010.04.25
ht = handle(hittest(hObject));

if strcmp(get(ht,'tag'),'y_indexLine_in_xy') || strcmp(get(ht,'tag'),'x_indexLine_in_xy') ||...
        strcmp(get(ht,'tag'),'y_indexLine_in_yz') || strcmp(get(ht,'tag'),'z_indexLine_in_yz') ||...
        strcmp(get(ht,'tag'),'z_indexLine_in_xz') || strcmp(get(ht,'tag'),'x_indexLine_in_xz')
    set(hObject,'Pointer','hand')
else
    set(hObject,'Pointer','arrow')
end
    

function mybuttondown(hObject, eventdata,handles)
% this function was modified at 2010.04.24  3 a.m.
% really good job
% Ref. SEE window_motion_fcn.m


ht = handle(hittest(hObject));
seleted_panel = get(ancestor(ht,'uipanel'),'tag');

% disp([seleted_panel,' selected'])

% ----------- added at 2010.04.24  3 a.m.
% really good job
if  strcmp(get(hObject,'SelectionType'),'normal') && strcmp(get(ht,'tag'),'y_indexLine_in_xy')
    set(hObject,'WindowButtonMotionFcn',{@my_wbmcb_y_indexLine_in_xy,handles})
    set(hObject,'WindowButtonUpFcn',@my_wbucb)
elseif  strcmp(get(hObject,'SelectionType'),'normal') && strcmp(get(ht,'tag'),'x_indexLine_in_xy')
    set(hObject,'WindowButtonMotionFcn',{@my_wbmcb_x_indexLine_in_xy,handles})
    set(hObject,'WindowButtonUpFcn',@my_wbucb)
elseif  strcmp(get(hObject,'SelectionType'),'normal') && strcmp(get(ht,'tag'),'y_indexLine_in_yz')
    set(hObject,'WindowButtonMotionFcn',{@my_wbmcb_y_indexLine_in_yz,handles})
    set(hObject,'WindowButtonUpFcn',@my_wbucb)
elseif  strcmp(get(hObject,'SelectionType'),'normal') && strcmp(get(ht,'tag'),'z_indexLine_in_yz')
    set(hObject,'WindowButtonMotionFcn',{@my_wbmcb_z_indexLine_in_yz,handles})
    set(hObject,'WindowButtonUpFcn',@my_wbucb)
elseif  strcmp(get(hObject,'SelectionType'),'normal') && strcmp(get(ht,'tag'),'z_indexLine_in_xz')
    set(hObject,'WindowButtonMotionFcn',{@my_wbmcb_z_indexLine_in_xz,handles})
    set(hObject,'WindowButtonUpFcn',@my_wbucb)
elseif  strcmp(get(hObject,'SelectionType'),'normal') && strcmp(get(ht,'tag'),'x_indexLine_in_xz')
    set(hObject,'WindowButtonMotionFcn',{@my_wbmcb_x_indexLine_in_xz,handles})
    set(hObject,'WindowButtonUpFcn',@my_wbucb)
else
    set(hObject,'WindowButtonMotionFcn',@mybuttonMotion)
    set(hObject,'WindowButtonUpFcn','')
end


% save struct - 2011.03.30
save_struct('seleted_panel',seleted_panel)



function my_wbmcb_y_indexLine_in_xy(hObject, eventdata,handles)
% this function added at 2010.04.24  3 a.m.
% really good job
global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

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

    
set(handles.figure1,'Pointer','crosshair')

cp = get(handles.axes1,'CurrentPoint');
use_cpr = round(cp(1,2));

if use_cpr>0 && use_cpr<Gv3Dimage_spec.ny+1
    Gv3Dslice_index.xz = use_cpr;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
    plot_xzview(handles)
end

    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;



function my_wbmcb_x_indexLine_in_xy(hObject, eventdata,handles)
% this function added at 2010.04.24  3 a.m.
% really good job
global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

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
    
set(handles.figure1,'Pointer','crosshair')

cp = get(handles.axes1,'CurrentPoint');
use_cpr = round(cp(1,1));

if use_cpr>0 && use_cpr<Gv3Dimage_spec.nx+1
    Gv3Dslice_index.yz = use_cpr;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
    plot_yzview(handles)
end

    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;
    

    
function my_wbmcb_y_indexLine_in_yz(hObject, eventdata,handles)
% this function added at 2010.04.24  3 a.m.
% really good job
global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

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
    
set(handles.figure1,'Pointer','crosshair')

cp = get(handles.axes2,'CurrentPoint');
use_cpr = round(cp(1,2));

if use_cpr>0 && use_cpr<Gv3Dimage_spec.ny+1
    Gv3Dslice_index.xz = use_cpr;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
    plot_xzview(handles)
end

    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;

    
function my_wbmcb_z_indexLine_in_yz(hObject, eventdata,handles)
% this function added at 2010.04.24  3 a.m.
% really good job
global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

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
    
set(handles.figure1,'Pointer','crosshair')

cp = get(handles.axes2,'CurrentPoint');
use_cpr = round(cp(1,1));

if use_cpr>0 && use_cpr<Gv3Dimage_spec.nz+1
    Gv3Dslice_index.xy = use_cpr;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
    plot_xyview(handles)
end

    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;

    
function my_wbmcb_z_indexLine_in_xz(hObject, eventdata,handles)
% this function added at 2010.04.24  3 a.m.
% really good job
global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

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
    
set(handles.figure1,'Pointer','crosshair')

cp = get(handles.axes3,'CurrentPoint');
use_cpr = round(cp(1,2));

if use_cpr>0 && use_cpr<Gv3Dimage_spec.nz+1
    Gv3Dslice_index.xy = use_cpr;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
    plot_xyview(handles)
end

    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;
    
    
function my_wbmcb_x_indexLine_in_xz(hObject, eventdata,handles)
% this function added at 2010.04.24  3 a.m.
% really good job
global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

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
    
set(handles.figure1,'Pointer','crosshair')

cp = get(handles.axes3,'CurrentPoint');
use_cpr = round(cp(1,1));

if use_cpr>0 && use_cpr<Gv3Dimage_spec.nx+1
    Gv3Dslice_index.yz = use_cpr;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
    plot_yzview(handles)
end

    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;

    
function my_wbucb(hObject, eventdata)
set(hObject,'WindowButtonMotionFcn',@mybuttonMotion)
set(hObject,'Pointer','arrow')



function mykeypress(hObject, eventdata, handles)

global num_keypressed;
if isempty(num_keypressed)
    num_keypressed = 0;
end

% load saved struct - 2011.03.30
mystruct = save_struct;

seleted_panel = mystruct.seleted_panel;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

try
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
    % SEE help -> Annotation Textbox Properties (matlab 2009b)
    % ---------------------------------------------------
    
    % added 'downarrow' at 2010.04.25
    if strcmp(eventdata.Key,'rightarrow') || strcmp(eventdata.Key,'downarrow')
        
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
    
    % added 'uparrow' at 2010.04.25
    if strcmp(eventdata.Key,'leftarrow') || strcmp(eventdata.Key,'uparrow')
        
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
    
    % added '=' at 2010.04.25
    if strcmp(eventdata.Character,'+') || strcmp(eventdata.Character,'=')
        menu_miniCmap_Brighten_Callback(hObject, eventdata, handles)
    end
    
    if strcmp(eventdata.Character,'-')
        menu_miniCmap_Darken_Callback(hObject, eventdata, handles)
    end
    
    % ------------ don't forget this line !! --------------------
    num_keypressed=num_keypressed-1;

catch%ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
end




function write_logfile(Gv3Dimage_spec)

filepath = Gv3Dimage_spec.filepath;
if isempty(filepath) || strcmp(filepath,'../')
    return;
end

fid = fopen(['./' 'LogfileView3D.log'],'w');


log_content = ['3D mri path = ',filepath,...
    char(13),char(10),...   % carrige return and newline
    ];

if fid~=-1
    fwrite(fid,char(log_content),'char');
    fclose(fid);
end


function view3Dmri_filepath = read_logfile(curfilepath)


fid = fopen(['./' 'LogfileView3D.log'],'r');

if fid~=-1
    log_cont = fread(fid,'char');
    fclose(fid);

    % Input strings must have one row.
    log_cont = char(log_cont');
    
    try
        view3Dmri_filepath = findAsc(log_cont,'3D mri path',' = ');
    catch
        view3Dmri_filepath = curfilepath;
    end
else
    view3Dmri_filepath=[];

end


% --------------------------------------------------------------------
function menu_simhelp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_simhelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


helpdlg({'Can extract Philips CPX Data Sets.',...
    'Just try and see tooltip.'},'Notice');


% --- Executes on button press in pushbutton_save2mat.
function pushbutton_save2mat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save2mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;


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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

% --------------------------------------------------------------------
function change_info(handles)


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;

text_nx = 'X-size';
text_ny = 'Y-size';
text_nz = 'Z-size';
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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)


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


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;


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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)

clear_axes(handles)
plot_image(hObject, eventdata, handles)


function plot_image(hObject, eventdata, handles)


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;

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
    
    set(handles.checkbox_minip_xy,'enable','on');
    set(handles.checkbox_minip_yz,'enable','on');
    set(handles.checkbox_minip_xz,'enable','on');
    
    set(handles.pushbutton_chxy,'enable','on');
    set(handles.pushbutton_chyz,'enable','on');
    set(handles.pushbutton_chzx,'enable','on');
    
    set(handles.text_xyindex,'enable','on');
    set(handles.text_yzindex,'enable','on');
    set(handles.text_xzindex,'enable','on');
    
    set(handles.checkbox_matchAllaxes,'enable','on');
    
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


% %-- add at 2010.04.18 -----> no use 2010.04.23
% if strcmp(get(handles.uitoggletool_zoomin,'State'),'off') && ...
%         strcmp(get(handles.uitoggletool_zoomout,'State'),'off') && ...        
%         strcmp(get(handles.uitoggletool_pan,'State'),'off') && ...
%         strcmp(get(handles.uitoggletool5,'State'),'off')
%     
    set(handles.figure1,'KeyPressFcn',{@mykeypress,handles})
% end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)

change_info(handles)
plot_xyzview(handles)


function clear_axes(handles)
% copy from initializing function
%


% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

%--------- turn off all matlab supported uitoggletool
% see putdowntext (e.g.,) putdowntext('pan',handles.uitoggletool_pan)
% --- this should exist on openeing, clear_axes,initializing
% --- added at 2010.04.23
zoom(handles.figure1,'off')
pan(handles.figure1,'off')
datacursormode(handles.figure1,'off')


Gv3DindexLine = 1;
set(handles.menu_indexLine,'Checked','on');


Gv3Dimage_spec.mip = struct('xy',[],'yz',[],'xz',[]);
Gv3Dimage_spec.minip = struct('xy',[],'yz',[],'xz',[]);

% Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

% set(handles.edit_y_res,'string','1.0');
% set(handles.edit_x_res,'string','1.0');
% set(handles.edit_z_res,'string','1.0');

Gv3Dslice_index = struct('xy',1,'yz',1,'xz',1);
Gv3Daxes_data = struct('xy',[],'yz',[],'xz',[]);
Gv3Daxes_normal = struct('xy',0,'yz',0,'xz',0);
Gv3Dchk_mip = struct('xy',0,'yz',0,'xz',0);
Gv3Dchk_minip = struct('xy',0,'yz',0,'xz',0);

Gv3D_Intensity = struct('min',[],'max',[]);
Gv3Dcur_Intensity = struct('min',[],'max',[]);

Gv3DcurCmap = [];
Gv3Dapply_curCmap2all = 1;
set(handles.menu_miniCmap_apply2all,'Checked','on');
apply_Gv3DcurCmap2enlarged = 1;
set(handles.menu_miniCmap_apply2enlarged,'Checked','on');


Gv3DaxesOn = 0;
set(handles.menu_axisOn,'Checked','off');

Gv3DmatchAllaxes = 0;
set(handles.checkbox_matchAllaxes,'enable','off');
set(handles.checkbox_matchAllaxes,'Value',0)

Gv3Disphase = 0;
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

set(handles.checkbox_minip_xy,'enable','off');
set(handles.checkbox_minip_yz,'enable','off');
set(handles.checkbox_minip_xz,'enable','off');

set(handles.checkbox_minip_xy,'Value',0);
set(handles.checkbox_minip_yz,'Value',0);
set(handles.checkbox_minip_xz,'Value',0);

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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)
save_struct('Gv3Daxes_data',Gv3Daxes_data)
save_struct('Gv3Daxes_normal',Gv3Daxes_normal)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
save_struct('Gv3D_Intensity',Gv3D_Intensity)
save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)
save_struct('Gv3Disphase',Gv3Disphase)
save_struct('Gv3DcurCmap',Gv3DcurCmap)
save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)
save_struct('Gv3DaxesOn',Gv3DaxesOn)
save_struct('Gv3DmatchAllaxes',Gv3DmatchAllaxes)
save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)
save_struct('apply_Gv3DcurCmap2enlarged',apply_Gv3DcurCmap2enlarged)
save_struct('Gv3DindexLine',Gv3DindexLine)
save_struct('seleted_panel','uipanel1')

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

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Daxes_data = mystruct.Gv3Daxes_data;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;
Gv3Disphase = mystruct.Gv3Disphase;
Gv3DcurCmap = mystruct.Gv3DcurCmap;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;
Gv3Dres = mystruct.Gv3Dres;
Gv3DenLarged_imH = mystruct.Gv3DenLarged_imH;
apply_Gv3DcurCmap2enlarged = mystruct.apply_Gv3DcurCmap2enlarged;

Gv3DenLarged_imH = check_enLarged_index(Gv3DenLarged_imH);

[r,c] = size(Gv3Daxes_data.xy);

if r>1 && c>1
    if Gv3Disphase || isempty(Gv3Dcur_Intensity.max)
        mrimage(Gv3Daxes_data.xy,[],Gv3DenLarged_imH.init_fig_index+1);
    else
%         mrimage(Gv3Daxes_data.xy,[min(mag(Gv3Daxes_data.xy(:))),...
%             min(max(mag(Gv3Daxes_data.xy(:))),Gv3Dcur_max_Intensity)],...
%             Gv3DenLarged_imH.init_fig_index+1);
        
%         if isreal(Gv3Daxes_data.xy(:))
%             min_intensity = min(Gv3Daxes_data.xy(:));
%         else
%             min_intensity = min(mag(Gv3Daxes_data.xy(:)));
%         end
        mrimage(Gv3Daxes_data.xy,[Gv3Dcur_Intensity.min,...
            Gv3Dcur_Intensity.max],...
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
    elseif Gv3Dchk_minip.xy
        title({['filename : ',Gv3Dimage_spec.filename,' '],...
            ['varable : ',Gv3Dimage_spec.selected_var,', ',...
            'x-y MinIP image']},'Interpreter','none');
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
% set(gcf,'position',[screen_size(3)*0.2 screen_size(4)*0.2 screen_size(3)*0.6 screen_size(4)*0.6])
% ------- modified at 2010.04.18
min_screen_size = min(screen_size(3),screen_size(4));
% set(gcf,'position',[min_screen_size*0.2 min_screen_size*0.2 min_screen_size*0.6 min_screen_size*0.6])

% ------- modified at 2010.04.19
offset_size = 30; % maybe pixel
max_num_LR = floor(screen_size(3)*0.1/offset_size);
max_num_BT = floor(screen_size(4)*0.1/offset_size);
offset_LR = mod(length(Gv3DenLarged_imH.opened_fig_indic),max_num_LR)*offset_size;
offset_BT = mod(length(Gv3DenLarged_imH.opened_fig_indic),max_num_BT)*offset_size;

% ------- modified at 2011.02.10
% set(gcf,'position',[screen_size(3)*0.1+offset_LR screen_size(4)*0.1-offset_BT min_screen_size*0.6 min_screen_size*0.6])
set(gcf,'position',[screen_size(3)*0.1+offset_LR screen_size(4)*0.1-offset_BT min_screen_size*0.5 min_screen_size*0.5])
% -------------------------------------------------------------------------


Gv3DenLarged_imH.opened_fig_indic = ...
    [Gv3DenLarged_imH.opened_fig_indic;Gv3DenLarged_imH.init_fig_index+1];


set(handles.pushbutton_close_enla,'enable','on');


% save struct - 2011.03.30
save_struct('Gv3DenLarged_imH',Gv3DenLarged_imH)

% --- Executes on button press in pushbutton_enla2.
function pushbutton_enla2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enla2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Daxes_data = mystruct.Gv3Daxes_data;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;
Gv3Disphase = mystruct.Gv3Disphase;
Gv3DcurCmap = mystruct.Gv3DcurCmap;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;
Gv3Dres = mystruct.Gv3Dres;
Gv3DenLarged_imH = mystruct.Gv3DenLarged_imH;
apply_Gv3DcurCmap2enlarged = mystruct.apply_Gv3DcurCmap2enlarged;

Gv3DenLarged_imH = check_enLarged_index(Gv3DenLarged_imH);

if Gv3Disphase || isempty(Gv3Dcur_Intensity.max)
    mrimage(Gv3Daxes_data.yz,[],Gv3DenLarged_imH.init_fig_index+1);
else
%     mrimage(Gv3Daxes_data.yz,[min(mag(Gv3Daxes_data.yz(:))),...
%         min(max(mag(Gv3Daxes_data.yz(:))),Gv3Dcur_max_Intensity)],...
%         Gv3DenLarged_imH.init_fig_index+1);

%     if isreal(Gv3Daxes_data.yz(:))
%         min_intensity = min(Gv3Daxes_data.yz(:));
%     else
%         min_intensity = min(mag(Gv3Daxes_data.yz(:)));
%     end
    mrimage(Gv3Daxes_data.yz,[Gv3Dcur_Intensity.min,...
        Gv3Dcur_Intensity.max],...
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
elseif Gv3Dchk_minip.yz
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        'y-z MinIP image']},'Interpreter','none');
else
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        num2str(Gv3Dslice_index.yz),' th y-z slice']},'Interpreter','none');
end

%-------------------- set figure size -- modified at 2009.10.31 ------------
screen_size = get(0,'ScreenSize');
% set(gcf,'position',[screen_size(3)*0.2 screen_size(4)*0.2 screen_size(3)*0.6 screen_size(4)*0.6])
% ------- modified at 2010.04.18
min_screen_size = min(screen_size(3),screen_size(4));
% set(gcf,'position',[min_screen_size*0.2 min_screen_size*0.2 min_screen_size*0.6 min_screen_size*0.6])

% ------- modified at 2010.04.19
offset_size = 30; % maybe pixel
max_num_LR = floor(screen_size(3)*0.1/offset_size);
max_num_BT = floor(screen_size(4)*0.1/offset_size);
offset_LR = mod(length(Gv3DenLarged_imH.opened_fig_indic),max_num_LR)*offset_size;
offset_BT = mod(length(Gv3DenLarged_imH.opened_fig_indic),max_num_BT)*offset_size;

% ------- modified at 2011.02.10
% set(gcf,'position',[screen_size(3)*0.3+offset_LR screen_size(4)*0.1-offset_BT min_screen_size*0.6 min_screen_size*0.6])
set(gcf,'position',[screen_size(3)*0.4+offset_LR screen_size(4)*0.1-offset_BT min_screen_size*0.5 min_screen_size*0.5])
% -------------------------------------------------------------------------


Gv3DenLarged_imH.opened_fig_indic = ...
    [Gv3DenLarged_imH.opened_fig_indic;Gv3DenLarged_imH.init_fig_index+1];

set(handles.pushbutton_close_enla,'enable','on');

% save struct - 2011.03.30
save_struct('Gv3DenLarged_imH',Gv3DenLarged_imH)

% --- Executes on button press in pushbutton_enla3.
function pushbutton_enla3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enla3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Daxes_data = mystruct.Gv3Daxes_data;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;
Gv3Disphase = mystruct.Gv3Disphase;
Gv3DcurCmap = mystruct.Gv3DcurCmap;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;
Gv3Dres = mystruct.Gv3Dres;
Gv3DenLarged_imH = mystruct.Gv3DenLarged_imH;
apply_Gv3DcurCmap2enlarged = mystruct.apply_Gv3DcurCmap2enlarged;

Gv3DenLarged_imH = check_enLarged_index(Gv3DenLarged_imH);

if Gv3Disphase || isempty(Gv3Dcur_Intensity.max)
    mrimage(Gv3Daxes_data.xz,[],Gv3DenLarged_imH.init_fig_index+1);
else
%     mrimage(Gv3Daxes_data.xz,[min(mag(Gv3Daxes_data.xz(:))),...
%         min(max(mag(Gv3Daxes_data.xz(:))),Gv3Dcur_max_Intensity)],...
%         Gv3DenLarged_imH.init_fig_index+1);

%     if isreal(Gv3Daxes_data.xz(:))
%         min_intensity = min(Gv3Daxes_data.xz(:));
%     else
%         min_intensity = min(mag(Gv3Daxes_data.xz(:)));
%     end
    mrimage(Gv3Daxes_data.xz,[Gv3Dcur_Intensity.min,...
        Gv3Dcur_Intensity.max],...
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
elseif Gv3Dchk_minip.xz
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        'x-z MinIP image']},'Interpreter','none');
else
    title({['filename : ',Gv3Dimage_spec.filename,' '],...
        ['varable : ',Gv3Dimage_spec.selected_var,', ',...
        num2str(Gv3Dslice_index.xz),' th x-z slice']},'Interpreter','none');
end

%-------------------- set figure size -- modified at 2009.10.31 ------------
screen_size = get(0,'ScreenSize');
% set(gcf,'position',[screen_size(3)*0.2 screen_size(4)*0.2 screen_size(3)*0.6 screen_size(4)*0.6])
% ------- modified at 2010.04.18
min_screen_size = min(screen_size(3),screen_size(4));
% set(gcf,'position',[min_screen_size*0.2 min_screen_size*0.2 min_screen_size*0.6 min_screen_size*0.6])

% ------- modified at 2010.04.19
offset_size = 30; % maybe pixel
max_num_LR = floor(screen_size(3)*0.1/offset_size);
max_num_BT = floor(screen_size(4)*0.1/offset_size);
offset_LR = mod(length(Gv3DenLarged_imH.opened_fig_indic),max_num_LR)*offset_size;
offset_BT = mod(length(Gv3DenLarged_imH.opened_fig_indic),max_num_BT)*offset_size;

% ------- modified at 2011.02.10
% set(gcf,'position',[screen_size(3)*0.1+offset_LR screen_size(4)*0.3-offset_BT min_screen_size*0.6 min_screen_size*0.6])
set(gcf,'position',[screen_size(3)*0.1+offset_LR screen_size(4)*0.4-offset_BT min_screen_size*0.5 min_screen_size*0.5])
% -------------------------------------------------------------------------


Gv3DenLarged_imH.opened_fig_indic = ...
    [Gv3DenLarged_imH.opened_fig_indic;Gv3DenLarged_imH.init_fig_index+1];

set(handles.pushbutton_close_enla,'enable','on');

% save struct - 2011.03.30
save_struct('Gv3DenLarged_imH',Gv3DenLarged_imH)

% --- Executes on button press in pushbutton_close_enla.
function pushbutton_close_enla_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close_enla (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3DenLarged_imH = mystruct.Gv3DenLarged_imH;

for n=1:length(Gv3DenLarged_imH.opened_fig_indic)
    if ishandle(Gv3DenLarged_imH.opened_fig_indic(n))
        close(Gv3DenLarged_imH.opened_fig_indic(n));
    end
end

Gv3DenLarged_imH.init_fig_index = Gv3DenLarged_imH.opened_fig_indic(1)-1;
Gv3DenLarged_imH.opened_fig_indic = [];

set(handles.pushbutton_close_enla,'enable','off');

save_struct('Gv3DenLarged_imH',Gv3DenLarged_imH)

function Gv3DenLarged_imH = check_enLarged_index(Gv3DenLarged_imH)


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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Daxes_normal.xy = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Daxes_normal.xy = 0;
end

% save struct - 2011.03.30
save_struct('Gv3Daxes_normal',Gv3Daxes_normal)

plot_xyview(handles)

% --- Executes on button press in checkbox_axis2.
function checkbox_axis2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axis2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_axis2

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Daxes_normal.yz = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Daxes_normal.yz = 0;
end

% save struct - 2011.03.30
save_struct('Gv3Daxes_normal',Gv3Daxes_normal)

plot_yzview(handles)

% --- Executes on button press in checkbox_axis3.
function checkbox_axis3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axis3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_axis3

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Daxes_normal = mystruct.Gv3Daxes_normal;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Daxes_normal.xz = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3Daxes_normal.xz = 0;
end

% save struct - 2011.03.30
save_struct('Gv3Daxes_normal',Gv3Daxes_normal)

plot_xzview(handles)


% --- Executes on button press in checkbox_mip_yz.
function checkbox_mip_yz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mip_yz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mip_yz

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_mip.yz = 1;
    set(handles.checkbox_minip_yz,'Value',0)
    Gv3Dchk_minip.yz = 0;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_mip.yz = 0;
end

if isempty(Gv3Dimage_spec.mip.yz)
    disp('processing MIP...')
    Gv3Dimage_spec.mip.yz = MIP(Gv3Dimage_spec.image_data,2);
    disp('Done!!')
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)

plot_yzview(handles)


% --- Executes on button press in checkbox_mip_xy.
function checkbox_mip_xy_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mip_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mip_xy

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_mip.xy = 1;
    set(handles.checkbox_minip_xy,'Value',0)
    Gv3Dchk_minip.xy = 0;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_mip.xy = 0;
end

if isempty(Gv3Dimage_spec.mip.xy)
    disp('processing MIP...')
    Gv3Dimage_spec.mip.xy = MIP(Gv3Dimage_spec.image_data,3);
    disp('Done!!')
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)

plot_xyview(handles)

% --- Executes on button press in checkbox_mip_xz.
function checkbox_mip_xz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mip_xz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mip_xz

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_mip.xz = 1;
    set(handles.checkbox_minip_xz,'Value',0)
    Gv3Dchk_minip.xz = 0;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_mip.xz = 0;
end

if isempty(Gv3Dimage_spec.mip.xz)
    disp('processing MIP...')
    Gv3Dimage_spec.mip.xz = MIP(Gv3Dimage_spec.image_data,1);
    disp('Done!!')
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)

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

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dres = mystruct.Gv3Dres;


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
    
    
    % ---- swap
    temp = Gv3Dres.x;
    Gv3Dres.x = Gv3Dres.y;
    Gv3Dres.y = temp;
    set(handles.edit_x_res,'string',num2str(Gv3Dres.x));
    set(handles.edit_y_res,'string',num2str(Gv3Dres.y));
    

    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dslice_index',Gv3Dslice_index)
    save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
    save_struct('Gv3Dres',Gv3Dres)

    my_delete_All_index_Line(handles)
    
    plot_image(hObject, eventdata, handles)
    
    
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


% --- Executes on button press in pushbutton_chyz.
function pushbutton_chyz_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chyz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dres = mystruct.Gv3Dres;

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

    
    % ---- swap
    temp = Gv3Dres.y;
    Gv3Dres.y = Gv3Dres.z;
    Gv3Dres.z = temp;
    set(handles.edit_z_res,'string',num2str(Gv3Dres.z));
    set(handles.edit_y_res,'string',num2str(Gv3Dres.y));
    

    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dslice_index',Gv3Dslice_index)
    save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
    save_struct('Gv3Dres',Gv3Dres)
    
    my_delete_All_index_Line(handles)
    
    plot_image(hObject, eventdata, handles)

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


% --- Executes on button press in pushbutton_chzx.
function pushbutton_chzx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_chzx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dres = mystruct.Gv3Dres;

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
    
    
    % ---- swap
    temp = Gv3Dres.x;
    Gv3Dres.x = Gv3Dres.z;
    Gv3Dres.z = temp;
    set(handles.edit_x_res,'string',num2str(Gv3Dres.x));
    set(handles.edit_z_res,'string',num2str(Gv3Dres.z));
    

    % save struct - 2011.03.30
    save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
    save_struct('Gv3Dslice_index',Gv3Dslice_index)
    save_struct('Gv3Dchk_mip',Gv3Dchk_mip)
    save_struct('Gv3Dres',Gv3Dres)


    my_delete_All_index_Line(handles)
    
    plot_image(hObject, eventdata, handles)
    
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



% --- Executes on button press in pushbutton_flz.
function pushbutton_flz_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;

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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)

plot_image(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_flx.
function pushbutton_flx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;

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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)

plot_image(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_fly.
function pushbutton_fly_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;

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

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dslice_index',Gv3Dslice_index)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)

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

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dres = mystruct.Gv3Dres;

% import variable names of base workspace
vars = evalin('base', 'who');

if ~isempty(vars)
    pathname = Gv3Dimage_spec.filepath;     % save path before initializing
    
    initializing(hObject, eventdata, handles)

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

    Gv3Dimage_spec.filename = 'Base_Workspace';
    Gv3Dimage_spec.filepath = pathname;
%     Gv3Dimage_spec.type = 'baseWS';
    
% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dres',Gv3Dres)

    change_var(hObject, eventdata, handles)
    
    Gv3Dres = struct('y',1.0,'x',1.0,'z',1.0);

% save struct - 2011.03.30
save_struct('Gv3Dres',Gv3Dres)

    set(handles.edit_y_res,'string','1.0');
    set(handles.edit_x_res,'string','1.0');
    set(handles.edit_z_res,'string','1.0');

end



% --- Executes on slider movement.
function slider_max_Callback(hObject, eventdata, handles)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3D_Intensity = mystruct.Gv3D_Intensity;
Gv3Dcur_Intensity = mystruct.Gv3Dcur_Intensity;

max_Intensity_percent = get(hObject,'Value');

if Gv3Dimage_spec.is3D

    if ~(iscell(Gv3Dimage_spec.image_data) ||...
            ischar(Gv3Dimage_spec.image_data) ||...
            iscellstr(Gv3Dimage_spec.image_data))
        if isempty(Gv3D_Intensity.max)
            disp('Finding minimum & maximum intensity...')
            drawnow
            if isreal(Gv3Dimage_spec.image_data)
                Gv3D_Intensity.max = max(Gv3Dimage_spec.image_data(:));
                Gv3D_Intensity.min = min(Gv3Dimage_spec.image_data(:));
            else
                Gv3D_Intensity.max = max(mag(Gv3Dimage_spec.image_data(:)));
                Gv3D_Intensity.min = min(mag(Gv3Dimage_spec.image_data(:)));
            end
            
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
        if r>1 && c>1 && isempty(Gv3D_Intensity.max)
            Gv3D_Intensity.max = zeros(Gv3Dimage_spec.ns,1);

            disp('Finding maximum intensity...')
            drawnow
            for n=1:Gv3Dimage_spec.ns
                if isreal(Gv3Dimage_spec.image_data{n})
                    Gv3D_Intensity.max(n) = max(Gv3Dimage_spec.image_data{n}(:));
                    Gv3D_Intensity.min(n) = min(Gv3Dimage_spec.image_data{n}(:));
                else
                    Gv3D_Intensity.max(n) = max(mag(Gv3Dimage_spec.image_data{n}(:)));
                    Gv3D_Intensity.min(n) = min(mag(Gv3Dimage_spec.image_data{n}(:)));
                end
            end            
            Gv3D_Intensity.max = max(Gv3D_Intensity.max(n));
            Gv3D_Intensity.min = min(Gv3D_Intensity.min(n));
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

if ~isempty(Gv3D_Intensity.max)
    Gv3Dcur_Intensity.max = Gv3D_Intensity.max*max_Intensity_percent;
    Gv3Dcur_Intensity.min = Gv3D_Intensity.min;
    set(handles.pushbutton_resetMax,'enable','on');
    
% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3D_Intensity',Gv3D_Intensity)
save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)

    plot_xyzview(handles)
else
    set(handles.slider_max,'Value',1)
end


% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3D_Intensity',Gv3D_Intensity)
save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)

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



Gv3Dcur_Intensity = struct('min',[],'max',[]);

set(handles.slider_max,'Value',1)
set(handles.pushbutton_resetMax,'enable','off');

% save struct - 2011.03.30
save_struct('Gv3Dcur_Intensity',Gv3Dcur_Intensity)

% plot_image(hObject, eventdata, handles)
plot_xyzview(handles)


% --- Executes on button press in checkbox_viewphase.
function checkbox_viewphase_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_viewphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_viewphase

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Disphase = mystruct.Gv3Disphase;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Disphase = 1;    
else
	% Checkbox is not checked-take approriate action
    Gv3Disphase = 0;
end

% save struct - 2011.03.30
save_struct('Gv3Disphase',Gv3Disphase)

plot_xyzview(handles)


% --- Executes on button press in checkbox_matchAllaxes.
function checkbox_matchAllaxes_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_matchAllaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_matchAllaxes

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3DmatchAllaxes = mystruct.Gv3DmatchAllaxes;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3DmatchAllaxes = 1;
else
	% Checkbox is not checked-take approriate action
    Gv3DmatchAllaxes = 0;
end

% save struct - 2011.03.30
save_struct('Gv3DmatchAllaxes',Gv3DmatchAllaxes)

set_imageSizeEqual(handles)


function set_imageSizeEqual(handles)

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3DmatchAllaxes = mystruct.Gv3DmatchAllaxes;
Gv3Dres = mystruct.Gv3Dres;
Gv3DinitAxisPos = mystruct.Gv3DinitAxisPos;

% ---- entirely modified at 2010.04.24
% nicely work now
if Gv3DmatchAllaxes && Gv3Dimage_spec.is3D
    
    FOVx = Gv3Dimage_spec.nx * Gv3Dres.x;
    FOVy = Gv3Dimage_spec.ny * Gv3Dres.y;
    FOVz = Gv3Dimage_spec.nz * Gv3Dres.z;
    
    max_FOV = max([FOVx,FOVy,FOVz]);
    FOV_ratio = [FOVy, FOVx, FOVz]/max_FOV;
    
    
    set(handles.axes1,'Position',[Gv3DinitAxisPos(1)+Gv3DinitAxisPos(3)*(1-FOV_ratio(2))/2,...
        Gv3DinitAxisPos(2)+Gv3DinitAxisPos(4)*(1-FOV_ratio(1))/2,...
        Gv3DinitAxisPos(3)*FOV_ratio(2), Gv3DinitAxisPos(4)*FOV_ratio(1)]);

    set(handles.axes2,'Position',[Gv3DinitAxisPos(1)+Gv3DinitAxisPos(3)*(1-FOV_ratio(3))/2,...
        Gv3DinitAxisPos(2)+Gv3DinitAxisPos(4)*(1-FOV_ratio(1))/2,...
        Gv3DinitAxisPos(3)*FOV_ratio(3), Gv3DinitAxisPos(4)*FOV_ratio(1)]);
    
    set(handles.axes3,'Position',[Gv3DinitAxisPos(1)+Gv3DinitAxisPos(3)*(1-FOV_ratio(2))/2,...
        Gv3DinitAxisPos(2)+Gv3DinitAxisPos(4)*(1-FOV_ratio(3))/2,...
        Gv3DinitAxisPos(3)*FOV_ratio(2), Gv3DinitAxisPos(4)*FOV_ratio(3)]);
    
else
    
    set(handles.axes1,'Position',Gv3DinitAxisPos)
    set(handles.axes2,'Position',Gv3DinitAxisPos)
    set(handles.axes3,'Position',Gv3DinitAxisPos)

end


% --------------------------------------------------------------------
function menu_cmap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_cmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% just start colormap editor ????
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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dapply_curCmap2all = mystruct.Gv3Dapply_curCmap2all;

if strcmp(get(hObject, 'Checked'),'on')
    set(hObject,'Checked','off');
    Gv3Dapply_curCmap2all = 0;
else 
    set(hObject,'Checked','on');
    Gv3Dapply_curCmap2all = 1;
% save struct - 2011.03.30
save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)
    plot_xyzview(handles) % only set current colormap when checked
end

% save struct - 2011.03.30
save_struct('Gv3Dapply_curCmap2all',Gv3Dapply_curCmap2all)

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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3DcurCmap = mystruct.Gv3DcurCmap;

Gv3DcurCmap = get(handles.figure1,'Colormap'); % fig is figure handle or use gcf
% save struct - 2011.03.30
save_struct('Gv3DcurCmap',Gv3DcurCmap)


% --------------------------------------------------------------------
function menu_exWS_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dimage_spec = mystruct.Gv3Dimage_spec;

if isempty(Gv3Dimage_spec.data)
    return;
end

disp('Exporting to Base Workspace...')

var_name = sort(fieldnames(Gv3Dimage_spec.data));    % get variable name in struct to cell

for n=1:length(var_name)
    eval(['assignin(''base'',var_name{n},Gv3Dimage_spec.data.',var_name{n},')']);
end

if ~isempty(Gv3Dimage_spec.mip.xy)
    assignin('base',[Gv3Dimage_spec.selected_var,'_MIP_xy'],Gv3Dimage_spec.mip.xy)
end
if ~isempty(Gv3Dimage_spec.mip.xz)
    assignin('base',[Gv3Dimage_spec.selected_var,'_MIP_xz'],Gv3Dimage_spec.mip.xz)
end
if ~isempty(Gv3Dimage_spec.mip.yz)
    assignin('base',[Gv3Dimage_spec.selected_var,'_MIP_yz'],Gv3Dimage_spec.mip.yz)
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

% load saved struct - 2011.03.30
mystruct = save_struct;
apply_Gv3DcurCmap2enlarged = mystruct.apply_Gv3DcurCmap2enlarged;

if strcmp(get(hObject, 'Checked'),'on')
    set(hObject,'Checked','off');
    apply_Gv3DcurCmap2enlarged = 0;
else 
    set(hObject,'Checked','on');
    apply_Gv3DcurCmap2enlarged = 1;
end

% save struct - 2011.03.30
save_struct('apply_Gv3DcurCmap2enlarged',apply_Gv3DcurCmap2enlarged)


% --------------------------------------------------------------------
function menu_miniCmap_clear_Callback(hObject, eventdata, handles)
% hObject    handle to menu_miniCmap_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Gv3DcurCmap = [];
% save struct - 2011.03.30
save_struct('Gv3DcurCmap',Gv3DcurCmap)

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



%------ i want delete this not-using function ????



function text_xzindex_Callback(hObject, eventdata, handles)
% hObject    handle to text_xzindex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_xzindex as text
%        str2double(get(hObject,'String')) returns contents of text_xzindex as a double

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;

user_entry = str2double(get(hObject,'string'));

% if isnan(user_entry)
%  errordlg('You must enter a numeric value','Bad Input','modal')
%  return
% end

% Proceed with callback...
try
    if ~isnan(user_entry) && user_entry>0 && user_entry<=Gv3Dimage_spec.ny
        Gv3Dslice_index.xz = user_entry;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
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

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;


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
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
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

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;

user_entry = str2double(get(hObject,'string'));

% if isnan(user_entry)
%  errordlg('You must enter a numeric value','Bad Input','modal')
%  return
% end

% Proceed with callback...
try
    if ~isnan(user_entry) && user_entry>0 && user_entry<=Gv3Dimage_spec.nx
        Gv3Dslice_index.yz = user_entry;
% save struct - 2011.03.30
save_struct('Gv3Dslice_index',Gv3Dslice_index)
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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dres = mystruct.Gv3Dres;

user_entry = str2double(get(hObject,'string'));

% Proceed with callback...
try
    
    if ~isnan(user_entry) && user_entry>0
        Gv3Dres.y = user_entry;
% save struct - 2011.03.30
save_struct('Gv3Dres',Gv3Dres)
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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dres = mystruct.Gv3Dres;

user_entry = str2double(get(hObject,'string'));

% Proceed with callback...
try
    
    if ~isnan(user_entry) && user_entry>0
        Gv3Dres.x = user_entry;
% save struct - 2011.03.30
save_struct('Gv3Dres',Gv3Dres)
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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3Dres = mystruct.Gv3Dres;

user_entry = str2double(get(hObject,'string'));

% Proceed with callback...
try
    
    if ~isnan(user_entry) && user_entry>0
        Gv3Dres.z = user_entry;
% save struct - 2011.03.30
save_struct('Gv3Dres',Gv3Dres)
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

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3DaxesOn = mystruct.Gv3DaxesOn;

if strcmp(get(hObject, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    Gv3DaxesOn = 0;
else 
    set(gcbo, 'Checked', 'on');
    Gv3DaxesOn = 1;
end

% save struct - 2011.03.30
save_struct('Gv3DaxesOn',Gv3DaxesOn)

plot_xyzview(handles)


% --- Executes on button press in checkbox_minip_xz.
function checkbox_minip_xz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_minip_xz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_minip_xz

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_minip.xz = 1;
    set(handles.checkbox_mip_xz,'Value',0)
    Gv3Dchk_mip.xz = 0;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_minip.xz = 0;
end

if isempty(Gv3Dimage_spec.minip.xz)
    disp('processing minIP...')
    Gv3Dimage_spec.minip.xz = MinIP(Gv3Dimage_spec.image_data,1);
    disp('Done!!')
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)

plot_xzview(handles)


% --- Executes on button press in checkbox_minip_xy.
function checkbox_minip_xy_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_minip_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_minip_xy

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_minip.xy = 1;
    set(handles.checkbox_mip_xy,'Value',0)
    Gv3Dchk_mip.xy = 0;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_minip.xy = 0;
end

if isempty(Gv3Dimage_spec.minip.xy)
    disp('processing minIP...')
    Gv3Dimage_spec.minip.xy = MinIP(Gv3Dimage_spec.image_data,3);
    disp('Done!!')
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)

plot_xyview(handles)


% --- Executes on button press in checkbox_minip_yz.
function checkbox_minip_yz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_minip_yz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_minip_yz

% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dchk_mip = mystruct.Gv3Dchk_mip;
Gv3Dchk_minip = mystruct.Gv3Dchk_minip;

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    Gv3Dchk_minip.yz = 1;
    set(handles.checkbox_mip_yz,'Value',0)
    Gv3Dchk_mip.yz = 0;
else
	% Checkbox is not checked-take approriate action
    Gv3Dchk_minip.yz = 0;
end

if isempty(Gv3Dimage_spec.minip.yz)
    disp('processing minIP...')
    Gv3Dimage_spec.minip.yz = MinIP(Gv3Dimage_spec.image_data,2);
    disp('Done!!')
end

% save struct - 2011.03.30
save_struct('Gv3Dimage_spec',Gv3Dimage_spec)
save_struct('Gv3Dchk_minip',Gv3Dchk_minip)
save_struct('Gv3Dchk_mip',Gv3Dchk_mip)

plot_yzview(handles)


% --------------------------------------------------------------------
function menu_indexLine_Callback(hObject, eventdata, handles)
% hObject    handle to menu_indexLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load saved struct - 2011.03.30
mystruct = save_struct;
Gv3DindexLine = mystruct.Gv3DindexLine;

if strcmp(get(hObject, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    Gv3DindexLine = 0;
    delete(findobj(get(handles.axes2,'children'),'tag','z_indexLine_in_yz'))
    delete(findobj(get(handles.axes2,'children'),'tag','y_indexLine_in_yz'))
    delete(findobj(get(handles.axes3,'children'),'tag','z_indexLine_in_xz'))
    delete(findobj(get(handles.axes3,'children'),'tag','x_indexLine_in_xz'))
    delete(findobj(get(handles.axes1,'children'),'tag','x_indexLine_in_xy'))
    delete(findobj(get(handles.axes1,'children'),'tag','y_indexLine_in_xy'))
else 
    set(gcbo, 'Checked', 'on');
    Gv3DindexLine = 1;
end

% save struct - 2011.03.30
save_struct('Gv3DindexLine',Gv3DindexLine)

plot_xyzview(handles)

% --------------------------------------------------------------------
function my_plot_index_Line(handles,cur_axes_handle)
% this function added at 2010.04.24  3 a.m.
% good job
%
% remove axes() using 'parent' property - 2011.07.23
% drawnow ?????? ?? ?????? ???? - 2011.07.25


% load saved struct - 2011.03.30
mystruct = save_struct;

Gv3Dimage_spec = mystruct.Gv3Dimage_spec;
Gv3Dslice_index = mystruct.Gv3Dslice_index;
Gv3DindexLine = mystruct.Gv3DindexLine;

try
    if Gv3DindexLine && Gv3Dimage_spec.is3D
        
        % cur_axes_handle = get(handles.figure1,'CurrentAxes');
        
        % ------------------- modified at 2010.07.20
        if cur_axes_handle==handles.axes1
            delete(findobj(get(handles.axes2,'children'),'tag','z_indexLine_in_yz'))
            line([Gv3Dslice_index.xy Gv3Dslice_index.xy],[1-0.5 Gv3Dimage_spec.ny+0.5],'color','g','tag','z_indexLine_in_yz','parent',handles.axes2,'EraseMode','none')
            
            delete(findobj(get(handles.axes3,'children'),'tag','z_indexLine_in_xz'))
            line([1-0.5 Gv3Dimage_spec.nx+0.5],[Gv3Dslice_index.xy Gv3Dslice_index.xy],'color','g','tag','z_indexLine_in_xz','parent',handles.axes3,'EraseMode','none')
            
            drawnow
        end
        
        if cur_axes_handle==handles.axes2
            delete(findobj(get(handles.axes1,'children'),'tag','x_indexLine_in_xy'))
            line([Gv3Dslice_index.yz Gv3Dslice_index.yz],[1-0.5 Gv3Dimage_spec.ny+0.5],'color','r','tag','x_indexLine_in_xy','parent',handles.axes1,'EraseMode','none')
            
            delete(findobj(get(handles.axes3,'children'),'tag','x_indexLine_in_xz'))
            line([Gv3Dslice_index.yz Gv3Dslice_index.yz],[1-0.5 Gv3Dimage_spec.nz+0.5],'color','r','tag','x_indexLine_in_xz','parent',handles.axes3,'EraseMode','none')
            
            drawnow
        end
        
        if cur_axes_handle==handles.axes3
            delete(findobj(get(handles.axes1,'children'),'tag','y_indexLine_in_xy'))
            line([1-0.5 Gv3Dimage_spec.nx+0.5],[Gv3Dslice_index.xz Gv3Dslice_index.xz],'color','y','tag','y_indexLine_in_xy','parent',handles.axes1,'EraseMode','none')
            
            delete(findobj(get(handles.axes2,'children'),'tag','y_indexLine_in_yz'))
            line([1-0.5 Gv3Dimage_spec.nz+0.5],[Gv3Dslice_index.xz Gv3Dslice_index.xz],'color','y','tag','y_indexLine_in_yz','parent',handles.axes2,'EraseMode','none')
            
            drawnow
        end
    
        
        % ------------------- modified at 2010.07.20
        %---------------- redraw index line --- not much slow, good
        if isempty(findobj(get(handles.axes1,'children'),'tag','y_indexLine_in_xy'))
            line([1-0.5 Gv3Dimage_spec.nx+0.5],[Gv3Dslice_index.xz Gv3Dslice_index.xz],'color','y','tag','y_indexLine_in_xy','parent',handles.axes1,'EraseMode','none')
            drawnow
        end
        if isempty(findobj(get(handles.axes1,'children'),'tag','x_indexLine_in_xy'))
            line([Gv3Dslice_index.yz Gv3Dslice_index.yz],[1-0.5 Gv3Dimage_spec.ny+0.5],'color','r','tag','x_indexLine_in_xy','parent',handles.axes1,'EraseMode','none')
            drawnow
        end
        if isempty(findobj(get(handles.axes2,'children'),'tag','y_indexLine_in_yz'))
            line([1-0.5 Gv3Dimage_spec.nz+0.5],[Gv3Dslice_index.xz Gv3Dslice_index.xz],'color','y','tag','y_indexLine_in_yz','parent',handles.axes2,'EraseMode','none')
            drawnow
        end
        if isempty(findobj(get(handles.axes2,'children'),'tag','z_indexLine_in_yz'))
            line([Gv3Dslice_index.xy Gv3Dslice_index.xy],[1-0.5 Gv3Dimage_spec.ny+0.5],'color','g','tag','z_indexLine_in_yz','parent',handles.axes2,'EraseMode','none')
            drawnow
        end
        if isempty(findobj(get(handles.axes3,'children'),'tag','z_indexLine_in_xz'))
            line([1-0.5 Gv3Dimage_spec.nx+0.5],[Gv3Dslice_index.xy Gv3Dslice_index.xy],'color','g','tag','z_indexLine_in_xz','parent',handles.axes3,'EraseMode','none')
            drawnow
        end
        if isempty(findobj(get(handles.axes3,'children'),'tag','x_indexLine_in_xz'))
            line([Gv3Dslice_index.yz Gv3Dslice_index.yz],[1-0.5 Gv3Dimage_spec.nz+0.5],'color','r','tag','x_indexLine_in_xz','parent',handles.axes3,'EraseMode','none')
            drawnow
        end
        
        % --- added at 2010.12.03
        seleted_panel = get(ancestor(cur_axes_handle,'uipanel'),'tag');
        % save struct - 2011.03.30
        save_struct('seleted_panel',seleted_panel)
    end
    
    
catch%ME
%     disp(ME)
%     disp(ME.stack(1))
%     disp(ME.message)
%     disp(' ')
end




% --------------------------------------------------------------------
function my_delete_All_index_Line(handles)
% added at 2010.12.03

% ------- delete all index lines -----------
cur_axes_handle = get(handles.figure1,'CurrentAxes');

% ------- delete all index lines -----------
cur_axes_handle = get(handles.figure1,'CurrentAxes');

delete(findobj(get(handles.axes2,'children'),'tag','z_indexLine_in_yz'))
delete(findobj(get(handles.axes2,'children'),'tag','y_indexLine_in_yz'))

delete(findobj(get(handles.axes3,'children'),'tag','z_indexLine_in_xz'))
delete(findobj(get(handles.axes3,'children'),'tag','x_indexLine_in_xz'))

delete(findobj(get(handles.axes1,'children'),'tag','x_indexLine_in_xy'))
delete(findobj(get(handles.axes1,'children'),'tag','y_indexLine_in_xy'))

% restore previous axes handle
axes(cur_axes_handle);

% --- added at 2010.12.03
seleted_panel = get(ancestor(cur_axes_handle,'uipanel'),'tag');
% --------------------------------------

save_struct('seleted_panel',seleted_panel)
