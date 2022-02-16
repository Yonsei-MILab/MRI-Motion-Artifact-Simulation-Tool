function [ img ] = fft2c( input_image )
% 2d centered fft

img = fftshift(fftshift(fft2(ifftshift(ifftshift(input_image,2 ),1 )),1),2 );

end

