function compened = compen1ph(prevph,curph)

dph = 2*pi;   % wrapping phase by 2pi

ntime = (prevph-curph)/dph;
ntime = round(ntime);

compened = curph + dph*ntime;
