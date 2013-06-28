function [OptimalKernelWidth,TestedKernelWidths] = optimizeKernelWidth(varargin)
% function [OptimalKernelWidth,TestedKernelWidths] = optimizeKernelWidth('InputSpikeMatrix',[],'TimeUnits',[],'ObservationInterval',[],'KernelForm','')
%
% Determines numerically an optimal standard deviation of convolution
% kernel for rate estimation from single trial or trial-averaged spike
% trains. The algorithms assumes logarithmically increasing values of
% standard deviation sigma and constructs rate estimates for each of these
% widths. Any two successive rate estimates are subtracted and the minimum
% difference is used as indicaor for an optimal kernel. The idea is that if
% the time resolution of hte kernel and the temporal resolution of rate
% dynamics nearly coincide, the least variation in rate estimate is to be
% expeced for a (local) change in the resolution. This implements a heuristic
% approach. For calculation of the difference between any two rate vectors
% the MSE (mean squared error) is used
%
% 
%
% --- Obligatory Parameters ---
%
%     InputSpikeMatrix    : m x n matrix with binary spiketrain(s) in columns
%     TimeUnits           : input resolution in seconds (=TimeStampResolution)
%     ObservationInterval : 2 element vector with first and last bin of
%                           observation interval = [start,end) in index
%                           of InputSpikeMatrix column
%     KernelForm          : string for determining kernel form 
%                           'BOX','TRI','EPA','GAU','ALP','EXP'

%
% --- Optional Parameters -----
%
%     SampleFactor        : resolution factor for temporal resolution of
%                           tested kernel widths. The smaller this value,
%                           the more fine-grained are the test resolutions.
%                           Default value is sqrt(2)
%
%     MinimumSigma        : lower bound for sigmas tested; must not coincide with actual 
%                           minimum of tested kernele widths. default: 0.004 seconds (4ms).
%                           If data shows very low rates, increase this
%                           value.
%                           For high rates (~>n*100Hz) you may decrease this
%                           values to allow for smaller optimal kernels.
%
%     biasflag            : The optimum points at the difference between
%                           two values of sigma. biasflag determines whether the lower or higher
%                           of the two values is finally used, introductin a bias towards
%                           high/low temporal resolution. values are 'low' or ;high'. low->lower
%                           value of sigmais used, i.e. higher temporal
%                           resolution.
%
%
% --- Output Variables --------
%
%    OptimalKernelWidth   : one value for for each column of the matrix
%
%    TestedKernelWidths   : sample of tested kernel standard deviations
%
%
% Notes
%
% calls 'makeKernel.m'
%
% History
%
% (0) Feb 14, 2008 Martin Nawrot (nawrot@neurobiologie.fu-berlin.de).
%       based on 'derive_optimal_kernel.m' (2001) by Martin Nawrot
%       
%
% --------------------------------------------------
% --- Original References of this tool
%
%   [1] Nawrot M, Aertsen A, Rotter S (1999)
%       Single-trial estimation of neuronal firing rates - From single neuron
%       spike trains to population activity.
%       J Neurosci Meth 94: 81-92
%       -> original description and test applications
%
% 
% --- Futhere References: Analysis used in .....
%
%
%   [2] Meier R, Egert U, Aertsen A, Nawrot M (2008)
%   FIND - a unified framework for neural data analysis
%   (submitted manuscript)
%
%   [3] Nawrot MP, Aertsen A, Rotter S (2003) Elimination of response
%   latency variability in neuronal spike trains. Biol Cybern 88: 321-334 
%
%
%   [4] Nawrot MP, Boucsein C, Rodriguez-Molina V, Riehle A, Aertsen A, Rotter S (2007)
%       Measurement of variability dynamics in cortical spike trains.
%       J Neurosci Meth, doi:10.1016/j.jneumeth.2007.10.013
%       
%
%



% obligatory argument names
obligatoryArgs={'InputSpikeMatrix','TimeUnits','ObservationInterval','KernelForm'}; %-% e.g. {'x','y'}

% default paramters
SampleFactor=sqrt(2);   % corresponds to 2ms
MinimumSigma=0.004;
biasflag='low';
% optional arguments names with default values
optionalArgs={'SampleFactor','biasflag'}; 

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

% =====================================================================

MinimumSigmaRes=MinimumSigma/TimeUnits;

TrialLength=size(InputSpikeMatrix,1);
NumberOfTrials=size(InputSpikeMatrix,2);
%left=ceil(ObservationInterval(1)/TimeUnits);
%right=ceil(ObservationInterval(2)/TimeUnits);
left=ceil(ObservationInterval(1));
right=ceil(ObservationInterval(2));
KernelMax=min(left-1,TrialLength-right);
%
% 1) determine vector of kernel sigmas
% - check for observation interval
switch KernelForm
   % c.f. makeKernel
     case 'BOX'
	UpperBoundaryForSigma=floor(KernelMax/sqrt(3)); % BOX- kernel
    case 'TRI'
       % corrected for factor 2 of too small widths, Jan 17 2003
	UpperBoundaryForSigma=floor(KernelMax/sqrt(6)); % TRI - kernel
    case 'EPA'
	UpperBoundaryForSigma=floor(KernelMax/sqrt(5)); % EPA - kernel  
    case 'GAU'
	UpperBoundaryForSigma=floor(KernelMax/2.7);     % GAU - kernel  (>99%)        
    case 'ALP'
	UpperBoundaryForSigma=floor(KernelMax/(5/2));   % TRI - kernel
    case 'EXP'
	UpperBoundaryForSigma=floor(KernelMax/(5/2));   % TRI - kernel
        
   otherwise
	disp('not supported yet')
	return
    end;
e1=ceil(log(MinimumSigmaRes)/log(SampleFactor));
e2=floor(log(UpperBoundaryForSigma)/log(SampleFactor));

%
% corrected for rounding and time resolutions other than ms: Jan 17. 2003
sigmas=floor(SampleFactor.^(e1:e2));

%sigmas=round(SampleFactor.^(e1:e2)*TimeUnits);
TestedKernelWidths=sigmas*TimeUnits;

%
% 2) LOOP over sigams
%
for i=1:length(sigmas)-1
  kernel1=makeKernel('form',KernelForm,'sigma',sigmas(i)*TimeUnits,'TimeStampResolution',TimeUnits);
  kernel2=makeKernel('form',KernelForm,'sigma',sigmas(i+1)*TimeUnits,'TimeStampResolution',TimeUnits);
  if i==1
      A=InputSpikeMatrix(left-floor(length(kernel1)/2): ...
                                   right+floor(length(kernel1)/2),:);
	  % changed Aug 2001 : former : right+ceil(length(...
	  % corrected Jan 2000 : former: (l+1-floor(len... 
	  % corrected Oct 25, 1999: former: r+1+ceil(....
       AC=filter(kernel1,1,A);
       AC=AC(length(kernel1)+1:end,:);
  else
       A=B;
       clear B
       AC=BC;
       clear BC
  end;
  B=InputSpikeMatrix(left-floor(length(kernel2)/2): ...
			right+floor(length(kernel2)/2),:);
	  % changed Aug 2001 : former : right+ceil(length(...
	  % corrected Jan 2000 : former: (l+1-floor(len... 
  BC=filter(kernel2,1,B);
  BC=BC(length(kernel2)+1:end,:);
  %
  % Compute MISE
  %
        DIF=BC-AC;
	D(i,:)=sum(DIF.*DIF,1)*TimeUnits;
	clear DIF	    
end;  % LOOP over sigmas

%
% 3) determine best sigma for each trial
%
if find(D==0) % no unique minimum 
  [position,trial]=find(D==0);
  disp(['0 difference in trials ',num2str(unique(trial)'), ...
	' -> kernel sigma set to maximum'])
  [su,sv]=find(InputSpikeMatrix(left:right,unique(trial)));
  if isempty(sv)
    disp('    for reason of zero spike activity within observation interval')
  end;
  OptimalKernelWidth(unique(trial))=max(sigmas)/TimeUnits;
  for i=1:size(D,2)
    if find(i==unique(trial));
    else
    u=find(D(:,i)==min(D(:,i)));
    switch biasflag
    case 'low'
       OptimalKernelWidth(i)=sigmas(u)/TimeUnits;
    case 'high'
       OptimalKernelWidth(i)=sigmas(u+1)/TimeUnits;
    end;
  end;
end;
%
%
else; % normal case
  MIN=repmat(min(D),size(D,1),1);
  [u,v]=find(D-MIN==0);
  switch biasflag
    case 'low'
       OptimalKernelWidth=sigmas(u)*TimeUnits;
    case 'high'
       OptimalKernelWidth=sigmas(u+1)*TimeUnits;
  end;
  % takes the lower value of the two subtracted
end;


