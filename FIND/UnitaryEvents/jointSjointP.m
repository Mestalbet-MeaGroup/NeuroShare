function [j,p]=jointSjointP(Nact,Nexp)
% j=jointSurprise(Nact,Nexp): joint-surprise
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         Nact, number of occurrences                         *
% *         Nexp, mean of assumed Poisson distribution          *
% *         j, joint-surprise                                   *
% *                                                             *
% * NOTE  :                                                     *
% *                                                             *	    
% * See Also: jointP.m,                                         *
% *                                                             *
% *                                                             *
% * Uses:                                                       *
% *                                                             *
% *                                                             *
% * Bugs:                                                       *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (0) NEW VERSION using gamma incomplete              *
% *             see also Memo by MD from 19-3-99                *
% *            SG, 23-3-99 MD                                   *
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************
if nargin ==2
 % this is the joint-p-value
 p=gammainc(Nexp,Nact);
elseif nargin==1 % if p is given directly
 p = Nact;
end 

if p >= 1-eps
 j= -Inf;
else
 j= log10(1-p)-log10(p);
end
