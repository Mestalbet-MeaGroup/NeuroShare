function [iint,ifin] = initfin(BinaryFiringSequence,type)
% [iint,ifin] = initfin(BinaryBurstSequence)
%
% Provides initial and final indexes of bursts/Spikes within binary
% sequence BinaryFiringSequence
%
% Input:
% BinaryFiringSequence: binary sequence of firing (1 if firing, 0
% otherwise) - usually each element corresponds to a time bin
%
% Output:
% iint: initial instants
% ifin: final instants
%
% Both iint and ifin have the same length of input and are logical vectors.
%
% v1.0
% Maurizio De Pitta', Tel Aviv, March 26th, 2009.

if nargin<2
    type = '';
end

iint = and(BinaryFiringSequence,~[0 BinaryFiringSequence(1:end-1)]);
ifin = and(BinaryFiringSequence,~[BinaryFiringSequence(2:end),0]);

if ~strcmp(type,'logical')
    iint = find(iint);
    ifin = find(ifin);
end

