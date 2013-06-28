function [cn,n1,n2,cij1,cij2] = countJBS(sp1,sp2,jit) 
% [cn,n1,n2,cij1,cij2]=countJBS(sp1,sp2,jit), coincidences JNM version  
% ***************************************************************** 
% * input:
% * -------
% *      sp1, sp2 0-1 spike matrices with structure:
% *   
% *              trial
% *            ---------->
% *            |
% *       time |
% *            |
% *            v
% * 
% *
% *       jit,  max allowed jitter (in bins)
% *           
% * 
% *
% * output:
% * -------
% *   c  : number of coincidences of given jitter jit
% *        n1  : total number of spikes of sp1
% *        n2  : total number of spikes of sp2
% *       cij1: matrix of indices of spikes 
% *                      in sp1 involved in any coincidence 
% *                     (2nd column)
% *                      and its trial of occurrence (1st column)
% *                      (trial id, time idx)
% *        cij2: matrix of indices of spikes 
% *                      in sp2 involved in any coincidence 
% *                     (2nd column)
% *                      and its trial of occurrence (1st column) 
% *                      (trial id, time idx) 
% * 
% *
% * History: (0) first version
% *              SG, AR, 16.3.98, Ffm
% *              TO_DO: for input of spike matrix
% *          (1) output of spike indices
% *              SG, FG, 6.5.98, Ffm
% *          (2) for spike matrices now (1 neuron in many trials)
% *              output of (trial id,idx) for coincidence indices
% *              SG, FG, 8.5.98, Ffm
% *          (3) output of firing probabilities added
% *              SG, FG, 8.5.98, Ffm
% *          (4) rewritten for application to whole data set
% *              MD, SG, 5.5.00, Marseille
% *
% ******************************************************************


%
% first neuron is reference
%

n1 = sum(sp1);
n2 = sum(sp2);

n = size(sp1,1);   % number of time steps
m = size(sp2,2);   % number of trials

%
% temporary matrix for coincidences found at a specific shift
%
c  = zeros(n,m);


%
% total coincidence count cn(i) for time step i using spikes of neuron
% i as reference
%
cn = zeros(n,1);

cij1 = zeros(0,2);
cij2 = zeros(0,2);

%
% loop over all time shifts -jit, -jit+1, ..., -1, 0, 1, ... jit-1, jit 
%
for k=-jit:jit

 if k>0
  k1 = 1:n-k; 
  k2 = k+1:n;
 else
  k1 = -k+1:n;
  k2 = 1:n+k;
 end  

 c  = sp1(k1,:) & sp2(k2,:);


 cn(k1) = cn(k1) + sum(c,2);

 
 %
 % find indices of coincidences at shift k
 %
 [i,j] = find(c);
 
 ji1 = cat(2, j, i+k1(1)-1);
 ji2 = cat(2, j, i+k2(1)-1); 


 cij1 = cat(1, cij1, ji1);
 cij2 = cat(1, cij2, ji2);


end






