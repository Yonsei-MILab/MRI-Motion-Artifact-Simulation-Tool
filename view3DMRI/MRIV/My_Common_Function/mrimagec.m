function varargout = mrimagec(varargin)
% varargout = mrimagec(im)
% 
% varargin{1} = data
% varargin{2} = clim
% varargin{3} = figure index
% return figure handle
% 
% last modified 2009.04.10
% coded by cefca (Sang-Young Zho)



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
uimenu(menu_hndl, 'Label', 'Colormap', 'Callback', {@localCmap});
clrmenu     % Add colormap menu to figure window - see help

% below code is learned from code <clrmenu>
miniCmap_menuhndl = uimenu(h, 'Label', 'mini Colormap');
uimenu(miniCmap_menuhndl,'Label','Gray 64 (default gray)', 'Callback','colormap(gray(64))');
uimenu(miniCmap_menuhndl,'Label','Gray 256', 'Callback','colormap(gray(256))');
uimenu(miniCmap_menuhndl,'Label','Jet (default color)', 'Callback','colormap jet');
uimenu(miniCmap_menuhndl,'Label','Brighten','Separator','on', 'Callback','brighten(.25)');
uimenu(miniCmap_menuhndl,'Label','Darken', 'Callback','brighten(-.25)');


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

%------ init image
axis('image');
colorbar
colormap hsv
%----------------------

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

function localCmap(gcbo, eventdata)
% just start colormap editor ¤»¤»
colormapeditor
