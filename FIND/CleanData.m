function out = CleanData(varargin)
% function out=CleanData(action, tdata);
%
% CleanData.m will clean the data array using a principal
% component analysis to find common signal across channels
% and remove it.  Edit the initialized value of the global variables in this
% file appropriately to optimize cleaning of your data.
% 
% The version embedded into FIND is adapted to some required structural 
% standards and spike detection was expanded.
%       
% step 1: get the data
% step 2: pca the data
% step 3: get list of putative spikes in data
% step 4: replace the spikes with the noise estimate
% step 5: do second order cleaning
% step 6: store cleaned data in nsFile
%
% If the data passed to the program is larger than the number points to 
% analyze in a 'chunk', the data will be analyzed in pieces, each of size 
% ptspercut. If this number is very large there may be memory limitations 
% which will slow down the computations. However, note also that spikes
% falling EXACTLY on a cut may be distorted because the noise estimates and 
% pca weights may differ in the adjacent chunks. The number of spikes so 
% affected is usually negligible, but is smaller for long chunks. 
% The problem can be completely eliminated by prewindowing the data around 
% relevant stimulus or behavioral events, and doing a second slightly 
% narrower windowing (by 5ms or so) after cleaning.
%
%
% %%%%% Parameters to be passed as parameter-value pairs:
%
% %%%%%%%%% Obligatory Parameters %%%%%%%%%%
%
% 'action': defines used processing step
%
%           possible actions:
%
%           "GetCleanedData" - contains the logic for the cleaning. Get raw
%           data, plot it and call cleaning steps successively
%
%           "FindBigStuff" - searches through the data for large events,
%           tentatively spikes. Change the logic for what should be
%           considered a spike here.
%
%           "ReplaceBigStuff" - Replaces the identified spikes with the
%           noise estimate.
%
%           "PlotData" - Displays the data and intermediates; edit this
%           code to change the way the data is displayed.
%
%           "ipca" and "pca2" are two pca routines used by the program
% 
%           " " - or anything else which result in a complete run
%           through the program - complete cleaning
%
%
% 'tdata': contains 3 or more continuous data sets to be cleaned
% 
%
% %%%%%%%%%% Optional Parameters %%%%%%%%%%
%
% 'loadMode': determine how data is stored
%
% 'zeroPadding': determine if zeropadding is used
%
% 'ptspercut': number of points in a 'chunk' of data (see sampling rate)
%
% 'dofilter': determine if data is filtered before spike detection
%
% 'thresholdFactor': set threshold for spike detection
% 
% 'analogDisplayOffset': number of analog units by which to displace each
%                        trace when displaying
%
% 'knownMedian': median used for calculating threshold
%
% 'prepts': additional points before threshold detection to replace
% 
% 'postpts': additional points after return under threshold to replace
%
% 'showWeights': show weighting applied to pc vectors 
%                The larger the number, the more noise has been removed
%                from that channel
%
% 'chunk': recent used chunk of data
%
%
% %%%%%%%%%% Notes:  %%%%%%%%%%
%
% The user has the option to edit the default variables to modify the way 
% the program cleans the data. Unless your conditions differ considerably, 
% we recommend starting with the values given here. 
%
%
%
% Example Call:
%
%    out=CleanData('action',NaN,'tdata',tdata,...
%         'plotData',1,'ptspercut',[25000],...
%         'doFilter',1,'detectMeth',[1],...
%         'prepts',[12],'postpts',[12],...
%         'thresholdFactor',[5],'knownMedian', [20],...
%         'analogDisplayOffset',[100],'ChannelEntityIDs',[1 4 7 9]);
%
%
% --------------------------------------------------
% This function is embedded into the FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
% (1.1) adapted to FIND by A. Kilias 04/08.
%
% Original Version by George Gerstein 
% Questions referring CleanData :  
%             jeff@mulab.physiol.upenn.edu
%			  george@mulab.physiol.upenn.edu



global nsFile; %-% if needed
try
    % obligatory argument names
    obligatoryArgs={'action','tdata'};

    % optional arguments names with default values
    optionalArgs={{'loadMode', @(val) ismember(val,{'prompt','append','overwrite'})},...
        {'zeroPadding', @(val) ismember(val,{'prompt','yes'})},...
        'plotData',...
        'ptspercut',...
        'doFilter',...
        'detectMeth',...
        'thresholdFactor',...
        'prepts',...
        'postpts',...
        'analogDisplayOffset',...
        'showWeights',...
        'knownMedian',...
        'ChannelEntityIDs',...
        'ptitle',...
        'biglist',...
        'replacearray',...
        'orig',...
        'chunk'};

    % default parameter values
    loadMode = 'prompt';
    zeroPadding = 'prompt';
    plotData='false';
    ptspercut = 25000;
    dofilter='true';
    thresholdFactor=2.5;
    analogDisplayOffset = 100;
    knownMedian=20;
    prepts = 10;
    postpts = 10;
    showWeights	='true';
    ptitle='';
    biglist=[];
    replacearray=[];
    orig=[];
    chunk=1;

    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,''); %used this format so that the '\n' are converted
    end

    % loading parameter value pairs into workspace, overwriting defaul values
    pvpmod(varargin);

    if ~isfield(nsFile,'Analog') || ~isfield(nsFile.Analog,'Data') ...
            || isempty(nsFile.Analog.Data)
        error('FIND:noAnalogData','No analog data found in nsFile variable.');
    end


    %% %%%%%%%%%%%%%%%% main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ischar(action)
        switch(action)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('GetCleanedData')

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%% step 1: get the tdata %%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % check the tdata

                if isempty(tdata)
                    out = [];
                    fprintf('Empty rawdata. Aborting.\n');
                    return;
                end

                [m,n] = size(tdata);

                if n < 3
                    out = [];
                    fprintf('Rawdata must have at least 3 channels. Aborting.\n');
                    return
                end

                if plotData
                    ptitle = ['raw - chunk ', num2str(chunk)];
                    CleanData('action','PlotData','tdata',tdata,'analogDisplayOffset',analogDisplayOffset,'ptitle',ptitle);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%% step 2: pca the tdata %%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                pcadata = CleanData('action','pca2','tdata',tdata);		% get 1st cleaned estimate
                pca12 = pcadata(:,[end-1 end]);			% last two columns are pca 1 and pca2
                pcadata(:,[end-1 end]) = [];				% get rid of them for now
                noiseEst = tdata - pcadata;				% get noise estimate
                NoSpikesData = tdata;						% copy of tdata for noise replacement

                % return;
                if plotData
                    ptitle = ['1st pca run - chunk ', num2str(chunk)];
                    CleanData('action','PlotData','tdata', pcadata,'analogDisplayOffset',analogDisplayOffset,'ptitle',ptitle);

                    ptitle = ['pca1 and pca2 - chunk ', num2str(chunk)];
                    CleanData('action','PlotData','tdata',pca12,'analogDisplayOffset',analogDisplayOffset,'ptitle',ptitle);

                    ptitle = ['noise estimate - chunk ', num2str(chunk)];
                    CleanData('action','PlotData','tdata',noiseEst,'analogDisplayOffset',analogDisplayOffset,'ptitle',ptitle);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%% step 3: get list of putative spikes in tdata %%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % find spike times using pca cleaned tdata
                biglist = CleanData('action','FindBigStuff',...
                    'tdata',pcadata,...
                    'ChannelEntityIDs',ChannelEntityIDs,...
                    'detectMeth',detectMeth,...
                    'doFilter',doFilter,...
                    'knownMedian', knownMedian,...
                    'thresholdFactor',thresholdFactor);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% step 4: replace the spikes with the noise estimate %%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % first use zeros to replace spikes
                % to avoid cross contamination of noise estimate
                % then replace spikes with noise estimate

                replacearray = zeros(m,n);
                NoSpikesData = CleanData('action','ReplaceBigStuff',...
                    'tdata',tdata,...
                    'biglist',biglist,...
                    'replacearray',replacearray,...
                    'prepts',prepts,...
                    'postpts',postpts);
                pcadata = CleanData('action','pca2','tdata',NoSpikesData);		% get 1st cleaned estimate
                pca12 = pcadata(:,[end-1 end]);		% last two columns are pca 1 and pca2
                pcadata(:,[end-1 end]) = [];		% get rid of them for now
                noiseEst = NoSpikesData - pcadata;	% get noise estimate
                replacearray = noiseEst;
                NoSpikesData = CleanData('action','ReplaceBigStuff',...
                    'tdata',tdata,...
                    'biglist',biglist,...
                    'replacearray',replacearray,...
                    'prepts',prepts,...
                    'postpts',postpts);	% now replace spikes with noise estimate

                if plotData
                    ptitle = ['spikes removed - chunk ', num2str(chunk)];
                    CleanData('action','PlotData','tdata',NoSpikesData,'analogDisplayOffset',analogDisplayOffset,'ptitle', ptitle);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%% step 5: do second order cleaning %%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                orig = tdata;
                out = CleanData('action','itpca','tdata',NoSpikesData,'orig',orig);

                if plotData
                    ptitle = ['final result - chunk ', num2str(chunk)];
                    CleanData('action','PlotData','tdata',out(:,1:end-2),....
                        'analogDisplayOffset',analogDisplayOffset,'ptitle',ptitle);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%% step 6: store cleaned data in nsFile %%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % store the data in a NEW entity ID
                     % --> this is done in CleanDataGUI
          

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('FindBigStuff')
                % finds spikes in the tdata and outputs them in gdf format
                % if you want to change the logic of what is a spike (for
                % example, if you want to use a template) change this code.

                %                 % first get the sd of each channel (column)
                %                 if strcmp(useSD,'true')
                %                     s = std(tdata);
                %                 end

                % now put ones wherever the tdata falls below n sd's of 0;
                spikelist = [];
                [m,n] = size(tdata);
                for tt=1:length(ChannelEntityIDs)
                    posChEntities(tt)=find(ChannelEntityIDs(tt)==nsFile.Analog.DataentityIDs);
                end
                if ~isfield(nsFile.Analog.Info(posChEntities), 'SampleRate')
                    disp('missing information about sampling rate - done without filtering');
                    doFilter='false';
                end

                if detectMeth==1      disp('chosen Method: rect. N* Median');
                elseif detectMeth==2  disp('chosen Method: rect. Mean +/- SD');
                elseif detectMeth==3  disp('chosen Method: Mean +/- SD');
                elseif detectMeth==4  disp('chosen Method: known median');
                end

                for i = 1:n  % Go over the data traces
                    times = [];
                    switch detectMeth
                        case 1 % The rect. N times median
                            if doFilter==true
                                Nyquist=1/2/ (1/ nsFile.Analog.Info(posChEntities(i)).SampleRate);
                                f=lowPassFilterFrequency/(Nyquist);
                                [b,a]=cheby1(2,0.1,f);
                                filtered_data=filtfilt(b,a,tdata(:,i));
                                MedianDataTrace=median(abs(filtered_data));
                            else
                                MedianDataTrace=median(abs(tdata(:,i)));
                            end
                            Threshold=MedianDataTrace*thresholdFactor;


                        case 2 % The rect. mean +/- SD
                            if doFilter==true
                                Nyquist=1/2/ (1/ nsFile.Analog.Info(posChEntities(i)).SampleRate);
                                f=lowPassFilterFrequency/(Nyquist);
                                [b,a]=cheby1(2,0.1,f);
                                filtered_data=filtfilt(b,a,tdata(:,i));
                                MeanDataTrace=mean(abs(filtered_data));
                                SDDataTrace=std(abs(filtered_data));
                            else
                                MeanDataTrace=mean(abs(tdata(:,i)));
                                SDDataTrace=std(abs(tdata(:,i)));
                            end
                            Threshold=MeanDataTrace+thresholdFactor * SDDataTrace;

                        case 3 % The mean +/- SD
                            if doFilter==true
                                Nyquist=1/2/ (1/ nsFile.Analog.Info(posChEntities(i)).SampleRate);
                                f=lowPassFilterFrequency/(Nyquist);
                                [b,a]=cheby1(2,0.1,f);
                                filtered_data=filtfilt(b,a,tdata(:,i));
                                MeanDataTrace=mean((filtered_data));
                                SDDataTrace=std(filtered_data);
                            else
                                MeanDataTrace=mean(tdata(:,i));
                                SDDataTrace=std(tdata(:,i));
                            end
                            Threshold=MeanDataTrace+thresholdFactor*SDDataTrace;

                        case 4 %with known median
                            Threshold=thresholdFactor*knownMedian;
                        otherwise
                            error(['Unknown method. -> Check the parameters: ']);
                    end

                    %% do the Detection
                    tdata(:,i)=abs(tdata(:,i))>Threshold;

                    times = find(diff(tdata(:,i)) == 1);         % find the times of the first ones
                    times2 = find(diff(tdata(:,i)) == -1);         % find the times of the last ones

                    %if there are some save them
                    if ~isempty(times)
                        times(:,2) = i;
                        if length(times2) == length(times(:,2))
                            times(:,3) = times2;
                        else
                            if length(times2) == length(times(:,2))-1
                                % end of tdata in the middle of a big spike
                                times(1:end-1,3) = times2;
                                times(end,3) = tdata(end,i);  % last point is end of spike
                            else
                                % beginning of tdata in a big spike
                                times(:,3) = times2(2:end);
                                times = [ [ 1 times(1,2) times2(1) ]; times]; % first point is beginning of spike
                            end
                        end
                        spikelist = [spikelist; times(:,[2 1 3])]; % put stuff in the right column
                        % and add to running total
                    end
                end
                % output result
                out = spikelist;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('ReplaceBigStuff')
                % replaces tdata at biglist with replacearray

                if ~isempty(biglist)
                    [m,n] = size(biglist);
                    for i = 1:m
                        atime = biglist(i,2);		% start time of big event
                        btime = biglist(i,3);		% stop time of big event
                        if (atime-prepts>0)
                            a = prepts;	% no out of array errors
                        else
                            a = atime-1;
                        end
                        if (btime + postpts < length(tdata))
                            b = postpts;
                        else
                            b = length(tdata)-btime;
                        end
                        % replace tdata points with replacearray estimate points
                        tdata(atime-a:btime+b,biglist(i,1)) = ...
                            replacearray(atime-a:btime+b,biglist(i,1));
                    end
                end
                out = tdata;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('PlotData')
                % makes a figure with the title using tdata
                % offsets each col by -100;

                figure('Name', ptitle, 'NumberTitle', 'off');

                [m,n] = size(tdata);

                for i = 1:n
                    tdata(:,i) = tdata(:,i) -(i-1)*analogDisplayOffset;
                end
                plot(tdata);
                drawnow
                zoom on

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('itpca')
                %  tdata and orig are in columns

                % subtract the mean from the tdata
                ch=size(tdata,2);
                M=mean(tdata);
                for i=1:ch
                    tdata(:,i)=tdata(:,i)-M(i);
                end

                C=cov(tdata);
                for i=1:ch
                    j=logical(ones(1,ch));
                    j(i)=0;
                    noti=tdata(:,j);     %subset of tdata not in channel i
                    Cnoti=C(j,j);       %cov for those channels
                    [v,d]=eig(Cnoti);
                    [junk,k]=sort(diag(d));   % sorts according to eigenvalues
                    v=v(:,k);d=d(:,k);        % rearrange v and d in this order
                    v=v(:,[end end-1]);       % take principal components 1 and 2
                    pc=noti*v;                % project tdata onto v
                    pc=[pc,orig(:,i)];        % matrix of 2 pc's and orig ch of interest
                    Cpc=cov(pc);              % the cov of this matrix
                    a1(i)=Cpc(1,3)/Cpc(1,1);
                    a2(i)=Cpc(2,3)/Cpc(2,2);
                    if i==1
                        art=[a1(i)*pc(:,1),a2(i)*pc(:,2)];
                    else
                        art=art+[a1(i)*pc(:,1),a2(i)*pc(:,2)];
                    end
                    out2(:,i)=orig(:,i)-a1(i)*pc(:,1)-a2(i)*pc(:,2);
                end
                art=art/ch;
                out = [out2,art];
                if strcmp(showWeights,'true')
                    fprintf('principle component weights for data columns 1 to %d\n',length(a1));
                    fprintf('first pc   ');
                    fprintf('%1.3f  ',a1);
                    fprintf('\nsecond pc  ');
                    fprintf('%1.3f  ',a2);
                    fprintf('\n\n');
                    %a1  % channel weights for first pc
                    %a2  % channel weights for second pc
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('pca2')
                %  out=pca(tdata)
                %  tdata is in columns

                % subtract the mean from the tdata
                ch=size(tdata,2);
                Mn=mean(tdata,1);
                for i=1:ch
                    tdata(:,i)=tdata(:,i)-Mn(i);
                end

                C=cov(tdata);
                for i=1:ch
                    j=logical(ones(1,ch));
                    j(i)=0;
                    noti=tdata(:,j);     %subset of tdata not in channel i
                    Cnoti=C(j,j);       %cov for those channels
                    [v,d]=eig(Cnoti);
                    [junk,k]=sort(diag(d));   % sorts according to eigenvalues
                    v=v(:,k);d=d(:,k);        % rearrange v and d in this order
                    v=v(:,[end end-1]);       % take principle components 1 and 2
                    pc=noti*v;                % project tdata onto v
                    pc=[pc,tdata(:,i)];        % matrix of 2 pc's and ch of interest
                    Cpc=cov(pc);              % the cov of this matrix
                    a1(i)=Cpc(1,3)/Cpc(1,1);
                    a2(i)=Cpc(2,3)/Cpc(2,2);
                    if i==1
                        art=[a1(i)*pc(:,1),a2(i)*pc(:,2)];
                    else
                        art=art+[a1(i)*pc(:,1),a2(i)*pc(:,2)];
                    end
                    out(:,i)=tdata(:,i)-a1(i)*pc(:,1)-a2(i)*pc(:,2);
                end
                art=art/ch;
                out=[out,art];
                a1;	% channel weights for first pc
                a2; % channel weights for second pc

        end

    else

        out = [];
        [m,n] = size(tdata);

        % assume there are fewer data channels than there are time points!
        if n > m
            tdata = tdata';
            [m,n] = size(tdata);
        end
        fprintf('Data contains %d channels of %d data pts.\n',n,m);

        last = ceil(m/ptspercut); 	% analyze data in ptspercut pieces
        dataLength = m;
        for ci = 0:last-1
            if (ci+1)*ptspercut > dataLength;
                stop = dataLength;			% last piece is whatever is left
                if size(tdata(ci*ptspercut+1:stop,:),1)==1
                    disp('Last chunk contains only single point. Point was added to previous chunk');
                    continue;
                end
            else
                stop = (ci+1)*ptspercut;
               % if there is only one point left, push this into previous
               % chunk
                if size(tdata,1)==stop+1
                    stop=((ci+1)*ptspercut)+1;
                end
            end
            warning off;

            cleaneddata=CleanData('action','GetCleanedData',...
                'tdata',tdata(ci*ptspercut+1:stop,:),...
                'plotData',plotData,...
                'ChannelEntityIDs',ChannelEntityIDs,...
                'analogDisplayOffset',analogDisplayOffset,...
                'chunk',(ci+1),...
                'doFilter',doFilter,...
                'detectMeth',detectMeth,...
                'knownMedian', knownMedian,...
                'thresholdFactor',thresholdFactor,...
                'prepts',prepts,...
                'postpts',postpts);

            warning on;
            out = [out;cleaneddata];
        end
    end
catch
    rethrow(lasterror);
end