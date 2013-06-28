function h=allHash(m)
% h=allHash(m), returns all hash values for (0,1)-patterns for m positions
% ***************************************************************
% *                                                             *
% * Usage:  m: number of positions                              *
% *                                                             *
% * See also: allBinary.m, hash.m, inv_hash.m                   *
% *                                                             *
% *         (0) first version                                   *
% *            SG, 14.5.98, Ffm                                 * 
% *                                                             *
% ***************************************************************

h = 0:(2^m)-1;
h = h'; 