function w=copy(v,m,n)
% copy(v,m,n), returns matrix v copied m x n times
% ***************************************************************
% *                                                             *
% * OBSOLETE! REPLACED BY MORE GENERAL REPMAT FUNCTION          *
% *                                                             *
% * Usage:                                                      *
% *             v, matrix                                       *
% *             m, number of times v should be copied in row    *
% *                direction                                    *
% *             n, number of times v should be copied in        *
% *                column direction                             *
% *             w, resulting matrix of size                     *
% *                  m*rows(v) x n*cols(v)                      *
% * Uses:                                                       *
% *      rows, cols, repetition(v,n)                            * 
% *               !!!NOTE, repetition(v,n,l) is implemented     *
% *                  by copy!!!                                 *
% * See Also:                                                   *
% *          partition, repetition                              *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (3) updated for matlab 5                            *
% *            MD, 30.4.1997, Freiburg                          *
% *         (2) support for compiled version added              *
% *            MD, 1.4.1997, Freiburg                           * 
% *         (1) orientation strings introduced to handle        *
% *             degenerate case scalar(v)==1.                   *
% *            MD, 5.2.1997, Freiburg                           *
% *         (0) first Version                                   *
% *            MD, SG 29.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************
%
%
%

w=repmat(v,m,n);


% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
%  
%  matlab 4 version:
%
%
%compiled=0;
%if ~compiled
% w=v(repetition(1:rows(v),m,'row'), repetition(1:cols(v),n,'row'));
%else
% mv=size(v,1);
% nv=size(v,2);
% w=zeros(mv*m,nv*n);
% mmv=(m-1)*mv;
% mnv=(n-1)*nv;
%
% for iv=1:mv
%  for jv=1:nv
%   ev=v(iv,jv);
%   for i=iv+0:mv:iv+mmv
%    for j=jv+0:nv:jv+mnv 
%     w(i,j)=ev;
%    end
%   end
%  end
% end
%end
%
%
%
% v=[4 5 6; 7 8 9];





