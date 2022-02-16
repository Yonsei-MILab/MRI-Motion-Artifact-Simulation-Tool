function varargout = plotmany(varargin)
% plot several line
%
% USAGE : fhndl = plotmany(data)
%         fhndl = plotmany(data,index)
%         fhndl = plotmany(x,data,index)
% 
%       x -> x-axis (time)
%       data -> y-axis (data to plot)
%       index -> index to identify color and marker
%       fhndl -> plot handle

% last modified at 2008.11.10
%               by SangYoung Zho


error(nargchk(1,3,nargin));


if nargin==1
    data=varargin{1};
    i=randint(1,1,13);
    x=1:length(data);
end

if nargin==2
    data=varargin{1};
    i=varargin{2};
    x=1:length(data);
end

if nargin==3
    x=varargin{1};
    data=varargin{2};
    i=varargin{3};
end


if ~isreal(data)
    data=abs(data);
end

linestyleorder={':','--','-.','-'};
markerorder={'+','o','*','.','x','s','d','^','v','>','<','p','h'};
colororder={'r','g','m','k','c','b'};

l=mod(i,4);
m=mod(i,13);
c=mod(i,6);

    
if(l==0)
    l=4;
end
  
if(m==0)
    m=13;
end
    
if(c==0)
    c=6;
end



hold on;grid on
fhndl = plot(x,data,char([char(linestyleorder(l)),char(markerorder(m)),char(colororder(c))]));
%set(gca,'XTick',x);
hold off

l=l+1;
m=m+1;
c=c+1;

if nargout==1
    varargout{1} = fhndl;
end

