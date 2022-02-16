function varargout = mrimcomp(im,title_text,index)
% varargout = mrimc(im,title_text,index)
%
% USAGE : im -> image
%         title_text -> figure title
%         do_unwrap -> unwrap negative phase if 1
%         index -> image indexing
%
%    output1 -> real image matrix
%    output2 -> imag image matrix


if nargin==1
    index=1;
    title_text='';
    
elseif nargin==2
    index=1;
    
end

rim = real(im);
iim = imag(im);

    

cf = figure; % make new figure
% set new position and size
set(cf,'Toolbar','figure',...
    'position',[100 380-50 560*2 420+50]);     % [left bottom width height]

% Scale data and display an image object

subplot(1,2,1);
f=imagesc(mag(rim)); % use 'f' as gcf of current figure
title(['Real part of image #',num2str(index)],'FontSize',15,'FontWeight','bold');
mrinit;

subplot(1,2,2);
g=imagesc(mag(iim)); % use 'g' as gcf of current figure
title(['Imaginary part of image #',num2str(index)],'FontSize',15,'FontWeight','bold');
mrinit;

% set title_text
title_text_win = uicontrol('style','text',...
    'string',title_text,...
    'BackgroundColor','w',...
    'fontsize',24,...
    'Units','pixel',...
    'Position',[180 10 560 40],...    % [left bottom width height]
    'Parent',cf);

switch nargout
    case 1
        varargout{1} = rim;
    case 2
        varargout{1} = rim;
        varargout{2} = iim;
end

        
    