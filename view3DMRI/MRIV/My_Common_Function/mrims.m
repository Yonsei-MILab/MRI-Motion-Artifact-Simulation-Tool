function varargout = mrims(varargin)
% varargout = mrim(im,do_unwrap,index)
%
% USAGE : varargin{1} -> image
%         varargin{2} -> figure title
%         varargin{3} -> filename
%         varargin{4} -> figure index
% 
%    output1 -> magnitude image matrix
%    output2 -> phase image matrix

im = varargin{1};

if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end

pim = angle(im);

title_text=[];
filename = [];

if nargin>1
    title_text = varargin{2};
end

if nargin>2
    filename = varargin{3};
end

if nargin>3
    cf = figure(varargin{4});
else
    cf = figure; % make new figure
end



% set new position and size
set(cf,'Toolbar','figure',...
    'position',[150 380-50 500*2 400+50]);     % [left bottom width height]

% Scale data and display an image object

subplot(1,2,1);
f=imagesc(mim); % use 'f' as gcf of current figure
title('Magnitude image','FontSize',18,'FontWeight','bold');
mrinit;

subplot(1,2,2);
g=imagesc(pim); % use 'g' as gcf of current figure
title('Phase image ','FontSize',18,'FontWeight','bold');
mrinit;

% set title_text
title_text_win = uicontrol('style','text',...
    'string',title_text,...
    'BackgroundColor','w',...
    'fontsize',18,...
    'Units','pixel',...
    'Position',[580 10 400 30],...    % [left bottom width height]
    'Parent',cf);

uicontrol('style','text',...
    'string','FileName :',...
    'fontsize',14,...
    'Units','pixel',...
    'Position',[10 10 100 30],...    % [left bottom width height]
    'Parent',cf);

uicontrol('style','text',...
    'string','Info :',...
    'fontsize',14,...
    'Units','pixel',...
    'Position',[530 10 50 30],...    % [left bottom width height]
    'Parent',cf);

filename_text_win = uicontrol('style','text',...
    'string',filename,...
    'BackgroundColor','w',...
    'fontsize',14,...
    'Units','pixel',...
    'Position',[110 10 400 30],...    % [left bottom width height]
    'Parent',cf);

switch nargout
    case 1
        varargout{1} = cf;
    case 2
        varargout{1} = cf;
        varargout{2} = mim;
    case 3
        varargout{1} = cf;
        varargout{2} = mim;
        varargout{3} = pim;
end

% clear im;
% clear mim;
% clear pim;
