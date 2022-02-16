function varargout = mrim(im,title_text,do_unwrap,index)
% varargout = mrim(im,title_text,do_unwrap,index)
%
% USAGE : im -> image
%         title_text -> figure title
%         do_unwrap -> unwrap negative phase if 1
%         index -> image indexing
%
%    output1 -> magnitude image matrix
%    output2 -> phase image matrix


if nargin==1
    index=1;
    do_unwrap=0;
    title_text='';
    
elseif nargin==2
    index=1;
    do_unwrap=0;
    
elseif nargin==3
    index=1;
end

if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end

pim = angle(im);

if do_unwrap==1
    pim=unwraptpim(pim);
end

mim_ent = eval('entropy(mim)','[]');
entropy_text = ['entropy(magnitude image) = ',num2str(mim_ent)];
mim_gradent = eval('gradentropy(mim)','[]');
gradentropy_text = ['gradient entropy = ',num2str(mim_gradent)];

cf = figure; % make new figure
% set new position and size
set(cf,'Toolbar','figure',...
    'position',[100 380-50 560*2 420+50]);     % [left bottom width height]

% Scale data and display an image object

subplot(1,2,1);
f=imagesc(mim); % use 'f' as gcf of current figure
title(['Magnitude image #',num2str(index)],'FontSize',18,'FontWeight','bold');
mrinit;

subplot(1,2,2);
g=imagesc(pim); % use 'g' as gcf of current figure
title(['Phase image #',num2str(index)],'FontSize',18,'FontWeight','bold');
mrinit;

% set title_text
title_text_win = uicontrol('style','text',...
    'string',title_text,...
    'BackgroundColor','w',...
    'fontsize',20,...
    'Units','pixel',...
    'Position',[550 10 480 40],...    % [left bottom width height]
    'Parent',cf);

% set entropy_text
entropy_text_win = uicontrol('style','text',...
    'string',entropy_text,...
    'BackgroundColor','w',...
    'fontsize',14,...
    'ForegroundColor','b',...
    'Units','pixel',...
    'Position',[130 35 400 25],...    % [left bottom width height]
    'Parent',cf);

% set gradentropy_text
gradentropy_text_win = uicontrol('style','text',...
    'string',gradentropy_text,...
    'BackgroundColor','w',...
    'fontsize',14,...
    'ForegroundColor','b',...
    'Units','pixel',...
    'Position',[130 10 400 25],...    % [left bottom width height]
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

        
    