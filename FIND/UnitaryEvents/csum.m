function s=csum(v)
% s=csum(v), returns row vector with sum over cols of matrix v
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, matrix of data organized in cols                   *
% *       s, row vector containing sum over cols of v           *
% *           length(s)==cols(v)                                *
% *                                                             *
% * NOTE: this is not matlab's sum()! If v is a row vector      *
% *       (1xn) matrix sum(v) returns the sum of the elements   *
% *       in v. csum(v) returns v. See examples below.          *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *           rsum()                                            *
% *                                                             *
% * Uses:                                                       *
% *       rows(), sum()                                         *
% *                                                             * 
% * History:                                                    *
% *         (0) first version                                   *
% *            MD, 20.2.1997, Jerusalem                         * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% *  >> csum([4 5 6; 7 8 9])      >> rsum([4 5 6; 7 8 9])       *
% *  ans =                        ans =                         *
% *        11    13    15               15                      *
% *                                     24                      *
% *                                                             *
% *  >> csum([4 5 6])             >> rsum([4 5 6])              *
% *  ans =                        ans =                         *
% *         4     5     6               15                      *
% *                                                             *
% *  >> csum([4;7])               >> rsum([4;7])                *
% *  ans =                        ans =                         *
% *        11                            4                      *
% *                                      7                      *
% *                                                             *       
% *                                                             *
% ***************************************************************
           

if rows(v)==1
 s=v;
else
 s=sum(v);
end



