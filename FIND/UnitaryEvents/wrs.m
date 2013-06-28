function h=wrs(f,g)
% h=wrs(f,g),  weighted running sum based on partition
%
%
% ***************************************************************
% *                                                             *
% * Usage (Input,Output):                                       *
% *                                                             *
% *        f,  row data vector or matrix of rows of data        *
% *        g,  row vector representing weighting function       *
% *            length(g)<=cols(f)                               *
% *        h,  weighted running sum                             *
% *            length(h) == cols(f) - (length(g)-1)             *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *           cnv                                               *
% *                                                             *
% *                                                             *
% * Literature:                                                 *
% *     [1] Bracewell, Ronald                                   *
% *         "The Fourier Transform and its Applications"        *
% *         McGraw-Hill 1986                                    * 
% *         ISBN 0-07-066454-4                                  *
% *         24pp                                                *
% *                                                             *
% * Future:                                                     *
% *        - optional implementation with for loop for          *
% *          compiled version.                                  *
% *            18.3.1997, SR experience with Mathematica        *
% *            winter 1996, SR, MD  discussion about binloop    *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *         (3) new algorithm with loop to conserve memory      *
% *             and optimization for compiled version           *
% *            MD, 1.10.1997, Marseille                         *
% *         (2) support for matrix of rows of data added        *
% *            MD, 16.2.1997, Jerusalem                         *
% *         (1) comments improved                               *
% *            MD, 9.12.1996, Freiburg                          *
% *         (0) first Version                                   *
% *            MD, SG 19.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% * Examples:                                                   *
% *                                                             *
% * The basic weighted running sum. Only results for fully      *
% * overlapping windows are computed. It is assumed that        *
% * g is the weighting function and length(g)<=cols(f).         *
% * wrs is not symmetrically in f and g. wrs is not interpreted *
% * as the physical operation of a filter (index space inter-   *
% * preted as time), hence g is not reversed here.              *
% *                                                             *
% * See cnv for an implementation of convolution (filtering,    *           
% * Faltung) using this algorithm.                              *
% *                                                             *
% *                                                             *
% *                                                             * 
% *    >> wrs([2 2 3 3 4], [2 1 1])                             *
% *    ans =                                                    *
% *          9    10    13                                      *
% *                                                             *
% *    >> wrs([0 0 2 2 3 3 4 0 0], [2 1 1])                     *
% *    ans =                                                    *
% *          2     4     9    10    13    10     8              *
% *                                                             *
% *                                                             *
% * wrs allows to process several data vectors with the same    *
% * weighting function simultaneously. f then is a matrix of    *
% * of rows of data:                                            *
% *                                                             *
% *    >> d=[4 5 6 7 8; 10 11 12 13 14]                         *
% *    d =                                                      *
% *         4     5     6     7     8                           *
% *        10    11    12    13    14                           *
% *                                                             * 
% *    >> wrs(d,[1 1])                                          *
% *    ans =                                                    *
% *          9    11    13    15                                *
% *         21    23    25    27                                *   
% *                                                             *      
% ***************************************************************
%

c=size(f,2)-size(g,2)+1;    % number of window positions
r=size(f,1);                % number of rows
d=0:(size(g,2)-1);          % relative window indices
g=g';                       % g col vector
h=zeros(r,c);               % allocate result matrix

for i=1:c
  h(:,i)=f(:,i+d)*g;
end


% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************


%           dimension along  ------      ---- size of 3rd dimension 
%           which to multiply     |      |    of partition matrix
%                                 v      v
% h=mult3d(partition(f,length(g),1),3,g',rows(f))';


%
% original implementation for one row (a row vector of data)
%
%h=(partition(f,length(g),1)*g')';
