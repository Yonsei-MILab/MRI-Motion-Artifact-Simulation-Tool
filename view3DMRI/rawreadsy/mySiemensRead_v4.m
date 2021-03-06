function mySiemensRead_v4(image_spec)
%% Information
% Only works in conventional 2D(3D)FT sequence
% 
% Coded by cefca (Sang-Young Zho).
% All rights reserved in MI laboratory.
% Last modified at 2009.02.15
% 
% 매트릭스 더 쪼개
% segment index 수정
% pixel size (resolution) 고려
% considered FFTscale factor
%
% ---------- Futher work todo
%           seperate data to each Acq
%      
%     NOTE : Navigator image processing is almost done.

tic;
fprintf('\nmySiemensRead_v4()\n')

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
    if ~mod(image_spec.ns,2)% if even # of slices
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
sync_data = single([]); % readout contains synchroneous data
phcor_data_cell = single([]); % phase correction data

%--- user defiend data -------------------------------------------------
% that is projection line in TSE sequence if sMDH.aushFreePara(1) == 302
projLine_raw_cell = single([]);
%-----------------------------------------------------------------------


timeTReff = single([]); % save each TReff for PACE
timeTReff_info = strvcat('TReff for PACE',...
    '1st column : PMU time stamp difference',...
    '2nd column : Δtime (ms)');
timeTReff_info_4excel = {'ΔPMU time stamp','Δtime (ms)'};
beginTimeTReff = single([]);
endTimeTReff = single([]);

time_btwShot_Nav = single([]); % save time between image sequence and following Nav
time_btwShot_Nav_info = strvcat('time between image sequence and following Nav',...
    '1st column : PMU time stamp difference',...
    '2nd column : Δtime (ms)');
time_btwShot_Nav_info_4excel = {'ΔPMU time stamp','Δtime (ms)'};
endTimeShot = single([]);
startTimeShot = single([]);
beginTimeNav = single([]);

seg_indic = uint32([]);
% contain [echo train index,segment index,ky index, kz index,slice index]
seg_indic_info = strvcat('[seg_indic] matrix has',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : echo train index',...
    '5th column : segment index',...
    '6th column : ky (PE) index',...
    '7th column : kz (PE) index',...
    '8th column : slice   index');
seg_indic_info_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'echo train','segment','ky','kz','slice'};
nseg_column = 5;

seg_indic_4s1 = uint32([]);
% contain [echo train index,segment index,ky index, kz index]
seg_indic_info_4s1 = strvcat('[seg_indic_4s1] matrix has (for 1 slice)',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : echo train index',...
    '5th column : segment index',...
    '6th column : ky (PE) index',...
    '7th column : kz (PE) index');
seg_indic_info_4s1_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'echo train','segment','ky','kz'};

acq_indic = uint32([]);
% contain [echo train index,segment index,acq index,ky index, kz index,slice index]
acq_indic_info = strvcat('[acq_indic] matrix has',' ',...
    '1st column : PMU time stamp',...
    '2nd column : PMU time stamp difference',...
    '3rd column : rounded Δtime (ms)',...
    '4th column : echo train index',...
    '5th column : segment index',...
    '6th column : acq index',...
    '7th column : ky (PE) index',...
    '8th column : kz (PE) index',...
    '9th column : slice   index');
acq_indic_info_4excel = {'PMU time stamp','ΔPMU time stamp','Δtime (ms)',...
    'echo train','segment','acq','ky','kz','slice'};

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

fid_full_raw = fopen([pathnameSS,'Raw_Data_VB15/',filenameSS,...
    '_full_raw','.mat']);
exist_full_raw_file = (fid_full_raw~=-1); % no file -> 0

if exist_full_raw_file && ~reprocess
    fclose(fid_full_raw);
    disp('--------------------------------')
    disp('Processed full-raw data is exist~!')
    disp('Just save to seperate files.')
    disp('--------------------------------')
    disp('Loading full-raw data...')

    set(figHndl.pushbutton_cancel,'enable','off')
    drawnow;

    load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
        '_full_raw','.mat']);
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
    
    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

    image_spec_MDH.nc = nc;
    image_spec_MDH.nz = nz;
    image_spec_MDH.ns = ns;
    image_spec_MDH.ny = ny;
    image_spec_MDH.nx = nx;
    image_spec_MDH.ne = ne;
    image_spec_MDH.nr = nr;
    image_spec_MDH.nset = nset;

    disp(' ')
    disp('Data size :')
    fprintf('\timage (ky)x(kx)x(kz) : %dx%dx%d\n',ny,nx,nz)
    fprintf('\t# of slice : %d\n',ns)
    fprintf('\t# of coil : %d\n',nc)
    fprintf('\t# of echo : %d\n',ne)
    fprintf('\t# of repitetion : %d\n',nr)
    fprintf('\t# of set : %d\n',nset)
    disp(' ')

    drawnow;
    save_RawimaComp

    disp('=========================================================================')
    % eval('dispetime(toc,0);','disp(''Total ''),toc')
    dispetime(toc,0);
    disp('=========================================================================')

    fclose(fid);
    return;
end

%% *********** Procsessing ****************


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
%------------------------------------------

disp('Processing...')
axes(figHndl.axes_waitbar);

readMDH(fid);
while ~readEIM(sMDH.aulEvalInfoMask,'MDH_ACQEND')


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
    if readEIM(sMDH.aulEvalInfoMask,'MDH_SIGNREV')
        temp = -temp;
    end

    % consider time reversal (EPI)
    if readEIM(sMDH.aulEvalInfoMask,'MDH_REFLECT')
        temp = flipud(temp);
    end

    cur_c = sMDH.ulChannelId+1;

    if cur_c<=size(rawcorr,1)
        % consider FFTscale
        temp = temp*rawcorr(cur_c,1);

        % consider RawDataCorrection
        if readEIM(sMDH.aulEvalInfoMask,'MDH_RAWDATACORRECTION')
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
    
    cur_timeStamp = sMDH.ulPMUTimeStamp;

    if readEIM(sMDH.aulEvalInfoMask,'MDH_TREFFECTIVEBEGIN')...
            && cur_c==1 && cur_seg==1 && ~isTReffBegin && ~isTReffEnd
        beginTimeTReff = cur_timeStamp;
        isTReffBegin = 1;
        
        if ~isempty(timeTReff) % begin - end
            timeTReff = [timeTReff;...
                beginTimeTReff-endTimeTReff,(beginTimeTReff-endTimeTReff)*2.5];
        end
    end
    
    if readEIM(sMDH.aulEvalInfoMask,'MDH_TREFFECTIVEEND')...
            && cur_c==1 && cur_seg==1 && ~isTReffEnd && isTReffBegin
        endTimeTReff = cur_timeStamp;
        isTReffEnd = 1;
    end
    
    if isTReffBegin && isTReffEnd % end - begin
        timeTReff = [timeTReff;...
            endTimeTReff-beginTimeTReff,(endTimeTReff-beginTimeTReff)*2.5];
        isTReffBegin = 0;
        isTReffEnd = 0;
    end
        
    % ---------- save ADC data to different variable -----------------
    % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    % if don't know, use above default structure

    % noise data
    % structure : (ny,nx,nc)
    if readEIM(sMDH.aulEvalInfoMask,'MDH_NOISEADJSCAN')
        noise_data(cur_y,:,cur_c) = temp;

        % phase correction data
        % structure : {nset,nr,ne,ns,na} [ny,nx,nz,nc]
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_PHASCOR')
        phcor_data_cell{cur_set,cur_r,cur_e,cur_s,cur_a}(cur_y,:,cur_z,cur_c) = temp;
        
        
        % synchroneous data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_SYNCDATA')
%         sync_data(cur_y,:,cur_z,cur_c,...
%             cur_s,cur_e,cur_r,cur_set) = temp;
        sync_data = [sync_data,temp];   % i found this flag in %AdjustSeq%/AdjCoilSensSeq

        % reference phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_REFPHASESTABSCAN')
        refphstabscan_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set) = temp;

        % phase stabilization scan data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_PHASESTABSCAN')
        phstabscan_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set) = temp;

        % navgator echo data HPFEEDBACK
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_HPFEEDBACK')
        navHP_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set) = temp;

        % navgator echo data RTFEEDBACK
        % structure : (ny,nx,nc)
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_RTFEEDBACK')
        navRT_data(cur_y,:,cur_c) = temp;

        if cur_c==1 && is_triggered && ~isempty(endTimeShot)
            beginTimeNav = cur_timeStamp;
            time_btwShot_Nav = [time_btwShot_Nav;...
                beginTimeNav-endTimeShot,(beginTimeNav-endTimeShot)*2.5];
            endTimeShot = single([]);
        end
        
        if cur_usedCh==cur_c && readEIM(sMDH.aulEvalInfoMask,'MDH_PHASEFFT')
            

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
                    navRT_image_trig_after_cell{cur_s,cur_e,cur_r,cur_set,triggered_acq}(:,end+1) = temp_navRT_image.';
                catch
                    navRT_image_trig_after_cell{cur_s,cur_e,cur_r,cur_set,triggered_acq}(:,1) = temp_navRT_image.';
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
        % structure : {nc,nz,ns} [ny,nx,ne,nr,nset]
    else
        raw_KSpaceCentreLineNo = sMDH.ushKSpaceCentreLineNo;
        raw_KSpaceCentrePartitionNo = sMDH.ushKSpaceCentrePartitionNo;
        raw_RO_PE_swapped = readEIM(sMDH.aulEvalInfoMask,'MDH_SWAPPED');
        %         raw_usedCh = cur_usedCh;

        % seperate each coil to cell to avoid 'Out of Memory'
        if cur_c ~= cp_coil_index    % did not include CP coil
            if ~donotAvg && (cur_a>1 || sMDH.aushFreePara(1) == 302) 
                
                try
                % --------- save acq index to average
                avg_cell{cur_c,cur_z,cur_s}(cur_y,1,...
                    cur_e,cur_r,cur_set) = avg_cell{cur_c,cur_z,cur_s}(cur_y,1,...
                    cur_e,cur_r,cur_set)+1;

                % add raw
                raw{cur_c,cur_z,cur_s}(cur_y,:,...
                    cur_e,cur_r,cur_set) = raw{cur_c,cur_z,cur_s}(cur_y,:,...
                    cur_e,cur_r,cur_set) + temp.';
                
                catch %-- in case of first appeared (sMDH.aushFreePara(1) == 302)
                    
                    avg_cell{cur_c,cur_z,cur_s}(cur_y,1,...
                        cur_e,cur_r,cur_set) = 1;

                    % save raw
                    raw{cur_c,cur_z,cur_s}(cur_y,:,...
                        cur_e,cur_r,cur_set) = temp;
                end                
                
%             elseif cur_a==2 % ----------------- for test
%                 realCenterLine(1,:,cur_c) = temp;
                
            else
                avg_cell{cur_c,cur_z,cur_s}(cur_y,1,...
                    cur_e,cur_r,cur_set) = 1;
                
                % save raw
                raw{cur_c,cur_z,cur_s}(cur_y,:,...
                    cur_e,cur_r,cur_set) = temp;
            end
        end
        %         % -------------- conventional approach
        %         % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
        %         if cur_a>1
        %             raw(cur_y,:,cur_z,cur_c,...
        %                 cur_s,cur_e,cur_r,cur_set) = raw(cur_y,:,cur_z,cur_c,...
        %                 cur_s,cur_e,cur_r,cur_set) + temp.';
        %         else
        %             raw(cur_y,:,cur_z,cur_c,...
        %                 cur_s,cur_e,cur_r,cur_set) = temp;
        %         end
        % ---------------------------------------------------------------
        endTimeShot = cur_timeStamp;

        % --------- save projection line --------------------------------
        if sMDH.aushFreePara(1) == 302
            % -------- save number of projection line
            try % try increase index
                nProjectLine{cur_s,cur_e,cur_r,cur_set}(cur_c,1) = ...
                    nProjectLine{cur_s,cur_e,cur_r,cur_set}(cur_c,1)+1;
            catch % if not defined, error will occur and set to 1
                nProjectLine{cur_s,cur_e,cur_r,cur_set}(cur_c,1) = 1;
            end
            
            projLine_raw_cell{cur_s,cur_e,cur_r,cur_set}...
                (nProjectLine{cur_s,cur_e,cur_r,cur_set}(cur_c,1),:,cur_c) = temp;            
        end
        % ---------------------------------------------------------------
        
        % save echo train index for TSE
        if cur_c==1 && cur_seg==1
            echoTrain_index = echoTrain_index+1;
        end
        
        % save last navRT_image before acqusition of image
        if ~isempty(temp_navRT_image) && is_navRT_image_prev && (~donotAvg || cur_a==1)
            % NOTE : (~donotAvg || cur_a==1) -> if donotAvg==1, only get
            % when cur_a==1
            % if donotAvg==0, consider all acq indic
            
%             fprintf('cur_s = %d\n',cur_s) % for debug
            
            try
                navRT_image_trig_before_cell{cur_s,cur_e,cur_r,cur_set,cur_a}(:,end+1) = temp_navRT_image.';
            catch
                navRT_image_trig_before_cell{cur_s,cur_e,cur_r,cur_set,cur_a}(:,1) = temp_navRT_image.';
            end
            
            triggered_acq = cur_a;
            
            is_triggered = 1;
            startTimeShot = cur_timeStamp;
        end
        
        % save segment index for one coil and 1 acqusition and 1 repetition
        % and 1 slice
        if cur_c==1 && cur_a==1 && cur_r==1 && cur_s==1
            if is_triggered && is_navRT_image_prev && ~isempty(seg_indic_4s1)
                seg_indic_4s1 = [seg_indic_4s1;zeros(1,size(seg_indic_4s1,2))];
            end
            if cur_seg == 1 && ~is_triggered
                startTimeShot = cur_timeStamp;
            end
            seg_indic_4s1 = [seg_indic_4s1;...
                cur_timeStamp,cur_timeStamp-startTimeShot,...
                (cur_timeStamp-startTimeShot)*2.5,echoTrain_index,...
                cur_seg,cur_y,cur_z];
        end

        % save segment index for one coil and 1 acqusition and 1 repetition
        if cur_c==1 && cur_a==1 && cur_r==1
            if is_triggered && is_navRT_image_prev && ~isempty(seg_indic)
                seg_indic = [seg_indic;zeros(1,size(seg_indic,2))];
            end
            if cur_seg == 1 && ~is_triggered
                startTimeShot = cur_timeStamp;
            end
            seg_indic = [seg_indic;...
                cur_timeStamp,cur_timeStamp-startTimeShot,...
                (cur_timeStamp-startTimeShot)*2.5,echoTrain_index,...
                cur_seg,cur_y,cur_z,cur_s];
        end
        
        % save acq index for TSE for one coil and 1 repetition
        if cur_c==1 && cur_r==1
            if is_triggered && is_navRT_image_prev && ~isempty(acq_indic)
                acq_indic = [acq_indic;zeros(1,size(acq_indic,2))];
            end
            if cur_seg == 1 && ~is_triggered
                startTimeShot = cur_timeStamp;
            end
            acq_indic = [acq_indic;...
                cur_timeStamp,cur_timeStamp-startTimeShot,...
                (cur_timeStamp-startTimeShot)*2.5,echoTrain_index,...
                cur_seg,cur_a,cur_y,cur_z,cur_s];
        end
        

        % save training data set
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

    if mod(processed_line,500)==0
        % ----------------- waitbar -----------------
        processed_byte = ftell(fid);
        processed_byte_percent = processed_byte/file_size*100;

        set(figHndl.text_processed,'string',...
            [num2str(processed_byte_percent,'%.2f'),'% processed.']);

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
%         cancel_process = 0;
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

xpatch = [0 100 100 0];
ypatch = [0 0 1 1];

patch(xpatch,ypatch,'b','EdgeColor','b'); %,'EraseMode','none');
drawnow;
% ------------------------------------------------

%% ------ save navRTimage_trig to file -----------------------------

% n_acq = max(acq_indic(:,6));

if ~isempty(navRT_image_trig_before_cell)
    if ~isdir([pathnameSS,'navRT_image'])
        mkdir([pathnameSS,'navRT_image'])
    end
    disp(['Saving ',...
        'navRT_image_before_trig to file...'])
    
    % n_acq = max(acq_indic(:,6));
    [ns,ne,nr,nset,n_acq] = size(navRT_image_trig_before_cell);

    for la = 1:n_acq
        for lset = 1:nset
            for lr = 1:nr
                for le = 1:ne
                    for ls = 1:ns
                        if ls<10
                            add0 = '00';
                        elseif ls<100
                            add0 = '0';
                        else
                            add0 = '';
                        end

                        navRT_image_before_trig = navRT_image_trig_before_cell{ls,le,lr,lset,la};

                        if ~isempty(navRT_image_before_trig)
                            save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_before_trig',...
                                '_s',add0,num2str(ls),...
                                '_a',num2str(la),'_e',num2str(le),...
                                '_r',num2str(lr),'_set',num2str(lset),...
                                '.mat'],'navRT_image_before_trig');
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
    
    [ns,ne,nr,nset,n_acq] = size(navRT_image_trig_after_cell);
    
    for la = 1:n_acq
        for lset = 1:nset
            for lr = 1:nr
                for le = 1:ne
                    for ls = 1:ns
                        if ls<10
                            add0 = '00';
                        elseif ls<100
                            add0 = '0';
                        else
                            add0 = '';
                        end

                        navRT_image_after_trig = navRT_image_trig_after_cell{ls,le,lr,lset,la};
                        
                        if ~isempty(navRT_image_after_trig)
                            save([pathnameSS,'navRT_image/',filenameSS,'_navRT_image_after_trig',...
                                '_s',add0,num2str(ls),...
                                '_a',num2str(la),'_e',num2str(le),...
                                '_r',num2str(lr),'_set',num2str(lset),...
                                '.mat'],'navRT_image_after_trig');
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
    
    [nset,nr,ne,ns,n_acq] = size(phcor_data_cell);

    % phase correction data
    % structure : {nset,nr,ne,ns,na} [ny,nx,nz,nc]
    for la = 1:n_acq
        for lset = 1:nset
            for lr = 1:nr
                for le = 1:ne
                    for ls = 1:ns
                        
                        if ls<10
                            add0 = '00';
                        elseif ls<100
                            add0 = '0';
                        else
                            add0 = '';
                        end
                        
                        phcor_data = phcor_data_cell{lset,lr,le,ls,la};
                        
                        save([pathnameSS,'phcor_data/',filenameSS,'_','phcor_data',...
                            '_s',add0,num2str(ls),...
                            '_a',num2str(la),'_e',num2str(le),...
                            '_r',num2str(lr),'_set',num2str(lset),...
                            '.mat'],'phcor_data');

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

if ~isempty(sync_data)
    if ~isdir([pathnameSS,'sync_data'])
        mkdir([pathnameSS,'sync_data'])
    end
    save([pathnameSS,'sync_data/',filenameSS,'_','sync_data','.mat'],'sync_data');
    clear sync_data
end

if ~isempty(seg_indic)
    if ~isdir([pathnameSS,'seg_indic'])
        mkdir([pathnameSS,'seg_indic'])
    end
    save([pathnameSS,'seg_indic/',filenameSS,'_','seg_indic','.mat'],...
        'seg_indic','seg_indic_info','seg_indic_info_4excel');
    clear seg_indic_info
    clear seg_indic_info_4excel
end

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
    
    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});
    
    for lset = 1:nset
        for lr = 1:nr
            for le = 1:ne
                for ls = 1:ns
                    
                    if ls<10
                        add0 = '00';
                    elseif ls<100
                        add0 = '0';
                    else
                        add0 = '';
                    end
                    
                    %-- extract projection image according to [s,e,r,set]
                    projLine_raw = projLine_raw_cell{ls,le,lr,lset};
                    %---- coil combine was done using root-Sum-of-squares
                    projLine_im = fft3c(projLine_raw,2);

                    if cut_RO_OS
                        projLine_im = projLine_im(:,nx/4+1:nx/4+nx/2,:);
                    end
                    
                    projLine_im_SOS = SOS(projLine_im);
                                    
                    save([pathnameSS,'UserData/',filenameSS,'_','projLine_im',...
                        '_s',add0,num2str(ls),'_e',num2str(le),...
                        '_r',num2str(lr),'_set',num2str(lset),'.mat'],...
                        'projLine_raw','projLine_im','projLine_im_SOS');%,'realCenterLine'
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

    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

    for lc = 1:nc
        for lz = 1:nz
            for ls = 1:ns
                for ly = 1:ny
                    for le = 1:ne
                        for lr = 1:nr
                            for lset = 1:nset
                                % just divide to avg_cell
                                raw{lc,lz,ls}(ly,:,...
                                    le,lr,lset) = raw{lc,lz,ls}(ly,:,...
                                    le,lr,lset)/avg_cell{lc,lz,ls}(ly,1,...
                                    le,lr,lset);
                            end
                        end
                    end
                end
            end
        end
    end

    clear avg_cell
    % assignin('base','acq',avg_cell);

%% consider KyCenter & KzCenter

    % [ny,nx,nz,nc,ns,ne,nr,nset] = size(raw);
    % seperate each coil to cell to avoid 'Out of Memory'
    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

    num_zero_padding = ny - 2*raw_KSpaceCentreLineNo;

    % zero filling to locate CentreLine center
    if num_zero_padding>0
        % seperate each coil to cell to avoid 'Out of Memory'
        temp_zeros = zeros(num_zero_padding,nx,ne,nr,nset,'single');
        for oc=1:nc
            for oz=1:nz
                for os=1:ns
                    raw{oc,oz,os} = cat(1,temp_zeros,raw{oc,oz,os});
                end
            end
        end
        clear temp_zeros
    elseif num_zero_padding<0
        % seperate each coil to cell to avoid 'Out of Memory'
        temp_zeros = zeros(-num_zero_padding,nx,ne,nr,nset,'single');
        for oc=1:nc
            for oz=1:nz
                for os=1:ns
                    raw{oc,oz,os} = cat(1,raw{oc,oz,os},temp_zeros);
                end
            end
        end
        clear temp_zeros
    end

    % -------------- conventional approach
    % % zero filling to locate CentreLine center
    % if num_zero_padding>0
    %     raw = cat(1,zeros(num_zero_padding,nx,nz,nc,ns,ne,nr,nset,'single'),raw);
    % elseif num_zero_padding<0
    %     raw = cat(1,raw,zeros(-num_zero_padding,nx,nz,nc,ns,ne,nr,nset,'single'));
    % end

    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

    if nz>1
        num_zero_padding = nz - 2*raw_KSpaceCentrePartitionNo;

        % zero filling to locate CentreLine center
        if num_zero_padding>0
            % seperate each coil to cell to avoid 'Out of Memory'
            temp_zeros = zeros(ny,nx,ne,nr,nset,'single');
            temp_zeros_cell = cell(nc,num_zero_padding,ns);

            for oc=1:nc
                for oz=1:num_zero_padding
                    for os=1:ns
                        temp_zeros_cell{oc,oz,os} = temp_zeros;
                    end
                end
            end
            raw = cat(2,temp_zeros_cell,raw);
            clear temp_zeros
            clear temp_zeros
        elseif num_zero_padding<0
            % seperate each coil to cell to avoid 'Out of Memory'
            temp_zeros = zeros(ny,nx,ne,nr,nset,'single');
            temp_zeros_cell = cell(nc,-num_zero_padding,ns);

            for oc=1:nc
                for oz=1:-num_zero_padding
                    for os=1:ns
                        temp_zeros_cell{oc,oz,os} = temp_zeros;
                    end
                end
            end
            raw = cat(2,raw,temp_zeros_cell);
            clear temp_zeros
            clear temp_zeros
        end

        % -------------- conventional approach
        %     % zero filling to locate CentreLine center
        %     if num_zero_padding>0
        %         raw = cat(3,zeros(ny,nx,num_zero_padding,nc,ns,ne,nr,nset,'single'),raw);
        %     elseif num_zero_padding<0
        %         raw = cat(3,raw,zeros(ny,nx,-num_zero_padding,nc,ns,ne,nr,nset,'single'));
        %     end
    end

    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

%% consider PE Resolution & slice Resolution

    % [ny,nx,nz,nc,ns,ne,nr,nset] = size(raw);
    % seperate each coil to cell to avoid 'Out of Memory'
    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

    % make iso-pixel
    RO_pixel_size = image_spec.FOVro/(nx/image_spec.read_os);
    ny_ima_mat = round(image_spec.FOVpe/RO_pixel_size);

    % note -- 얻은 PE line 이 더 크면 resolution 고려, 나눠주기?

    num_zero_padding = ny_ima_mat - ny;
    num_zero_padding = round(num_zero_padding/2);

    % zero filling to fit PE resolution
    if num_zero_padding>0
        % seperate each coil to cell to avoid 'Out of Memory'
        temp_zeros = zeros(num_zero_padding,nx,ne,nr,nset,'single');
        for oc=1:nc
            for oz=1:nz
                for os=1:ns
                    % concatenate it upper and lower part
                    raw{oc,oz,os} = cat(1,temp_zeros,raw{oc,oz,os});
                    raw{oc,oz,os} = cat(1,raw{oc,oz,os},temp_zeros);
                end
            end
        end
        clear temp_zeros
    end


    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

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
            % seperate each coil to cell to avoid 'Out of Memory'
            temp_zeros = zeros(ny,nx,ne,nr,nset,'single');
            temp_zeros_cell = cell(nc,num_zero_padding,ns);

            for oc=1:nc
                for oz=1:num_zero_padding
                    for os=1:ns
                        temp_zeros_cell{oc,oz,os} = temp_zeros;
                    end
                end
            end
            % concatenate it front and back
            raw = cat(2,temp_zeros_cell,raw);
            raw = cat(2,raw,temp_zeros_cell);
            clear temp_zeros
            clear temp_zeros
        end

    end

    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

%% consider phase/readout swapp

    if raw_RO_PE_swapped && ~donotSwapRO
        % seperate each coil to cell to avoid 'Out of Memory'
        for oc=1:nc
            for oz=1:nz
                for os=1:ns
                    raw{oc,oz,os} = permute(raw{oc,oz,os},[2,1,3,4,5]);
                end
            end
        end
        % -------------- conventional approach
        %     raw = permute(raw,[2,1,3,4,5,6,7,8]);
    end

    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});



%% save full raw data

    [nc,nz,ns] = size(raw);
    [ny,nx,ne,nr,nset] = size(raw{1});

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
    image_spec.RO_PE_swapped = raw_RO_PE_swapped;
    image_spec_MDH.RO_PE_swapped = raw_RO_PE_swapped;

    disp(' ')
    disp(['- Readout pixel size = ',num2str(RO_pixel_size),' mm'])
    disp(' ')
    disp('Final data size :')
    fprintf('\timage (ky)x(kx)x(kz) : %dx%dx%d\n',ny,nx,nz)
    fprintf('\t# of slice : %d\n',ns)
    fprintf('\t# of coil : %d\n',nc)
    fprintf('\t# of echo : %d\n',ne)
    fprintf('\t# of repitetion : %d\n',nr)
    fprintf('\t# of set : %d\n',nset)
    fprintf('\t# of segment : %d\n',image_spec_MDH.nseg)
    disp(' ')

    set(figHndl.pushbutton_cancel,'enable','off')
    drawnow;

    disp('Saving full-raw data to file...')
    %----- save raw to .mat file
    if ~isdir([pathnameSS,'Raw_Data_VB15'])
        mkdir([pathnameSS,'Raw_Data_VB15'])
    end

    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
        '_full_raw','.mat'],'raw');
    %---------------------------------------
    disp('Done!')
    disp(' ')

    set(figHndl.pushbutton_cancel,'enable','on')
    drawnow;

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

    save_RawimaComp

end

%% end of algorithm

disp('=========================================================================')
% eval('dispetime(toc,0);','disp(''Total ''),toc')
dispetime(toc,0);
disp('=========================================================================')

fclose(fid);

%% function save_RawimaComp - seperate full-raw

    function save_RawimaComp
        drawnow;
        
        % seperate each coil to cell to avoid 'Out of Memory'
        [nc,nz,ns] = size(raw);
        [ny,nx,ne,nr,nset] = size(raw{1});
        
        is_full_raw = 1; % raw is full-raw
        
         % if not 64 bit system AND larger than 300 MByte       
        if isempty(strfind(computer,'64')) && nc*nz*ns*ny*nx*ne*nr*nset*8 > 300*1e6
            disp('Raw data is larger than 300 MBytes.')
            disp('Process will save to seperate files.')
            disp('Saving...')
            
            is_full_raw = 0; % raw is seperated-raw
            
            % save seperate file
            if nz>1 % in 3D, to each coil
                for c=1:nc
                    if c<10
                        add0 = '00';
                    elseif c<100
                        add0 = '0';
                    else
                        add0 = '';
                    end
                    
                    fid_sep_raw = fopen([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                        '_raw_coil_',add0,num2str(c),'.mat']);
                    exist_sep_raw_file = (fid_sep_raw~=-1); % no file -> 0

%                     if exist_sep_raw_file && ~reprocess
%                         disp(['coil ',num2str(c),' file exist.'])
%                     else
                        raw_coil = raw(c,:,:);
                        save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                            '_raw_coil_',add0,num2str(c),'.mat'],'raw_coil');
%                     end
                end
                clear raw_coil
            else % in 2D, to each slice
                for s=1:ns
                    if s<10
                        add0 = '00';
                    elseif s<100
                        add0 = '0';
                    else
                        add0 = '';
                    end
                    
                    fid_sep_raw = fopen([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                        '_raw_slice_',add0,num2str(s),'.mat']);
                    exist_sep_raw_file = (fid_sep_raw~=-1); % no file -> 0

%                     if exist_sep_raw_file && ~reprocess
%                         disp(['slice ',num2str(s),' file exist.'])
%                     else
                        raw_slice = raw(:,:,s);
                        save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                            '_raw_slice_',add0,num2str(s),'.mat'],'raw_slice');
%                     end
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
%             cancel_process = 0;
            return;
        end
        
%% save raw data

        %------------------------ divide into matrix --------------------------
        if nz>1 % 3D data
            raw_part = complex(zeros(ny,nx,nz,'single'));
            for i_set = 1:nset
                for r = 1:nr
                    for e = 1:ne
                        for s = 1:ns
                            if s<10
                                add0 = '00';
                            elseif s<100
                                add0 = '0';
                            else
                                add0 = '';
                            end

                            for c = 1:nc
                                fid_file = fopen([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                    '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '_c',num2str(c),'.mat']);
                                exist_file = (fid_file~=-1); % no file -> 0
                                
%                                 if exist_file && ~reprocess
%                                     disp([num2str(c),'th raw file is exist.'])
%                                 else
                                    if is_full_raw
                                        % seperate each coil to cell to avoid 'Out of
                                        % Memory'
                                        for z=1:nz
                                            raw_part(:,:,z) = raw{c,z,s}(:,:,e,r,i_set);
                                        end
                                        % -------------- conventional approach
                                        %                         raw_part(:,:,:) = raw(:,:,:,c,s,e,r,i_set);
                                    else
                                        if c<10
                                            add0c = '00';
                                        elseif c<100
                                            add0c = '0';
                                        else
                                            add0c = '';
                                        end

                                        disp('Loading seperated raw data file...')
                                        load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                            '_raw_coil_',add0c,num2str(c),'.mat'])
                                        for z=1:nz
                                            raw_part(:,:,z) = raw_coil{1,z,s}(:,:,e,r,i_set);
                                        end
                                        clear raw_coil
                                    end

                                    disp('Saving raw to file...')
                                    %----- save raw to .mat file
                                    if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                        mkdir([pathnameSS,'Raw_Data_VB15'])
                                    end

                                    save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                        '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '_c',num2str(c),'.mat'],'raw_part');
                                    %---------------------------------------
%                                 end % end of if file exist
                                
                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
%                                     cancel_process = 0;
                                    return;
                                end

                                fid_file = fopen([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                        '_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '_c',num2str(c),'.mat']);
                                exist_file = (fid_file~=-1); % no file -> 0

%                                 if exist_file && ~reprocess
%                                     disp([num2str(c),'th image file is exist.'])
%                                 else
                                    disp('Now, evaluate FFT...')
                                    im = fft3c(raw_part);
                                    if cut_RO_OS
                                        if ~isempty(image_spec_MDH.RO_PE_swapped) &&...
                                                image_spec_MDH.RO_PE_swapped && ~donotSwapRO
                                            im = im(ny/4+1:ny/4+ny/2,:,:);
                                        else
                                            im = im(:,nx/4+1:nx/4+nx/2,:);
                                        end
                                    end

                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
%                                         cancel_process = 0;
                                        return;
                                    end

                                    disp('Saving image to file...')
                                    %----- save image to .mat file
                                    if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
                                        mkdir([pathnameSS,'Reconstructed_Data_VB15'])
                                    end

                                    save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                        '_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '_c',num2str(c),'.mat'],'im');
                                    %----------------------------------------
                                    disp('Done!')
                                    clear im
%                                 end % end of if file exist

                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
%                                     cancel_process = 0;
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        else    % 2D data (i.e. nz=1)
            raw_part = complex(zeros(ny,nx,nc,'single'));
            for i_set = 1:nset
                for r = 1:nr
                    for e = 1:ne
                        for s = 1:ns
                            if s<10
                                add0 = '00';
                            elseif s<100
                                add0 = '0';
                            else
                                add0 = '';
                            end

                            fid_file = fopen([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                    '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '.mat']);
                            exist_file = (fid_file~=-1); % no file -> 0

%                             if exist_file && ~reprocess
%                                 disp([num2str(s),'th raw file is exist.'])
%                             else
                                if is_full_raw
                                    % seperate each coil to cell to avoid 'Out of Memory'
                                    for c=1:nc
                                        raw_part(:,:,c) = raw{c,1,s}(:,:,e,r,i_set);
                                    end
                                    % -------------- conventional approach
                                    %                     raw_part(:,:,:) = raw(:,:,1,:,s,e,r,i_set);
                                else
                                    disp('Loading seperated raw data file...')
                                    load([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                        '_raw_slice_',add0,num2str(s),'.mat'])
                                    for c=1:nc
                                        raw_part(:,:,c) = raw_slice{c,1,1}(:,:,e,r,i_set);
                                    end
                                    clear raw_slice
                                end

                                disp('Saving raw to file...')
                                %----- save raw to .mat file
                                if ~isdir([pathnameSS,'Raw_Data_VB15'])
                                    mkdir([pathnameSS,'Raw_Data_VB15'])
                                end

                                save([pathnameSS,'Raw_Data_VB15/',filenameSS,...
                                    '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '.mat'],'raw_part');
                                %---------------------------------------
%                             end % end of if file exist

                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
%                                 cancel_process = 0;
                                return;
                            end

                            fid_file = fopen([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                    '_image_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '.mat']);
                            exist_file = (fid_file~=-1); % no file -> 0

%                             if exist_file && ~reprocess
%                                 disp([num2str(s),'th image file is exist.'])
%                             else
                                disp('Now, evaluate FFT...')
                                im = fft3c(raw_part,3);
                                if cut_RO_OS
                                    if ~isempty(image_spec_MDH.RO_PE_swapped) &&...
                                            image_spec_MDH.RO_PE_swapped && ~donotSwapRO
                                        im = im(ny/4+1:ny/4+ny/2,:,:);
                                    else
                                        im = im(:,nx/4+1:nx/4+nx/2,:);
                                    end
                                end

                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
%                                     cancel_process = 0;
                                    return;
                                end

                                disp('Saving image to file...')
                                %----- save image to .mat file
                                if ~isdir([pathnameSS,'Reconstructed_Data_VB15'])
                                    mkdir([pathnameSS,'Reconstructed_Data_VB15'])
                                end

                                save([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                                    '_image_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '.mat'],'im');
                                %----------------------------------------
                                disp('Done!')
                                clear im
%                             end % end of if file exist

                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
%                                 cancel_process = 0;
                                return;
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
%                 cancel_process = 0;
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
    
    for i_set = 1:nset
        for r = 1:nr
            for e = 1:ne
                for s = 1:ns
                    if s<10
                        add0 = '00';
                    elseif s<100
                        add0 = '0';
                    else
                        add0 = '';
                    end

                    for c = 1:nc

                        disp(['Loading ',num2str(c),'th coil image file...'])
                        load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                            '_r',num2str(r),'_set',num2str(i_set),...
                            '_c',num2str(c),'.mat']);
                        
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
                    end

                    % why step-by-step operation is memory efficient than
                    % combined one-line operation ?
                    comp_mag_im = sqrt(comp_mag_im);
                    comp_ph_im = angle(comp_ph_im);
                    comp_im = comp_mag_im.*exp(j*comp_ph_im);

                    disp('Saving composite image to file...')
                    % ------ save combined image to .mat file
                    if ~isdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                        mkdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                    end
                    save([pathnameSS,'Reconstructed_Data_VB15/Composite_image/',filenameSS,...
                        '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                        '_r',num2str(r),'_set',num2str(i_set),'.mat'],'comp_im');
                    disp('Done!')

                    drawnow;
                    if cancel_process
                        disp('Processing canceled.')
%                         cancel_process = 0;
                        return;
                    end
                end
            end
        end
    end
else    % 2D data (i.e. nz=1)
    for i_set = 1:nset
        for r = 1:nr
            for e = 1:ne
                for s = 1:ns
                    if s<10
                        add0 = '00';
                    elseif s<100
                        add0 = '0';
                    else
                        add0 = '';
                    end

                    disp('Loading image file...')
                    load([pathnameSS,'Reconstructed_Data_VB15/',filenameSS,...
                        '_image_s',add0,num2str(s),'_e',num2str(e),...
                        '_r',num2str(r),'_set',num2str(i_set),...
                        '.mat']);

                    comp_im = SOS(im).*exp(j*angle(sum(im,3)));
                    clear im

                    disp('Saving composite image to file...')
                    % ------ save combined image to .mat file
                    if ~isdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                        mkdir([pathnameSS,'Reconstructed_Data_VB15/Composite_image'])
                    end
                    save([pathnameSS,'Reconstructed_Data_VB15/Composite_image/',filenameSS,...
                        '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                        '_r',num2str(r),'_set',num2str(i_set),'.mat'],'comp_im');
                    disp('Done!')
                    
                    drawnow;
                    if cancel_process
                        disp('Processing canceled.')
%                         cancel_process = 0;
                        return;
                    end
                end
            end
        end
    end
end
clear comp_im
end % end of function func_make_comp_im
