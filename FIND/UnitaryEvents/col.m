function [w,b]=col(v)
% [w,b]=col(v), returns v as a column vector,
% (optional b=colvec(v)==1)
% ***************************************************************
% *                                                             *
% * Input:  v: inputvector                                      *
% *                                                             *
% * Output: w: outputvector                                     *
% *         b: marker if cols(v)==1                             *
% *                                                             *
% * Uses:   cols()                                              *
% *                                                             *
% * History:                                                    *
% *         (1) function colvec() no longer used                *
% *             content of colvec() (b= cols(v)==1) is now      *
% *             explicitly executed                             *
% *            PM, 7.8.02, FfM                                  *
% *         (0) first Version                                   *
% *            MD, 31.1.1997, Freiburg                          * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

w=reshape(v,elements(v),1);

if nargout==2
 %b=colvec(v);
 b = cols(v)==1;
end
