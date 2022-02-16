function im = fftnc(d)
% im = fftnc(d)
%
% fftnc performs a centered fftn
%
im = fftshift(fftn(fftshift(d)));
