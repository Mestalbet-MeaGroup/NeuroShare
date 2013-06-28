function jp=jp_val(Nact,Nexp)
% jp=jp_val(Nact,Nexp): joint-P-value
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         Nact, number of occurrences                         *
% *         Nexp, mean of assumed Poisson distribution          *
% *         jp, joint-P-value                                   *
% *            if Nact=0, Nexp ~=0 : jp = 1                     *
% *            if Nexp=0, Nact ~=0 : jp = 0
% *            if Nexp=0 and Nact=0: jp = 1
% *         if only Nact is given, it is interpreted as p       *
% *         which is then used to compute jp                    *
% *                                                             *
% * NOTE  :                                                     *
% *                                                             *	    
% * See Also: jointSurprise.m (same as logP.m)                  *
% *                                                             *
% *                                                             *
% * Uses: gammainc.m                                            *
% *                                                             *
% *                                                             *
% * Bugs:                                                       *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (1) direct input for p added                        *
% *             SG, 7.5.99 FfM                                  *
% *         (0) NEW VERSION using gamma incomplete              *
% *             see also Memo by MD from 19-3-99                *
% *            SG, 23-3-99 MD                                   *
% *         (2) jointP-value on the basis of jointSurprise.m    *
% *             using gammainc.m                                *
% *             SG, 11-12-99                                    * 
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************
if nargin==2
 jp=gammainc(Nexp,Nact);
elseif nargin==1
 jp=Nact;
end


%if p >= 1-eps
% j= -Inf;
%else
% j= log10(1-p)-log10(p);
%end











