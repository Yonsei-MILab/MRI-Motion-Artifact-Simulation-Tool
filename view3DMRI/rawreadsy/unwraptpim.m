function out = unwraptpim(pim)
% unwrapping phase image image by plus 2pi to below 0

below0 = pim<-pi/2;
out=pim+(below0*2*pi);
