function [CountMat,EdgesMs]=pp_Gdf2CountMat(gdf,BinSizeMs,NumberOfSteps)
%   Converts the gdf (in ms-resolution) into a matrix of spikecounts (each
%   column ~ one neuron, each row ~ one timebin)
%   
%   INPUT:        gdf  - Data in ms Resolution
%                 BinSizeMs - Size of Analysis Window in ms!!!!
%                 NumberOfSteps - desired length of CountMat (optional);
%
%
%  OUTPUT: CountMat - matrix of counts, each column corresponds to one
%                       channel
%          EdgesMs  - position of the bins  
%
%  REMARKS: Data is required to be in ms Resolution and to start at 0!!!
%  
% History: 20.12.05 -   changed output format to oen neuron per column, one
%                       timepoint per row!
% Version 1.0
% HISTORY: 11.1.06 included optional NumberOfSteps
% 14/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the Point Process Toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Resulting Parameters
ProcessIds=unique(gdf(:,1));
NumberOfProcesses=length(ProcessIds);
TimeMinMs=0;
TimeMaxMs=max(gdf(:,2));
TotalTimeMs=TimeMaxMs-TimeMinMs;


%%%%%%%%%%%%%%%%%%%%%  Analysis     %%%%%%%%%%%%%%%%%%%%%%%%%%

EdgesMs=0:(BinSizeMs):TotalTimeMs;
CountMat=zeros(length(EdgesMs),NumberOfProcesses);

for jj=1:NumberOfProcesses
    ProcessId=ProcessIds(jj);
    idx=find(gdf(:,1)==ProcessId);
    if length(idx)==0
        CountMat(:,jj)=0;
    else
        TimesMs=gdf(idx,2);
        CountMat(:,jj) = histc(TimesMs,EdgesMs);
    end
end


if nargin==3
    if size(CountMat,1) < NumberOfSteps
        CountMat(NumberOfSteps,NumberOfProcesses)=0;
    elseif size(CountMat,1) > NumberOfSteps
        CountMat=CountMat(1:NumberOfSteps,:);
    end
end


