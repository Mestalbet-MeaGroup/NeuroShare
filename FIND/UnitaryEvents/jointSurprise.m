function j=jointSurprise(Nact,Nexp)
% j=jointSurprise(Nact,Nexp): joint-surprise
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         Nact, number of occurrences                         *
% *         Nexp, mean of assumed Poisson distribution          *
% *         j, joint-surprise
% *                                                             *
% * NOTE  :                                                     *
% *                                                             *	    
% * See Also: jointP.m,                                     *
% *                                                             *
% *                                                             *
% * Uses:                                                       *
% *                                                             *
% *                                                             *
% * Bugs:                                                       *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (0) NEW VERSION using gamma incomplete 
% *             see also Memo by MD from 19-3-99            
% *            SG, 23-3-99 MD                                   *
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************

p=gammainc(Nexp,Nact); 

if p >= 1-eps
 j= -Inf;
else
 j= log10(1-p)-log10(p);
end











