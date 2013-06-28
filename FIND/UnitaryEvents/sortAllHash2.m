function [s,v,ss] = sortAllHash2(n,basis,m)
% [s,v,ss] = sortAllHash2(n,basis,m): sorted hashs for all patterns up
% to n digits with minimum m spikes
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       n, total number of digits of basis representation     *
% *       basis, basis for hash respresentation                 *
% *       m, mimimum number of spikes per pattern
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
% *                                                             *
% *                                                             *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************
% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% * >> [s,v,ss]=sortAllHash2(4,2,3)                             *
% *                                                             *
% * s =
% *
% *     7
% *    11
% *    13
% *    14
% *    15
% *
% * v =
% *
% *     0     1     1     1
% *     1     0     1     1
% *     1     1     0     1
% *     1     1     1     0
% *     1     1     1     1
% *
% * ss =
% *
% *     3
% *     3
% *     3
% *     3
% *     4 
% ***************************************************************

ah = allHash(n);
ih = inv_hash(ah,n,basis);
ss = sum(ih,2);               % sum along rows

% take only patterns of equal m or more spikes
index = find(ss>=m);
ss    = ss(index);
ah    = ah(index);
ih    = ih(index,:);

% sort according to spike sum
[sortsum,sortindex]=sort(ss);

s     = ah(sortindex);
v     = ih(sortindex,:);
ss    = ss(sortindex);












