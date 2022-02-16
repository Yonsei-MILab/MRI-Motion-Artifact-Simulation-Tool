function varargout = dispetime(end_time,start_time)
% display etime to hour, min, sec
% same usage w/ etime
% except when start_time is 0 -> convert second to hh,mm,ss
% 
% USAGE : varargout = dispetime(end_time,start_time)
% 
%                     varargout -> empty (print) or string
%                     end_time -> clock
%                     start_time -> clock
%

if length(start_time)>1
    elps_time = etime(end_time,start_time);
else
    elps_time = end_time;
end

h=floor(elps_time/3600);
m=floor((elps_time-h*3600)/60);
s=elps_time-h*3600-m*60;

str_time = sprintf('Elapsed time = %d h %d min %f sec.',...
    h,m,s);


if nargout>0
    varargout{1}=str_time;
else
    disp(str_time)
end