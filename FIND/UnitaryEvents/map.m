function o=map(f,v)
% map vector v on function f  (MD)
%
% in the spirit of Mathematica's Map
%
% Experimental, not all combinations of dimensions may be
% supprted.
%
% if v is a matrix (e.g. column vector of strings). f is applied to each row.
% The result of f is assumed to be a scalar.
% o is a row vector
%
% if v is row vector f is applied to each element.
% The result is a column vector or a matrix (column vector of vectors).
%
% History:
%         (0) first version
%             15.10.96, Diesmann, Freiburg
%
%

 s=size(v);
 if s(1)==1
  l=length(v);
  for i=1:l
   h=feval(f,v(i));
   o(i,1:length(h))=feval(f,h);
  end
 else
  l=s(1);                  % number of rows
  o=zeros(1,l);
  for i=1:l
   o(i)=feval(f,v(i,:));
  end
 end



