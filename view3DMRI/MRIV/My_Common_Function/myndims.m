function n = myndims(data)
% verify number of array dimension
% provide 3D data

[y,x,z] = size(data);


% if x>1 && y>1 && z>1
%     n=3;
% elseif x==1 || y==1 || z==1
%     n=2;
% else
%     n=1;
% end

if z>1
    n=3;
elseif x>1 && y>1
    n=2;
else
    n=1;
end