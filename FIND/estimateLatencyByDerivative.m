function [lat,fs,tfs] = estimateLatencyByDerivative(varargin);
% function [lat,fs,tfs] = estimateLatencyByDerivative(varargin);
%
% Estimates the latency of a response onset in a rate function by finding the max. of the
% first derivative.
%
% Obligatory Arguments:
% s: 1 dim Data Vector (i.e. firing rate) - CAVE: should not be sparse.
% n: 1/2*width of the filter in samples 
%
% Optional Arguments:
% T : interval of interest 
%
% Output:
% lat: latency in time steps (samples) 
% fs:  filtered signal (s)
% tfs: time axis for fs
% 
% (1) Mar 7, 2007
% (0) Mar 1, 2007 - nawrot@neurobiologie.fu-berlin.de
% Adapted for FIND - Feb. 2008, Ralph Meier
% 
% References: 
% Meier et al. 2008, Neural Networks, Spec. Issue Neuroinformatics  
%

obligatoryArgs={{'s', @(val) length(val)>1 }
    {'n', @(val) length(val)==1 && val>0}};

optionalArgs={{'T', @(val) length(val)==1 && val>0}}; 

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);

if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end

% Default Parameters:
m=1;


pvpmod(varargin);

% default for T:
if ~exist('T')
 T=[1 length(s)]; Tdefault=true;
end

    
nl = -n;      % number of data points to the left
nr = -nl;       % number of data points to the rigth
ld = 1;         % 0: smooting, 1: numerical derivative
savgol = makeSavgol('n',n,'ld',ld,'m',m, ...
    'wf','Welch','h',1e-3);
le=length(savgol);

if Tdefault
    T=[1 length(s)-le];
end

fs = filter(fliplr(savgol),1,s);
%fs = filter((savgol),1,s);
fs=fs(le:end);
tfs=(1:length(fs))+nr;
[m,lat] = max(fs(T(1)+1:T(2)));
lat=lat(1)+T(1);
lat=lat+nr;