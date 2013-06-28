function SON2neuroshare_Data(varargin)
% function SON2neuroshare_Data(varargin)
% This fuction imports smr\son files under linux or macos by using the SON
% library (Copyright � The Author & King's College London 2002-2006) and
% pushs the the data into the neuroshare based FIND structure.
%
% used SON functions:
%
%   SONGetBlockHeaders      - returns a matrix containing the SON data block headers
%   SONGetChannel           - provides a gateway to the individual channel read functions.
%   SONGetEventChannel      - reads an event channel from a SON file
%   SONGetMarkerChannel     - reads a marker channel from a SON file.
%   SONGetRealMarkerChannel - reads an RealMark channel from a SON file.
%   SONGetRealWaveChannel   - reads an ADC (waveform) channel from a SON file.
%   SONGetSampleInterval    - returns the sampling interval in microseconds
%   SONGetSampleTicks       - Finds the sampling interval on a data channel in a SON file
%
%
%%%%% Notes: %%%%%%%%%
%
% Note that partial loading of data stored in one channel is recently
% not possible!
%
% a.kilias 12/08, kilias@bccn.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de



global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={{'fileName',@(val) ischar(val) && isfile(val)}};

    % optional arguments names with default values
    optionalArgs={{'loadMode',@(val) ismember(val,{'overwrite','append','prompt'})},...
        {'zeroPadding', @(val) ismember(val,{'prompt','yes'})},...
        'analogData','eventData','segmentData','neuralData'};

    % default parameter values
    loadMode = 'prompt';
    analogData=0;
    eventData=0;
    segmentData=0;
    neuralData=0;

    % parameter check
    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,'');
    end
    pvpmod(varargin);

    addpath([pwd,'/son']);
    fid=fopen(fileName);
    %fclose(fid);

    %     disp('not implemented')
    %     return;

    %%%%%%%%%%%%%%%%%%%%%%%%%%% EventData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if eventData ~= 0

        if strcmp(eventData,'all')     % check for 'all' option
            eventData=[1,1,[nsFile.EntityInfo(find(nsFile.EntityInfo.EntityType==1)).EntityID]];
        end
        selectedEvent=eventData(3:end);
        % ID and poition are equal
        getCH=([nsFile.EntityInfo.Info]);
        EventDataOrigin={''};
        for kk=1:length(selectedEvent)
            [data,header]=SONGetChannel(fid,[getCH(selectedEvent(kk)).channel],'seconds','scale');

            if isstruct(data)
                newdata.Event.TimeStamp{kk}=(data.timings);
                if isfield(data,'markers')
                    newdata.Event.Data{kk}=double(data.markers);
                else
                    newdata.Event.Data{kk}=zeros(length(newdata.Event.TimeStamp{kk}),1);
                end
                if isfield(data,'real')
                    newdata.Event.DataSize{kk}=double(data.real);
                else
                    newdata.Event.DataSize{kk}=zeros(length(newdata.Event.TimeStamp{kk}),1);
                end
            else
                newdata.Event.TimeStamp{kk}=double(data);
                newdata.Event.Data{kk}=zeros(length(newdata.Event.TimeStamp{kk}),1);
                newdata.Event.DataSize{kk}=zeros(length(newdata.Event.TimeStamp{kk}),1);
            end

            newdata.Event.EntityID(kk)=selectedEvent(kk);
            newdata.Event.Info(kk).CSVDesc=header.comment;
            newdata.Event.Info(kk).EntityID=selectedEvent(kk);
            newdata.Event.Info(kk).ItemCount=nsFile.EntityInfo(selectedEvent(kk)).ItemCount;
            EventDataOrigin{kk}=header.title;

            if header.kind==2
                newdata.Event.Info(kk).EventType='ns_Event_(+)';
            elseif header.kind==3
                newdata.Event.Info(kk).EventType='ns_Event_(-)';
            elseif header.kind==4
                newdata.Event.Info(kk).EventType='ns_Event_Level';
            elseif header.kind==5
                newdata.Event.Info(kk).EventType='ns_Event_Marker';
            elseif header.kind==7
                newdata.Event.Info(kk).EventType='ns_Event_RealMark';
            elseif header.kind==8
                newdata.Event.Info(kk).EventType='ns_Event_TextMark';
            else
                error('FIND: impropper entity type assignment');
            end


            % missing implementation
            newdata.Event.Info(kk).MinDataLength=[];
            newdata.Event.Info(kk).MaxDataLength=[];
        end
        store_ns_neweventdata('newdata',newdata,'DataOrigin',EventDataOrigin);

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%% AnalogData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if analogData ~= 0
        if strcmp(analogData,'all')     % check for 'all' option
            analogData=[1,1,[nsFile.EntityInfo(find(nsFile.EntityInfo.EntityType==2)).EntityID]];
        end
        selectedAnalog=analogData(3:end);

        % ID and poition are equal
        getCH=([nsFile.EntityInfo.Info]);
         getItem=([nsFile.EntityInfo.ItemCount]);
        for kk=1:length(selectedAnalog)
            [data,header]=SONGetChannel(fid,[getCH(selectedAnalog(kk)).channel],'seconds');
            newdata.Analog.Data=double(data);
            newdata.Analog.DataentityIDs(1)=selectedAnalog(kk);
            newdata.Analog.Info(1).EntityID=selectedAnalog(kk);
            newdata.Analog.Info(1).Units=header.units;
            newdata.Analog.Info(1).ProbeInfo=header.comment;
            newdata.Analog.Info(1).ItemCount=getItem(selectedAnalog(kk));
            newdata.Analog.Info(1).EntityLabel=header.title;
            newdata.Analog.Info(1).SampleRate=1000000/header.sampleinterval;


            % ns infos
            %         SampleRate: 2.5000e+004
            %             MinVal: -5000
            %             MaxVal: 5000
            %              Units: 'pA'
            %         Resolution: 0.1526
            %          LocationX: 0
            %          LocationY: 0
            %          LocationZ: 0
            %       LocationUser: 0
            %     HighFreqCorner: 0
            %      HighFreqOrder: 0
            %     HighFilterType: 'unknown'
            %      LowFreqCorner: 0
            %       LowFreqOrder: 0
            %      LowFilterType: ''
            %          ProbeInfo: 'intracellular electrode current'
            %           EntityID: 1
            %              Label: 'current'
            %               Type: 2
            %          ItemCount: 115915
            %        EntityLabel: []



            % header info
            %           FileName: [1x95 char]
            %             system: 'SON6'
            %        FileChannel: 1
            %            phyChan: 0
            %               kind: 9
            %            comment: 'intracellular electrode current'
            %              title: 'current'
            %     sampleinterval: 40
            %              scale: 1000
            %             offset: 0
            %                min: -21.9727
            %                max: -18.3105
            %              units: 'pA'
            %         interleave: 1
            %            npoints: 115915
            %               mode: 'Continuous'
            %              start: 2.5000e-005
            %               stop: 4.6366
            %             Epochs: {[1]  [33]  'of'  [33]  'blocks'}
            %          TimeUnits: 'seconds'
            %          transpose: 1



            % Channel info
            %         FileName: 'C:\Documents and Settings\student.BCCN\My Documents\FIND\trunk\Testdata\InVivo_extEl_Spikes.smr'
            %          channel: 1
            %          delSize: 0
            %     nextDelBlock: -1
            %       firstblock: 5120
            %        lastblock: 3137536
            %           blocks: 33
            %           nExtra: 0
            %          preTrig: 0
            %            free0: 0
            %            phySz: 7168
            %          maxData: 3574
            %          comment: 'intracellular electrode current'
            %      maxChanTime: 1854634
            %         lChanDvd: 16
            %          phyChan: 0
            %            title: 'current'
            %        idealRate: 25000
            %             kind: 1
            %              pad: 0
            %            scale: 1000
            %           offset: 0
            %            units: 'pA'
            %           divide: []
            %       interleave: 0
            %              min: []
            %              max: []
            %          initLow: []
            %          nextLow: []

%            [res,start]=SONGetSampleTicks(fid,[getCH(selectedAnalog(kk)).channel]);

            % missing implementation
            newdata.Analog.Info(1).MinVal=0;
            newdata.Analog.Info(1).MaxVal=0;
            newdata.Analog.Info(1).Resolution=[];
            newdata.Analog.Info(1).LocationX=0;
            newdata.Analog.Info(1).LocationY=0;
            newdata.Analog.Info(1).LocationZ=0;
            newdata.Analog.Info(1).LocationUser=0;
            newdata.Analog.Info(1).HighFreqCorner=0;
            newdata.Analog.Info(1).HighFreqOrder=0;
            newdata.Analog.Info(1).HighFilterType='unknown';
            newdata.Analog.Info(1).LowFreqCorner=0;
            newdata.Analog.Info(1).LowFreqOrder=0;
            newdata.Analog.Info(1).LowFilterType='';

            [usedIDs]=store_ns_newanalogdata('newdata',newdata);
            if ~isempty(usedIDs)
                temp=find(nsFile.Analog.DataentityIDs==usedIDs);
                nsFile.Analog.Info(temp).Type=2;
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% SegmentData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if segmentData ~= 0
        if strcmp(segmentData,'all')     % check for 'all' option
            segmentData=[1,1,[nsFile.EntityInfo(find(nsFile.EntityInfo.EntityType==3)).EntityID]];
        end
        selectedSegment=segmentData(3:end);
        % ID and poition are equal
        getCH=([nsFile.EntityInfo.Info]);
        SegmentDataOrigin={''};
        for kk=1:length(selectedSegment)
            [data,header]=SONGetChannel(fid,[getCH(selectedSegment(kk)).channel],'seconds','scale');
            newdata.Segment.Data{kk}=double(data.adc);
            newdata.Segment.TimeStamp{kk}=double(data.timings);
            newdata.Segment.UnitID{kk}=double(data.markers(:,1)+1);
            newdata.Segment.SampleCount{kk}=ones(size(data.adc,2),1).*size(data.adc,1);
            newdata.Segment.DataentityIDs(kk)=selectedSegment(kk);
            SegmentDataOrigin{kk}=header.title;
        end
        store_ns_newsegmentdata('newdata',newdata,'DataOrigin',SegmentDataOrigin);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% NeuralData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if neuralData ~= 0
        if strcmp(neuralData,'all')     % check for 'all' option
            neuralData=[1,1,[nsFile.EntityInfo(find(nsFile.EntityInfo.EntityType==4)).EntityID]];
        end
        selectedNeural=neuralData(3:end);

        getCH=([nsFile.EntityInfo.Info]);
        NeuralDataOrigin={''};
        for kk=1:length(selectedNeural)
            [data,header]=SONGetChannel(fid,[getCH(selectedNeural(kk)).channel],'seconds','scale');
            newdata.Neural.Data{kk}=double(data.timings);
            newdata.Neural.EntityID(kk)=selectedNeural(kk);
            NeuralDataOrigin{kk}=header.title;
        end
        store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);
    end

    fclose(fid);
catch
    if exist('fid','var');
        fclose(fid);
    end
    rethrow(lasterror);
end