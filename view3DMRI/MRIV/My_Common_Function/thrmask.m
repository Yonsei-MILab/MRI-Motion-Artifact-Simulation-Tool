function logical_out = thrmask(im)
% threshold masking using magnitude of im

[r,c] = size(im);
im = mag(im);

% th = sum(sum(im))/(r*c); % saptial average
th = mean2(im); % saptial average

% logical_out = dia(im>th);
logical_out = (im>th);


% ------------------ y-directional detecting
for n=1:c
    [minindex,maxindex] = findminmax(logical_out(:,n));
    
    if minindex>0 && maxindex>0
        logical_out(minindex:maxindex,n)=1;
    end

end


% ------------------ x-directional detecting
for n=1:r
    [minindex,maxindex] = findminmax(logical_out(n,:));
    
    if minindex>0 && maxindex>0
        logical_out(n,minindex:maxindex)=1;
    end

end




function [minindex,maxindex] = findminmax(vec)

veclen = length(vec);
minindex=0;
maxindex=0;

for n=1:veclen
    if vec(n)==1
        minindex=n;
        break;
    end    
end

if n==veclen, return, end

for m=veclen:-1:minindex
    if vec(m)==1
        maxindex=m;
        break;
    end
end

