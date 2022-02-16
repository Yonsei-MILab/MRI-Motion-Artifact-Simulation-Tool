function im = fft2c(d)
% im = fft2c(d)
%
% fft2c performs a centered fft2
%
im = fftshift(fft2(fftshift(d)));
