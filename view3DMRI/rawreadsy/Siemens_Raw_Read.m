function varargout = Siemens_Raw_Read(varargin)
%SIEMENS_RAW_READ M-file for Siemens_Raw_Read.fig
%      SIEMENS_RAW_READ, by itself, creates a new SIEMENS_RAW_READ or raises the existing
%      singleton*.
%
%      H = SIEMENS_RAW_READ returns the handle to a new SIEMENS_RAW_READ or the handle to
%      the existing singleton*.
%
%      SIEMENS_RAW_READ('Property','Value',...) creates a new SIEMENS_RAW_READ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Siemens_Raw_Read_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SIEMENS_RAW_READ('CALLBACK') and SIEMENS_RAW_READ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SIEMENS_RAW_READ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Siemens_Raw_Read

% Last Modified by GUIDE v2.5 07-Jun-2011 16:15:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Siemens_Raw_Read_OpeningFcn, ...
                   'gui_OutputFcn',  @Siemens_Raw_Read_OutputFcn, ...
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


% --- Executes just before Siemens_Raw_Read is made visible.
function Siemens_Raw_Read_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Siemens_Raw_Read
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%  initialize 
global figHndl;
global image_spec;
global image_spec_MDH;
global mem_err_occured;
global cancel_process;

% global make_comp_im;
% global cut_RO_OS;
% global donotSwapRO;
% global reprocess;
% global donotAvg;
% global make_same_slice_DCM;
% global make_3DwithCoil;
% global useInterleaving;
% global ignore_image_data;
% global donotSaveFullRaw;
% global donotPadZeros;
% global doFFTScaling;
% global gSkipifft4im;
% global gPrereadAllMDH;
% global g3Dradial_ejaCODE;

% make_comp_im = 1;
% donotAvg = 0;
% cut_RO_OS = 1;
% donotSwapRO = 0;
% make_same_slice_DCM = 1;
% make_3DwithCoil = 0;
% useInterleaving = 1;
% ignore_image_data = 0;
% donotSaveFullRaw = 1;
% donotPadZeros = 0;
% doFFTScaling = 0;
% 
% gSkipifft4im = 0;
% gPrereadAllMDH = 0;
% g3Dradial_ejaCODE = 0;
% reprocess = 0;

global filenamecell;
global filename_table_data;
global pathANDfilename_cell;

filenamecell=[];
filename_table_data=[];
pathANDfilename_cell=[];

figHndl = handles;

cancel_process = 0;

mem_err_occured = struct('flag',0,'numfig',0);

image_spec = struct('cp_coil_index',[],'ver',[],'seqFN',[],'protN',[],...
    'TR',[],'TE',[],...
    'filenameSS',[],'pathSS','../','glo_hdr_size',[],...
    'multiSliceMode',[],'multiSliceSeriesMode',[],...
    'ns',[],'thick',[],'FOVpe',[],'FOVro',[],...
    'na',[],'na_db',[],'ne',[],'nset',[],'nseg',[],...
    'nx',[],'ny',[],'nz',[],'nc',[],'nr',[],...
    'ny_res',[],'nz_res',[],'nz_ima',[],...
    'read_os',[],'ny_os',[],'nz_os',[],...
    'nyPF',[],'nzPF',[],'PEPFforSNR',[],...
    'AccelFactPE',[],'AccelFact3D',[],'rawcorr',[],...
    'RO_PE_swapped',[],'Nav_RFtype','empty',...
    'Nav_offset_PE_pixel',[],'Nav_num_zeroPadding_PE',[],'Nav_PE_size',[]);

image_spec_MDH = struct('cp_coil_index',[],'ver',[],...
    'filenameSS',[],'pathSS','../','glo_hdr_size',[],...
    'na',[],'nacq_double',1,'raw_is_avged',0,...
    'ne',[],'ns',[],'nset',[],'nseg',[],...
    'nx',[],'ny',[],'nz',[],'nc',[],'nr',[],...
    'read_os',[],...
    'ny_res',[],'nz_res',[],...
    'RO_pixel_size',[],...
    'PE_pixel_size',[],'Th_pixel_size',[],...
    'PE_pixel_size_original',[],'Th_pixel_size_original',[],...
    'index_y',[],'index_z',[],'mySiemensRead_version','_v',...
    'AccelFactPE',[],'AccelFact3D',[],'rawcorr',[],...
    'RO_PE_swapped',[]);

delete(get(handles.axes_waitbar,'children'));
set(handles.text_processed,'string','0% processed.');
set(handles.text_remaintime,'string','?? remain.');
set(handles.list_info,'string',strvcat('Some ASCII file (.asc) information','wiil be displayed here.'));

set(handles.checkbox_reprocess,'Value',0);
set(handles.checkbox_noAvg,'Value',0);
set(handles.checkbox_cutreados,'Value',1);  % default 'on'
set(handles.checkbox_donotswap,'Value',0);
set(handles.checkbox_makecomp,'Value',1);  % default 'on'
set(handles.checkbox_sameSliceDCM,'Value',1);  % default 'on'
set(handles.checkbox_make3DwithCoil,'Value',0);
set(handles.checkbox_slice_interleave,'Value',1);
set(handles.checkbox_wo_ima,'Value',0);
set(handles.checkbox_donotSaveFullRaw,'Value',1);  % default 'on'
set(handles.checkbox_donotPadZeros,'Value',0);
set(handles.checkbox_zeroPad_kz,'Value',0)
set(handles.checkbox_doFFTScaling,'Value',1);  % default 'on'
set(handles.checkbox_skipfft4im,'Value',0);
set(handles.checkbox_prereadAllMDH,'Value',0);
set(handles.checkbox_3Dradial_ejaCODE,'Value',0);
set(handles.checkbox_nonCart,'Value',0);
set(handles.checkbox_batch,'Value',0);

set(handles.checkbox_skipfft4im,'enable','on')
set(handles.checkbox_prereadAllMDH,'enable','on')
set(handles.checkbox_donotPadZeros,'enable','on')
set(handles.checkbox_zeroPad_kz,'enable','on')
set(handles.checkbox_makecomp,'enable','on')
set(handles.checkbox_batch,'enable','on')

set(handles.pushbutton_view3Dmri,'enable','on')
set(handles.pushbutton_open,'enable','on')
set(handles.pushbutton_openfolder,'enable','on')
set(handles.pushbutton_cancel,'enable','on') % set on for batch - 2011.04.05
set(handles.pushbutton_processing,'enable','off')
set(handles.figure1,'CloseRequestFcn',{@my_closefcn,handles})

if isempty(getappdata(handles.figure1,'h_msgbox_vec'))
    set(handles.pushbutton_closeDoneBox,'enable','off')
end

%---- added at 2011.06.07
% --- close info board - 2010.11.07
info_fig_handle = getappdata(handles.figure1,'info_fig_handle');
if ishandle(info_fig_handle)
    close(info_fig_handle)
end

%---- added at 2011.06.07
% --- close filename_table - 2011.04.05
fntabH = getappdata(handles.figure1,'fntabH');
if ishandle(fntabH)
    close(fntabH)
end


read_logfile;

%--------------------------------------

% UIWAIT makes Siemens_Raw_Read wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Siemens_Raw_Read_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% call back fuctions

% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

my_closefcn;

% --------------------------------------------------------------------
function menu_info_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helpdlg({'Sorry,','Not yet supported!!'},'Help');

% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox({'Siemens Measurement Data Reader ver.9.1',...
    'GUI made by cefca (Sang-Young Zho).',...
    '- Last Modified at 2010.06.16',...
    '- Last Modified at 2010.09.09',...
    '- Last Modified at 2010.10.04',...
    '- Last Modified at 2010.11.02',...
    '- Last Modified at 2010.11.07',...
    '- Last Modified at 2010.11.11',...
    '- Last Modified at 2010.11.12',...
    '- Last Modified at 2010.11.13',...
    '- Last Modified at 2010.12.03',...
    '- Last Modified at 2011.04.06',...
    '- Last Modified at 2011.04.07',...
    '- Last Modified at 2011.06.07',...
    ' ',...
    'Please report me any bugs!!',...
    '    cefca302@gmail.com',...
    ' ',...
    '@copyright Sang-Young Zho, Medical Imaging Lab, Yonsei University'},'Notice','modal');

% --- Executes on selection change in list_info.
function list_info_Callback(hObject, eventdata, handles)
% hObject    handle to list_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_info contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_info


% --- Executes during object creation, after setting all properties.
function list_info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_processing.
function pushbutton_processing_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image_spec;
global cancel_process;
global filenamecell;
global pathANDfilename_cell;

% ------------ make checkbox disable -----------------------
set(handles.checkbox_batch,'enable','off');

if ~iscell(filenamecell)
    set(handles.checkbox_batch,'Value',0)
    drawnow
end


if get(handles.checkbox_batch,'Value')==0
    error_flag = my_processing(image_spec,handles);
    
    if cancel_process==1
        cancel_process = 0;
        return;
    end
else
    set(handles.pushbutton_view3Dmri,'enable','off')
    set(handles.pushbutton_open,'enable','off')
    set(handles.pushbutton_openfolder,'enable','off');
    set(handles.pushbutton_processing,'enable','off')
    set(handles.pushbutton_cancel,'enable','on')
    set(handles.pushbutton_closeDoneBox,'enable','off')
        
    % ------------ get all (17) checkbox state -----------------------
    enable_state_checkbox_makecomp = get(handles.checkbox_makecomp,'enable');
    enable_state_checkbox_cutreados = get(handles.checkbox_cutreados,'enable');
    enable_state_checkbox_donotswap = get(handles.checkbox_donotswap,'enable');
    enable_state_checkbox_reprocess = get(handles.checkbox_reprocess,'enable');
    enable_state_checkbox_noAvg = get(handles.checkbox_noAvg,'enable');
    enable_state_checkbox_sameSliceDCM = get(handles.checkbox_sameSliceDCM,'enable');
    enable_state_checkbox_make3DwithCoil = get(handles.checkbox_make3DwithCoil,'enable');
    enable_state_checkbox_slice_interleave = get(handles.checkbox_slice_interleave,'enable');
    enable_state_checkbox_wo_ima = get(handles.checkbox_wo_ima,'enable');
    enable_state_checkbox_donotSaveFullRaw = get(handles.checkbox_donotSaveFullRaw,'enable');
    enable_state_checkbox_donotPadZeros = get(handles.checkbox_donotPadZeros,'enable');
    enable_state_checkbox_doFFTScaling = get(handles.checkbox_doFFTScaling,'enable');
    enable_state_checkbox_skipfft4im = get(handles.checkbox_skipfft4im,'enable');
    enable_state_checkbox_prereadAllMDH = get(handles.checkbox_prereadAllMDH,'enable');
    enable_state_checkbox_3Dradial_ejaCODE = get(handles.checkbox_3Dradial_ejaCODE,'enable');
    enable_state_checkbox_zeroPad_kz = get(handles.checkbox_zeroPad_kz,'enable');
    enable_state_checkbox_nonCart = get(handles.checkbox_nonCart,'enable');
    % ----------------------------------------------
    
    Nfname = length(filenamecell);
    for n=1:Nfname
        temp = filenamecell{n};
        
        if ~isempty(pathANDfilename_cell)
            image_spec.pathSS = pathANDfilename_cell{n,1};
        end
        
        my_open_meas_dat(temp,image_spec.pathSS,handles)
        my_update_filename_table(handles,n,true,false) % no action when set to 0,1
        
        error_flag = my_processing(image_spec,handles);
        
        if error_flag==0
            my_update_filename_table(handles,n,true,true) % no action when set to 0,1
        end
        
        if cancel_process==1
            break;
        end
    end
    
    if cancel_process==1
        cancel_process = 0;
    else
        h_msgbox = msgbox(strvcat('End batch process',' ','All Done!'),'SEE ME');
        % --- save msgbox handle to close  - 2010.11.07
        h_msgbox_vec = getappdata(handles.figure1,'h_msgbox_vec');
        h_msgbox_vec = [h_msgbox_vec; h_msgbox];
        setappdata(handles.figure1,'h_msgbox_vec',h_msgbox_vec)
    end
    set(handles.pushbutton_closeDoneBox,'enable','on')
    
    
    set(handles.pushbutton_view3Dmri,'enable','on')
    set(handles.pushbutton_open,'enable','on')
    set(handles.pushbutton_openfolder,'enable','on');
    set(handles.pushbutton_processing,'enable','on')
    set(handles.pushbutton_cancel,'enable','off')
    set(handles.pushbutton_closeDoneBox,'enable','on')
    
    % ------------ restore all (17) checkbox state -----------------------
    set(handles.checkbox_makecomp,'enable',enable_state_checkbox_makecomp);
    set(handles.checkbox_cutreados,'enable',enable_state_checkbox_cutreados);
    set(handles.checkbox_donotswap,'enable',enable_state_checkbox_donotswap);
    set(handles.checkbox_reprocess,'enable',enable_state_checkbox_reprocess);
    set(handles.checkbox_noAvg,'enable',enable_state_checkbox_noAvg);
    set(handles.checkbox_sameSliceDCM,'enable',enable_state_checkbox_sameSliceDCM);
    set(handles.checkbox_make3DwithCoil,'enable',enable_state_checkbox_make3DwithCoil);
    set(handles.checkbox_slice_interleave,'enable',enable_state_checkbox_slice_interleave);
    set(handles.checkbox_wo_ima,'enable',enable_state_checkbox_wo_ima);
    set(handles.checkbox_donotSaveFullRaw,'enable',enable_state_checkbox_donotSaveFullRaw);
    set(handles.checkbox_donotPadZeros,'enable',enable_state_checkbox_donotPadZeros);
    set(handles.checkbox_doFFTScaling,'enable',enable_state_checkbox_doFFTScaling);
    set(handles.checkbox_skipfft4im,'enable',enable_state_checkbox_skipfft4im);
    set(handles.checkbox_prereadAllMDH,'enable',enable_state_checkbox_prereadAllMDH);
    set(handles.checkbox_3Dradial_ejaCODE,'enable',enable_state_checkbox_3Dradial_ejaCODE);
    set(handles.checkbox_zeroPad_kz,'enable',enable_state_checkbox_zeroPad_kz);
    set(handles.checkbox_nonCart,'enable',enable_state_checkbox_nonCart);
    % ----------------------------------------------
    
end


% ------------ make checkbox enable -----------------------
set(handles.checkbox_batch,'enable','on');


% --- Executes on button press in pushbutton_view3Dmri.
function pushbutton_view3Dmri_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view3Dmri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% !view3Dmri_2007b_v7_wip_win32 &
try
    view3Dmri
catch
    disp('view3Dmri is not supported.')
end

% --- Executes on button press in pushbutton_open.
function pushbutton_open_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image_spec;
global filenamecell;
global pathANDfilename_cell;

pathANDfilename_cell = [];

delete(get(handles.axes_waitbar,'children'));
set(handles.text_processed,'string','0% processed.');
set(handles.text_remaintime,'string','?? remain.');

% set(handles.pushbutton_cancel,'enable','on')
% ------------ make checkbox disable -----------------------
set(handles.checkbox_batch,'enable','off');
set(handles.pushbutton_open,'enable','off');
set(handles.pushbutton_openfolder,'enable','off');


% include filename - modified at 2010.11.12
% add '.dat' to filename - 2011.04.06
if isempty(image_spec.filenameSS)
    default_path = [image_spec.pathSS, image_spec.filenameSS];
else
    default_path = [image_spec.pathSS, [image_spec.filenameSS,'.dat']];
end

if get(handles.checkbox_batch,'Value')==0
    
    % --- close filename_table - 2011.04.05
    fntabH = getappdata(handles.figure1,'fntabH');
    if ishandle(fntabH)
        close(fntabH)
    end

    [temp pathnameSS] = uigetfile({'*.dat','Measurement files (*.dat)'},...
        'Open Measurement file',default_path);
    
    if isequal(temp,0)
        set(handles.checkbox_batch,'enable','on');
        set(handles.pushbutton_open,'enable','on');
        set(handles.pushbutton_openfolder,'enable','on');
        disp('Files are not selected');
        return;
    end
    
    my_open_meas_dat(temp,pathnameSS,handles);
    

else
    
    [filenamecell pathnameSS] = uigetfile({'*.dat','Measurement files (*.dat)'},...
        'Open Measurement file',default_path,'MultiSelect', 'on');
    
    if isequal(filenamecell,0)
        set(handles.checkbox_batch,'enable','on');
        set(handles.pushbutton_open,'enable','on');
        set(handles.pushbutton_openfolder,'enable','on');
        if isempty(image_spec.filenameSS)
            set(handles.pushbutton_processing,'enable','off');
        end
        disp('Files are not selected');
        return;
    end
    
    image_spec.pathSS = pathnameSS;
    write_logfile;
    
    if ~iscell(filenamecell)
        filenamecell = {filenamecell};
    end

    my_init_filename_table(handles)
    
    set(handles.text2,'string',[num2str(length(filenamecell)),' .dat files are selected in ''',pathnameSS,'']);
    
    set(handles.pushbutton_processing,'enable','on');
end


set(handles.pushbutton_cancel,'enable','on')
set(handles.pushbutton_open,'enable','on');
set(handles.pushbutton_openfolder,'enable','on');

% --- Executes on button press in checkbox_makecomp.
function checkbox_makecomp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_makecomp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_makecomp


function my_closefcn(hObject, eventdata, handles)


write_logfile;

% --- close msgbox until opened  - 2010.11.07
h_msgbox_vec = getappdata(handles.figure1,'h_msgbox_vec');
for n=1:length(h_msgbox_vec)
    if ishandle(h_msgbox_vec(n))
        close(h_msgbox_vec(n))
    end
end

% --- close info board - 2010.11.07
info_fig_handle = getappdata(handles.figure1,'info_fig_handle');
if ishandle(info_fig_handle)
    close(info_fig_handle)
end

% --- close filename_table - 2011.04.05
fntabH = getappdata(handles.figure1,'fntabH');
if ishandle(fntabH)
    close(fntabH)
end

fprintf('\n\nExit from : Siemens_Raw_Read_sy.\n\n')

fclose all;
closereq;

function write_logfile

global image_spec;

if isempty(image_spec.pathSS) || strcmp(image_spec.pathSS,'../')
    return;
end

fid = fopen(['./' 'LogfileSRR.log'],'w');

log_content = ['DAT path = ',image_spec.pathSS,...
    char(13),char(10)];   % carrige return and newline

if fid~=-1
    fwrite(fid,char(log_content),'char');
    fclose(fid);
end


function read_logfile

global image_spec;

fid = fopen(['./' 'LogfileSRR.log'],'r');

if fid~=-1
    log_cont = fread(fid,'char');
    fclose(fid);

    % Input strings must have one row.
    log_cont = char(log_cont');
    
    asc_path = findAsc(log_cont,'DAT path',' = ');

    if ~isempty(asc_path) && isdir(asc_path)
        image_spec.pathSS = asc_path;
    end

end


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cancel_process;

cancel_process = 1;

if  strcmp(get(handles.checkbox_batch,'enable'),'off')
    set(handles.checkbox_batch,'enable','on')
end

% --- Executes on button press in checkbox_cutreados.
function checkbox_cutreados_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_cutreados (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_cutreados


% --------------------------------------------------------------------
function menu_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_open_Callback(hObject, eventdata, handles)


% --- Executes on button press in checkbox_donotswap.
function checkbox_donotswap_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_donotswap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_donotswap


% --- Executes on button press in checkbox_reprocess.
function checkbox_reprocess_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_reprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_reprocess


% --- Executes on button press in checkbox_noAvg.
function checkbox_noAvg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_noAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_noAvg


% --- Executes on button press in checkbox_sameSliceDCM.
function checkbox_sameSliceDCM_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sameSliceDCM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sameSliceDCM


% --- Executes on button press in checkbox_make3DwithCoil.
function checkbox_make3DwithCoil_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_make3DwithCoil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_make3DwithCoil


% --- Executes on button press in checkbox_slice_interleave.
function checkbox_slice_interleave_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_slice_interleave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_slice_interleave


% --- Executes on button press in checkbox_wo_ima.
function checkbox_wo_ima_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_wo_ima (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_wo_ima


% --- Executes on button press in checkbox_donotSaveFullRaw.
function checkbox_donotSaveFullRaw_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_donotSaveFullRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_donotSaveFullRaw


% --- Executes on button press in checkbox_donotPadZeros.
function checkbox_donotPadZeros_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_donotPadZeros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_donotPadZeros


% --- Executes on button press in checkbox_doFFTScaling.
function checkbox_doFFTScaling_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_doFFTScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_doFFTScaling


% --- Executes on button press in checkbox_skipfft4im.
function checkbox_skipfft4im_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_skipfft4im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_skipfft4im

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    
    set(handles.checkbox_makecomp,'Value',0)
    set(handles.checkbox_makecomp,'enable','off')

else
	% Checkbox is not checked-take approriate action

    set(handles.checkbox_makecomp,'Value',1)
    set(handles.checkbox_makecomp,'enable','on')

end

% --- Executes on button press in checkbox_prereadAllMDH.
function checkbox_prereadAllMDH_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_prereadAllMDH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_prereadAllMDH


% --- Executes on button press in checkbox_3Dradial_ejaCODE.
function checkbox_3Dradial_ejaCODE_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_3Dradial_ejaCODE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_3Dradial_ejaCODE

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action
    

    set(handles.checkbox_skipfft4im,'Value',1)
    set(handles.checkbox_skipfft4im,'enable','off')
    set(handles.checkbox_prereadAllMDH,'Value',1)
    set(handles.checkbox_prereadAllMDH,'enable','off')
    set(handles.checkbox_donotPadZeros,'Value',1)
    set(handles.checkbox_donotPadZeros,'enable','off')
    set(handles.checkbox_makecomp,'Value',0)
    set(handles.checkbox_makecomp,'enable','off')
    
    set(handles.checkbox_nonCart,'Value',1)
    set(handles.checkbox_nonCart,'enable','off')
    
    set(handles.checkbox_zeroPad_kz,'Value',0)
    set(handles.checkbox_zeroPad_kz,'enable','off')
    
else
	% Checkbox is not checked-take approriate action

    set(handles.checkbox_skipfft4im,'Value',0)
    set(handles.checkbox_skipfft4im,'enable','on')
    set(handles.checkbox_prereadAllMDH,'Value',0)
    set(handles.checkbox_prereadAllMDH,'enable','on')
    set(handles.checkbox_donotPadZeros,'Value',0)
    set(handles.checkbox_donotPadZeros,'enable','on')
    set(handles.checkbox_makecomp,'Value',1)
    set(handles.checkbox_makecomp,'enable','on')
    
    set(handles.checkbox_nonCart,'Value',0)
    set(handles.checkbox_nonCart,'enable','on')
    
    set(handles.checkbox_zeroPad_kz,'Value',0)
    set(handles.checkbox_zeroPad_kz,'enable','on')
   
    
end


% --- Executes on button press in checkbox_nonCart.
function checkbox_nonCart_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_nonCart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_nonCart

if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action

    set(handles.checkbox_skipfft4im,'Value',1)
    set(handles.checkbox_skipfft4im,'enable','off')
    set(handles.checkbox_donotPadZeros,'Value',1)
    set(handles.checkbox_donotPadZeros,'enable','off')
    set(handles.checkbox_makecomp,'Value',0)
    set(handles.checkbox_makecomp,'enable','off')
else
	% Checkbox is not checked-take approriate action

    set(handles.checkbox_skipfft4im,'Value',0)
    set(handles.checkbox_skipfft4im,'enable','on')
    set(handles.checkbox_donotPadZeros,'Value',0)
    set(handles.checkbox_donotPadZeros,'enable','on')
    set(handles.checkbox_makecomp,'Value',1)
    set(handles.checkbox_makecomp,'enable','on')
end


% --- Executes on button press in pushbutton_closeDoneBox.
function pushbutton_closeDoneBox_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_closeDoneBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- close msgbox currently opened  - 2010.11.07
h_msgbox_vec = getappdata(handles.figure1,'h_msgbox_vec');
for n=1:length(h_msgbox_vec)
    if ishandle(h_msgbox_vec(n))
        close(h_msgbox_vec(n))
    end
end
% init handle data
setappdata(handles.figure1,'h_msgbox_vec',[]);

set(handles.pushbutton_closeDoneBox,'enable','off')


% --- Executes on button press in checkbox_zeroPad_kz.
function checkbox_zeroPad_kz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_zeroPad_kz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_zeroPad_kz
if (get(hObject,'Value') == get(hObject,'Max'))
	% Checkbox is checked-take approriate action

    set(handles.checkbox_donotPadZeros,'Value',1)
    set(handles.checkbox_donotPadZeros,'enable','off')
else
	% Checkbox is not checked-take approriate action

    if get(handles.checkbox_nonCart,'Value')==0
        set(handles.checkbox_donotPadZeros,'Value',0)
        set(handles.checkbox_donotPadZeros,'enable','on')
    end
end


%% call back fuctions 2

function error_flag = my_processing(image_spec,handles)
% at 2011.04.05

global cancel_process;

error_flag = 1;

set(handles.text_processed,'string','0% processed.');
set(handles.text_remaintime,'string','?? remain.');

delete(get(handles.axes_waitbar,'children'));

if get(handles.checkbox_batch,'Value')==0
    
    set(handles.pushbutton_view3Dmri,'enable','off')
    set(handles.pushbutton_open,'enable','off')
    set(handles.pushbutton_openfolder,'enable','off');
    set(handles.pushbutton_processing,'enable','off')
    set(handles.pushbutton_cancel,'enable','on')
    set(handles.pushbutton_closeDoneBox,'enable','off')
    
    
    % ------------ get all (17) checkbox state -----------------------
    enable_state_checkbox_makecomp = get(handles.checkbox_makecomp,'enable');
    enable_state_checkbox_cutreados = get(handles.checkbox_cutreados,'enable');
    enable_state_checkbox_donotswap = get(handles.checkbox_donotswap,'enable');
    enable_state_checkbox_reprocess = get(handles.checkbox_reprocess,'enable');
    enable_state_checkbox_noAvg = get(handles.checkbox_noAvg,'enable');
    enable_state_checkbox_sameSliceDCM = get(handles.checkbox_sameSliceDCM,'enable');
    enable_state_checkbox_make3DwithCoil = get(handles.checkbox_make3DwithCoil,'enable');
    enable_state_checkbox_slice_interleave = get(handles.checkbox_slice_interleave,'enable');
    enable_state_checkbox_wo_ima = get(handles.checkbox_wo_ima,'enable');
    enable_state_checkbox_donotSaveFullRaw = get(handles.checkbox_donotSaveFullRaw,'enable');
    enable_state_checkbox_donotPadZeros = get(handles.checkbox_donotPadZeros,'enable');
    enable_state_checkbox_doFFTScaling = get(handles.checkbox_doFFTScaling,'enable');
    enable_state_checkbox_skipfft4im = get(handles.checkbox_skipfft4im,'enable');
    enable_state_checkbox_prereadAllMDH = get(handles.checkbox_prereadAllMDH,'enable');
    enable_state_checkbox_3Dradial_ejaCODE = get(handles.checkbox_3Dradial_ejaCODE,'enable');
    enable_state_checkbox_zeroPad_kz = get(handles.checkbox_zeroPad_kz,'enable');
    enable_state_checkbox_nonCart = get(handles.checkbox_nonCart,'enable');
    % ----------------------------------------------
end

% ------------ make all (17) checkbox disable -----------------------
set(handles.checkbox_makecomp,'enable','off');
set(handles.checkbox_cutreados,'enable','off');
set(handles.checkbox_donotswap,'enable','off');
set(handles.checkbox_reprocess,'enable','off');
set(handles.checkbox_noAvg,'enable','off');
set(handles.checkbox_sameSliceDCM,'enable','off');
set(handles.checkbox_make3DwithCoil,'enable','off');
set(handles.checkbox_slice_interleave,'enable','off');
set(handles.checkbox_wo_ima,'enable','off');
set(handles.checkbox_donotSaveFullRaw,'enable','off');
set(handles.checkbox_donotPadZeros,'enable','off');
set(handles.checkbox_doFFTScaling,'enable','off');
set(handles.checkbox_skipfft4im,'enable','off');
set(handles.checkbox_prereadAllMDH,'enable','off');
set(handles.checkbox_3Dradial_ejaCODE,'enable','off');
set(handles.checkbox_zeroPad_kz,'enable','off');
set(handles.checkbox_nonCart,'enable','off');
% ----------------------------------------------

drawnow;

try
    
    mySiemensRead_v7(image_spec,handles);
    
    if cancel_process
        h_msgbox = msgbox('Process Canceled!','SEE ME');
        % --- save msgbox handle to close  - 2010.11.07
        h_msgbox_vec = getappdata(handles.figure1,'h_msgbox_vec');
        h_msgbox_vec = [h_msgbox_vec; h_msgbox];
        setappdata(handles.figure1,'h_msgbox_vec',h_msgbox_vec)
        set(handles.pushbutton_closeDoneBox,'enable','on')

%         cancel_process = 0;
        dispetime(toc,0);
    else
        if get(handles.checkbox_batch,'Value')==0
            
            h_msgbox = msgbox(strvcat([image_spec.filenameSS,'.dat'],' ','All Done!'),'SEE ME');
            % --- save msgbox handle to close  - 2010.11.07
            h_msgbox_vec = getappdata(handles.figure1,'h_msgbox_vec');
            h_msgbox_vec = [h_msgbox_vec; h_msgbox];
            setappdata(handles.figure1,'h_msgbox_vec',h_msgbox_vec)
            set(handles.pushbutton_closeDoneBox,'enable','on')
        end
    end
    
    if get(handles.checkbox_batch,'Value')==0
        
        set(handles.pushbutton_view3Dmri,'enable','on')
        set(handles.pushbutton_open,'enable','on')
        set(handles.pushbutton_openfolder,'enable','on');
        set(handles.pushbutton_processing,'enable','on')
        set(handles.pushbutton_cancel,'enable','off')
        set(handles.pushbutton_closeDoneBox,'enable','on')
        
        % ------------ restore all (17) checkbox state -----------------------
        set(handles.checkbox_makecomp,'enable',enable_state_checkbox_makecomp);
        set(handles.checkbox_cutreados,'enable',enable_state_checkbox_cutreados);
        set(handles.checkbox_donotswap,'enable',enable_state_checkbox_donotswap);
        set(handles.checkbox_reprocess,'enable',enable_state_checkbox_reprocess);
        set(handles.checkbox_noAvg,'enable',enable_state_checkbox_noAvg);
        set(handles.checkbox_sameSliceDCM,'enable',enable_state_checkbox_sameSliceDCM);
        set(handles.checkbox_make3DwithCoil,'enable',enable_state_checkbox_make3DwithCoil);
        set(handles.checkbox_slice_interleave,'enable',enable_state_checkbox_slice_interleave);
        set(handles.checkbox_wo_ima,'enable',enable_state_checkbox_wo_ima);
        set(handles.checkbox_donotSaveFullRaw,'enable',enable_state_checkbox_donotSaveFullRaw);
        set(handles.checkbox_donotPadZeros,'enable',enable_state_checkbox_donotPadZeros);
        set(handles.checkbox_doFFTScaling,'enable',enable_state_checkbox_doFFTScaling);
        set(handles.checkbox_skipfft4im,'enable',enable_state_checkbox_skipfft4im);
        set(handles.checkbox_prereadAllMDH,'enable',enable_state_checkbox_prereadAllMDH);
        set(handles.checkbox_3Dradial_ejaCODE,'enable',enable_state_checkbox_3Dradial_ejaCODE);
        set(handles.checkbox_zeroPad_kz,'enable',enable_state_checkbox_zeroPad_kz);
        set(handles.checkbox_nonCart,'enable',enable_state_checkbox_nonCart);
        % ----------------------------------------------
    end

    error_flag = 0;
    
catch ME
    disp(' ')
    disp(ME)
    disp(ME.message)
    disp(ME.stack(1))
    disp('Unexpected error has occured.')
    
    err = lasterror;
    fprintf('Last error ...\n')
    disp('-------------------------------------')
    fprintf('\t message: %s\n',err.message)
    fprintf('\t identifier: %s\n',err.identifier)
    fprintf('\t stack: ')
    disp(err.stack)
    disp(' ')
    disp('-------------------------------------')
    
    dispetime(toc,0);

    set(handles.text_processed,'string','Error has occured..');
    
    % remove flickering info_board in batch process - 2011.04.07
    info_fig_handle = getappdata(handles.figure1,'info_fig_handle');
    if isempty(info_fig_handle) || ~ishandle(info_fig_handle)
        info_fig_handle = info_board;
        % --- save info board handle to close  - 2010.11.07
        setappdata(handles.figure1,'info_fig_handle',info_fig_handle)
    end

    disp2infoboard(info_fig_handle,' ')
    disp2infoboard(info_fig_handle,'Error has occured..');
    disp2infoboard(info_fig_handle,' ')
    
    h_msgbox = msgbox({'Error has occurred!'},'SEE ME');
    % --- save msgbox handle to close  - 2010.11.07
    h_msgbox_vec = getappdata(handles.figure1,'h_msgbox_vec');
    h_msgbox_vec = [h_msgbox_vec; h_msgbox];
    setappdata(handles.figure1,'h_msgbox_vec',h_msgbox_vec)
    set(handles.pushbutton_closeDoneBox,'enable','on')
    
   
end


function my_open_meas_dat(temp,pathnameSS,handles)
% at 2011.04.05

global image_spec;

image_spec.pathSS = pathnameSS;
write_logfile;

% change white space separator to _
idx =strfind(temp,' ');
temp_new = temp;
temp_new(idx)='_';
% change file name
if ~strcmp(temp,temp_new)
%     movefile([pathnameSS,'/',temp],[pathnameSS,'/',temp_new],'f'); % ----> slow in big file
    eval(['!ren ',pathnameSS,'"',temp,'" "',temp_new,'"']); % ----> window system
end
temp = temp_new;

%-- remove automatically added '.mat'
% -- added at 2010.04.19 - again 2010.11.13
index_jum_mat = strfind(temp,'.dat');
if length(index_jum_mat)>1
    temp(index_jum_mat(2):end) = [];
end

% cut extension
filenameSS = temp(1:length(temp)-4);

image_spec.filenameSS = filenameSS;


%% read global header size in (.out or .dat) file

fid = fopen([pathnameSS filenameSS '.dat'],'r');

if fid==-1
    disp('Unable open file.')
    return;
end

% read global header size in first 4 bytes
glob_hdr_size = fread(fid,1,'int32');
fclose(fid);

%% make header files

% exe_ehe(filenameSS,pathnameSS);


header_extracter(filenameSS,pathnameSS);



%% get ACSII data
fid = fopen([pathnameSS filenameSS,'.asc'],'r');
asc = fread(fid,'char');
fclose(fid);

asc = char(asc');

%% extract info from header (asc)
sep_text = ' = ';

%--------------------------- find system version
text_ver = 'sProtConsistencyInfo.tBaselineString ';
ver = char(findAsc(asc,text_ver,sep_text));

%--------------------------- find seq file name
text_seqFN = 'tSequenceFileName ';
seqFN = char(findAsc(asc,text_seqFN,sep_text));

%--------------------------- find protocol name
text_protN = 'tProtocolName ';
protN = char(findAsc(asc,text_protN,sep_text));

%--------------------------- find TR
text_TR = 'alTR[0] ';
TR = str2double(findAsc(asc,text_TR,sep_text));
TR = TR/1000; % to ms

%--------------------------- find TE
text_TE = 'alTE[0] ';
TE = str2double(findAsc(asc,text_TE,sep_text));
TE = TE/1000; % to ms

%--------------------------- find multislice mode
text_multiSliceMode = 'sKSpace.ucMultiSliceMode ';
multiSliceMode = findAsc(asc,text_multiSliceMode,sep_text);

%---- predefined mode in SeqDeines.h
%   enum MultiSliceMode
%   {
%     MSM_SEQUENTIAL  = 0x01,
%     MSM_INTERLEAVED = 0x02,
%     MSM_SINGLESHOT  = 0x04
%   };
if isempty(multiSliceMode)
    multiSliceMode = 'No info.';
else
    switch multiSliceMode(1:min(4,end))
        case {'0x1','0x01'}
            multiSliceMode = 'MSM_SEQUENTIAL';
        case {'0x2','0x02'}
            multiSliceMode = 'MSM_INTERLEAVED';
        case {'0x4','0x04'}
            multiSliceMode = 'MSM_SINGLESHOT';
    end
end

%--------------------------- find multislice series mode
text_multiSliceSeriesMode = 'sSliceArray.ucMode ';
multiSliceSeriesMode = findAsc(asc,text_multiSliceSeriesMode,sep_text);

%---- predefined mode in SeqDeines.h
%   enum SeriesMode
%   {
%     ASCENDING   = 0x01,
%     DESCENDING  = 0x02,
%     INTERLEAVED = 0x04, 
%     AUTOMATIC   = 0x08,
%     APEXTOBASE  = 0x10,
%     BASETOAPEX  = 0x20
%   };
if isempty(text_multiSliceSeriesMode)
    multiSliceSeriesMode = 'No info.';
else
    switch multiSliceSeriesMode(1:min(4,end))
        case {'0x1','0x01'}
            multiSliceSeriesMode = 'ASCENDING';
        case {'0x2','0x02'}
            multiSliceSeriesMode = 'DESCENDING';
        case {'0x4','0x04'}
            multiSliceSeriesMode = 'INTERLEAVED';
        case {'0x8','0x08'}
            multiSliceSeriesMode = 'AUTOMATIC';
        case '0x10'
            multiSliceSeriesMode = 'APEXTOBASE';
        case '0x20'
            multiSliceSeriesMode = 'BASETOAPEX';
    end
end


%--------------------------- find ns
text_ns = 'sSliceArray.lSize ';
ns = str2double(findAsc(asc,text_ns,sep_text));

%--------------------------- find FOV
thick = zeros(ns,1);
FOVpe = zeros(ns,1);
FOVro = zeros(ns,1);
info_FOV= '';

for n=0:ns-1
    text_thick = ['sSliceArray.asSlice[',num2str(n),'].dThickness '];
    text_FOVpe = ['sSliceArray.asSlice[',num2str(n),'].dPhaseFOV '];
    text_FOVro = ['sSliceArray.asSlice[',num2str(n),'].dReadoutFOV '];
    thick(n+1) = str2double(findAsc(asc,text_thick,sep_text));
    FOVpe(n+1) = str2double(findAsc(asc,text_FOVpe,sep_text));
    FOVro(n+1) = str2double(findAsc(asc,text_FOVro,sep_text));
    
    info_FOV = strvcat(info_FOV,...
        [text_thick,sep_text,num2str(thick(n+1)),' (mm)'],...
        [text_FOVpe,sep_text,num2str(FOVpe(n+1)),' (mm)'],...
        [text_FOVro,sep_text,num2str(FOVro(n+1)),' (mm)']);
end

%--------------------------- find nx
text_nx = 'sKSpace.lBaseResolution ';
nx = str2double(findAsc(asc,text_nx,sep_text));

%--------------------------- find na (average)
text_na = 'lAverages ';
na = str2double(findAsc(asc,text_na,sep_text));

%--------------------------- find na (average double)
text_na_db = 'dAveragesDouble ';
na_db = str2double(findAsc(asc,text_na_db,sep_text));

%--------------------------- find na (average double)
text_nr = 'lRepetitions ';
nr = str2double(findAsc(asc,text_nr,sep_text));

%--------------------------- find ny
text_ny = 'sKSpace.lPhaseEncodingLines ';
ny = str2double(findAsc(asc,text_ny,sep_text));

%--------------------------- find nz
text_nz = 'sKSpace.lPartitions ';
nz = str2double(findAsc(asc,text_nz,sep_text));

%--------------------------- find nz_ima
text_nz_ima = 'sKSpace.lImagesPerSlab ';
nz_ima = str2double(findAsc(asc,text_nz_ima,sep_text));

%--------------------------- find PE resolution
text_ny_res = 'sKSpace.dPhaseResolution ';
ny_res = str2double(findAsc(asc,text_ny_res,sep_text));

%--------------------------- find slice resolution
text_nz_res = 'sKSpace.dSliceResolution ';
nz_res = str2double(findAsc(asc,text_nz_res,sep_text));

%--------------------------- find PE oversampling
text_ny_os = 'sKSpace.dPhaseOversamplingForDialog ';
ny_os = str2double(findAsc(asc,text_ny_os,sep_text));

if isempty(ny_os)
    ny_os = 0;
end

%--------------------------- find slice oversampling
text_nz_os = 'sKSpace.dSliceOversamplingForDialog ';
nz_os = str2double(findAsc(asc,text_nz_os,sep_text));

if isempty(nz_os)
    nz_os = 0;
end

%--------------------------- find PE PF
text_nyPF = 'sKSpace.ucPhasePartialFourier ';
nyPF = findAsc(asc,text_nyPF,sep_text);

%---- predefined mode in SeqDeines.h
% enum PartialFourierFactor
%   {
%     PF_HALF = 0x01,
%     PF_5_8  = 0x02,
%     PF_6_8  = 0x04,
%     PF_7_8  = 0x08,
%     PF_OFF  = 0x10,
%     PF_AUTO = 0x20
%   };
if isempty(nyPF)
    nyPF = 'No info.';
else
    switch nyPF(1:min(4,end))
        case {'0x1','0x01'}
            nyPF = 'PF_HALF';
        case {'0x2','0x02'}
            nyPF = 'PF_5_8';
        case {'0x4','0x04'}
            nyPF = 'PF_6_8';
        case {'0x8','0x08'}
            nyPF = 'PF_7_8';
        case '0x10'
            nyPF = 'PF_OFF';
        case '0x20'
            nyPF = 'PF_AUTO';
    end
end
%--------------------------- find slice PF
text_nzPF = 'sKSpace.ucSlicePartialFourier ';
nzPF = findAsc(asc,text_nzPF,sep_text);

%---- predefined mode in SeqDeines.h
% enum PartialFourierFactor
%   {
%     PF_HALF = 0x01,
%     PF_5_8  = 0x02,
%     PF_6_8  = 0x04,
%     PF_7_8  = 0x08,
%     PF_OFF  = 0x10,
%     PF_AUTO = 0x20
%   };
if isempty(nzPF)
    nzPF = 'No info.';
else
    switch nzPF(1:min(4,end))
        case {'0x1','0x01'}
            nzPF = 'PF_HALF';
        case {'0x2','0x02'}
            nzPF = 'PF_5_8';
        case {'0x4','0x04'}
            nzPF = 'PF_6_8';
        case {'0x8','0x08'}
            nzPF = 'PF_7_8';
        case '0x10'
            nzPF = 'PF_OFF';
        case '0x20'
            nzPF = 'PF_AUTO';
    end
end

%--------------------------- find PE PF for SNR
text_PEPFforSNR = 'sKSpace.dSeqPhasePartialFourierForSNR ';
PEPFforSNR = str2double(findAsc(asc,text_PEPFforSNR,sep_text));

%--------------------------- find nc
% text_nc = 'iMaxNoOfRxChannels';
text_nc = '].lRxChannelConnected';
% text_nc =  '.asList[*].lRxChannel ';
nc_vec = str2double(findAsc(asc,text_nc,sep_text));
% nc=length(nc_vec);
nc = max(nc_vec);

%--------------------------- find ne
text_ne = 'lContrasts ';
ne = str2double(findAsc(asc,text_ne,sep_text));

%--------------------------- find AccelFactPE
text_AccelFactPE = 'sPat.lAccelFactPE ';
AccelFactPE = str2double(findAsc(asc,text_AccelFactPE,sep_text));

if isempty(AccelFactPE)
    AccelFactPE = 1;
end

% -------- find refLinePE
disp_text_RefLinesPE = '';
if AccelFactPE>1
    text_RefLinesPE = 'sPat.lRefLinesPE ';
    RefLinesPE = str2double(findAsc(asc,text_RefLinesPE,sep_text));
    disp_text_RefLinesPE = [text_RefLinesPE,sep_text,num2str(RefLinesPE)];
end

%--------------------------- find sPat.lAccelFact3D
text_AccelFact3D = 'sPat.lAccelFact3D ';
AccelFact3D = str2double(findAsc(asc,text_AccelFact3D,sep_text));

if isempty(AccelFact3D)
    AccelFact3D = 1;
end

% -------- find refLine3D
disp_text_RefLines3D = '';
if AccelFact3D>1
    text_RefLines3D = 'sPat.lRefLines3D ';
    RefLines3D = str2double(findAsc(asc,text_RefLines3D,sep_text));
    disp_text_RefLines3D = [text_RefLines3D,sep_text,num2str(RefLines3D)];
end

%--------------------------- find readout os factor
text_read_os = 'flReadoutOSFactor ';
read_os_temp = str2double(findAsc(asc,text_read_os,sep_text));

if isempty(read_os_temp)
    text_read_os = 'flReadoutOSFactor (Not found.) default';
    read_os = 2;    % default
else
    read_os = read_os_temp;
end

%--------------------------- find turbo factor for TSE
text_nseg = 'sFastImaging.lTurboFactor ';
nseg = str2double(findAsc(asc,text_nseg,sep_text));

%--------------------------- find magnetic field strength
% text_B0 = 'flMagneticFieldStrength';
text_B0 = 'flNominalB0 ';
B0 = char(findAsc(asc,text_B0,sep_text));

%------------------ get PC info
text_angio = 'sAngio';
angio = char(findAsc(asc,text_angio,'.'));

%% get reference coil (CP) index

cp_coil_text = '].sCoilElementID.tElement ';
cp_coil_cell = findAsc(asc,cp_coil_text,sep_text);
is_cp_coil_cell = strfind(cp_coil_cell,'CP');

cp_coil_index = 0;
for n=1:nc
    if iscell(is_cp_coil_cell) && ~isempty(is_cp_coil_cell{n})
        cp_coil_index = n;
        break;
    end
end

if cp_coil_index>0
    cp_coil_info = 'CP coil index';
else
    cp_coil_info = 'CP coil index (Not found.)';
end

%% get Navigator info

text_Nav_RFtype = 'sNavigatorPara.ucRFPulseType ';
Nav_RFtype = char(findAsc(asc,text_Nav_RFtype,sep_text));

if ~isempty(Nav_RFtype)
%---- predefined mode in SeqDeines.h
% %       enum PulseMode
% %   {
% %     EXCIT_MODE_2D_PENCIL            = 0x1,      // The timing used is a 2D-pencil-excitation
% %     EXCIT_MODE_GRE                  = 0x2,      // The timing used is a gradient-echo sequence
% %     EXCIT_MODE_EPI                  = 0x4,      // The timing uses a EPI sequence
% %     EXCIT_MODE_CROSSED_PAIR         = 0x8,      // Two crossed slices with 90 and 180 degree excitations, forming a spin-echo where the slices intersect
% %     EXCIT_MODE_2D_PENCIL_CARDIAC    = 0x10      // The timing used is a 2D-pencil-excitation for cardiac appls
% % 
% %   };
    switch Nav_RFtype
        case '0x1'
            Nav_RFtype_str = '2D_PENCIL';
            Nav_RFtype_str_description = '- The timing used is a 2D-pencil-excitation';
        case '0x2'
            Nav_RFtype_str = 'GRE : 2D PACE';
            Nav_RFtype_str_description = '- The timing used is a gradient-echo sequence';
        case '0x4'
            Nav_RFtype_str = 'EPI';
            Nav_RFtype_str_description = '- The timing uses a EPI sequence';
        case '0x8'
            Nav_RFtype_str = 'CROSSED_PAIR';
            Nav_RFtype_str_description = '- Two crossed slices with 90 and 180 degree excitations, forming a spin-echo where the slices intersect';
        case '0x10'
            Nav_RFtype_str = '2D_PENCIL_CARDIAC';
            Nav_RFtype_str_description = '- The timing used is a 2D-pencil-excitation for cardiac appls';
    end
    
    % -- only consider about 2D PACE
    if strcmp(Nav_RFtype,'0x2')
        text_Nav0_pos_Sag = 'sNavigatorArray.asElm[0].sCuboid.sPosition.dSag';
        Nav0_pos_Sag = str2double(findAsc(asc,text_Nav0_pos_Sag,sep_text));
        text_Nav0_pos_Tra = 'sNavigatorArray.asElm[0].sCuboid.sPosition.dTra';
        Nav0_pos_Tra = str2double(findAsc(asc,text_Nav0_pos_Tra,sep_text));
        text_Nav0_pos_Cor = 'sNavigatorArray.asElm[0].sCuboid.sPosition.dCor';
        Nav0_pos_Cor = str2double(findAsc(asc,text_Nav0_pos_Cor,sep_text));
        
        text_Nav1_pos_Sag = 'sNavigatorArray.asElm[1].sCuboid.sPosition.dSag';
        Nav1_pos_Sag = str2double(findAsc(asc,text_Nav1_pos_Sag,sep_text));
        text_Nav1_pos_Tra = 'sNavigatorArray.asElm[1].sCuboid.sPosition.dTra';
        Nav1_pos_Tra = str2double(findAsc(asc,text_Nav1_pos_Tra,sep_text));
        text_Nav1_pos_Cor = 'sNavigatorArray.asElm[1].sCuboid.sPosition.dCor';
        Nav1_pos_Cor = str2double(findAsc(asc,text_Nav1_pos_Cor,sep_text));
        
        text_Nav0_FOVpe = 'sNavigatorArray.asElm[0].sCuboid.dPhaseFOV';
        Nav0_FOVpe = str2double(findAsc(asc,text_Nav0_FOVpe,sep_text));
        text_Nav0_FOVro = 'sNavigatorArray.asElm[0].sCuboid.dReadoutFOV';
        Nav0_FOVro = str2double(findAsc(asc,text_Nav0_FOVro,sep_text));
        
        text_Nav1_FOVpe = 'sNavigatorArray.asElm[1].sCuboid.dPhaseFOV';
        Nav1_FOVpe = str2double(findAsc(asc,text_Nav1_FOVpe,sep_text));
        text_Nav1_FOVro = 'sNavigatorArray.asElm[1].sCuboid.dReadoutFOV';
        Nav1_FOVro = str2double(findAsc(asc,text_Nav1_FOVro,sep_text));
        
        Nav_offset = [Nav1_pos_Sag - Nav0_pos_Sag,...
            Nav1_pos_Tra - Nav0_pos_Tra,...
            Nav1_pos_Cor - Nav0_pos_Cor];
        
        Nav_offset_PE_mm = Nav_offset(Nav_offset~=0);
        
        %-- Nav_1_FOV_PE is multiple of 32mm
        % Nav has 12 PE lines and assume it has 32mm resolution 
        % (not 256/12 mm) -->  no need zeros padding
        %--------
        %------> NOTE : NAV has  42.6733 mm resolution from Gradient calculation
        %--------------- but several data shows that 32mm res results more high SNR
        %---- sum up the 2 lines? : No;;
        % -- 데이터마다 바꾸기;;
        
        % ------- 2009.12.08 - find out
        % ------- Nav_1_FOV_PE is multiple of 32mm
        % ------- NAV has  42.6733 mm resolution from Gradient calculation
        % ------- 42.6733 mm * 12 lines = 512.0796 (FOV PE)
        % ------- 512 mm / 32 mm = 16 lines
        % ------- conclude : zero padding
        Nav_offset_PE_pixel = round(Nav_offset_PE_mm/32);
        
        %-- number of used PE lines in Nav ROI
        Nav_PE_size = round(Nav1_FOVpe/32);

    end
    
end



%% view info and save spec


% do not make cell array of string !!
% which make code complicate
info_list = strvcat([filenameSS,'.asc'],...
    ' ',...
    [text_ver,sep_text,ver],...
    [text_seqFN,sep_text,seqFN],...
    [text_protN,sep_text,protN],...
    [text_B0,sep_text,B0],...
    [text_TR,sep_text,num2str(TR),' (ms)'],...
    [text_TE,sep_text,num2str(TE),' (ms)'],...
    ' ',...
    ['Max ',text_nc,sep_text,num2str(nc)],...
    [text_ne,sep_text,num2str(ne)],...
    [text_na,sep_text,num2str(na)],...
    [text_na_db,sep_text,num2str(na_db)],...
    [text_nr,sep_text,num2str(nr)],...
    [text_nseg,sep_text,num2str(nseg)],...
    ' ',...
    [text_ns,sep_text,num2str(ns)],...
    [text_multiSliceMode,sep_text,multiSliceMode],...
    [text_multiSliceSeriesMode,sep_text,multiSliceSeriesMode],...
    info_FOV,...
    ' ',...
    [text_nx,sep_text,num2str(nx)],...
    [text_ny,sep_text,num2str(ny)],...    
    [text_nz,sep_text,num2str(nz)],...
    [text_nz_ima,sep_text,num2str(nz_ima)],...
    ' ',...
    [text_ny_res,sep_text,num2str(ny_res)],...
    [text_nz_res,sep_text,num2str(nz_res)],...
    [text_ny_os,sep_text,num2str(ny_os)],...
    [text_nz_os,sep_text,num2str(nz_os)],...
    ' ',...
    [text_nyPF,sep_text,nyPF],...
    [text_nzPF,sep_text,nzPF],...
    [text_PEPFforSNR,sep_text,num2str(PEPFforSNR)],...
    ' ',...    
    [text_read_os,sep_text,num2str(read_os)],...
    [cp_coil_info,sep_text,num2str(cp_coil_index)],...
    [text_AccelFactPE,sep_text,num2str(AccelFactPE)],...
    disp_text_RefLinesPE,...
    [text_AccelFact3D,sep_text,num2str(AccelFact3D)],...
    disp_text_RefLines3D,...
    ' ',...
    strcat(text_angio,'.',angio));


info_list = strvcat(info_list,...
    ' ',...
    ['global header size : ',num2str(glob_hdr_size),...
    ' (in fisrt 4 bytes of .dat file)']);

image_spec.Nav_RFtype = 'empty';
if ~isempty(Nav_RFtype)
    info_list = strvcat(info_list,...
        ' ',...
        ['Navgator type = ',Nav_RFtype_str],...
        Nav_RFtype_str_description,...
        ['----------------------------------------------------------']);
    
    image_spec.Nav_RFtype = Nav_RFtype;
    
    if strcmp(Nav_RFtype,'0x2')
        info_list = strvcat(info_list,...
            [text_Nav0_pos_Sag,sep_text,num2str(Nav0_pos_Sag)],...
            [text_Nav0_pos_Tra,sep_text,num2str(Nav0_pos_Tra)],...
            [text_Nav0_pos_Cor,sep_text,num2str(Nav0_pos_Cor)],...
            [text_Nav0_FOVpe,sep_text,num2str(Nav0_FOVpe)],...
            [text_Nav0_FOVro,sep_text,num2str(Nav0_FOVro)],...
            ' ',...
            [text_Nav1_pos_Sag,sep_text,num2str(Nav1_pos_Sag)],...
            [text_Nav1_pos_Tra,sep_text,num2str(Nav1_pos_Tra)],...
            [text_Nav1_pos_Cor,sep_text,num2str(Nav1_pos_Cor)],...
            [text_Nav1_FOVpe,sep_text,num2str(Nav1_FOVpe)],...
            [text_Nav1_FOVro,sep_text,num2str(Nav1_FOVro)]);
        
        image_spec.Nav_offset_PE_pixel = Nav_offset_PE_pixel;
% % %         image_spec.Nav_num_zeroPadding_PE = Nav_num_zeroPadding_PE;
        image_spec.Nav_PE_size = Nav_PE_size;
    end
end

if isempty(image_spec.Nav_offset_PE_pixel)
    image_spec.Nav_offset_PE_pixel = 0;
% % %     image_spec.Nav_num_zeroPadding_PE = 0;
    image_spec.Nav_PE_size = 1;
end

image_spec.glo_hdr_size = glob_hdr_size;

image_spec.na = na;
image_spec.na_db = na_db;
image_spec.nr = nr;

image_spec.ver = ver;
image_spec.seqFN = seqFN;
image_spec.protN = protN;
image_spec.cp_coil_index = cp_coil_index;

image_spec.multiSliceMode = multiSliceMode;
image_spec.multiSliceSeriesMode = multiSliceSeriesMode;
image_spec.ns = ns;
image_spec.thick = thick(1);
image_spec.FOVpe = FOVpe(1);
image_spec.FOVro = FOVro(1);

image_spec.TR = TR;
image_spec.TE = TE;

image_spec.nx = nx;
image_spec.ny = ny;
image_spec.nz = nz;
image_spec.nz_ima = nz_ima;
image_spec.ny_res = ny_res;
image_spec.nz_res = nz_res;
image_spec.ny_os = ny_os;
image_spec.nz_os = nz_os;
image_spec.nyPF = nyPF;
image_spec.nzPF = nzPF;
image_spec.PEPFforSNR = PEPFforSNR;

image_spec.nc = nc;
image_spec.ne = ne;
image_spec.nseg = nseg;
image_spec.read_os = read_os;
image_spec.AccelFactPE = AccelFactPE;
image_spec.AccelFact3D = AccelFact3D;


set(handles.list_info,'string',info_list);

set(handles.pushbutton_processing,'enable','on');
% set(handles.text2,'string',[num2str(ns),' slice found.']);
set(handles.text2,'string',[filenameSS,'.dat']);

%% get meas.evp data
fid = fopen([pathnameSS,'evp_header/', filenameSS,'.evp'],'r');
evp = fread(fid,'char');
fclose(fid);

evp = char(evp');

%% extract rawdata correction factor from meas.evp

% datafor_rawcorr_str = ['            <ParamDouble."dRawDataCorrectionFactorRe"> ',...
%     char(13),char(10),...
%     '            {',...
%     char(13),char(10),...
%     '              <Precision> 6 ',...
%     char(13),char(10),...
%     '            }',...
%     char(13),char(10),...
%     '            ',...
%     char(13),char(10),...
%     '            <ParamDouble."dRawDataCorrectionFactorIm"> ',...
%     char(13),char(10),...
%     '            {',...
%     char(13),char(10),...
%     '              <Precision> 6 ',...
%     char(13),char(10),...
%     '            }',...
%     char(13),char(10),...
%     '          }',...
%     char(13),char(10),...
%     '          { }',...
%     char(13),char(10),...
%     '          ',...
%     char(13),char(10),...
%     '        }',...
%     char(13),char(10),...
%     '        { <MinSize> 1  <MaxSize> 1000000000'];

% below is text file that saved above info DON'T EDIT THIS FILE!
fid_temp = fopen('rawdatacorr.donotedit','r');
datafor_rawcorr_str = fread(fid_temp,'char');
fclose(fid_temp);
datafor_rawcorr_str = char(datafor_rawcorr_str');

% find string until '{' and newline
rawcorr_str = findAsc(evp,datafor_rawcorr_str,'{');


if isempty(rawcorr_str) % avoid error
    rawcorr_num = ones(nc+5,2);
else
    
    % ------ remove or change following string
    idx = strfind(rawcorr_str,'{');
    rawcorr_str(idx) = '';

    idx = strfind(rawcorr_str,' ');
    rawcorr_str(idx) = '';

    idx = strfind(rawcorr_str,'}');
    rawcorr_str(idx) = char(10);
    % ----------------------------

    % seperate string 2 mat using mystrtok(str,delimiter,is_num)
    rawcorr_num = mystrtok(rawcorr_str,char(10),1);
    rawcorr_num(isnan(rawcorr_num)) = [];

    % reshape to easy readable mat
    if rawcorr_num(2)==1
        % if dRawDataCorrectionFactorRe==1, dRawDataCorrectionFactorIm =[]
        % rawcorr_num(1,:) = dFFTScale
        % rawcorr_num(2,:) = dRawDataCorrectionFactorRe
        rawcorr_num = reshape(rawcorr_num,2,[]);
    else
        % rawcorr_num(1,:) = dFFTScale
        % rawcorr_num(2,:) = dRawDataCorrectionFactorRe
        % rawcorr_num(3,:) = dRawDataCorrectionFactorIm
        rawcorr_num = reshape(rawcorr_num,3,[]);
        rawcorr_num(2,:) = rawcorr_num(2,:)+1i*rawcorr_num(3,:);
        rawcorr_num(3,:) = [];
    end
    rawcorr_num = rawcorr_num.';
end

disp('Correction factor :')
disp('   FFTscale          RawDataCorrection')
disp(rawcorr_num)
disp('Ready to Processing !')

% remove flickering info_board in batch process - 2011.04.07
info_fig_handle = getappdata(handles.figure1,'info_fig_handle');
if isempty(info_fig_handle) || ~ishandle(info_fig_handle)
    info_fig_handle = info_board;
    % --- save info board handle to close  - 2010.11.07
    setappdata(handles.figure1,'info_fig_handle',info_fig_handle)
end

disp2infoboard(info_fig_handle,'=============================================================')
disp2infoboard(info_fig_handle,pathnameSS)
disp2infoboard(info_fig_handle,[filenameSS,'.dat'])
disp2infoboard(info_fig_handle,'=============================================================')
disp2infoboard(info_fig_handle,info_list)
disp2infoboard(info_fig_handle,' ')
disp2infoboard(info_fig_handle,'Correction factor :')
disp2infoboard(info_fig_handle,'   FFTscale          RawDataCorrection')
disp2infoboard(info_fig_handle,num2str(rawcorr_num))
disp2infoboard(info_fig_handle,' ')
disp2infoboard(info_fig_handle,'Ready to Processing !')
disp2infoboard(info_fig_handle,' ')


image_spec.rawcorr = rawcorr_num;

%% set init after reopen

set(handles.pushbutton_processing,'enable','on')

set(handles.text_processed,'string','0% processed.');
delete(get(handles.axes_waitbar,'children'));

if get(handles.checkbox_batch,'Value')==0
    % focus figure
    figure(handles.figure1)
end


% --- Executes on button press in checkbox_batch.
function checkbox_batch_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_batch


function my_init_filename_table(handles)
% initialize filename_table
% table Data should be cell
% 
% at 2011.04.05

global filenamecell;
global filename_table_data;
global pathANDfilename_cell;

fntabH = filename_table;

% --- save filename_table handle to close  - 2011.04.05
setappdata(handles.figure1,'fntabH',fntabH)

h=findobj(fntabH,'tag','uitable1');

Nfname = length(filenamecell);

filename_table_data = cell(Nfname,4);
for n=1:Nfname
    if ~isempty(pathANDfilename_cell)
        filename_table_data{n,1} = pathANDfilename_cell{n,1};
    end
    filename_table_data{n,2} = filenamecell{n};
    filename_table_data{n,3} = false; % no action when set to 0,1
    filename_table_data{n,4} = false; % no action when set to 0,1
end

set(h,'data',filename_table_data)


function my_update_filename_table(handles,fname_id,flag_header,flag_process)
% table Data should be cell
% logical format should be 'true' or 'false', not 0,1
% logical format: flag_header,flag_process -> true, false
% 
% at 2011.04.05

global filename_table_data;

% --- load filename_table handle to close  - 2011.04.05
fntabH = getappdata(handles.figure1,'fntabH');

if isempty(fntabH) || ~ishandle(fntabH)
    fntabH = filename_table;
    % --- save filename_table handle to close  - 2011.04.05
    setappdata(handles.figure1,'fntabH',fntabH)
end

    
h=findobj(fntabH,'tag','uitable1');

filename_table_data{fname_id,3} = flag_header; % no action when set to 0,1
filename_table_data{fname_id,4} = flag_process; % no action when set to 0,1

set(h,'data',filename_table_data)


% --- Executes on button press in pushbutton_openfolder.
function pushbutton_openfolder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_openfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% added at 2011.06.07
global image_spec;
global filenamecell;
global pathANDfilename_cell;

delete(get(handles.axes_waitbar,'children'));
set(handles.text_processed,'string','0% processed.');
set(handles.text_remaintime,'string','?? remain.');

% set(handles.pushbutton_cancel,'enable','on')
% ------------ make checkbox disable -----------------------
set(handles.checkbox_batch,'enable','off');
set(handles.pushbutton_open,'enable','off');
set(handles.pushbutton_openfolder,'enable','off');

set(handles.checkbox_batch,'Value',1)

dname=uigetdir(image_spec.pathSS);

if isequal(dname,0)
    set(handles.checkbox_batch,'enable','on');
    set(handles.pushbutton_open,'enable','on');
    set(handles.pushbutton_openfolder,'enable','on');
    if isempty(image_spec.filenameSS)
        set(handles.pushbutton_processing,'enable','off');
    end
    disp('Folders are not selected');
    return;
end

image_spec.filenameSS = [];

set(handles.text2,'string','Finding .dat files...');
drawnow

pathANDfilename_cell = my_find_ooo_files(dname,'dat',[]);
filenamecell = pathANDfilename_cell(:,2);

set(handles.text2,'string',[num2str(size(pathANDfilename_cell,1)),' .dat files found in ''',dname,'']);
drawnow

my_init_filename_table(handles)

image_spec.pathSS = dname;
write_logfile;

set(handles.checkbox_batch,'enable','on');
set(handles.pushbutton_open,'enable','on');
set(handles.pushbutton_openfolder,'enable','on');
set(handles.pushbutton_processing,'enable','on');
set(handles.pushbutton_cancel,'enable','on')
