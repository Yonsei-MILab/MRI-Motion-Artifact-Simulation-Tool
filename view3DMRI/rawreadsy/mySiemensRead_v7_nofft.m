function mySiemensRead_v7(image_spec)
%% Information
% Only works in conventional 2D(3D)FT sequence
% 
% Coded by cefca (Sang-Young Zho).
% All rights reserved in MI laboratory.
% Last modified at 2009.06.04
% 
% 
% acq_indic 저장하는 것을 preallocating 하지 않으면 매우 느려짐
% raw data는 preallocating 하지 않아도 별차이 없음
% [ny,nz,nx] 만 matrix로, 나머진 cell로
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
mySiemensRead_version = '_v7';
fprintf('\nmySiemensRead%s()\n',mySiemensRead_version)

%% set parameter

global image_spec_MDH;
global make_comp_im;
global cut_RO_OS;
global figHndl;
global cancel_process;
global donotSwapRO;
global reprocess;
global donotAvg;
global make_same_slice_DCM;
global make_3DwithCoil;
global mMDH;
global useInterleaving;

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

if strcmp(image_spec.multiSliceMode,'MSM_INTERLEAVED') && useInterleaving
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
fprintf('File Size = %g MBytes\n',file_size/1e6)

%% MDH based recon - don't care memory

initMDH;

fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)

%% define some data variable

raw = single([]);   % image raw data
avg_cell = single([]); % to save acqusition index

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
% that is projection line in TSE sequence if mMDH(MDH_aushFreePara(1) == 302
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

%% MDH_H index definition %%

mMDH = zeros(48,1);

MDH_ulDMALength                             = 1; % fread(fid, 1, 'uint32');      % 4
MDH_lMeasUID                                = 2; % fread(fid, 1,  'int32');      % 8
MDH_ulScanCounter                           = 3; % fread(fid, 1, 'uint32');      % 12
MDH_ulTimeStamp                             = 4; % fread(fid, 1, 'uint32');      % 16
MDH_ulPMUTimeStamp                          = 5; % fread(fid, 1, 'uint32');      % 20

MDH_aulEvalInfoMask1                 = 6; % fread(fid, 1, 'uint32');      % 20 + 2 * 4 = 28
MDH_aulEvalInfoMask2                 = 7; % fread(fid, 1, 'uint32');

MDH_ushSamplesInScan                        = 8; % fread(fid, 1, 'uint16');      % 30
MDH_ushUsedChannels                         = 9; % fread(fid, 1, 'uint16');      % 32
MDH_sLC_ushLine                             = 10; % fread(fid, 1, 'uint16');
MDH_sLC_ushAcquisition                      = 11; % fread(fid, 1, 'uint16');
MDH_sLC_ushSlice                            = 12; % fread(fid, 1, 'uint16');
MDH_sLC_ushPartition                        = 13; % fread(fid, 1, 'uint16');
MDH_sLC_ushEcho                             = 14; % fread(fid, 1, 'uint16');
MDH_sLC_ushPhase                            = 15; % fread(fid, 1, 'uint16');
MDH_sLC_ushRepetition                       = 16; % fread(fid, 1, 'uint16');
MDH_sLC_ushSet                              = 17; % fread(fid, 1, 'uint16');
MDH_sLC_ushSeg                              = 18; % fread(fid, 1, 'uint16');
MDH_sLC_ushIda                              = 19; % fread(fid, 1, 'uint16');
MDH_sLC_ushIdb                              = 20; % fread(fid, 1, 'uint16');
MDH_sLC_ushIdc                              = 21; % fread(fid, 1, 'uint16');
MDH_sLC_ushIdd                              = 22; % fread(fid, 1, 'uint16');
MDH_sLC_ushIde                              = 23; % fread(fid, 1, 'uint16');      % 32 + 14 * 2 = 60

MDH_sCutOff_ushPre                          = 24; % fread(fid, 1, 'uint16');
MDH_sCutOff_ushPost                         = 25; % fread(fid, 1, 'uint16');      % 60 + 2 * 2 = 64
MDH_ushKSpaceCentreColumn                   = 26; % fread(fid, 1, 'uint16');
MDH_ushDummy                                = 27; % fread(fid, 1, 'uint16');      % 64 + 2 * 2 = 68
MDH_fReadOutOffcentre                       = 28; % fread(fid, 1, 'float');       % 68 + 4 = 72
MDH_ulTimeSinceLastRF                       = 29; % fread(fid, 1, 'uint32');
MDH_ushKSpaceCentreLineNo                   = 30; % fread(fid, 1, 'uint16');
MDH_ushKSpaceCentrePartitionNo              = 31; % fread(fid, 1, 'uint16');      % 72 + 4 + 2 + 2 = 80

MDH_aushIceProgramPara1              = 32; % fread(fid, 1, 'uint16');      % 80 + 4 * 2 = 88
MDH_aushIceProgramPara2              = 33; % fread(fid, 1, 'uint16');
MDH_aushIceProgramPara3              = 34; % fread(fid, 1, 'uint16');
MDH_aushIceProgramPara4              = 35; % fread(fid, 1, 'uint16');

MDH_aushFreePara1                       = 36; % fread(fid, 1, 'uint16');      % 88 + 4 * 2 = 96
MDH_aushFreePara2                       = 37; % fread(fid, 1, 'uint16');
MDH_aushFreePara3                       = 38; % fread(fid, 1, 'uint16');
MDH_aushFreePara4                       = 39; % fread(fid, 1, 'uint16');

MDH_sSD_sVector_flSag                       = 40; % fread(fid, 1, 'float');
MDH_sSD_sVector_flCor                       = 41; % fread(fid, 1, 'float');
MDH_sSD_sVector_flTra                       = 42; % fread(fid, 1, 'float');       % 96 + 3 * 4 = 108

MDH_aflQuaternion1                   = 43; % fread(fid, 1, 'float');       % 108 + 4 * 4 = 124
MDH_aflQuaternion2                   = 44; % fread(fid, 1, 'float');
MDH_aflQuaternion3                   = 45; % fread(fid, 1, 'float');
MDH_aflQuaternion4                   = 46; % fread(fid, 1, 'float');

MDH_ulChannelId                             = 47; % fread(fid, 1, 'uint16');      % 124 + 2 = 126
MDH_ushPTABPosNeg                           = 48; % -fread(fid, 1, 'uint16');      % 126 + 2 = 128 OK!

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

if donotAvg
    flag_avged_full_raw = [];
else
    flag_avged_full_raw = '_avged';
end

PathFIleName_of_saved_full_raw_file = [pathnameSS,'Raw_Data_VB15/',filenameSS,...
    '_full_raw',flag_avged_full_raw,mySiemensRead_version,'.mat'];

if ~reprocess
    set(figHndl.text2,'string','Checking saved raw...');
    drawnow
    disp('Checking saved raw...')
        
    
    fid_full_raw = fopen(PathFIleName_of_saved_full_raw_file);
    exist_full_raw_file = (fid_full_raw~=-1); % no file -> 0

    
    if exist_full_raw_file
        
        fclose(fid_full_raw);
        disp('--------------------------------')
        disp('Same version of processed full-raw data is exist.')
        disp('Just save to seperate files.')
        disp('--------------------------------')
        disp('Loading full-raw data...')
        
        set(figHndl.text2,'string','Loading saved raw,,,');
        
        set(figHndl.pushbutton_cancel,'enable','off')
        drawnow;
        
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
    
end

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

readMDHmatsome(fid);
while isempty(nx)

    cur_nx = mMDH(MDH_ushSamplesInScan);
    
    % % read ADC data -> saved column vector
%     temp = single(fread(fid,cur_nx*2,'float32'));  % *2 -> real and imag data

    % skip (ADC data) from cof (Current position in file) in [Byte]
    fseek(fid,cur_nx*2*4,'cof');  % *4 -> float32


    % ---------- save ADC data to different variable -----------------
    % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    % if don't know, use above default structure

    % noise data
    % structure : (ny,nx,nc)
    if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_NOISEADJSCAN)
%         noise_data(cur_y,:,cur_c) = temp;

        % phase correction data
        % structure : {nphase,nset,nr,ne,ns,na} [ny,nx,nz,nc]
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_PHASCOR)
%         phcor_data_cell{cur_phase,cur_set,cur_r,cur_e,cur_s,cur_a}(cur_y,:,cur_z,cur_c) = temp;
        
        
        % synchroneous data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_SYNCDATA)
% %         sync_data(cur_y,:,cur_z,cur_c,...
% %             cur_s,cur_e,cur_r,cur_set) = temp;
%         sync_data = [sync_data,temp];   % i found this flag in %AdjustSeq%/AdjCoilSensSeq

        % reference phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_REFPHASESTABSCAN)
%         refphstabscan_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_PHASESTABSCAN)
%         phstabscan_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data HPFEEDBACK
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_HPFEEDBACK)
%         navHP_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data RTFEEDBACK
        % structure : (ny,nx,nc)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_RTFEEDBACK)
%         navRT_data(cur_y,:,cur_c) = temp;

        % image raw data
        % structure : {ny,nz,na} [nx,ns,ne,nr,nset,nphase,nc]
        % NOTE : this structure is most effective memory savings when considering
        % zero-padding AND for double valued average factor
    else
%         cur_c = mMDH(MDH_ulChannelId)+1;
%         
%         % seperate each coil to cell to avoid 'Out of Memory'
%         if cur_c ~= cp_coil_index    % did not include CP coil
           
            %------- get larger index -----------------
            nx = cur_nx;
            nc = mMDH(MDH_ushUsedChannels);
            %-------------------------------------------
            
%         end

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

    readMDHmatsome(fid);   % read MDH before next loop
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


%% *********** Procsessing ****************

delete(get(figHndl.axes_waitbar,'children'));
drawnow;

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

readMDHmat(fid);
while ~bitget(mMDH(MDH_aulEvalInfoMask1),MDH_ACQEND)


    cur_nx = mMDH(MDH_ushSamplesInScan);
    cur_KspaceCenterCol = mMDH(MDH_ushKSpaceCentreColumn);

    % modified at 2009.05.22
    % cur_KspaceCenterCol : means index of current vector
%     if cur_KspaceCenterCol>0
%         num_zero_padding = cur_nx/2 - cur_KspaceCenterCol;
%     else
%         num_zero_padding = 0;
%     end
    % modified at 2009.09.29
    num_zero_padding = cur_nx - cur_KspaceCenterCol*2;

    % read ADC data -> saved column vector
    temp = single(fread(fid,cur_nx*2,'*float32'));  % *2 -> real and imag data
    % make it complex and save to matrix
    temp = complex(temp(1:2:end),temp(2:2:end));

    % modified at 2009.05.22
    % zero filling to locate echo center
    % but total # of readout samples is unchanged
%     if num_zero_padding>0
%         temp = [zeros(num_zero_padding,1,'single');temp(1:end-num_zero_padding)];
%     elseif num_zero_padding<0
%         temp = [temp(num_zero_padding+1:end);zeros(-num_zero_padding,1,'single')];
%     end
    % modified at 2009.09.29
    % zero filling to locate echo center
    if num_zero_padding>0
        temp = [zeros(num_zero_padding,1,'single');temp];
    elseif num_zero_padding<0
        temp = [temp;zeros(-num_zero_padding,1,'single')];
    end

    cur_preCut = mMDH(MDH_sCutOff_ushPre);
    cur_postCut = mMDH(MDH_sCutOff_ushPost);

    % replace zeros to ADC data
    temp(1:1+cur_preCut-1) = 0;
    temp(end-cur_postCut+1:end) = 0;

    % consider sign reversal
    if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_SIGNREV)
        temp = -temp;
    end

    % consider time reversal (EPI)
    if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_REFLECT)
        temp = flipud(temp);
    end

    cur_c = mMDH(MDH_ulChannelId)+1;

    if cur_c<=size(rawcorr,1)
        % consider FFTscale
        temp = temp*rawcorr(cur_c,1);

        % consider RawDataCorrection
        if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_RAWDATACORRECTION)
            temp = temp*rawcorr(cur_c,2);
        end
    end

    cur_a = mMDH(MDH_sLC_ushAcquisition)+1;  % just add if this >1
    cur_e = mMDH(MDH_sLC_ushEcho)+1;
    cur_s = org_s(mMDH(MDH_sLC_ushSlice)+1); % reorder slice
    cur_seg = mMDH(MDH_sLC_ushSeg)+1;
    cur_z = mMDH(MDH_sLC_ushPartition)+1;
    cur_y = mMDH(MDH_sLC_ushLine)+1;
    cur_r = mMDH(MDH_sLC_ushRepetition)+1;
    cur_set = mMDH(MDH_sLC_ushSet)+1;
    cur_usedCh = mMDH(MDH_ushUsedChannels);
    % added at 2009.05.25
    cur_phase = mMDH(MDH_sLC_ushPhase)+1;
    
    cur_timeStamp = mMDH(MDH_ulPMUTimeStamp);

    if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_TREFFECTIVEBEGIN)...
            && cur_c==1 && cur_seg==1 && ~isTReffBegin && ~isTReffEnd
        beginTimeTReff = cur_timeStamp;
        isTReffBegin = 1;
        
        if ~isempty(timeTReff) % begin - end
            index_timeTReff = index_timeTReff+1;
            timeTReff{index_timeTReff,1} = [beginTimeTReff-endTimeTReff,(beginTimeTReff-endTimeTReff)*2.5];
        end
    end
    
    if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_TREFFECTIVEEND)...
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
    if bitget(mMDH(MDH_aulEvalInfoMask1),MDH_NOISEADJSCAN)
        noise_data(cur_y,:,cur_c) = temp;

        % phase correction data
        % structure : {nphase,nset,nr,ne,ns,na} [ny,nx,nz,nc]
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_PHASCOR)
        phcor_data_cell{cur_phase,cur_set,cur_r,cur_e,cur_s,cur_a}(cur_y,:,cur_z,cur_c) = temp;
        
        
        % synchroneous data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_SYNCDATA)
%         sync_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set) = temp;
        index_sync_data = index_sync_data+1;
        sync_data{1,index_sync_data} = temp;   % i found this flag in %AdjustSeq%/AdjCoilSensSeq

        % reference phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_REFPHASESTABSCAN)
        refphstabscan_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_PHASESTABSCAN)
        phstabscan_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data HPFEEDBACK
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset,nphase,na)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_HPFEEDBACK)
        navHP_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set,cur_phase,cur_a) = temp;

        % navgator echo data RTFEEDBACK
        % structure : (ny,nx,nc)
    elseif bitget(mMDH(MDH_aulEvalInfoMask1),MDH_RTFEEDBACK)
        navRT_data(cur_y,:,cur_c) = temp;

        if cur_c==1 && is_triggered && ~isempty(endTimeShot)
            beginTimeNav = cur_timeStamp;
            index_time_btwShot_Nav = index_time_btwShot_Nav+1;
            time_btwShot_Nav{index_time_btwShot_Nav,1} = [beginTimeNav-endTimeShot,(beginTimeNav-endTimeShot)*2.5];
            endTimeShot = single([]);
        end
        
        if cur_usedCh==cur_c && bitget(mMDH(MDH_aulEvalInfoMask1),MDH_PHASEFFT)
            

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
        % structure : {nc,ns,na,ne,nr,nset,nphase} [ny,nx,nz]
        % NOTE :
    else
        raw_KSpaceCentreLineNo = mMDH(MDH_ushKSpaceCentreLineNo);
        raw_KSpaceCentrePartitionNo = mMDH(MDH_ushKSpaceCentrePartitionNo);
        raw_RO_PE_swapped = bitget(mMDH(MDH_aulEvalInfoMask1),MDH_SWAPPED);
        %         raw_usedCh = cur_usedCh;

        % seperate each coil to cell to avoid 'Out of Memory'
        if cur_c ~= cp_coil_index    % did not include CP coil
            
            if ~donotAvg && (cur_a>1 || mMDH(MDH_aushFreePara1) == 302) 
                
                try
                    % --------- save acq index to average
                    avg_cell{cur_c,cur_s,1,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,1,cur_z) = avg_cell{cur_c,cur_s,1,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,1,cur_z) + 1;                    
                    % ------ add raw
                    % ADC data (temp) -> saved column vector
                    raw{cur_c,cur_s,1,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,:,cur_z) = raw{cur_c,cur_s,1,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,:,cur_z) + temp.';
                    
                catch %-- in case of first appeared (mMDH(MDH_aushFreePara1) == 302)
                    
                    avg_cell{cur_c,cur_s,1,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,1,cur_z) = 1;                    
                    % save raw
                    raw{cur_c,cur_s,1,cur_e,cur_r,cur_set,cur_phase}...                        
                        (cur_y,:,cur_z) = temp;
                end
                                
            else % if donotAvg==1, sepatate acq

                avg_cell{cur_c,cur_s,cur_a,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,1,cur_z) = 1;                
                % save raw
                raw{cur_c,cur_s,cur_a,cur_e,cur_r,cur_set,cur_phase}...
                        (cur_y,:,cur_z) = temp;
            end
            
%             if cur_c==1
%                 fprintf('y=%d, z=%d, a=%d, s=%d, e=%d, r=%d, set=%d, p=%d \n',...
%                     cur_y,cur_z,cur_a,cur_s,cur_e,cur_r,cur_set,cur_phase);
%             end
        end
        
        endTimeShot = cur_timeStamp;

        % --------- save projection line --------------------------------
        if mMDH(MDH_aushFreePara1) == 302
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

    readMDHmat(fid);   % read MDH before next loop
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

patch(xpatch,ypatch,'b','EdgeColor','b','parent',figHndl.axes_waitbar); %,'EraseMode','none');
drawnow;
% ------------------------------------------------

set(figHndl.text2,'string',[filenameSS,'.dat']);
drawnow

dispetime(clock,t1);

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
    
    [nc,ns,na,ne,nr,nset,nphase] = size(raw);
    [ny,nx,nz] = size(raw{1});
    
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
    
    [nc,ns,na,ne,nr,nset,nphase] = size(raw);
    [ny,nx,nz] = size(raw{1});

    if ~donotAvg && na>1
        
        t1=clock;
        disp('Averaging...')
        
        for lc = 1:nc
            for ls = 1:ns
                for la = 1:na
                    for le = 1:ne
                        for lr = 1:nr
                            for lset = 1:nset
                                for lphase = 1:nphase                                    
                                    for ly = 1:ny
                                        for lz = 1:nz
                                            % just divide to avg_cell
                                            if ~isempty(raw{lc,ls,la,le,lr,lset,lphase})
                                                raw{lc,ls,la,le,lr,lset,lphase}...
                                                    (ly,:,lz) = raw{lc,ls,la,le,lr,lset,lphase}...
                                                    (ly,:,lz)/avg_cell{lc,ls,la,le,lr,lset,lphase}...
                                                    (ly,1,lz);
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

        avg_mat = cell2mat(avg_cell);
        clear avg_cell
        
        avg_mat = avg_mat(:);
        image_spec_MDH.nacq_double = sum(avg_mat)/sum(avg_mat>0);
        
%         assignin('base','avg_mat',avg_mat);
        clear avg_mat
        
        dispetime(clock,t1)
    end
    
    
    

%% consider KyCenter & KzCenter

    disp('consider KyCenter & KzCenter...')
    
    % save initial ky,kz size
    index_y = [1;ny];
    index_z = [1;nz];

    num_zero_padding = ny - 2*raw_KSpaceCentreLineNo;

    % zero filling to locate CentreLine center
    if num_zero_padding>0
        index_y = index_y + num_zero_padding;
        ny = ny + num_zero_padding;
    elseif num_zero_padding<0
        ny = ny + num_zero_padding;
    end

    if nz>1
        num_zero_padding = nz - 2*raw_KSpaceCentrePartitionNo;

        % zero filling to locate CentreLine center
        if num_zero_padding>0
            index_z = index_z + num_zero_padding;
            nz = nz + num_zero_padding;
        elseif num_zero_padding<0
            nz = nz + num_zero_padding;
        end

    end

%% consider PE Resolution & slice Resolution

    disp('consider PE Resolution & slice Resolution...')
    
    % ---- get resolution
    RO_pixel_size = image_spec.FOVro/(nx/image_spec.read_os);    
    PE_pixel_size_original = image_spec.FOVpe/ny;
    Th_pixel_size_original = image_spec.thick/nz;
    
    % make iso-pixel    
    ny_ima_mat = round(image_spec.FOVpe/RO_pixel_size);

    % note -- 얻은 PE line 이 더 크면 resolution 고려, 나눠주기?

    num_zero_padding = ny_ima_mat - ny;
    num_zero_padding = round(num_zero_padding/2);

    % zero filling to fit PE resolution
    if num_zero_padding>0
        index_y = index_y + num_zero_padding;
        ny = ny + num_zero_padding*2;
    end

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
            index_z = index_z + num_zero_padding;
            nz = nz + num_zero_padding*2;
        end

    end
    
    PE_pixel_size = image_spec.FOVpe/ny;
    Th_pixel_size = image_spec.thick/nz;

%% save full raw data

    set(figHndl.text2,'string','Saving full raw...');
    drawnow

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
    
    image_spec_MDH.index_y = index_y;
    image_spec_MDH.index_z = index_z;
    image_spec_MDH.mySiemensRead_version = mySiemensRead_version;
    
    image_spec_MDH.RO_pixel_size = RO_pixel_size;
    image_spec_MDH.PE_pixel_size_original = PE_pixel_size_original;
    image_spec_MDH.Th_pixel_size_original = Th_pixel_size_original;
    image_spec_MDH.PE_pixel_size = PE_pixel_size;
    image_spec_MDH.Th_pixel_size = Th_pixel_size;
    
    image_spec_MDH.ny_res = image_spec.ny_res;
    image_spec_MDH.nz_res = image_spec.nz_res;

    if donotAvg || image_spec_MDH.nacq_double==1
        raw_is_avged_text = '- Raw data is not Averaged.';
        image_spec_MDH.raw_is_avged = 0;
    else
        raw_is_avged_text = sprintf('- Raw data is Averaged by factor of %g.',image_spec_MDH.nacq_double);
        image_spec_MDH.raw_is_avged = 1;        
    end
    
    struct_raw = whos('raw');
    full_raw_FileSizeMBytes = struct_raw.bytes/1e6;
    
    raw_info_text = strvcat(' ',...
        '---------------------------------------------',...
        sprintf('\t\tRAW data information'),...
        '---------------------------------------------',...
        'full_raw data structure : {nc,ns,na,ne,nr,nset,nphase} [ny,nx,nz]',...
        ' ',...
        sprintf(' - Full Raw data size = %g [MBytes]',full_raw_FileSizeMBytes),...
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
    
    if full_raw_FileSizeMBytes > 2000
        disp('Matlab can save file larger than 2GB in Version 7.3 or later')
        try
            save(PathFIleName_of_saved_full_raw_file,...
                 'image_spec_MDH','image_spec','raw_info_text','-v7.3');
        %                'raw','image_spec_MDH','image_spec','raw_info_text','-v7.3');

            
        catch
            try
                save(PathFIleName_of_saved_full_raw_file,...
                     'image_spec_MDH','image_spec','raw_info_text'); 
            %                    'raw','image_spec_MDH','image_spec','raw_info_text');
               
            catch
                disp('Cannot save file.')
            end
        end
    else
        save(PathFIleName_of_saved_full_raw_file,...
        'image_spec_MDH','image_spec','raw_info_text');
 %orig           'raw','image_spec_MDH','image_spec','raw_info_text');    
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

    clear mMDH

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
    clear cur_phase
    

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
        
        index_y = image_spec_MDH.index_y;
        index_z = image_spec_MDH.index_z;
        mySiemensRead_version = image_spec_MDH.mySiemensRead_version;
        
%% Seperate full-raw
        is_full_raw = 1; % raw is full-raw
        
        struct_raw = whos('raw');
        full_raw_FileSizeMBytes = struct_raw.bytes/1e6;
    
        fprintf(' - Full Raw data size = %g [MBytes]\n',full_raw_FileSizeMBytes)
        
        %----------- check available physical memory
        [user sys] = memory;
        available_phMEMSizeMBytes = sys.PhysicalMemory.Available/1e6;        
        fprintf(' - Available physical memory : %g [MBytes]\n',available_phMEMSizeMBytes)
        
        %---------- calculate needed memory
        if nz>1 % 3D data
            if make_3DwithCoil
                needed_memory_sizeMBytes = ny*nx*nz*nc*8*3/1e6;
            else
                needed_memory_sizeMBytes = ny*nx*nz*8*3/1e6;
            end   
        else % 2D data
            needed_memory_sizeMBytes = ny*nx*nc*8*3/1e6;
        end
        fprintf(' - Needed memory size (raw, image, FFT): %g [MBytes]\n',needed_memory_sizeMBytes)
        
        do_separate_full_raw = available_phMEMSizeMBytes < needed_memory_sizeMBytes;
        disp(' ')
        
        %---------- if memory is insufficient
        if do_separate_full_raw
            
            disp('Not enough Available physical memory.')
            disp('Process will save to seperate files.')
            disp('Saving...')
            
            is_full_raw = 0; % raw is seperated-raw
            
            % save seperate file
            if nz>1 % in 3D, to each coil
                for c=1:nc
                    if c<10
                        add0c = '00';
                    elseif c<100
                        add0c = '0';
                    else
                        add0c = '';
                    end
                    for s = 1:ns
                        if s<10
                            add0s = '00';
                        elseif s<100
                            add0s = '0';
                        else
                            add0s = '';
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
                            
                            for e = 1:ne
                                if e<10
                                    add0e = '00';
                                elseif e<100
                                    add0e = '0';
                                else
                                    add0e = '';
                                end
                                for r = 1:nr
                                    if r<10
                                        add0r = '00';
                                    elseif r<100
                                        add0r = '0';
                                    else
                                        add0r = '';
                                    end
                                    for i_set = 1:nset
                                        if i_set<10
                                            add0set = '00';
                                        elseif i_set<100
                                            add0set = '0';
                                        else
                                            add0set = '';
                                        end
                                        for iphase = 1:nphase
                                            if iphase<10
                                                add0p = '00';
                                            elseif iphase<100
                                                add0p = '0';
                                            else
                                                add0p = '';
                                            end
                                            
                                            raw_part0rg = raw{c,s,ia,e,r,i_set,iphase};
                                            
                                            disp(['Saving raw separately... ',...
                                                'raw_part0rg',mySiemensRead_version,...
                                                '_a',add0a,num2str(ia),...
                                                '_r',add0r,num2str(r),...
                                                '_set',add0set,num2str(i_set),...
                                                '_p',add0p,num2str(iphase),...
                                                '_e',add0e,num2str(e),...
                                                '_s',add0s,num2str(s),...
                                                '_c',add0c,num2str(c)])
%                                             save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
%                                                 '_raw_part0rg',mySiemensRead_version,...
%                                                 '_a',add0a,num2str(ia),...
%                                                 '_r',add0r,num2str(r),...
%                                                 '_set',add0set,num2str(i_set),...
%                                                 '_p',add0p,num2str(iphase),...
%                                                 '_e',add0e,num2str(e),...
%                                                 '_s',add0s,num2str(s),...
%                                                 '_c',add0c,num2str(c),'.mat'],...
%                                                 'raw_part0rg','image_spec_MDH','image_spec','raw_info_text');
%                                             
                                            % check user cancel
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
                
                clear raw_part0rg
                
            else % in 2D, to each slice
                
                for s = 1:ns
                    if s<10
                        add0s = '00';
                    elseif s<100
                        add0s = '0';
                    else
                        add0s = '';
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
                        
                        for e = 1:ne
                            if e<10
                                add0e = '00';
                            elseif e<100
                                add0e = '0';
                            else
                                add0e = '';
                            end
                            for r = 1:nr
                                if r<10
                                    add0r = '00';
                                elseif r<100
                                    add0r = '0';
                                else
                                    add0r = '';
                                end
                                for i_set = 1:nset
                                    if i_set<10
                                        add0set = '00';
                                    elseif i_set<100
                                        add0set = '0';
                                    else
                                        add0set = '';
                                    end
                                    for iphase = 1:nphase
                                        if iphase<10
                                            add0p = '00';
                                        elseif iphase<100
                                            add0p = '0';
                                        else
                                            add0p = '';
                                        end
                                        
                                        raw_part0rgAllCoil = raw(:,s,ia,e,r,i_set,iphase);
                                        
                                        disp(['Saving raw  separately... ',...
                                            'raw_part0rgAllCoil',mySiemensRead_version,...
                                            '_a',add0a,num2str(ia),...
                                            '_r',add0r,num2str(r),...
                                            '_set',add0set,num2str(i_set),...
                                            '_p',add0p,num2str(iphase),...
                                            '_e',add0e,num2str(e),...
                                            '_s',add0s,num2str(s),...
                                            ])
%                                         save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
%                                             '_raw_part0rgAllCoil',mySiemensRead_version,...
%                                             '_a',add0a,num2str(ia),...
%                                             '_r',add0r,num2str(r),...
%                                             '_set',add0set,num2str(i_set),...
%                                             '_p',add0p,num2str(iphase),...
%                                             '_e',add0e,num2str(e),...
%                                             '_s',add0s,num2str(s),...
%                                             '.mat'],...
%                                             'raw_part0rgAllCoil','image_spec_MDH','image_spec','raw_info_text');
%                                         
                                        % check user cancel
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
                
                clear raw_part0rgAllCoil
                
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
            
                
            for s = 1:ns
                if s<10
                    add0s = '00';
                elseif s<100
                    add0s = '0';
                else
                    add0s = '';
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
                    
                    for e = 1:ne
                        if e<10
                            add0e = '00';
                        elseif e<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for r = 1:nr
                            if r<10
                                add0r = '00';
                            elseif r<100
                                add0r = '0';
                            else
                                add0r = '';
                            end
                            for i_set = 1:nset
                                if i_set<10
                                    add0set = '00';
                                elseif i_set<100
                                    add0set = '0';
                                else
                                    add0set = '';
                                end
                                for iphase = 1:nphase
                                    if iphase<10
                                        add0p = '00';
                                    elseif iphase<100
                                        add0p = '0';
                                    else
                                        add0p = '';
                                    end
                                    
                                    if make_3DwithCoil
                                        % make 3D data with coils -> 4D matrix
                                            
                                        for c = 1:nc
                                            if c<10
                                                add0c = '00';
                                            elseif c<100
                                                add0c = '0';
                                            else
                                                add0c = '';
                                            end
                                            
                                            if is_full_raw
                                                if ~isempty(raw{c,s,ia,e,r,i_set,iphase})
                                                    raw_part(index_y(1):index_y(2),:,index_z(1):index_z(2),c)...
                                                        = raw{c,s,ia,e,r,i_set,iphase};
                                                end
                                            else
                                                disp(['Loading seperated raw... ',...
                                                    'raw_part0rg',mySiemensRead_version,...
                                                    '_a',add0a,num2str(ia),...
                                                    '_r',add0r,num2str(r),...
                                                    '_set',add0set,num2str(i_set),...
                                                    '_p',add0p,num2str(iphase),...
                                                    '_e',add0e,num2str(e),...
                                                    '_s',add0s,num2str(s),...
                                                    '_c',add0c,num2str(c)])
                                                load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                    '_raw_part0rg',mySiemensRead_version,...
                                                    '_a',add0a,num2str(ia),...
                                                    '_r',add0r,num2str(r),...
                                                    '_set',add0set,num2str(i_set),...
                                                    '_p',add0p,num2str(iphase),...
                                                    '_e',add0e,num2str(e),...
                                                    '_s',add0s,num2str(s),...
                                                    '_c',add0c,num2str(c),'.mat'],'raw_part0rg')
                                                
                                                if ~isempty(raw_part0rg)
                                                    raw_part(index_y(1):index_y(2),:,index_z(1):index_z(2),c)...
                                                        = raw_part0rg;
                                                end
                                                clear raw_part0rg
                                            end % end of 'if is_full_raw'
                                            
                                            drawnow;
                                            if cancel_process
                                                disp('Processing canceled.')
                                                return;
                                            end
                                            
                                        end % end of coil (nc) iteration
                                        
                                        disp('Saving 3D raw (4D : 3D with coils) to file...')
                                        %----- save raw to .mat file
                                        if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                            mkdir([pathnameSS,'Raw_Data_VB15'])
                                        end
                                        
                                        save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                            '_raw',mySiemensRead_version,...
                                            '_a',add0a,num2str(ia),...
                                            '_r',add0r,num2str(r),...
                                            '_set',add0set,num2str(i_set),...
                                            '_p',add0p,num2str(iphase),...
                                            '_e',add0e,num2str(e),...
                                            '_s',add0s,num2str(s),...
                                            '.mat'],'raw_part','image_spec_MDH','image_spec','raw_info_text');
                                        %----------------------------------
                                        %-----
                                        
                                        drawnow;
                                        if cancel_process
                                            disp('Processing canceled.')
                                            return;
                                        end
                                        
                                        %----------- check available physical memory befor FFT
                                        disp('Check available physical memory for FFT...')
                                        [user sys] = memory;
                                        available_phMEMSizeMBytes = sys.PhysicalMemory.Available/1e6;
                                        fprintf(' - Available physical memory : %g [MBytes]\n',available_phMEMSizeMBytes)
                                        needed_memory_sizeMBytes4FFT = needed_memory_sizeMBytes*2/3;
                                        fprintf(' - Needed memory size (image, FFT): %g [MBytes]\n',needed_memory_sizeMBytes4FFT)
                                        
                                        if available_phMEMSizeMBytes > needed_memory_sizeMBytes4FFT
                                            disp('Now, evaluate FFT...')
                                            im = fft3c(raw_part,11);
                                        else
                                            disp('Not enough memory for FFT.')
                                            clear raw_part
                                            im = complex(zeros(ny,nx,nz,nc,'single'));
                                            raw_temp = complex(zeros(ny,nx,nz,'single'));
                                            
                                            for c = 1:nc
                                                if c<10
                                                    add0c = '00';
                                                elseif c<100
                                                    add0c = '0';
                                                else
                                                    add0c = '';
                                                end
                                                disp(['Loading seperated raw... ',...
                                                    'raw_part0rg',mySiemensRead_version,...
                                                    '_a',add0a,num2str(ia),...
                                                    '_r',add0r,num2str(r),...
                                                    '_set',add0set,num2str(i_set),...
                                                    '_p',add0p,num2str(iphase),...
                                                    '_e',add0e,num2str(e),...
                                                    '_s',add0s,num2str(s),...
                                                    '_c',add0c,num2str(c)])
                                                load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                    '_raw_part0rg',mySiemensRead_version,...
                                                    '_a',add0a,num2str(ia),...
                                                    '_r',add0r,num2str(r),...
                                                    '_set',add0set,num2str(i_set),...
                                                    '_p',add0p,num2str(iphase),...
                                                    '_e',add0e,num2str(e),...
                                                    '_s',add0s,num2str(s),...
                                                    '_c',add0c,num2str(c),'.mat'],'raw_part0rg')
                                                
                                                raw_temp(index_y(1):index_y(2),:,index_z(1):index_z(2))...
                                                    = raw_part0rg;
                                                
                                                fprintf('Now, evaluate FFT of coil_%s%d...\n',add0c,c)
                                                im(:,:,:,c) = fft3c(raw_temp);
                                                
                                            end % end of coil (nc) iteration
                                            clear raw_part0rg
                                            clear raw_temp
                                        end
                                        
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
                                        
%                                         disp('Saving 3D image (4D : 3D with coils) to file...')
%                                         %----- save image to .mat file
%                                         if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
%                                             mkdir([pathnameSS,'Reconstructed_Data_VB15'])
%                                         end
%                                         
%                                         save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
%                                             '_image',mySiemensRead_version,...
%                                             '_a',add0a,num2str(ia),...
%                                             '_r',add0r,num2str(r),...
%                                             '_set',add0set,num2str(i_set),...
%                                             '_p',add0p,num2str(iphase),...
%                                             '_e',add0e,num2str(e),...
%                                             '_s',add0s,num2str(s),...
%                                             '.mat'],'im','image_spec_MDH','image_spec','raw_info_text');
%                                         %----------------------------------------
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
                                            
                                            
                                            if is_full_raw
                                                if ~isempty(raw{c,s,ia,e,r,i_set,iphase})
                                                    raw_part(index_y(1):index_y(2),:,index_z(1):index_z(2))...
                                                        = raw{c,s,ia,e,r,i_set,iphase};
                                                end
                                            else
                                                disp(['Loading seperated raw... ',...
                                                    'raw_part0rg',mySiemensRead_version,...
                                                    '_a',add0a,num2str(ia),...
                                                    '_r',add0r,num2str(r),...
                                                    '_set',add0set,num2str(i_set),...
                                                    '_p',add0p,num2str(iphase),...
                                                    '_e',add0e,num2str(e),...
                                                    '_s',add0s,num2str(s),...
                                                    '_c',add0c,num2str(c)])
                                                load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                    '_raw_part0rg',mySiemensRead_version,...
                                                    '_a',add0a,num2str(ia),...
                                                    '_r',add0r,num2str(r),...
                                                    '_set',add0set,num2str(i_set),...
                                                    '_p',add0p,num2str(iphase),...
                                                    '_e',add0e,num2str(e),...
                                                    '_s',add0s,num2str(s),...
                                                    '_c',add0c,num2str(c),'.mat'],'raw_part0rg')
                                                
                                                if ~isempty(raw_part0rg)
                                                    raw_part(index_y(1):index_y(2),:,index_z(1):index_z(2))...
                                                        = raw_part0rg;
                                                end
                                                clear raw_part0rg
                                            end % end of 'if is_full_raw'
                                                
                                            
                                            disp(['Saving ',num2str(c),'th 3D raw (3D without coils) to file...'])
                                            %----- save raw to .mat file
                                            if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                                mkdir([pathnameSS,'Raw_Data_VB15'])
                                            end
                                            
                                            save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                                '_raw',mySiemensRead_version,...
                                                '_a',add0a,num2str(ia),...
                                                '_r',add0r,num2str(r),...
                                                '_set',add0set,num2str(i_set),...
                                                '_p',add0p,num2str(iphase),...
                                                '_e',add0e,num2str(e),...
                                                '_s',add0s,num2str(s),...
                                                '_c',add0c,num2str(c),'.mat'],...
                                                'raw_part','image_spec_MDH','image_spec','raw_info_text');
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
                                                '_image',mySiemensRead_version,...
                                                '_a',add0a,num2str(ia),...
                                                '_r',add0r,num2str(r),...
                                                '_set',add0set,num2str(i_set),...
                                                '_p',add0p,num2str(iphase),...
                                                '_e',add0e,num2str(e),...
                                                '_s',add0s,num2str(s),...
                                                '_c',add0c,num2str(c),'.mat'],...
                                                'im','image_spec_MDH','image_spec','raw_info_text');
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
            
            for s = 1:ns
                if s<10
                    add0s = '00';
                elseif s<100
                    add0s = '0';
                else
                    add0s = '';
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
                    
                    for e = 1:ne
                        if e<10
                            add0e = '00';
                        elseif e<100
                            add0e = '0';
                        else
                            add0e = '';
                        end
                        for r = 1:nr
                            if r<10
                                add0r = '00';
                            elseif r<100
                                add0r = '0';
                            else
                                add0r = '';
                            end
                            for i_set = 1:nset
                                if i_set<10
                                    add0set = '00';
                                elseif i_set<100
                                    add0set = '0';
                                else
                                    add0set = '';
                                end
                                for iphase = 1:nphase
                                    if iphase<10
                                        add0p = '00';
                                    elseif iphase<100
                                        add0p = '0';
                                    else
                                        add0p = '';
                                    end
                                    
                                                                        
                                    if is_full_raw
                                        for c=1:nc
                                            if ~isempty(raw{c,s,ia,e,r,i_set,iphase})
                                                raw_part(index_y(1):index_y(2),:,c)...
                                                    = raw{c,s,ia,e,r,i_set,iphase}(:,:,1);
                                            end
                                        end
                                    else
                                        disp(['Loading seperated raw... ',...
                                            'raw_part0rgAllCoil',mySiemensRead_version,...
                                            '_a',add0a,num2str(ia),...
                                            '_r',add0r,num2str(r),...
                                            '_set',add0set,num2str(i_set),...
                                            '_p',add0p,num2str(iphase),...
                                            '_e',add0e,num2str(e),...
                                            '_s',add0s,num2str(s),...
                                            ])
                                        load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                            '_raw_part0rgAllCoil',mySiemensRead_version,...
                                            '_a',add0a,num2str(ia),...
                                            '_r',add0r,num2str(r),...
                                            '_set',add0set,num2str(i_set),...
                                            '_p',add0p,num2str(iphase),...
                                            '_e',add0e,num2str(e),...
                                            '_s',add0s,num2str(s),...
                                            '.mat'],'raw_part0rgAllCoil')
                                            
                                        for c=1:nc
                                            if ~isempty(raw_part0rgAllCoil{c})
                                                raw_part(index_y(1):index_y(2),:,c)...
                                                    = raw_part0rgAllCoil{c};
                                            end
                                        end
                                        clear raw_part0rgAllCoil
                                    end
                                    
                                    disp('Saving raw to file...')
                                    %----- save raw to .mat file
                                    if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                        mkdir([pathnameSS,'Raw_Data_VB15'])
                                    end
                                    
                                    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                        '_raw',mySiemensRead_version,...
                                        '_a',add0a,num2str(ia),...
                                        '_r',add0r,num2str(r),...
                                        '_set',add0set,num2str(i_set),...
                                        '_p',add0p,num2str(iphase),...
                                        '_e',add0e,num2str(e),...
                                        '_s',add0s,num2str(s),...
                                        '.mat'],'raw_part','image_spec_MDH','image_spec','raw_info_text');
                                    %---------------------------------------
                                    
                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
                                        return;
                                    end
                                    
%                                     disp('Now, evaluate FFT...')
%                                     im = fft3c(raw_part,3);
%                                     if cut_RO_OS
%                                         im = im(:,nx/4+1:nx/4+nx/2,:);
%                                         % consider phase/readout swapp
%                                         if image_spec_MDH.RO_PE_swapped && ~donotSwapRO
%                                             im = permute(im,[2,1,3]);
%                                         end
%                                     end
%                                     
%                                     drawnow;
%                                     if cancel_process
%                                         disp('Processing canceled.')
%                                         return;
%                                     end
%                                     
%                                     disp('Saving image to file...')
%                                     %----- save image to .mat file
%                                     if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
%                                         mkdir([pathnameSS,'Reconstructed_Data_VB15'])
%                                     end
%                                     
%                                     save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
%                                         '_image',mySiemensRead_version,...
%                                         '_a',add0a,num2str(ia),...
%                                         '_r',add0r,num2str(r),...
%                                         '_set',add0set,num2str(i_set),...
%                                         '_p',add0p,num2str(iphase),...
%                                         '_e',add0e,num2str(e),...
%                                         '_s',add0s,num2str(s),...
%                                         '.mat'],'im','image_spec_MDH','image_spec','raw_info_text');
%                                     %----------------------------------------
%                                     disp('Done!')
%                                     clear im
                                    
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
                func_make_comp_im(image_spec,raw_info_text)
                disp(' ')
            catch ME
                disp(ME)
                disp(ME.stack(1))
                disp(ME.message)
                if ~isempty(strfind(ME.message,'HELP MEMORY'))
                    disp(' ')
                    disp('Not enough contiguous memory.')
                    disp('Try again, after you have enough memory.')
                    disp(' ')
                    
%                     err = lasterror;
%                     fprintf('Last error in "make & save composite image" ...\n')
%                     disp('-------------------------------------')
%                     fprintf('\t message: %s\n',err.message)
%                     fprintf('\t identifier: %s\n',err.identifier)
%                     fprintf('\t stack: ')
%                     disp(err.stack)
%                     disp(' ')
%                     disp('-------------------------------------')
                else
                    disp(' ')
                    disp('Unexpected error has occured.')
                end
            end
        end % end of make_comp_im

    end % end of function save_RawimaComp

end% end of function mySiemensRead_v2

%% function make_comp_im

function func_make_comp_im(image_spec,raw_info_text)
global cancel_process;
global make_3DwithCoil;
global image_spec_MDH;

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

mySiemensRead_version = image_spec_MDH.mySiemensRead_version;

% if nz>1 % 3D data
%     
%     try
%         % allocate memory
%         comp_im = complex(zeros(ny,nx,nz,'single'));
%         comp_mag_im = zeros(ny,nx,nz,'single');
%         temp_mag_im = comp_mag_im;
%         comp_ph_im = comp_im;
%         
%     catch ME
%         disp(ME)
%         disp(ME.stack(1))
%         disp(ME.message)
%         if ~isempty(strfind(ME.message,'HELP MEMORY'))
%             disp(' ')
%             disp('Not enough contiguous memory.')
%             disp('Try again, after you have enough memory.')
%             disp(' ')
%         end
%         return;
%     end
%     
%     for ia = 1:na
%         if ia<10
%             add0a = '00';
%         elseif ia<100
%             add0a = '0';
%         else
%             add0a = '';
%         end
%         if image_spec_MDH.raw_is_avged
%             add0a = 'vged';
%         end
%         
%         for iphase = 1:nphase
%             if iphase<10
%                 add0p = '00';
%             elseif iphase<100
%                 add0p = '0';
%             else
%                 add0p = '';
%             end
%             for i_set = 1:nset
%                 if i_set<10
%                     add0set = '00';
%                 elseif i_set<100
%                     add0set = '0';
%                 else
%                     add0set = '';
%                 end
%                 for r = 1:nr
%                     if r<10
%                         add0r = '00';
%                     elseif r<100
%                         add0r = '0';
%                     else
%                         add0r = '';
%                     end
%                     for e = 1:ne
%                         if e<10
%                             add0e = '00';
%                         elseif e<100
%                             add0e = '0';
%                         else
%                             add0e = '';
%                         end
%                         for s = 1:ns
%                             if s<10
%                                 add0s = '00';
%                             elseif s<100
%                                 add0s = '0';
%                             else
%                                 add0s = '';
%                             end
%                             
%                             if make_3DwithCoil
%                                 disp('Loading  3D image (4D : 3D without coils) file...')
%                                 disp([' - ','image',mySiemensRead_version,...
%                                     '_a',add0a,num2str(ia),...
%                                     '_r',add0r,num2str(r),...
%                                     '_set',add0set,num2str(i_set),...
%                                     '_p',add0p,num2str(iphase),...
%                                     '_e',add0e,num2str(e),...
%                                     '_s',add0s,num2str(s)])
%                                 load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
%                                     '_image',mySiemensRead_version,...
%                                     '_a',add0a,num2str(ia),...
%                                     '_r',add0r,num2str(r),...
%                                     '_set',add0set,num2str(i_set),...
%                                     '_p',add0p,num2str(iphase),...
%                                     '_e',add0e,num2str(e),...
%                                     '_s',add0s,num2str(s),...
%                                     '.mat'],'im');
%                                 
%                                 comp_mag_im = SOS(im);
%                                 comp_ph_im = sum(im,4);
%                             else
%                                 
%                                 for c = 1:nc
%                                     if c<10
%                                         add0c = '00';
%                                     elseif c<100
%                                         add0c = '0';
%                                     else
%                                         add0c = '';
%                                     end
%                                     disp(['Loading ',num2str(c),'th coil 3D image file...'])
%                                     disp([' - ','image',mySiemensRead_version,...
%                                         '_a',add0a,num2str(ia),...
%                                         '_r',add0r,num2str(r),...
%                                         '_set',add0set,num2str(i_set),...
%                                         '_p',add0p,num2str(iphase),...
%                                         '_e',add0e,num2str(e),...
%                                         '_s',add0s,num2str(s),...
%                                         '_c',add0c,num2str(c)])
%                                     load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
%                                         '_image',mySiemensRead_version,...
%                                         '_a',add0a,num2str(ia),...
%                                         '_r',add0r,num2str(r),...
%                                         '_set',add0set,num2str(i_set),...
%                                         '_p',add0p,num2str(iphase),...
%                                         '_e',add0e,num2str(e),...
%                                         '_s',add0s,num2str(s),...
%                                         '_c',add0c,num2str(c),'.mat'],'im');
%                                     
%                                     if c==1
%                                         temp_mag_im = mag(im);
%                                         temp_mag_im = temp_mag_im.*temp_mag_im;
%                                         comp_mag_im = temp_mag_im;
%                                         comp_ph_im = im;
%                                     else
%                                         
%                                         temp_mag_im = mag(im);
%                                         temp_mag_im = temp_mag_im.*temp_mag_im;
%                                         comp_mag_im = comp_mag_im+temp_mag_im;
%                                         comp_ph_im = comp_ph_im+im;
%                                     end
%                                     
%                                     drawnow;
%                                     if cancel_process
%                                         disp('Processing canceled.')
%                                         %                             cancel_process = 0;
%                                         return;
%                                     end
%                                     clear temp_mag_im
%                                     clear comp_im
%                                     clear im
%                                 end % end of coil iteration
%                                 
%                                 % why step-by-step operation is memory efficient than
%                                 % combined one-line operation ?
%                                 comp_mag_im = sqrt(comp_mag_im);
%                                 comp_ph_im = angle(comp_ph_im);
%                                 
%                             end % end of 'make_3DwithCoil'
%                             
%                             % make composite image (root-sum-of-squares
%                             % magnitude and complex summed phase)
%                             comp_im = comp_mag_im.*exp(j*comp_ph_im);
%                             
%                             disp('Saving composite image to file...')
%                             disp([' - ','Composite_image',mySiemensRead_version,...
%                                         '_a',add0a,num2str(ia),...
%                                         '_r',add0r,num2str(r),...
%                                         '_set',add0set,num2str(i_set),...
%                                         '_p',add0p,num2str(iphase),...
%                                         '_e',add0e,num2str(e),...
%                                         '_s',add0s,num2str(s)])
%                             % ------ save combined image to .mat file
%                             if ~isdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
%                                 mkdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
%                             end
%                             save([pathnameSS,'Reconstructed_Data_VB15/Composite_image/',filenameSS,...
%                                 '_Composite_image',mySiemensRead_version,...
%                                 '_a',add0a,num2str(ia),...
%                                 '_r',add0r,num2str(r),...
%                                 '_set',add0set,num2str(i_set),...
%                                 '_p',add0p,num2str(iphase),...
%                                 '_e',add0e,num2str(e),...
%                                 '_s',add0s,num2str(s),...
%                                 '.mat'],'comp_im','image_spec_MDH','image_spec','raw_info_text');
%                             disp('Done!')
%                             
%                             drawnow;
%                             if cancel_process
%                                 disp('Processing canceled.')
%                                 return;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% else    % 2D data (i.e. nz=1)
%     for ia = 1:na
%         if ia<10
%             add0a = '00';
%         elseif ia<100
%             add0a = '0';
%         else
%             add0a = '';
%         end
%         if image_spec_MDH.raw_is_avged
%             add0a = 'vged';
%         end
%         
%         for iphase = 1:nphase
%             if iphase<10
%                 add0p = '00';
%             elseif iphase<100
%                 add0p = '0';
%             else
%                 add0p = '';
%             end
%             for i_set = 1:nset
%                 if i_set<10
%                     add0set = '00';
%                 elseif i_set<100
%                     add0set = '0';
%                 else
%                     add0set = '';
%                 end
%                 for r = 1:nr
%                     if r<10
%                         add0r = '00';
%                     elseif r<100
%                         add0r = '0';
%                     else
%                         add0r = '';
%                     end
%                     for e = 1:ne
%                         if e<10
%                             add0e = '00';
%                         elseif e<100
%                             add0e = '0';
%                         else
%                             add0e = '';
%                         end
%                         for s = 1:ns
%                             if s<10
%                                 add0s = '00';
%                             elseif s<100
%                                 add0s = '0';
%                             else
%                                 add0s = '';
%                             end
%                             
%                             disp('Loading 2D image file...')
%                             load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
%                                 '_image',mySiemensRead_version,...
%                                 '_a',add0a,num2str(ia),...
%                                 '_r',add0r,num2str(r),...
%                                 '_set',add0set,num2str(i_set),...
%                                 '_p',add0p,num2str(iphase),...
%                                 '_e',add0e,num2str(e),...
%                                 '_s',add0s,num2str(s),...
%                                 '.mat']);
%                             
%                             comp_im = SOS(im).*exp(j*angle(sum(im,3)));
%                             clear im
%                             
%                             disp('Saving composite image to file...')
%                             % ------ save combined image to .mat file
%                             if ~isdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
%                                 mkdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
%                             end
%                             save([pathnameSS,'Reconstructed_Data_VB15/Composite_image/',filenameSS,...
%                                 '_Composite_image',mySiemensRead_version,...
%                                 '_a',add0a,num2str(ia),...
%                                 '_r',add0r,num2str(r),...
%                                 '_set',add0set,num2str(i_set),...
%                                 '_p',add0p,num2str(iphase),...
%                                 '_e',add0e,num2str(e),...
%                                 '_s',add0s,num2str(s),...
%                                 '.mat'],'comp_im','image_spec_MDH','image_spec','raw_info_text');
%                             disp('Done!')
%                             
%                             drawnow;
%                             if cancel_process
%                                 disp('Processing canceled.')
%                                 return;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
clear comp_im
end % end of function func_make_comp_im
