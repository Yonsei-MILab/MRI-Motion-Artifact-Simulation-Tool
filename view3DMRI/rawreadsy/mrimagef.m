function varargout = mrimagef(ah,im,clim,donot_setgray)
% varargout = mrimagef(ah,im,clim,donot_setgray)
% varargout = mrimagef(im,clim,donot_setgray)
% 
% ah : axes handle
%
% displays a complex image into a colormap scaled from 1 to 64
% returns the handle for an image graphics object.
% 
% modified by Sang-Young Zho
% last modified at 2010.07.20
% 
% fix bugs on empty clim
% simplfy code
% ----- last modified at 2010.12.03
% 
% add use axes handle
% ----- last modified at 2011.07.22
% ----- last modified at 2011.07.23


% use axes handle - added at 2011.07.22
if sum(ah(:))~=0 && sum(ishandle(ah(:)))
    h = ah;
    if nargin<4
        donot_setgray=0;
    end
    if nargin<3
        clim=[];
    end
else
    h = gca;
    switch nargin
        case 1
            donot_setgray=0;
            clim=[];            
        case 2
            donot_setgray=0;
            clim=im;            
        case 3
            donot_setgray=clim;
            clim=im;            
    end        
    im=ah;
end
  

% added at 2009.10.23
% Remove singleton dimensions
im = squeeze(im);

if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end



if isempty(get(findobj(h,'type','image'),'cdata'))
    imagesc(mim,'parent',h); % use axes handle - added at 2011.07.23
else
    set(findobj(h,'type','image'),'cdata',mim)
end


if isempty(clim)
    % -- added at 2010.12.03
    set(h,'CLimMode','auto')
else
    if clim(2)<=clim(1)
        clim(2) = clim(1)+0.001;    % make max to larger
        %             clim(1) = -2*mag(clim(2));  % make min to smaller
    end
    set(h,'clim',clim)
end


if ~isempty(im)
    axis(h,'image');
end
axis(h,'off');

if ~donot_setgray
    colormap(h,'gray');
end

if nargout>0
    varargout{1} = h;
end

