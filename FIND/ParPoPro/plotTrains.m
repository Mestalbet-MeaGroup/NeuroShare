%plotTrains generates a raster plot for each simulation

mySpike={};

myOnset=0:200:800; % parameterizable

for iOnset=1:length(myOnset)
    
% load the file containing spike times
load(['tmp/ramp/ramp' num2str(myOnset(iOnset)) 'Trial10.mat']);
% load rate function
rateProfile = load(['Data/RateNonStatRamp' num2str(myOnset(iOnset)) '.dat']);

samplingFactor = 100; % sampling at 1 ms
markers = find(Data.gdf(:,1)==Data.TrialParameters.Marker);

% store gdf data to mySpike
for nTrial=1:Data.TrialParameters.NumberOfTrials
    if nTrial < length(markers)
        myGdf = Data.gdf(markers(nTrial):markers(nTrial+1), :);
    else
        myGdf = Data.gdf(markers(end):end, :);
    end
    for nProcess=1:Data.TrialParameters.NumberOfProcesses
        mySpike(nTrial, nProcess)=num2cell(myGdf(find(myGdf(:,1)==nProcess),2),1);
    end
end


myCell={};

for jProcess=1:nProcess

    subplot(length(myOnset), nProcess, nProcess*(iOnset-1)+jProcess);
    hold on;

    for iTrial=1:nTrial

        myMatrix = zeros(1, ...
            Data.TrialParameters.TrialDurationMs*100/samplingFactor);
        myMat=cell2mat(mySpike(iTrial, jProcess));

        for i = 1:length(myMat)
            if myMat(i)*100/samplingFactor-1000*(iTrial-1) ~= 0
                myMatrix(1, myMat(i)*100/samplingFactor-1000*(iTrial-1)) = 1;
            end
        end

        duration=length(myMatrix);

        % plot raster plot and rate profile together
        [ax h1 h2]=plotyy(.01*samplingFactor:.01*samplingFactor:(duration*.01*samplingFactor),...
            myMatrix*iTrial,.01*samplingFactor:.01*samplingFactor:(duration*.01*samplingFactor),...
            rateProfile(:,jProcess),'plot');
        
        % adjust axes properties
        myMax=max(rateProfile);myMax=max(myMax)+10;
        set(h1,'LineStyle','.');
        set(h2,'Color','r');
        set(ax(2),'YLim',[0 myMax],'YTick',0:myMax/2:myMax,...
            'YTickLabel', {'0Hz'; '55Hz'; '110Hz'});
        xlabel('ms','fontsize',8);

    end
    
    hold off;

    set(ax(2),'Position',get(ax(1),'Position'));
    set(ax(2),'YColor','k');
    set(ax(1),'YColor','k');
    set(ax(1),'YLim',[0.2 nTrial+0.2], 'YTick', 2:2:nTrial);


end % iterate over different slopes

end % iterate over different onsets



