function varargout = save_variable_once(varargin)
% save upto 10 variables
% to prevent clear by 'clear all'
% 
% first call this func. with input, then call with output to remind
% once variable were saved, cannot modify them
% 
% use following to clear this from memory and initiate
%     munlock save_variable_once, clear save_variable_once
% 
% 
% 
% by cefca
% at 2010.10.25

mlock

persistent ps1
persistent ps2
persistent ps3
persistent ps4
persistent ps5
persistent ps6
persistent ps7
persistent ps8
persistent ps9
persistent ps10

if nargin>10
    fprintf('upto 10 input. current Nin = %d\n',nargin)
end
if nargout>10
    fprintf('upto 10 output. current Nout = %d\n',nargout)
end

for n=1:min(nargin,10)
    if eval(['isempty(ps',num2str(n),')'])
        eval(['ps',num2str(n),'= varargin{n};'])
    end
end

for n=1:nargout
    if n<11
        eval(['varargout{n} = ','ps',num2str(n),';'])
    else
        varargout{n} = [];
    end
end
