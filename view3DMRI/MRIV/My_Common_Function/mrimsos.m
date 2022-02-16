function varargout = mrimsos(varargin)
% h = mrimsos(im)
% 
% displays a square root sum-of square image
% z direction is coil dir
% varargin = data,figure_index


im = varargin{1};

sosim = SOS(im);

if nargin>1
    h=figure(varargin{2}); % make new figure w/ specified index
else
    h=figure; % make new figure
end


imagesc(sosim);

mrinit;

switch nargout
    case 1
        varargout{1} = sosim;
    case 2
        varargout{1} = sosim;
        varargout{2} = h;
end
