function [i,j,s] = where(v,t,p)
% [i,j,s] = where(v,t,p), returns positions of test values t in vector v
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% * input:                                                      *
% *         v,    row or column vector of data                  *
% *         t,    row or column vector of test values           *
% *         p,    string 'first' or 'second'                    *
% *                                                             *
% * output:                                                     *
% *         i,    vector of test values t found in v            *
% *               Values are sorted by their value.             *
% *         j,    vector of indices of test values t in vector  *
% *               v. Multiple occurences are allowed.           *
% *               j has same orientation as t. Indices are      *
% *               sorted by their value.                        *
% *         s,    if 'first': number of occurrences of          *
% *                           testvalues t in v                 *
% *                           (same sequence as in t)           *
% *               if 'second': number of occurrence per entries *
% *                            in i and j (all 1) (obsolete)    *
% *                                                             *
% * Uses:                                                       *
% *       matrix, row, col, copy                                *
% *                                                             *
% * See Also:                                                   *
% *           find                                              *
% *                                                             *
% *                                                             *
% * Future:                                                     *
% *         - optimize by computing only necessary sum          *
% *           s in case of 'first'                              *
% *                                                             *
% *                                                             *
% * Example:                                                    *
% *         h=[7 5 2 3 2 8 5 1 5 4]';  hu=[1 2 3 4 5 7 8]';     *
% *                                                             *
% * h =    hu =                      i =    j =    s =          *
% *    7       1                        8      1      1         *
% *    5       2                        3      2      2         *
% *    2       3                        5      2      1         *
% *    3       4  where(hu,h,'first')   4      3      1         *
% *    2       5      ------->         10      4      3         *
% *    8       7                        2      5      1         *
% *    5       8                        7      5      1         *
% *    1                                9      5                *
% *    5                                1      6                *
% *    4                                6      7                *
% *                                                             *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (3) commented                                       *
% *            SG, 17.3.02, FfM                                 *
% *         (2) compiled version                                *
% *            MD, 25.3.1997, Freiburg                          *
% *         (1) rewritten in matrix notation                    *
% *            MD, 31.1.1997, Freiburg                          *
% *         (0) first Version                                   *
% *            SG 9.4.1996, Jerusalem                           * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

compiled=0;

if matrix(v) | matrix(t)                   % matrices not supported
 error('Where::WrongArgumentTypeError');
end

o=orientation(t);

if ~compiled
 b=copy(row(v),length(t),1)==copy(col(t),1,length(v));
 [i,j]=find(b); 
 sv=csum(b);
 st=csum(b');
else
 m=length(t);
 n=length(v);
 i=zeros(m*n,1);
 j=zeros(m*n,1);
 st=zeros(m,1);
 sv=zeros(n,1);
 l=0; 
 for iv=1:n
  for it=1:m
   if t(it)==v(iv)
    l=l+1;
    i(l)=it;
    j(l)=iv;
    sv(iv)=sv(iv)+1;
    st(it)=st(it)+1;
   end
  end
  end
 i=i(1:l);
 j=j(1:l);
end


                                    
if nargout<2
 i=orientv(j,o);
elseif nargout==2
 i=orientv(i,o);
 j=orientv(j,o);
else
 if nargin==3
  i=orientv(i,o);
  j=orientv(j,o);
  if strcmp(p,'first')
   s=orientv(sv,o);
  elseif strcmp(p,'second')
   s=orientv(st,o);
  else
   error('Where::UnknownProperty');
  end 
 else
  error('Where::MissingPropertyArgument');
 end 
end


% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% Sonja's original implementation
%
%function  index = where(vector, value_vec)
%
% n = size(value_vec)
% for i=1:n(2)
%  tmp_idx = find(vector == value_vec(i));
%  if i == 1 index = [tmp_idx]
%  else index = [index, tmp_idx]
%  end
% end
% index = sort(index);


