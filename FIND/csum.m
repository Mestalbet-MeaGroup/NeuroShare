function y = csum(x)
% Cummulative sum - alternative version to Matlab cumsum with less numerical problems. 
% function y = csum(x)
% Version 1.0 - 28/01/00 - rotter@biologie.uni-freiburg.de
%
% WARNING: The matlab routine "cumsum" has numerical problems.
%
% Try the following example:
%
% a = -sort(-rand(100000,1));
% b = cumsum(a);
% sum(a) - b(end)
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

y = filter(1, [1 -1], x);
