function varargout = MIP2D(im2d,prj_dir)
% maximum intensity projection in 2D
% return complex line
%
% [xy_im,yz_im] = MIP(im2d,prj_dir)
% 
% prj_dir = empty or 0   -> all
% prj_dir =         1   -> y-dir projection
% prj_dir =         2   -> x-dir projection
% 
% coded at 2008.08.04
% by cefca


if nargin<2
    prj_dir = 0;
end

[y,x,z] = size(im2d);
mim2d = mag(im2d);

if ~(y>1 && x>1 && z==1)
    disp('2D data only...');
    varargout{1} = 0;
    return;
end


%% yz, x-dir projection

if prj_dir==0 || prj_dir==2

    y_im = zeros(y,1);

    for yi=1:y
        [v,n] = max(mim2d(yi,:));
        y_im(yi,1) = im2d(yi,n);
    end
end

%% xz, y-dir projection

if prj_dir==0 || prj_dir==1

    x_im = zeros(1,x);

    for xi=1:x
        [v,n] = max(mim2d(:,xi));
        x_im(1,xi) = im2d(n,xi);
    end
end

%% output

switch prj_dir
    case 0
        varargout{1} = x_im;
        varargout{2} = y_im;
    case 1
        varargout{1} = x_im;
    case 2
        varargout{1} = y_im;
end

