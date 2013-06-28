clear;

myOnset=0:200:800; % parameterizable

mySpike = {};
for iOnset = 1:length(myOnset)
    load(['tmp/ramp/ramp' num2str(myOnset(iOnset)) 'Trial10.mat']);
    markers = find(Data.gdf(:,1)==Data.TrialParameters.Marker);

    % store gdf data to mySpike
    for nTrial=1:Data.TrialParameters.NumberOfTrials
        if nTrial < length(markers)
            myGdf = Data.gdf(markers(nTrial):markers(nTrial+1), :);
        else
            myGdf = Data.gdf(markers(end):end, :);
        end
        for nProcess=1:Data.TrialParameters.NumberOfProcesses
            mySpike(end+1)=num2cell(myGdf(find(myGdf(:,1)==nProcess),2),1);
        end
    end
end

ISI = []; spikeCount = []; myStart = 1; myEnd = 50; FF = []; myFlag = 0;

% calculates FF
while myEnd <= 250

    for i = 1:5
        spikeCount = [];
        for j = myStart:5:myEnd
            myTrain = cell2mat(mySpike(j));
            ISI = [ISI; diff(myTrain)];
            spikeCount = [spikeCount length(myTrain)];
        end
        FF(end+1) = var(spikeCount) / mean(spikeCount);
        myStart = myStart + 1;
    end
    myStart = myStart + 45; myEnd = myEnd + 50;

    myFlag = myFlag + 1;

end

cv = std(ISI) / mean(ISI);
meanFF = mean(FF)
stdFF = std(FF)
myFlag

BinSizeMs = 3;
edges = 0:BinSizeMs:max(ISI);
%{
bar(edges, histc(ISI, edges));
xlim([0 inf]);
xlabel('ISI in ms');
ylabel('ISI count');
title(['Interspike interval distribution CV=' num2str(cv)]);
%}