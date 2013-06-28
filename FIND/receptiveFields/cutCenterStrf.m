function centerRF=cutCenterStrf(varargin)
% calculates spike triggered covariance and returns those filters where
% eigenvectors are significant if stated
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
%
%
%
%
%
% Henriette Walz 03/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'stimulus','spikeTrain', 'responseEntities','STA'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'ifRawCov'};
ifRawCov=0;

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

posEntityIDs=[];
for j=1:length(responseEntities)
    posEntityIDs=[posEntityIDs,find(nsFile.Analog.DataentityIDs==responseEntities(j))];
end

stim_s=size(stimulus);
resp_s=size(spikeTrain);

if prod(stim_s(1:end)<prod(stim_s(2:end))
else
    STA=reshape(stimulus,sqrt(stim_s(2)),sqrt(stim_s(2)));
end

[maxIndexX,maxIndexY]=find(STA{2}(1,1,:)==(max(abs(STA{2}(2,1,:)))));
indices=[maxIndexX-3,maxIndexX+3,maxIndexY-3,maxIndexY+3];
if indices<1 || indices>89
   
end

CenterRF=stimulus
