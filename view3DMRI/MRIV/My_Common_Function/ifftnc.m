function im = ifftnc(d)
% im = ifftnc(d)
%
% ifftnc performs a centered ifftn
%
im = fftshift(ifftn(fftshift(d)));
