function t=complexp(v,complexity)
% t=complexp(v), returns indices of rows with sum >= complexity
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       v, matrix, one pattern per row,                       *
% *          one row represents one time step                   *
% *       t, col vector with row indices of v where sum along   *
% *          row >= comlexity.                                  *
% *                                                             *
% * See Also:                                                   *
% *           UE_core()                                         *
% *                                                             *
% * Uses:                                                       *
% *       rsum()                                                *
% *                                                             *
% * Bugs:                                                       *
% *       - might not be the right measure for more than        *
% *         one spike per bin                                   *
% *                                                             *
% * History:                                                    *
% *         (1) separate function                               *
% *            MD, 21.2.1997, Jerusalem                         *
% *         (0) first version (in UE_core.m)                    *
% *            SG, 12.3.1996                                    * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% *  >> complexp([1 0 1;0 0 0;0 1 1;0 1 0])                     *
% *  ans =                                                      *
% *        1                                                    *
% *        3                                                    *
% *  >> complexp([1 0 1])                                       *
% *  ans =                                                      *
% *        1                                                    *
% *  >> complexp([1 0 0;0 1 0])                                 *
% *  ans =                                                      *
% *        []                                                   *
% *  >> complexp([0 ;3 ])                                       *
% *  ans =                                                      *
% *        2                                                    *
% *                                                             *
% ***************************************************************

t=find(rsum(v)>=complexity);


% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% Sonja's 25.8.1996 implementation in UE_core.m
%
%
% count_coinc_vec	= sum(mat');		% number of spikes per
%						% time step across the neurons
%						% work on the transposed matrix
% condition	= 2;				% minimum 2 spikes
% non_zero_index  = find(count_coinc_vec>=condition);


