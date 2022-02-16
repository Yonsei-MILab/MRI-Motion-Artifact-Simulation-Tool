function pathANDfilename_cell = my_find_ooo_files(cur_pathname,file_filtername,pathANDfilename_cell)
%        pathANDfilename_cell = my_find_ooo_files(cur_pathname,'dat',[])
% at 2011.06.07

% % ---- for debugging
% % disp('----------------- enter func. my_findDATfiles() ------------------')
% % cur_pathname

cur_pathANDfilename_cell_size = size(pathANDfilename_cell,1);

dat_files = dir([cur_pathname,'/*.',file_filtername]);
for n=1:length(dat_files)
    pathANDfilename_cell{cur_pathANDfilename_cell_size+n,1} = [cur_pathname,'/'];
    pathANDfilename_cell{cur_pathANDfilename_cell_size+n,2} = dat_files(n).name;
end
    
dir_struct=dir(cur_pathname);

for n=3:length(dir_struct)
    if dir_struct(n).isdir
        pathANDfilename_cell = my_find_ooo_files([cur_pathname,'/',dir_struct(n).name],file_filtername,pathANDfilename_cell);
    end
end

