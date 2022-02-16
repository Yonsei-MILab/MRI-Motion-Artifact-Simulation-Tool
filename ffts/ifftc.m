function [ xout ] = ifftc( x , n , dim )
% xout = fftshift(fft(ifftshift(x),n,dim));

xout = fftshift(ifft(ifftshift(x),n,dim));

end