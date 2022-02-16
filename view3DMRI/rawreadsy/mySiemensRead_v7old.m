function mySiemensRead_v7(image_spec)
%% Information
% Only works in conventional 2D(3D)FT sequence
% 
% Coded by cefca (Sang-Young Zho).
% All rights reserved in MI laboratory.
% Last modified at 2009.05.31
% 
% 
% acq_indic 저장하는 것을 preallocating 하지 않으면 매우 느려짐
% raw data는 preallocating 하지 않아도 별차이 없음
% {ny,nz,ns,na} 만 cell로, 나머진 matrix로
% 
% segment index 수정
% pixel size (resolution) 고려
% consider FFTscale factor
% phase index
% separate acqiusition
%
% ---------- Futher work todo
% 
%      
%     NOTE : Navigator image processing is almost done.

tic;
mySiemensRead_version = 'mySiemensRead_v7()';
fprintf('\n%s\n',mySiemensRead_version)

%% set parameter

global image_spec_MDH;
global make_comp_im;
global cut_RO_OS;
global sMDH;
global figHndl;
global cancel_process;
global make_comp_needed_memory_size_byte;
global donotSwapRO;
global reprocess;
global donotAvg;
global make_same_slice_DCM;
global make_3DwithCoil;

mdh = 128; % measurement data header (byte) -> fixed
glob_hdr = image_spec.glo_hdr_size;   % global header in byte (found .out file)

filenameSS = image_spec.filenameSS;
pathnameSS = image_spec.pathSS;
image_spec_MDH.filenameSS = filenameSS;
image_spec_MDH.pathSS = pathnameSS;

rawcorr = image_spec.rawcorr;

cp_coil_index = image_spec.cp_coil_index;   % did not consider this
ver = image_spec.ver;


%% reodrder multislice (get slice order info)
% for more information about slice ordering,
% refer MrProtSliceSeries.h
% in    Z:\n4\pkg\MrServers\MrProtSrv\MrProt\

if strcmp(image_spec.multiSliceMode,'MSM_INTERLEAVED')
    if ~mod(image_spec.ns,2)% if even # of slices & ...interleaved ?
        org_s = [2:2:image_spec.ns,1:2:image_spec.ns].';
    else % if odd # of slices
        org_s = (1:image_spec.ns).'; % 맞나?
    end
else
    org_s = (1:image_spec.ns).';
end


%% open .out file

fid = fopen([pathnameSS filenameSS '.dat'],'r');

%% check file size

fseek(fid,0,'eof');
file_size = ftell(fid);
disp(' ')
disp(['File Size = ',num2str(file_size),' Bytes'])

%% MDH based recon - don't care memory

initMDH;

fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)

%% define some data variable

raw = single([]);   % image raw data
avg_cell = uint16([]); % to save acqusition index

navRT_image = single([]);   % series of navgator echo image RTFEEDBACK
navRT_image_trig_before_cell = single([]);   % series of navgator echo image RTFEEDBACK before triggering
navRT_image_trig_after_cell = single([]);   % series of navgator echo image RTFEEDBACK before triggering
temp_navRT_image = single([]);

noise_data = single([]);    % noise data
navRT_data = single([]);  % navgator echo data RTFEEDBACK
navHP_data = single([]);  % navgator echo data HPFEEDBACK
refphstabscan_data = single([]);    % reference phase stabilization scan data
phstabscan_data = single([]);    % phase stabilization scan data

% sync_data = single([]); % readout contains synchroneous data
sync_data = cell(65536,1); % readout contains synchroneous data

phcor_data_cell = single([]); % phase correction data

%--- user defiend data -------------------------------------------------
% that is projection line in TSE sequence if sMDH.aushFreePara(1) == 302
projLine_raw_cell = single([]);
%-----------------------------------------------------------------------


% timeTReff = single([]); % save each TReff for PACE
timeTReff = cell(65536,1); % save each TReff for PACE
timeTReff_info = strvcat('TReff for PACE',...
    '1st column : PMU time stamp difference',...
    '2nd column : Δtime (ms)');
timeTReff_info_4excel = {'ΔPMU time stamp','Δtime (ms)'};
beginTimeTReff = single([]);
endTimeTReff = single([]);

% time_btwShot_Nav = single([]); % save time between image sequence and following Nav
time_btwShot_Nav = cell(65536,1); % save time between image sequence and following Nav
time_btwShot_Nav_info = strvcat('time between image sequence and following Nav',...
    '1st column : PMU time stamp difference',...
    '2nd column : Δtime (ms)');
time_btwShot_Nav_info_4excel = {'ΔPMU time stamp','Δtime (ms)'};
endTimeShot = single([]);
startTimeShot = single([]);
beginTimeNav = single([]);

% seg_indic = uint32([]);
% save segment index for 1 coil and 1 acqusition and 1 repetition
% and 1 phase
seg_indic_info = strvcat('[seg_indic] matrix has',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : echo train index',...
    '5th column : segment index',...
    '6th column : set index',...
    '7th column : ky (PE) index',...
    '8th column : kz (PE) index',...
    '9th column : slice   index');
seg_indic_info_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'echo train','segment','set','ky','kz','slice'};
nseg_column = 5;

% seg_indic_4s1 = uint32([]);
% save segment index for 1 coil and 1 acqusition and 1 repetition
% and 1 phase
% and 1 slice
seg_indic_info_4s1 = strvcat('[seg_indic_4s1] matrix has (for 1 slice)',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : echo train index',...
    '5th column : segment index',...
    '6th column : set index',...
    '7th column : ky (PE) index',...
    '8th column : kz (PE) index');
seg_indic_info_4s1_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'echo train','segment','set','ky','kz'};

% acq_indic = uint32([]);
% save acq index for TSE for 1 coil and 1 repetition
acq_indic_info = strvcat('[acq_indic] matrix has',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : echo train index',...
    '5th column : segment index',...
    '6th column : set index',...
    '7th column : acq index',...
    '8th column : ky (PE) index',...
    '9th column : kz (PE) index',...
    '10th column : slice   index');
acq_indic_info_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'echo train','segment','set','acq','ky','kz','slice'};

% whole_acq_indic = uint32([]);
whole_acq_indic_info = strvcat('[whole_acq_indic] matrix has',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : coil index',...
    '5th column : echo train index',...
    '6th column : segment index',...
    '7th column : phase index',...
    '8th column : set index',...
    '9th column : repetition index',...
    '10th column : acq index',...
    '11th column : ky (PE) index',...
    '12th column : kz (PE) index',...
    '13th column : slice   index');
whole_acq_indic_info_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'coil','echo train','segment','phase','set','repetition','acq','ky','kz','slice'};


%% EvalInfoMask - dragged from MdhProxy.h in IDEA

% /*--------------------------------------------------------------------------*/
% /*  Definition of EvalInfoMask:                                             */
% /*--------------------------------------------------------------------------*/
MDH_ACQEND            = 0 +1;
MDH_RTFEEDBACK        = 1 +1;
MDH_HPFEEDBACK        = 2 +1;
MDH_ONLINE            = 3 +1;
MDH_OFFLINE           = 4 +1;
MDH_SYNCDATA          = 5 +1;       % // readout contains synchroneous data
MDH_LASTSCANINCONCAT  = 8 +1;       % // Flag for last scan in concatination

MDH_RAWDATACORRECTION = 10 +1;      % // Correct the rawadata with the rawdata correction factor
MDH_LASTSCANINMEAS    = 11 +1;      % // Flag for last scan in measurement
MDH_SCANSCALEFACTOR   = 12 +1;      % // Flag for scan specific additional scale factor
MDH_2NDHADAMARPULSE   = 13 +1;      % // 2nd RF exitation of HADAMAR
MDH_REFPHASESTABSCAN  = 14 +1;      % // reference phase stabilization scan         
MDH_PHASESTABSCAN     = 15 +1;      % // phase stabilization scan
MDH_D3FFT             = 16 +1;      % // execute 3D FFT         
MDH_SIGNREV           = 17 +1;      % // sign reversal
MDH_PHASEFFT          = 18 +1;      % // execute phase fft     
MDH_SWAPPED           = 19 +1;      % // swapped phase/readout direction
MDH_POSTSHAREDLINE    = 20 +1;      % // shared line               
MDH_PHASCOR           = 21 +1;      % // phase correction data    
MDH_PATREFSCAN        = 22 +1;      % // additonal scan for PAT reference line/partition
MDH_PATREFANDIMASCAN  = 23 +1;      % // additonal scan for PAT reference line/partition that is also used as image scan
MDH_REFLECT           = 24 +1;      % // reflect line              
MDH_NOISEADJSCAN      = 25 +1;      % // noise adjust scan --> Not used in NUM4        
MDH_SHARENOW          = 26 +1;      % // all lines are acquired from the actual and previous e.g. phases
MDH_LASTMEASUREDLINE  = 27 +1;      % // indicates that the current line is the last measured line of all succeeding e.g. phases
MDH_FIRSTSCANINSLICE  = 28 +1;      % // indicates first scan in slice (needed for time stamps)
MDH_LASTSCANINSLICE   = 29 +1;      % // indicates  last scan in slice (needed for time stamps)
MDH_TREFFECTIVEBEGIN  = 30 +1;      % // indicates the begin time stamp for TReff (triggered measurement)
MDH_TREFFECTIVEEND    = 31 +1;      % // indicates the   end time stamp for TReff (triggered measurement)

MDH_FIRST_SCAN_IN_BLADE       = 40 -31;  % // Marks the first line of a blade
MDH_LAST_SCAN_IN_BLADE        = 41 -31;  % // Marks the last line of a blade
MDH_LAST_BLADE_IN_TR          = 42 -31;  % // Set for all lines of the last BLADE in each TR interval

MDH_RETRO_LASTPHASE           = 45 -31;  % // Marks the last phase in a heartbeat
MDH_RETRO_ENDOFMEAS           = 46 -31;  % // Marks an ADC at the end of the measurement
MDH_RETRO_REPEATTHISHEARTBEAT = 47 -31;  % // Repeat the current heartbeat when this bit is found
MDH_RETRO_REPEATPREVHEARTBEAT = 48 -31;  % // Repeat the previous heartbeat when this bit is found
MDH_RETRO_ABORTSCANNOW        = 49 -31;  % // Just abort everything
MDH_RETRO_LASTHEARTBEAT       = 50 -31;  % // This adc is from the last heartbeat (a dummy)
MDH_RETRO_DUMMYSCAN           = 51 -31;  % // This adc is just a dummy scan, throw it away
MDH_RETRO_ARRDETDISABLED      = 52 -31;  % // Disable all arrhythmia detection when this bit is found

%% considered EIM

% const MdhBitField MDH_ACQEND            ((unsigned long)0);
% const MdhBitField MDH_RTFEEDBACK        (1);
% const MdhBitField MDH_HPFEEDBACK        (2);
% const MdhBitField MDH_SYNCDATA          (5);       // readout contains synchroneous data
% const MdhBitField MDH_RAWDATACORRECTION (10);      // Correct the rawadata with the rawdata correction factor
% const MdhBitField MDH_REFPHASESTABSCAN  (14);      // reference phase stabilization scan
% const MdhBitField MDH_PHASESTABSCAN     (15);      // phase stabilization scan
% const MdhBitField MDH_SIGNREV           (17);      // sign reversal
% const MdhBitField MDH_PHASEFFT          (18);      // execute phase fft
% const MdhBitField MDH_SWAPPED           (19);      // swapped phase/readout direction
% const MdhBitField MDH_PHASCOR           (21);      // phase correction data    
% const MdhBitField MDH_REFLECT           (24);      // reflect line
% const MdhBitField MDH_NOISEADJSCAN      (25);      // noise adjust scan --> Not used in NUM4

% const MdhBitField MDH_TREFFECTIVEBEGIN  (30);      // indicates the begin time stamp for TReff (triggered measurement)
% const MdhBitField MDH_TREFFECTIVEEND    (31);      // indicates the   end time stamp for TReff (triggered measurement)

%% considered MDH

%   'aulEvalInfoMask',zeros(1,MDH_NUMBEROFEVALINFOMASK),...   %% unsigned long  evaluation info mask field                        8
%   'ushUsedChannels',0,...                                   %% unsigned short # of channels used in scan                        2   =32
%   'ushSamplesInScan',0,...                                  %% unsigned short # of samples acquired in scan                     2
%   'sLC',sLoopCounter,...                                    %% loop counters                                                    28  =60
%   'sCutOff',sCutOffData,...                                 %% cut-off values                                                   4
%   'ushKSpaceCentreColumn',0,...                             %% unsigned short centre of echo                                    2
%   'ushKSpaceCentreLineNo',0,...                             %% unsigned short number of K-space centre line                     2
%   'ushKSpaceCentrePartitionNo',0,...                        %% unsigned short number of K-space centre partition                2
%   'ulChannelId',0,...                                       %% unsigned short	 channel Id must be the last parameter          2

%   'ulPMUTimeStamp',0,...                                    %% unsigned long  PMU time stamp [2.5 ms ticks since last trigger]  4

%   'aushFreePara',zeros(1,MDH_FREEHDRPARA),...               %% unsigned short free parameter                          4 * 2 =   8   

%% check saved full raw before processing

set(figHndl.text2,'string','Checking saved raw,,,');
drawnow

if donotAvg
    flag_avged_full_raw = [];
else
    flag_avged_full_raw = '_avged';
end

PathFIleName_of_saved_full_raw_file = [pathnameSS,'Raw_Data_VB15/',filenameSS,...
    '_full_raw',flag_avged_full_raw,'.mat'];

fid_full_raw = fopen(PathFIleName_of_saved_full_raw_file);
exist_full_raw_file = (fid_full_raw~=-1); % no file -> 0


if exist_full_raw_file
    %----- check mySiemensRead_version - added at 2009.05.27
    % get variable names in a file
    varnames = who('-file', PathFIleName_of_saved_full_raw_file);    
    
    same_mySiemensRead_version = 0;
    
    for n = 1:length(varnames)
        if strcmp(varnames{n},'mySiemensRead_version')
            temp = load(PathFIleName_of_saved_full_raw_file,'mySiemensRead_version');
            mySiemensRead_version_inFile = temp.mySiemensRead_version;
            same_mySiemensRead_version = strcmp(mySiemensRead_version_inFile,mySiemensRead_version);
        end
    end
end

if exist_full_raw_file && ~reprocess && ~same_mySiemensRead_version
    
    fclose(fid_full_raw);
    disp('--------------------------------')
    disp('Processed full-raw data is exist.')
    disp(['But different version of : ',mySiemensRead_version])
    disp('Processing should be redo.')
    disp('--------------------------------')
end

if exist_full_raw_file && ~reprocess && same_mySiemensRead_version
        
    fclose(fid_full_raw);
    disp('--------------------------------')
    disp('Processed full-raw data is exist.')
    disp(['And same version of : ',mySiemensRead_version])
    disp('Just save to seperate files.')
    disp('--------------------------------')
    disp('Loading full-raw data...')

    set(figHndl.text2,'string','Loading saved raw,,,');

    set(figHndl.pushbutton_cancel,'enable','off')
    drawnow;

    if donotAvg
        flag_avged_full_raw = [];
    else
        flag_avged_full_raw = '_avged';
    end
    % full_raw has
    % 'raw','image_spec_MDH','image_spec','raw_info_text'
    load(PathFIleName_of_saved_full_raw_file);
    disp('Done!')

    set(figHndl.pushbutton_cancel,'enable','on')

    axes(figHndl.axes_waitbar);
    % ----------------- waitbar -----------------
    set(figHndl.text_processed,'string',...
        '100% processed.');

    xpatch = [0 100 100 0];
    ypatch = [0 0 1 1];

    patch(xpatch,ypatch,'b','EdgeColor','b'); %,'EraseMode','none');
    drawnow;
    % ------------------------------------------------
    
    disp(raw_info_text)
    
    assignin('base','image_spec_MDH',image_spec_MDH)
    assignin('base','image_spec',image_spec)
    assignin('base','raw_info_text',raw_info_text)

    set(figHndl.text2,'string',[filenameSS,'.dat']);

    drawnow;
    save_RawimaComp

    disp('=========================================================================')
    % eval('dispetime(toc,0);','disp(''Total ''),toc')
    dispetime(toc,0);
    disp('=========================================================================')

    fclose(fid);
    return;
end

set(figHndl.text2,'string',[filenameSS,'.dat']);
drawnow

%% <<< Procsessing some MDH and preallocating some variables>>>
% 
set(figHndl.text2,'string','Reading some MDHs...');
drawnow

disp('----------------------------------')
disp('Reading some MDH and preallocating some variables...')

processed_line = 0;
t1 = clock;

axes(figHndl.axes_waitbar);


nx = [];
nc = [];

readMDHsome(fid);
while isempty(nx)

    cur_nx = sMDH.ushSamplesInScan;
    
    % % read ADC data -> saved column vector
%     temp = single(fread(fid,cur_nx*2,'float32'));  % *2 -> real and imag data

    % skip (ADC data) from cof (Current position in file) in [Byte]
    fseek(fid,cur_nx*2*4,'cof');  % *4 -> float32


    % ---------- save ADC data to different variable -----------------
    % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    % if don't know, use above default structure

    % noise data
    % structure : (ny,nx,nc)
    if bitget(sMDH.aulEvalInfoMask(1),MDH_NOISEADJSCAN)
%         noise_data(cur_y,:,cur_c) = temp;

        % phase correction data
        % structure : {nphase,nset,nr,ne,ns,na} [ny,nx,nz,nc]
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_PHASCOR)
%         phcor_data_cell{cur_phase,cur_set,cur_r,cur_e,cur_s,cur_a}(cur_y,:,cur_z,cur_c) = temp;
        
        
        % synchroneous data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_SYNCDATA)
% %         sync_data(cur_y,:,cur_z,cur_c,...
% %             cur_s,cur_e,cur_r,cur_set) = temp;
%         sync_data = [sync_data,temp];   % i found this flag in %AdjustSeq%/AdjCoilSensSeq

        % reference phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_REFPHASESTABSCAN)
%         refphstabscan_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_PHASESTABSCAN)
%         phstabscan_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data HPFEEDBACK
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_HPFEEDBACK)
%         navHP_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data RTFEEDBACK
        % structure : (ny,nx,nc)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_RTFEEDBACK)
%         navRT_data(cur_y,:,cur_c) = temp;

        % image raw data
        % structure : {ny,nz,na} [nx,ns,ne,nr,nset,nphase,nc]
        % NOTE : this structure is most effective memory savings when considering
        % zero-padding AND for double valued average factor
    else
        cur_c = sMDH.ulChannelId+1;
        
        % seperate each coil to cell to avoid 'Out of Memory'
        if cur_c ~= cp_coil_index    % did not include CP coil
           
            %------- get larger index -----------------
            nx = cur_nx;
            nc = sMDH.ushUsedChannels;
            %-------------------------------------------
            
        end

    end % end of save ADC data to different variable -----------------

    
    processed_line = processed_line+1;
    
    if mod(processed_line,1024)==0
        % ----------------- waitbar -----------------
        processed_byte = ftell(fid);
        processed_byte_percent = processed_byte/file_size*100;
        
        % set text of % processed
        set(figHndl.text_processed,'string',...
            [num2str(processed_byte_percent,'%.2f'),'% processed.']);
        
        % set text of remaining time
        remaining_time_sec = (100-processed_byte_percent)*etime(clock, t1)/processed_byte_percent;
        remaining_time_min = floor(remaining_time_sec/60);
        
        set(figHndl.text_remaintime,'string',...
            sprintf('%d:%2.2fs remain.',remaining_time_min,remaining_time_sec-remaining_time_min*60));
        
        
        xpatch = [0 processed_byte_percent processed_byte_percent 0];
        ypatch = [0 0 1 1];
        
        % ----- draw patch to <figHndl.axes_waitbar>
        patch(xpatch,ypatch,'b','EdgeColor','b','parent',figHndl.axes_waitbar); %,'EraseMode','none');
        drawnow;
        % ------------------------------------------------
    end % end of processed lines
        
    
    if cancel_process
        disp('Processing canceled.')
        fclose(fid);
        return;
    end

    readMDHsome(fid);   % read MDH before next loop
end


disp('Some MDH read.')
fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)
dispetime(clock,t1);

set(figHndl.text2,'string',[filenameSS,'.dat']);
drawnow

% ----- preallocating some variables --------------
% estimate # of acq
number_of_whole_acq = round(file_size/(nx*2*4));
number_of_acq = round(number_of_whole_acq/nc);

seg_indic = cell(number_of_acq,1);
seg_indic_4s1 = cell(number_of_acq,1);
acq_indic = cell(number_of_acq,1);
whole_acq_indic = cell(number_of_whole_acq,1);
% ------------------------------------------------


%% +++++ Procsessing ONLY MDH ++++++
% 
% set(figHndl.text2,'string','Reading All MDHs...');
% drawnow
% 
% 
% disp('----------------------------------')
% disp('Reading MDH and set image size...')
% 
% processed_line = 0;
% t1 = clock;
% 
% axes(figHndl.axes_waitbar);
% 
% % tic
% % for i=1:524289
% %     fread(fid,mdh,'int8');
% % %     readMDHsome(fid);
% %     fseek(fid,512*2*4,'cof');  % *4 -> float32
% % end  % Elapsed time is 70.584296 seconds.
% % toc
% 
% ny = 1;
% nz = 1;
% na = 1;
% nx = 1;
% ns = 1;
% ne = 1;
% nr = 1;
% nset = 1;
% nphase = 1;
% nc = 1;
% nseg = 1;
% 
% readMDHsome(fid);
% 
% while ~bitget(sMDH.aulEvalInfoMask(1),MDH_ACQEND)
% 
%     cur_nx = sMDH.ushSamplesInScan;
%     
%     % % read ADC data -> saved column vector
%     temp = single(fread(fid,cur_nx*2,'float32'));  % *2 -> real and imag data
% 
%     % skip (ADC data) from cof (Current position in file) in [Byte]
% %     fseek(fid,cur_nx*2*4,'cof');  % *4 -> float32
% 
% 
%     % ---------- save ADC data to different variable -----------------
%     % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
%     % if don't know, use above default structure
% 
%     % noise data
%     % structure : (ny,nx,nc)
%     if bitget(sMDH.aulEvalInfoMask(1),MDH_NOISEADJSCAN)
% %         noise_data(cur_y,:,cur_c) = temp;
% 
%         % phase correction data
%         % structure : {nphase,nset,nr,ne,ns,na} [ny,nx,nz,nc]
%     elseif bitget(sMDH.aulEvalInfoMask(1),MDH_PHASCOR)
% %         phcor_data_cell{cur_phase,cur_set,cur_r,cur_e,cur_s,cur_a}(cur_y,:,cur_z,cur_c) = temp;
%         
%         
%         % synchroneous data
%         % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
%     elseif bitget(sMDH.aulEvalInfoMask(1),MDH_SYNCDATA)
% % %         sync_data(cur_y,:,cur_z,cur_c,...
% % %             cur_s,cur_e,cur_r,cur_set) = temp;
% %         sync_data = [sync_data,temp];   % i found this flag in %AdjustSeq%/AdjCoilSensSeq
% 
%         % reference phase stabilization scan data
%         % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
%     elseif bitget(sMDH.aulEvalInfoMask(1),MDH_REFPHASESTABSCAN)
% %         refphstabscan_data(cur_y,:,cur_z,cur_c,...
% %             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;
% 
%         % phase stabilization scan data
%         % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
%     elseif bitget(sMDH.aulEvalInfoMask(1),MDH_PHASESTABSCAN)
% %         phstabscan_data(cur_y,:,cur_z,cur_c,...
% %             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;
% 
%         % navgator echo data HPFEEDBACK
%         % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
%     elseif bitget(sMDH.aulEvalInfoMask(1),MDH_HPFEEDBACK)
% %         navHP_data(cur_y,:,cur_z,cur_c,...
% %             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;
% 
%         % navgator echo data RTFEEDBACK
%         % structure : (ny,nx,nc)
%     elseif bitget(sMDH.aulEvalInfoMask(1),MDH_RTFEEDBACK)
% %         navRT_data(cur_y,:,cur_c) = temp;
% 
%         % image raw data
%         % structure : {ny,nz,na} [nx,ns,ne,nr,nset,nphase,nc]
%         % NOTE : this structure is most effective memory savings when considering
%         % zero-padding AND for double valued average factor
%     else
%         cur_c = sMDH.ulChannelId+1;
%         
%         % seperate each coil to cell to avoid 'Out of Memory'
%         if cur_c ~= cp_coil_index    % did not include CP coil
%                         
%             cur_a = sMDH.sLC.ushAcquisition+1;  % just add if this >1
%             cur_e = sMDH.sLC.ushEcho+1;
%             cur_s = org_s(sMDH.sLC.ushSlice+1); % reorder slice
%             cur_seg = sMDH.sLC.ushSeg+1;
%             cur_z = sMDH.sLC.ushPartition+1;
%             cur_y = sMDH.sLC.ushLine+1;
%             cur_r = sMDH.sLC.ushRepetition+1;
%             cur_set = sMDH.sLC.ushSet+1;
%             % added at 2009.05.25
%             cur_phase = sMDH.sLC.ushPhase+1;
%             
%             %------- get larger index -----------------
%             ny = max(ny,cur_y);
%             nz = max(nz,cur_z);
%             na = max(na,cur_a);
%             nx = max(nx,cur_nx);
%             ns = max(ns,cur_s);
%             ne = max(ne,cur_e);
%             nr = max(nr,cur_r);
%             nset = max(nset,cur_set);
%             nphase = max(nphase,cur_phase);
%             nc = max(nc,cur_c);
%             nseg = max(nseg,cur_seg);
%             %-------------------------------------------
%             
%             if ~donotAvg && (cur_a>1 || sMDH.aushFreePara(1) == 302) 
%                 
%                 try
%                     % --------- save acq index to average
%                     avg_cell{cur_y,cur_z,1}(1,cur_s,...
%                         cur_e,cur_r,cur_set,cur_phase,cur_c) = avg_cell{cur_y,cur_z,1}(1,cur_s,...
%                         cur_e,cur_r,cur_set,cur_phase,cur_c) + 1;                    
%                     % ------ add raw
%                     % ADC data (temp) -> saved column vector
%                     raw{cur_y,cur_z,1}(:,cur_s,...
%                         cur_e,cur_r,cur_set,cur_phase,cur_c) = raw{cur_y,cur_z,1}(:,cur_s,...
%                         cur_e,cur_r,cur_set,cur_phase,cur_c) + temp;
%                     
%                 catch %-- in case of first appeared (sMDH.aushFreePara(1) == 302)
%                     
%                     avg_cell{cur_y,cur_z,1}(1,cur_s,...
%                         cur_e,cur_r,cur_set,cur_phase,cur_c) = 1;                    
%                     % save raw
%                     raw{cur_y,cur_z,1}(:,cur_s,...
%                         cur_e,cur_r,cur_set,cur_phase,cur_c) = temp;
%                 end
%                                 
%             else % if donotAvg==1, sepatate acq
% 
%                 avg_cell{cur_y,cur_z,cur_a}(1,cur_s,...
%                     cur_e,cur_r,cur_set,cur_phase,cur_c) = 1;                
%                 % save raw
%                 raw{cur_y,cur_z,cur_a}(:,cur_s,...
%                     cur_e,cur_r,cur_set,cur_phase,cur_c) = temp;
%             end        
%             
%         end
% 
%     end % end of save ADC data to different variable -----------------
% 
%     
%     processed_line = processed_line+1;
%     
%     if mod(processed_line,1024)==0
%         % ----------------- waitbar -----------------
%         processed_byte = ftell(fid);
%         processed_byte_percent = processed_byte/file_size*100;
%         
%         % set text of % processed
%         set(figHndl.text_processed,'string',...
%             [num2str(processed_byte_percent,'%.2f'),'% processed.']);
%         
%         % set text of remaining time
%         remaining_time_sec = (100-processed_byte_percent)*etime(clock, t1)/processed_byte_percent;
%         remaining_time_min = floor(remaining_time_sec/60);
%         
%         set(figHndl.text_remaintime,'string',...
%             sprintf('%d:%2.2fs remain.',remaining_time_min,remaining_time_sec-remaining_time_min*60));
%         
%         
%         xpatch = [0 processed_byte_percent processed_byte_percent 0];
%         ypatch = [0 0 1 1];
%         
%         % ----- draw patch to <figHndl.axes_waitbar>
%         patch(xpatch,ypatch,'b','EdgeColor','b','parent',figHndl.axes_waitbar); %,'EraseMode','none');
%         drawnow;
%         % ------------------------------------------------
%     end % end of processed lines
%         
%     
%     if cancel_process
%         disp('Processing canceled.')
%         fclose(fid);
%         return;
%     end
% 
%     readMDHsome(fid);   % read MDH before next loop
% end
% 
% 
% disp('Whole MDH read.')
% 
% fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)
% 
% dispetime(clock,t1);
% 
% set(figHndl.text2,'string',[filenameSS,'.dat']);
% drawnow
% 
% assignin('base','raw',raw);
% return;
% 
% ny = 128;
% nz = 32;
% na = 1;
% nx = 512;
% ns = 1;
% ne = 1;
% nr = 1;
% nset = 4;
% nphase = 8;
% nc = 4;

% tic
% %------ initialize raw matrix ----------------
% disp('initialize raw cell matrix...')
% raw = cell(prod([ny,nz,na,ns,ne,nr,nset,nphase,nc]),2);
% raw1 = complex(zeros(nx,'single'));
% for ln = 1:size(raw,1)
%     raw{ln,2} = raw1;
% end
% disp('Done.')
% %-------------------------------------------------
% toc

% %------ initialize raw matrix ----------------
% disp('initialize raw cell matrix...')
% if donotAvg
%     raw = cell(ny,nz,na,ns,ne,nr,nset,nphase,nc);
%     avg_cell = cell(ny,nz,na,ns,ne,nr,nset,nphase,nc);
%     raw1zeros = complex(zeros(nx,'single'));
%     avg1zeros = zeros(1,'uint16');    
%     for ly=1:ny
%         for lz=1:nz
%             for la=1:na
%                 for ls=1:ns
%                     for le=1:ne
%                         for lr=1:nr
%                             for lset=1:nset
%                                 for lphase=1:nphase
%                                     for lc=1:nc
%                                         raw{ly,lz,la,ls,le,lr,lset,lphase} = raw1zeros;
%                                         avg_cell{ly,lz,la,ls,le,lr,lset,lphase} = avg1zeros;
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% else
%     raw = cell(ny,nz,1,ns,ne,nr,nset,nphase,nc);
%     avg_cell = cell(ny,nz,1,ns,ne,nr,nset,nphase,nc);
%     raw1zeros = complex(zeros(nx,'single'));
%     avg1zeros = zeros(1,'uint16');    
%     for ly=1:ny
%         for lz=1:nz
%             for ls=1:ns
%                 for le=1:ne
%                     for lr=1:nr
%                         for lset=1:nset
%                             for lphase=1:nphase
%                                 for lc=1:nc
%                                     raw{ly,lz,1,ls,le,lr,lset,lphase} = raw1zeros;
%                                     avg_cell{ly,lz,1,ls,le,lr,lset,lphase} = avg1zeros;
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
% disp('Done.')
% %-------------------------------------------------
% toc

% tic
% %------ initialize raw matrix ----------------
% disp('initialize raw cell matrix...')
% if donotAvg
%     raw = complex(zeros(ny,nz,na,nx,ns,ne,nr,nset,nphase,nc,'single'));
%     avg_cell = zeros(ny,nz,na,1,ns,ne,nr,nset,nphase,nc,'uint16');    
% else
%     raw = complex(zeros(ny,nz,1,nx,ns,ne,nr,nset,nphase,nc,'single'));
%     avg_cell = zeros(ny,nz,1,1,ns,ne,nr,nset,nphase,nc,'uint16');    
% end
% disp('Done.')
% %-------------------------------------------------
% toc

% tic
% %------ initialize raw matrix ----------------
% disp('initialize raw cell matrix...')
% if donotAvg
%     raw = cell(ny,nz,na);
%     avg_cell = cell(ny,nz,na);
%     raw1zeros = complex(zeros(nx,ns,ne,nr,nset,nphase,nc,'single'));
%     avg1zeros = zeros(1,ns,ne,nr,nset,nphase,nc,'uint16');    
%     for ly=1:ny
%         for lz=1:nz
%             for la=1:na
%                 raw{ly,lz,la} = raw1zeros;
%                 avg_cell{ly,lz,la} = avg1zeros;
%             end
%         end
%     end
% else
%     raw = cell(ny,nz,1);
%     avg_cell = cell(ny,nz,1);
%     raw1zeros = complex(zeros(nx,ns,ne,nr,nset,nphase,nc,'single'));
%     avg1zeros = zeros(1,ns,ne,nr,nset,nphase,nc,'uint16');    
%     for ly=1:ny
%         for lz=1:nz
%             raw{ly,lz,1} = raw1zeros;
%             avg_cell{ly,lz,1} = avg1zeros;
%         end
%     end
% end
% disp('Done.')
% %-------------------------------------------------
% toc


%% *********** Procsessing ****************

set(figHndl.text2,'string',[filenameSS,'.dat']);
drawnow

disp('--------------------------------')
disp('Using Standard I/O File acces.')
disp('MDH based recon')

%------------- initialize some variable
echoTrain_index = 0;
navRT_image_index = 0;
navRT_image_file_index = 1;

is_navRT_image_prev = 0;
is_triggered = 0;
nav_train_saved = 0;

isTReffBegin = 0;
isTReffEnd = 0;

% for user data
nProjectLine = uint16([]);

processed_line = 0;

%--- index for preallocated variables
index_sync_data = 0;

index_timeTReff = 0;
index_time_btwShot_Nav = 0;

index_seg_indic_4s1 = 0;
index_seg_indic = 0;
index_acq_indic = 0;
index_whole_acq_indic = 0;
%----------------
%------------------------------------------

t1 = clock;

disp('Processing...')
axes(figHndl.axes_waitbar);

readMDH(fid);
while ~bitget(sMDH.aulEvalInfoMask(1),MDH_ACQEND)


    cur_nx = sMDH.ushSamplesInScan;
    cur_KspaceCenterCol = sMDH.ushKSpaceCentreColumn;

    % modified at 2009.05.22
    % cur_KspaceCenterCol : means index of current vector
    if cur_KspaceCenterCol>0
        num_zero_padding = cur_nx/2 - cur_KspaceCenterCol;
    else
        num_zero_padding = 0;
    end

    % read ADC data -> saved column vector
    temp = single(fread(fid,cur_nx*2,'float32'));  % *2 -> real and imag data
    % make it complex and save to matrix
    temp = complex(temp(1:2:end),temp(2:2:end));

    % modified at 2009.05.22
    % zero filling to locate echo center
    % but total # of readout samples is unchanged
    if num_zero_padding>0
        temp = [zeros(num_zero_padding,1,'single');temp(1:end-num_zero_padding)];
    elseif num_zero_padding<0
        temp = [temp(num_zero_padding+1:end);zeros(-num_zero_padding,1,'single')];
    end

    cur_preCut = sMDH.sCutOff.ushPre;
    cur_postCut = sMDH.sCutOff.ushPost;

    % replace zeros to ADC data
    temp(1:1+cur_preCut-1) = 0;
    temp(end-cur_postCut+1:end) = 0;

    % consider sign reversal
    if bitget(sMDH.aulEvalInfoMask(1),MDH_SIGNREV)
        temp = -temp;
    end

    % consider time reversal (EPI)
    if bitget(sMDH.aulEvalInfoMask(1),MDH_REFLECT)
        temp = flipud(temp);
    end

    cur_c = sMDH.ulChannelId+1;

    if cur_c<=size(rawcorr,1)
        % consider FFTscale
        temp = temp*rawcorr(cur_c,1);

        % consider RawDataCorrection
        if bitget(sMDH.aulEvalInfoMask(1),MDH_RAWDATACORRECTION)
            temp = temp*rawcorr(cur_c,2);
        end
    end

    cur_a = sMDH.sLC.ushAcquisition+1;  % just add if this >1
    cur_e = sMDH.sLC.ushEcho+1;
    cur_s = org_s(sMDH.sLC.ushSlice+1); % reorder slice
    cur_seg = sMDH.sLC.ushSeg+1;
    cur_z = sMDH.sLC.ushPartition+1;
    cur_y = sMDH.sLC.ushLine+1;
    cur_r = sMDH.sLC.ushRepetition+1;
    cur_set = sMDH.sLC.ushSet+1;
    cur_usedCh = sMDH.ushUsedChannels;
    % added at 2009.05.25
    cur_phase = sMDH.sLC.ushPhase+1;
    
    cur_timeStamp = sMDH.ulPMUTimeStamp;

    if bitget(sMDH.aulEvalInfoMask(1),MDH_TREFFECTIVEBEGIN)...
            && cur_c==1 && cur_seg==1 && ~isTReffBegin && ~isTReffEnd
        beginTimeTReff = cur_timeStamp;
        isTReffBegin = 1;
        
        if ~isempty(timeTReff) % begin - end
            index_timeTReff = index_timeTReff+1;
            timeTReff{index_timeTReff,1} = [beginTimeTReff-endTimeTReff,(beginTimeTReff-endTimeTReff)*2.5];
        end
    end
    
    if bitget(sMDH.aulEvalInfoMask(1),MDH_TREFFECTIVEEND)...
            && cur_c==1 && cur_seg==1 && ~isTReffEnd && isTReffBegin
        endTimeTReff = cur_timeStamp;
        isTReffEnd = 1;
    end
    
    if isTReffBegin && isTReffEnd % end - begin
        index_timeTReff = index_timeTReff+1;
        timeTReff{index_timeTReff,1} = [endTimeTReff-beginTimeTReff,(endTimeTReff-beginTimeTReff)*2.5];
        isTReffBegin = 0;
        isTReffEnd = 0;
    end
        
    % ---------- save ADC data to different variable -----------------
    % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    % if don't know, use above default structure

    % noise data
    % structure : (ny,nx,nc)
    if bitget(sMDH.aulEvalInfoMask(1),MDH_NOISEADJSCAN)
        noise_data(cur_y,:,cur_c) = temp;

        % phase correction data
        % structure : {nphase,nset,nr,ne,ns,na} [ny,nx,nz,nc]
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_PHASCOR)
        phcor_data_cell{cur_phase,cur_set,cur_r,cur_e,cur_s,cur_a}(cur_y,:,cur_z,cur_c) = temp;
        
        
        % synchroneous data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_SYNCDATA)
%         sync_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set) = temp;
        index_sync_data = index_sync_data+1;
        sync_data{1,index_sync_data} = temp;   % i found this flag in %AdjustSeq%/AdjCoilSensSeq

        % reference phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_REFPHASESTABSCAN)
        refphstabscan_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_PHASESTABSCAN)
        phstabscan_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data HPFEEDBACK
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_HPFEEDBACK)
        navHP_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data RTFEEDBACK
        % structure : (ny,nx,nc)
    elseif bitget(sMDH.aulEvalInfoMask(1),MDH_RTFEEDBACK)
        navRT_data(cur_y,:,cur_c) = temp;

        if cur_c==1 && is_triggered && ~isempty(endTimeShot)
            beginTimeNav = cur_timeStamp;
            index_time_btwShot_Nav = index_time_btwShot_Nav+1;
            time_btwShot_Nav{index_time_btwShot_Nav,1} = [beginTimeNav-endTimeShot,(beginTimeNav-endTimeShot)*2.5];
            endTimeShot = single([]);
        end
        
        if cur_usedCh==cur_c && bitget(sMDH.aulEvalInfoMask(1),MDH_PHASEFFT)
            

% % % % % % % %             % =========== wip - how to projection (before combine coil)
% % % % % % % %             % fisrt add along PE
% % % % % % % % %             temp_navRT_image = sum(temp_navRT_image,1); % just sum complex
% % % % % % % % %             temp_navRT_image = sum(mag(temp_navRT_image),1); % use magnitude
% % % % % % % % %             temp_navRT_image = sum(mag(temp_navRT_image).^2,1); % use magnitude sqaure
% % % % % % % %             temp_navRT_image = sum(mag(temp_navRT_image(5:6,:,:)),1); % use magnitude of some lines
% % % % % % % %                         
% % % % % % % %             % ======== wip - hot to combine coil
% % % % % % % %             % combine coil images SOS
% % % % % % % %             temp_navRT_image = SOS(temp_navRT_image).*exp(j*angle(sum(temp_navRT_image,3)));
% % % % % % % % 
% % % % % % % %             % combine coil images Just Add
% % % % % % % % %             temp_navRT_image = sum(temp_navRT_image,3);
% % % % % % % %             
% % % % % % % %             % use one coil image
% % % % % % % % %             temp_navRT_image = temp_navRT_image(:,:,1);
% % % % % % % %             % or use some coil image
% % % % % % % % %             temp_navRT_image = mag(temp_navRT_image);
% % % % % % % % %             temp_navRT_image = temp_navRT_image(:,:,2)+temp_navRT_image(:,:,4);
% % % % % % % %             % ================================================
            

            % ============== Navigator Processing - 2D PACE ==============
            % find NAV ROI in 2D NAV image
            % it have 12 PE lines ....... temp_navRT_image -> [y,x,coil]  
            
% % %             % first zero-padding
% % %             navRT_data = cat(1,navRT_data,...
% % %                 zeros(image_spec.Nav_num_zeroPadding_PE,size(navRT_data,2),size(navRT_data,3)));
            
            % do FFT
            temp_navRT_image = fft3c(navRT_data,3);
            
            % define ROI along PE
            temp_navRT_image = sum(mag(temp_navRT_image(...
                end/2+1+image_spec.Nav_offset_PE_pixel:...
                end/2+1+image_spec.Nav_offset_PE_pixel+image_spec.Nav_PE_size-1,...
                :,:)),1);
            
            % combine coil images SOS
            temp_navRT_image = SOS(temp_navRT_image).*exp(j*angle(sum(temp_navRT_image,3)));
            % ============================================================
            
            % get readout length
            [nav_ny,nav_nx] = size(temp_navRT_image);
            
            % cut RO oversampling
            if cut_RO_OS
                temp_navRT_image = temp_navRT_image(:,nav_nx/4+1:nav_nx/4+nav_nx/2,:);
            end
            
            % try to just sum to make projection along PE - i think it did work!
%             temp_navRT_image = sum(temp_navRT_image,1);
            
            % =========== wip - how to projection (after combine coil)
%             temp_navRT_image_ph = angle(sum(temp_navRT_image,1));
%             temp_navRT_image_mag = sum(mag(temp_navRT_image),1);
%             temp_navRT_image = temp_navRT_image_mag.*exp(j*temp_navRT_image_ph);
            
%             temp_navRT_image = sum(temp_navRT_image,1);

%             temp_navRT_image = fft3c(temp_navRT_image,1);
%             temp_navRT_image = temp_navRT_image(nav_ny/2,:);
            % ================================================

            % concatenate nav image
            % assume readout line is always longer than PE
            navRT_image = [navRT_image,temp_navRT_image.'];

            navRT_image_index = navRT_image_index+1;
            is_navRT_image_prev = 1;

            % save after triggering
            if is_triggered
                try
                    navRT_image_trig_after_cell{cur_s,cur_e,cur_r,cur_set,cur_phase,triggered_acq}(:,end+1) = temp_navRT_image.';
                catch
                    navRT_image_trig_after_cell{cur_s,cur_e,cur_r,cur_set,cur_phase,triggered_acq}(:,1) = temp_navRT_image.';
                end
                
                is_triggered = 0;
            end
            
            
            % save image to file when 10 image is collected
            %
            % when project along PE, concatenate (RO_length/2) images
            % save image to file when (RO_length/2) image is collected
            % %%% ---------> modified to 200 image (TRnav(150ms)*200 = 30s) -> NOT use
            % %%% ---------------> and after save training data set -> NOT use
            if navRT_image_index==(nav_nx/2)
                % add 0 to filenameSS
                if navRT_image_file_index<10
                    add0 = '00';
                elseif navRT_image_file_index<100
                    add0 = '0';
                else
                    add0 = '';
                end
                            
                if ~isdir([pathnameSS,'navRT_image'])
                    mkdir([pathnameSS,'navRT_image'])
                end
                disp(['Saving ',num2str(navRT_image_file_index),...
                    'th navRT_image to file...'])
                save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_',add0,...
                    num2str(navRT_image_file_index),'.mat'],'navRT_image');
                disp('Done!')
                
                if navRT_image_file_index ==1
                    mrimage(navRT_image);
                    title('1st NAV image set','fontsize',15)
                end

                navRT_image_file_index = navRT_image_file_index+1;
                navRT_image_index = 0;

                if nav_train_saved
                    navRT_image = single([]);   % reset matrix
                end
            end

        end % end of make nav image

        % image raw data
        % structure : {ny,nz,ns,nc,na} [nx,ne,nr,nset,nphase]
        % NOTE : this structure is most effective memory savings when considering
        % zero-padding AND for double valued average factor
    else
        raw_KSpaceCentreLineNo = sMDH.ushKSpaceCentreLineNo;
        raw_KSpaceCentrePartitionNo = sMDH.ushKSpaceCentrePartitionNo;
        raw_RO_PE_swapped = bitget(sMDH.aulEvalInfoMask(1),MDH_SWAPPED);
        %         raw_usedCh = cur_usedCh;

        % seperate each coil to cell to avoid 'Out of Memory'
        if cur_c ~= cp_coil_index    % did not include CP coil
            
            if ~donotAvg && (cur_a>1 || sMDH.aushFreePara(1) == 302) 
                
                try
                    % --------- save acq index to average
                    avg_cell{cur_y,cur_z,cur_s,cur_c,1}(1,...
                        cur_e,cur_r,cur_set,cur_phase) = avg_cell{cur_y,cur_z,cur_s,cur_c,1}(1,...
                        cur_e,cur_r,cur_set,cur_phase) + 1;                    
                    % ------ add raw
                    % ADC data (temp) -> saved column vector
                    raw{cur_y,cur_z,cur_s,cur_c,1}(:,...
                        cur_e,cur_r,cur_set,cur_phase) = raw{cur_y,cur_z,cur_s,cur_c,1}(:,...
                        cur_e,cur_r,cur_set,cur_phase) + temp;
                    
                catch %-- in case of first appeared (sMDH.aushFreePara(1) == 302)
                    
                    avg_cell{cur_y,cur_z,cur_s,cur_c,1}(1,...
                        cur_e,cur_r,cur_set,cur_phase) = 1;                    
                    % save raw
                    raw{cur_y,cur_z,cur_s,cur_c,1}(:,...
                        cur_e,cur_r,cur_set,cur_phase) = temp;
                end
                                
            else % if donotAvg==1, sepatate acq

                avg_cell{cur_y,cur_z,cur_s,cur_c,cur_a}(1,...
                    cur_e,cur_r,cur_set,cur_phase) = 1;                
                % save raw
                raw{cur_y,cur_z,cur_s,cur_c,cur_a}(:,...
                    cur_e,cur_r,cur_set,cur_phase) = temp;
            end        
            
%             if cur_c==1
%                 fprintf('y=%d, z=%d, a=%d, s=%d, e=%d, r=%d, set=%d, p=%d \n',...
%                     cur_y,cur_z,cur_a,cur_s,cur_e,cur_r,cur_set,cur_phase);
%             end
        end
        
        endTimeShot = cur_timeStamp;

        % --------- save projection line --------------------------------
        if sMDH.aushFreePara(1) == 302
            % -------- save number of projection line
            try % try increase index
                nProjectLine{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}(cur_c,1) = ...
                    nProjectLine{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}(cur_c,1)+1;
            catch % if not defined, error will occur and set to 1
                nProjectLine{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}(cur_c,1) = 1;
            end
            
            projLine_raw_cell{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}...
                (nProjectLine{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}(cur_c,1),:,cur_c) = temp;            
        end
        % ---------------------------------------------------------------
        
        %------------- save echo train index for TSE
        if cur_c==1 && cur_seg==1
            echoTrain_index = echoTrain_index+1;
        end
        
        %------------- save last navRT_image before acqusition of image
        if ~isempty(temp_navRT_image) && is_navRT_image_prev
            
%             fprintf('cur_s = %d\n',cur_s) % for debug
            
            try
                navRT_image_trig_before_cell{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}(:,end+1) = temp_navRT_image.';
            catch
                navRT_image_trig_before_cell{cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a}(:,1) = temp_navRT_image.';
            end
            
            triggered_acq = cur_a;
            
            is_triggered = 1;
            startTimeShot = cur_timeStamp;
        end
        
        %------------- save segment index for one coil and 1 acqusition and 1 repetition
        % and 1 phase
        % and 1 slice
        if cur_c==1 && cur_a==1 && cur_r==1 && cur_s==1 && cur_phase==1
            if is_triggered && is_navRT_image_prev && ~isempty(seg_indic_4s1)
                index_seg_indic_4s1 = index_seg_indic_4s1+1;
                seg_indic_4s1{index_seg_indic_4s1,1} = zeros(1,size(seg_indic_4s1,2));
            end
            if cur_seg == 1 && ~is_triggered
                startTimeShot = cur_timeStamp;
            end
            index_seg_indic_4s1 = index_seg_indic_4s1+1;
            seg_indic_4s1{index_seg_indic_4s1,1} = [cur_timeStamp,cur_timeStamp-startTimeShot,...
                (cur_timeStamp-startTimeShot)*2.5,echoTrain_index,...
                cur_seg,cur_set,cur_y,cur_z];
        end

        %------------- save segment index for one coil and 1 acqusition and 1 repetition
        % and 1 phase
        if cur_c==1 && cur_a==1 && cur_r==1 && cur_phase==1
            if is_triggered && is_navRT_image_prev && ~isempty(seg_indic)
                index_seg_indic = index_seg_indic+1;
                seg_indic{index_seg_indic,1} = [seg_indic;zeros(1,size(seg_indic,2))];
            end
            if cur_seg == 1 && ~is_triggered
                startTimeShot = cur_timeStamp;
            end
            index_seg_indic = index_seg_indic+1;
            seg_indic{index_seg_indic,1} = [cur_timeStamp,cur_timeStamp-startTimeShot,...
                (cur_timeStamp-startTimeShot)*2.5,echoTrain_index,...
                cur_seg,cur_set,cur_y,cur_z,cur_s];
        end
        
        %------------- save acq index for TSE for one coil and 1 repetition
        if cur_c==1 && cur_r==1
            if is_triggered && is_navRT_image_prev && ~isempty(acq_indic)
                index_acq_indic = index_acq_indic+1;
                acq_indic{index_acq_indic,1} = [acq_indic;zeros(1,size(acq_indic,2))];
            end
            if cur_seg == 1 && ~is_triggered
                startTimeShot = cur_timeStamp;
            end
            index_acq_indic = index_acq_indic+1;
            acq_indic{index_acq_indic,1} = [cur_timeStamp,cur_timeStamp-startTimeShot,...
                (cur_timeStamp-startTimeShot)*2.5,echoTrain_index,...
                cur_seg,cur_set,cur_a,cur_y,cur_z,cur_s];
        end
        
        %------------- save whole acq index
        if cur_seg == 1 && ~is_triggered
            startTimeShot = cur_timeStamp;
        end
        index_whole_acq_indic = index_whole_acq_indic+1;
        whole_acq_indic{index_whole_acq_indic,1} = [cur_timeStamp,cur_timeStamp-startTimeShot,...
            (cur_timeStamp-startTimeShot)*2.5,...
            cur_c,echoTrain_index,...
            cur_seg,cur_phase,cur_set,cur_r,cur_a,cur_y,cur_z,cur_s];

        %------------- save training data set
        if  ~isempty(navRT_image_trig_before_cell) && ~nav_train_saved% is_navRT_image_prev && size(navRT_image_trig_before_cell{1,1,1,1,1},2)==1
            navRT_image_train = navRT_image;
            
            if ~isdir([pathnameSS,'navRT_image'])
                mkdir([pathnameSS,'navRT_image'])
            end
            disp(['Saving ',...
                'navRT_image_train to file...'])
            save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_train',...
                '.mat'],'navRT_image_train');
            disp('Done!')
            
            nav_train_saved = 1;
            clear navRT_image_train
        end
        is_navRT_image_prev = 0;

    end % end of save ADC data to different variable -----------------


    processed_line = processed_line+1;

    if mod(processed_line,512)==0
        % ----------------- waitbar -----------------
        processed_byte = ftell(fid);
        processed_byte_percent = processed_byte/file_size*100;

        % set text of % processed
        set(figHndl.text_processed,'string',...
            [num2str(processed_byte_percent,'%.2f'),'% processed.']);
        
        % set text of remaining time
        remaining_time_sec = (100-processed_byte_percent)*etime(clock, t1)/processed_byte_percent;
        remaining_time_min = floor(remaining_time_sec/60);
        
        set(figHndl.text_remaintime,'string',...
            sprintf('%d:%2.2fs remain.',remaining_time_min,remaining_time_sec-remaining_time_min*60));
        

        xpatch = [0 processed_byte_percent processed_byte_percent 0];
        ypatch = [0 0 1 1];

        % ----- draw patch to <figHndl.axes_waitbar>
        patch(xpatch,ypatch,'b','EdgeColor','b','parent',figHndl.axes_waitbar); %,'EraseMode','none');
        drawnow;
        % ------------------------------------------------

        % waitbar was made following source code
        % waitbar.m

        % h = axes('XLim',[0 100],...
        %     'YLim',[0 1],...
        %     'Box','on', ...
        %     'Units','Points',...
        %     'XTickMode','manual',...
        %     'YTickMode','manual',...
        %     'XTick',[],...
        %     'YTick',[],...
        %     'XTickLabelMode','manual',...
        %     'XTickLabel',[],...
        %     'YTickLabelMode','manual',...
        %     'YTickLabel',[]);
        %
        % xpatch = [0 x x 0];
        % ypatch = [0 0 1 1];
        % xline = [100 0 0 100 100];
        % yline = [0 0 1 1 0];
        %
        % patch(xpatch,ypatch,'r','EdgeColor','r','EraseMode','none');
        % l = line(xline,yline,'EraseMode','none');
        % set(l,'Color',get(gca,'XColor'));
        % ------------------------------------------------
    end

    if cancel_process
        disp('Processing canceled.')
        fclose(fid);
        return;
    end

    readMDH(fid);   % read MDH before next loop
end

% ------ save last navRTimage to file -----------------------------
if ~isempty(navRT_image)
        % add 0 to filenameSS
        if navRT_image_file_index<10
            add0 = '00';
        elseif navRT_image_file_index<100
            add0 = '0';
        else
            add0 = '';
        end

        if ~isdir([pathnameSS,'navRT_image'])
            mkdir([pathnameSS,'navRT_image'])
        end
        disp(['Saving ',num2str(navRT_image_file_index),...
                    'th navRT_image to file...'])
        save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_',add0,...
            num2str(navRT_image_file_index),'.mat'],'navRT_image');
        disp('Done!')

        navRT_image_file_index = navRT_image_file_index+1;
        navRT_image_index = 0;

        navRT_image = single([]);   % reset matrix

end % end of save last navRTimage to file
% ------------------------------------------------

disp('Extraction was done!')

axes(figHndl.axes_waitbar);
% ----------------- waitbar -----------------
set(figHndl.text_processed,'string',...
    '100% processed.');
set(figHndl.text_remaintime,'string',...
    '00:00 s remain.');
        
xpatch = [0 100 100 0];
ypatch = [0 0 1 1];

patch(xpatch,ypatch,'b','EdgeColor','b'); %,'EraseMode','none');
drawnow;
% ------------------------------------------------

set(figHndl.text2,'string',[filenameSS,'.dat']);
drawnow

dispetime(clock,t1);
% assignin('base','raw',raw);


%% ------ save navRTimage_trig to file -----------------------------

% n_acq = max(acq_indic(:,6));

if ~isempty(navRT_image_trig_before_cell)
    if ~isdir([pathnameSS,'navRT_image'])
        mkdir([pathnameSS,'navRT_image'])
    end
    disp(['Saving ',...
        'navRT_image_before_trig to file...'])
    
    % n_acq = max(acq_indic(:,6));
    [ns,ne,nr,nset,nphase,n_acq] = size(navRT_image_trig_before_cell);

    for la = 1:n_acq
        if la<10
            add0a = '00';
        elseif la<100
            add0a = '0';
        else
            add0a = '';
        end
        for lphase = 1:nphase
            if lphase<10
                add0p = '00';
            elseif lphase<100
                add0p = '0';
            else
                add0p = '';
            end
            for lset = 1:nset
                if lset<10
                    add0set = '00';
                elseif lset<100
                    add0set = '0';
                else
                    add0set = '';
                end
                for lr = 1:nr
                    if lr<10
                        add0r = '00';
                    elseif lr<100
                        add0r = '0';
                    else
                        add0r = '';
                    end
                    for le = 1:ne
                        if le<10
                            add0e = '00';
                        elseif le<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for ls = 1:ns
                            if ls<10
                                add0 = '00';
                            elseif ls<100
                                add0 = '0';
                            else
                                add0 = '';
                            end
                            
                            navRT_image_before_trig = navRT_image_trig_before_cell{ls,le,lr,lset,lphase,la};
                            
                            if ~isempty(navRT_image_before_trig)
                                save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_before_trig',...
                                    '_a',add0a,num2str(la),...
                                    '_r',add0r,num2str(lr),...
                                    '_set',add0set,num2str(lset),...
                                    '_p',add0p,num2str(lphase),...
                                    '_e',add0e,num2str(le),...
                                    '_s',add0,num2str(ls),...
                                    '.mat'],'navRT_image_before_trig');
                            end
                            
                        end
                    end
                end
            end
        end
    end
    
    clear navRT_image_trig_before_cell
    clear navRT_image_before_trig
    disp('Done!')
end


if ~isempty(navRT_image_trig_after_cell)
    if ~isdir([pathnameSS,'navRT_image'])
        mkdir([pathnameSS,'navRT_image'])
    end
    disp(['Saving ',...
        'navRT_image_after_trig to file...'])
    
    [ns,ne,nr,nset,nphase,n_acq] = size(navRT_image_trig_after_cell);
    
    for la = 1:n_acq
        if la<10
            add0a = '00';
        elseif la<100
            add0a = '0';
        else
            add0a = '';
        end
        for lphase = 1:nphase
            if lphase<10
                add0p = '00';
            elseif lphase<100
                add0p = '0';
            else
                add0p = '';
            end
            for lset = 1:nset
                if lset<10
                    add0set = '00';
                elseif lset<100
                    add0set = '0';
                else
                    add0set = '';
                end
                for lr = 1:nr
                    if lr<10
                        add0r = '00';
                    elseif lr<100
                        add0r = '0';
                    else
                        add0r = '';
                    end
                    for le = 1:ne
                        if le<10
                            add0e = '00';
                        elseif le<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for ls = 1:ns
                            if ls<10
                                add0 = '00';
                            elseif ls<100
                                add0 = '0';
                            else
                                add0 = '';
                            end
                            
                            navRT_image_after_trig = navRT_image_trig_after_cell{ls,le,lr,lset,lphase,la};
                            
                            if ~isempty(navRT_image_after_trig)
                                save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_after_trig',...
                                    '_a',add0a,num2str(la),...
                                    '_r',add0r,num2str(lr),...
                                    '_set',add0set,num2str(lset),...
                                    '_p',add0p,num2str(lphase),...
                                    '_e',add0e,num2str(le),...
                                    '_s',add0,num2str(ls),...
                                    '.mat'],'navRT_image_after_trig');
                            end
                            
                        end
                    end
                end
            end
        end
    end
    
    clear navRT_image_trig_after_cell
    clear navRT_image_after_trig
    disp('Done!')
end

% ------------------------------------------------

%% ------------- save variable to file -----------------

if ~isempty(phcor_data_cell)
    if ~isdir([pathnameSS,'phcor_data'])
        mkdir([pathnameSS,'phcor_data'])
    end
    
    [nphase,nset,nr,ne,ns,n_acq] = size(phcor_data_cell);

    % phase correction data
    % structure : {nphase,nset,nr,ne,ns,na} [ny,nx,nz,nc]
    for lphase = 1:nphase
        if lphase<10
            add0p = '00';
        elseif lphase<100
            add0p = '0';
        else
            add0p = '';
        end
        for la = 1:n_acq
            if la<10
                add0a = '00';
            elseif la<100
                add0a = '0';
            else
                add0a = '';
            end
            for lset = 1:nset
                if lset<10
                    add0set = '00';
                elseif lset<100
                    add0set = '0';
                else
                    add0set = '';
                end
                for lr = 1:nr
                    if lr<10
                        add0r = '00';
                    elseif lr<100
                        add0r = '0';
                    else
                        add0r = '';
                    end
                    for le = 1:ne
                        if le<10
                            add0e = '00';
                        elseif le<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for ls = 1:ns
                            
                            if ls<10
                                add0 = '00';
                            elseif ls<100
                                add0 = '0';
                            else
                                add0 = '';
                            end
                            
                            phcor_data = phcor_data_cell{lphase,lset,lr,le,ls,la};
                            
                            if ~isempty(phcor_data)
                                save([pathnameSS,'phcor_data/',filenameSS,'_','phcor_data',...
                                    '_a',add0a,num2str(la),...
                                    '_r',add0r,num2str(lr),...
                                    '_set',add0set,num2str(lset),...
                                    '_p',add0p,num2str(lphase),...
                                    '_e',add0e,num2str(le),...
                                    '_s',add0,num2str(ls),...
                                    '.mat'],'phcor_data');
                            end
                            
                        end
                    end
                end
            end
        end
    end
    clear phcor_data_cell
    clear phcor_data
end

if ~isempty(noise_data)
    if ~isdir([pathnameSS,'noise_data'])
        mkdir([pathnameSS,'noise_data'])
    end
    save([pathnameSS,'noise_data/',filenameSS,'_','noise_data','.mat'],'noise_data');
    clear noise_data
end

if ~isempty(navHP_data)
    if ~isdir([pathnameSS,'navHP_data'])
        mkdir([pathnameSS,'navHP_data'])
    end
    save([pathnameSS,'navHP_data/',filenameSS,'_','navHP_data','.mat'],'navHP_data');
    clear navHP_data
end

if ~isempty(refphstabscan_data)
    if ~isdir([pathnameSS,'refphstabscan_data'])
        mkdir([pathnameSS,'refphstabscan_data'])
    end
    save([pathnameSS,'refphstabscan_data/',filenameSS,'_','refphstabscan_data','.mat'],'refphstabscan_data');
    clear refphstabscan_data
end

if ~isempty(phstabscan_data)
    if ~isdir([pathnameSS,'phstabscan_data'])
        mkdir([pathnameSS,'phstabscan_data'])
    end
    save([pathnameSS,'noise_data/',filenameSS,'_','phstabscan_data','.mat'],'phstabscan_data');
    clear phstabscan_data
end

sync_data = cell2mat(sync_data);
if ~isempty(sync_data)
    if ~isdir([pathnameSS,'sync_data'])
        mkdir([pathnameSS,'sync_data'])
    end    
    save([pathnameSS,'sync_data/',filenameSS,'_','sync_data','.mat'],'sync_data');
    clear sync_data
end

seg_indic = cell2mat(seg_indic);
if ~isempty(seg_indic)
    if ~isdir([pathnameSS,'seg_indic'])
        mkdir([pathnameSS,'seg_indic'])
    end    
    save([pathnameSS,'seg_indic/',filenameSS,'_','seg_indic','.mat'],...
        'seg_indic','seg_indic_info','seg_indic_info_4excel');
    clear seg_indic_info
    clear seg_indic_info_4excel
end

seg_indic_4s1 = cell2mat(seg_indic_4s1);
if ~isempty(seg_indic_4s1)
    if ~isdir([pathnameSS,'seg_indic'])
        mkdir([pathnameSS,'seg_indic'])
    end    
    save([pathnameSS,'seg_indic/',filenameSS,'_','seg_indic_4s1','.mat'],...
        'seg_indic_4s1','seg_indic_info_4s1','seg_indic_info_4s1_4excel');
    clear seg_indic_4s1
    clear seg_indic_info_4s1
    clear seg_indic_info_4s1_4excel
end

acq_indic = cell2mat(acq_indic);
if ~isempty(acq_indic)
    if ~isdir([pathnameSS,'seg_indic'])
        mkdir([pathnameSS,'seg_indic'])
    end    
    save([pathnameSS,'seg_indic/',filenameSS,'_','acq_indic','.mat'],...
        'acq_indic','acq_indic_info','acq_indic_info_4excel');
    clear acq_indic
    clear acq_indic_info
    clear acq_indic_info_4excel
end

whole_acq_indic = cell2mat(whole_acq_indic);
if ~isempty(whole_acq_indic)
    if ~isdir([pathnameSS,'seg_indic'])
        mkdir([pathnameSS,'seg_indic'])
    end    
    save([pathnameSS,'seg_indic/',filenameSS,'_','whole_acq_indic','.mat'],...
        'whole_acq_indic','whole_acq_indic_info','whole_acq_indic_info_4excel');
    clear whole_acq_indic
    clear whole_acq_indic_info
    clear whole_acq_indic_info_4excel
end

timeTReff = cell2mat(timeTReff);
if ~isempty(timeTReff)
    if ~isdir([pathnameSS,'Nav_time_Stamps'])
        mkdir([pathnameSS,'Nav_time_Stamps'])
    end    
    save([pathnameSS,'Nav_time_Stamps/',filenameSS,'_','timeTReff','.mat'],...
        'timeTReff','timeTReff_info','timeTReff_info_4excel');
    fprintf('\n- average TReff = %g ms\n',mean(timeTReff(:,2)))
    clear timeTReff
    clear timeTReff_info
    clear timeTReff_info_4excel
end

time_btwShot_Nav = cell2mat(time_btwShot_Nav);
if ~isempty(time_btwShot_Nav)
    if ~isdir([pathnameSS,'Nav_time_Stamps'])
        mkdir([pathnameSS,'Nav_time_Stamps'])
    end    
    save([pathnameSS,'Nav_time_Stamps/',filenameSS,'_','time_btwShot_Nav','.mat'],...
        'time_btwShot_Nav','time_btwShot_Nav_info','time_btwShot_Nav_info_4excel');
    fprintf('\n- average time between Shot & NAV = %g ms\n',mean(time_btwShot_Nav(:,2)))
    clear time_btwShot_Nav
    clear time_btwShot_Nav_info
    clear time_btwShot_Nav_info_4excel
end

%% --------- save user data - projection line

if ~isempty(projLine_raw_cell)
    if ~isdir([pathnameSS,'UserData'])
        mkdir([pathnameSS,'UserData'])
    end
    
    [ny,nz,ns,nc,na] = size(raw);
    [nx,ne,nr,nset,nphase] = size(raw{1});
    
    for lphase = 1:nphase
        if lphase<10
            add0p = '00';
        elseif lphase<100
            add0p = '0';
        else
            add0p = '';
        end
        for la = 1:na
            if la<10
                add0a = '00';
            elseif la<100
                add0a = '0';
            else
                add0a = '';
            end
            for lset = 1:nset
                if lset<10
                    add0set = '00';
                elseif lset<100
                    add0set = '0';
                else
                    add0set = '';
                end
                for lr = 1:nr
                    if lr<10
                        add0r = '00';
                    elseif lr<100
                        add0r = '0';
                    else
                        add0r = '';
                    end
                            
                    for le = 1:ne
                        if le<10
                            add0e = '00';
                        elseif le<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for ls = 1:ns
                            
                            if ls<10
                                add0 = '00';
                            elseif ls<100
                                add0 = '0';
                            else
                                add0 = '';
                            end
                            
                            %-- extract projection image according to
                            %  {s,e,r,set,phase,acq}                            
                            projLine_raw = projLine_raw_cell{ls,le,lr,lset,lphase,la};
                            
                            if ~isempty(projLine_raw)
                                %---- coil combine was done using root-Sum-of-squares
                                projLine_im = fft3c(projLine_raw,2);
                                
                                if cut_RO_OS
                                    projLine_im = projLine_im(:,nx/4+1:nx/4+nx/2,:);
                                end
                                
                                projLine_im_SOS = SOS(projLine_im);
                                
                                save([pathnameSS,'UserData/',filenameSS,'_','projLine_im',...
                                    '_a',add0a,num2str(la),...
                                    '_r',add0r,num2str(lr),...
                                    '_set',add0set,num2str(lset),...
                                    '_p',add0p,num2str(lphase),...
                                    '_e',add0e,num2str(le),...
                                    '_s',add0,num2str(ls),...
                                    '.mat'],...
                                    'projLine_raw','projLine_im','projLine_im_SOS');%,'realCenterLine'
                            end
                            
                        end
                    end
                end
            end
        end
    end
        
    fprintf('\n- total # of projection line = %d \n',size(projLine_im,1))
    
    clear projLine_raw
    clear projLine_im
    clear projLine_im_SOS
end

%% Save raw and make image

if isempty(raw{1})
    disp('------------------')
    disp('No Image Data.')
    disp('Algorithm stopped.')
    disp('------------------')
else
%% averaging to acq index

    [ny,nz,ns,nc,na] = size(raw);
    [nx,ne,nr,nset,nphase] = size(raw{1});

    for lc = 1:nc
        for lz = 1:nz
            for ls = 1:ns
                for ly = 1:ny
                    for le = 1:ne
                        for lr = 1:nr
                            for lset = 1:nset
                                for lphase = 1:nphase
                                    for la = 1:na
                                        
                                        % just divide to avg_cell
                                        if ~isempty(raw{ly,lz,ls,lc,la})
                                            raw{ly,lz,ls,lc,la}(:,...
                                                le,lr,lset,lphase) = raw{ly,lz,ls,lc,la}(:,...
                                                le,lr,lset,lphase)/avg_cell{ly,lz,ls,lc,la}(:,...
                                                le,lr,lset,lphase);
                                        end
                                        
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
%         assignin('base','avg_cell',avg_cell);
    
    if ~donotAvg
        avg_mat = cell2mat(avg_cell);
    end
    clear avg_cell
    
    if ~donotAvg
        avg_mat = avg_mat(:);
        image_spec_MDH.nacq_double = sum(avg_mat)/sum(avg_mat>0);
        
%         assignin('base','avg_mat',avg_mat);
        clear avg_mat
    end
    
    
    

%% consider KyCenter & KzCenter

    [ny,nz,ns,nc,na] = size(raw);

    num_zero_padding = ny - 2*raw_KSpaceCentreLineNo;

    % zero filling to locate CentreLine center
    if num_zero_padding>0
        temp_zeros_cell = cell(num_zero_padding,nz,ns,nc,na);
        % NOTE : cell can be defined and concatenated with empty
        % element
        raw = cat(1,temp_zeros_cell,raw);
        clear temp_zeros_cell
    elseif num_zero_padding<0
        temp_zeros_cell = cell(-num_zero_padding,nz,ns,nc,na);
        % NOTE : cell can be defined and concatenated with empty
        % element
        raw = cat(1,raw,temp_zeros_cell);
        clear temp_zeros_cell
    end

    [ny,nz,ns,nc,na] = size(raw);

    if nz>1
        num_zero_padding = nz - 2*raw_KSpaceCentrePartitionNo;

        % zero filling to locate CentreLine center
        if num_zero_padding>0
            temp_zeros_cell = cell(ny,num_zero_padding,ns,nc,na);
            % NOTE : cell can be defined and concatenated with empty
            % element
            raw = cat(2,temp_zeros_cell,raw);
            clear temp_zeros_cell
        elseif num_zero_padding<0
            temp_zeros_cell = cell(ny,-num_zero_padding,ns,nc,na);
            % NOTE : cell can be defined and concatenated with empty
            % element
            raw = cat(2,raw,temp_zeros_cell);
            clear temp_zeros_cell
        end

    end

%% consider PE Resolution & slice Resolution

    [ny,nz,ns,nc,na] = size(raw);

    % make iso-pixel
    RO_pixel_size = image_spec.FOVro/(nx/image_spec.read_os);
    ny_ima_mat = round(image_spec.FOVpe/RO_pixel_size);

    % note -- 얻은 PE line 이 더 크면 resolution 고려, 나눠주기?

    num_zero_padding = ny_ima_mat - ny;
    num_zero_padding = round(num_zero_padding/2);

    % zero filling to fit PE resolution
    if num_zero_padding>0
        temp_zeros_cell = cell(num_zero_padding,nz,ns,nc,na);
        % NOTE : cell can be defined and concatenated with empty
        % element
        % concatenate it upper and lower part
        raw = cat(1,temp_zeros_cell,raw);
        raw = cat(1,raw,temp_zeros_cell);
        clear temp_zeros_cell
    end


    [ny,nz,ns,nc,na] = size(raw);

    if nz>1
        
        if make_same_slice_DCM
            % make same as image/slab (DICOM slice #)
            nz_ima_mat = round(image_spec.nz_ima);
        else
            % make iso-pixel
            nz_ima_mat = round(image_spec.thick/RO_pixel_size);
        end

        num_zero_padding = nz_ima_mat - nz;
        num_zero_padding = round(num_zero_padding/2);

        % zero filling to fit slice resolution
        if num_zero_padding>0
            temp_zeros_cell = cell(ny,num_zero_padding,ns,nc,na);
            % NOTE : cell can be defined and concatenated with empty
            % element
            % concatenate it front and back
            raw = cat(2,temp_zeros_cell,raw);
            raw = cat(2,raw,temp_zeros_cell);
            clear temp_zeros_cell
        end

    end


%% save full raw data

    set(figHndl.text2,'string','Saving full raw...');
    drawnow
    
    [ny,nz,ns,nc,na] = size(raw);

    image_spec_MDH.nseg = max(seg_indic(:,nseg_column));
    clear seg_indic
    image_spec_MDH.nc = nc;
    image_spec_MDH.nz = nz;
    image_spec_MDH.ns = ns;
    image_spec_MDH.ny = ny;
    image_spec_MDH.nx = nx;
    image_spec_MDH.ne = ne;
    image_spec_MDH.nr = nr;
    image_spec_MDH.nset = nset;
    image_spec_MDH.nphase = nphase;
    image_spec_MDH.na = na;
    image_spec.RO_PE_swapped = raw_RO_PE_swapped;
    image_spec_MDH.RO_PE_swapped = raw_RO_PE_swapped;

    if donotAvg || image_spec_MDH.nacq_double==1
        raw_is_avged_text = '- Raw data is not Averaged.';
        image_spec_MDH.raw_is_avged = 0;
    else
        raw_is_avged_text = sprintf('- Raw data is Averaged by factor of %g.',image_spec_MDH.nacq_double);
        image_spec_MDH.raw_is_avged = 1;        
    end
    
    struct_raw = whos('raw');
    full_raw_FileSizeMByte = struct_raw.bytes/1e6;
    
    raw_info_text = strvcat(' ',...
        '---------------------------------------------',...
        sprintf('\t\tRAW data information'),...
        '---------------------------------------------',...
        'full_raw data structure : {ny,nz,ns,nc,na} [nx,ne,nr,nset,nphase]',...
        '    NOTE : this structure is most effective memory savings when considering',...
        '    zero-padding AND for double valued average factor',...
        ' ',...
        sprintf(' - Full Raw data size = %g [MB]',full_raw_FileSizeMByte),...
        ' ',...
        ['- Readout pixel size = ',num2str(RO_pixel_size),' mm'],...
        sprintf('- ReadOut and PhaseEncoding swapped = %d',raw_RO_PE_swapped),...
        sprintf('- User set ReadOut to x-axis = %d',donotSwapRO),...
        ' ',...
        'Final data size :',...
        sprintf('\timage (ky)x(kx)x(kz) : %dx%dx%d',ny,nx,nz),...
        sprintf('\t# of slice : %d',ns),...
        sprintf('\t# of coil : %d',nc),...
        sprintf('\t# of echo : %d',ne),...
        sprintf('\t# of repitetion : %d',nr),...
        sprintf('\t# of set : %d',nset),...
        sprintf('\t# of segment : %d',image_spec_MDH.nseg),...
        sprintf('\t# of phase : %d',nphase),...
        sprintf('\t# of acquisition (may be averaged): %d',na),...
        ' ',...
        raw_is_avged_text,...
        '---------------------------------------------',...
        ' ');
    
    disp(raw_info_text)

    set(figHndl.pushbutton_cancel,'enable','off')
    drawnow;

    disp('Saving full-raw data to file...')
    %----- save raw to .mat file
    if ~isdir([pathnameSS,'Raw_Data_VB15'])
        mkdir([pathnameSS,'Raw_Data_VB15'])
    end
    
    if full_raw_FileSizeMByte > 2000
        save(PathFIleName_of_saved_full_raw_file,...
        'raw','image_spec_MDH','image_spec','raw_info_text','mySiemensRead_version','-v7.3');
    else
        save(PathFIleName_of_saved_full_raw_file,...
            'raw','image_spec_MDH','image_spec','raw_info_text','mySiemensRead_version');
    end
    %---------------------------------------
    disp('Done!')
    disp(' ')

    set(figHndl.pushbutton_cancel,'enable','on')
    drawnow;
    
    assignin('base','image_spec_MDH',image_spec_MDH)
    assignin('base','image_spec',image_spec)
    assignin('base','raw_info_text',raw_info_text)

    set(figHndl.text2,'string',[filenameSS,'.dat']);
    drawnow

%% clear unused variables before save files

    clear sMDH

    clear cur_a
    clear cur_c
    clear cur_e
    clear cur_s
    clear cur_seg
    clear cur_z
    clear cur_y
    clear cur_r
    clear cur_set
    clear cur_usedCh

    clear cur_KspaceCenterCol
    clear raw_KSpaceCentreLineNo
    clear raw_KSpaceCentrePartitionNo

    clear processed_byte
    clear processed_byte_percent

    clear navRT_image_index
    clear navRT_image_file_index
    clear processed_line
    %---------------------------------------

    
    set(figHndl.text2,'string','Saving to Files...');
    drawnow
    t1=clock;
    
    save_RawimaComp
    
    dispetime(clock,t1)
    set(figHndl.text2,'string',[filenameSS,'.dat']);
    drawnow
    

end

%% end of algorithm

disp('=========================================================================')
disp(['Total ',dispetime(toc,0)]);
disp('=========================================================================')

fclose(fid);

%% function save_RawimaComp

    function save_RawimaComp
        drawnow;
        
        filenameSS = image_spec_MDH.filenameSS;
        pathnameSS = image_spec_MDH.pathSS;
        
        nc = image_spec_MDH.nc;
        nz = image_spec_MDH.nz;
        ns = image_spec_MDH.ns;        
        ny = image_spec_MDH.ny;
        nx = image_spec_MDH.nx;
        ne = image_spec_MDH.ne;
        nr = image_spec_MDH.nr;
        nset = image_spec_MDH.nset;        
        nphase = image_spec_MDH.nphase;
        na = image_spec_MDH.na;
        
%% seperate full-raw
        is_full_raw = 1; % raw is full-raw
        
        struct_raw = whos('raw');
        full_raw_FileSizeMByte = struct_raw.bytes/1e6;
    
        fprintf(' - Full Raw data size = %g [MB]\n',full_raw_FileSizeMByte)
        % if (not 64 bit system AND larger than 1 GByte) OR larger than 6 GByte
        if (isempty(strfind(computer,'64')) && full_raw_FileSizeMByte > 1000) || full_raw_FileSizeMByte > 2000
            
            if (isempty(strfind(computer,'64')) && full_raw_FileSizeMByte > 1000)
                disp('System is not 64 bit.')
                disp('Raw data is larger than 1 GBytes.')
            end
            if full_raw_FileSizeMByte > 2000
                disp('Raw data is larger than 6 GBytes.')
            end
            
            disp('Process will save to seperate files.')
            disp('Saving...')
            
            is_full_raw = 0; % raw is seperated-raw
            
            % save seperate file
            if nz>1 && make_3DwithCoil % in 3D, to each partition
                for z=1:nz
                    if z<10
                        add0z = '00';
                    elseif z<100
                        add0z = '0';
                    else
                        add0z = '';
                    end
                    
                    raw_partition = raw(:,z,:,:,:);
                    disp(['Saving raw data file separately... ','raw_partition_',add0z,num2str(z)])
                    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                        '_raw_partition_',add0z,num2str(z),'.mat'],'raw_partition');
                end
                clear raw_partition
            elseif nz>1 && ~make_3DwithCoil % in 3D, to each coil
                for c=1:nc
                    if c<10
                        add0c = '00';
                    elseif c<100
                        add0c = '0';
                    else
                        add0c = '';
                    end
                    
                    raw_coil = raw(:,:,:,c,:);
                    disp(['Saving raw data file separately... ','raw_coil_',add0c,num2str(c)])
                    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                        '_raw_coil_',add0c,num2str(c),'.mat'],'raw_coil');
                end
                clear raw_coil
            else % in 2D, to each slice
                for s=1:ns
                    if s<10
                        add0s = '00';
                    elseif s<100
                        add0s = '0';
                    else
                        add0s = '';
                    end
                    
                    raw_slice = raw(:,:,s,:,:);
                    disp(['Saving raw data file separately... ','raw_slice_',add0s,num2str(s)])
                    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                        '_raw_slice_',add0s,num2str(s),'.mat'],'raw_slice');
                end
                clear raw_slice
            end
            
            % clear full-raw
            clear raw
            
            disp('Done!')
        end
        
        % check user cancel
        drawnow;
        if cancel_process
            disp('Processing canceled.')
            return;
        end
        
%% save raw data

        %------------------------ divide into matrix --------------------------
        if nz>1 % 3D data
            if make_3DwithCoil
                raw_part = complex(zeros(ny,nx,nz,nc,'single'));
            else
                raw_part = complex(zeros(ny,nx,nz,'single'));
            end            
            
                
            for ia = 1:na
                if ia<10
                    add0a = '00';
                elseif ia<100
                    add0a = '0';
                else
                    add0a = '';
                end
                if image_spec_MDH.raw_is_avged
                    add0a = 'vged';
                end
                
                for iphase = 1:nphase
                    if iphase<10
                        add0p = '00';
                    elseif iphase<100
                        add0p = '0';
                    else
                        add0p = '';
                    end
                    for i_set = 1:nset
                        if i_set<10
                            add0set = '00';
                        elseif i_set<100
                            add0set = '0';
                        else
                            add0set = '';
                        end
                        for r = 1:nr
                            if r<10
                                add0r = '00';
                            elseif r<100
                                add0r = '0';
                            else
                                add0r = '';
                            end
                            for e = 1:ne
                                if e<10
                                    add0e = '00';
                                elseif e<100
                                    add0e = '0';
                                else
                                    add0e = '';
                                end
                                for s = 1:ns
                                    if s<10
                                        add0s = '00';
                                    elseif s<100
                                        add0s = '0';
                                    else
                                        add0s = '';
                                    end
                                    
                                    if make_3DwithCoil
                                        % make 3D data with coils -> 4D matrix
                                        for z=1:nz
                                            if z<10
                                                add0z = '00';
                                            elseif z<100
                                                add0z = '0';
                                            else
                                                add0z = '';
                                            end
                                            
                                            if ~is_full_raw
                                                disp(['Loading seperated raw data file... ','raw_partition_',add0z,num2str(z)])
                                                load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                    '_raw_partition_',add0z,num2str(z),'.mat'])
                                            end
                                            
                                            for c = 1:nc
                                                for y=1:ny
                                                    
                                                    if is_full_raw
                                                        if ~isempty(raw{y,z,s,c,ia})
                                                            raw_part(y,:,z,c) = raw{y,z,s,c,ia}(:,e,r,i_set,iphase);
                                                        else
                                                            raw_part(y,:,z,c) = 0;
                                                        end
                                                    else
                                                        if ~isempty(raw_partition{y,1,s,c,ia})
                                                            raw_part(y,:,z,c) = raw_partition{y,1,s,c,ia}(:,e,r,i_set,iphase);
                                                        else
                                                            raw_part(y,:,z,c) = 0;
                                                        end
                                                    end % end of 'if is_full_raw'
                                                    
                                                end % end of 'for y=1:yz'
                                            end % end of coil (nc) iteration
                                            
                                            drawnow;
                                            if cancel_process
                                                disp('Processing canceled.')
                                                return;
                                            end
                                        end % end of 'for z=1:nz'
                                        
                                        
                                        
                                        disp('Saving 3D raw (4D : 3D with coils) to file...')
                                        %----- save raw to .mat file
                                        if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                            mkdir([pathnameSS,'Raw_Data_VB15'])
                                        end
                                        
                                        save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                            '_raw',...
                                            '_a',add0a,num2str(ia),...
                                            '_r',add0r,num2str(r),...
                                            '_set',add0set,num2str(i_set),...
                                            '_p',add0p,num2str(iphase),...
                                            '_e',add0e,num2str(e),...
                                            '_s',add0s,num2str(s),...
                                            '.mat'],'raw_part');
                                        %----------------------------------
                                        %-----
                                        
                                        drawnow;
                                        if cancel_process
                                            disp('Processing canceled.')
                                            return;
                                        end
                                        
                                        disp('Now, evaluate FFT...')
                                        im = fft3c(raw_part,11);
                                        if cut_RO_OS
                                            im = im(:,nx/4+1:nx/4+nx/2,:,:);
                                            % consider phase/readout swapp
                                            if image_spec_MDH.RO_PE_swapped && ~donotSwapRO
                                                im = permute(im,[2,1,3,4]);
                                            end
                                        end
                                        
                                        drawnow;
                                        if cancel_process
                                            disp('Processing canceled.')
                                            return;
                                        end
                                        
                                        disp('Saving 3D image (4D : 3D with coils) to file...')
                                        %----- save image to .mat file
                                        if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
                                            mkdir([pathnameSS,'Reconstructed_Data_VB15'])
                                        end
                                        
                                        save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                            '_image',...
                                            '_a',add0a,num2str(ia),...
                                            '_r',add0r,num2str(r),...
                                            '_set',add0set,num2str(i_set),...
                                            '_p',add0p,num2str(iphase),...
                                            '_e',add0e,num2str(e),...
                                            '_s',add0s,num2str(s),...
                                            '.mat'],'im');
                                        %----------------------------------------
                                        disp('Done!')
                                        clear im
                                    end % end of make_3DwithCoil for file saving
                                    
                                    if ~make_3DwithCoil % if 'make_3DwithCoil' unchecked
                                        % make 3D data without coils -> 3D matrix
                                                                                
                                        for c = 1:nc
                                            if c<10
                                                add0c = '00';
                                            elseif c<100
                                                add0c = '0';
                                            else
                                                add0c = '';
                                            end
                                            
                                            if ~is_full_raw
                                                disp(['Loading seperated raw data file... ','raw_coil_',add0c,num2str(c)])
                                                load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                    '_raw_coil_',add0c,num2str(c),'.mat'])
                                            end
                                            
                                            for z=1:nz
                                                                                                
                                                for y=1:ny
                                                    
                                                    if is_full_raw
                                                        if ~isempty(raw{y,z,s,c,ia})
                                                            raw_part(y,:,z) = raw{y,z,s,c,ia}(:,e,r,i_set,iphase);
                                                        else
                                                            raw_part(y,:,z) = 0;
                                                        end
                                                    else
                                                        if ~isempty(raw_coil{y,z,s,1,ia})
                                                            raw_part(y,:,z) = raw_coil{y,z,s,1,ia}(:,e,r,i_set,iphase);
                                                        else
                                                            raw_part(y,:,z) = 0;
                                                        end
                                                    end % end of 'if is_full_raw'
                                                                                                        
                                                end % end of 'for y=1:yz'
                                                
                                            end % end of 'for z=1:nz'
                                            
                                            disp(['Saving ',num2str(c),'th 3D raw (3D without coils) to file...'])
                                            %----- save raw to .mat file
                                            if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                                mkdir([pathnameSS,'Raw_Data_VB15'])
                                            end
                                            
                                            save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                '_raw',...
                                                '_a',add0a,num2str(ia),...
                                                '_r',add0r,num2str(r),...
                                                '_set',add0set,num2str(i_set),...
                                                '_p',add0p,num2str(iphase),...
                                                '_e',add0e,num2str(e),...
                                                '_s',add0s,num2str(s),...
                                                '_c',add0c,num2str(c),'.mat'],'raw_part');
                                            %---------------------------------------
                                            
                                            drawnow;
                                            if cancel_process
                                                disp('Processing canceled.')
                                                return;
                                            end
                                            
                                            disp('Now, evaluate FFT...')
                                            im = fft3c(raw_part);
                                            if cut_RO_OS
                                                im = im(:,nx/4+1:nx/4+nx/2,:);
                                                % consider phase/readout swapp
                                                if image_spec_MDH.RO_PE_swapped && ~donotSwapRO
                                                    im = permute(im,[2,1,3]);
                                                end
                                            end
                                            
                                            drawnow;
                                            if cancel_process
                                                disp('Processing canceled.')
                                                return;
                                            end
                                            
                                            disp(['Saving ',num2str(c),'th 3D image (3D : 3D without coils) to file...'])
                                            %----- save image to .mat file
                                            if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
                                                mkdir([pathnameSS,'Reconstructed_Data_VB15'])
                                            end
                                            
                                            save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                                '_image',...
                                                '_a',add0a,num2str(ia),...
                                                '_r',add0r,num2str(r),...
                                                '_set',add0set,num2str(i_set),...
                                                '_p',add0p,num2str(iphase),...
                                                '_e',add0e,num2str(e),...
                                                '_s',add0s,num2str(s),...
                                                '_c',add0c,num2str(c),'.mat'],'im');
                                            %----------------------------------------
                                            disp('Done!')
                                            clear im
                                            
                                        end % end of coil (nc) iteration
                                    end % end of ~make_3DwithCoil for file saving
                                    
                                    
                                    
                                    
                                end
                            end
                        end
                    end
                end
            end
        else    % 2D data (i.e. nz=1)
            raw_part = complex(zeros(ny,nx,nc,'single'));
            
            for ia = 1:na
                if ia<10
                    add0a = '00';
                elseif ia<100
                    add0a = '0';
                else
                    add0a = '';
                end
                if image_spec_MDH.raw_is_avged
                    add0a = 'vged';
                end
                
                for iphase = 1:nphase
                    if iphase<10
                        add0p = '00';
                    elseif iphase<100
                        add0p = '0';
                    else
                        add0p = '';
                    end
                    for i_set = 1:nset
                        if i_set<10
                            add0set = '00';
                        elseif i_set<100
                            add0set = '0';
                        else
                            add0set = '';
                        end
                        for r = 1:nr
                            if r<10
                                add0r = '00';
                            elseif r<100
                                add0r = '0';
                            else
                                add0r = '';
                            end
                            for e = 1:ne
                                if e<10
                                    add0e = '00';
                                elseif e<100
                                    add0e = '0';
                                else
                                    add0e = '';
                                end
                                for s = 1:ns
                                    if s<10
                                        add0s = '00';
                                    elseif s<100
                                        add0s = '0';
                                    else
                                        add0s = '';
                                    end
                                    
                                    if ~is_full_raw
                                            disp(['Loading seperated raw data file... ','raw_slice_',add0s,num2str(s)])
                                            load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                '_raw_slice_',add0s,num2str(s),'.mat'])
                                    end
                                    
                                    for c=1:nc
                                        
                                        if is_full_raw
                                            for y=1:ny
                                                if ~isempty(raw{y,1,s,c,ia})
                                                    raw_part(y,:,c) = raw{y,1,s,c,ia}(:,e,r,i_set,iphase);
                                                else
                                                    raw_part(y,:,c) = 0;
                                                end
                                            end
                                        else
                                            for y=1:ny
                                                if ~isempty(raw_slice{y,1,1,c,ia})
                                                    raw_part(y,:,c) = raw_slice{y,1,1,c,ia}(:,e,r,i_set,iphase);
                                                else
                                                    raw_part(y,:,c) = 0;
                                                end
                                            end
                                        end
                                    end % end of for c=1:nc
                                    
                                    disp('Saving raw to file...')
                                    %----- save raw to .mat file
                                    if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                        mkdir([pathnameSS,'Raw_Data_VB15'])
                                    end
                                    
                                    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                        '_raw',...
                                        '_a',add0a,num2str(ia),...
                                        '_r',add0r,num2str(r),...
                                        '_set',add0set,num2str(i_set),...
                                        '_p',add0p,num2str(iphase),...
                                        '_e',add0e,num2str(e),...
                                        '_s',add0s,num2str(s),...
                                        '.mat'],'raw_part');
                                    %---------------------------------------
                                    
                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
                                        return;
                                    end
                                    
                                    disp('Now, evaluate FFT...')
                                    im = fft3c(raw_part,3);
                                    if cut_RO_OS
                                        im = im(:,nx/4+1:nx/4+nx/2,:);
                                        % consider phase/readout swapp
                                        if image_spec_MDH.RO_PE_swapped && ~donotSwapRO
                                            im = permute(im,[2,1,3]);
                                        end
                                    end
                                    
                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
                                        return;
                                    end
                                    
                                    disp('Saving image to file...')
                                    %----- save image to .mat file
                                    if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
                                        mkdir([pathnameSS,'Reconstructed_Data_VB15'])
                                    end
                                    
                                    save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                        '_image',...
                                        '_a',add0a,num2str(ia),...
                                        '_r',add0r,num2str(r),...
                                        '_set',add0set,num2str(i_set),...
                                        '_p',add0p,num2str(iphase),...
                                        '_e',add0e,num2str(e),...
                                        '_s',add0s,num2str(s),...
                                        '.mat'],'im');
                                    %----------------------------------------
                                    disp('Done!')
                                    clear im
                                    
                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
                                        return;
                                    end
                                end
                            end
                        end
                    end                    
                end
            end
        end

        clear raw
        clear raw_part
        clear im

%% make & save composite image

        if make_comp_im
            % check user cancel
            drawnow;
            if cancel_process
                disp('Processing canceled.')
                return;
            end

            try
                disp(' ')
                func_make_comp_im(image_spec_MDH)
                disp(' ')
            catch %ME
%                 disp(ME)
%                 disp(ME.stack(1))
%                 disp(ME.message)
%                 if ~isempty(strfind(ME.message,'HELP MEMORY'))
%                     disp(' ')
%                     disp('Not enough contiguous memory.')
%                     disp(['3 x ',num2str(make_comp_needed_memory_size_byte/1e6),' MBytes and '])
%                     disp(['2 x ',num2str(make_comp_needed_memory_size_byte/2/1e6),' MBytes'])
%                     disp('of contiguous memory is needed.')
                    disp('Try again, after you have enough memory.')
                    disp(' ')
                    
                    err = lasterror;
                    fprintf('Last error in "make & save composite image" ...\n')
                    disp('-------------------------------------')
                    fprintf('\t message: %s\n',err.message)
                    fprintf('\t identifier: %s\n',err.identifier)
                    fprintf('\t stack: ')
                    disp(err.stack)
                    disp(' ')
                    disp('-------------------------------------')
%                 else
%                     disp(' ')
%                     disp('Unexpected error has occured.')
%                 end
            end
        end % end of make_comp_im

    end % end of function save_RawimaComp

end% end of function mySiemensRead_v2

%% function make_comp_im

function func_make_comp_im(image_spec_MDH)
global cancel_process;
global make_comp_needed_memory_size_byte;
global make_3DwithCoil;

filenameSS = image_spec_MDH.filenameSS;
pathnameSS = image_spec_MDH.pathSS;

nc = image_spec_MDH.nc;
nz = image_spec_MDH.nz;
ns = image_spec_MDH.ns;

ny = image_spec_MDH.ny;
nx = image_spec_MDH.nx;
ne = image_spec_MDH.ne;
nr = image_spec_MDH.nr;
nset = image_spec_MDH.nset;

nphase = image_spec_MDH.nphase;
na = image_spec_MDH.na;


if nz>1 % 3D data
    
    try
        % allocate memory
        comp_im = complex(zeros(ny,nx,nz,'single'));
        comp_mag_im = zeros(ny,nx,nz,'single');
        temp_mag_im = comp_mag_im;
        comp_ph_im = comp_im;

        % needed memory size is
        make_comp_needed_memory_size_byte = ny*nx*nz*8;
        
    catch %ME
%         disp(ME)
%         disp(ME.stack(1))
%         disp(ME.message)
%         if ~isempty(strfind(ME.message,'HELP MEMORY'))
%             disp(' ')
%             disp('Not enough contiguous memory.')
%             disp(['3 x ',num2str(make_comp_needed_memory_size_byte/1e6),' MBytes and '])
%             disp(['2 x ',num2str(make_comp_needed_memory_size_byte/2/1e6),' MBytes'])
%             disp('of contiguous memory is needed.')
            disp('Try again, after you have enough memory.')
            disp(' ')
%         end
        return;
    end
    
    for ia = 1:na
        if ia<10
            add0a = '00';
        elseif ia<100
            add0a = '0';
        else
            add0a = '';
        end
        if image_spec_MDH.raw_is_avged
            add0a = 'vged';
        end
        
        for iphase = 1:nphase
            if iphase<10
                add0p = '00';
            elseif iphase<100
                add0p = '0';
            else
                add0p = '';
            end
            for i_set = 1:nset
                if i_set<10
                    add0set = '00';
                elseif i_set<100
                    add0set = '0';
                else
                    add0set = '';
                end
                for r = 1:nr
                    if r<10
                        add0r = '00';
                    elseif r<100
                        add0r = '0';
                    else
                        add0r = '';
                    end
                    for e = 1:ne
                        if e<10
                            add0e = '00';
                        elseif e<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for s = 1:ns
                            if s<10
                                add0s = '00';
                            elseif s<100
                                add0s = '0';
                            else
                                add0s = '';
                            end
                            
                            if make_3DwithCoil
                                disp('Loading  3D image (4D : 3D without coils) file...')
                                load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                    '_image',...
                                    '_a',add0a,num2str(ia),...
                                    '_r',add0r,num2str(r),...
                                    '_set',add0set,num2str(i_set),...
                                    '_p',add0p,num2str(iphase),...
                                    '_e',add0e,num2str(e),...
                                    '_s',add0s,num2str(s),...
                                    '.mat']);
                                
                                comp_mag_im = SOS(im);
                                comp_ph_im = sum(im,4);
                            else
                                
                                for c = 1:nc
                                    if c<10
                                        add0c = '00';
                                    elseif c<100
                                        add0c = '0';
                                    else
                                        add0c = '';
                                    end
                                    disp(['Loading ',num2str(c),'th coil 3D image file...'])
                                    load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                        '_image',...
                                        '_a',add0a,num2str(ia),...
                                        '_r',add0r,num2str(r),...
                                        '_set',add0set,num2str(i_set),...
                                        '_p',add0p,num2str(iphase),...
                                        '_e',add0e,num2str(e),...
                                        '_s',add0s,num2str(s),...
                                        '_c',add0c,num2str(c),'.mat']);
                                    
                                    if c==1
                                        temp_mag_im = mag(im);
                                        temp_mag_im = temp_mag_im.*temp_mag_im;
                                        comp_mag_im = temp_mag_im;
                                        comp_ph_im = im;
                                    else
                                        
                                        temp_mag_im = mag(im);
                                        temp_mag_im = temp_mag_im.*temp_mag_im;
                                        comp_mag_im = comp_mag_im+temp_mag_im;
                                        comp_ph_im = comp_ph_im+im;
                                    end
                                    
                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
                                        %                             cancel_process = 0;
                                        return;
                                    end
                                    clear temp_mag_im
                                    clear comp_im
                                    clear im
                                end % end of coil iteration
                                
                                % why step-by-step operation is memory efficient than
                                % combined one-line operation ?
                                comp_mag_im = sqrt(comp_mag_im);
                                comp_ph_im = angle(comp_ph_im);
                                
                            end % end of 'make_3DwithCoil'
                            
                            % make composite image (root-sum-of-squares
                            % magnitude and complex summed phase)
                            comp_im = comp_mag_im.*exp(j*comp_ph_im);
                            
                            disp('Saving composite image to file...')
                            % ------ save combined image to .mat file
                            if ~isdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                                mkdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                            end
                            save([pathnameSS,'Reconstructed_Data_VB15/Composite_image/',filenameSS,...
                                '_Composite_image',...
                                '_a',add0a,num2str(ia),...
                                '_r',add0r,num2str(r),...
                                '_set',add0set,num2str(i_set),...
                                '_p',add0p,num2str(iphase),...
                                '_e',add0e,num2str(e),...
                                '_s',add0s,num2str(s),...
                                '.mat'],'comp_im');
                            disp('Done!')
                            
                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
else    % 2D data (i.e. nz=1)
    for ia = 1:na
        if ia<10
            add0a = '00';
        elseif ia<100
            add0a = '0';
        else
            add0a = '';
        end
        if image_spec_MDH.raw_is_avged
            add0a = 'vged';
        end
        
        for iphase = 1:nphase
            if iphase<10
                add0p = '00';
            elseif iphase<100
                add0p = '0';
            else
                add0p = '';
            end
            for i_set = 1:nset
                if i_set<10
                    add0set = '00';
                elseif i_set<100
                    add0set = '0';
                else
                    add0set = '';
                end
                for r = 1:nr
                    if r<10
                        add0r = '00';
                    elseif r<100
                        add0r = '0';
                    else
                        add0r = '';
                    end
                    for e = 1:ne
                        if e<10
                            add0e = '00';
                        elseif e<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for s = 1:ns
                            if s<10
                                add0s = '00';
                            elseif s<100
                                add0s = '0';
                            else
                                add0s = '';
                            end
                            
                            disp('Loading 2D image file...')
                            load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                '_image',...
                                '_a',add0a,num2str(ia),...
                                '_r',add0r,num2str(r),...
                                '_set',add0set,num2str(i_set),...
                                '_p',add0p,num2str(iphase),...
                                '_e',add0e,num2str(e),...
                                '_s',add0s,num2str(s),...
                                '.mat']);
                            
                            comp_im = SOS(im).*exp(j*angle(sum(im,3)));
                            clear im
                            
                            disp('Saving composite image to file...')
                            % ------ save combined image to .mat file
                            if ~isdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                                mkdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                            end
                            save([pathnameSS,'Reconstructed_Data_VB15/Composite_image/',filenameSS,...
                                '_Composite_image',...
                                '_a',add0a,num2str(ia),...
                                '_r',add0r,num2str(r),...
                                '_set',add0set,num2str(i_set),...
                                '_p',add0p,num2str(iphase),...
                                '_e',add0e,num2str(e),...
                                '_s',add0s,num2str(s),...
                                '.mat'],'comp_im');
                            disp('Done!')
                            
                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end
clear comp_im
end % end of function func_make_comp_im
