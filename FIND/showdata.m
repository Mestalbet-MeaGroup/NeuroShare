function showdata(varargin)
% This function is used to show a single trace of Analog and Segment data
% and give a first impression of neural and event data. For further
% visualisation use the the "Visulalisation" option in the
% pulldownm menu of the browseEntitiesGUI
%
% Rmeier April 2007
% kilias 2008
% the function belongs to FIND_GUI Toolbox project www.bccn.uni-freiburg.de

if calledfromgui()==1
    disp('fct. called from gui')
    fullName=get(findobj('Tag','FIND_GUI_fileInUseText'),'String');
    dataSet=fullName(length(pwd)+2:end);
else
    disp('fct. called from commandline')
    dataSet='';
end

if ~isempty(varargin)
    pvpmod(varargin);
end

% make nsFile available in current scope
global nsFile

if exist('selectedentities')
    %get selected entities
    FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
    selectedidx=find(FIND_GUIdata.IDselected);
    % elseif %check for call from commandline here
elseif exist('entities')
    selectedidx=entities;
else
    error('no valid parameters specified')
    return;
end


%get entitytypes for all selected entities
for ii=1:length(selectedidx)
    entitytype(ii)=nsFile.EntityInfo(selectedidx(ii)).EntityType;
end

selEvents=[]; EventPlot=false;
selNeural=[]; NeuralPlot=false;
selSegments=[];NeuralfSegPlot=false;

for ii=1:length(selectedidx)
    % -------------------------------------------------------------
    if entitytype(ii)==1 %Event
        if isfield(nsFile,'Event') && (ismember(selectedidx(ii),nsFile.Event.EntityID))
            EventPlot=true;
            % count and store ID for one single plot
            selEvents=[selEvents;selectedidx(ii)];
        end
        % -------------------------------------------------------------
    elseif entitytype(ii)==2 %Analog
        if isfield(nsFile,'Analog') && (ismember(selectedidx(ii),nsFile.Analog.DataentityIDs))
            %get sampling rate
            for jj=1:length(nsFile.Analog.Info)
                ana_sampfreqs(jj)=nsFile.Analog.Info(jj).SampleRate;
                ana_entityIDs(jj)=nsFile.Analog.Info(jj).EntityID;
            end
            mysampfreq=ana_sampfreqs(find(ana_entityIDs==selectedidx(ii)));
            %make xaxis
            mytmp=find(nsFile.Analog.DataentityIDs==selectedidx(ii));
            myxlen=length(nsFile.Analog.Data(:,mytmp));
            myxaxis=0:1/mysampfreq:(length(nsFile.Analog.Data(1:myxlen,mytmp))-1)/mysampfreq;
            mydatawindowwidth=myxlen/(mysampfreq*5);
            PosSelecidx=find([nsFile.Analog.DataentityIDs]==selectedidx(ii));

            %create plot command
            scrollplot(mydatawindowwidth,myxaxis,nsFile.Analog.Data(1:myxlen,PosSelecidx));
            set(gcf,'Name',['Dataentity ',num2str(selectedidx(ii)),' Entitytype:',' analog']);
            title({dataSet;[];['Dataentity ',num2str(selectedidx(ii)),' Entitytype:',' analog']},'Interpreter','none');
        end
        % -------------------------------------------------------------
    elseif entitytype(ii)==3 % Segment
        if  isfield(nsFile,'Segment') && isfield(nsFile.Segment,'Data') ...
                && ismember(selectedidx(ii),nsFile.Segment.DataentityIDs)
            PosSelecData=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
            %get sampling rate
            if isfield(nsFile.EntityInfo(selectedidx(ii)),'Info') &&...
                    isfield(nsFile.EntityInfo(selectedidx(ii)).Info, 'SampleRate')
                PosSelecidx=find([nsFile.EntityInfo(:).EntityID]==selectedidx(ii));
                mysampfreq=nsFile.EntityInfo(PosSelecidx).Info.SampleRate;
                myxlen=(size(nsFile.Segment.Data{ii},1))/mysampfreq; %[s]
                xaxname='time [s]';
            elseif isfield(nsFile.EntityInfo(selectedidx(ii)),'Info') &&...
                    isfield(nsFile.Segment.Info(selectedidx(ii)), 'SampleRate')
                PosSelecidx=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
                mysampfreq=nsFile.Segment.Info(PosSelecidx).SampleRate;
                myxlen=(size(nsFile.Segment.Data{ii},1))/mysampfreq; %[s]
                xaxname='time [s]';
            elseif isfield(nsFile.FileInfo, 'TimeStampResolution')
                mysampfreq=nsFile.FileInfo.TimeStampResolution;
                PosSelecidx=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
                myxlen=(size(nsFile.Segment.Data{PosSelecidx},1))/mysampfreq; %[s]
                xaxname='time [s]';
            else
                mysampfreq=1;
                PosSelecidx=find([nsFile.Segment.DataentityIDs]==selectedidx(ii));
                myxlen=size(nsFile.Segment.Data{PosSelecidx},1); %[sampling steps]
                xaxname='sampling steps';
                disp('to get timeaxis load up Infos for Segmentdata first');
            end

            % plot all cutouts
            figure('NumberTitle','off');
            for tt=1:size(nsFile.Segment.Data{PosSelecData},2)
                plot(0:(1/mysampfreq):(myxlen-1/mysampfreq), nsFile.Segment.Data{PosSelecData}(1:end,tt),'Color',rand(1,3));
                hold on;
            end
            set(gcf,'Name',['Dataentity ',num2str(selectedidx(ii)),' Entitytype:',' segment']);
            xlabel(gca,xaxname);
            title({dataSet;[];['all stored segments in Dataentity',num2str(selectedidx(ii))]},'Interpreter','none');
            hold off;
        end

        % plot the timestamps like the neural data
        if isfield(nsFile,'Segment') && isfield(nsFile.Segment,'TimeStamp') &&...
                ~isempty(nsFile.Segment.TimeStamp{PosSelecData})&&...
                (ismember(selectedidx(ii),nsFile.Segment.DataentityIDs))
            % store ID for one single plot
            selSegments=[selSegments; selectedidx(ii)];
            NeuralfSegPlot=true;
        end
        % -------------------------------------------------------------
    elseif entitytype(ii)==4  % Neural
        if isfield(nsFile,'Neural') && (isfield(nsFile.Neural,'Data')|| ...
                isfield(nsFile.Neural,'Data'))&&(ismember(selectedidx(ii),nsFile.Neural.EntityID))
            NeuralPlot=true;
            % store ID for one single plot
            selNeural=[selNeural;selectedidx(ii)];
        end
    else
        warndlg('Requested Entity not present in memory, load to nsFile first','EntityID not available')
    end
end

%% overview plot of events and neural

if EventPlot || NeuralPlot || NeuralfSegPlot
    ticks={};
    times=[];
    channel=[];vecData=[];vecData2=[];
    figure('Name','raster plot','NumberTitle','off');

    if EventPlot && ~NeuralPlot
        %------------------------------------------------------
        % only trigger
        for kk=1:length(selEvents)
            posData=find(nsFile.Event.EntityID==selEvents(kk));
            vecData=nsFile.Event.TimeStamp{posData};
            if size(vecData,1)==1
                vecData=vecData';
            end
            times=[times;vecData];
            channel=[channel;ones(length(nsFile.Event.TimeStamp(:,posData)),1)*kk];
            ticks{kk}=num2str(selEvents(kk));
        end
        plot(times,channel,'ro','MarkerFaceColor','r','MarkerSize',5);
        hold on;
        title({dataSet;[];['rasterplot for all loaded Event Entities']},'Interpreter','none');
        ylim([(0.8) (length(selEvents)+0.2)]);
        set(gca,'YTick',[1:1:length(selEvents)]);
        legend('Event',1);

    elseif NeuralPlot && ~EventPlot
        %------------------------------------------------------
        % only spikes
        for kk=1:length(selNeural)
            posData=find(nsFile.Neural.EntityID==selNeural(kk));
            vecData=nsFile.Neural.Data{posData};
            if size(vecData,1)==1
                vecData=vecData';
            end
            times=[times;vecData];
            channel=[channel;ones(length(nsFile.Neural.Data{posData}),1)*kk];
            ticks{end+1}=num2str(selNeural(kk));
        end
        plot(times,channel,'bo','MarkerFaceColor','b','MarkerSize',5);
        hold on;
        title({dataSet;[];['rasterplot for all loaded Neural Entities']},'Interpreter','none');
        ylim([(0.8) (length(selNeural)+0.2)]);
        set(gca,'YTick',[1:1:(length(selNeural))]);
        legend('Neural',1);

    elseif NeuralPlot && EventPlot
        %------------------------------------------------------
        % spikes and trigger
        for kk=1:length(selEvents)
            posData=find(nsFile.Event.EntityID==selEvents(kk));
            vecData=nsFile.Event.TimeStamp{posData};
            if size(vecData,1)==1
                vecData=vecData';
            end
            times=[times;vecData];
            channel=[channel;ones(length(nsFile.Event.TimeStamp(:,posData)),1)*kk];
            ticks{kk}=num2str(selEvents(kk));
        end
        ph1=plot(times,channel,'ro','MarkerFaceColor','r','MarkerSize',5);
        hold on;

        times2=[];
        channel2=[];
        for kk=1:length(selNeural)
            posData=find(nsFile.Neural.EntityID==selNeural(kk));
            vecData2=nsFile.Neural.Data{posData};
            if size(vecData2,1)==1
                vecData2=vecData2';
            end
            times2=[times2;vecData2];
            channel2=[channel2;ones(length(nsFile.Neural.Data{posData}),1)*(length(selEvents)+kk)];
            ticks{end+1}=num2str(selNeural(kk));
        end
        ph2= plot(times2,channel2,'bo','MarkerFaceColor','b','MarkerSize',5);
        hold on;
        title({dataSet;[];['rasterplot for all loaded Neural and Event Entities']},'Interpreter','none');
        ylim([(0.8) (length(selNeural)+length(selEvents)+1)]);
        set(gca,'YTick',[1:1:(length(selNeural)+length(selEvents))]);
        hold on;

        legend([ph1(1),ph2(1)],'Event', 'Neural',1);
        xlabel('time [sec]');
        ylabel('EntityID');
        set(gca,'YTickLabel',ticks);
        hold off;
    end
    
    if NeuralfSegPlot && ~EventPlot
        %------------------------------------------------------
        % segment_timestamps
        if NeuralPlot || EventPlot
            figure('Name','raster plot','NumberTitle','off');
            ticks={};
            times=[];
            channel=[];
        end
        for kk=1:length(selSegments)
            posData=find(nsFile.Segment.DataentityIDs==selSegments(kk));
            if size(nsFile.Segment.TimeStamp{posData},1)==1
                vecData=nsFile.Segment.TimeStamp{posData}';
            else
                vecData=nsFile.Segment.TimeStamp{posData};
            end
            times=[times;vecData];
            channel=[channel;ones(length(nsFile.Segment.TimeStamp{posData}),1)*kk];
            ticks{kk}=num2str(selSegments(kk));
        end
        plot(times,channel,'bo','MarkerFaceColor','b','MarkerSize',5);
        hold on;
        title({dataSet;[];['rasterplot for all TimeStamps of loaded Segment Entities']},'Interpreter','none');
        ylim([(0.8) (length(selSegments)+0.2)]);
        set(gca,'YTick',[1:1:length(selSegments)]);
        legend('Segment TimeStamps',1);

    elseif NeuralfSegPlot && EventPlot
        %------------------------------------------------------
        % segment_timestamps and trigger
        if NeuralPlot || EventPlot
            figure('Name','raster plot','NumberTitle','off');
            ticks={};
            times=[];times2=[];vecData2=[];
            channel=[];channel2=[];vecData=[];
        end
        for kk=1:length(selEvents)
            posData=find(nsFile.Event.EntityID==selEvents(kk));
            vecData=nsFile.Event.TimeStamp{posData};
            if size(vecData,1)==1
                vecData=vecData';
            end
            times=[times;vecData];
            channel=[channel;ones(length(nsFile.Event.TimeStamp(:,posData)),1)*kk];
            ticks{kk}=num2str(selEvents(kk));
        end
        ph3=plot(times,channel,'ro','MarkerFaceColor','r','MarkerSize',5);
        hold on;

        times2=[];
        channel2=[];
        for kk=1:length(selSegments)
            posData=find(nsFile.Segment.DataentityIDs==selSegments(kk));
            vecData2=nsFile.Segment.TimeStamp{posData};
            if size(vecData,1)==1
                vecData2=vecData';
            end
            times2=[times2;vecData2];
            channel2=[channel2;ones(length(nsFile.Segment.TimeStamp{posData}),1)*(length(selEvents)+kk)];
            ticks{end+1}=num2str(selSegments(kk));
        end
        ph4=plot(times2,channel2,'bo','MarkerFaceColor','b','MarkerSize',5);
        hold on;
        title({dataSet;[];['rasterplot for all TimeStamps of loaded Segment and Event Entities']},'Interpreter','none');
        ylim([(0.8) (length(selSegments)+length(selEvents)+1)]);
        set(gca,'YTick',[1:1:(length(selSegments)+length(selEvents))]);

        legend([ph3(1),ph4(1)],'Event', 'Segment TimeStamps',1);
        xlabel('time [sec]');
        ylabel('EntityID');
        set(gca,'YTickLabel',ticks);
        hold off;
    end
end