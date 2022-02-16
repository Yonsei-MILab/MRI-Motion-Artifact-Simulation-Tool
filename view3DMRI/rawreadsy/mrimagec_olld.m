function varargout = mrimagec(varargin)
% varargout = mrimagec(im)
% 
% varargin{1} = data
% varargin{2} = clim
% varargin{3} = figure index
% return figure handle

im = varargin{1};

if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end

if nargin>2
    h=figure(varargin{3}); % make new figure w/ specified index
else
    h=figure; % make new figure
end

menu_hndl = uimenu(h, 'Label', 'Edit');
uimenu(menu_hndl, 'Label', 'Copy Figure (bmp)', 'Callback', {@localprint});
uimenu(menu_hndl, 'Label', 'Copy Figure (meta)', 'Callback', {@localprint_meta});

if nargin>1
    clim = varargin{2};
    if isempty(clim)
        imagesc(mim);
    else
        if clim(2)<=clim(1)
            clim(2) = clim(1)+0.001;    % make max to larger
%             clim(1) = -2*mag(clim(2));  % make min to smaller
        end
        imagesc(mim,clim);
    end
else
    imagesc(mim);
end


my_mrinit;

if nargout>0
    varargout{1} = h;
end

function localprint(gcbo, eventdata)
try
    print(gcf, '-dbitmap');
%     print(gcf, '-dmeta');
catch
%     print(gcf, '-dbitmap');
end

function localprint_meta(gcbo, eventdata)
try
%     print(gcf, '-dbitmap');
    print(gcf, '-dmeta');
catch
    print(gcf, '-dbitmap');
end

function my_mrinit

% initializations for MR image displays.

% Matlab assumes pseudocolor image, set the colormap to grayscale
% colormap('gray');

% you want to display the image with a square aspect ratio.
%axis('square');

%axis image is the same as axis equal except that the plot box fits tightly
%around the data.
axis('image');

% also, you probably don't care about the axes
axis('off');

% the default colormap has 64 gray levels. The image(im) function uses the
% value of im at each pixel as an index into the colormap. hence, you want
% im to be real valued, and scaled from 1 to 64
% imx = max(max(abs(im)));
% image(abs(im)*64/imx);

