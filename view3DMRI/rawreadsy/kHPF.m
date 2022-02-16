function f2 = kHPF(size_ky,size_kx,c,w)
% test filter design
% ref. high-pass GRAPPA
% c = filter width 
% w = edge sharpness


kx = -size_kx/2:size_kx/2-1;
kx = repmat(kx,size_ky,1);
ky = (-size_ky/2:size_ky/2-1)';
ky = repmat(ky,1,size_kx);


% disp(['selected HPF paramer : C = ',num2str(c),', W = ',num2str(w)]);
f2 = 1-1./(1+exp((sqrt(kx.^2+ky.^2)-c)/w))+1./(1+exp((sqrt(kx.^2+ky.^2)+c)/w));

% mrimage(f2);