function w=initialize(i,d)
% w=initialize(i,d), 
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *                                                             *
% * See Also:                                                   *
% *                                                             *
% * History:                                                    *
% *         (1) orientation forced                              *
% *            MD, 21.1.1997, Jerusalem                         *
% *         (0) first Version                                   *
% *            MD, 18.2.1997, Jerusalem                         * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

w=zeros(rows(i),cols(i));
w(i)=d; % deletes w, comment on assign(v,i,d) funct



