function mySiemensRead(slice_range,image_spec,asc)
%% Information
% Only works in conventional 2DFT sequence
% Coded by cefca (Sang_young Zho).
% All rights reserved in MI laboratory.
% Last modified at 2008.05.28


%% set parameter

global make_comp_im;
global save_raw;
global force_iter;
global force_direct;
global sMDH;
global figHndl;

% glob_hdr = 32;   % global header in byte
mdh = 128; % measurement data header (byte) -> fixed

na = image_spec.na;
ver = image_spec.ver;
cp_coil_index = image_spec.cp_coil_index;
filename = image_spec.filename;
path = image_spec.path;
glob_hdr = image_spec.glo_hdr_size;   % global header in byte (found .out file)
nx = image_spec.nx;
ny = image_spec.ny;
nc = image_spec.nc;
ne = image_spec.ne;
ns = image_spec.ns;
read_os = image_spec.read_os;

%% get slice order info

% this function might have some misleading

% try
%     slice_order = getSliceOrder(asc,ns);
% catch
slice_order = (1:ns)';
% end

% %% set slice index in file
%
% slice_order = slice_order.';    % make it row
%
% slice_indic = false(1,ns);
% slice_indic(slice_range.min:slice_range.max) = 1;
%
% ordered_slice_indic = slice_order(slice_indic);


%% open .out file

fid = fopen([path filename '.out'],'r');
if fid==-1
    fid = fopen([path filename '.dat'],'r');
end

%% read data

tic;

disp('--------------------------------')
disp('Using Standard I/O File acces.')

%--- start entire loop

% raw = zeros(ny,nx*read_os,nc); % initialize one image data

% fseek(fid,32,'bof');    % skip 32 byte (global hdr) from bof(begining of file)

% conventional file structure
% raw[ny][ns][ne][nc][nx]   : 5 dimension

%% VB13

if isempty(strfind(ver,'VB15'))
    disp('not VB15')

    raw = zeros(ny,nx*read_os,nc,'single'); % initialize one image data
%     raw = complex(raw,raw);

    for s = slice_range.min:slice_range.max
        for e=1:ne

            if s<10
                add0 = '00';
            elseif s<100
                add0 = '0';
            else
                add0 = '';
            end

            %------- Do not processing when specific data exist.
            fid_raw = fopen([path,'Raw_Data/',filename,...
                '_raw_s',add0,num2str(s),'_e',num2str(e),'.mat']);
            fid_image = fopen([path,'Reconstructed_Data/',filename,...
                '_image_s',add0,num2str(s),'_e',num2str(e),'.mat']);
            fid_composite_image = fopen([path,'Reconstructed_Data/Composite_data/',filename,...
                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),'.mat']);

            exist_raw_file = (fid_raw~=-1); % no file -> 0
            exist_image_file = (fid_image~=-1); % no file -> 0
            exist_composite_image_file = (fid_composite_image~=-1);
            
            if exist_raw_file
                fclose(fid_raw);
            end

            if exist_image_file
                fclose(fid_image);
            end

            if exist_composite_image_file
                fclose(fid_composite_image);
            end

            if exist_image_file && (exist_composite_image_file || ~make_comp_im) ...
                    && (exist_raw_file || ~save_raw)
                disp([num2str(s),'th slice, ',num2str(e),'th echo image',...
                    ' has already processed!!'])
                break;
            end

            %---------------------------------------------------

            readLine_size = nx*read_os + mdh/8;   % in data size(each 8 byte)

            % nc_skip = (c-1)*readLine_size;
            ne_skip = (e-1)*nc*readLine_size;

            % ----- easy to misleading in slice indexing
            s_index = slice_order(s);
            ns_skip = (s_index-1)*ne*nc*readLine_size;
            % ----------------------------------------

            total_c_skip = ns_skip+ne_skip;

            disp('------------------------------')
            disp('Processing k-space data...')

            for y = 1:ny

                ny_skip = (y-1)*ns*ne*nc*readLine_size;

                total_skip = ny_skip+total_c_skip;

                fseek(fid,glob_hdr+total_skip*8,'bof');
                %     position = ftell(fid);

                for c= 1:nc
                    fseek(fid,mdh,'cof');   % skip mdh from current point
                    %     position1 = ftell(fid);

                    %     mdh_data = fread(fid,mdh/4,'uint32');

                    % read one read line
                    temp = fread(fid,nx*read_os*2,'float32');  % *2 -> real and imag
                    %     position2 = ftell(fid);

                    % make it complex
                    temp_cpx = complex(temp(1:2:length(temp)),temp(2:2:length(temp)));
                    % save to matrix
                    raw(y,:,c) = temp_cpx;
                end

            end
            
            % ======================= save raw file ===============================
            if save_raw && ~exist_raw_file
                
                disp('Now, save raw to file...')
                %----- save raw to .mat file
                if ~isdir([path,'Raw_Data'])
                    mkdir([path,'Raw_Data'])
                end

                save([path,'Raw_Data/',filename,...
                    '_raw_s',add0,num2str(s),'_e',num2str(e),'.mat'],'raw');

                disp([num2str(s),'th slice, ',num2str(e),'th echo ',...
                    ' Raw was saved in .mat file format.'])
                
            else

                disp([filename,'_raw_s',add0,num2str(s),'_e',num2str(e),'.mat',...
                    ' file exist.'])
            end %-------------------------------------- end save raw file

            disp('Done!!')
            disp('Now, evaluate FFT...')

            %%---------- FTed image

            im = zeros(ny,nx*read_os,nc);

            for c=1:nc
                im(:,:,c) = fft2c(raw(:,:,c));
                %     mrimage(im(:,:,c) );

            end

            if read_os==2
                im = im(:,nx/2+1:nx/2+nx,:);
            end
            % mrimage(im(:,:,1));

            disp('Done!!')

            % ======================= save file ===============================
            if exist_image_file

                disp([filename,'_image_s',add0,num2str(s),'_e',num2str(e),'.mat',...
                    ' file exist.'])

            else

                disp('Now, save image to file...')
                %----- save image to .mat file
                if ~isdir([path,'Reconstructed_Data'])
                    mkdir([path,'Reconstructed_Data'])
                end

                save([path,'Reconstructed_Data/',filename,...
                    '_image_s',add0,num2str(s),'_e',num2str(e),'.mat'],'im');

                disp([num2str(s),'th slice, ',num2str(e),'th echo ',...
                    ' Image was saved in .mat file format.'])

            end %-------------------------------------- end save image file

            if make_comp_im

                if exist_composite_image_file

                    disp([filename,'_Composite_image_s',add0,num2str(s),'_e',num2str(e),'.mat',...
                        ' file exist.'])

                else

                    disp('Now, save composite image to file...')
                    % ------ save combined image to .mat file
                    if ~isdir([path,'Reconstructed_Data/Composite_data'])
                        mkdir([path,'Reconstructed_Data/Composite_data'])
                    end

                    if cp_coil_index>0
                        im(:,:,cp_coil_index)=[];
                    end

                    sos_im = SOS(im);
                    phase_im = angle(sum(im,3));
                    composite_im = sos_im.*exp(j*phase_im);

                    clear sos_im;
                    clear phase_im;

                    save([path,'Reconstructed_Data/Composite_data/',filename,...
                        '_Composite_image_s',add0,num2str(s),'_e',num2str(e),'.mat'],'composite_im');

                    disp([num2str(s),'th slice, ',num2str(e),'th echo ',...
                        ' Composite Image was saved in .mat file format.'])

                end
            end %---------------------------------- end save composite image file
            % =================================================================

        end
    end
end
%% VB15

if ~isempty(strfind(ver,'VB15'))
    disp('VB15 - MDH based recon')


%% initialize for MDH based recon

    initMDH;

    fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)

    readMDH(fid);
    %------- assume NOISEADJSCAN exist at first of scan
    while readEIM(sMDH.aulEvalInfoMask,'MDH_NOISEADJSCAN')
        fseek(fid,sMDH.ushSamplesInScan*8,'cof');   % skip NOISEADJSCAN*8 bytes
        readMDH(fid);
    end     % last MDH have no NOISEADJSCAN info
    skip_NOISEADJSCAN_byte = ftell(fid)-mdh-glob_hdr;   % after global header

    nc = sMDH.ushUsedChannels;
    nx = sMDH.ushSamplesInScan; % nx will does not change during scan in 2DFT seq.

    max_dim = struct(...
        'line_index',0,...
        'acq_index',0,...
        'slice_index',0,...
        'part_index',0,...
        'echo_index',0,...
        'ph_index',0,...
        'rep_index',0,...
        'set_index',0,...
        'seg_index',0 ...
        );

    %------- find maximum index
    disp('------------------------------')
    disp('Finding maximum index. This will take some time.')
    disp('Searching whole MDH...')
    while ~readEIM(sMDH.aulEvalInfoMask,'MDH_ACQEND')
        %         disp(num2str((sMDH.ulScanCounter))) % for debugging

        max_dim.line_index = max(max_dim.line_index, sMDH.sLC.ushLine);
        max_dim.acq_index = max(max_dim.acq_index, sMDH.sLC.ushAcquisition);
        max_dim.slice_index = max(max_dim.slice_index, sMDH.sLC.ushSlice);
        max_dim.part_index = max(max_dim.part_index, sMDH.sLC.ushPartition);
        max_dim.echo_index = max(max_dim.echo_index, sMDH.sLC.ushEcho);
        max_dim.ph_index = max(max_dim.ph_index, sMDH.sLC.ushPhase);
        max_dim.rep_index = max(max_dim.rep_index, sMDH.sLC.ushRepetition);
        max_dim.set_index = max(max_dim.set_index, sMDH.sLC.ushSet);
        max_dim.seg_index = max(max_dim.seg_index, sMDH.sLC.ushSeg);

        fseek(fid,sMDH.ushSamplesInScan*8,'cof');   % skip NOISEADJSCAN*8 bytes
        fseek(fid,(mdh+nx*8)*(nc-1),'cof');    % skip remain channel
        readMDH(fid);
    end
    disp('Done!')

    assignin('base','max_dim',max_dim); % for debugging
    assignin('base','nc',nc); % for debugging
    assignin('base','nx',nx); % for debugging
    
    disp('------------------------------')
    disp('- found maximum dimension (you should +1) : ')
    disp(max_dim)
    disp('-------- image spec ----------')
    disp(['- # of samples in each line : ',num2str(nx)])
    disp(['- # of channel : ',num2str(nc)])
    
    %-------- redefine image spec
    ny = max_dim.line_index+1;
    ne = max_dim.echo_index+1;
    na = max_dim.acq_index+1;
%     nseg = max_dim.seg_index+1;
    nz = max_dim.part_index+1;
    ns = max_dim.slice_index+1;
    nr = max_dim.rep_index+1;
    nset = max_dim.set_index+1;

    if mod(ny,2)
        ny = ny+1;
    end
    
    disp(['- # of PEy : ',num2str(ny)])
    disp(['- # of PEz : ',num2str(nz)])
    disp(['- # of slice : ',num2str(ns)])
    disp(['- # of echo : ',num2str(ne)])
    disp(['- # of Acqusition : ',num2str(na)])
    disp(['- # of set : ',num2str(nset)])
    disp(['- # of Repetition : ',num2str(nr)])
    disp(' ')

%% check file size
% I cannot know how process for TSE seq.
% -> try do not care segment index

    fseek(fid,0,'eof');
    file_size = ftell(fid);

    if file_size * image_spec.AccelFactPE * image_spec.AccelFact3D ...
            < 800000000    % 800 MB
        read_whole_data = true;
    else
        read_whole_data = false;
    end
    
    if force_iter
        read_whole_data = false;
    end

    if force_direct
        read_whole_data = true;
    end
    
%     read_whole_data=0;
    
%% Method 1 - don't care memory

% try
    if read_whole_data
        disp('------------------------------')
        disp('Read whole data at once.')

        %-------- init matrix
        if nz>1 % 3D data
%             raw_full = single(zeros(ny,nx,nz,nc,nseg,ns,ne,na,nr,nset));
            raw_full = zeros(ny,nx,nz,nc,ns,ne,na,nr,nset,'single');
%             raw_full = complex(raw_full,raw_full);
            raw = zeros(ny,nx,nz,'single');
%             raw = complex(raw,raw);
            if make_comp_im
                im4D = zeros(ny,nx,nz,nc,'single');
            end
%             im4D = complex(im4D,im4D);
            
        else    % 2D data (i.e. nz=1)
%             raw_full = single(zeros(ny,nx,nc,nz,nseg,ns,ne,na,nr,nset));
            raw_full = zeros(ny,nx,nc,nz,ns,ne,na,nr,nset,'single');
%             raw_full = complex(raw_full,raw_full);
            raw = zeros(ny,nx,nc,'single');
%             raw = complex(raw,raw);
        end

        disp('------------------------------')
        disp('Processing k-space data...')
        %-------- rewind file pointer
        fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)
        fseek(fid,skip_NOISEADJSCAN_byte,'cof');

        readMDH(fid);
        while ~readEIM(sMDH.aulEvalInfoMask,'MDH_ACQEND')
            cur_a = sMDH.sLC.ushAcquisition+1;
            cur_e = sMDH.sLC.ushEcho+1;
            cur_s = sMDH.sLC.ushSlice+1;
%             cur_seg = sMDH.sLC.ushSeg+1;
            cur_c = sMDH.ulChannelId+1;
            cur_z = sMDH.sLC.ushPartition+1;
            cur_y = sMDH.sLC.ushLine+1;
            cur_r = sMDH.sLC.ushRepetition+1;
            cur_set = sMDH.sLC.ushSet+1;

            temp = fread(fid,nx*2,'float32');  % *2 -> real and imag
            % make it complex and save to matrix
            if nz>1 % 3D data
                raw_full(cur_y,:,cur_z,...
                    cur_c,cur_s,...
                    cur_e,cur_a,cur_r,...
                    cur_set) = complex(temp(1:2:length(temp)),temp(2:2:length(temp)));
            else    % 2D data (i.e. nz=1)
                raw_full(cur_y,:,cur_c,...
                    cur_z,cur_s,...
                    cur_e,cur_a,cur_r,...
                    cur_set) = complex(temp(1:2:length(temp)),temp(2:2:length(temp)));
            end

            readMDH(fid);
        end

        %------------------------ divide into matrix --------------------------
        if nz>1 % 3D data
            for i_set = 1:nset
                for r = 1:nr
                    for a = 1:na
                        for e = 1:ne
                            for s = 1:ns
                                if s<10
                                    add0 = '00';
                                elseif s<100
                                    add0 = '0';
                                else
                                    add0 = '';
                                end

%                                 for seg = 1:nseg
                                    for c = 1:nc
                                        do_process = 1;
                                        
                                        %------- Do not processing when specific data exist.
                                        fid_raw = fopen([path,'Raw_Data_VB15/',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '_c',num2str(c),'.mat']);
                                        fid_image = fopen([path,'Reconstructed_Data_VB15/',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '_c',num2str(c),'.mat']);
                                        fid_composite_image = fopen([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                            '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat']);

                                        exist_raw_file = (fid_raw~=-1); % no file -> 0
                                        exist_image_file = (fid_image~=-1); % no file -> 0
                                        exist_composite_image_file = (fid_composite_image~=-1);

                                        if exist_raw_file
                                            fclose(fid_raw);
                                        end
                                        
                                        if exist_image_file
                                            fclose(fid_image);
                                        end

                                        if exist_composite_image_file
                                            fclose(fid_composite_image);
                                        end

                                        if exist_image_file && (exist_composite_image_file || ~make_comp_im) ...
                                                && (exist_raw_file || ~save_raw)
                                            disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
                                                num2str(a),'th acq, ',...%num2str(seg),'th segment, ',...
                                                num2str(r),'th rep, ',num2str(i_set),'th set ','image',...
                                                ' has already processed!!'])
                                            do_process = 0;
                                        end
                                        %---------------------------------------------------
                                        
                                        if do_process

%                                         raw(:,:,:) = raw_full(:,:,:,c,seg,s,e,a,r,i_set);
                                        raw(:,:,:) = raw_full(:,:,:,c,s,e,a,r,i_set);

                                        % ======================= save raw file ===============================
                                        if save_raw && ~exist_raw_file
                                            disp('Now, save raw to file...')
                                            %----- save raw to .mat file
                                            if ~isdir([path,'Raw_Data_VB15'])
                                                mkdir([path,'Raw_Data_VB15'])
                                            end

                                            save([path,'Raw_Data_VB15/',filename,...
                                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat'],'raw');

                                            disp(['[',filename,...
                                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] Raw file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 num2str(c),'th coil,',...
%                                                 ' Raw was saved in .mat file format.'])

                                        elseif save_raw && exist_raw_file
                                            disp(['[',filename,...
                                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] file exist.'])
                                        end %-------------------------------------- end save raw file
                                        
                                        disp('Now, evaluate FFT...')
                                        im = fft3c(raw);

                                        % ======================= save file ===============================
                                        if exist_image_file

                                            disp(['[',filename,...
                                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] file exist.'])

                                        else
                                            disp('Now, save image to file...')
                                            %----- save image to .mat file
                                            if ~isdir([path,'Reconstructed_Data_VB15'])
                                                mkdir([path,'Reconstructed_Data_VB15'])
                                            end

                                            save([path,'Reconstructed_Data_VB15/',filename,...
                                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat'],'im');

                                            disp(['[',filename,...
                                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] Image file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 num2str(c),'th coil,',...
%                                                 ' Image was saved in .mat file format.'])
                                        end %-------------------------------------- end save image file

                                        if make_comp_im
                                            try
                                                im4D(:,:,:,c) = im;
                                            catch
                                                disp('+++++++++++++++++++++++++++++++++++++++++++++++')
                                                disp('Error occurred. Failed to make Composite image.')
                                                disp('+++++++++++++++++++++++++++++++++++++++++++++++')
                                                clear im4D
                                                make_comp_im = 0;
                                                set(figHndl.checkbox1,'Value',0)
                                            end
                                        end
                                        
                                        end % end of do_process
                                    end % end of nc

                                    if make_comp_im
                                        clear im;

                                        if exist_composite_image_file

                                            disp(['[',filename,'_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat',...
                                                '] file exist.'])

                                        else

                                            disp('Now, save composite image to file...')
                                            % ------ save combined image to .mat file
                                            if ~isdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                                mkdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                            end

                                            sos_im = sqrt(sum(mag(im4D).^2,4));
                                            phase_im = angle(sum(im4D,4));
                                            composite_im = sos_im.*exp(j*phase_im);

                                            clear sos_im;
                                            clear phase_im;

                                            save([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),'.mat'],'composite_im');

                                            disp(['[',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),'.mat',...
                                                '] Composite Image file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment,',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 ' Composite Image was saved in .mat file format.'])
                                        end
                                    end %-------------------------------------- end save composite image file
                                    % ========================================================================
%                                 end
                            end
                        end
                    end
                end
            end

        else    % 2D data (i.e. nz=1)
            for i_set = 1:nset
                for r = 1:nr
                    for a = 1:na
                        for e = 1:ne
                            for s = 1:ns
                                if s<10
                                    add0 = '00';
                                elseif s<100
                                    add0 = '0';
                                else
                                    add0 = '';
                                end
                                
                                do_process = 1;
                                
%                                 for seg = 1:nseg
                                    %------- Do not processing when specific data exist.
                                    fid_raw = fopen([path,'Raw_Data_VB15/',filename,...
                                        '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                        '_acq',num2str(a),...%'_seg',num2str(seg),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '.mat']);
                                    fid_image = fopen([path,'Reconstructed_Data_VB15/',filename,...
                                        '_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_acq',num2str(a),...%'_seg',num2str(seg),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '.mat']);
                                    fid_composite_image = fopen([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                        '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_acq',num2str(a),...%'_seg',num2str(seg),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '.mat']);

                                    exist_raw_file = (fid_raw~=-1); % no file -> 0
                                    exist_image_file = (fid_image~=-1); % no file -> 0
                                    exist_composite_image_file = (fid_composite_image~=-1);

                                    if exist_raw_file
                                        fclose(fid_raw);
                                    end
                                    
                                    if exist_image_file
                                        fclose(fid_image);
                                    end

                                    if exist_composite_image_file
                                        fclose(fid_composite_image);
                                    end

                                    if exist_image_file && (exist_composite_image_file || ~make_comp_im) ...
                                            && (exist_raw_file || ~save_raw)
                                        disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
                                            num2str(a),'th acq, ',...%num2str(seg),'th segment, ',...
                                            num2str(r),'th rep, ',num2str(i_set),'th set ','image',...
                                            ' has already processed!!'])
                                        do_process = 0;
                                    end
                                    %---------------------------------------------------
                                    
                                    if do_process

%                                     raw(:,:,:) = raw_full(:,:,:,nz,seg,s,e,a,r,i_set);
                                    raw(:,:,:) = raw_full(:,:,:,nz,s,e,a,r,i_set);

                                    % ======================= save raw file ===============================
                                    if save_raw && ~exist_raw_file
                                        disp('Now, save raw to file...')
                                        %----- save raw to .mat file
                                        if ~isdir([path,'Raw_Data_VB15'])
                                            mkdir([path,'Raw_Data_VB15'])
                                        end

                                        save([path,'Raw_Data_VB15/',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat'],'raw');

                                        disp(['[',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] Raw file was saved in .mat file format.'])
                                        
%                                         disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                             num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                             num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                             ' Raw was saved in .mat file format.'])
                                        
                                    elseif save_raw && exist_raw_file
                                        disp(['[',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] file exist.'])
                                    end %-------------------------------------- end save raw file
                                    
                                    disp('Now, evaluate FFT...')
                                    im = fft3c(raw,3);

                                    % ======================= save file ===============================
                                    if exist_image_file

                                        disp(['[',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] file exist.'])

                                    else
                                        disp('Now, save image to file...')
                                        %----- save image to .mat file
                                        if ~isdir([path,'Reconstructed_Data_VB15'])
                                            mkdir([path,'Reconstructed_Data_VB15'])
                                        end

                                        save([path,'Reconstructed_Data_VB15/',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat'],'im');

                                        disp(['[',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] Image file was saved in .mat file format.'])
                                        
%                                         disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                             num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                             num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                             ' Image was saved in .mat file format.'])
                                    end %-------------------------------------- end save image file

                                    end % end of do_process
                                    
                                    if make_comp_im

                                        if exist_composite_image_file

                                            disp(['[',filename,'_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat',...
                                                '] file exist.'])

                                        else

                                            disp('Now, save composite image to file...')
                                            % ------ save combined image to .mat file
                                            if ~isdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                                mkdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                            end

                                            if cp_coil_index>0
                                                im(:,:,cp_coil_index)=[];
                                            end

                                            sos_im = SOS(im);
                                            phase_im = angle(sum(im,3));
                                            composite_im = sos_im.*exp(j*phase_im);

                                            clear sos_im;
                                            clear phase_im;

                                            save([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat'],'composite_im');

                                            disp(['[',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat',...
                                                '] Composite Image file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment,',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 ' Composite Image was saved in .mat file format.'])
                                        end
                                    end %-------------------------------------- end save composite image file
                                    % ========================================================================
%                                 end
                            end
                        end
                    end
                end
            end


        end
        %----------------------------------------------------------------------



    end
    
% catch
%     disp('++++++++++++++++++++++++++++++++++++')
%     disp('Error occurred. Maybe memory error')
%     disp('Try second method.')
%     disp('++++++++++++++++++++++++++++++++++++')
%     
%     clear raw_full
%     clear raw
%     clear im4D
%     clear im
%     
%     read_whole_data = 0;
% end

%% Method 2 - avoid memory prob. - This is very slow, slow, slow... ぬぬ

    if ~read_whole_data
        disp('------------------------------')
        disp('Read data iteratively.')
        disp('This is very slow, slow, slow... ぬぬ')

        if nz>1 % 3D data

            %-------- init matrix
            raw = zeros(ny,nx,nz,'single');
%             raw = complex(raw,raw);
        if make_comp_im
            im4D = zeros(ny,nx,nz,nc,'single');
        end
%             im4D = complex(im4D,im4D);

            for i_set = 1:nset
                for r = 1:nr
                    for a = 1:na
                        for e = 1:ne
                            for s = 1:ns
                                if s<10
                                    add0 = '00';
                                elseif s<100
                                    add0 = '0';
                                else
                                    add0 = '';
                                end

%                                 for seg = 1:nseg
                                    for c = 1:nc
                                        do_process = 1;
                                        
                                        %------- Do not processing when specific data exist.
                                        fid_raw = fopen([path,'Raw_Data_VB15/',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '_c',num2str(c),'.mat']);
                                        fid_image = fopen([path,'Reconstructed_Data_VB15/',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '_c',num2str(c),'.mat']);
                                        fid_composite_image = fopen([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                            '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat']);

                                        exist_raw_file = (fid_raw~=-1); % no file -> 0
                                        exist_image_file = (fid_image~=-1); % no file -> 0
                                        exist_composite_image_file = (fid_composite_image~=-1);

                                        if exist_raw_file
                                            fclose(fid_raw);
                                        end
                                        
                                        if exist_image_file
                                            fclose(fid_image);
                                        end

                                        if exist_composite_image_file
                                            fclose(fid_composite_image);
                                        end

                                        if exist_image_file && (exist_composite_image_file || ~make_comp_im) ...
                                                && (exist_raw_file || ~save_raw)
                                            disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
                                                num2str(a),'th acq, ',...%num2str(seg),'th segment, ',...
                                                num2str(r),'th rep, ',num2str(i_set),'th set ','image',...
                                                ' has already processed!!'])
                                            do_process = 0;
                                        end
                                        %---------------------------------------------------
%                                     end

                                        if do_process
                                            
                                        disp('------------------------------')
                                        disp('Processing k-space data...')
                                        %-------- rewind file pointer
                                        fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)
                                        fseek(fid,skip_NOISEADJSCAN_byte,'cof');

                                        readMDH(fid);
                                        while ~readEIM(sMDH.aulEvalInfoMask,'MDH_ACQEND')
                                            cur_a = sMDH.sLC.ushAcquisition+1;
                                            cur_e = sMDH.sLC.ushEcho+1;
                                            cur_s = sMDH.sLC.ushSlice+1;
%                                             cur_seg = sMDH.sLC.ushSeg+1;
                                            cur_c = sMDH.ulChannelId+1;
                                            cur_z = sMDH.sLC.ushPartition+1;
                                            cur_y = sMDH.sLC.ushLine+1;
                                            cur_r = sMDH.sLC.ushRepetition+1;
                                            cur_set = sMDH.sLC.ushSet+1;

                                            if cur_a==a && cur_e==e ...
                                                    && cur_s==s ...% && cur_seg==seg ...
                                                    && cur_r==r && cur_c==c ...
                                                    && cur_set==i_set
                                                temp = fread(fid,nx*2,'float32');  % *2 -> real and imag
                                                % make it complex
                                                raw(cur_y,:,cur_z) = complex(temp(1:2:length(temp)),temp(2:2:length(temp)));
                                            else
                                                fseek(fid,nx*8,'cof');
                                            end

                                            readMDH(fid);
                                        end

%                                         for c = 1:nc
%                                             raw = raw4D(:,:,:,c);
                                            
                                        % ======================= save raw file ===============================
                                        if save_raw && ~exist_raw_file
                                            disp('Now, save raw to file...')
                                            %----- save raw to .mat file
                                            if ~isdir([path,'Raw_Data_VB15'])
                                                mkdir([path,'Raw_Data_VB15'])
                                            end

                                            save([path,'Raw_Data_VB15/',filename,...
                                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat'],'raw');

                                            disp(['[',filename,...
                                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] Raw file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 num2str(c),'th coil,',...
%                                                 ' Raw was saved in .mat file format.'])

                                        elseif save_raw && exist_raw_file
                                            disp(['[',filename,...
                                                '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] file exist.'])
                                        end %-------------------------------------- end save raw file
                                        
                                        disp('Now, evaluate FFT...')
                                        im = fft3c(raw);
                                        
                                        % ======================= save file ===============================
                                        if exist_image_file

                                            disp(['[',filename,...
                                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] file exist.'])

                                        else
                                            disp('Now, save image to file...')
                                            %----- save image to .mat file
                                            if ~isdir([path,'Reconstructed_Data_VB15'])
                                                mkdir([path,'Reconstructed_Data_VB15'])
                                            end

                                            save([path,'Reconstructed_Data_VB15/',filename,...
                                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat'],'im');

                                            disp(['[',filename,...
                                                '_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '_c',num2str(c),'.mat',...
                                                '] Image file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 num2str(c),'th coil,',...
%                                                 ' Image was saved in .mat file format.'])
                                        end %-------------------------------------- end save image file
                                        
                                        if make_comp_im
                                            try
                                                im4D(:,:,:,c) = im;
                                            catch
                                                disp('+++++++++++++++++++++++++++++++++++++++++++++++')
                                                disp('Error occurred. Failed to make Composite image.')
                                                disp('+++++++++++++++++++++++++++++++++++++++++++++++')
                                                clear im4D
                                                make_comp_im = 0;
                                                set(figHndl.checkbox1,'Value',0)
                                            end
                                        end
                                        
                                        end % end of do_process
                                    end % end of nc

                                    if make_comp_im
                                        clear im;

                                        if exist_composite_image_file

                                            disp(['[',filename,'_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat',...
                                                '] file exist.'])

                                        else

                                            disp('Now, save composite image to file...')
                                            % ------ save combined image to .mat file
                                            if ~isdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                                mkdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                            end

                                            sos_im = sqrt(sum(mag(im4D).^2,4));
                                            phase_im = angle(sum(im4D,4));
                                            composite_im = sos_im.*exp(j*phase_im);

                                            clear sos_im;
                                            clear phase_im;

                                            save([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),'.mat'],'composite_im');

                                            disp(['[',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),'.mat',...
                                                '] Composite Image file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment,',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 ' Composite Image was saved in .mat file format.'])
                                        end
                                    end %-------------------------------------- end save composite image file
                                    % ========================================================================                        % ================


%                                 end
                            end
                        end
                    end
                end
            end
            
        else    % 2D data (i.e. nz=1)
            
            %-------- init matrix
            raw = zeros(ny,nx,nc,'single');
%             raw = complex(raw,raw);

            for i_set = 1:nset
                for r = 1:nr
                    for a = 1:na
                        for e = 1:ne
                            for s = 1:ns
                                if s<10
                                    add0 = '00';
                                elseif s<100
                                    add0 = '0';
                                else
                                    add0 = '';
                                end

                                do_process = 1;
                                
%                                 for seg = 1:nseg
                                    %------- Do not processing when specific data exist.
                                    fid_raw = fopen([path,'Raw_Data_VB15/',filename,...
                                        '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                        '_acq',num2str(a),...%'_seg',num2str(seg),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '.mat']);
                                    fid_image = fopen([path,'Reconstructed_Data_VB15/',filename,...
                                        '_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_acq',num2str(a),...%'_seg',num2str(seg),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '.mat']);
                                    fid_composite_image = fopen([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                        '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                        '_acq',num2str(a),...%'_seg',num2str(seg),...
                                        '_r',num2str(r),'_set',num2str(i_set),...
                                        '.mat']);

                                    exist_raw_file = (fid_raw~=-1); % no file -> 0
                                    exist_image_file = (fid_image~=-1); % no file -> 0
                                    exist_composite_image_file = (fid_composite_image~=-1);

                                    if exist_raw_file
                                        fclose(fid_raw);
                                    end
                                    
                                    if exist_image_file
                                        fclose(fid_image);
                                    end

                                    if exist_composite_image_file
                                        fclose(fid_composite_image);
                                    end

                                    if exist_image_file && (exist_composite_image_file || ~make_comp_im) ...
                                            && (exist_raw_file || ~save_raw)
                                        disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
                                            num2str(a),'th acq, ',...%num2str(seg),'th segment, ',...
                                            num2str(r),'th rep, ',num2str(i_set),'th set ','image',...
                                            ' has already processed!!'])
                                        do_process = 0;
                                    end
                                    %---------------------------------------------------

                                    if do_process
                                        
                                    disp('------------------------------')
                                    disp('Processing k-space data...')
                                    %-------- rewind file pointer
                                    fseek(fid,glob_hdr,'bof');    % skip (global hdr) from bof(begining of file)
                                    fseek(fid,skip_NOISEADJSCAN_byte,'cof');

                                    readMDH(fid);
                                    while ~readEIM(sMDH.aulEvalInfoMask,'MDH_ACQEND')
                                        %                             disp(num2str((sMDH.ulScanCounter))) % for debugging

                                        cur_a = sMDH.sLC.ushAcquisition+1;
                                        cur_e = sMDH.sLC.ushEcho+1;
                                        cur_s = sMDH.sLC.ushSlice+1;
%                                         cur_seg = sMDH.sLC.ushSeg+1;
                                        cur_c = sMDH.ulChannelId+1;
                                        cur_y = sMDH.sLC.ushLine+1;
                                        cur_r = sMDH.sLC.ushRepetition+1;
                                        cur_set = sMDH.sLC.ushSet+1;

                                        if cur_a==a && cur_e==e ...
                                                && cur_s==s ...% && cur_seg==seg ...
                                                && cur_r==r && cur_set==i_set
                                            temp = fread(fid,nx*2,'float32');  % *2 -> real and imag
                                            % make it complex
                                            raw(cur_y,:,cur_c) = complex(temp(1:2:length(temp)),temp(2:2:length(temp)));
                                            %                                 disp('process 1 PE line') % for debugging
                                        else
                                            fseek(fid,nx*8,'cof');
                                            %                                 disp('skip') % for debugging
                                        end

                                        readMDH(fid);
                                    end

                                    % ======================= save raw file ===============================
                                    if save_raw && ~exist_raw_file
                                        disp('Now, save raw to file...')
                                        %----- save raw to .mat file
                                        if ~isdir([path,'Raw_Data_VB15'])
                                            mkdir([path,'Raw_Data_VB15'])
                                        end

                                        save([path,'Raw_Data_VB15/',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat'],'raw');

                                        disp(['[',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] Raw file was saved in .mat file format.'])
                                        
%                                         disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                             num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                             num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                             ' Raw was saved in .mat file format.'])
                                        
                                    elseif save_raw && exist_raw_file
                                        disp(['[',filename,...
                                            '_raw_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] file exist.'])
                                    end %-------------------------------------- end save raw file
                                    
                                    disp('Now, evaluate FFT...')
                                    im = fft3c(raw,3);

                                    % ======================= save file ===============================
                                    if exist_image_file

                                        disp(['[',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] file exist.'])

                                    else
                                        disp('Now, save image to file...')
                                        %----- save image to .mat file
                                        if ~isdir([path,'Reconstructed_Data_VB15'])
                                            mkdir([path,'Reconstructed_Data_VB15'])
                                        end

                                        save([path,'Reconstructed_Data_VB15/',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat'],'im');

                                        disp(['[',filename,...
                                            '_image_s',add0,num2str(s),'_e',num2str(e),...
                                            '_acq',num2str(a),...%'_seg',num2str(seg),...
                                            '_r',num2str(r),'_set',num2str(i_set),...
                                            '.mat',...
                                            '] Image file was saved in .mat file format.'])
                                        
%                                         disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                             num2str(a),'th acq, ',num2str(seg),'th segment, ',...
%                                             num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                             ' Image was saved in .mat file format.'])
                                    end %-------------------------------------- end save image file

                                    end % end of do_process
                                    
                                    if make_comp_im

                                        if exist_composite_image_file

                                            disp(['[',filename,'_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat',...
                                                '] file exist.'])

                                        else

                                            disp('Now, save composite image to file...')
                                            % ------ save combined image to .mat file
                                            if ~isdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                                mkdir([path,'Reconstructed_Data_VB15/Composite_data'])
                                            end

                                            if cp_coil_index>0
                                                im(:,:,cp_coil_index)=[];
                                            end

                                            sos_im = SOS(im);
                                            phase_im = angle(sum(im,3));
                                            composite_im = sos_im.*exp(j*phase_im);

                                            clear sos_im;
                                            clear phase_im;

                                            save([path,'Reconstructed_Data_VB15/Composite_data/',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat'],'composite_im');

                                            disp(['[',filename,...
                                                '_Composite_image_s',add0,num2str(s),'_e',num2str(e),...
                                                '_acq',num2str(a),...%'_seg',num2str(seg),...
                                                '_r',num2str(r),'_set',num2str(i_set),...
                                                '.mat',...
                                                '] Composite Image file was saved in .mat file format.'])
                                            
%                                             disp([num2str(s),'th slice, ',num2str(e),'th echo, ',...
%                                                 num2str(a),'th acq, ',num2str(seg),'th segment,',...
%                                                 num2str(r),'th rep, ',num2str(i_set),'th set, ',...
%                                                 ' Composite Image was saved in .mat file format.'])
                                        end
                                    end %-------------------------------------- end save composite image file
                                    % ========================================================================                        % ================

%                                 end
                            end
                        end
                    end
                end
            end
            
            
        end


    end

end     % end of VB15
%% end of algorithm

disp('=========================================================================')
% eval('dispetime(toc,0);','disp(''Total ''),toc')
dispetime(toc,0);
disp('=========================================================================')

fclose(fid);


