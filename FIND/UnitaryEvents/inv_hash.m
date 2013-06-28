function v = inv_hash(h,n,basis)
% v=inv_hash(h,n,basis), return basis representation of h as row vector (matrix) 
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       h, scalar or col vector of hash values                *
% *       n, total number of digits of basis representation     *
% *       v, row vector or matrix with basis representation     *
% *          of h using n digits. The leftmost element v(1)     *
% *          contains digit with highest significance:          *
% *                                                             *
% *   digit:             v(1),  ...     v(n)                    *
% *   factor:     basis^(n-1),  ...  basis^0                    *
% *                                                             *
% * The following invariant holds:                              *
% *                                                             *
% *          v==inv_hash(hash(v,cols(v)),cols(v))               *
% *                                                             *
% * See Also:                                                   *
% *           hash()                                            *
% *                                                             *
% * Uses:                                                       *
% *       mod()                                                 *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (2) optimized for basis==2, idea taken from         *
% *             dec2bin                                         *
% *            MD, 11.5.1997, Freiburg                          *
% *         (1) bug removed (highest bit was always 1),         *
% *             rewritten for col vector of hash values         *
% *            MD, 19.2.1997                                    *
% *         (0) first matlab version                            *
% *             (rewritten from IDL inv_hash.pro ??)            *
% *            SG, 7.2.1996 / 15.2.1996                         * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             * 
% *  >> inv_hash([5 7]',4)                                      *
% *  ans =                                                      *
% *        0     1     0     1                                  *
% *        0     1     1     1                                  *
% *                                                             *
% *  >> inv_hash([5 7]',5)                                      *
% *  ans =                                                      *
% *        0     0     1     0     1                            *
% *        0     0     1     1     1                            *
% *                                                             *
% ***************************************************************
        

if ~strcmp(orientation(h),'col') & ~strcmp(orientation(h),'none')
 error('InvHash::ColVectorExpected');
end

if ndigits(max(h),basis) > n
 error('InvHash::HashValueExceedsDigits');
end

if basis==2
 v=rem(floor(h*pow2(1-n:0)),2);
else
 v=zeros(length(h),n);
 for i=1:n
  [v(:,i),h]=modulo(h,basis^(n-i));
 end
end




% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% Sonja's 15.2.1996 implementation
%
%
% i		= 0	;
% diff		= 100	;
% while diff >=0 
%  diff = hash_val-basis^i;
%  i = i+1		;
% end
%
% array		= zeros(1,n)		;
%
% max_exp	= i-2			;
%  diff_old	= hash_val		;	
%  for i=max_exp:-1:0
%   diff_new = diff_old - basis^i	;
%   if diff_new >= 0
%    array(max_exp-i+1) = 1		;
%    diff_old = diff_new			;
%   else array(max_exp-i+1) = 0		;
%   end
%  end




