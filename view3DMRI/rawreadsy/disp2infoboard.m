function disp2infoboard(fig_handle,input_str)
% display string to info_board
% 
% fig_handle - info_board handle
% input_str - cell array of string or string (sprintf is ok)
% 
% Coded by Sang-Young Zho at 2009.12.07
%       Last modified at 2009.12.07


try
    
    fig_handle_listbox1 = findobj(fig_handle,'tag','listbox1');
    
    prev_text = get(fig_handle_listbox1,'string');
    
    cur_text = strvcat(prev_text,strvcat(input_str));
    
    set(fig_handle_listbox1,'string',cur_text);
    
    set(fig_handle_listbox1,'value',size(cur_text,1))

catch
%     disp('can not diplay to info_board.')
end