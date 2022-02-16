function [ xout ] = fftc( x , n , dim )
% xout = fftshift(fft(ifftshift(x),n,dim));

xout = fftshift(fft(ifftshift(x),n,dim));

end

