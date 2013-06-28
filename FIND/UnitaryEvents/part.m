function e=part(v,i,j,k,n)
% part,  sort of Mathematica's part function
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% * -------                                                     *
% *  1d-matrices (vectors):                                     *
% *       part(v,i)  returns ith component of v                 *
% *                                                             *
% *  2d-matrices:                                               *
% *       part(v,i,j)  returns (i,j)th component of v           *
% *                                                             *
% *  3d-matrices:                                               *
% *       part(v,i,j,k,n) returns (i,j,k)th component of v,     *
% *                       only works correctly if n is the      *
% *                       number of elements in the first       *
% *                       dimension (range of i).               *
% *                                                             *
% * Input:  v: input matrix                                     *
% *         n: number of elements in first dimension            * 
% *         i,j,k: position of of return element                *
% *                                                             *
% * Output: e: requested element of v                           *    
% *                                                             *
% * See Also:                                                   *
% *           partindex, replace, zeros3d                       *
% * Uses:                                                       *
% *           partcheck(), parterror(),                         *
% *           rows(), cols()                                    *
% *                                                             *
% * History:                                                    *
% *         (4) keys 'row' and 'col' added to force             *
% *             orientation of result independent of v,i.       *
% *            MD, 5.2.1997, Freiburg                           *
% *         (3) support for linear index added                  *
% *            MD, 11.12.1996, Freiburg                         *
% *         (2) now using parterror                             *
% *            MD, SG 26.11.1996, Jerusalem                     * 
% *         (1) partcheck, comments extended                    *
% *            MD, SG 25.11.1996, Jerusalem                     *
% *         (0) first Version                                   *
% *            MD, SG 20.11.1996, Jerusalem                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% *                                                             *
% *                                                             *
% *                                                             *
% *  In version 4 matlab does not support mult-dimensional      *
% *  matrices. Here we extend matrix access to 3 dimensions     *
% *                                                             *
% * matrices are stored in column first ordere,                 *
% * "leftmost index grows fastest".                             * 
% *                                                             *
% * Linear addressing is allowed                                *
% *                           v=[4 5; 6 7];                     *
% *                           v(1,2)==v(3)==5                   *
% *                                                             *
% * For the 3d case we can map the indices ijk two 2ds indices  *
% * using:                                                      *
% *        v(j,(i-1)*(part(size(v),2)/n)+k)                     * 
% * However this does approach does not work if i and k are     *
% * vectors of by themself, more code is neccessary to resolve  *
% * this.                                                       *
% *                                                             *
% * part can be implemented by using v(partindex( ...)) and     *
% * reshaping the result. Here we use the build in 2d access    *
% * to increase performance.                                    *
% *                                                             *
% * The interpretation of ijk is the following (see the         *
% * comment in partindex for more details):                     *
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
% * Examples:                                                   *
% *                                                             *
% *  v=[4 5 14 15 24 25;6 7 16 17 26 27;8 9 18 19 28 29;        *
% *     10 11 20 21 30 31];                                     *
% *                                                             *
% *       >> part([4 5 6],2)                                    *
% *       ans =                                                 *
% *             5                                               *
% *       >> part([4 5 6; 7 8 9],2,3)                           *
% *       ans =                                                 *
% *             9                                               *
% *       >> part(v,2,4,1,3)                                    *      
% *       ans =                                                 *
% *             20                                              *
% *       >> part(v,2,4,[1 2],3)                                *            
% *       ans =                                                 *
% *             20    21                                        *      
% *       >> part(v,2,[3 4],1,3)                                *         
% *       ans =                                                 *
% *             18                                              *
% *             20                                              *
% *       >> part(v,[2 3],4,1,3)                                *
% *       ans =                                                 *
% *             20    30                                        *
% *       >> part(v,2,1:4,1:2,3)                                *
% *       ans =                                                 *
% *            14    15                                         *
% *            16    17                                         *
% *            18    19                                         *
% *            20    21                                         *
% *       >> part(v,[1 2],[3 4],1,3)                            *
% *       ans =                                                 *
% *             8    18                                         *
% *            10    20                                         *
% *       >> part(v,[1 2],4,[1 2],3)                            *
% *       ans =                                                 *
% *            10    11    20    21                             *  
% *       >> part(v,[1 3],[3 4],[1 2],3)                        *
% *       ans =                                                 *
% *             8     9    28    29                             *
% *            10    11    30    31                             *
% *                                                             *
% *                                                             *
% ***************************************************************
%
%
%

if nargin==2
 if cols(v)==1 | rows(v)==1
  i=partcheck(i,rows(v(:)));
  if i 
   e=v(i);
  else
   parterror('part','range','1d','i');
  end
 else
  parterror('part','shape','1d');
 end
elseif nargin==3
 if strcmp(j,'linear')
  if i<=elements(v)
   e=v(i);
  else
   parterror('part','linear','xx','i');
  end
 elseif strcmp(j,'row')
  if i<=elements(v)
   e=reshape(v(i),1,elements(i));
  else
   parterror('part','row','xx','i');
  end
 elseif strcmp(j,'col')
  if i<=elements(v)
   e=reshape(v(i),elements(i),1);
  else
   parterror('part','col','xx','i');
  end 
 elseif strcmp(j,'reshape')
  if i<=elements(v)
   e=reshape(v(i),rows(i),cols(i));
  else
   parterror('part','reshape','xx','i');
  end
 else
  i=partcheck(i,rows(v));
  j=partcheck(j,cols(v));
  if i
   if j 
    e=v(i,j);
   else
    parterror('part','range','2d','j'); 
   end
  else
   parterror('part','range','2d','i'); 
  end
 end
elseif nargin==5           
 cn = cols(v)/n;
 j=partcheck(j,rows(v));
 i=partcheck(i,n);
 k=partcheck(k,cn);
 if j
  if i
   if k
    kn = length(k);
    in = length(i);

   iv=repetrow((i-1)*cn,kn,1);
   kv=repetrow(k,in,kn);

%    iv = reshape(ones(kn,1)*(i-1)*cn,1,in*kn);
%    kv = reshape(k'*ones(1,in),1,in*kn);
    e=v(j,iv+kv);
   else
    parterror('part','range','3d','k');
   end
  else
   parterror('part','range','3d','i');
  end
 else
  parterror('part','range','3d','j');
 end
else
  parterror('part','arguments');
end



% ***************************************************************
% * Historical Section                                          *
% ***************************************************************


%
% first implementation in 3d case
%
%
%    iv = reshape(ones(kn,1)*(i-1)*cn,1,in*kn);
%    kv = reshape(k'*ones(1,in),1,in*kn);
