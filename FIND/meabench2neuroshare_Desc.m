function d=loaddesc(fn)
% reads the description file FN or FN.desc corresponding to the meabench spike files
%
% It returns a structure with values for each line read.
% The fields are named from the label in the description file.
% All values are converted to double. Original strings are stored in
% the field LABEL_str.
% Repeated keys are stored in a cell array.

% matlab/loaddesc.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
%
% modified by a.kilias 07 
% (FIND_GUI Toolbox project; http://find.bccn.uni-freiburg.de)

d = struct('dummy','dummy');

fd = fopen(fn,'r');
if fd==0
    fd = fopen([fn '.desc'],'r');
end
if fd==0
    error([ 'File ' fn ' or ' fn '.desc not found']);
end

while 1
    txt = fgetl(fd);
    if ~ischar(txt)
        break
    end

    colon = min(find(txt==':'));
    key = convertkey(txt(1:(colon-1)));
    val = skipspace(txt((colon+1):end));
    numval = sscanf(val,'%f');
    if ischar(numval)
        numval=val;
    else
        numval = numval';
    end

    %  d = descset(d,key,numval);
    %  d = descset(d,[ key '_str'],val);
    d = descset(d,key,val);
end
fclose(fd);

d = rmfield(d,'dummy');

return


% ----------------------------------------------------------------------
function key = convertkey(key)
key = skipspace(key);
spc = find(key == ' ');
key(spc) = '_';
good = find((key>='0' & key<='9') | (key>='A' & key<='Z') | ...
    (key>='a' & key<='z') | key=='_');
key = key(good);
return

% ----------------------------------------------------------------------
function d = descset(d,key,val)
if isfield(d,key)
    % Key occurred before
    oldv = getfield(d,key);
    if iscell(oldv)
        % Already a cell array
        L = length(oldv);
        oldv{L+1} = val;
        d = setfield(d,key,oldv);
    else
        % Key occurred before, but only once, so not yet cell array
        newv = { oldv, val};
        d = setfield(d,key,newv);
    end
else
    % Key didn't occur before
    d = setfield(d,key,val);
end
return

% ----------------------------------------------------------------------
function s = skipspace(s)
ok = find(s ~= ' ');
s = s(min(ok):max(ok));
return

