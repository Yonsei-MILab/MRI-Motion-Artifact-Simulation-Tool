function varargout = mrimagef(im,clim,donot_setgray)
% varargout = mrimagef(im,clim,donot_setgray)
%
% displays a complex image into a colormap scaled from 1 to 64
% returns the handle for an image graphics object.
% 
% modified by Sang-Young Zho
% last modified at 2010.07.20



% added at 2009.10.23
% Remove singleton dimensions
im = squeeze(im);

if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end

if nargin<3
    donot_setgray = 0;
end

if nargin<2
    if isempty(get(findobj(gca,'type','image'),'cdata'))
        h=imagesc(mim);
    else
        set(findobj(gca,'type','image'),'cdata',mim)
        h = gca;
    end
else
    if isempty(clim)
        if isempty(get(findobj(gca,'type','image'),'cdata'))
            h=imagesc(mim);
        else
            set(findobj(gca,'type','image'),'cdata',mim)
            h = gca;
        end
    else
        if clim(2)<=clim(1)
            clim(2) = clim(1)+0.001;    % make max to larger
%             clim(1) = -2*mag(clim(2));  % make min to smaller
        end
        if isempty(get(findobj(gca,'type','image'),'cdata'))
            h=imagesc(mim,clim);
        else
            set(findobj(gca,'type','image'),'cdata',mim)
            set(gca,'clim',clim)
            h = gca;
        end
    end
end

if nargout>0
    varargout{1} = h;
end

if donot_setgray
    %axis image is the same as axis equal except that the plot box fits tightly
    %around the data.
    axis('image');

    % also, you probably don't care about the axes
    axis('off');
else
    mrinit;
end


