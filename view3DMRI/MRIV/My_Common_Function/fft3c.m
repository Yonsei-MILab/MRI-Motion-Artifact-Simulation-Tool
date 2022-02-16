function im = fft3c(d,option)
% USAGE : im = fft3c(d,option)
%
% fft3c performs a centered fft3
%
% option :
%     0 -> all dir
%     1 -> y dir
%     2 -> x dir
%     8 -> z dir
%     3 -> y,x dir
%     9 -> y,z dir
%     10 -> x,z dir
%     11 -> x,y,z dir
%     
% coded by Sang-Young Zho
% last modified at 2009.05.27

if nargin==1
    option = 0;
end

switch option
    case 0 %     0 -> all dir
        im = ifftshift(fftn(fftshift(d)));
        
    case 1 %     1 -> y dir
        im = ifftshift(fft(fftshift(d),[],1));
    case 2 %     2 -> x dir
        im = ifftshift(fft(fftshift(d),[],2));
    case 8 %     8 -> z dir
        im = ifftshift(fft(fftshift(d),[],3));
        
    case 3 %     3 -> y,x dir
        im = fftshift(d);
        clear d;
        im = fft(im,[],1);
        im = fft(im,[],2);
        im = ifftshift(im);        
    case 9 %     9 -> y,z dir
        im = fftshift(d);
        clear d;
        im = fft(im,[],1);
        im = fft(im,[],3);
        im = ifftshift(im);
    case 10 %     10 -> x,z dir
        im = fftshift(d);
        clear d;
        im = fft(im,[],2);
        im = fft(im,[],3);
        im = ifftshift(im);
        
    case 11 %     11 -> x,y,z dir
        im = fftshift(d);
        clear d;
        im = fft(im,[],1);
        im = fft(im,[],2);
        im = fft(im,[],3);
        im = ifftshift(im);
        
    otherwise
        disp('Error using "fft3c"...')
        disp('Invalid option.')
        im = [];
        return;
end
