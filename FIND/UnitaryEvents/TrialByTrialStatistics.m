function [nempsum,nexpsum,ff] = TrialByTrialStatistics(wcell,bst,bstjk,basis,hu,JPmethod)
% [nempsum,nexpsum,ff] = TrialByTrialStatistics(wcell,basis,hu):
%              Statistics of coincidences on trial by trial basis
% ***************************************************************
% *                                                            
% * Usage:                                                      
% * input:                                                      
% *         wcell,  cell with spike data (0,1)                  
% *                 1st dim: time steps in trial
% *                 2nd dim: trials
% *                 3rd dim: neuron
% *         basis,  basis for calculating hash values of patterns
% *         hu   ,  hash values to be explored
% *
% *                                                             
% * output:                                                     
% *         nempsum, number of empirical coincidence counts
% *                  of patterns requested by hu, in same oder
% *                  as hu;
% *                  sum over all trials
% *         nexpsum, number of expected coincidences
% *                  of patterns requested by hu, in same oder
% *                  as hu;
% *                  sum over all trials
% *         ff,      fano factor per neuron (along column) 
% *                  variance of spike counts per trial divided
% *                  by the mean spike counts
% *
% * Optional: figure of spike counts, nexp and nemp per trial
% *
% *                                                             
% * Uses:                                                       
% *       where.m, exp_j_prob.m, hash.m 
% *                                                             
% * See Also:                                                   
% *                                                             
% *                                                             
% * Future:  if requested, statistics of single trials
% *          is prepared and can be provided
% *          (nempmat, nexpmat, spcountsmat)          
% *                                                             
% *                                                             
% * History:                                                    
% *         (0) first Version on the basis of
% *             'Effect of across trial non-stationarity 
% *              on joint-spike events' submitted to Biol Cyber
% *            SG 17.3.02, FfM                                   
% *                                                             
% *                                                             
% *                          diesmann@chaos.gwdg.de             
% *                          gruen@mpih-frankfurt.mpg.de        
% *                                                             
% ***************************************************************

s       = size(wcell);
T       = s(1);         % number of time steps
n       = s(3);         % number of parallel neurons
nt      = s(2);         % number of trials

nhu     = size(hu,1);   % number of hash values to check
  
% number of spike counts per trial and neuron
spc = sum(wcell);

%  spiking probability per trial and neuron
pt  = spc./T;

nempsum  = zeros(size(hu));
nexpsum  = zeros(size(hu));
nexpmat  = zeros(nhu,nt);
nempmat  = zeros(nhu,nt);
spcountsmat = zeros(n,nt);
 
for i=1:nt                % loop over trials

 ppertrial   = [];         % spike prob per trial
 spcountspertrial = [];     % spike counts per trial
 patpertrial = [];         % parallel spike trains per trial
 nemppertrial= [];         % empirical counts per trial
 nexppertrial= [];         % expected counts per trial
 jprobpertrial = [];       % expected probability per trial
 hpertrial   = [];         % hash values per trial

 for j=1:n                 % loop over neurons
  ppertrial   = [ppertrial pt(:,i,j)];
  spcountspertrial = [spcountspertrial spc(:,i,j)];
  %patpertrial = [patpertrial wcell(:,i,j)];
 end


 % alternative on bst with bstjk
  patpertrial = bst(find(bstjk(:,2)==i),:);

   %  setdiff(patpertrial,patpertrial2,'rows')
   %  patpertrial = patpertrial2;

 % hashvalue per pattern per trial
 hpertrial = hash(patpertrial,n,basis);

 % expected probability per trial per requested pattern
 %jprobpertrial = exp_j_prob(hu,n,basis,ppertrial);
jprobpertrial = ExpJProb(hu,n,basis,ppertrial,JPmethod);

 % expected number of coincidences per trial
 nexppertrial = jprobpertrial * T;

 % put spike counts in matrix
 spcountsmat(:,i) = spcountspertrial'; 

 % put expected number of coincidences per trial in matrix
 nexpmat(:,i) = nexppertrial;

 % number of occurrences of hash values in hu per trial
 [dummy1,dummy2,nemppertrial]=where(hu,hpertrial,'first');

 % put empirical number of coincidences per trial in matrix
 nempmat(:,i) = nemppertrial;

end

% calculate results

 % sum of empirical number of coincidences over trials
 nempsum = sum(nempmat,2);

 % sum over trials of expected number of coincidences
 nexpsum = sum(nexpmat,2);

 % fano factors
 varc  = (std(spcountsmat,0,2)).^2;
 meanc = mean(spcountsmat,2);
 for j=1:n
  ff(j,1) = varc(j,1)/meanc(j,1);
 end 

% spike count covariance
% corrcoef(spcountsmat(1,:) ,spcountsmat(2,:)) 
 
