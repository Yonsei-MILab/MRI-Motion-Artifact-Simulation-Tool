function compened_phase = compenphase(phasehistory)

yi=1:length(phasehistory);
ky_index = round(length(phasehistory)/2 - yi);

compened_phase = phasehistory;

% to do;;;

% start at DC line
start_yi = yi(ky_index==0);

for n= start_yi+1:length(yi)
    compened_phase(n)=compen1ph(compened_phase(n-1),compened_phase(n));
end

for n= start_yi-1:-1:1
    compened_phase(n)=compen1ph(compened_phase(n+1),compened_phase(n));
end
