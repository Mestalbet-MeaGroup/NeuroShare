function num = cell2num(cel, dim);
% Converts a cell array of doubles to a double array.
%
% num = cell2num(cel)
% <cel> must not contain strings, all cells must be of equal size 
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

if nargin==1
   dim = 1;
end;

num= cat(dim, cel{:});
   
   
return



str = cell2struct(cel, 'f1', length(cel));
num=zeros(length(str),1);

try
     for i=1:length(str)
          num(i) = str2num(getfield(str(i), 'f1'));
     end
catch
   disp('could not convert the cell array, maybe it is not all doubles');
end;

