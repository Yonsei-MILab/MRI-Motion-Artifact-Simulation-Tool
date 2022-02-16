function [ img ] = fftnc( input_image )
% 2d centered fft

img = fftshift(fftn(ifftshift(input_image)));

end

