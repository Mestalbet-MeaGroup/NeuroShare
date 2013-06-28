function dva = cell2mat(dvc, varargin);
% CELL2mat - converts a cell array of vectors to a matrix
% dva = cell2mat(dvc, varargin) places each cell of <dvc>
%    into a row of <dva>, rows are padded with zeros to the 
%    longest vector in <dvc>.
%
% These options can be set by parameter values pairs (default
% values in brackets):
% 
% parameter     value              function
% M            integer(64)         number of rows
% N            max. vector length  number of columns
% usesparse    'yes'/('no')        use a sparse matrix style
% sortorder    integers, (1:64)    determines how the cells are 
%                                  mapped to rows.
%
% U. Egert 6/98


% ############################################################

usesparse = 'no';

for i = 1:length(dvc)
     m(i) = length(dvc{i});
end;
N = max(m);
M = length(dvc);
sortorder = 1:length(m);

% -----------------------------------
% this loop looks for modifications of the default values
for i = 1:2:size(varargin,2)
     assign(varargin{i}, varargin{i+1});
end;

assert('length(dvc) == length(sortorder)');

% -----------------------------------

if strcmp(usesparse, 'no')
     dva = zeros(M, N);
else
     dva = spalloc(M, N, sum(m));
end;


for i = 1:length(dvc)
     if N < m(i)
          dva(sortorder(i), 1:N) = dvc{i}(1:N);
     else
          dva(sortorder(i), 1:m(i)) = dvc{i};
     end;
end;


