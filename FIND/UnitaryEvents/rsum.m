function s=rsum(v)
% s=rsum(v), returns col vector with sum over rows of matrix v
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, matrix of data organized in rows                   *
% *       s, col vector containing sum over rows of v           *
% *           length(s)==rows(v)                                *
% *                                                             *
% * NOTE:  csum is more efficient than rsum.                    *
% *        rsum involves two additional tranpose operations     *
% *                                                             *
% * See Also:                                                   *
% *           sum()                                             *
% *                                                             *
% * Uses:                                                       *
% *       csum()                                                *
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
           
s=csum(v')';




