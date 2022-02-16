function exe_ehe(fn_dat,in_path)
% function using ehe
% 
% 2008.06.17
% Sang-Young Zho

if nargin<2
    in_path = '';
end

if isempty(strfind(fn_dat,'.dat'))
    fn_dat = [fn_dat,'.dat'];
end

% change Path separator to /
idx =strfind(in_path,'\');
in_path(idx)='/';


%% main

% -----------------------------------------
% Usage: ehe options: 
% 
% -i <input file>: Input meas dat file 
% -o <output dir>: Output directory. 
%                  if not given the directory from input file is taken. 
% -n: Do not overwrite existing files. Default is overwriting. 
% -t: Do not append suffix of filename to extracted files. 
% -----------------------------------------

%  Usage in Matlab:
% 
% unix(['ehe -i ./','meas_116740.dat'])
% 
% No output path given --> Take input path 
% Output path given: . 
% New file: ./Config_116740.evp 
% New file: ./Dicom_116740.evp 
% New file: ./meas_116740.evp 
% New file: ./meas_116740.asc 
% New file: ./Phoenix_116740.evp 
% New file: ./Spice_116740.evp 
% Buffers succesfully extracted. 
% -----------------------------------------


% ehe_src is sub-directory that has ehe
cd ehe_src

% path should bounded to double quote
unix(['ehe -t -i ','"',in_path,'"',fn_dat]);

cd ..

%% rename

fname = fn_dat(1:end-4);

movefile([in_path,'/','Config.evp'],[in_path,'/',fname,'_','Config.evp'],'f');
movefile([in_path,'/','meas.evp'],[in_path,'/',fname,'.evp'],'f');
movefile([in_path,'/','meas.asc'],[in_path,'/',fname,'.asc'],'f');
movefile([in_path,'/','Dicom.evp'],[in_path,'/',fname,'_','Dicom.evp'],'f');
movefile([in_path,'/','Phoenix.evp'],[in_path,'/',fname,'_','Phoenix.evp'],'f');
movefile([in_path,'/','Spice.evp'],[in_path,'/',fname,'_','Spice.evp'],'f');

disp('File name was changed.')
disp(' ')
