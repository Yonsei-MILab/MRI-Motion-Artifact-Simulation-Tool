function out = mystrtok(str,delimiter,out_isnum)


remain = str;
i=1;
    
while ~isempty(remain)
    [token,remain] = strtok(remain,delimiter);
    
    if out_isnum
        out(i,1)=str2double(token);
    else
        out{i,1}=token;
    end
    
    i=i+1;
end