function err = AP(ref_im,im,do_normalize)
% calculate Artifact Power
% Eq 5. ref. in Jaesoek Park 2005
% do_normalize = 1 -> difference image of normalized images



if nargin<3
    do_normalize = 0;
end

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

% err_im = mag(mag_ref_im-mag_im);
err = sum((mag_ref_im(:)-mag_im(:)).^2)/sum(mag_ref_im(:).^2);
% err = sum((mag(ref_im(:))-mag(im(:))).^2)/sum(mag(ref_im(:)).^2);

