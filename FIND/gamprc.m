function result = gamprc(tMin,tMax,rate,shapeParam,nRealizations,varargin)
% Simulate gamma point processes
% called by simulateGammaGUI
%
% Version 1.2 - 2007-03-07 David Reichert
% Version 1.1 - 06/02/05 - stefan.rotter@biologie.uni-freiburg
%
%
% 1.2 changelog: Removed divide by zero warning for rate=0, added comments,
% used (hopefully) more descriptive variable names; and, changed form of
% return value to cell array to save memory. Originally it was a matrix
% with two colums, the trial number being stored explicitely in the first 
% one. Now the trial is given implicitely as index of the cell array. 
% (Note: The result cannot be simply a matrix with the rows containing the
% event times of the different trials, because different trials can have 
% different numbers of events.)
%
%
% result = gamprc(tMin,tMax,rate,shapeParam,nRealizations) gives
% 'nRealizations' independent realizations of a stationary gamma-process on
% [tMin,tMax], with rate 'rate' and shape parameter 'shapeParam' of the
% interval distribution. The result is a cell array with 'nRealizations'
% elements, each an array containing the times of one trial's events. An
% optional argument is either 'Equilibrium' (default) or 'Ordinary'. In the
% latter case each realization starts with an event at tMin. For details,
% see DR Cox, Renewal Theory, Chapman and Hall, 1967.

%----------------------------------------------------------------------
% Remarks:
%
% 1. This simulation tool draws a sequence of i.i.d. intervals.  Therefore,
% the actual number of events can only be approximately predicted and must
% be determined by iteration.
%
% 2. Don't use cumsum(x) because of potential numerical problems. Use
% filter(1, [1 -1], x) instead.
%
% 3. Makes use of gamrnd.m from the Statistics Toolbox. The core of it
% might be transplanted to be independent of the toolbox.
%
% 4. Using the paramters of the MATLAB gamma distribution, a and b, it 
% holds that rate=1/(ab), shapeParam=a.
%
% 5. For the equilibrium case: The first interval (forward recurrence time)
% is drawn from the exact equilibrium distribution. If f(x) is the p.d.f. 
% of the interval distribution and mu is the mean interval, then x*f(x)/mu 
% is the p.d.f. that a random point hits an interval of length x. The 
% position of the random point is then uniformly distributed over the 
% interval.
%
% 5b: The above formula can be made plausible in the following way: The aim
% is to randomly choose the duration until the first event occurs after
% time onset. This situation corresponds to first choosing a point in a
% gamma process at random as time onset, and then determining the duration
% from there to the next event.
%
% One now has to consider the length of the inter-event-interval into which
% the time onset falls. What is the probability of a certain interval
% length being selected in this manner? Of course, here the occurrence of
% intervals is governed by the gamma distribution, g(x), where x is the 
% length of the interval. However, when placing a point at random in the
% process, it is more likely to hit a longer interval than a short one.
% Hence, the gamma probability distribution is furthermore weightened with
% x. The factor mu then results from the normalization of the probability
% distribution.
%
% After the interval is drawn from the above distribution it needs to be
% determined where the time onset tMin falls inside the interval. Here,
% every position is equally likely. Hence, the position of the interval's
% right end, which marks the time of the first event in the equilibrium
% process, is taken (uniformly) randomly within [tMin, tMax + x].
%
% Finally, to actually draw the interval x, one can make use of the fact
% that x * g(x, shapeParam, rate) / mu = g(x , shapeParam + 1, rate).
% Hence, the gamma distribution gamrnd from MATLAB can be utilized.
%----------------------------------------------------------------------

%----------------------------------------------------------------------
% Determine the type of process.
%----------------------------------------------------------------------

% default value
type = 'Equilibrium';
 
for i = 1:length(varargin)
  switch varargin{i}
    case {'o', 'ordinary', 'Ordinary'}
      type = 'Ordinary';
    case {'e', 'equilibrium', 'Equilibrium'}
      type = 'Equilibrium';
    otherwise
      error(['Unknown option ', varargin{i}, '.']);
  end
end

%----------------------------------------------------------------------
% Draw random sequence of intervals, take care of first interval.
%----------------------------------------------------------------------

duration = tMax - tMin;
if rate == 0
    meanInterval=inf;
else
    meanInterval = 1/rate;
end

%----------------------------------------------------------------------
if shapeParam == inf                % Clock starting with random phase.
%----------------------------------------------------------------------

switch type
  case 'Equilibrium'
    firstIntervals = rand(nRealizations,1) * meanInterval;
  case 'Ordinary'
    firstIntervals = zeros(nRealizations,1);
  otherwise
    error('Internal error. Exiting.');
end

for i = 1:nRealizations
    result{i} = (tMin + firstIntervals(i) : meanInterval : tMax);
end

%----------------------------------------------------------------------
elseif shapeParam > 0                              % Covered by gamrnd.
%----------------------------------------------------------------------

switch type
  case 'Equilibrium'
    firstIntervals = rand(nRealizations,1) .* ...
              gamrnd(shapeParam+1,meanInterval/shapeParam,nRealizations,1);
  case 'Ordinary'
    firstIntervals = zeros(1,nRealizations);
  otherwise
    error('Internal error. Exiting.');
end

for i = 1:nRealizations
  
  intervals = [firstIntervals(i) gamrnd(shapeParam,meanInterval/shapeParam, ...
                                        1,ceil(1.2*rate*duration))];
  while sum(intervals) < duration
    intervals = [intervals gamrnd(shapeParam,meanInterval/shapeParam, ...
                                  1,ceil(0.2*rate*duration))];
  end

  result{i} = filter(1, [1 -1], intervals);

  result{i} = result{i}(result{i}<=duration);
  result{i} = result{i} + tMin;

  
end

%----------------------------------------------------------------------
else                            % Must exclude non-positive shapeParam.
%----------------------------------------------------------------------

  error('Shape parameter must be a positive real number or inf!')

%----------------------------------------------------------------------
end                                                       % This is it.
%----------------------------------------------------------------------





