function im = fftc(d)
% im = fftc(d)
%
% fftc performs a centered fft
%
im = fftshift(fft(fftshift(d)));
