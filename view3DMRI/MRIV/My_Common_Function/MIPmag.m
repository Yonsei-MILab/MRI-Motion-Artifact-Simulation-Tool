function varargout = MIPmag(im3d,prj_dir)
% maximum intensity projection
% return magnitude image
%
% [xy_im,yz_im,xz_im] = MIP(im3d,prj_dir)
% 
% prj_dir = empty or 0   -> all
% prj_dir =         1   -> y-dir projection
% prj_dir =         2   -> x-dir projection
% prj_dir =         3   -> z-dir projection
% 
% rather optimized... 2008.04.02


if nargin<2
    prj_dir = 0;
end

[y,x,z] = size(im3d);
mim3d = mag(im3d);

if ~(y>1 && x>1 && z>1)
    disp('3D data only...');
end

%% xy, z-dir projection

if prj_dir==0 || prj_dir==3

    xy_im = zeros(y,x);

    for yi=1:y
        for xi=1:x
            xy_im(yi,xi) = max(mim3d(yi,xi,:));
        end
    end
end

%% yz, x-dir projection

if prj_dir==0 || prj_dir==2

    yz_im = zeros(y,z);

    for yi=1:y
        for zi=1:z
            yz_im(yi,zi) = max(mim3d(yi,:,zi));
        end
    end
end

%% xz, y-dir projection

if prj_dir==0 || prj_dir==1

    xz_im = zeros(z,x);

    for zi=1:z
        for xi=1:x
            xz_im(zi,xi) = max(mim3d(:,xi,zi));
        end
    end
end

%% output

switch prj_dir
    case 0
        varargout{1} = xy_im;
        varargout{2} = yz_im;
        varargout{3} = xz_im;
    case 1
        varargout{1} = xz_im;
    case 2
        varargout{1} = yz_im;
    case 3
        varargout{1} = xy_im;
end

