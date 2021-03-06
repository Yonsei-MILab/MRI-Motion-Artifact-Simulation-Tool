function data = readPHcpx(path,filename,nx,ny,nz,ns,is3D,index,offset)
% read Philips complex (cpx) data
% 
% Usage : data = readPHcpx(path,filename,nx,ny,nz,ns,is3D,index,offset)
%
% use variable only in 2D data -> ns,index
% use variable only in 3D data -> nz


fid=fopen([path filename '.data'],'r','ieee-le');

if fid==-1
    errordlg(['No [',filename,'.data','] file.'],'File error','modal');
    data=[];
    return;
end

if is3D

    data = zeros(ny,nx,nz);

    h = waitbar(0,'Reading data...');
    hdl_patch = findobj(h,'type','patch');
    set(hdl_patch,'FaceColor','b','EdgeColor','b');
    
    for n=1:nz
        %     A = fread(fid, count, precision)
        d=fread(fid,nx*2*ny,'float32');

        pre=reshape(d,2,[]);
        cpx = pre(1,:)+j*pre(2,:);
        algn_cpx=reshape(cpx,nx,[]);

        data(:,:,n) = algn_cpx.';
        
        waitbar(n/nz)
    end
    

    %---- below is same as fftshift 
    %       when offset is equal to half of nz
    temp = data(:,:,1:nz-offset);
    data(:,:,1:offset) = data(:,:,nz-offset+1:nz);
    data(:,:,offset+1:nz) = temp;
%     data = fftshift(data,3);
    %------------------------------------------------
    
    close(h)

else
    index = index+offset;
    if index>=ns
        index = index-ns;
    end
    
    fseek(fid,nx*2*ny*index*4,'bof');

    d=fread(fid,nx*2*ny,'float32');

    pre=reshape(d,2,[]);
    cpx = pre(1,:)+j*pre(2,:);
    algn_cpx=reshape(cpx,nx,[]);

    data = algn_cpx.';
    
end

fclose(fid);