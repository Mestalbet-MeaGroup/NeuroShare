function vn=reiterate(v,n)
% vn=reiterate(v,n), v col vector returns elements [v(1:n(1)), v(1:n(2)), ...]
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         v,  column vector of data                           *
% *         n,  vector specifying length of iterations n(i)     *
% *         vn, column vector of length sum(n)                  *
% *                                                             *
% * See Also:                                                   *
% *           repeat                                            *
% * Uses:                                                       *
% *           copy, belown, part                                *
% *                                                             *
% * History:                                                    *
% *         (0) first Version                                   *
% *            MD, 11.12.1996, Freiburg                         * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% * Example:                                                    *
% *          v=[20 21 22 23 24 25];                             *
% *                                                             *
% *          w=reiterate(v',[5 2 3])';                          *
% *                                                             *
% *          w == [20 21 22 23 24   20 21   20 21 22]           *
% *                                                             *
% *                      5            2        3   times        *
% *                                                             *
% *                                                             *
% *                                                             *
% ***************************************************************

% v=1, n= [1 1 0 0]'

compiled=0;

if ~compiled

 vn=col(part(copy(v(1:max(n)),1,length(n)),belown(n),'linear'));

else

 s=sum(n);
 if size(v,2)==1
  vn=zeros(s,1);
 else
  vn=zeros(1,s);
 end
 nn=length(n);
 l=0;
 for i=1:nn
  for j=1:n(i)
   vn(l+j)=v(j);
  end
  l=l+n(i);
 end

end


% ***************************************************************
% *                                                             *
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************


%
% trial implementation
%
%nn=length(n);
%mx=max(n);
%c=copy(v(1:mx),1,nn);
%i=belown(n);
%vn=c(i);
