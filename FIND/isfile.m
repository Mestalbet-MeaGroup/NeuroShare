function result = isfile(x);
% ISFILE           - check if a file exists 
% result = isfile(x)
% checks if file named by a string exists
%
% (c) U. Egert 1999
% 
% Could be brushed up - is obsolete for modern matlab


result = 0;
if isempty(x) | isnumeric(x)
%   disp([mfilename ':: x must be a string']);
   return
end;

result = (exist(x) == 2);
