function unwrapedpim = unwrapxpim(pim)
% unwrapping phase image along x dir.
% start at DC

[r,c]=size(pim);
unwrapedpim = zeros(r,c);

for i=1:r
    unwrapedpim(i,:) = compenphase(pim(i,:));
end

