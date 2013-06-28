function lp =logP(px,lambda)
% lp=logP(x,lambda), joint-surprise of x or more occurrences,
%                    given lambda
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         x, number of occurrences                            *
% *    lambda, mean of assumed Poisson distribution             *
% *         lp, log of probability (joint-surprise)             *
% *             of getting x or more occurrences                *
% *             given Poisson distribution with mean lambda     *
% *             RETURNs the same orientation as the input vectors *
% *                                                             *
% * NOTE  : if jp_val == 0, thus logP would be inf,             *
% *         the maximum is set to 20,-20 (SG, 3.9.98)           *
% *                                                             *	    
% * See Also:                                                   *
% *      Fpoisscdf(),exp_j_prob(),jp_val.m                      *
% *                                                             *
% * Uses:                                                       *
% *      jp_val.m                                               *
% *                                                             *
% * Bugs:                                                       *
% *       			                                *
% *                                                             *
% * History:                                                    *
% *         (1) comments improved, in case of logP==inf,        *
% *             logP set to 20 ; in case of logP==-inf,         *
% *             set to -20                                      *
% *            SG, 6.10..98, FfM                                * 
% *         (0) first version                                   *
% *            SG, 25.2.96                                      *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih-frankfurt,mpg.de        *
% *                                                             *
% ***************************************************************


if nargin == 2
 p  = jp_val(px, lambda);

 idx = find(p>0 & p ~=1);
 if ~isempty(idx)
   lp(idx) = log10((1-p(idx))./p(idx));
 end
 
 idx = find(p==1);
 if ~isempty(idx)
   lp(idx) = -20+zeros(size(p(idx)));
 end
 
 idx = find(p==0);
 if ~isempty(idx)
   lp(idx) = 20+zeros(size(p(idx)));
 end
 
 if ~rowvec(px)
  lp = lp';
 end
elseif nargin == 1

  idx=find(px~=0 & px ~=1);
  
  lp(idx) = [log10((1-px(idx))./px(idx))]';

  idx=find(px==1);
  
  lp(idx)=-20*ones(size(idx));  % p==1 => lp= -Inf

  idx=find(px==0);
  
  lp(idx)=20*ones(size(idx));    % p==0 => lp = Inf

  lp=reshape(lp,size(px));
  
end








