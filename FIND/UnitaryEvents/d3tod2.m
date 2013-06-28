function [w,bc]=d3tod2(v,a,b,c)
% [w,bc]=d3tod2(v,a,b,c), collapse dimensions a,b to one 
% dimension, keep dim.c
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v,n specify the source matrix. v is the matrix and    *
% *       n the number of elements in v's first dimension.      *
% *                                                             *
% *       a,b,c specify the role of the 3 old dimensions in the *
% *       new 2d matrix. The dimensions are represented as      *
% *       integers i=1, j=2, k=3, therefore a,b,c an take       *
% *       values between 1 and 3. In the new matrix the first   *
% *       dimension is preserved, the others b,c are collapsed  *
% *       into a single one.                                    *
% *                                                             *
% * Input:  v: source matrix                                    *
% *                                                             *
% *         a,b,c: role of the 3 old dimensions in the new      *
% *                2d matrix                                    *
% *                                                             *
% * Output: w: the resulting 2d matrix                          *
% *            s(a) x s(b)*s(c) with  s=size3d(v,n)             * 
% *                                                             *
% *         bc:(optional) 2 x s(b)*s(c) matrix, providing a     *
% *            translation table to be able to from the new     *
% *            index t go back to the original ones b,c .       *
% *            bc(1,t) is the corresponding index of the b dim. *
% *            bc(2,t) is the corresponding index of the c dim. *
% *                                                             *
% *                                                             * 
% * Uses:   repetrow()                                          *
% *                                                             *
% * History:                                                    *
% *         (6) removed section, that followed                  *
% *             error('D3toD2::CombinationNotSupported');       *
% *             in case of error, function would have           *
% *             terminated anyway                               *
% *            PM, 7.8.02, FfM                                  *
% *         (5) version 5 matrix operations                     *
% *            MD, 4.5.97, Freiburg                             *
% *         (4) repetition() replaced by more specialized       *
% *             repetrow()                                      *
% *            MD, 2.4.1997, Freiburg                           *  
% *         (3) optimization for special case a=1,b=2,c=3       *
% *            MD, 12.3.1997, Freiburg                          *
% *         (2) checked for degenerate cases in all dimensions  *
% *             forced orientation 'row' added for repetition   *
% *            MD, 17.2.1997, Jerusalem                         *
% *         (1) example added                                   *
% *            MD, 11.12.1996, Freiburg                         *
% *         (0) first Version                                   *
% *            MD, SG 28.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% * Example:                                                    *
% *                                                             *
% *  Consider the following matrix                              *
% *                                                             *
% *                   1  2 k                                    *
% *                  ------>                                    *
% *      1|  4  5    14 15    24 25                             *
% *      2|  6  7    16 17    26 27      n=3                    *
% *      3|  8  9    18 19    28 29                             *
% *      4| 10 11    20 21    30 31                             *
% *     j v -------------------------->                         *
% *           1        2        3     i                         *
% *                                                             *
% *  Let's say this is WorkCell format. i specifies the         *
% *  neuron, k the trial, and j the time.                       *
% *                                                             *
% *  Suppose we want to glue consecutive trials one after each  *
% *  other to run an analysis on a long segment of time.        *
% *  This means, that we reduce the 3d matrix to a 2d matrix    *
% *  where we only have neuron and time as dimensions. The      *
% *  time and trial dimensions of the old matrix are collapsed  *
% *  into a single time dimension.                              *
% *                                                             *
% *                w=d3tod2(v,1,2,3,3)                          *
% *                                                             *
% *  The sequence 1,2,3 of dimension specifiers means that the  *
% *  first dimension 1 is preserved and the second and third    *
% *  dimension are collapsed such that along the new dimension  *
% *  the corresponding index of the second dimension in the old *
% *  matrix grows faster than the third one.                    *
% *                                                             *
% *  Here is the above w(i,t). We use i as the first index to   *
% *  indicate that this is our old neuron dimension and t as    *
% *  the new index resulting from collapsing j and k:           *
% *                                                             *
% *                                           t                 *
% *        ---------------------------------->                  *
% *     1|  4   6   8  10   5   7   9  11                       *
% *     2| 14  16  18  20  15  17  19  21                       *
% *     3| 24  26  28  30  25  27  29  31                       *
% *    i v                                                      *
% *                                                             *
% *  the corresponding indices in the old (3d) matrix are:      *
% *                                                             *
% *     j| 1   2    3   4   1   2   3   4                       *
% *     k| 1   1    1   1   2   2   2   2                       *
% *                                                             *
% *  d3tod2 can actually return this matrix as a second return  *
% *  value. This is useful if at a later stage one wants to get *
% *  back from index t to indices j,k                           *
% *                                                             *
% *              [w, jk]=d3tod2(v,1,2,3,3);                     *
% *                                                             *
% *                                                             *
% *                                                             *
% *                                                             *
% ***************************************************************

s=size(v);

if a==1 & b==2 & c==3
 w=reshape(v,s(a)*s(b),s(c))';
else 
 error('D3toD2::CombinationNotSupported');
 
 % historical section, PM, 7.8.02
 %
 %en  = elements(v);
 %ijk=allpositions(v,n);
 %pqn = s(b)*s(c);
 %pq =  zeros(en,2);
 %pq(:,1) = ijk(:,a);
 %pq(:,2) = s(b)*(ijk(:,c)-1) + ijk(:,b);
 %ei =  pq(:,1) + s(a) * (pq(:,2)-1);
 %w  =  zeros(s(a),pqn); 
 %w(ei)=v;
 %
 
end


if nargout > 1
 bc=[repetrow(1:s(a),s(b),s(a)); repetrow(1:s(b),s(a),1) ];   
end


% ***************************************************************
% *                                                             *
% *                  Historical Section                         *
% *                                                             *
% ***************************************************************

%
% last matlab 4 version
% 
%
%s=dsize3d(v,n);
%
%if a==1 & b==2 & c==3
% w=reshape(v,s(b)*s(c),s(a))';
%else 
% en  = elements(v);
% ijk=allpositions(v,n);
% pqn = s(b)*s(c);
% pq =  zeros(en,2);
% pq(:,1) = ijk(:,a);
% pq(:,2) = s(b)*(ijk(:,c)-1) + ijk(:,b);
% ei =  pq(:,1) + s(a) * (pq(:,2)-1);
% w  =  zeros(s(a),pqn); 
% w(ei)=v;
%end
%
%
%if nargout > 1
% bc=[repetrow(1:s(b),s(c),s(b)); repetrow(1:s(c),s(b),1) ];   
%end


%
% 17.2.97 implementation
%
%s=dsize3d(v,n);
%en  = elements(v);
%ijk=allpositions(v,n);
%
%pqn = s(b)*s(c);
%
%w  =  zeros(s(a),pqn);
%pq =  zeros(en,2);
%
%
%pq(:,1) = ijk(:,a);
%pq(:,2) = s(b)*(ijk(:,c)-1) + ijk(:,b);
%
%ei =  pq(:,1) + s(a) * (pq(:,2)-1);
%
%if nargout==1
% w(ei)=v;
%else
% w(ei)=v;
% bc= [repetition(1:s(b),s(c),'row'); repetition(1:s(c),s(b),1,'row') ];   
%end


%
% original implementation of bc
%
% bc= [reshape((1:s(b))'*ones(1,s(c)),1,s(b)*s(c)); ...
%      reshape(ones(s(b),1)*(1:s(c)),1,s(c)*s(b))];   


%
% optimization for partposition of all elements
%
% partposition(v,(1:en)',s(1)) == allpositions(v,n)
%

%
%  12.3.1997 implementation
%
%if nargout > 1
% bc=[repetition(1:s(b),s(c),'row'); repetition(1:s(c),s(b),1,'row') ];   
%end
