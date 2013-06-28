function h=allBinary(v,basis)
% h=allBinary(m), returns all binary patterns for hash-values in v
% ***************************************************************
% *                                                             *
% * Usage:  v    : vector of hash-values                        *
% *         basis: default ==2; not implemented yet for others  *
% *                                                             *
% *  returns: matrix of binary patterns; each row corresponds   *
% *           to one hash value                                 *
% *                                                             *
% * See also: allHash.m, hash.m, inv_hash.m                     *
% *                                                             *
% *         (0) first version                                   *
% *            SG, 14.5.98, Ffm                                 * 
% *                                                             *
% ***************************************************************

% ***************************************************************
% *
% * Example: 
% * >> allBinary(1:5)
% * ans =
% *     0     0     1
% *     0     1     0
% *     0     1     1
% *     1     0     0
% *     1     0     1
% ***************************************************************

if colvec(v)~=1
  v = col(v);
end

if nargin == 1
  basis = 2;
end

if basis == 2
 inv_hash(v,ceil(log2(max(v))),basis)
else
 error('allBinary::NotImplementedForGivenBasis');
end

