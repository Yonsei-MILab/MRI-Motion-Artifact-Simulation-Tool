function varargout = mrimage(varargin)
% varargout = mrimage(im)
% 
% varargin{1} = data
% varargin{2} = clim
% varargin{3} = figure index
% return figure handle
% 
% coded by cefca (Sang-Young Zho)
% 
% 
% last modified 2009.04.10
% 
% ----- intersting menu items are added
% last modified 2010.04.18
% 
% ----- global Clim & maintain Title
% ----- maintain data aspect ratio
% last modified 2010.04.19
% 
% ----- handle when no argin
% last modified 2010.04.20
% 
% ----- can export gca data
% last modified at 2010.09.14
% 
% fix bugs on empty im
% ----- last modified at 2010.12.04
% 
% modify clim to remove hyper outlier
% - with 2/3 FOV of center, set clim max to 1.5*mean
% ----- last modified at 2011.04.01
% 
% add centered FFT function
% ----- last modified at 2011.04.20
% 
% modify auto clim mode action
% ----- last modified at 2011.04.22


if nargin==0
    im=[];
else
    im = varargin{1};
end

% added at 2009.10.23
% Remove singleton dimensions
im = squeeze(im);


if nargin>2
    h=figure(varargin{3}); % make new figure w/ specified index
else
    h=figure; % make new figure
end

clim = [];
if nargin>1
    clim = varargin{2};
    if ~isempty(clim)
        if clim(2)<=clim(1)
            clim(2) = clim(1)+0.001;    % make max to larger
%             clim(1) = -2*mag(clim(2));  % make min to smaller
        end
        
    end
end

clrmenu     % Add colormap menu to figure window - see help

menu_hndl = uimenu(h, 'Label', 'Edit');
uimenu(menu_hndl, 'Label', 'Copy Figure (bmp)', 'Callback', {@localprint});
uimenu(menu_hndl, 'Label', 'Copy Figure (meta)', 'Callback', {@localprint_meta});
uimenu(menu_hndl, 'Label', 'Colormap', 'Callback', {@localCmap});
% added at 2011.04.01
uimenu(menu_hndl, 'Label', 'Auto Clim Max','Checked', 'on', 'Callback', {@localAutoClim,menu_hndl,clim});
% added at 2009.10.23
% uimenu(menu_hndl, 'Label', 'Axis On','Separator','on', 'Callback', 'axis(''on'')');
% uimenu(menu_hndl, 'Label', 'Axis Off', 'Callback', 'axis(''off'')');
% modified at 2010.04.18
uimenu(menu_hndl, 'Label', 'Axis On','Separator','on', 'Callback', {@local_axisOn});
% added at 2010.04.18
uimenu(menu_hndl, 'Label', 'Phase','Separator','on', 'Callback', {@plot_phase,menu_hndl,clim});
% added at 2011.04.20
uimenu(menu_hndl, 'Label', 'FFT', 'Callback', {@plot_fft,menu_hndl,clim});
% added at 2011.04.22
uimenu(menu_hndl, 'Label', 'iFFT', 'Callback', {@plot_ifft,menu_hndl,clim});
% added at 2011.04.22
uimenu(menu_hndl, 'Label', 'flip LR','Separator','on', 'Callback', {@plot_flipLR,menu_hndl,clim});
uimenu(menu_hndl, 'Label', 'flip UD', 'Callback', {@plot_flipUD,menu_hndl,clim});
uimenu(menu_hndl, 'Label', 'complex conj (.'')', 'Callback', {@plot_compconj,menu_hndl,clim});
% added at 2010.04.18
uimenu(menu_hndl, 'Label', 'Export to Base Workspace','Separator','on', 'Callback', {@local_export2BS,menu_hndl});

% below code is learned from code <clrmenu>
miniCmap_menuhndl = uimenu(h, 'Label', 'mini Colormap');
uimenu(miniCmap_menuhndl,'Label','Gray 64 (default gray)', 'Callback','colormap(gray(64))');
uimenu(miniCmap_menuhndl,'Label','Gray 256', 'Callback','colormap(gray(256))');
uimenu(miniCmap_menuhndl,'Label','Jet (default color)', 'Callback','colormap jet');
uimenu(miniCmap_menuhndl,'Label','Brighten','Separator','on', 'Callback','brighten(.25)');
uimenu(miniCmap_menuhndl,'Label','Darken', 'Callback','brighten(-.25)');
% added at 2010.04.18
uimenu(miniCmap_menuhndl,'Label','Save & Remove Clim','Separator','on', 'Callback',{@remove_clim,menu_hndl});
uimenu(miniCmap_menuhndl,'Label','Restore Clim', 'Callback',{@restore_clim,miniCmap_menuhndl,menu_hndl});
% added at 2010.04.19
uimenu(miniCmap_menuhndl,'Label','Save & Remove Global Clim','Separator','on','Callback',{@remove_global_clim,menu_hndl});
uimenu(miniCmap_menuhndl,'Label','Restore Global Clim', 'Callback',{@restore_global_clim,menu_hndl});

set(menu_hndl,'userdata',im)
if ~isempty(clim)
    set(findobj(menu_hndl,'Label', 'Auto Clim Max'),'Checked','off')
end
plot_image(menu_hndl,clim);
colormap('gray');

% mrinit -> removed at 2010.04.18


if nargout>0
    varargout{1} = h;
end

function plot_image(menu_hndl,clim)
% added at 2010.04.18

im = get(menu_hndl,'userdata');
% added at 2010.12.04
if isempty(im)
    im = get(findobj(gca,'type','image'),'cdata');
    set(menu_hndl,'userdata',im)
end

% added at 2010.04.25
im = double(im);

% added at 2011.04.20
if strcmp(get(findobj(menu_hndl,'Label', 'FFT'),'Checked'),'on')
    im = fft3c(im);
end
% added at 2011.04.22
if strcmp(get(findobj(menu_hndl,'Label', 'iFFT'),'Checked'),'on')
    im = ifft3c(im);
end

if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end

% get current title - added at 2010.04.19
current_title.String = get(get(gca,'title'),'String');
current_title.Interpreter = get(get(gca,'title'),'Interpreter');
current_title.FontSize = get(get(gca,'title'),'FontSize');
current_title.FontName = get(get(gca,'title'),'FontName');
current_title.FontAngle = get(get(gca,'title'),'FontAngle');
current_title.FontWeight = get(get(gca,'title'),'FontWeight');
current_title.Color = get(get(gca,'title'),'Color');

% get data aspect ratio - added at 2010.04.19
current_daspect = daspect;

if strcmp(get(findobj(menu_hndl,'Label', 'Phase'),'Checked'),'off')
    imagesc(mim);
    
    if ~isempty(mim) && strcmp(get(findobj(menu_hndl,'Label', 'Auto Clim Max'),'Checked'),'on')
        % --------------- add at 2011.04.01
        % --------------- to remove hyper outlier
        % --- with 2/3 FOV of center, set clim max to 1.5*mean
        my_fov = mag(im(round(end*1/6):round(end*5/6),round(end*1/6):round(end*5/6)));
        fov_mean = mean(my_fov(:));
        max_clim = fov_mean*1.5;
        cur_clim = get(gca,'clim'); % gca = get(h,'CurrentAxes')
        if cur_clim(1)>=max_clim
            set(gca,'CLimMode','auto')
        else
            set(gca,'clim',[cur_clim(1),max_clim])
        end
        % ----------------------------
    else
        if isempty(clim)
            % -- added at 2010.12.03
            set(gca,'CLimMode','auto')
        else
            imagesc(mim,clim);
        end
    end
    
else
    imagesc(angle(im));
    % -- added at 2010.12.03
    set(gca,'CLimMode','auto')
end

if ~isempty(im)
    axis('image');
end

if strcmp(get(findobj(menu_hndl,'Label', 'Axis On'),'Checked'),'on')
    axis('on');
else
    axis('off');
end

% set title - added at 2010.04.19
set(get(gca,'title'),'String',current_title.String,'Interpreter',current_title.Interpreter,...
    'FontSize',current_title.FontSize,'FontName',current_title.FontName,...
    'FontAngle',current_title.FontAngle,'FontWeight',current_title.FontWeight,...
    'Color',current_title.Color);

% set data aspect ratio - added at 2010.04.19
daspect(current_daspect)


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

function plot_phase(gcbo, eventdata,menu_hndl,clim)
% added at 2010.04.18

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
end

plot_image(menu_hndl,clim)

function plot_fft(gcbo, eventdata,menu_hndl,clim)
% added at 2011.04.20

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
    set(findobj(menu_hndl,'Label', 'iFFT'),'Checked','off')
end

plot_image(menu_hndl,clim)

function plot_ifft(gcbo, eventdata,menu_hndl,clim)
% added at 2011.04.22

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
    set(findobj(menu_hndl,'Label', 'FFT'),'Checked','off')
end

plot_image(menu_hndl,clim)


function plot_flipLR(gcbo, eventdata,menu_hndl,clim)
% added at 2011.04.22

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
end

im = get(menu_hndl,'userdata');
set(menu_hndl,'userdata',fliplr(im))
plot_image(menu_hndl,clim)

function plot_flipUD(gcbo, eventdata,menu_hndl,clim)
% added at 2011.04.22

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
end

im = get(menu_hndl,'userdata');
set(menu_hndl,'userdata',flipud(im))
plot_image(menu_hndl,clim)

function plot_compconj(gcbo, eventdata,menu_hndl,clim)
% added at 2011.04.22

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
end

im = get(menu_hndl,'userdata');
set(menu_hndl,'userdata',im.')
plot_image(menu_hndl,clim)



function remove_clim(gcbo, eventdata,menu_hndl)
% added at 2010.04.18

set(gcbo,'userdata',get(gca,'clim'))

plot_image(menu_hndl,[])

function restore_clim(gcbo, eventdata,miniCmap_menuhndl,menu_hndl)
% added at 2010.04.18

clim = get(findobj(miniCmap_menuhndl,'Label', 'Save & Remove Clim'),'userdata');

plot_image(menu_hndl,clim)


function remove_global_clim(gcbo, eventdata,menu_hndl)
% added at 2010.04.19
global mrimage_global_clim;

mrimage_global_clim = get(gca,'clim');

plot_image(menu_hndl,[])

function restore_global_clim(gcbo, eventdata,menu_hndl)
% added at 2010.04.19
global mrimage_global_clim;

clim = mrimage_global_clim;

plot_image(menu_hndl,clim)

function local_axisOn(gcbo, eventdata)
% added at 2010.04.18

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    axis('off');
else 
    set(gcbo, 'Checked', 'on');
    axis('on');
end

function local_export2BS(gcbo, eventdata,menu_hndl)
% added at 2010.04.18
% modified at 2010.09.14

im = get(menu_hndl,'userdata');

if isempty(im)
    im_temp = get(findobj(gca,'type','image'),'cdata');
    assignin('base','current_fig_data',im_temp);
else
    assignin('base','current_fig_data',im);
end

function localAutoClim(gcbo, eventdata,menu_hndl,clim)
% added at 2011.04.01

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
end

plot_image(menu_hndl,clim)
