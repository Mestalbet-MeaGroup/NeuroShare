%plotKernelExample plots spike trains together with a filtering kernel

load(['tmp/ramp/ramp800Trial10.mat']);
rateProfile = load(['Data/RateNonStatRamp800.dat']);

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

% only plot 2 spike trains
for iTrial = 1:2

myMatrix = zeros(1, Data.TrialParameters.TrialDurationMs*100/samplingFactor); 

% only take the spike train with onset 800ms
myMat=cell2mat(mySpike(iTrial, 5));

duration = Data.TrialParameters.TrialDurationMs;
        
for i = 1:length(myMat)
    if myMat(i)*100/samplingFactor-1000*(iTrial-1) ~= 0
        % if necessary, subtract duration from the subsequent trial
        myMatrix(1, myMat(i)*100/samplingFactor-duration*(iTrial-1)) = 1;
    end
end

subplot(2, 1, iTrial);


[nProcesses duration]=size(myMatrix);

hold on;

myMat = myMat - duration*(iTrial-1);
tau = 50; % parameterizable

% Gaussian
%
trainFiltered=conv(myMatrix,normpdf(-5*tau:0.01*samplingFactor:5*tau,0,tau));

trainFiltered=trainFiltered(500/samplingFactor*tau:end-500/samplingFactor*tau);

for i = 1:length(myMat)
    % plot kernels
    plot(myMat(i)-5*tau:0.01*samplingFactor:myMat(i)+5*tau, ...
        125*normpdf(myMat(i)-5*tau:0.01*samplingFactor:myMat(i)+5*tau,myMat(i),tau),'r');
end
%

% Exp.
%{
trainFiltered=conv(myMatrix,exppdf(0:.01*samplingFactor:5*tau,tau));

trainFiltered=trainFiltered(1:end-500/samplingFactor*tau+1);

for i = 1:length(myMat)

    plot(myMat(i):0.01*samplingFactor:myMat(i)+5*tau, ...
        100*exppdf(0:0.01*samplingFactor:5*tau,tau),'r');
end
%}

% plot spike train, before and after convolution
[ax h1 h2] = plotyy(.01*samplingFactor:.01*samplingFactor:(duration*.01*samplingFactor),...
    myMatrix, ...
    0:.01*samplingFactor:(duration*.01*samplingFactor),...
    trainFiltered, 'stem', 'plot');

set(get(ax(2),'Ylabel'),'String','kHz', 'fontsize', 16);
set(h1,'Color','b', 'marker', 'none');
set(h2, 'color', [0.8 0.8 0.8], 'LineWidth', 3);
set(ax(2),'YLim',[0 0.15], 'YTick', 0:0.05:0.15, 'XLim', [0 1000]);
set(ax(2),'YColor','k', 'fontsize', 16);
set(ax(1),'YColor','k', 'fontsize', 16);
set(ax(1),'YLim',[-1 2], 'YTick', [0 1], 'XLim', [0 1000]);


xlabel('ms', 'fontsize', 16);
title(['Trial' num2str(iTrial)], 'fontsize', 16);

hold off;

end

%suptitle('Spike trains filtered with Gaussian kernel (\sigma=100ms)');
