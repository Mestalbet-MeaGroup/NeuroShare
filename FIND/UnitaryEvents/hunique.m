function w=hunique(v)
% w=hunique(v), returns unique(v) for a vector v of (integer) hash values
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, vector of (integer) hash values                    *
% *       w, sorted hash values with duplicates removed         *
% *                                                             *
% * See Also:                                                   *
% *           unique, adjacent_find                             *
% * Uses:                                                       *
% *           initialize                                        *
% *                                                             *
% * History:                                                    *
% *         (1) using initialze, is now compatible to unique    *
% *            MD, 18.2.1997, Jerusalem                         *
% *         (0) first Version                                   *
% *            MD, 17.2.1997, Jerusalem                         * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% *  >> hashunique([1 2 3 4])                                   *
% *  ans =                                                      *
% *        1     2     3     4                                  *
% *                                                             *
% *  >> hashunique([])                                          *
% *  ans =                                                      *
% *        []                                                   *
% *                                                             *
% *  >> hashunique([1 2 2 3 5 5 7])                             *
% *  ans =                                                      *
% *        1     2     3     5     7                            *
% *                                                             *
% *  >> hashunique([2 2 3 5 5 7])                               *
% *  ans =                                                      *
% *        2     3     5     7                                  *
% *                                                             *
% *  >> hashunique([2 3 5 5])                                   *
% *  ans =                                                      *
% *        2     3     5                                        *
% *                                                             *
% *  >> hashunique([2 3 5 5 5 7])                               *
% *  ans =                                                      *
% *        2     3     5     7                                  *
% *                                                             *
% ***************************************************************
%
%

if length(v)~=0
 w=find(initialize(v,ones(length(v),1)));
else
 w=[];
end



% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% first version without initialize
%
% i(v)=ones(length(v),1);  % remaining initialized to zero 
% w=find(i);



