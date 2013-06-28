function [s,v,ss] = sortAllHash3(n,basis,minc,maxc)
% [s,v,ss] = sortAllHash3(n,basis,minc,maxc): sorted hashs for all patterns up
% to n digits with minimum minc  and maximum maxc spikes
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       n    , total number of digits of basis representation *
% *       basis, basis for hash respresentation                 *
% *       m    , mimimum number of spikes per pattern
% *       minc , minimal complexity required 
% *       maxc , maximal complexity required
% *                                                             *
% * output: s : sorted hash numbers according to number of 1's  *
% *             for n possible 0,1 positions                    *
% *         v : matrix of sorted 0,1 vectors                    *
% *         ss: sorted spike sums per pattern                   *
% *                                                             *
% * See Also:  hash()                                           *
% *                                                             *
% *                                                             *
% * Uses:                                                       *
% *      inv_hash(), allHash()                                  *
% *                                                             *
% *                                                             * 
% * History:                                                    *
% *         (0) first version                                   *
% *            SG, 13.4.99, FfM                                 * 
% *         (1) give sorted results only for pattern            *
% *             having equal or more than m spikes              *
% *             some bugs from sortAllHash.m repared.           *
% *            SG, 13.8.99, FfM                                 *
% *         (2) extended version of sortAllHash2.m
% *             now with the option to decide on the
% *             minimal and maximal complexity
% *            SG, 22.3.02, FFM
% *                                                             *
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************
% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% * >> [s,v,ss]=sortAllHash3(4,2,2,3)                           *
% *                                                             *
%s =
%     3
%     5
%     6
%     9
%    10
%    12
%     7
%    11
%    13
%    14
%
%
%v =
%     0     0     1     1
%     0     1     0     1
%     0     1     1     0
%     1     0     0     1
%     1     0     1     0
%     1     1     0     0
%     0     1     1     1
%     1     0     1     1
%     1     1     0     1
%     1     1     1     0
%
%ss =
%     2
%     2
%     2
%     2
%     2
%     2
%     3
%     3
%     3
%     3
%
% ***************************************************************

ah = allHash(n);
ih = inv_hash(ah,n,basis);
ss = sum(ih,2);               % sum along rows

if maxc > n 
 error('sortAllHash3::RequestedComplexityNotAvailable')
end
if maxc < minc 
 error('sortAllHash3::NoOverlapOfRequestedComplexity')
end

index = find(ss>=minc & ss<= maxc);

ss    = ss(index);
ah    = ah(index);
ih    = ih(index,:);

% sort according to spike sum
[sortsum,sortindex]=sort(ss);

s     = ah(sortindex);
v     = ih(sortindex,:);
ss    = ss(sortindex);












