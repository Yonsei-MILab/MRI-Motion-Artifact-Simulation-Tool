function [err,err_im] = RMSerror(ref_im,im,do_normalize)
% Usage : [err,err_im] = RMSerror(ref_im,im,do_normalize)
% 
% calculate RMS error and error image
% error image -> absolute magnitude difference image
% do_normalize = 1 -> difference image of normalized images
% 
% last modified at 2008.10.03 by Zho

if nargin<3
    do_normalize = 1; % always normalize
end

d_size = numel(im); % product of array size

mag_ref_im = mag(ref_im);
clear ref_im
mag_im = mag(im);
clear im


if do_normalize
    max_ref_im = max(mag_ref_im(:));
    max_im = max(mag_im(:));
    mag_ref_im = mag_ref_im/max_ref_im;
    mag_im = mag_im/max_im;
    
%     mrimage(mag_ref_im/max_ref_im);
%     mrimage(mag_im/max_im);

end

err_im = mag(mag_ref_im-mag_im);
% err = sqrt(sum((mag_ref_im(:)-mag_im(:)).^2))/sqrt(sum(mag_ref_im(:).^2));

err = sqrt(sum((mag_ref_im(:)-mag_im(:)).^2))/sqrt(d_size); % general RMS error
