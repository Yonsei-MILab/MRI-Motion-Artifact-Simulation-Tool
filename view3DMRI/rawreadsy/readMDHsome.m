function readMDHsome(fid)
% extract from ReadSiemensMeas
% by Maolin Qiu YALE 11-26-2007 (maolin.qiu(at)yale(dot)edu)
% This is exactly same as MDH.h in IDEA
%
% call initMDH() before this function

global sMDH;

%% EvalInfoMask - dragged from MdhProxy.h in IDEA

% /*--------------------------------------------------------------------------*/
% /*  Definition of EvalInfoMask:                                             */
% /*--------------------------------------------------------------------------*/
% const MdhBitField MDH_ACQEND            ((unsigned long)0);
% const MdhBitField MDH_RTFEEDBACK        (1);
% const MdhBitField MDH_HPFEEDBACK        (2);
% const MdhBitField MDH_ONLINE            (3);
% const MdhBitField MDH_OFFLINE           (4);
% const MdhBitField MDH_SYNCDATA          (5);       // readout contains synchroneous data
% const MdhBitField MDH_LASTSCANINCONCAT  (8);       // Flag for last scan in concatination
% 
% const MdhBitField MDH_RAWDATACORRECTION (10);      // Correct the rawadata with the rawdata correction factor
% const MdhBitField MDH_LASTSCANINMEAS    (11);      // Flag for last scan in measurement
% const MdhBitField MDH_SCANSCALEFACTOR   (12);      // Flag for scan specific additional scale factor
% const MdhBitField MDH_2NDHADAMARPULSE   (13);      // 2nd RF exitation of HADAMAR
% const MdhBitField MDH_REFPHASESTABSCAN  (14);      // reference phase stabilization scan         
% const MdhBitField MDH_PHASESTABSCAN     (15);      // phase stabilization scan
% const MdhBitField MDH_D3FFT             (16);      // execute 3D FFT         
% const MdhBitField MDH_SIGNREV           (17);      // sign reversal
% const MdhBitField MDH_PHASEFFT          (18);      // execute phase fft     
% const MdhBitField MDH_SWAPPED           (19);      // swapped phase/readout direction
% const MdhBitField MDH_POSTSHAREDLINE    (20);      // shared line               
% const MdhBitField MDH_PHASCOR           (21);      // phase correction data    
% const MdhBitField MDH_PATREFSCAN        (22);      // additonal scan for PAT reference line/partition
% const MdhBitField MDH_PATREFANDIMASCAN  (23);      // additonal scan for PAT reference line/partition that is also used as image scan
% const MdhBitField MDH_REFLECT           (24);      // reflect line              
% const MdhBitField MDH_NOISEADJSCAN      (25);      // noise adjust scan --> Not used in NUM4        
% const MdhBitField MDH_SHARENOW          (26);      // all lines are acquired from the actual and previous e.g. phases
% const MdhBitField MDH_LASTMEASUREDLINE  (27);      // indicates that the current line is the last measured line of all succeeding e.g. phases
% const MdhBitField MDH_FIRSTSCANINSLICE  (28);      // indicates first scan in slice (needed for time stamps)
% const MdhBitField MDH_LASTSCANINSLICE   (29);      // indicates  last scan in slice (needed for time stamps)
% const MdhBitField MDH_TREFFECTIVEBEGIN  (30);      // indicates the begin time stamp for TReff (triggered measurement)
% const MdhBitField MDH_TREFFECTIVEEND    (31);      // indicates the   end time stamp for TReff (triggered measurement)
% 
% const MdhBitField MDH_FIRST_SCAN_IN_BLADE       (40);  // Marks the first line of a blade
% const MdhBitField MDH_LAST_SCAN_IN_BLADE        (41);  // Marks the last line of a blade
% const MdhBitField MDH_LAST_BLADE_IN_TR          (42);  // Set for all lines of the last BLADE in each TR interval
% 
% const MdhBitField MDH_RETRO_LASTPHASE           (45);  // Marks the last phase in a heartbeat
% const MdhBitField MDH_RETRO_ENDOFMEAS           (46);  // Marks an ADC at the end of the measurement
% const MdhBitField MDH_RETRO_REPEATTHISHEARTBEAT (47);  // Repeat the current heartbeat when this bit is found
% const MdhBitField MDH_RETRO_REPEATPREVHEARTBEAT (48);  // Repeat the previous heartbeat when this bit is found
% const MdhBitField MDH_RETRO_ABORTSCANNOW        (49);  // Just abort everything
% const MdhBitField MDH_RETRO_LASTHEARTBEAT       (50);  // This adc is from the last heartbeat (a dummy)
% const MdhBitField MDH_RETRO_DUMMYSCAN           (51);  // This adc is just a dummy scan, throw it away
% const MdhBitField MDH_RETRO_ARRDETDISABLED      (52);  // Disable all arrhythmia detection when this bit is found

%% Constants used in sMDH

MDH_NUMBEROFEVALINFOMASK   = 2;
% MDH_NUMBEROFICEPROGRAMPARA = 4;
% MDH_FREEHDRPARA            = 4;


%% Definition of loop counter structure                                     %%
% Note: any changes of this structure affect the corresponding swapping    %%
%       method of the measurement data header proxy class (MdhProxy)       %%

% sLoopCounter = struct( ...
%   'ushLine',0,...                  %% unsigned short  line index                   %%
%   'ushAcquisition',0,...           %% unsigned short  acquisition index            %%
%   'ushSlice',0,...                 %% unsigned short  slice index                  %%
%   'ushPartition',0,...             %% unsigned short  partition index              %%
%   'ushEcho',0,...                  %% unsigned short  echo index                   %%	
%   'ushPhase',0,...                 %% unsigned short  phase index                  %%
%   'ushRepetition',0,...            %% unsigned short  measurement repeat index     %%
%   'ushSet',0,...                   %% unsigned short  set index                    %%
%   'ushSeg',0,...                   %% unsigned short  segment index  (for TSE)     %%
%   'ushIda',0,...                   %% unsigned short  IceDimension a index         %%
%   'ushIdb',0,...                   %% unsigned short  IceDimension b index         %%
%   'ushIdc',0,...                   %% unsigned short  IceDimension c index         %%
%   'ushIdd',0,...                   %% unsigned short  IceDimension d index         %%
%   'ushIde',0 ...                   %% unsigned short  IceDimension e index         %%
% );                                 %% sizeof : 28 byte             %%

%%  Definition of slice vectors                                             %%

% sVector = struct( ...
%   'flSag',0.0,...       %% float
%   'flCor',0.0,...       %% float
%   'flTra',0.0 ...       %% float
% );

% sSliceData = struct( ...
%   'sSlicePosVec',sVector,...                   %% slice position vector               %%
%   'aflQuaternion',zeros(1,4) ...               %% float rotation matrix as quaternion %%
% );                                              %% sizeof : 28 byte                    %%

%%  Definition of cut-off data                                              %%

% sCutOffData = struct( ...
%   'ushPre',0,...               %% unsigned short  write ushPre zeros at line start %%
%   'ushPost',0 ...              %% unsigned short  write ushPost zeros at line end  %%
% );

%%  Definition of measurement data header                                   %%

% sMDH = struct( ...
%   'ulDMALength',0,...                                       %% unsigned long  DMA length [bytes] must be                        4 bytes %% first parameter                        
%   'lMeasUID',0,...                                          %% long           measurement user ID                               4     
%   'ulScanCounter',0,...                                     %% unsigned long  scan counter [1...]                               4
%   'ulTimeStamp',0,...                                       %% unsigned long  time stamp [2.5 ms ticks since 00:00]             4
%   'ulPMUTimeStamp',0,...                                    %% unsigned long  PMU time stamp [2.5 ms ticks since last trigger]  4
%   'aulEvalInfoMask',zeros(1,MDH_NUMBEROFEVALINFOMASK),...   %% unsigned long  evaluation info mask field                        8
%   'ushSamplesInScan',0,...                                  %% unsigned short # of samples acquired in scan                     2
%   'ushUsedChannels',0,...                                   %% unsigned short # of channels used in scan                        2   =32
%   'sLC',sLoopCounter,...                                    %% loop counters                                                    28  =60
%   'sCutOff',sCutOffData,...                                 %% cut-off values                                                   4           
%   'ushKSpaceCentreColumn',0,...                             %% unsigned short centre of echo                                    2
%   'ushDummy',0,...                                          %% unsigned short for swapping                                      2
%   'fReadOutOffcentre',0.0,...                               %% float          ReadOut offcenter value                           4
%   'ulTimeSinceLastRF',0,...                                 %% unsigned long  Sequence time stamp since last RF pulse           4
%   'ushKSpaceCentreLineNo',0,...                             %% unsigned short number of K-space centre line                     2
%   'ushKSpaceCentrePartitionNo',0,...                        %% unsigned short number of K-space centre partition                2
%   'aushIceProgramPara',zeros(1,MDH_NUMBEROFICEPROGRAMPARA),... %% unsigned short free parameter for IceProgram                  8  =88
%   'aushFreePara',zeros(1,MDH_FREEHDRPARA),...               %% unsigned short free parameter                          4 * 2 =   8   
%   'sSD',sSliceData,...                                      %% Slice Data                                                       28 =124
%   'ulChannelId',0,...                                       %% unsigned short	 channel Id must be the last parameter          2
%   'ushPTABPosNeg',0 ...                                     %% unsigned short    negative, absolute PTAB position in [0.1 mm]   2
% );                                                          %% (automatically set by PCI_TX firmware)
%                                                             %% total length: 32 * 32 Bit (128 Byte)                             128

%% MDH_H %%


%% read MDH;
% read MDH from current position of fid

% sMDH.ulDMALength                             = fread(fid, 1, 'uint32');      % 4
% sMDH.lMeasUID                                = fread(fid, 1,  'int32');      % 8
% sMDH.ulScanCounter                           = fread(fid, 1, 'uint32');      % 12
% sMDH.ulTimeStamp                             = fread(fid, 1, 'uint32');      % 16
% sMDH.ulPMUTimeStamp                          = fread(fid, 1, 'uint32');      % 20

fseek(fid,20,'cof');

for i = 1:MDH_NUMBEROFEVALINFOMASK       % 2
    sMDH.aulEvalInfoMask(i)                 = fread(fid, 1, 'uint32');      % 20 + 2 * 4 = 28
end
sMDH.ushSamplesInScan                        = fread(fid, 1, 'uint16');      % 30
sMDH.ushUsedChannels                         = fread(fid, 1, 'uint16');      % 32
sMDH.sLC.ushLine                             = fread(fid, 1, 'uint16');
sMDH.sLC.ushAcquisition                      = fread(fid, 1, 'uint16');
sMDH.sLC.ushSlice                            = fread(fid, 1, 'uint16');
sMDH.sLC.ushPartition                        = fread(fid, 1, 'uint16');
sMDH.sLC.ushEcho                             = fread(fid, 1, 'uint16');
sMDH.sLC.ushPhase                            = fread(fid, 1, 'uint16');
sMDH.sLC.ushRepetition                       = fread(fid, 1, 'uint16');
sMDH.sLC.ushSet                              = fread(fid, 1, 'uint16');
sMDH.sLC.ushSeg                              = fread(fid, 1, 'uint16');
sMDH.sLC.ushIda                              = fread(fid, 1, 'uint16');
sMDH.sLC.ushIdb                              = fread(fid, 1, 'uint16');
sMDH.sLC.ushIdc                              = fread(fid, 1, 'uint16');
sMDH.sLC.ushIdd                              = fread(fid, 1, 'uint16');
sMDH.sLC.ushIde                              = fread(fid, 1, 'uint16');      % 32 + 14 * 2 = 60

% sMDH.sCutOff.ushPre                          = fread(fid, 1, 'uint16');
% sMDH.sCutOff.ushPost                         = fread(fid, 1, 'uint16');      % 60 + 2 * 2 = 64
% sMDH.ushKSpaceCentreColumn                   = fread(fid, 1, 'uint16');
% sMDH.ushDummy                                = fread(fid, 1, 'uint16');      % 64 + 2 * 2 = 68
% sMDH.fReadOutOffcentre                       = fread(fid, 1, 'float');       % 68 + 4 = 72
% sMDH.ulTimeSinceLastRF                       = fread(fid, 1, 'uint32');
% sMDH.ushKSpaceCentreLineNo                   = fread(fid, 1, 'uint16');
% sMDH.ushKSpaceCentrePartitionNo              = fread(fid, 1, 'uint16');      % 72 + 4 + 2 + 2 = 80
% for i = 1:MDH_NUMBEROFICEPROGRAMPARA    % 4
%     sMDH.aushIceProgramPara(i)              = fread(fid, 1, 'uint16');      % 80 + 4 * 2 = 88
% end
% for i = 1:MDH_FREEHDRPARA  % 4
%     sMDH.aushFreePara(i)                       = fread(fid, 1, 'uint16');      % 88 + 4 * 2 = 96
% end
% sMDH.sSD.sVector.flSag                       = fread(fid, 1, 'float');
% sMDH.sSD.sVector.flCor                       = fread(fid, 1, 'float');
% sMDH.sSD.sVector.flTra                       = fread(fid, 1, 'float');       % 96 + 3 * 4 = 108
% for i = 1:4
%     sMDH.aflQuaternion(i)                   = fread(fid, 1, 'float');       % 108 + 4 * 4 = 124
% end

fseek(fid,64,'cof');

sMDH.ulChannelId                             = fread(fid, 1, 'uint16');      % 124 + 2 = 126

% sMDH.ushPTABPosNeg                           = -fread(fid, 1, 'uint16');      % 126 + 2 = 128 OK!

fseek(fid,2,'cof');

