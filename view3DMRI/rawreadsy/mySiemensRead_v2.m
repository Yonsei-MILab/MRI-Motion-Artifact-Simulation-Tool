function mySiemensRead_v2(image_spec)
%% Information
% Only works in conventional 2DFT sequence
% Coded by cefca (Sang_Young Zho).
% All rights reserved in MI laboratory.
% Last modified at 2008.06.20

tic;

%% set parameter

global make_comp_im;
global sMDH;
global figHndl;
global cancel_process;

mdh = 128; % measurement data header (byte) -> fixed
glob_hdr = image_spec.glo_hdr_size;   % global header in byte (found .out file)

filename = image_spec.filename;
pathname = image_spec.path;

rawcorr = image_spec.rawcorr;

cp_coil_index = image_spec.cp_coil_index;   % did not consider this
ver = image_spec.ver;

% na = image_spec.na;
% nx = image_spec.nx;
% ny = image_spec.ny;
% nz = image_spec.nz;
% nc = image_spec.nc;
% ne = image_spec.ne;
% ns = image_spec.ns;
% read_os = image_spec.read_os;

%% get slice order info



%% open .out file

fid = fopen([pathname filename '.dat'],'r');

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
navRT_image = single([]);   % series of navgator echo image RTFEEDBACK

noise_data = single([]);    % noise data
navRT_data = single([]);  % navgator echo data RTFEEDBACK
navHP_data = single([]);  % navgator echo data HPFEEDBACK
refphstabscan_data = single([]);    % reference phase stabilization scan data
phstabscan_data = single([]);    % phase stabilization scan data
sync_data = single([]); % readout contains synchroneous data

seg_indic = int16([]); % contain [segment index,ky index, kz index,slice index]

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
% const MdhBitField MDH_REFLECT           (24);      // reflect line
% const MdhBitField MDH_NOISEADJSCAN      (25);      // noise adjust scan --> Not used in NUM4

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

%% check saved full raw before processing

fid_full_raw = fopen([pathname,'Raw_Data_VB15/',filename,...
    '_full_raw','.mat']);
exist_full_raw_file = (fid_full_raw~=-1); % no file -> 0

if exist_full_raw_file
    fclose(fid_full_raw);
    disp('--------------------------------')
    disp('Processed full-raw data is exist~!')
    disp('Just save to seperate files.')
    disp('--------------------------------')
    disp('Loading full-raw data...')

    set(figHndl.pushbutton_cancel,'enable','off')
    drawnow;

    load([pathname,'Raw_Data_VB15/',filename,...
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

    % seperate each coil to cell to avoid 'Out of Memory'
    nc = length(raw);
    [ny,nx,nz,ns,ne,nr,nset] = size(raw{1});

    save_RawimaComp

    disp('=========================================================================')
    % eval('dispetime(toc,0);','disp(''Total ''),toc')
    dispetime(toc,0);
    disp('=========================================================================')

    fclose(fid);
    return;
end

%% procsessing


disp('--------------------------------')
disp('Using Standard I/O File acces.')
disp('MDH based recon')


navRT_image_index = 0;
navRT_image_file_index = 1;

processed_line = 0;

disp('Processing...')
axes(figHndl.axes_waitbar);

readMDH(fid);
while ~readEIM(sMDH.aulEvalInfoMask,'MDH_ACQEND')


    cur_nx = sMDH.ushSamplesInScan;
    cur_KspaceCenterCol = sMDH.ushKSpaceCentreColumn;

    if cur_KspaceCenterCol>0
        num_zero_padding = cur_nx - 2*cur_KspaceCenterCol;
    else
        num_zero_padding = 0;
    end

    % read ADC data -> saved column vector
    temp = single(fread(fid,cur_nx*2,'float32'));  % *2 -> real and imag data
    % make it complex and save to matrix
    temp = complex(temp(1:2:end),temp(2:2:end));

    % zero filling to locate echo center
    if num_zero_padding>0
        temp = [zeros(num_zero_padding,1,'single');temp];
    elseif num_zero_padding<0
        temp = [temp;zeros(-num_zero_padding,1,'single')];
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

    % consider rawdatacorrection
    if readEIM(sMDH.aulEvalInfoMask,'MDH_RAWDATACORRECTION')
        temp = temp*rawcorr(cur_c,2);
    end

    cur_a = sMDH.sLC.ushAcquisition+1;  % just add if this >1
    cur_e = sMDH.sLC.ushEcho+1;
    cur_s = sMDH.sLC.ushSlice+1;
    cur_seg = sMDH.sLC.ushSeg+1;
    cur_z = sMDH.sLC.ushPartition+1;
    cur_y = sMDH.sLC.ushLine+1;
    cur_r = sMDH.sLC.ushRepetition+1;
    cur_set = sMDH.sLC.ushSet+1;
    cur_usedCh = sMDH.ushUsedChannels;

    % ---------- save ADC data to different variable -----------------
    % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    % if don't know, use above default structure

    % noise data
    % structure : (ny,nx,nc)
    if readEIM(sMDH.aulEvalInfoMask,'MDH_NOISEADJSCAN')
        noise_data(cur_y,:,cur_c) = temp;

        % synchroneous data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    elseif readEIM(sMDH.aulEvalInfoMask,'MDH_SYNCDATA')
        sync_data(cur_y,:,cur_z,cur_c,...
            cur_s,cur_e,cur_r,cur_set) = temp;

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

        if cur_usedCh==cur_c && readEIM(sMDH.aulEvalInfoMask,'MDH_PHASEFFT')
            % do FFT
            temp_navRT_image = fft3c(navRT_data,3);
            temp_navRT_image = SOS(temp_navRT_image).*exp(j*angle(sum(temp_navRT_image,3)));

            % concatenate nav image
            % assume readout line is always longer than PE
            navRT_image = [navRT_image,temp_navRT_image.'];
            clear temp_navRT_image;

            navRT_image_index = navRT_image_index+1;

            % save image to file when 10 image is collected
            if navRT_image_index==10
                % add 0 to filename
                if navRT_image_file_index<10
                    add0 = '00';
                elseif navRT_image_file_index<100
                    add0 = '0';
                else
                    add0 = '';
                end
                            
                if ~isdir([pathname,'navRT_image'])
                    mkdir([pathname,'navRT_image'])
                end
                disp('Saving navRT_image to file...')
                save([pathname,'navRT_image/',filename,'_navRT_image_',add0,...
                    num2str(navRT_image_file_index),'.mat'],'navRT_image');
                disp('Done!')

                navRT_image_file_index = navRT_image_file_index+1;
                navRT_image_index = 0;

                navRT_image = single([]);   % reset matrix
            end

        end % end of make nav image

        % image raw data
        % structure : (ny,nx,nz,nc,ns,ne,nr,nset)
    else
        raw_KSpaceCentreLineNo = sMDH.ushKSpaceCentreLineNo;
        raw_KSpaceCentrePartitionNo = sMDH.ushKSpaceCentrePartitionNo;
        raw_RO_PE_swapped = readEIM(sMDH.aulEvalInfoMask,'MDH_SWAPPED');
        %         raw_usedCh = cur_usedCh;

        % seperate each coil to cell to avoid 'Out of Memory'
        if cur_a>1
            raw{cur_c}(cur_y,:,cur_z,...
                cur_s,cur_e,cur_r,cur_set) = raw{cur_c}(cur_y,:,cur_z,...
                cur_s,cur_e,cur_r,cur_set) + temp.';
        else
            raw{cur_c}(cur_y,:,cur_z,...
                cur_s,cur_e,cur_r,cur_set) = temp;
        end
        %         % -------------- conventional approach
        %         if cur_a>1
        %             raw(cur_y,:,cur_z,cur_c,...
        %                 cur_s,cur_e,cur_r,cur_set) = raw(cur_y,:,cur_z,cur_c,...
        %                 cur_s,cur_e,cur_r,cur_set) + temp.';
        %         else
        %             raw(cur_y,:,cur_z,cur_c,...
        %                 cur_s,cur_e,cur_r,cur_set) = temp;
        %         end

        % save segment index
        seg_indic(cur_y,:) = [cur_seg,cur_y,cur_z,cur_s];

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

        patch(xpatch,ypatch,'b','EdgeColor','b'); %,'EraseMode','none');
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
        cancel_process = 0;
        fclose(fid);
        return;
    end

    readMDH(fid);   % read MDH before next loop
end

disp('Done!')

axes(figHndl.axes_waitbar);
% ----------------- waitbar -----------------
set(figHndl.text_processed,'string',...
    '100% processed.');

xpatch = [0 100 100 0];
ypatch = [0 0 1 1];

patch(xpatch,ypatch,'b','EdgeColor','b'); %,'EraseMode','none');
drawnow;
% ------------------------------------------------

%% consider KyCenter & KzCenter

% [ny,nx,nz,nc,ns,ne,nr,nset] = size(raw);
% seperate each coil to cell to avoid 'Out of Memory'
nc = length(raw);
[ny,nx,nz,ns,ne,nr,nset] = size(raw{1});

num_zero_padding = ny - 2*raw_KSpaceCentreLineNo;

% zero filling to locate CentreLine center
if num_zero_padding>0
    % seperate each coil to cell to avoid 'Out of Memory'
    for c=1:nc
        raw{c} = cat(1,zeros(num_zero_padding,nx,nz,ns,ne,nr,nset,'single'),raw{c});
    end
elseif num_zero_padding<0
    % seperate each coil to cell to avoid 'Out of Memory'
    for c=1:nc
        raw{c} = cat(1,raw{c},zeros(-num_zero_padding,nx,nz,ns,ne,nr,nset,'single'));
    end
end

% -------------- conventional approach
% % zero filling to locate CentreLine center
% if num_zero_padding>0
%     raw = cat(1,zeros(num_zero_padding,nx,nz,nc,ns,ne,nr,nset,'single'),raw);
% elseif num_zero_padding<0
%     raw = cat(1,raw,zeros(-num_zero_padding,nx,nz,nc,ns,ne,nr,nset,'single'));
% end

if nz>1
    num_zero_padding = nz - 2*raw_KSpaceCentrePartitionNo;

    % zero filling to locate CentreLine center
    if num_zero_padding>0
        % seperate each coil to cell to avoid 'Out of Memory'
        for c=1:nc
            raw{c} = cat(3,zeros(ny,nx,num_zero_padding,ns,ne,nr,nset,'single'),raw{c});
        end
    elseif num_zero_padding<0
        % seperate each coil to cell to avoid 'Out of Memory'
        for c=1:nc
            raw{c} = cat(3,raw{c},zeros(ny,nx,-num_zero_padding,ns,ne,nr,nset,'single'));
        end
    end

    % -------------- conventional approach
    %     % zero filling to locate CentreLine center
    %     if num_zero_padding>0
    %         raw = cat(3,zeros(ny,nx,num_zero_padding,nc,ns,ne,nr,nset,'single'),raw);
    %     elseif num_zero_padding<0
    %         raw = cat(3,raw,zeros(ny,nx,-num_zero_padding,nc,ns,ne,nr,nset,'single'));
    %     end
end

%% consider phase/readout swapp

if raw_RO_PE_swapped
    % seperate each coil to cell to avoid 'Out of Memory'
    for c=1:nc
        raw{c} = permute(raw{c},[2,1,3,4,5,6,7]);
    end
    % -------------- conventional approach
    %     raw = permute(raw,[2,1,3,4,5,6,7,8]);
end


%% ------------- save variable to file -----------------

if ~isempty(noise_data)
    if ~isdir([pathname,'noise_data'])
        mkdir([pathname,'noise_data'])
    end
    save([pathname,'noise_data/',filename,'_','noise_data','.mat'],'noise_data');
    clear noise_data
end

if ~isempty(navHP_data)
    if ~isdir([pathname,'navHP_data'])
        mkdir([pathname,'navHP_data'])
    end
    save([pathname,'navHP_data/',filename,'_','navHP_data','.mat'],'navHP_data');
    clear navHP_data
end

if ~isempty(refphstabscan_data)
    if ~isdir([pathname,'refphstabscan_data'])
        mkdir([pathname,'refphstabscan_data'])
    end
    save([pathname,'refphstabscan_data/',filename,'_','refphstabscan_data','.mat'],'refphstabscan_data');
    clear refphstabscan_data
end

if ~isempty(phstabscan_data)
    if ~isdir([pathname,'phstabscan_data'])
        mkdir([pathname,'phstabscan_data'])
    end
    save([pathname,'noise_data/',filename,'_','phstabscan_data','.mat'],'phstabscan_data');
    clear phstabscan_data
end

if ~isempty(sync_data)
    if ~isdir([pathname,'sync_data'])
        mkdir([pathname,'sync_data'])
    end
    save([pathname,'sync_data/',filename,'_','sync_data','.mat'],'sync_data');
    clear sync_data
end

if ~isempty(seg_indic)
    if ~isdir([pathname,'seg_indic'])
        mkdir([pathname,'seg_indic'])
    end
    save([pathname,'seg_indic/',filename,'_','seg_indic','.mat'],'seg_indic');
    clear seg_indic
end

%% save full raw data

disp('Saving full-raw data to file...')
%----- save raw to .mat file
if ~isdir([pathname,'Raw_Data_VB15'])
    mkdir([pathname,'Raw_Data_VB15'])
end

save([pathname,'Raw_Data_VB15/',filename,...
    '_full_raw','.mat'],'raw');
%---------------------------------------
disp('Done!')

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

%% end of algorithm

disp('=========================================================================')
% eval('dispetime(toc,0);','disp(''Total ''),toc')
dispetime(toc,0);
disp('=========================================================================')

fclose(fid);


    function save_RawimaComp
%% save raw data

        %------------------------ divide into matrix --------------------------
        if nz>1 % 3D data
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
                                % seperate each coil to cell to avoid 'Out of
                                % Memory'
                                raw_part(:,:,:) = raw{c}(:,:,:,s,e,r,i_set);
                                % -------------- conventional approach
                                %                         raw_part(:,:,:) = raw(:,:,:,c,s,e,r,i_set);

                                disp('Saving raw to file...')
                                %----- save raw to .mat file
                                if ~isdir([pathname,'Raw_Data_VB15'])
                                    mkdir([pathname,'Raw_Data_VB15'])
                                end

                                save([pathname,'Raw_Data_VB15/',filename,...
                                    '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '_c',num2str(c),'.mat'],'raw_part');
                                %---------------------------------------
                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
                                    cancel_process = 0;
                                    return;
                                end

                                disp('Now, evaluate FFT...')
                                im = fft3c(raw_part);
                                
                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
                                    cancel_process = 0;
                                    return;
                                end

                                disp('Saving image to file...')
                                %----- save image to .mat file
                                if ~isdir([pathname,'Reconstructed_Data_VB15'])
                                    mkdir([pathname,'Reconstructed_Data_VB15'])
                                end

                                save([pathname,'Reconstructed_Data_VB15/',filename,...
                                    '_image_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '_c',num2str(c),'.mat'],'im');
                                %----------------------------------------
                                disp('Done!')
                                clear im

                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
                                    cancel_process = 0;
                                    return;
                                end
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

                            % seperate each coil to cell to avoid 'Out of Memory'
                            for c=1:nc
                                raw_part(:,:,c) = raw{c}(:,:,1,s,e,r,i_set);
                            end
                            % -------------- conventional approach
                            %                     raw_part(:,:,:) = raw(:,:,1,:,s,e,r,i_set);

                            disp('Saving raw to file...')
                            %----- save raw to .mat file
                            if ~isdir([pathname,'Raw_Data_VB15'])
                                mkdir([pathname,'Raw_Data_VB15'])
                            end

                            save([pathname,'Raw_Data_VB15/',filename,...
                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                '_r',num2str(r),'_set',num2str(i_set),...
                                '.mat'],'raw_part');
                            %---------------------------------------
                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
                                cancel_process = 0;
                                return;
                            end

                            disp('Now, evaluate FFT...')
                            im = fft3c(raw_part,3);
                            
                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
                                cancel_process = 0;
                                return;
                            end

                            disp('Saving image to file...')
                            %----- save image to .mat file
                            if ~isdir([pathname,'Reconstructed_Data_VB15'])
                                mkdir([pathname,'Reconstructed_Data_VB15'])
                            end

                            save([pathname,'Reconstructed_Data_VB15/',filename,...
                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                '_r',num2str(r),'_set',num2str(i_set),...
                                '.mat'],'im');
                            %----------------------------------------
                            disp('Done!')
                            clear im

                            drawnow;
                            if cancel_process
                                disp('Processing canceled.')
                                cancel_process = 0;
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
            if nz>1 % 3D data
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
                                    % ------- extract one data from .mat file ------------------
                                    data = load([pathname,'Reconstructed_Data_VB15/',filename,...
                                        '_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '_c',num2str(c),'.mat'],'im');
                                    var_name = sort(fieldnames(data));    % get variable name in struct to cell
                                    im = eval(['data.',var_name{1}]);   % save file data to 'im'
                                    % ---------------------------------------------------------
                                    if c==1
                                        comp_mag_im = mag(im).^2;
                                        comp_ph_im = im;
                                    else
                                        comp_mag_im = comp_mag_im+mag(im).^2;
                                        comp_ph_im = comp_ph_im+im;
                                    end
                                    
                                    drawnow;
                                    if cancel_process
                                        disp('Processing canceled.')
                                        cancel_process = 0;
                                        return;
                                    end
                                end

                                comp_im = sqrt(comp_mag_im).*exp(j*angle(comp_ph_im));

                                disp('Saving composite image to file...')
                                % ------ save combined image to .mat file
                                if ~isdir([pathname,'Reconstructed_Data_VB15/Composite_image'])
                                    mkdir([pathname,'Reconstructed_Data_VB15/Composite_image'])
                                end
                                save([pathname,'Reconstructed_Data_VB15/Composite_image/',filename,...
                                    '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),'.mat'],'comp_im');
                                disp('Done!')

                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
                                    cancel_process = 0;
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
                                % ------- extract one data from .mat file ------------------
                                data = load([pathname,'Reconstructed_Data_VB15/',filename,...
                                    '_image_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),...
                                    '.mat'],'im');
                                var_name = sort(fieldnames(data));    % get variable name in struct to cell
                                im = eval(['data.',var_name{1}]);   % save file data to 'im'
                                % ---------------------------------------------------------

                                comp_im = SOS(im).*exp(j*angle(sum(im,3)));

                                disp('Saving composite image to file...')
                                % ------ save combined image to .mat file
                                if ~isdir([pathname,'Reconstructed_Data_VB15/Composite_image'])
                                    mkdir([pathname,'Reconstructed_Data_VB15/Composite_image'])
                                end
                                save([pathname,'Reconstructed_Data_VB15/Composite_image/',filename,...
                                    '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                    '_r',num2str(r),'_set',num2str(i_set),'.mat'],'comp_im');
                                disp('Done!')

                                drawnow;
                                if cancel_process
                                    disp('Processing canceled.')
                                    cancel_process = 0;
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end

    end % end of function save_RawimaComp


end% end of function mySiemensRead_v2

