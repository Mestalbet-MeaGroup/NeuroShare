function nexp = ExpCoincNonStat(n1,n2,jit,Ts)
% nexp = ExpCoincNonStat(n1,n2,jit,Ts): number of expected coincidences 
%                   with trial by trial expectation
%---------------------------------------------------------------
% input:  
%        n1,n2: vectors containing the number of spikes
%               of neuron 1, neuron 2 per trial in window Ts
%               n1 and n2 need to have the same length
%        jit  : jitter in time units
%        Ts   : number of time units in window
%
%
% output:
%        nexp : number of expected coincidences
%
%
% History: (0) explicit implementation in
%              MultipleShiftGDF.m (SG, 17.5.02)
%              ExpCoincArrNonStat(ii+1)= ...
%              Tslid*(2*jit+1)*(freq1(ii+1,:)* freq2(ii+1,:)')/(Tslid)^2;
%          (1) as separat function 
%              SG, 24.6.02, FFM 
%
%

n1 = row(n1);
n2 = row(n2);

% here implemented as scalar product
nexp = Ts*(2*jit+1)*(n1 * n2')/(Ts)^2;
