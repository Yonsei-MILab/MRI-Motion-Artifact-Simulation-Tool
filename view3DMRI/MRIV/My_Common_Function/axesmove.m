function axesmove(hObject, eventdata, handles)
% Usage : type below a line of code at GUI initialize
% 
%           set(handles.axes,'ButtonDownFcn',{@axesmove,handles})
% 
% 
% hObject    handle to current axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parent_hdl = get(hObject,'parent');

%% set all Units to {Pixel}
set(parent_hdl,'units','pixel')
set(hObject,'units','pixel')

%% main

cur_parent_pos = get(parent_hdl,'Position');
curax_pos = get(hObject,'Position');

rect_pos(1:2) = cur_parent_pos(1:2)+curax_pos(1:2);
rect_pos(3:4) = curax_pos(3:4);

[next_pos] = dragrect(rect_pos);    % draw rect at figure


next_pos(1:2) = next_pos(1:2)-cur_parent_pos(1:2);

% ------- get max limit
limit_max = cur_parent_pos(3:4)-curax_pos(3:4);

% ---------- set limited position
next_pos(1) = max(0,next_pos(1));
next_pos(1) = min(limit_max(1),next_pos(1));
next_pos(2) = max(0,next_pos(2));
next_pos(2) = min(limit_max(2),next_pos(2));
% ------------------------------------------

set(hObject,'Position',next_pos);   % apply it


%% set all Units to {normalized} for resizing
set(parent_hdl,'units','normalized')
set(hObject,'units','normalized')
