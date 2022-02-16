function enableAxesmove(hObject, handles)
% Enable axes move when axes has children
% Usage : enableAxesmove(handles.axes, handles)
% 
% 
% hObject    handle to current axes (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

hdl_child = get(hObject,'Children');
set(hdl_child,'ButtonDownFcn',{@axesChildmove,handles});



function axesChildmove(hObject, eventdata, handles)

% 
% 
% hObject    handle to current child object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hdl_parent_axes = ancestor(hObject,'axes');
axesmove(hdl_parent_axes, eventdata, handles)