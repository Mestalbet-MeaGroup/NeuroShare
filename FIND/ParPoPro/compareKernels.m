function compareKernels(filename,profile,kernel)
%compareKernels plots original spike trains with rate profile and the 
%               curve after filtering with different kernels
%
%   Usage: compareKernels(filename, profile, kernel);
%
%   @param filename - file saved after simulation (usually .mat), which
%                     contains the spike train data in gdf format
%   @param profile - rate profile (.dat)
%   @param kernel - type of kernel used to filter the original spike
%                   trains, choices are 'gauss', 'exp' and 'exprev'


tic

% define the initial value of kernel width, also related to sampling rate
samplingFactor=100;

load(filename);

% initializing a binary matrix for spike timing
myMatrix = zeros(Data.TrialParameters.NumberOfProcesses, ...
    Data.TrialParameters.TrialDurationMs*100/samplingFactor); 
for i = 1:size(Data.gdf, 1)
    if Data.gdf(i,1) ~= Data.TrialParameters.Marker
        myMatrix(Data.gdf(i,1), Data.gdf(i,2)*100/samplingFactor) = 1;
    end
end

tau=[1 2 5 10];
tau=tau*samplingFactor;
cm=jet;
%figure;
rateProfile=load(profile); 

% adjusting rate vector at the new sampling rate
myProfile=[]; 
for i=1:size(rateProfile,2)
    myProfile(:,i)=interp1(1:Data.TrialParameters.TrialDurationMs,...
        rateProfile(:,i),...
        .01*samplingFactor:.01*samplingFactor:Data.TrialParameters.TrialDurationMs);
end

[nProcesses duration]=size(myMatrix);

% plotting
for k=1:nProcesses
    
% spike train with rate profile (lhs)
subplot(nProcesses,2,2*k-1);

[ax h1 h2]=plotyy(.01*samplingFactor:.01*samplingFactor:(duration*.01*samplingFactor),...
    myMatrix(k,:),.01*samplingFactor:.01*samplingFactor:(duration*.01*samplingFactor),...
    myProfile(:,k),'stem','plot');

%myMin=min(rateProfile);myMin=min(myMin)-10;
myMax=max(rateProfile);myMax=max(myMax)+10;

set(ax(2),'Position',get(ax(1),'Position'));
set(get(ax(2),'Ylabel'),'String','Hz'); 
set(h2,'Color','r');
set(ax(2),'YLim',[0 myMax],'YTick',0:myMax/2:myMax); 
set(ax(2),'YColor','k');
set(ax(1),'YColor','k');
set(ax(1),'YLim',[-1 2]);
set(h1,'Marker','none');
set(ax(1),'YTick',[0 1]);

xlabel('ms');
title(['train' num2str(k)]);

if k==1
% suptitle
myXLim=get(gca,'XLim');
myYLim=get(gca,'YLim');
text(myXLim(2)*1.1,myYLim(2)*1.3,kernel,'fontsize',14);
end

% convolved curve (rhs)
subplot(nProcesses,2,2*k);

j=1;
for i=1:length(tau)
    if strcmp(kernel,'gauss')
        trainFiltered=conv(myMatrix(k,:),...
            normpdf(-5*tau(i):0.01*samplingFactor:5*tau(i),0,tau(i)));
        trainFiltered=trainFiltered(500/samplingFactor*tau(i):end-500/samplingFactor*tau(i));
    elseif strcmp(kernel,'exp')
        trainFiltered=conv(myMatrix(k,:),...
            exppdf(0:.01*samplingFactor:5*tau(i),tau(i)));
        trainFiltered=trainFiltered(1:end-500/samplingFactor*tau(i)+1);
    elseif strcmp(kernel,'exprev')
        trainFiltered=conv(myMatrix(k,:),...
            1/tau(i)*exp((-5*tau(i):.01*samplingFactor:0)./(tau(i))));
        trainFiltered=trainFiltered(500/samplingFactor*tau(i):end);
    else
        error('Please specify a kernel, either gauss, exp or exprev...');
    end

    plot(0:.01*samplingFactor:(duration*.01*samplingFactor),...
        trainFiltered,'Color',cm(j,:));
    xlim([0 duration*.01*samplingFactor]);
    hold on;
    j=j+21;
end

c=colorbar(cm);

set(c, 'YTick', 1:21:64);
set(c, 'YTickLabel', tau);
set(get(c,'YLabel'),'String','kernel width (ms)');

xlabel('ms');
ylabel('kHz');
title(['train' num2str(k) ' convolved with kernels with different widths']);

end

toc
