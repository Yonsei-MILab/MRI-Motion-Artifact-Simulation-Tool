function out_text = findAsc(asc,text,sep_text)
% find information in ASCII file
%
% asc -> get whole ASCII text
% text -> information text
% sep_text -> seperation text between key and value
% 
% Note for out_text :
% if no text is found, out_text will be empty cell array, i.e., 0x1 {}
%     str2double({}) -> []
%     str2double([]) -> NaN
% if you use out_text to character, convert it to character to avoid error
%     char(out_text)
% 
% last modified at 2008.07.26


%% init
sep_indic = strfind(asc,sep_text)' + length(sep_text);

nl_text = char(10);
nl_indic = strfind(asc,nl_text)'-2; % why -2 works correctly??
% becuase carrige return (13) following newline (10)

%% find

k = strfind(asc,text) + length(text);
len_k = length(k);

if len_k==1
    next_sep = sep_indic(sep_indic>k);
    next_nl = nl_indic(nl_indic>k);

    start_index = next_sep(1);
    end_index = next_nl(1);

    out_text = asc(start_index:end_index);
else
    out_text = cell(len_k,1);

    for n=1:len_k
        next_sep = sep_indic(sep_indic>k(n));
        next_nl = nl_indic(nl_indic>k(n));

        start_index = next_sep(1);
        end_index = next_nl(1);

        out_text{n} = asc(start_index:end_index);

    end
end
