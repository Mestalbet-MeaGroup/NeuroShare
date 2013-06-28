function b=rowvec(v)
% b=rowvec(v), true if v is a 1 x n matrix
% ***************************************************************
% *                                                             *
% * Input:  v: vector                                           *
% *                                                             *
% * Output: b: return value (true, if v is row vector)          *
% *                                                             *
% * Uses:   rows()                                              *
% *                                                             *
% * Note,   rowvec==1 for a 1x1 matrix (a scalar) to allow for  *
% *         the degenerate case of a row vector with only       *
% *         one element.                                        *
% *                                                             *
% * History:                                                    *
% *         (0) first Version                                   *
% *            MD, 30.1.1997, Freiburg                          *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

b= rows(v)==1;
