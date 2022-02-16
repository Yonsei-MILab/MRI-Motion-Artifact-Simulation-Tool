function header_extracter(filename,pathname)
% function for extract 6 header which is done ehe.exe
% 
% coded by Sang-Young Zho
%     at 2009.11.27
% last modified at 2009.12.08
% 
% increase MAC compatibility
% last modified at 2010.06.16
% 
% make folder for .evp header
% last modified at 2010.10.04


fid = fopen([pathname filename '.dat'],'r');
% read global header size in first 4 bytes
glob_hdr_size = fread(fid,1,'int32');
% read all text header
asc_all_header = fread(fid, glob_hdr_size-4, 'char');
fclose(fid);
asc_all_header = char(asc_all_header');

% remove following because of strfind error in MAC : 2010.06.16
% 
% % ------------ replace [newline (10)] to [carrige return (13),newline (10)]
% % ...
% % ...
% % ...
% % --------------------------------------


% ---- header info. should be appeared following order
% ---- if not, algorithm will fail
text_Config = 'Config';
text_Dicom = 'Dicom';
text_Meas = 'Meas';
text_MeasYaps = 'MeasYaps';
text_Phoenix = 'Phoenix';
text_Spice = 'Spice';

text_asc = '### ASCCONV BEGIN ###';
text_Xprotocol = '<XProtocol>';

ind_text_Config = strfind(asc_all_header,text_Config);
ind_text_Dicom = strfind(asc_all_header,text_Dicom);
ind_text_Meas = strfind(asc_all_header,text_Meas);
ind_text_MeasYaps = strfind(asc_all_header,text_MeasYaps);
ind_text_Phoenix = strfind(asc_all_header,text_Phoenix);
ind_text_Spice = strfind(asc_all_header,text_Spice);

ind_text_asc = strfind(asc_all_header,text_asc);
ind_text_Xprotocol = strfind(asc_all_header,text_Xprotocol);

% -------- find real index of Config
inc_id = 0;
for k=1:length(ind_text_Xprotocol)
    isReal_ind_text_Config = ind_text_Config+length(text_Config)+4 == ind_text_Xprotocol(k);
    % check after 5 char
    if sum(isReal_ind_text_Config)==0
        isReal_ind_text_Config = ind_text_Config+length(text_Config)+5 == ind_text_Xprotocol(k);
    end
    if ~isempty(ind_text_Config(isReal_ind_text_Config))
        inc_id = inc_id+1;
        selected_ind_text_Config(inc_id) = ind_text_Config(isReal_ind_text_Config);
        ind_Xprotocol_Config(inc_id) = ind_text_Xprotocol(k);
    end
end

% -------- find real index of Dicom
inc_id = 0;
for k=1:length(ind_text_Xprotocol)
    isReal_ind_text_Dicom = ind_text_Dicom+length(text_Dicom)+4 == ind_text_Xprotocol(k);
    % check after 5 char
    if sum(isReal_ind_text_Dicom)==0
        isReal_ind_text_Dicom = ind_text_Dicom+length(text_Dicom)+5 == ind_text_Xprotocol(k);
    end
    if ~isempty(ind_text_Dicom(isReal_ind_text_Dicom))
        inc_id = inc_id+1;
        selected_ind_text_Dicom(inc_id) = ind_text_Dicom(isReal_ind_text_Dicom);
        ind_Xprotocol_Dicom(inc_id) = ind_text_Xprotocol(k);
    end
end

% -------- find real index of Meas
inc_id = 0;
for k=1:length(ind_text_Xprotocol)
    isReal_ind_text_Meas = ind_text_Meas+length(text_Meas)+4 == ind_text_Xprotocol(k);
    % check after 5 char
    if sum(isReal_ind_text_Meas)==0
        isReal_ind_text_Meas = ind_text_Meas+length(text_Meas)+5 == ind_text_Xprotocol(k);
    end
    if ~isempty(ind_text_Meas(isReal_ind_text_Meas))
        inc_id = inc_id+1;
        selected_ind_text_Meas(inc_id) = ind_text_Meas(isReal_ind_text_Meas);
        ind_Xprotocol_Meas(inc_id) = ind_text_Xprotocol(k);
    end
end

% -------- find real index of MeasYaps
inc_id = 0;
for k=1:length(ind_text_asc)
    isReal_ind_text_MeasYaps = ind_text_MeasYaps+length(text_MeasYaps)+4 == ind_text_asc(k);
    % check after 5 char
    if sum(isReal_ind_text_MeasYaps)==0
        isReal_ind_text_MeasYaps = ind_text_MeasYaps+length(text_MeasYaps)+5 == ind_text_asc(k);
    end
    if ~isempty(ind_text_MeasYaps(isReal_ind_text_MeasYaps))
        inc_id = inc_id+1;
        selected_ind_text_MeasYaps(inc_id) = ind_text_MeasYaps(isReal_ind_text_MeasYaps);
        ind_asc_MeasYaps(inc_id) = ind_text_asc(k);
    end
end

% -------- find real index of Phoenix
inc_id = 0;
for k=1:length(ind_text_Xprotocol)
    isReal_ind_text_Phoenix = ind_text_Phoenix+length(text_Phoenix)+4 == ind_text_Xprotocol(k);
    % check after 5 char
    if sum(isReal_ind_text_Phoenix)==0
        isReal_ind_text_Phoenix = ind_text_Phoenix+length(text_Phoenix)+5 == ind_text_Xprotocol(k);
    end
    if ~isempty(ind_text_Phoenix(isReal_ind_text_Phoenix))
        inc_id = inc_id+1;
        selected_ind_text_Phoenix(inc_id) = ind_text_Phoenix(isReal_ind_text_Phoenix);
        ind_Xprotocol_Phoenix(inc_id) = ind_text_Xprotocol(k);
    end
end

% -------- find real index of Spice
inc_id = 0;
for k=1:length(ind_text_Xprotocol)
    isReal_ind_text_Spice = ind_text_Spice+length(text_Spice)+4 == ind_text_Xprotocol(k);
    % check after 5 char
    if sum(isReal_ind_text_Spice)==0
        isReal_ind_text_Spice = ind_text_Spice+length(text_Spice)+5 == ind_text_Xprotocol(k);
    end
    if ~isempty(ind_text_Spice(isReal_ind_text_Spice))
        inc_id = inc_id+1;
        selected_ind_text_Spice(inc_id) = ind_text_Spice(isReal_ind_text_Spice);
        ind_Xprotocol_Spice(inc_id) = ind_text_Xprotocol(k);
    end
end

%------ seperate headers
header_Config = asc_all_header(ind_Xprotocol_Config(1):selected_ind_text_Dicom(1)-1);
header_Dicom = asc_all_header(ind_Xprotocol_Dicom(1):selected_ind_text_Meas(1)-1);
header_Meas = asc_all_header(ind_Xprotocol_Meas(1):selected_ind_text_MeasYaps(1)-1);
header_MeasYaps = asc_all_header(ind_asc_MeasYaps(1):selected_ind_text_Phoenix(1)-1);
header_Phoenix = asc_all_header(ind_Xprotocol_Phoenix(1):selected_ind_text_Spice(1)-1);
header_Spice = asc_all_header(ind_Xprotocol_Spice(1):end); % global header size..

%----- replace to win form : 2010.06.16
header_Config = replaceNewline2winForm(header_Config);
header_Dicom = replaceNewline2winForm(header_Dicom);
header_Meas = replaceNewline2winForm(header_Meas);
header_MeasYaps = replaceNewline2winForm(header_MeasYaps);
header_Phoenix = replaceNewline2winForm(header_Phoenix);
header_Spice = replaceNewline2winForm(header_Spice);


%--------- save header text to files
% see the fopen help - Binary and Text Modes - not work on MAC
% fid = fopen([pathname filename '.asc'],'wt');
fid = fopen([pathname filename '.asc'],'w');
fwrite(fid, header_MeasYaps, 'char');
fclose(fid);

% ---- make directory for .evp
if ~isdir([pathname,'evp_header'])
    mkdir([pathname,'evp_header'])
end

% see the fopen help - Binary and Text Modes - not work on MAC
fid = fopen([pathname,'evp_header/', filename '_Config.evp'],'w');
fwrite(fid, header_Config, 'char');
fclose(fid);
% see the fopen help - Binary and Text Modes - not work on MAC
fid = fopen([pathname,'evp_header/', filename '_Dicom.evp'],'w');
fwrite(fid, header_Dicom, 'char');
fclose(fid);
% see the fopen help - Binary and Text Modes - not work on MAC
fid = fopen([pathname,'evp_header/', filename '.evp'],'w');
fwrite(fid, header_Meas, 'char');
fclose(fid);
% see the fopen help - Binary and Text Modes - not work on MAC
fid = fopen([pathname,'evp_header/', filename '_Phoenix.evp'],'w');
fwrite(fid, header_Phoenix, 'char');
fclose(fid);
% see the fopen help - Binary and Text Modes - not work on MAC
fid = fopen([pathname,'evp_header/', filename '_Spice.evp'],'w');
fwrite(fid, header_Spice, 'char');
fclose(fid);



function out_text = replaceNewline2winForm(in_text)
% ------------ replace [newline (10)] to [carrige return (13),newline (10)]
% 
% converte to function at 2010.06.16


ind_newline = strfind(in_text,char(10));
size_ind_newline = length(ind_newline);

out_text = zeros(1,length(in_text)+size_ind_newline);
clear ind_newline
out_text = char(out_text);

kk=1;
for k=1:length(in_text)
    if in_text(k) == char(10)
        out_text(kk:kk+1) = [char(13),char(10)];
        kk = kk+1;
    else
        out_text(kk) = in_text(k);
    end
    kk = kk+1;
end

clear in_text
% --------------------------------------
