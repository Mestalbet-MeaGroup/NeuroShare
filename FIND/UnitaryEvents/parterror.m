function e=parterror(f,t,d,i)
% parterror,  display part, partindex errors
% ***************************************************************
% *  In version 4 matlab does not support mult-dimensional      *
% *  matrices. Here we extend matrix access to 3 dimensions     *
% *                                                             *
% * Usage:                                                      *
% *        f string containing name of function where error     *
% *          occurred                                           *
% *        t string specifying type of error:                   *
% *            'range'                                          *
% *            'shape'                                          *
% *            'arguments'                                      *
% *            'linear'                                         *
% *        d string describing dimension of matrix              *
% *             '1d', '2d', '3d'                                *
% *        i string specifying out of range index               *
% *             'i', 'j', 'k'                                   *
% *                                                             *
% * See Also:                                                   *
% *           part, partindex                                   *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (2) message for linear indices added                *
% *            MD, 11.12.1996, Freiburg                         *
% *         (1) new parameters f, t, d, i                       *
% *            MD, SG, 26.11.1996, Jerusalem                    *
% *         (0) first Version                                   *
% *            MD, SG 22.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************
%
%
% 

disp(['Error in:         ',f]);

if strcmp(t,'range')
 disp(['Matrix Dimension: ',d]);
 disp(['   Index ',i,' exceeds range']);
elseif strcmp(t,'shape')
 disp(['Matrix Dimension: ',d]);
 disp( '   Matrix has unexpected shape'); 
elseif strcmp(t,'arguments')
 disp( '   Wrong number of arguments');
elseif strcmp(t,'linear')
 disp( '   Linear index exceeds total number of elements');
elseif strcmp(t,'row')
 disp( '   Linear index exceeds total number of elements');
elseif strcmp(t,'col')
 disp( '   Linear index exceeds total number of elements');
end

error('returning to keyboard...');
