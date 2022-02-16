function readMDHmat(fid)
% extract from ReadSiemensMeas
% by Maolin Qiu YALE 11-26-2007 (maolin.qiu(at)yale(dot)edu)
% This is exactly same as MDH.h in IDEA
%
% call initMDH() before this function

global mMDH;

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

% MDH_NUMBEROFEVALINFOMASK   = 2;
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

%% MDH_H index definition %%

% MDH_ulDMALength                             = 1; % fread(fid, 1, 'uint32');      % 4
% MDH_lMeasUID                                = 2; % fread(fid, 1,  'int32');      % 8
% MDH_ulScanCounter                           = 3; % fread(fid, 1, 'uint32');      % 12
% MDH_ulTimeStamp                             = 4; % fread(fid, 1, 'uint32');      % 16
% MDH_ulPMUTimeStamp                          = 5; % fread(fid, 1, 'uint32');      % 20
% 
% MDH_aulEvalInfoMask1                 = 6; % fread(fid, 1, 'uint32');      % 20 + 2 * 4 = 28
% MDH_aulEvalInfoMask2                 = 7; % fread(fid, 1, 'uint32');
% 
% MDH_ushSamplesInScan                        = 8; % fread(fid, 1, 'uint16');      % 30
% MDH_ushUsedChannels                         = 9; % fread(fid, 1, 'uint16');      % 32
% MDH_sLC_ushLine                             = 10; % fread(fid, 1, 'uint16');
% MDH_sLC_ushAcquisition                      = 11; % fread(fid, 1, 'uint16');
% MDH_sLC_ushSlice                            = 12; % fread(fid, 1, 'uint16');
% MDH_sLC_ushPartition                        = 13; % fread(fid, 1, 'uint16');
% MDH_sLC_ushEcho                             = 14; % fread(fid, 1, 'uint16');
% MDH_sLC_ushPhase                            = 15; % fread(fid, 1, 'uint16');
% MDH_sLC_ushRepetition                       = 16; % fread(fid, 1, 'uint16');
% MDH_sLC_ushSet                              = 17; % fread(fid, 1, 'uint16');
% MDH_sLC_ushSeg                              = 18; % fread(fid, 1, 'uint16');
% MDH_sLC_ushIda                              = 19; % fread(fid, 1, 'uint16');
% MDH_sLC_ushIdb                              = 20; % fread(fid, 1, 'uint16');
% MDH_sLC_ushIdc                              = 21; % fread(fid, 1, 'uint16');
% MDH_sLC_ushIdd                              = 22; % fread(fid, 1, 'uint16');
% MDH_sLC_ushIde                              = 23; % fread(fid, 1, 'uint16');      % 32 + 14 * 2 = 60
% 
% MDH_sCutOff_ushPre                          = 24; % fread(fid, 1, 'uint16');
% MDH_sCutOff_ushPost                         = 25; % fread(fid, 1, 'uint16');      % 60 + 2 * 2 = 64
% MDH_ushKSpaceCentreColumn                   = 26; % fread(fid, 1, 'uint16');
% MDH_ushDummy                                = 27; % fread(fid, 1, 'uint16');      % 64 + 2 * 2 = 68
% MDH_fReadOutOffcentre                       = 28; % fread(fid, 1, 'float');       % 68 + 4 = 72
% MDH_ulTimeSinceLastRF                       = 29; % fread(fid, 1, 'uint32');
% MDH_ushKSpaceCentreLineNo                   = 30; % fread(fid, 1, 'uint16');
% MDH_ushKSpaceCentrePartitionNo              = 31; % fread(fid, 1, 'uint16');      % 72 + 4 + 2 + 2 = 80
% 
% MDH_aushIceProgramPara1              = 32; % fread(fid, 1, 'uint16');      % 80 + 4 * 2 = 88
% MDH_aushIceProgramPara2              = 33; % fread(fid, 1, 'uint16');
% MDH_aushIceProgramPara3              = 34; % fread(fid, 1, 'uint16');
% MDH_aushIceProgramPara4              = 35; % fread(fid, 1, 'uint16');
% 
% MDH_aushFreePara1                       = 36; % fread(fid, 1, 'uint16');      % 88 + 4 * 2 = 96
% MDH_aushFreePara2                       = 37; % fread(fid, 1, 'uint16');
% MDH_aushFreePara3                       = 38; % fread(fid, 1, 'uint16');
% MDH_aushFreePara4                       = 39; % fread(fid, 1, 'uint16');
% 
% MDH_sSD_sVector_flSag                       = 40; % fread(fid, 1, 'float');
% MDH_sSD_sVector_flCor                       = 41; % fread(fid, 1, 'float');
% MDH_sSD_sVector_flTra                       = 42; % fread(fid, 1, 'float');       % 96 + 3 * 4 = 108
% 
% MDH_aflQuaternion1                   = 43; % fread(fid, 1, 'float');       % 108 + 4 * 4 = 124
% MDH_aflQuaternion2                   = 44; % fread(fid, 1, 'float');
% MDH_aflQuaternion3                   = 45; % fread(fid, 1, 'float');
% MDH_aflQuaternion4                   = 46; % fread(fid, 1, 'float');
% 
% MDH_ulChannelId                             = 47; % fread(fid, 1, 'uint16');      % 124 + 2 = 126
% MDH_ushPTABPosNeg                           = 48; % -fread(fid, 1, 'uint16');      % 126 + 2 = 128 OK!

%% read MDH;
% read MDH from current position of fid

mMDH(1:7)                             = fread(fid, 7, 'uint32');      % 4
% mMDH(2)                                = fread(fid, 1,  'int32');      % 8
% mMDH(3)                           = fread(fid, 1, 'uint32');      % 12
% mMDH(4)                             = fread(fid, 1, 'uint32');      % 16
% mMDH(5)                          = fread(fid, 1, 'uint32');      % 20
% 
% mMDH(6)                 = fread(fid, 1, 'uint32');      % 20 + 2 * 4 = 28
% mMDH(7)                 = fread(fid, 1, 'uint32');

mMDH(8:27)                        = fread(fid, 20, 'uint16');      % 30
% mMDH(9)                         = fread(fid, 1, 'uint16');      % 32
% mMDH(10)                             = fread(fid, 1, 'uint16');
% mMDH(11)                      = fread(fid, 1, 'uint16');
% mMDH(12)                            = fread(fid, 1, 'uint16');
% mMDH(13)                        = fread(fid, 1, 'uint16');
% mMDH(14)                             = fread(fid, 1, 'uint16');
% mMDH(15)                            = fread(fid, 1, 'uint16');
% mMDH(16)                       = fread(fid, 1, 'uint16');
% mMDH(17)                              = fread(fid, 1, 'uint16');
% mMDH(18)                              = fread(fid, 1, 'uint16');
% mMDH(19)                              = fread(fid, 1, 'uint16');
% mMDH(20)                              = fread(fid, 1, 'uint16');
% mMDH(21)                              = fread(fid, 1, 'uint16');
% mMDH(22)                              = fread(fid, 1, 'uint16');
% mMDH(23)                              = fread(fid, 1, 'uint16');      % 32 + 14 * 2 = 60
% 
% mMDH(24)                          = fread(fid, 1, 'uint16');
% mMDH(25)                         = fread(fid, 1, 'uint16');      % 60 + 2 * 2 = 64
% mMDH(26)                   = fread(fid, 1, 'uint16');
% mMDH(27)                                = fread(fid, 1, 'uint16');      % 64 + 2 * 2 = 68

mMDH(28)                       = fread(fid, 1, 'float');       % 68 + 4 = 72
mMDH(29)                       = fread(fid, 1, 'uint32');

mMDH(30:39)                   = fread(fid, 10, 'uint16');
% mMDH(31)              = fread(fid, 1, 'uint16');      % 72 + 4 + 2 + 2 = 80
% 
% mMDH(32)              = fread(fid, 1, 'uint16');      % 80 + 4 * 2 = 88
% mMDH(33)              = fread(fid, 1, 'uint16');
% mMDH(34)              = fread(fid, 1, 'uint16');
% mMDH(35)              = fread(fid, 1, 'uint16');
% 
% 
% mMDH(36)                       = fread(fid, 1, 'uint16');      % 88 + 4 * 2 = 96
% mMDH(37)                       = fread(fid, 1, 'uint16');
% mMDH(38)                       = fread(fid, 1, 'uint16');
% mMDH(39)                       = fread(fid, 1, 'uint16');

mMDH(40:46)                       = fread(fid, 7, 'float');
% mMDH(41)                       = fread(fid, 1, 'float');
% mMDH(42)                       = fread(fid, 1, 'float');       % 96 + 3 * 4 = 108
% 
% mMDH(43)                   = fread(fid, 1, 'float');       % 108 + 4 * 4 = 124
% mMDH(44)                   = fread(fid, 1, 'float');
% mMDH(45)                   = fread(fid, 1, 'float');
% mMDH(46)                   = fread(fid, 1, 'float');

mMDH(47:48)                             = fread(fid, 2, 'uint16');      % 124 + 2 = 126
% mMDH(48)                           = -fread(fid, 1, 'uint16');      % 126 + 2 = 128 OK!
mMDH(48) = -mMDH(48);

