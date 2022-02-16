function f2 = kHPF3D(size_ky,size_kx,size_kz,c,w)
% test filter design
% ref. high-pass GRAPPA
% c = filter width 
% w = edge sharpness


kx = -size_kx/2:size_kx/2-1;
kx = repmat(kx,size_ky,1);
kx = repmat(kx,[1,1,size_kz]);

ky = (-size_ky/2:size_ky/2-1)';
ky = repmat(ky,1,size_kx);
ky = repmat(ky,[1,1,size_kz]);

kzi = -size_kz/2:size_kz/2-1;
kz = zeros(1,1,size_kz);
kz(1,1,:) = kzi;
kz = repmat(kz,[1,size_kx,1]);
kz = repmat(kz,[size_ky,1,1]);


% disp(['selected HPF paramer : C = ',num2str(c),', W = ',num2str(w)]);
f2 = 1-1./(1+exp((sqrt(kx.^2+ky.^2+kz.^2)-c)/w))...
    +1./(1+exp((sqrt(kx.^2+ky.^2+kz.^2)+c)/w));

% mrimage(f2);