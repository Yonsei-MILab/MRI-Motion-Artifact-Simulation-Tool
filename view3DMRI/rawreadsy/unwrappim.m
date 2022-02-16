function unwrapedpim = unwrappim(pim)
% unwrapping phase image along y dir.
% start at DC

[r,c]=size(pim);
unwrapedpim = zeros(r,c);

for i=1:c
    unwrapedpim(:,i) = compenphase(pim(:,i));
end

