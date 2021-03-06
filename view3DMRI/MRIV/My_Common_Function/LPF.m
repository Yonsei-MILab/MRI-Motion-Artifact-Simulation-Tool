function out=LPF(data,str_type)
% 5-tap LPF, support above 3D
% Hamming window
%
% str_type = '1d', '2d', '3d' or empty

%% init

M = 5; % window size (filter size)
n=0:(M-1);
wc=pi/2;
% Hamming window
wn = 0.53836 - 0.46164*cos(2*pi*n/(M-1));

% ------------------------- from equation
hd=sin(wc*(n-(M-1)/2))./(pi*(n-(M-1)/2));
hd(isnan(hd))=1/2;

hn = hd.*wn;
% --------------------------- 1024 tap
% fbin1=1024;
% H1=zeros(1,fbin1);
% fc1=fbin1/256;
% H1(1:fc1)=1;
% H1((fbin1-(fc1-2)):fbin1)=1;
%
% hd1 = ifft(H1);
% hd15 = [hd1(3:-1:2) hd1(1:3)];
%
% hn = hd15.*wn;

%% define input dim

if nargin<2
    [y,x,z] = size(data);

    if z>1
        str_type = '3d';
    elseif x>1 && y>1
        str_type = '2d';
    else
        str_type = '1d';
    end
end

%% apply filter

switch str_type
    case '1d'
        % ----------------- 1D filter
        disp('1D LPF')
        h5 = 1/sum(sum(hn)) * hn;  % normalize it

        out = conv(data(:),h5(:));
        r = length(out);

        out = out(3:r-2);

    case '2d'
        % ----------------- 2D filter
        disp('2D LPF')
        hn55 = hn.'*hn;  % use from eq.

        h55 = 1/sum(sum(hn55)) * hn55;  % normalize it

        out = conv2(data,h55);
        [r,c] = size(out);

        out = out(3:r-2,3:c-2);

    case '3d'
        % ----------------- 3D filter
        disp('3D LPF')
        hn55 = hn.'*hn;  % use from eq.
        hn555 = zeros(5,5,5);
        for n=1:5
            hn555(:,:,n) = hn(n)*hn55;
        end

        h555 = 1/sum(hn555(:)) * hn555;  % normalize it

        out = convn(data,h555);
        [r,c,s] = size(out);

        out = out(3:r-2,3:c-2,3:s-2);
    otherwise
        disp('invalid option')

end