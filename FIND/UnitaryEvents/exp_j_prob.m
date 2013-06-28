function jp=exp_j_prob(h,n,basis,p)
% jp=exp_j_prob(h,n,basis,p), expected probabilities of patterns coded by hash values h
% ***************************************************************
% * Returns the expected probabilities jp of the patterns       *
% * coded by its hash values h and number of digits n           *
% * according to the marginal probabilites p.                   *
% * A spike (1) in neuron i occurs with probability p(i)        *
% * a non spike (0) with probability 1-p(i).                    *
% *                                                             *
% * Usage:                                                      *
% *       h, scalar or col vector of hash values                *
% *       n, number of neurons (total number of digits of basis *
% *          representation)                                    *
% *       p, scalar or row vector length(p)==n containing       *
% *          marginal probabilities of each neuron              *
% *      jp, scalar or col vector of expected probabilities     *
% *          length(jp)==length(h)                              *
% *                                                             *
% * See Also:                                                   *
% *           jp_val()                                          *
% *                                                             *
% * Uses:                                                       *
% *       copy(), rows(), inv_hash(), orientation()             *
% *                                                             *
% * History:                                                    *
% *         (2) rewritten for col vector of hash values         *
% *            MD, 19.2.1997                                    *
% *         (1) made faster                                     *
% *            SG, 25.8.1996                                    *
% *         (0) first version                                   *
% *            SG, 8.2.1996                                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * Examples:                                                   *
% *                                                             *
% *  >> exp_j_prob(5,     3,[0.2 0.4 0.3])                      *
% *  ans =                                                      *
% *        0.0360                                               *
% *                     1   0   1    =>   0.2*0.6*0.3==0.0360   *
% *                                                             *
% *  >> exp_j_prob([5 3]',3,[0.2 0.4 0.3])                      *
% *  ans =                                                      *
% *        0.0360                                               *
% *        0.0960                                               *
% *                     1   0   1         0.2*0.6*0.3==0.0360   *
% *                     0   1   1    =>   0.8*0.4*0.3==0.0960   * 
% *                                                             *
% ***************************************************************


if length(p)~=n
 error('ExpJProb::MarginalsNotFitN');
end

if ~strcmp(orientation(p),'row') & ~strcmp(orientation(p),'none')
 error('ExpJProb::RowVecPExpected');
end

v = inv_hash(h,n,basis);                   % checks h and n 	
p = copy(p,rows(h),1);
jp= rprod(v.*p + (1-v).*(1-p));



% ***************************************************************
% * Historical Section                                          *
% *                                                             *
% *                                                             *
% ***************************************************************

%
% Sonja's 25.8.1996 implementation
%
%
% pattern_vec	= inv_hash(hash_val,n);	
%					
% if size(marg_prob_vec, 2) ~= size(pattern_vec, 2)
%  disp('ERROR: Dimensions of vectors do not fit (exp_j_prob.m)');
%  disp('       empty vector returned!!!                       ');
%  j_prob		= [ ];
% else
%  j_prob	= prod( pattern_vec.*marg_prob_vec + ...
%		        ((1-pattern_vec)).*(1-marg_prob_vec) );
% end

