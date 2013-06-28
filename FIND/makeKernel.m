function [kernel,norm,m_idx] = makeKernel(varargin)
% function makeKernel(varargin)
%
% Constructs a numeric linear convolution kernel of basic shape to be used
% for data smoothing (linear low pass filtering) and firing rate estimation
% from single trial or trial-averaged spike trains. Exponential and alpha
% kernels may also be used to represent postynaptic currents / potentials
% in a linear (current-based) model.
%
% %%%%% Obligatory Parameters %%%%%
%
%   form        :   kernel form (string) Currently implemented forms are
%                   BOX - boxcar, TRI - triangle, GAU - gaussian, EPA -
%                   epanechnikov, EXP - exponential, ALP - alpha function
%                   EXP and ALP are aymmetric kernel forms and assume
%                   optional paramter 'direction'
%
%   sigma       :   standard deviation of the distribution associated with
%                   kernel shape. This paramters defines the time
%                   resolution of the kernel estimate and makes different
%                   kernels comparable (cf. [1] for symetric kernels). This
%                   is used here as an alternative definition to the cut-off
%                   frequency of the associated linear filter.
%
%   TimeStampResolution :  temporal resolution of input and output in SI
%                          units. E.g. value 0.001 means 1ms time
%                          resolution
%
% %%%%% Optional Parameters %%%%%
%
%   direction   :   Asymmetric kernels have two possible directions. The
%                   values are -1 or 1, default is 1. The definitoin here
%                   is that for direction 1 the kernel represents the impulse
%                   response function of the linear filter.
%
%
%   Output Variables
%
%   kernel      :   array of kernel. The length of this array is always an
%                   odd number to represent symmetric kernels such that the
%                   center bin coincides with the median of the numeric
%                   array, i.e for a triangle, the maximum will be at the center
%                   bin with equal number of bins to the right and to the left.
%
%   norm        :   for rate estimates. The kernel vector is normalized
%                   such that the sum of all entries euals unity
%                   sum(kernel)=1. When estimating rate functions from
%                   discrete spike data (0/1) the additional paramter 'norm' allows for
%                   the normalization to rate in spikes per second. Use:
%                   RATE = norm*filter(kernel,1,spike_data);
%
%   m_idx       :   index into 'kernel' points at numerically determined
%                   median (center of gravity)
%
%
%
% Further comments:
%
%   Assume matrix S of n spike trains represented as binary vector (0/1).
%   To obtain single trial rate function of trial i use
%        r=norm*filter(kernel,1,X(:,i));
%   To obtain trial-averaged spike train use
%       r_avg=norm*filter(kernel,1,mean(X,2));
%   Use 'filter' or 'conv' for convolution. This is fastest along first
%   dimension (column representation of spike trains).
%
%   Note that filter assumes a causal filtering. To represent the resulting
%   firing rate function at center of gravity (acausal) use
%
%       r=r(length(kernel):end);    -> discard first length(kernel)-1
%                                   elements which considered zero entries
%                                   (border effect)
%       t=((1:length(r))+m_idx)*TimeStampResolution -> in seconds
%       plot(t,r)   -> in second time scale
%
%
%
%
%
% History
%
%       (0) Feb 14, 2008. Martin Nawrot (nawrot@neurobiologie.fu-berlin.de)
%        based on former version 'kernel_make.m' (1997). Similar to
%        version re_kernelmake implemented in the MEA-tools (2000)
%
%
%
% --------------------------------------------------
% Original References of this tool
%
%   [1] Nawrot M, Aertsen A, Rotter S (1999)
%       Single-trial estimation of neuronal firing rates - From single neuron
%       spike trains to population activity.
%       J Neurosci Meth 94: 81-92
%
%   [2] Meier R, Egert U, Aertsen A, Nawrot M (2008)
%       FIND - a unified framework for neural data analysis
%       (submitted manuscript)
%       -> application: time-derivative of rate function from 
%          single trial spike trains
%
%
% Futhere References: Analysis used in .....
%
%   [3] Nawrot MP, Boucsein C, Rodriguez-Molina V, Riehle A, Aertsen A, Rotter S (2007)
%       Measurement of variability dynamics in cortical spike trains.
%       J Neurosci Meth, doi:10.1016/j.jneumeth.2007.10.013
%       -> application to rate estimation and to generation of noise
%       currents for current injection in patch clamp recordings in vitro.
%

% Author of this Function (Year)
%
%   Martin Nawrot 2008. Original version from 1997
%



% obligatory argument names
obligatoryArgs={{'form', @(value) ismember(upper(value),{'BOX','TRI','GAU','EPA','EXP','ALP'})},'sigma','TimeStampResolution'}; %-% e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={'direction'};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% default for optional paramter
direction=1;
% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

% ========================================================================

norm=1/TimeStampResolution;

switch upper(form)

    case 'BOX'

        w=2*sigma*sqrt(3);                  % support width (cf. [1]) CORRECTED WITH *2 8.12.97
        width=2*floor(w/2/TimeStampResolution)+1;    % always odd number of bins
        higth=1/width;                      % sum equals one
        kernel=ones(1,width)*higth;         % area=1

    case 'TRI'

        w=2*sigma*sqrt(6);                  % support width (cf. [1])
        halfwidth=floor(w/2/TimeStampResolution);
        trileft=(1:halfwidth+1);
        triright=(halfwidth:-1:1);          % odd number of bins
        triangle=[trileft,triright];
        kernel=triangle/sum(triangle);      % now area equals 1

    case 'EPA'

        w=2*sigma*sqrt(5);                  % support width (cf. [1])
        halfwidth=floor(w/2/TimeStampResolution);    % always odd number of bins
        base=(-halfwidth:halfwidth);
        parabell=base.^2;
        epanech=max(parabell)-parabell;     % inverse parabula starting at (-width;0)
        kernel=epanech/sum(epanech);        % area = 1;


    case 'GAU'

        SIsigma=sigma/1000;
        w=2*sigma*2.7;                      % > 99% of distribution weigth
        halfwidth=floor(w/2/TimeStampResolution);    %always odd number of bins
        base=(-halfwidth:halfwidth)/1000*TimeStampResolution;
        g=exp(-(base.^2)./2./SIsigma^2)./SIsigma./sqrt(2*pi);  %compute gauss
        kernel=g/sum(g);

    case 'ALP'

        SIsigma=sigma/1000;
        w=5*sigma;                          % accounts for 99.3145% of the distribution weight
        alpha=(1:2*floor(w/TimeStampResolution/2)+1)/1000*TimeStampResolution;     % always odd number of bins (added May 25, 2006)
        alpha=(2/SIsigma^2)*alpha.*exp(-alpha*sqrt(2)/SIsigma);  %compute alpha
        kernel=alpha/sum(alpha);            % normalization
        if direction <=-1
            kernel=fliplr(kernel);
        end;

    case 'EXP'

        SIsigma=sigma/1000;
        w=5*sigma;                          % accounts for 99.3262% of the distribution weight
        expo=(1:2*floor(w/TimeStampResolution/2)+1)/1000*TimeStampResolution; %always odd number of bins (added May 25, 2006)
        expo=exp(-expo/SIsigma);
        kernel=expo/sum(expo);              % normalization
        if direction <=-1
            kernel=fliplr(kernel);
        end;

end;

m_idx=min(find(csum(kernel)>=0.5));



