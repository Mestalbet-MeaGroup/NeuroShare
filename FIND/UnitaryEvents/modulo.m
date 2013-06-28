function [i,r] = modulo(number, divisor)
% [i,r]=modulo(number, divisor), return remainder (and integer part) of division
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       i, if none or one return value the remainder of the   *
% *          division, i has the same orientation as the result *
% *          of number./divisor.                                *
% *   [i,r], if two return values i is the integer part         *
% *          and r the remainder of the division, both have the *
% *          same orientation as the result of number./divisor  *
% *                                                             *
% * Uses:                                                       *
% *       rem(), fix()                                          *
% *                                                             *
% * History:                                                    *
% *         (1) integer part as optional return value and       *
% *             examples added                                  *
% *            MD 18.2.1997                                     *
% *         (0) first Version                                   *
% *            SG 17.3.1996                                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% *  >> mod([7 8 9],3)                                          *
% *  ans =                                                      *
% *        2     2     3                                        *
% *                                                             *
% *  >> [i,r]=mod([7 8 9],[3 3 3])                              *
% *  i =                                                        *
% *      2     2     3                                          *
% *  r =                                                        *
% *      1     2     0                                          *
% *                                                             *
% *  >> [i,r]=mod([7 8 9],3)                                    *
% *  i =                                                        *
% *      2     2     3                                          *
% *  r =                                                        *
% *      1     2     0                                          *
% *                                                             *
% *  >> [i,r]=mod([7 8 9]',3)                                   *
% *  i =                                                        *
% *     2                                                       *
% *     2                                                       *
% *     3                                                       *
% *  r =                                                        *
% *     1                                                       *
% *     2                                                       *
% *     0                                                       *
% *                                                             *
% ***************************************************************

if nargout>1
 i=fix(number./divisor);
 r=number-divisor.*i;
else
 i=rem(number, divisor);
end

