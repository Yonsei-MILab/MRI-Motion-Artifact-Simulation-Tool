function masked_flag = readEIM(aulEvalInfoMask,text_info)
% extract EvalInfoMask bit
% 
% use after readMDH()

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

%% get EvalInfoMask bit

if nargin<2
    disp(fliplr(dec2bin(aulEvalInfoMask(1))))
    disp(fliplr(dec2bin(aulEvalInfoMask(2))))
    return;
end

switch text_info
    case 'MDH_ACQEND'        % ((unsigned long)0);
        masked_flag = bitget(aulEvalInfoMask(1),1);
    case 'MDH_RTFEEDBACK'    % (1);
        masked_flag = bitget(aulEvalInfoMask(1),2);
    case 'MDH_HPFEEDBACK'    % (2);
        masked_flag = bitget(aulEvalInfoMask(1),3);
    case 'MDH_ONLINE'        % (3);
        masked_flag = bitget(aulEvalInfoMask(1),4);
    case 'MDH_OFFLINE'       % (4);
        masked_flag = bitget(aulEvalInfoMask(1),5);
    case 'MDH_SYNCDATA'      % (5);       // readout contains synchroneous data
        masked_flag = bitget(aulEvalInfoMask(1),6);
    case 'MDH_LASTSCANINCONCAT'  % (8);       // Flag for last scan in concatination
        masked_flag = bitget(aulEvalInfoMask(1),9);
    case 'MDH_RAWDATACORRECTION' % (10);      // Correct the rawadata with the rawdata correction factor
        masked_flag = bitget(aulEvalInfoMask(1),11);
    case 'MDH_LASTSCANINMEAS'    % (11);      // Flag for last scan in measurement
        masked_flag = bitget(aulEvalInfoMask(1),12);
    case 'MDH_SCANSCALEFACTOR'   % (12);      // Flag for scan specific additional scale factor
        masked_flag = bitget(aulEvalInfoMask(1),13);
    case 'MDH_2NDHADAMARPULSE'   % (13);      // 2nd RF exitation of HADAMAR
        masked_flag = bitget(aulEvalInfoMask(1),14);
    case 'MDH_REFPHASESTABSCAN'  % (14);      // reference phase stabilization scan
        masked_flag = bitget(aulEvalInfoMask(1),15);
    case 'MDH_PHASESTABSCAN'     % (15);      // phase stabilization scan
        masked_flag = bitget(aulEvalInfoMask(1),16);
    case 'MDH_D3FFT'             % (16);      // execute 3D FFT
        masked_flag = bitget(aulEvalInfoMask(1),17);
    case 'MDH_SIGNREV'           % (17);      // sign reversal
        masked_flag = bitget(aulEvalInfoMask(1),18);
    case 'MDH_PHASEFFT'          % (18);      // execute phase fft
        masked_flag = bitget(aulEvalInfoMask(1),19);
    case 'MDH_SWAPPED'           % (19);      // swapped phase/readout direction
        masked_flag = bitget(aulEvalInfoMask(1),20);
    case 'MDH_POSTSHAREDLINE'    % (20);      // shared line
        masked_flag = bitget(aulEvalInfoMask(1),21);
    case 'MDH_PHASCOR'           % (21);      // phase correction data
        masked_flag = bitget(aulEvalInfoMask(1),22);
    case 'MDH_PATREFSCAN'        % (22);      // additonal scan for PAT reference line/partition
        masked_flag = bitget(aulEvalInfoMask(1),23);
    case 'MDH_PATREFANDIMASCAN'  % (23);      // additonal scan for PAT reference line/partition that is also used as image scan
        masked_flag = bitget(aulEvalInfoMask(1),24);
    case 'MDH_REFLECT'           % (24);      // reflect line
        masked_flag = bitget(aulEvalInfoMask(1),25);
    case 'MDH_NOISEADJSCAN'      % (25);      // noise adjust scan --> Not used in NUM4
        masked_flag = bitget(aulEvalInfoMask(1),26);
    case 'MDH_SHARENOW'          % (26);      // all lines are acquired from the actual and previous e.g. phases
        masked_flag = bitget(aulEvalInfoMask(1),27);
    case 'MDH_LASTMEASUREDLINE'  % (27);      // indicates that the current line is the last measured line of all succeeding e.g. phases
        masked_flag = bitget(aulEvalInfoMask(1),28);
    case 'MDH_FIRSTSCANINSLICE'  % (28);      // indicates first scan in slice (needed for time stamps)
        masked_flag = bitget(aulEvalInfoMask(1),29);
    case 'MDH_LASTSCANINSLICE'   % (29);      // indicates  last scan in slice (needed for time stamps)
        masked_flag = bitget(aulEvalInfoMask(1),30);
    case 'MDH_TREFFECTIVEBEGIN'  % (30);      // indicates the begin time stamp for TReff (triggered measurement)
        masked_flag = bitget(aulEvalInfoMask(1),31);
    case 'MDH_TREFFECTIVEEND'    % (31);      // indicates the   end time stamp for TReff (triggered measurement)
        masked_flag = bitget(aulEvalInfoMask(1),32);
        
%         below can be not exact
    case 'MDH_FIRST_SCAN_IN_BLADE'   % (40);  // Marks the first line of a blade
        masked_flag = bitget(aulEvalInfoMask(2),40-31);
    case 'MDH_LAST_SCAN_IN_BLADE'    % (41);  // Marks the last line of a blade
        masked_flag = bitget(aulEvalInfoMask(2),41-31);
    case 'MDH_LAST_BLADE_IN_TR'      % (42);  // Set for all lines of the last BLADE in each TR interval
        masked_flag = bitget(aulEvalInfoMask(2),42-31);
    case 'MDH_RETRO_LASTPHASE'       % (45);  // Marks the last phase in a heartbeat
        masked_flag = bitget(aulEvalInfoMask(2),45-31);
    case 'MDH_RETRO_ENDOFMEAS'       % (46);  // Marks an ADC at the end of the measurement
        masked_flag = bitget(aulEvalInfoMask(2),46-31);
    case 'MDH_RETRO_REPEATTHISHEARTBEAT' % (47);  // Repeat the current heartbeat when this bit is found
        masked_flag = bitget(aulEvalInfoMask(2),47-31);
    case 'MDH_RETRO_REPEATPREVHEARTBEAT' % (48);  // Repeat the previous heartbeat when this bit is found
        masked_flag = bitget(aulEvalInfoMask(2),48-31);
    case 'MDH_RETRO_ABORTSCANNOW'        % (49);  // Just abort everything
        masked_flag = bitget(aulEvalInfoMask(2),49-31);
    case 'MDH_RETRO_LASTHEARTBEAT'       % (50);  // This adc is from the last heartbeat (a dummy)
        masked_flag = bitget(aulEvalInfoMask(2),50-31);
    case 'MDH_RETRO_DUMMYSCAN'           % (51);  // This adc is just a dummy scan, throw it away
        masked_flag = bitget(aulEvalInfoMask(2),51-31);
    case 'MDH_RETRO_ARRDETDISABLED'      % (52);  // Disable all arrhythmia detection when this bit is found
        masked_flag = bitget(aulEvalInfoMask(2),52-31);
    otherwise
        disp('Invalid Tag.')
        return;
end



