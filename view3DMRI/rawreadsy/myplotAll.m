function myplotAll(im,dir,use_each_clim,res)
% function myplotAll(im,dir,use_each_clim)
% 
% plot image through selected slice direction
% 
% 
% im            : maximum 4-dim image
% dir           : slice direction, in order y,x,z = 1,2,3
% use_each_clim : if it use each scale limit (set 1) or whole image scale limit (set 0)
% res           : resolution, [resY, resX, resZ]
% 
% 
% coded by Sang-Young Zho
% refer Mino's code
% first coded at 2010.07.20
% 
% add figure resize fuction
% last modified at 2010.07.21
% 
% minor bug fixed
% last modified at 2010.07.25



%% error control for input param

if nargin<2
    error('give me ''im'', ''dir''')
end


maxDim = ndims(im);


if maxDim==1
    plot(im,'.-');
    return;
else
    if maxDim==2
        mrimage(im);
        return;
    else
        if maxDim>4
            errordlg('function ''myplotAll'' does not support above 4D image')
        end
        
        dimSize = size(im);
        if dir<1
            dir = 1;
        end
        if dir>maxDim
            dir = maxDim;
        end    
    end
end

if nargin==2
    use_each_clim = 0;
    res = ones(size(dimSize));
end

if nargin==3
    res = ones(size(dimSize));
end


%% find optimal # of row, col


switch dir
    case 1
        text_dir = 'ZX';
    case 2
        text_dir = 'YZ';
    case 3
        text_dir = 'YX';
end



numSlice = dimSize(dir);

plotSize = dimSize(1:3).*res;

switch dir
    case 1
        plotSize = [plotSize(3),plotSize(2)];
        data_res = [res(3) res(2) 1];
    case 2
        plotSize = [plotSize(1),plotSize(3)];
        data_res = [res(1) res(3) 1];
    case 3
        plotSize(3) = [];
        data_res = [res(1) res(2) 1];
end


screen_size = get(0,'ScreenSize');
Margin = 10; % pixel

[Nrow, Ncol] = findOptimalNim(screen_size(4:-1:3),plotSize+Margin,numSlice);



%% subplot

if use_each_clim==0
    im1v = im(:);
    if ~isreal(im1v)
        im1v = mag(im1v);
    end
    
    clim_min = min(im1v);
    clim_max = max(im1v);
    
    clear im1v
end


if maxDim==4
    N4D = dimSize(4);
else
    N4D = 1;
end

for i4D = 1:min(N4D,10) % limit 10 figures
    
    f=figure;
    set(f,'name',sprintf('myplotAll - %s slices',text_dir))
    set(f,'PaperPositionMode','auto')
    menu_hndl = uimenu(f, 'Label', 'Arrange');
    uimenu(menu_hndl, 'Label', 'Auto ReArrange', 'Callback', {@local_autoRearr,f});
    set(findobj(menu_hndl,'Label', 'Auto ReArrange'), 'Checked', 'on');
    setappdata(f,'flag_autoRearr',1)

    
    setappdata(f,'plotSize',plotSize)
    setappdata(f,'Nrow',Nrow)
    setappdata(f,'Ncol',Ncol)
    setappdata(f,'Margin',Margin)
    
    % --------- initial arrangement and sizing figure
    desired_figSize = screen_size(3:4)*0.7;
    % minus margin
    desired_figSize = desired_figSize - [Margin*(Ncol+1) Margin*(Nrow+1)];
    plotAllSize = [plotSize(1)*Nrow plotSize(2)*Ncol]; % pixel
    
    fig_vs_plotAll_Ratio = desired_figSize./fliplr(plotAllSize);
    desired_figSizeRatio = min(fig_vs_plotAll_Ratio);

    plotSize = plotSize*desired_figSizeRatio;
    
    figSize = fliplr(plotAllSize)*desired_figSizeRatio + [Margin*(Ncol+1) Margin*(Nrow+1)];
    figSize = ceil(figSize);
    % -----------------------------------

    set(f,'position',[(screen_size(3:4)-figSize)/2,  figSize])
    
    
    ha = zeros(numSlice,1);    
    iSlice = 1;
    for r = 1:Nrow
        for c = 1:Ncol
            
            if iSlice>numSlice
                break;
            end
            
            switch dir
                case 1 % 'ZX'
                    temp_im = permute(im(iSlice,:,:),[3 2 1]);
                case 2 % 'YZ'
                    temp_im = permute(im(:,iSlice,:),[1 3 2]);
                case 3 % 'YX'
                    temp_im = im(:,:,iSlice);
            end
            
 
            ha(iSlice) = axes('units','pixel','position',floor([Margin+(Margin+plotSize(2))*(c-1), figSize(2)-(Margin+plotSize(1))*r, plotSize(2:-1:1)]));
            set(gca,'units','normalized')
           
            if use_each_clim
                mrimagef(temp_im);
            else
                mrimagef(temp_im,[clim_min,clim_max]);
            end
            daspect(data_res)
            
            iSlice = iSlice +1;
        end
    end
    
    setappdata(f,'ha',ha)
    setappdata(f,'numSlice',numSlice)
    
    set(f,'ResizeFcn',{@myfigResize,f})

end


function myfigResize(gcbo, eventdata,f)


plotSize = getappdata(f,'plotSize');
ha = getappdata(f,'ha');
numSlice = getappdata(f,'numSlice');
Nrow = getappdata(f,'Nrow');
Ncol = getappdata(f,'Ncol');
Margin = getappdata(f,'Margin');
flag_autoRearr = getappdata(f,'flag_autoRearr');

pos = get(f,'position');
figSize = pos(3:4);

if flag_autoRearr
    [Nrow, Ncol] = findOptimalNim(figSize(2:-1:1),plotSize+Margin,numSlice);
    setappdata(f,'newNrow',Nrow)
    setappdata(f,'newNcol',Ncol)
end

% minus margin
figSize = figSize - [Margin*(Ncol+1) Margin*(Nrow+1)];
plotAllSize = [plotSize(1)*Nrow plotSize(2)*Ncol]; % pixel

fig_vs_plotAll_Ratio = figSize./fliplr(plotAllSize);

desired_figSizeRatio = min(fig_vs_plotAll_Ratio);

plotSize = plotSize*desired_figSizeRatio;


iSlice = 1;
for r = 1:Nrow
    for c = 1:Ncol
        if iSlice>numSlice
            break;
        end
        set(ha(iSlice),'units','pixel')
        set(ha(iSlice),'position',floor([Margin+(Margin+plotSize(2))*(c-1), pos(4)-(Margin+plotSize(1))*r, plotSize(2:-1:1)]));
        set(ha(iSlice),'units','normalized')
        
        iSlice = iSlice +1;
        
    end
end


function [Nrow, Ncol] = findOptimalNim(figSize,plotSize,numSlice)
% figSize, plotSize = [row, col]

Nrow_per_Ncol = (figSize(1)/plotSize(1))/(figSize(2)/plotSize(2));

Ncol = round(sqrt(numSlice/Nrow_per_Ncol));
Nrow = round(Ncol*Nrow_per_Ncol);
Nrow = min(Nrow,round(numSlice/Ncol));

if Ncol*Nrow<numSlice
    remainSlice = numSlice - Ncol*Nrow;
    remainNcol = remainSlice/Nrow;
    remainNrow = remainSlice/Ncol;
    
    if remainNcol>remainNrow
        Ncol = Ncol+ ceil(remainNcol);
    else
        Nrow = Nrow+ ceil(remainNrow);
    end
end


function local_autoRearr(gcbo, eventdata,f)

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    setappdata(f,'flag_autoRearr',0)
    newNrow = getappdata(f,'newNrow');
    newNcol = getappdata(f,'newNcol');
    setappdata(f,'Nrow',newNrow)
    setappdata(f,'Ncol',newNcol)
    
else 
    set(gcbo, 'Checked', 'on');
    setappdata(f,'flag_autoRearr',1)
    myfigResize(gcbo, eventdata,f)

end

