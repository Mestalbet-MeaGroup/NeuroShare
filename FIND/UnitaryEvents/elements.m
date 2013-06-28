function s=elements(v)
% s=elements(v), returns total number of elements in matrix v
% ***************************************************************
% *                                                             *
% * Uses:                                                       *
% *      prod                                                   *
% *                                                             *
% * See Also:                                                   *
% *          rows, cols, dsize3d, size                           *
% *                                                             *
% * History:                                                    *
% *         (0) first Version                                   *
% *            MD, SG 28.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

s=prod(size(v));
