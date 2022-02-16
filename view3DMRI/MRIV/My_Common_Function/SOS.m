function sos_im = SOS(im)
% compute square root sum-of-squares
%
% coil element is
%     3-dim : [Ny,Nx,Nc]
%     4-dim : [Ny,Nx,Nz,Nc]
%     
% coded by Sang-Young Zho
% last modified at 2009.05.27


[Ny,Nx,Nz,Nc] = size(im);
if Nc==1
    coil_dim = 3;
elseif Nc>1
    coil_dim = 4;    
end

sos_im = sqrt(sum(mag(im).^2,coil_dim));