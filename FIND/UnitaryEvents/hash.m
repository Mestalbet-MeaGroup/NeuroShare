function h=hash(v,n,basis)
% h=hash(v,n,basis), returns decimal value of basis representation v, n==cols(v)
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, row vector or matrix with basis representation     *
% *          of h using n digits. The leftmost element v(1)     *
% *          is assumed to contain digit with highest           *
% *          significance:                                      *
% *             digit:            v(1),  ...     v(n)           *
% *            factor:     basis^(n-1),  ...  basis^0           *
% *       n, total number of digits of basis representation     *
% *       h, scalar or col vector of hash values                *
% *                                                             *
% * The following invariant holds:                              *
% *                                                             *
% *          v==inv_hash(hash(v,cols(v)),cols(v))               *
% *                                                             *
% * See Also:                                                   *
% *           inv_hash()                                        *
% *                                                             *
% * Uses:                                                       *
% *       copy(), rows(), cols(), rsum()                        *
% *                                                             *
% *                                                             * 
% * History:                                                    *
% *         (3) optimized for base==2                           *
% *            MD, 11.5.1997                                    *
% *         (2) bug for patterns of length 1 removed            *
% *             If v is a row vector sum(v) returns the sum of  *
% *             all elements! sum replaced by rsum.             *
% *            MD, 20.2.1997                                    *
% *         (1) rewritten for row matrix of basis               *
% *             representations                                 *
% *            MD, 19.2.1997                                    *
% *         (0) first matlab version                            *
% *             (rewritten from IDL hash.pro)                   *
% *            SG, 8.2.1996                                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% * Note:                                                       *
% *      it looks as if function bitset used like:              *
% *                                                             *
% *  h=  sum(...                                                *
% *             bitset(...                                      *
% *                    zeros(size(v)),...                       *
% *                    repmat(n:-1:1,size(v,1),1),...           *
% *                    v...                                     *
% *                   ),...                                     *
% *              2...                                           *
% *            )                                                *
% *                                                             *
% * should improve the performance. However, bitset is not      *
% * implemented as a lowlevel operator and has a very poor      *
% * performance.                                                *
% * matlab function bin2dec is implemented using the same       *
% * algorithm as our routine.                                   *
% *                                                             *
% * Examples:                                                   *
% *                                                             *
% *  >> hash([1 0 1],3)                                         *
% *  ans =                                                      *
% *        5                                                    *
% *                                                             *
% *  >> hash([0 0 1 0 1;0 1 0 0 1],5)                           *
% *  ans =                                                      *
% *        5                                                    *
% *        9                                                    *
% *                                                             *
% *  >> hash([1 0]',1)                                          *
% *  ans =                                                      *
% *        1                                                    *
% *        0                                                    *
% *                                                             *       
% *                                                             *
% ***************************************************************
           

if cols(v)~=n
 error('Hash::NotEnoughDigits');
end

if basis==2
 h=sum(v.*repmat(pow2((n-1):-1:0),size(v,1),1),2);
else
 h=rsum(v.*copy(basis.^((n-1):-1:0),rows(v),1));
end


% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% Sonja's 8.2.1996 implementation
%
%
%basis		= 2;
%hash_val	= 0;
%
%n_ele		= n_elements(array(:));
%if n_ele == n
% for i=1:n
%  hash_val = hash_val + array(i)*basis^(n-i);
% end
%else
% '>> Check number of vector elements; output is set to -1! <<'
% hash_val	=-1;
%end
