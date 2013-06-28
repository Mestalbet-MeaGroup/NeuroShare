function p=jp_val(x,lambda)
% p=jp_val(x,lambda), probability of x or more occurrences, given poisson pdf(lambda)
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         x, number of occurrences                            *
% *    lambda, mean of assumed Poisson distribution             *
% *         p, probability of getting x or more occurrences     *
% *            given Poisson distribution with mean lambda      *
% *                                                             *
% * NOTE  : if joint-p-value of x is to be calculated, i.e.     *
% *         area from x on upward, i.e. here only to take       *
% *         up to x-1                                           *
% *                                                             *	    
% * See Also:                                                   *
% *           exp_j_prob()                                      *
% *                                                             *
% * Uses:                                                       *
% *      Fpoisscdf()                                            *
% *                                                             *
% * Bugs:                                                       *
% *       - confusing comments ?!?!                             *
% *                                                             *
% * History:                                                    *
% *         (3) now using Fpoisscdf() as a replacement for      *
% *             poisscdf() because poisscdf(x,l) fails for      *
% *             x with all elements zero.                       *
% *            MD, 23.2.1997, Jerusalem                         *            
% *         (2) checked for vector x, comments improved,        *
% *             examples added                                  *
% *            MD, 19.2.1997                                    *
% *         (1) now using matlab's poisscdf                     *
% *            SG, 19.12.96, Freiburg                           *
% *         (0) first version                                   *
% *            SG, 25.2.96                                      *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% *  >> jp_val(8,5)                                             *
% *  ans =                                                      *
% *        0.1334                                               *
% *                                                             *
% *  >> jp_val(2,5)                                             *
% *  ans =                                                      *
% *        0.9596                                               *
% *                                                             *
% *  >> jp_val([8 2]',5)                                        *
% *  ans =                                                      *
% *        0.1334                                               *
% *        0.9596                                               *
% *                                                             *
% *  >> jp_val([8 2]',[5 3]')                                   *
% *  ans =                                                      *
% *        0.1334                                               *
% *        0.8009                                               *  
% ***************************************************************

Implementation='new'; % 'new', 'IDLVersion'

switch Implementation

 case 'new'
  p = 1 - Fpoisscdf(x-1,lambda);
 case 'IDLVersion'
  p=zeros(length(x),1);
  for j=1:length(x)
   sum = 0;
   for i=0:x(j)-1
    sum = sum + IDLpoisson(lambda(j), i);
   end
   p(j) = 1 - sum;
   if ((p(j) <= 0) & (x ~= 0)) p(j) = 10^(-10); end
   if ((p(j) <= 0) & (x == 0)) p(j) = -1; end
  end
                   
 otherwise
  error('JpVal::UnknownImplementation');
end



% ENDIF ELSE BEGIN                   ; calculate by normal distribution
%   sum = DOUBLE(0)
%   FOR i=LONG(0), r0-1 DO BEGIN
%    sum = sum + normal(p, N_exp, i)
%   ENDFOR
%   p_value = double(1) - sum
% ENDELSE

% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************


%
% Sonja's 25.2.1996 implementation
%
%for j=1:length(x)
%N_emp=x(j);
%N_exp=lambda(j);
%tmp_arr = zeros(N_emp,1);
%tmp_arr(1) = 1;
%f = 1;
%for i=1:N_emp-1
%  f = f*(N_exp/i);
%  tmp_arr(i+1,1) = f;
%end
%tmp_arr = exp(-N_exp)*tmp_arr(:,1) ;
%jp_val = 1. - sum(tmp_arr(:,1));
%
%if ((jp_val <= 0.) & (N_emp ~= 0.))
% jp_val = 10^(-10)			;
%end
%if ((jp_val <= 0.) & (N_emp == 0.))
% jp_val = -1.				;
%end
%p(j)=jp_val;
%end
%p=p';


