function [ues, it, bstjk2] = UEcore(bst,bstjk, wcell,significance,complexity,...
                                    basis,UEmethod, wildcard, patrequest,...
                                    NShuffleElements, NMCSteps, gen_case)
%[ues,it]=UE_core(bst,significance,complexity,basis, ...
%                 basis,UEmethod, wildcard, patrequest, ...
%                 NShuffleElements, NMCSteps, gen_case)
% ***************************************************************
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% * Usage:                                                      *
% *       bst,      binned spike trains                         *
% *                 -      -     -                              *
% *                 col matrix of binned parallel processes     *
% *   significance, level from on jp value is significant       *
% *   complexity,   minimal complexity of patterns taken        *
% *                 into account                                *
% *   basis,        maximal entry in bst matrix                 *
% *                 (helps in constructing hash values)         *
% *                                                             *
% *   ues,  unitary events statistics                           *
% *         -       -      -                                    *
% *        matrix with unitary events statistics, one col for   *
% *        each pattern with a minimal complexity 'complexity'  *
% *        occurring in bst. The first 19 rows are reserved for *
% *        pattern properties (listed below). From row 20 on    *
% *        times (row indices of bst) of pattern occurences are *
% *        listed.                                              *
% *                                                             *
% *   it,  (optional) matrix with two cols constituting a list  *
% *        of all patterns with minimal complexity 'complexity' *
% *        where the it(:,1) are specifying the type of pattern *
% *        (col index of the ues matrix) and the corresponding  *
% *        it(:,2) are the times (row indices of bst matrix) of *
% *        occurrence.                                          *
% *                                                             *
% *  patrequest, (optional)                                     *
% *        if this list of hash values is given UE_core         *
% *        returns the statistics for all these patterns.       *
% *        Otherwiese statistics is only returned for patterns  *
% *        existent in bst.                                     *
% *                                                             *
% *     ues                                                     *
% *   -------           col                                     *
% *           1    2    3    4    pattern index                *
% *        ---------------------------------->                  *
% *     1  |  hash value of pattern                             *
% *     2  |  number of occurrences                             *
% *     3  |  empirical probability of pattern                  *
% *     4  |  expected probability of pattern                   *
% *     5  |  number of expected occurrences                    *
% *     6  |  joint-p-value                                     *
% *     7  |  1 if is a UE      (jp<=significance), 0 else      *
% * row 8  | -1 if is a neg. UE (jp>=1-significance), 0 else    *
% *     9  |                                                    *
% *     .                                                       *
% *     .     currently not used                                *
% *     .                                                       *
% *    19  |                                                    *
% *    20  | t11  t12               |                           *
% *        | t21  t22               |  times  (row indices      *
% *        | t31                    |  of bst matrix) of        *
% *        | t41    ----------------0  occurrence               *
% *        |                                                    *
% *        v                                                    *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *          UE(), UEMWA()                                      *
% *                                                             *
% * Uses:                                                       *
% *      rows(), cols(), partlinear(), reiterate()              *
% *      cmean(),                                               *
% *      hash(), inv_hash(), hunique(),                         *
% *      complexp(),                                            *
% *      where(),                                               *
% *      exp_j_prob(), jp_val()                                 *
% *                                                             *
% * Future:                                                     *
% *         - matlab 4.x does not support structures. a matrix  *
% *           is used for ues instead. Replace when structures  *
% *           are available                                     *
% *         - add option (SG, 14.4.99, FfM):                    *
% *           sort entries according to patrequest ????         *
% *                                                             *
% * History:                                                    *
% *         (4) passes CSR parameters                           *
% *            PM, 14.9.02, FfM                                 *
% *         (3) statistics can now be returned also for         *
% *             patterns not existent in bst                    *
% *            MD, 30.7.1997, Jerusalem                         *
% *         (2) rewritten in matrix notation, commented         *
% *            MD, 23.2.1997                                    *
% *         (1) made faster                                     *
% *            SG, 25.8.1996                                    *
% *         (0) first version                                   *
% *            SG, 12.3.1996                                    * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

%dbstop in UEcore at 97
if nargin<9
    patrequest=[];
end

% ***************************************
% * get:                                *                           
% *      T - number of time steps       *
% *      n - number of neurons          *
% *          (length of patterns)       *
% ***************************************
T = size(bst,1);
n = size(bst,2);


bstjk2 = bstjk;

% ************************************************
% * p - row vector length(p)==n with             *
% *     marginal probability for each neuron     *
% *                                              *
% * h - col vector length(h)==T with             *
% *     hash value for pattern in each time step *
% ************************************************    
p = mean(bst,1);

h = hash(bst,n,basis);

% ****************************************
% * tc - col vector length(tc)<=T with   *
% *      indices of all time steps where *
% *      a complex pattern occured       *
% ****************************************
tc = complexp(bst,complexity);


switch wildcard
    
case 'on'
    
    JPmethod   = 'OnlySpikes';
    spsum      = sum(bst,2);
    spsumindex = find(spsum>2);
    
    if ~isempty(spsumindex)
        
        tc         = complexp(bst,0);
        
        newbst   = bst;
        newtc    = tc;
        newbstjk = bstjk;
        
        addtoindex = 0;
        for ii=1:length(spsumindex)
            
            % create subpattern
            [stmp,vtmp,sstmp] = sortAllHash3(spsum(spsumindex(ii)),basis,2,spsum(spsumindex(ii))-1);
            
            % HIER WIRD FALSCHES EINGEFUEGT, DENN
            % wenn bst(540,:)=     0     1     1     1             
            % existiert wird
            %vtmp =
            % 
            %     0     0     1     1
            %     0     1     0     1
            %     0     1     1     0
            %     1     0     0     1
            %     1     0     1     0
            %     1     1     0     0
            %                
            %eingefuegt, d.h. fuer die linke Spalte werden spikes
            %eingefuegt - falsch!!!!
            
            vvtmp = zeros(length(stmp),n);
            vvtmp(:,find(bst(spsumindex(ii),:))) = vtmp;
            clear vtmp;
            
            ninsert = size(stmp,1);  
            
            % insert pattern in newbst
            newbst = InsertInArray(newbst,vvtmp,spsumindex(ii)+1+addtoindex,1);
            
            % insert identical index in newtc
            newtc = InsertInArray(newtc,tc(spsumindex(ii))+zeros(size(stmp)), ...
                spsumindex(ii)+1+addtoindex,1);
            % insert identical time, trial indices into newbstjk
            inserttmp = copy(bstjk(spsumindex(ii),:),ninsert,1);
            
            newbstjk = InsertInArray(newbstjk, inserttmp, ...
                spsumindex(ii)+1+addtoindex,1);
            
            
            addtoindex = addtoindex + ninsert;  
            
        end
        
        bst = newbst;
        bstjk2 = newbstjk;
        tc  = newtc;
        tc  = complexp(bst,complexity);
        h   = hash(bst,n,basis);
        %T   = size(bst,1); 
        
    end
    
case 'off'
    JPmethod   = 'IncludeNonSpikes';
    
otherwise
    error('UEcore::WrongWildcardSelection');
    
end



%
% check if patterns of sufficient complexity exist
%
if ~isempty(tc)   
    
    % ***************************************************
    % * h   - reduce col vector of all hash values to   *
    % *       col vector of hash values with sufficient *
    % *       complexity length(h)==length(tc)          *
    % * hu  - col vector containing a unique list of    *
    % *       hash values in h length(hu)<=length(h)    *
    % * nhu - number of different hash values           *
    % *       (patterns)                                *
    % ***************************************************
    h   = h(tc);
    hu  = hunique(h);
    nhu = length(hu);
    
    
    % **************************************************************************
    % * Check all hash values h(k) in h. For each hash value h(i) occuring     *
    % * in hu index i is returned. At the same time an index j is assigned     *
    % * telling which in the  unique list of hash values hu it is h(i)==hu(j). * 
    % * Because in our case every h(k) actually does occur in hu               *
    % *                                                                        *
    % *      length(i)==length(j)==length(h)                                   *
    % *                                                                        *
    % * s(j) is the number of times hu(j) occured in h:                        *
    % *                                                                        *
    % *      length(s)==length(hu) .                                           *
    % *                                                                        *
    % * Example:                                                               *
    % *         h=[7 5 2 3 2 8 5 1 5 4]';  hu=[1 2 3 4 5 7 8]';                *
    % *                                                                        *
    % * h =    hu =                      i =    j =    s =    in =             *
    % *    7       1                        8      1      1       1            *
    % *    5       2                        3      2      2       1            *
    % *    2       3                        5      2      1       2            *
    % *    3       4  where(hu,h,'first')   4      3      1       1            *
    % *    2       5      ------->         10      4      3       1            *
    % *    8       7                        2      5      1       1            *
    % *    5       8                        7      5      1       2            *
    % *    1                                9      5              3            *
    % *    5                                1      6              1            *
    % *    4                                6      7              1            *
    % *                                                                        *
    % **************************************************************************
    [i,j,s]=where(hu,h, 'first');
    
    %keyboard
    
    mo=max(s);
    in=reiterate((1:mo)',s');
    
    
    % ********************************************************
    % * tc - resort time indices of pattern occurrences with *
    % *      respect to the appearance of the corresponding  *
    % *      hash value in unique list of hash values hu.    *
    % *      Afterwards for a given tc(k) holds:             *
    % *        - hu(j(k)) is the corresponding hash value    *
    % *        - in(k) counts how often pattern index j(k)   *
    % *          already occured in j                        *
    % *                                                      *
    % * i,h - are cleared to make sure they are not used     *
    % *       anymore                                        *
    % ********************************************************
    
    % these values are finally in ues (times for ues)
    tc=tc(i);
    clear i,h;
    
else % isempty(tc)
    hu=[];
    nhu=0;
    tc=[];
    s=[];
    mo=0;
    i=[];
    j=[];
    in=[];
end



% ********************************************************
% * if patrequest is not empty. Append hash values of    *
% * requested patterns which are not already in hu to    *
% * hu and compute statistics also for them.             *
% *                                                      *
% *                                                      *
% *  hu  s  patrequest                 hu  s             *
% *                                                      *
% *  3   5   9                         3   5             *
% *  7   1   3                         7   1             *
% *  1   2   5          -------->      1   2             *
% *          7                         2   0             *
% *          1                         4   0             *
% *          4                         5   0             *
% *          2                         9   0             *
% *                                                      *
% ********************************************************

if ~isempty(patrequest)
    hu=cat(1,hu,col(setdiff(patrequest,hu)));
    nhu=length(hu);
    s =cat(1,s,zeros(nhu-length(s),1)); 
end



% ****************************************
% * RETURN                               *
% *   if no patterns found or specified  *
% *                                      *
% ****************************************
if isempty(hu)
    ues=[];
    if nargout>=2
        it=[];
    end
    return
end



switch UEmethod
    
case 'csr'
    
    % ------- new new new new 6/02 ----------------------
    
    % *************************************
    % 
    %  Gordons CSR method
    %
    % *************************************
    
    %[p_value_array,mean_counts_simulaneous,mean_counts_shuffled,corresponding_hashv]= ...
    % CSR_Method(Spiketrain_array,Number_of_shuffle_ele,gen_case,Number_of_MC_steps);
    % [nempsum,nexpsum,ff] = TrialByTrialStatistics(wcell,bst,bstjk2,basis,hu,JPmethod);
    
    
    [p_value_array,mean_counts_simulaneous,mean_counts_shuffled,corresponding_hashv]= ...
        CSR_Method(wcell,NShuffleElements,gen_case,NMCSteps);
    
    % final:     10* nr_trials 0der 1000, 'random', 10000 
    %CSR_Method(wcell,1000,'random', 10000); 
    % Screening: 2*nr_trials, 'random', 1000
    %[nr_time_steps nr_trials nr_neuron]=size(wcell);
    
    ues = zeros(20+mo-1,nhu);
    for iii=1:length(hu)
        idx = find(corresponding_hashv==hu(iii));
        if ~isempty(idx)
            ues(1,iii)=corresponding_hashv(idx);
            ues(2,iii)=mean_counts_simulaneous(idx);
            ues(3,iii)=mean_counts_simulaneous(idx)/T;
            ues(5,iii)=mean_counts_shuffled(idx);
            ues(4,iii)=mean_counts_shuffled(idx)/T;
            ues(6,iii)=p_value_array(idx);
            jp = p_value_array(idx);
            ues(7,iii)= jp<=significance      & jp>0;
            ues(8,iii)= -1*(jp>=(1-significance)  & jp>0);
            ues(9,iii)= jointSjointP(jp);
        else
            ues(1,iii)=hu(iii);
            ues(2,iii)=0;
            ues(3,iii)=0;
            ues(5,iii)=0;
            ues(4,iii)=0;
            ues(6,iii)=1;
            jp = 1;
            ues(7,iii)= jp<=significance      & jp>0;
            ues(8,iii)= -1*(jp>=(1-significance)  & jp>0);
            ues(9,iii)= jointSjointP(jp);
        end
        
        
    end
    
    ues(11,1:nhu) = ues(2,1:nhu);   % will be used outside for actCoincRate 
    ues(12,1:nhu) = ues(5,1:nhu);   % will be used outside for expCoincRate 
    
        
    % ------- end new 6/02 -----------------------------
    
    
    
    
case 'trialbytrial'
    
    % ------- new new new new 3/02 ----------------------
    
    % *************************************
    % 
    %  go over single trials and patterns
    %
    % *************************************
    
    [nempsum,nexpsum,ff] = TrialByTrialStatistics(wcell,bst,bstjk2,basis,hu,JPmethod);
    
    % *************************************
    % 
    %  use sums across trials for evaluating
    %   significance
    %
    % USE old parts of the program UE_core.m
    %
    % *************************************
    
    jp       = jp_val(nempsum,nexpsum);
    js       = logP(nempsum,nexpsum);
    
    ue_p     =     jp<=significance      & jp>0;
    ue_n     = -1*(jp>=(1-significance)  & jp>0);
    
    
    
    % *********************************************
    % * build ues - unitary events statistics     *
    % *             -       -      -              *
    % * data structure as return value            *
    % *                                           *
    % *********************************************          
    
    ues = zeros(20+mo-1,nhu);		
    
    ues(1,1:nhu)  = hu';		% hash-value of pattern
    ues(2,1:nhu)  = nempsum';	% number of occurrences
    ues(3,1:nhu)  = nempsum'/T;	% empirical probability
    ues(4,1:nhu)  = nexpsum'/T;     % expected probability
    ues(5,1:nhu)  = nexpsum'; 	% number of expected occurrences
    ues(6,1:nhu)  = jp';            % joint-p-value
    ues(7,1:nhu)  = ue_p';          % positive unitary events
    ues(8,1:nhu)  = ue_n';          % negative unitary events
    
    ues(9,1:nhu)  = js';            % joint-surprise
    %ues(10,1:nhu) = ues(2,1:nhu);   % will be used outside for UEs/trial 
    ues(11,1:nhu) = ues(2,1:nhu);   % will be used outside for actCoincRate 
    ues(12,1:nhu) = ues(5,1:nhu);   % will be used outside for expCoincRate 
    
    % ------- end new 3/02 -----------------------------
    
    
case 'trialaverage'
    
    
    % *********************************************
    % * ejpr - expected joint probability of each *
    % *        of the different patterns, given   *
    % *        the marginals p                    *
    % *         length(ejpr)==length(hu)          *
    % * jp   - joint-p-value of each of the       *
    % *        different patterns, given the      *
    % *        number of actual occurrences       *
    % *         length(jp)==length(ejpr)          *
    % *********************************************
    
    ejpr         = ExpJProb(hu,n,basis,p,JPmethod);
    
    expCoinc     = ejpr*T;
    
    jp           = jp_val(s,expCoinc);
    
    js           = logP(s,expCoinc);
    
    % js_HypGeo hygepdf.m?? - vorsciht, testen fuer grosse N
    % js_BinNom binopdf.m
    
    ue_p         =     jp<=significance      & jp>0;
    ue_n         = -1*(jp>=(1-significance)  & jp>0);
    
    
    % *********************************************
    % * build ues - unitary events statistics     *
    % *             -       -      -              *
    % * data structure as return value            *
    % *                                           *
    % *********************************************          
    
    ues = zeros(20+mo-1,nhu);		
    
    ues(1,1:nhu)  = hu';		% hash-value of pattern
    ues(2,1:nhu)  = s';		% number of occurrences
    ues(3,1:nhu)  = s'/T;		% empirical probability
    ues(4,1:nhu)  = ejpr';          % expected probability
    ues(5,1:nhu)  = expCoinc'; 	% number of expected occurrences
    ues(6,1:nhu)  = jp';            % joint-p-value
    ues(7,1:nhu)  = ue_p';          % positive unitary events
    ues(8,1:nhu)  = ue_n';          % negative unitary events
    
    ues(9,1:nhu)  = js';            % joint-surprise
    %ues(10,1:nhu) = ues(2,1:nhu);   % will be used outside for UEs/trial 
    ues(11,1:nhu) = ues(2,1:nhu);   % will be used outside for actCoincRate 
    ues(12,1:nhu) = ues(5,1:nhu);   % will be used outside for expCoincRate 
    
otherwise
    error('UEMWA::UnknownUEMethodOption');
end



% ****************************************
% * RETURN                               *
% *   if no patterns found of sufficient *
% *   complexity found                   *
% ****************************************
if isempty(tc)
    if nargout>=2
        it=zeros(0,2);
    end
    return
end


% *******************************************
% * in -  adjust in to the structure of the *
% *       ues matrix: time indices start at *
% *       row 20                            *
% *******************************************
in=20+in-1;

% *************************************************
% * store time indices as a matrix spanned        *
% * by pattern index j and count of occurrence in *
% *************************************************
ues(sub2ind(size(ues),in,j))=tc; 


% ***********************************************
% * it - if requested return list of hash value *
% *      (pattern) indices and corresponding    *
% *      times of occurrence                    *
% ***********************************************

if nargout>=2
    it=zeros(length(in),2);
    it(:,1)=j;
    it(:,2)=tc;
end



%if nargout>=3
% it=zeros(length(in),2);
% it(:,1)=j;
% it(:,2)=tc;
% rates=p;
%end

%keyboard












