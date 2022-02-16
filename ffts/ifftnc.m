function [ img ] = ifftnc( input_image )
% nd centered ifft

img = fftshift(ifftn(ifftshift(input_image)));

end

