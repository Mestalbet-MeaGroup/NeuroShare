function b=matrix(v)
% b=matrix(v), true if v is a m x n matrix, n,m > 1
% ***************************************************************
% *                                                             *
% * History:                                                    *
% *         (0) first Version                                   *
% *            MD, 31.1.1997, Freiburg                          * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************
%
%
%
b= cols(v)>1 & rows(v)>1;