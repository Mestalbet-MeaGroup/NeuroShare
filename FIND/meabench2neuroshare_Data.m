function meabench2neuroshare_Data(varargin)
% load selected entities of Meabench '.spike' File and convert it to neuroshare conform data structure
%
% meabench2neuroshare_Data loads the SegmentData of the spikes for the
% selected entities. Each entity corresponds to a single channel of the
% MEA.
% Spike timings were converted into seconds by using the sampling
% frequency. If it is unspecified, the frequency is set to 25 kHz.
% The data were converted to microvolts by multiplying by using the range.
% As a special case, range=0..3 is interpreted as a MultiChannel Systems
% gain setting:
%
% range value   electrode range (uV)    auxillary range (mV)
%      0               3410                 4092
%      1               1205                 1446
%      2                683                  819.6
%      3                341                  409.2
%
% "electrode range" is applied to channels 0..59, auxillary range is
% applied to channels 60..63.
% In this case, the frequency is set to 25 kHz unless specified.
%
% Finally results are stored in the global nsFile variable.
%
% meabench2neuroshare_Data uses the following parameters, all to passed as
% parameter-value-pairs.
%
% %%%%% Obligatory Parameters %%%%%
%
% 'fileName': Name of the data file to be loaded, including a relative or
% absolute path.
%
% %%%%% Optional Parameters %%%%%
%
% 'segmentData' :
%   Segment Data - contains all the spikedata for one entity
%
% 'eventData' :
%   Event Data - contains all the trigger time points for one entity
%
% 'rangeID' :
%   necessesary input to convert data into microvolts
%
% 'freq' :
%   sampling freuency - necessesary input to convert time into seconds
%
% 'loadMode': This argument controls what to do with previously loaded data
%   when new data of the same type is loaded to the nsFile variable.
% Possible values:
%   'prompt' - this is the default setting. The user will be prompted about
%   whether the new data should be appended or the old data be overwritten.
%   With the next two options this behaviour can be set directly.
%
%   'append' - new data is automatically appended to the existing data.
%   This may require zero padding and in consequence additional memory. See
%   the argument 'zeroPadding' below, which controls the behaviour in this
%   case.
%
% %%%%% RETRIEVING DATA %%%%%
%
% 'segmentData':
% 'segmentData',[Indices of segmentEntityIDs]
% [Indices of segmentEntityIDs] can be a single vector or a matrix of any form (e.g.
% [9:2:13])
% all spike cutout data of one channel are stored in an associated entity
%
% 'eventData':
% 'eventData',[Indices of eventEntityIDs]
% [Indices of segmentEntityIDs] can be a single vector or a matrix of any form (e.g.
% [9:2:13])
% all trigger timestamps of one trigger channel are stored in a single
% Event entity
%
% --------------------------
% a.kilias, r.meier 07 
% (last general revision 08/08 by kilias)
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={{'fileName',@(val) ischar(val) && isfile(val)}};

    % optional arguments names with default values
    optionalArgs={{'freq',@(val) val>0},...
        {'rangeID',@(val) ismember(val,[0 1 2 3])},...
        {'loadMode',@(val) ismember(val,{'overwrite','append','prompt'})},...
        'segmentData',...
        'eventData'};
    % frequ and range still included to uses this file undepentdently from
    % the meabench2neuroshare_Info file

    % default parameters
    rangeID= 2;
    loadMode='prompt';

    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,''); %used this format so that the '\n' are converted
    end
    pvpmod(varargin);

    if exist('segmentData')~=1 && exist('eventData')~=1
        postMessage('Please select EntityID first');
        return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist('segmentData')==1

        EL=segmentData(3:end); % determine the entity to load
        [l,PosEL,v]=intersect([nsFile.EntityInfo(:).EntityID],EL); % get postion of EL in EntityInfo

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % check for frequency
        for setFreq=1:length(EL)
            if  exist('freq')==1
                nsFile.EntityInfo(PosEL(setFreq)).Info.SampleRate=freq;
            elseif ~isfield(nsFile.EntityInfo(PosEL(setFreq)).Info,'SampleRate')
                error('ERROR - sampling frequency missing');
            end
        end

        % convert rangeID into range value
        RangePos=(find([0 1 2 3]==rangeID));
        rangeElec= [ 3410,1205,683,341 ]; %  Gain: '0.333496 uV/digistep [+- 683 uV range]'
        range=rangeElec(RangePos)/2048;      % divide by Digital_zero: '2048'

        for setRange=1:length(EL)
            if ~isfield(nsFile.EntityInfo(PosEL(setRange)).Info,'range') %only overwrite if empty
                nsFile.EntityInfo(PosEL(setRange)).Info.RangeInfo='uV/digistep';
                nsFile.EntityInfo(PosEL(setRange)).Info.Range=range;
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% read file and load up data in temporary structure newdata
        fid = fopen(fileName,'rb');
        if (fid<0)
            error('Cannot open the specified file');
        end

        ff=fseek(fid, -1, 'eof');
        ft=ftell(fid);
        ff=fseek(fid, 0, -1);
        raw = fread(fid,[132 (((ft+1) / 132) / 2)],'int16');
        % fills an 132xnum_spikes matrix,'int16' is a data type specifier, i.e. int with a size of 16 bits (2byte)
        fclose(fid);

        % initialise newdata
        newdata.Segment.Data={[]};
        newdata.Segment.TimeStamp={[]};
        newdata.Segment.UnitID={[]};
        newdata.Segment.SampleCount={[]};
        newdata.Segment.DataentityIDs=[];

        for kk=1:length(EL)
            channelSpike=find(raw(5,:)==(EL(kk)-1));
            %y.time and y.channel allready stored in neural data
            %(for further information see meabench2neuroshare_Info)
            ti0 = raw(1,(channelSpike)); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
            ti1 = raw(2,(channelSpike)); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
            ti2 = raw(3,(channelSpike)); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
            ti3 = raw(4,(channelSpike)); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
            newdata.Segment.TimeStamp{kk} = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)))*...
                (nsFile.EntityInfo(PosEL(kk)).Info.SampleRate);
            % get the cutouts and convert into microVolt steps
            newdata.Segment.Data{kk}(1:125,:)=raw(8:132,(channelSpike));
            newdata.Segment.Data{kk}=(newdata.Segment.Data{kk}.* ...
                (nsFile.EntityInfo(PosEL(kk)).Info.Range)-(nsFile.EntityInfo(PosEL(kk)).Info.Range*2048));

            y.channel{kk} = raw(5,(channelSpike));
            %use this for some checks
            if ~(unique(y.channel{kk})==(EL(kk)-1))
                error('FIND: error while loading meabench spike cutout data');
            end
            clear ti0 ti1 ti2 ti3;

            newdata.Segment.SampleCount{kk}=ones(size(newdata.Segment.Data{kk},2),1).*size(newdata.Segment.Data{kk},1);
            newdata.Segment.UnitID{kk}=zeros(size(newdata.Segment.Data{kk},2),1);
            newdata.Segment.DataentityIDs(kk)=EL(kk);
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % push into nsFile

        %1.) set EntityInfos
        for kk=1:length(EL)
            nsFile.EntityInfo(PosEL(kk)).EntityLabel=['Meabench EL ' num2str(hw2cr(EL(kk)-1))];
            nsFile.EntityInfo(PosEL(kk)).ItemCount=length(find(y.channel{kk}==(EL(kk)-1)));
            nsFile.EntityInfo(PosEL(kk)).EntityID=EL(kk);
            nsFile.EntityInfo(PosEL(kk)).EntityType=3;
        end

        %2.) store_ns_new...data
        DataOrigin{1}='MEABench Spike cutout Data (.*spike)';
        store_ns_newsegmentdata('newdata',newdata,'DataOrigin',DataOrigin);
        clear newdata; %% Clean up!

        %%%3.) include some general FileInfos
        nsFile.FileInfo.FileType=' MEABench Spike Data';
        nsFile.FileInfo.EntityCount= 64;
        nsFile.FileInfo.TimeStampResolution=1/(nsFile.EntityInfo(1).Info.SampleRate);
        nsFile.FileInfo.TimeSpan=(max(cellfun(@max,nsFile.Segment.TimeStamp)))/(nsFile.EntityInfo(1).Info.SampleRate);
        nsFile.FileInfo.AppName=' FIND 0.01 - MeaBench Import';



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif exist('eventData')==1
        count=0;
        for EL=[eventData(3:end)]
            count=count+1;
            PosEL=find([nsFile.EntityInfo(:).EntityID]==EL); % get postion of EL in EntityInfo

            if ~exist('raw')
                fid = fopen(fileName,'rb');
                if (fid<0)
                    error('Cannot open the specified file');
                end
                ff=fseek(fid, -1, 'eof');
                ft=ftell(fid);
                ff=fseek(fid, 0, -1);
                raw = fread(fid,[132 (((ft+1) / 132) / 2)],'int16');
                % fills an 132xnum_spikes matrix,'int16' is a data type specifier, i.e. int with a size of 16 bits (2byte)
                fclose(fid);
            end

            Trigger=find(raw(5,:)==(EL-1));
            %y.time and y.channel allready stored in neural data
            %(for further information see meabench2neuroshare_Info)
            ti0 = raw(1,(Trigger)); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
            ti1 = raw(2,(Trigger)); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
            ti2 = raw(3,(Trigger)); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
            ti3 = raw(4,(Trigger)); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
            newdata.Event.TimeStamp{count} = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)))*(nsFile.EntityInfo(PosEL).Info.SampleRate);
            newdata.Event.EntityID(count)=EL;
            clear ti0 ti1 ti2 ti3;
            DataOrigin{count}='MEABench Trigger Data (.*spike)';

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % push into nsFile

            %1.) set EntityInfos

            nsFile.EntityInfo(PosEL).EntityLabel=['Meabench EL ' num2str(hw2cr(EL-1))];
            nsFile.EntityInfo(PosEL).ItemCount=length(newdata.Event.TimeStamp);
            nsFile.EntityInfo(PosEL).EntityID=EL;
            nsFile.EntityInfo(PosEL).EntityType=1;
        end
        %2.) store_ns_new...data

        store_ns_neweventdata('newdata',newdata,'DataOrigin',DataOrigin);
        clear newdata; %% Clean up!

        %%%3.) include some general FileInfos
        nsFile.FileInfo.FileType='MEABench Spike Data';
        nsFile.FileInfo.EntityCount= 64;
        nsFile.FileInfo.AppName='FIND 1.0 - MeaBench Import';

    else
        postMessage('Please select entity first');

    end
catch
    rethrow(lasterror);
end