function [j,k] = inrange(t,lr)
% [j,k]=inrange(t,lr), returns index j of t in range k
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         t,    row or column vector of data                  *
% *         lr,   row matrix of ranges lr(k,1) ... lr(k,2)      *
% *         j,    col vector of indices with t(j)  in           *
% *               at least one of the ranges specified by lr.   *
% *         k,    t(j) is in range lr(k,:)                      *
% *                                                             *
% * Note:                                                       *
% *      - with the compiled flag set. set current path to      *
% *        path for inrange.m and compile                       *
% *        "mcc -ri inrange" at the matlab prompt.              *
% *                                                             *
% * Uses:                                                       *
% *       row, col, copy                                        *
% *                                                             *
% * See Also:                                                   *
% *           where(), find()                                   *
% *                                                             *
% * History:                                                    *
% *         (2) new code for compiled version which is also     *
% *             efficient when no copmpiler is available        *
% *            MD, 5.5.1997, Freiburg                           *
% *         (1) compiled version                                *
% *            MD, 25.3.1997, Freiburg                          *
% *         (0)  first Version                                  *
% *            MD, 23.3.1997, Freiburg                          *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Example:                                                    *
% *                                                             *
% *  t=        lr=                                j=    k=      *
% *     20         21 30                             2     1    *
% *     23         35 45                             3     1    *
% *     29         50 52                             4     1    *
% *     29                                           5     2    *
% *     35                [j,k]=inrange(t,lr)        6     2    *
% *     36                 -------------->           7     2    *
% *     41                                          10     3    *
% *     47                                                      *
% *     47                                                      *
% *     52                                                      *
% *                                                             *
% *                                                             *
% *                                                             *
% * t=[20 23 29 29 35 36 41 47 47 52]';                         *
% * lr=[21 30; 35 45; 50 52];                                   *
% ***************************************************************

compiled=1;


if ~compiled
 m=rows(lr);
 n=length(t);
 v = copy(col(t),1,m);
 b = v>=copy(row(lr(:,1)),n,1) & v<=copy(row(lr(:,2)),n,1);
 [j,k]=find(b); 
else
 m=rows(lr);
 n=length(t);
 j=zeros(n,1);
 k=zeros(n,1);
 l=0;

 for v=1:m
  u  = find(t>=lr(v,1) & t<=lr(v,2));
  ul = length(u);
  
  j(l+1:l+ul)=u;
  k(l+1:l+ul)=repmat(v,ul,1);
  l=l+ul;
 end
 j=j(1:l);
 k=k(1:l);

end


% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% completely resolved version
% 
%
%
% m=rows(lr);
% n=length(t);
% j=zeros(n,1);
% k=zeros(n,1);
% l=0;
% for u=1:n
%  for v=1:m
%   if t(u)>=lr(v,1) & t(u)<=lr(v,2)
%    l=l+1;
%    j(l)=u;
%    k(l)=v;
%   end
%  end
% end
% j=j(1:l);
% k=k(1:l);


