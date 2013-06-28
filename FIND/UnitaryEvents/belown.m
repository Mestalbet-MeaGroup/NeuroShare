function i=belown(n)
% i=belown(n), returns linear index of v(j,k) where j<=n(k), v max(n)xlength(n)
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *         n,  vector specifying the number n(k) of elements   *
% *             in column k. At the same time it specifies      *
% *             the size of the belown matrix v                 *
% *             max(n)xlength(n).                               *
% *                                                             *
% *         i, column vector of length sum(n) containing the    *
% *            linear indices of all elements v(j,k) where      *
% *            j<=n(k).                                         *
% *                                                             *
% * See Also:                                                   *
% *           viewbelown                                        *
% *           repeat, reiterate                                 *
% * Uses:                                                       *
% *           copy                                              *
% *                                                             *
% * History:                                                    *
% *         (1) checked for degenerate case, error message      *
% *             introduced                                      *
% *            MD, 17.2.1997, Jerusalem                         *
% *         (0) first Version                                   *
% *            MD, 11.12.1996, Freiburg                         * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% * Example:                                                    *
% *          n=[5 2 3];                                         *
% *                                                             *
% * Now, imagine a max(n)xlength(n) matrix, where in each       *
% * column k has the first n(k) (row) entries are filled with   *
% * 1s. The rest of the matrix contains 0s.                     *
% *                                                             *
% * Such a matrix is returned by viewbelown(n):                 *
% *                                                             *
% *                1     2  length(n)                           *
% *                ------------>                                *
% *         1   |  1     1     1                                *
% *             |  1     1     1                                *
% *             |  1     0     1                                *
% *             |  1     0     0                                *
% *     max(n)  v  1     0     0                                * 
% *                                                             *
% *                                                             *
% * below(n) returns the linear index i of all elements in this *
% * matrix containining a 1.                                    *
% *                                                             *
% *  belown(n)':                                                *
% *                                                             *
% *         1 2 3 4 5    6 7    11 12 13                        *
% *                                                             *
% * This is achieved by comparing two max(n)xlength(n)          *
% * matrices. The first one counts rows in its columns,         *
% * the second contains at all positions in a column the number *
% * of 1s in the corresponding column of the belown matrix:     *
% *                                                             *
% *                                                             *
% *      1  1  1       5  2  3                                  *
% *      2  2  2       5  2  3                                  *
% *      3  3  3   <=  5  2  3                                  *
% *      4  4  4       5  2  3                                  *
% *      5  5  5       5  2  3                                  *
% *                                                             *
% *                                                             *
% ***************************************************************


if ~strcmp(orientation(n),'row') & ~strcmp(orientation(n),'none')
 error('Belown::ArgumentNotRowVector');
end

mx=max(n);
i=col(find(copy((1:mx)',1,length(n))<=copy(n,mx,1)));



% ***************************************************************
% *                                                             *
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% trial implementation
%
%nn=length(n);
%mx=max(n);
%z1=copy((1:mx)',1,nn);
%z2=copy(n,mx,1);
%i=find(z1<=z2);
