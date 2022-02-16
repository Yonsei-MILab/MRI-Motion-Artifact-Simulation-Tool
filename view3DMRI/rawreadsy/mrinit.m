% initializations for MR image displays.

% Matlab assumes pseudocolor image, set the colormap to grayscale
colormap('gray');

% you want to display the image with a square aspect ratio.
%axis('square');

%axis image is the same as axis equal except that the plot box fits tightly
%around the data.
axis('image');

% also, you probably don't care about the axes
axis('off');

% the default colormap has 64 gray levels. The image(im) function uses the
% value of im at each pixel as an index into the colormap. hence, you want
% im to be real valued, and scaled from 1 to 64
% imx = max(max(abs(im)));
% image(abs(im)*64/imx);

