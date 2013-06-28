function p=rprod(v)
% p=rprod(v), returns col vector with prod over rows of matrix v
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, matrix of data organized in rows                   *
% *       p, col vector containing prod over rows of v          *
% *           length(s)==rows(v)                                *
% *                                                             *
% * NOTE:  cprod is more efficient than rprod.                  *
% *        rprod involves two additional tranpose operations    *
% *                                                             *
% * See Also:                                                   *
% *           prod()                                            *
% *                                                             *
% * Uses:                                                       *
% *       cprod()                                               *
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
% *  >> cprod([4 5 6; 7 8 9])      >> rprod([4 5 6; 7 8 9])     *
% *  ans =                        ans =                         *
% *        28    40    54               120                     *
% *                                     504                     *
% *                                                             *
% *  >> cprod([4 5 6])             >> rprod([4 5 6])            *
% *  ans =                        ans =                         *
% *         4     5     6               120                     *
% *                                                             *
% *  >> cprod([4;7])               >> rprod([4;7])              *
% *  ans =                        ans =                         *
% *        28                            4                      *
% *                                      7                      *
% *                                                             *       
% *                                                             *
% ***************************************************************
           
p=cprod(v')';




