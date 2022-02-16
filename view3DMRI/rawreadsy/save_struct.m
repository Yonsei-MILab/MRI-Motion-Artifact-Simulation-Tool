function varargout = save_struct(myvarname,myvar)
% save a structures
% to prevent clear by 'clear all'
% 
% first call this func. with input, then call with output to remind
% to modify them, call again
% 
% use following to clear this from memory and initiate
%     munlock save_struct, clear save_struct
% 
% 
% 
% by cefca
% at 2011.03.30

mlock

persistent pmystruct

if nargin>0
    if isa(myvarname,'char')==1
        eval(['pmystruct.',myvarname,'=myvar;'])
    else
        disp('''myvarname'' must be char, save ignored.')
    end
end

if nargout>0
    varargout{1} = pmystruct;
end