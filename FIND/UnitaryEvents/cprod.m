function p=cprod(v)
% s=cprod(v), returns row vector with prod over cols of matrix v
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, matrix of data organized in cols                   *
% *       p, row vector containing prod over cols of v          *
% *           length(p)==cols(v)                                *
% *                                                             *
% * NOTE: this is not matlab's prod()! If v is a row vector     *
% *       (1xn) matrix prod(v) returns the prod of the elements *
% *       in v. cprod(v) returns v. See examples below.         *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *           rprod()                                           *
% *                                                             *
% * Uses:                                                       *
% *       rows(), prod()                                        *
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
           

if rows(v)==1
 p=v;
else
 p=prod(v);
end



