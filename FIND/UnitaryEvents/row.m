function [w,b]=row(v)
% [w,b]=row(v), returns v as a row vector,(optional b=rowvec(v)==1)
% ***************************************************************
% *                                                             *
% * Input:  v: vector                                           *
% *                                                             *
% * Output: w: row vector of v                                  *
% *         b: marker (b=rowvec(v)==1)                          *
% *                                                             *
% * Uses:   rowvec()                                            *
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


w=reshape(v,1,elements(v));

if nargout==2
 b=rowvec(v);
end