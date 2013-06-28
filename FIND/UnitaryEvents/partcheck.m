function e=partcheck(i,n)
% partcheck, range check index i for use in part
% ***************************************************************
% *  In version 4 matlab does not support mult-dimensional      *
% *  matrices. Here we extend matrix access to 3 dimensions     *
% *                                                             *
% * matrices are stored in column first ordere,                 *
% * "leftmost index grows fastest".                             * 
% *                                                             *
% * See also:                                                   *
% *           part, partindex                                   *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (0) first Version                                   *
% *            MD, SG 25.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************
%
%
%

if isstr(i)
 if strcmp(i,':') 
  e=1:n;
 else
  disp('partcheck: ":" expected');
 end
elseif i<=n
  e=i;
else
  e=0;
end