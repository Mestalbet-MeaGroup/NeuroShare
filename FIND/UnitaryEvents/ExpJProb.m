function jp=ExpJProb(h,n,basis,p,JPmethod)
% jp=ExpJProb(h,n,basis,p,method), expected probabilities of 
%                                patterns coded by hash values h
% ***************************************************************
% * Returns the expected probabilities jp of the patterns       *
% * coded by its hash values h and number of digits n           *
% * according to the marginal probabilites p.                   *
% * A spike (1) in neuron i occurs with probability p(i)        *
% * a non spike (0) with probability 1-p(i).                    *
% *                                                             *
% * Usage:                                                      *
% *
% *  input:
% *       h, scalar or col vector of hash values                *
% *       n, number of neurons (total number of digits of basis *
% *          representation)                                    *
% *       p, scalar or row vector length(p)==n containing       *
% *          marginal probabilities of each neuron              *
% *  method, 'IncludeNonSpikes': include probabilities for
% *            zeros for calculating the joint-probability
% *           e.g. P([1 0 1]) = p1*(1-p2)*p3
% *          'OnlySpikes' : do not include probabilities for
% *            zeros for calculating the joint-probability 
% *           e.g. P([1 0 1]) = p1*p3 
% * 
% *  output:
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
% *         (3) modified version from exp_j_prob.m
% *             contains now the option to compute
% *             the joint-probs considering probabilities
% *             non-spikes or not                               *
% *            SG, 19.3.02, FFM                                 *
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
% *  >> ExpJProb(5,3,2,[0.2 0.4 0.3], 'IncludeNonSpikes')       *
% *  ans =                                                      *
% *        0.0360                                               *
% *                     1   0   1    =>   0.2*0.6*0.3==0.0360   *
% *                                                             *
% *  >> ExpJProb(5,3,2,[0.2 0.4 0.3], 'OnlySpikes')             *
% *  ans =                                                      *
% *        0.06                                                 *
% *                     1   0   1    =>   0.2*0.3==0.06         *
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


switch JPmethod
 case 'IncludeNonSpikes'
  jp= rprod(v.*p + (1-v).*(1-p));          % includes probs for
                                           % spikes and non-spikes
 case 'OnlySpikes'
  jp= rprod(v.*p + (1-v).* 1);             % product of probs only
                                           % for spikes
 otherwise
  error('ExpJProb::UnknownMethodOption');
end



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

