function [f,g] = mrimsv(im,index,dircname)
% [f,g] = mrimsv(im,index,dircname)
%
% for save complex image (magnitude and phase)  
% to 'dircname' directory in increasing order
%


if ~isreal(im)
    mim=mag(im);    % mag() is more fast function than abs()
else
    mim=im;
end

pim = angle(im);



f=imagesc(mim); % use 'f' as gcf of current figure
title(['Magnitude image #',num2str(index)],'FontSize',18,'FontWeight','bold');
mrinit;


if ~isdir(['./figure/' dircname])
    mkdir('./figure',dircname);
end

saveas(f,['./figure/' dircname '/' dircname ' - ' num2str(index) 'mag' '.jpg']);


g=imagesc(pim); % use 'g' as gcf of current figure
title(['Phase image #',num2str(index)],'FontSize',18,'FontWeight','bold');
mrinit;


saveas(g,mat2str(['./figure/' dircname '/' dircname '- ' num2str(index) 'ph' '.jpg']));

% close(gcf);   % close figure


