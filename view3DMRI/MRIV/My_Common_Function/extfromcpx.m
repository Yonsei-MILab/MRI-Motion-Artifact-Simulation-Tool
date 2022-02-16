function data = extfromcpx(y_res,x_res,filename,index)

if(index<1)
    error('index is too small.');
end

%-----------------------------------------------------------
fnlen = length(filename);

if fnlen>5 && sum(filename(fnlen-4:fnlen) == '.data')/5
    fid=fopen(filename,'r','ieee-le');
else
%     fid=fopen(mat2str([filename '.data']),'r','ieee-le'); % ver 7.0
    fid=fopen([filename '.data'],'r','ieee-le');    % ver 2007a
end
%-----------------------------------------------------------

if fid==-1
    errordlg(['No [',filename,'.data','] file.'],'File error','modal');
    data=[];
    return;
end


fseek(fid,x_res*2*y_res*(index-1)*4,'bof');
d=fread(fid,x_res*2*y_res,'float32');

% for n=1:index
%     d=fread(fid,x_res*2*y_res,'float32');
% end

pre=reshape(d,2,[]);
cpx = pre(1,:)+j*pre(2,:);
algn_cpx=reshape(cpx,x_res,[]);

data = algn_cpx.';
% data = single(algn_cpx.');    % --->>> significantly reduce performance of
% algorithm  <i.e. shape of convex curve>

fclose(fid);