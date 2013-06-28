function d=calculateSpikeMetrics(varargin) 
% calculates the distance between spike trains in nsFile.Neural.Data of the analog indices specified in IDs.  
%
%%%%%% Obligatory Arguments %%%%%%%%%%%%%%%%
%
%  x: the first group of two between which synchrony should be calculated (the
% entity IDs), or one group of which each pairwise combination should be
% tested
%   cost: penalty assigned for shifting the spike 1 second!
%%%%% Optional Arguments
%
% y: second group of two which should be compared
% trialDuration: in second
% baseDuration: baseline activity before and after trials in second
% ifplot
% grouping: 
%   - 'all': in one group all combination
%   -'two': two groups which should be compared
%   - 'trials': in one entity the trials should be compaired
%
%%%% This script belongs to the FIND toolbox
% 
% H.Walz July 08 adapted from 
% Copyright (c) 1999 by Daniel Reich and Jonathan Victor. 
% Translated to Matlab by Daniel Reich from FORTRAN code by Jonathan Victor. 


% obligatory argument names
obligatoryArgs={'x','cost'};        

% optional arguments names with default values
optionalArgs={'trialDuration','baseDuration','ifplot','y','grouping'};
trialDuration = 9;
baseDuration=0.5;
ifplot=0;
y=[];
grouping='all';

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);



global nsFile

switch grouping
    case 'all'
    y=x;
    xc=0;
    numa=length(x);
    numb=length(x);
    maxCounts=factorial(numa)/(factorial(numa-2)*factorial(2));
    case 'two groups'
    if isempty(y)
        error('second group of comparison is missing')
    end
    xc=1;
    numa=length(x);
    numb=length(y);
    case 'trials'
    xc=0;
    pos=find(nsFile.Neural.EntityID==x);
    posAnalog=find(nsFile.Analog.DataentityIDs==x);
    numa=length(nsFile.Event.Data);
    numb=length(nsFile.Event.Data);
    maxCounts=factorial(numa)/(factorial(numa-2)*factorial(2));
end
 n=0;
for na=1:numa
    if xc
        nn=1;
    elseif xc==0
        nn=na+1;
    end
    for nb=nn:numb
        n=n+1;
        if strcmp(grouping,'all') || strcmp(grouping,'two')
            posA=find(nsFile.Neural.EntityID==x(na));
            posB=find(nsFile.Neural.EntityID==y(nb))
            spa=nsFile.Neural.Data{posA};
            spb=nsFile.Neural.Data{posB};
        elseif strcmp(grouping,'trials')
            sr=nsFile.Analog.Info(posAnalog).SampleRate;
            spa=nsFile.Neural.Data{pos}(nsFile.Neural.Data{pos}*sr>nsFile.Event.Data(na) & nsFile.Neural.Data{pos}*sr<nsFile.Event.Data(na)+trialDuration*sr)-nsFile.Event.Data(na)/sr;
            spb=nsFile.Neural.Data{pos}(nsFile.Neural.Data{pos}*sr>nsFile.Event.Data(nb) & nsFile.Neural.Data{pos} *sr<nsFile.Event.Data(nb)+trialDuration*sr)-nsFile.Event.Data(nb)/sr;
        end
        nspa=length(spa);
        nspb=length(spb);

        if nspa && nspb
            if cost==0
                d(n)=abs(nspa-nspb)/(nspa+nspb);
                continue
            elseif cost==Inf
                d(n)=nspa+nspb/(nspa+nspb);
                continue
            end

            scr=zeros(nspa+1,nspb+1);
            %
            % INITIALIZE MARGINS WITH COST OF ADDING A SPIKE
            %

            scr(:,1)=(0:nspa)';
            scr(1,:)=(0:nspb);
            if nspa & nspb
                for ii=2:nspa+1
                    for j=2:nspb+1
                        scr(ii,j)=min([scr(ii-1,j)+1 scr(ii,j-1)+1 scr(ii-1,j-1)+cost*abs(spa(ii-1)-spb(j-1))]);
                    end
                end
            end

            d(n)=scr(nspa+1,nspb+1)/(nspa+nspb);
        else
            d(n)=-1;
        end
    end
end