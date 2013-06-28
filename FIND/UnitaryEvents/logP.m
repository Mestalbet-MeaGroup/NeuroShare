function j=logP(Nact,Nexp)
% j=logP(Nact,Nexp): joint-surprise
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         Nact, number of occurrences                         *
% *         Nexp, mean of assumed Poisson distribution          *
% *         j, joint-surprise                                   *
% *         if only Nact is given, it is interpreted as p       *
% *         which is then used to compute j                     *              % *                                                             *
% * NOTE  :                                                     *
% *                                                             *	    
% * See Also: jointSurprise.m, jp_val.m                         *
% *                                                             *
% *                                                             *
% * Uses:                                                       *
% *                                                             *
% *                                                             *
% * Bugs:                                                       *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (3) check for p>= 1-eps and p < eps included
% *             for vector version;
% *             if p>= 1-eps set to -Inf
% *             if p < eps   set to +Inf
% *             for UEver1.3.8
% *             SG, 16-12-99
% *        
% *         (2) old logP.m substituted by this version,
% *             which is equivalent to jointSurprise.m
% *             SG, 16-12-99, FfM
% *         (1) direct input for p added                        *
% *             SG, 7.5.99 FfM                                  *
% *         (0) NEW VERSION using gamma incomplete              *
% *             see also Memo by MD from 19-3-99                *
% *            SG, 23-3-99 MD                                   *
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************
if nargin==2
 p=gammainc(Nexp,Nact);
elseif nargin==1
 p=Nact;
end


% check for p>= 1-eps and p < eps

idx_p_larger_1_eps = find(p >= 1-eps);
idx_p_smaller_eps  = find(p < eps);

j = zeros(size(p));
if ~isempty(idx_p_larger_1_eps)
  j(idx_p_larger_1_eps)=-Inf;
end

if ~isempty(idx_p_smaller_eps)
  j(idx_p_smaller_eps)=+Inf;
end

idxCompute = ...
  setxor(union(idx_p_larger_1_eps,idx_p_smaller_eps),(1:length(p))');

j(idxCompute)= log10(1-p(idxCompute))-log10(p(idxCompute));


%if p >= 1-eps
% j= -Inf;
%else
% j= log10(1-p)-log10(p);
%end











