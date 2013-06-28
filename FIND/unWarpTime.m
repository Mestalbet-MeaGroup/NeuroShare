function opevents = unWarpTime(varargin)
% function opevents = unWarpTime('amplitude',vec,'events',vec)
%
% Returns a stationary version of the list of non-negative integer counts 'events', 
% assuming that time runs at velocity 'amplitude'. See als 'warpTime'.
%
% --- Obligatory Parameters ---
%
%   amplitude       : 'velocity of time' as function of time f(t) - column vector
%   events          : non-negative integer count - column vector
%
% --- Output Variables --------
%   
%   opevents        : non-negative integer count vector with unit rate
%
%   If we intepret events as the vector of count number of spikes for a fix width 
%   count window, then f is the rate of spike count. For small count window
%   where the entries are either 0 or 1, events is a binary representation of a
%   spike train an f is the firing probability per time bin.
%
%   unWarpTime performs the inverse operation of 'warpTime'. It
%   'demodulates' the vector events according to the function f. The resulting
%   count vector Y assumes a flat rate.
%
%   The general concept of operational time assumes a stochastic counting process 
%   with unit rate in operational time. The realisation of such a process
%   may be transformed to a different time axis where it follows predifined
%   rate function f, numerically this is performed using the 'warpTime'
%   function. This is an efficient method for simulating stochastic point processes 
%   with time-varying rate. 'unWarpTime' performs the inverse
%   transformation of a realisation of a counting process with time varying
%   rate to the operational time axis where the rate is constant.
%
%
% History
%
%  (0) Feb 21, 2000 orignal version by Stefan Rotter
%      adapted to FIND by Martin Nawrot (Feb 19, 2008)
%  
%  Original Version: 'unwarp.m'
%
%  Version 1.1 - 21/02/00 - rotter@biologie.uni-freiburg
%
%  Y = unwarp(f,X) gives a stationary version of the list of
%  non-negative integer counts X, assuming that time runs at
%  velocity f. Uniform distribution of events over bins is
%  assumed, and positions are assigned randomly. This implies
%  that ties are also broken randomly. Both f and X are assumed
%  to be column vectors, X may also be a matrix of column vectors.
%  See also Reich et al., JNeurosci 18(23):10090-10104, 1998.

% --------------------------------------------------
% Original References of this tool
%
% [1] Reich DS, Victor JD, Knight BW (1998) The power ratio and the interval map: spiking
% models and extracellular recordings. J Neurosci 18: 10090–104.
%
% [2] Brown EN, Barbieri R, Ventura V, Kaas RE, Frank LM (2001) The time-rescaling
% theorem and its application to neural spike train data analysis. Neural
% Comput 14: 325–46.
%
% [4] Nawrot MP, Boucsein C, Rodriguez-Molina V, Riehle A, Aertsen A, Rotter S (2007) 
% Measurement of variability dynamics in cortical spike trains. J Neurosci Meth, 
% doi:10.1016/j.jneumeth.2007.10.013
% -> review of unwarping method
% -> calibration of unWarpTime method on and its application to the CV
% measurement using point process simulations and in vitro control experiments
%

% obligatory argument names
obligatoryArgs={'amplitude','events'}; %-% e.g. {'x','y'}
optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

%----------------------------------------------------------------------
% Locate all events, account for multiple points.
%----------------------------------------------------------------------

[I J] = find(events);

for k = 2:max(events(:));

  [i j] = find(events>=k);

  I = [I;i]; J = [J;j];

end

%----------------------------------------------------------------------
% Assume points to be distributed uniformly within their bins.
%----------------------------------------------------------------------

F = filter(1,[1,-1],[0;amplitude]);

I = F(I)+rand(size(I)).*amplitude(I);

B = F(end)/size(amplitude,1) * (0:size(amplitude,1))';

%----------------------------------------------------------------------
% Count points according to operational time F.
%----------------------------------------------------------------------

opevents = zeros(size(events));

for k = 1:size(opevents,2)

  h = histc(I(J==k),B);

  opevents(:,k) = h(1:end-1);

end





