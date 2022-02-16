function data = sav2cpx(data,filename)

%-----------------------------------------------------------
fnlen = length(filename);

if fnlen>5 && sum(filename(fnlen-4:fnlen) == '.data')/5
    fid=fopen(filename,'w','ieee-le');
else
    fid=fopen(mat2str([filename '.data']),'w','ieee-le');
end
%-----------------------------------------------------------
if class(data)=='double'
    data = single(data);
end

data_real = real(data);
data_imag = imag(data);

vec_real = reshape(data_real.',1,[]);   % NOTE : transpse for keep order
vec_imag = reshape(data_imag.',1,[]);   % NOTE : transpse for keep order

vec2gether = [vec_real;vec_imag];

vec = reshape(vec2gether,1,[]);

fwrite(fid,vec,'float32');

fclose(fid);