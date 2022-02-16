function im = ifftc(d)
% im = ifftc(d)
%
% ifftc performs a centered ifft
%
im = fftshift(ifft(fftshift(d)));
