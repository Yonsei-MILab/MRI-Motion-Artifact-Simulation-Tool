function [ img ] = ifft2c( input_image )
% 2d centered ifft

img = fftshift(fftshift(ifft2(ifftshift(ifftshift(input_image,2 ),1 )),1),2 );

end

