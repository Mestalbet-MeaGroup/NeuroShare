function events=warpTime(varargin)
% function events = warpTime('duration',scalar/vec,'amplitude',vec,'opevents',vec)
%
% Useful for simulating non-homogenous point processes with defined
% time-varying rate (i.e. rate with piecewise constant amplitude). In a
% first step simulate a stationary process with unit rate and then pipe
% the realisation through warpTime with specified firing rate function. 
%
% --- Obligatory Parameters ---
%
%   duration        : duration for each piecewise constant rate. Either one positive number or a 
%                     column vector of the same length as amplitude 
%   amplitude       : vector of amplitudes associated with each duration.
%                     defines rate of events. expected number of events per bin is given by
%                     duration.*amplitude. if duration is fix and events were constructed with unit
%                     rate then amplitude may be interpreted as the velocity at which the process time 
%                     runs.
%   opevents        : non-negative integer of count (events in operational time) - column vector
%
%
% --- Output Variables --------
%   
%   events        : non-negative integer count vector following the
%                   specified rate
%
%
% History
%
%
%  (0) Feb 21, 2000 orignal version by Stefan Rotter
%      adapted to FIND by Martin Nawrot
%  
%  Original version name: 'warp.m'
%
% Version 1.0 - 28/01/05 - stefan.rotter@biologie.uni-freiburg
%
% events = warp(duration,rate,opevents) gives the time coordinates in real
% time for an array opevents of coordinates specified in operational time.
% Operational time corresponds to a piecewise constant rate specified by
% duration and amplitude on a per-bin basis. amplitude is a vector of
% arbitrary length. duration is either a positive number applying to all
% bins, or it is a vector of the same length as rate. opevents is a vector
% of numbers between 0 and the inner product of duration and amplitude.

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
% [3] Nawrot MP, Boucsein C, Rodriguez-Molina V, Riehle A, Aertsen A, Rotter S (2007) 
% Measurement of variability dynamics in cortical spike trains. J Neurosci Meth, 
% doi:10.1016/j.jneumeth.2007.10.013
% -> review of warping method


% obligatory argument names
obligatoryArgs={'duration','amplitude','opevents'};

% optional arguments names with default values
optionalArgs={}; 

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

%----------------------------------------------------------------------
% Remarks:
%
% 1. One must make sure that expected number of opevents is consistent with
% integrated rate given by duration*rate'.
%----------------------------------------------------------------------

opevents = opevents(:);
amplitude = amplitude(:);
duration = duration(:) .* ones(size(amplitude));

%----------------------------------------------------------------------
% Compute real time from durations, starting at 0.
%----------------------------------------------------------------------

time = filter(1, [1 -1], [0; duration]);

%----------------------------------------------------------------------
% Compute operational time using per-bin expectations.
%----------------------------------------------------------------------

optime = filter(1, [1 -1], [0; duration .* amplitude]);

%----------------------------------------------------------------------
% Apply inverse transform, assuming constant rate within each bin.
%----------------------------------------------------------------------

events = interp1q(optime,time,opevents);

%----------------------------------------------------------------------
% done!
%----------------------------------------------------------------------
