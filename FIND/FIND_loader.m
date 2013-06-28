function FIND_loader(varargin)
% Selectively load neural data entities from Neuroshare compatible data
% files.
%
% FIND_loader can selectively load parts of data stored in Neuroshare
% compatible data files. To access the proprietary data formats, it makes
% use of dll's provided by manufacturers that participate in the
% Neuroshare project. Furthermore, additional data formats are in the
% process of being incorporated by means of directly accessing them through
% MATLAB.
% For the time being, GDF (Gerstein Data Format) and data
% acquired with Meabench can be loaded, but are not fully supported in terms
% of seletively loading specific entities from the data file.
%
% All data will be loaded to the global variable nsFile.
%
% FIND_load uses the following parameters, all to passed as
% parameter-value-pairs.
%
% %%%%% Obligatory Parameters %%%%%
%
% 'fileName': Name of the data file to be loaded, including a relative or
% absolute path.
%
% 'DLLpath': Path to the coresponding Neuroshare dll.
%
% %%%%% Optional Parameters %%%%%
%
% GENERAL OPTIONS
%
% 'loadMode': This argument controls what to do with previously loaded data
% when new data of the same type is loaded to the nsFile variable.
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
%   'overwrite' - overwrites existing data of the same type in nsFile.
%
% 'zeroPadding': Some of the data entities are stored in matrices. When a
% data entity is appended to existing ones of different length, the shorter
% entity must be filled up with zeros in order to retain the matrix form.
% Depending on differences in lengths this might require large amounts of
% memory. Hence per default the user is prompted whether the operation
% should be continued when zero padding is necessary. With 'zeroPadding'
% this prompting behaviour can be overridden.
% Possible values:
%   'prompt' - this is the default setting. The user will be prompted about
%   whether to continue. An estimate of additional memory requirement is
%   provided.
%
%   'yes' - zero padding is always used if necessary. The user thus has to
%   consider memory requirements beforehand to avoid out of memory errors.
%
% RETRIEVING INFORMATION
%
% Note: All Information fields contain the additional Field 'EntityID',
% which contains the indices of the entities as they are stored
% in the data file.
%
% 'libraryInfo',1 : Gets library version information (only for data formats
% loaded via a dll).
%
% 'info','all': Gets all information contained in the data file.
% Example: FIND_loader('fileName','mydata.dat','DLLpath',pwd,'info','all');
%
% 'fileInfo',1: Gets information about the data file (e.g. Filetype,
% Application name, EntityCount, etc.).
% Example: FIND_loader(...,'fileInfo',1);
%
% 'entityInfo', 'analogInfo', 'segmentInfo', 'eventInfo', or 'neuralInfo':
% Retrieve general information about entities contained in the data file.
% Information about specific entities can also be retrieved by directly
% addressing the entity/-ies by (a vector containing) its/their index:
% Example: FIND_loader(..., 'entityInfo','all');
% Example: FIND_loader(..., 'entityInfo', [1 4:6 8]);
%
% RETRIEVING DATA
%
% Note: The option 'all' can be used for all data types to retrieve all
% data for the specified data type. E.g. 'analogData','all' would retrieve
% all analog data in the opened data file. '[]' indicates that values have
% to be provided as a vector.
%
% 'analogData':
% 'analogData',[FirstIdx,LastIdx,analogEntityIDs]
% FirstIdx and LastIdx designate the first and last data point
% (respectively) of the data to load. They apply to data points in all
% specified entities, so the retrieved data is always a square matrix of
% continuous data.
%
% 'eventData':
% 'eventData',[Indices of eventEntityIDs]
% [Indices of eventEntityIDs] can be a single integer or a vector of any form (e.g.
% [1,2:5,9:2:13])
%
% 'segmentData':
% 'segmentData',[Indices of segmentEntityIDs]
% [Indices of segmentEntityIDs] can be a single integer or a vector of any form (e.g.
% [1,2:5,9:2:13]). Note that only whole segments are retrieved. Retrieved
% data is a square (only one loaded entity) or cube shaped matrix (>1 data entity).
%
% 'neuralData':
% 'neuralData',[startIndex,indexCount,neuralEntityIDs]
% As retrieved data is stored in a matrix, care should be taken when loading from
% entityIDs with different lengths, for zero padding may need large amounts of
% memory.
%
% (0) Markus Nenniger 06/07, a.kilias 08/08 major revision
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


% Warning if linux - to avoid misunderstandings!
if ~ispc
    disp('------------------------------------------------------------------------------------------');
    disp('NOTE: ONLY non Neuroshare Data formats are available under Linux/Mac OS!');
    disp('For further information about supported data formats see: http://find.bccn.uni-freiburg.de');
    disp('------------------------------------------------------------------------------------------');
    warning(' Not all data formats are supported under Linux/Mac OS!');
end
% End of Warning, go on if possible

global nsFile;

%the whole function is one try/catch block. reason: see above.
try
    % obligatory argument names & validity test functions
    obligatoryArgs={{'fileName',@(val) ischar(val) && isfile(val)},...
        'DLLpath'}; %-% e.g. {'x','y'}

    % optional arguments names with default values
    optionalArgs={'fileInfo', ...
        'entityInfo', ...
        'analogData', ...
        'analogInfo', ...
        'eventData', ...
        'eventInfo', ...
        'segmentData', ...
        'segmentInfo', ...
        'neuralData', ...
        'neuralInfo', ...
        {'info', @(val) strcmp(val,'all') || val==0},...
        'libraryInfo',...
        {'loadMode', @(val) ismember(val,{'prompt','append','overwrite'})},...
        {'zeroPadding', @(val) ismember(val,{'prompt','yes'})}...
        };


    % default parameter values
    loadMode = 'prompt';
    zeroPadding = 'prompt';

    info = 0;
    fileInfo = 0;
    entityInfo = 0;
    analogData = 0;
    analogInfo = 0;
    eventData = 0;
    eventInfo = 0;
    segmentData = 0;
    segmentInfo = 0;
    neuralData = 0;
    neuralInfo = 0;
    libraryInfo = 0;

    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,''); %used this format so that the '\n' are converted
    end

    % loading parameter value pairs into workspace, overwriting defaul values
    pvpmod(varargin);


    % Load the appropriate DLL
    switch lower(fileName(end-3:end)) % sometimes filename endings are in Capitals.
        case '.mcd' %Multi Channel Systems
            DLLName = 'nsMCDLibrary64.dll';
        case '.smr' % PC spike2, Cambridge Electronic Design Ltd.
            DLLName = 'NSCEDSON.DLL';
        case '.son' % Mac spike2, Cambridge Electronic Design Ltd.
            DLLName = 'NSCEDSON.DLL';
        case '.map' % Alpha Omega Eng.
            DLLName = 'nsAOLibrary.dll';
            %     case '' %Cambridge Electronics. DLL is somehow bugged and can't be
            %     loaded.
            %         DLLName = 'CFS32.dll';
        case '.nex' % Nex Technologies (NeuroExplorer)
            DLLName = 'NeuroExplorerNeuroShareLibrary.dll';
        case '.plx' % Plexon Inc.
            DLLName = 'nsPlxLibrary.dll';
        case '.stb' % Tucker-Davis
            DLLName = 'nsTDTLib.dll';
        case {'.nev','.ns1','.ns2','.ns3','.ns4','.ns5'} % Cyberkinetics Inc., Library for Cerebus file group
            DLLName = 'nsNEVLibrary.dll';
            %         case  '.sif' || '.nix' || '.toc' || '.cpp' ||
            %         '.vcproj' ???
            %             DLLName = 'nsNEVLibrary.dll';
        case '.nsn' % Neuroshare Native File Format '.nsn'
            DLLName = 'nsNSNLibrary.dll';
        case 'pike' % could be meabench .spike file
            if strcmp(lower(fileName(end-5:end)),'.spike')
                loadNoNsFile('fileName', fileName,'segmentData', segmentData,'eventData',eventData,'neuralData',neuralData);
                DLLName = 'none neuroshare import';
            end
        otherwise
            % prompt user for DLL file?
            error('no DLL available for this type of file')
    end

    
    %%% first try for non windows import
    if ~ispc
        if ismember(lower(fileName(end-3:end)),{'.smr','.son'})
            loadNoNsFile('fileName', fileName,'segmentData', segmentData,...
                'eventData',eventData,'neuralData',neuralData,'analogData',analogData);
            DLLName = 'none neuroshare import';
        end
    end

    % return and dont ask for DLL after loading none neuroshare file formats
    if strcmp(DLLName,'none neuroshare import')
        postMessage('...done')
        return;
    end

    %%% find the DLL

    DLLfile = fullfile(DLLpath, DLLName);
    [nsresult] = ns_SetLibrary(DLLfile);
    if (nsresult ~= 0)
        error('DLL was not found!');
    end

    % Open data file
    [nsresult, hfile] = ns_OpenFile(fileName);
    if (nsresult ~= 0)
        disp('Data file did not open!');
        return
    else
        global FINDfilehandles
        FINDfilehandles=[FINDfilehandles hfile];
    end


    if strcmp(info,'all')
        fileInfo = 'all';
        entityInfo = 'all';
        analogInfo = 'all';
        eventInfo = 'all';
        segmentInfo = 'all';
        neuralInfo = 'all';
    elseif info==0
    else
        error('invalid argument for ''info'' ')
    end

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%% FileInfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if fileInfo ~= 0;
        [ns_RESULT, nsFile.FileInfo] = ns_GetFileInfo(hfile);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% EntityInfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if entityInfo ~= 0;
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        if strcmp(entityInfo,'all')
            [ns_RESULT, nsFile.EntityInfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
            % add Field "EntityID"
            for ii = 1:tempfileinfo.EntityCount
                nsFile.EntityInfo(ii).EntityID=ii;
            end
        elseif all(entityInfo > 0) && all(entityInfo <= tempfileinfo.EntityCount)
            [ns_RESULT, nsFile.EntityInfo] = ns_GetEntityInfo(hfile, entityInfo);
            % add Field "EntityID"
            for ii = 1:length(entityInfo)
                nsFile.EntityInfo(ii).EntityID=entityInfo(ii);
            end
        else error('invalid argument for entityInfo') %this could be more detailed
        end
        clear tempfileinfo
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% AnalogInfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if analogInfo ~= 0;
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        analogentityIDs = find(cell2mat({tempentityinfo.EntityType})==2);
        if isempty(analogentityIDs)
            disp('no analog entitites exist in this file')
        elseif strcmp(analogInfo,'all') && ~isempty(analogentityIDs)
            [ns_RESULT, nsFile.Analog.Info] = ns_GetAnalogInfo(hfile, analogentityIDs);
            % add Field "EntityID"
            for ii = 1:length(analogentityIDs)
                nsFile.Analog.Info(ii).EntityID=analogentityIDs(ii);
                nsFile.Analog.Info(ii).ItemCount=tempentityinfo(ii).ItemCount;
                nsFile.Analog.Info(ii).EntityLabel=tempentityinfo(ii).EntityLabel;
            end
        elseif all(ismember(analogInfo,analogentityIDs))
            [ns_RESULT, nsFile.Analog.Info] = ns_GetAnalogInfo(hfile, analogInfo);
            % add Field "EntityID"
            for ii = 1:length(analogInfo)
                nsFile.Analog.Info(ii).EntityID=analogInfo(ii);
            end
        elseif ~all(ismember(analogInfo,analogentityIDs))
            disp('Information could not be retrieved, not all specified entities are analog entities')
        end
        clear tempfileinfo tempentityinfo
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% EventInfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if eventInfo ~= 0;
        %%% indexing could be faulty!
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        evententityIDs = find(cell2mat({tempentityinfo.EntityType})==1);
        if isempty(evententityIDs)
            disp('no event entities exist in this file')
        elseif strcmp(eventInfo,'all') && ~isempty(evententityIDs)
            [ns_RESULT, nsFile.Event.Info] = ns_GetEventInfo(hfile, evententityIDs);
            % add Field "EntityID"
            for ii = 1:length(evententityIDs)
                nsFile.Event.Info(ii).EntityID=evententityIDs(ii);
                nsFile.Event.Info(ii).ItemCount=tempentityinfo(evententityIDs(ii)).ItemCount;
                nsFile.Event.Info(ii).EntityLabel=tempentityinfo(evententityIDs(ii)).EntityLabel;
            end
        elseif all(ismember(eventInfo,evententityIDs))
            [ns_RESULT, nsFile.Event.Info] = ns_GetEventInfo(hfile, eventInfo);
            % add Field "EntityID"
            for ii = 1:length(eventInfo)
                nsFile.Event.Info(ii).EntityID=eventInfo(ii);
            end
        elseif ~all(ismember(eventInfo,evententityIDs))
            disp('Information could not be retrieved, not all specified entities are event entities')
        end
        clear tempfileinfo tempentityinfo
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% SegmentInfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if segmentInfo ~= 0;
        %%% indexing could be faulty!
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        segmententityIDs = find(cell2mat({tempentityinfo.EntityType})==3);
        if isempty(segmententityIDs)
            disp('no segment entities exist in this file')
        elseif strcmp(segmentInfo,'all') && ~isempty(segmententityIDs)
            [ns_RESULT, nsFile.Segment.Info] = ns_GetSegmentInfo(hfile, segmententityIDs);
            % add Field "EntityID"
            for ii = 1:length(segmententityIDs)
                nsFile.Segment.Info(ii).EntityID=segmententityIDs(ii);
                nsFile.Segment.Info(ii).ItemCount=tempentityinfo(ii).ItemCount;
                nsFile.Segment.Info(ii).EntityLabel=tempentityinfo(ii).EntityLabel;
            end
        elseif all(ismember(segmentInfo,segmententityIDs))
            [ns_RESULT, nsFile.Segment.Info] = ns_GetSegmentInfo(hfile, segmentInfo);
            % add Field "EntityID"
            for ii = 1:length(segmentInfo)
                nsFile.Segment.Info(ii).EntityID=segmentInfo(ii);
            end
        elseif ~all(ismember(eventInfo,segmententityIDs))
            disp('Information could not be retrieved, not all specified entities are segment entities')
        end
        clear tempfileinfo tempentityinfo
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% NeuralInfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % not up to date, appropriate test file still missing
    % indexing could be faulty! actually just about everything could be faulty
    % this is not officially supported yet.
    if neuralInfo ~= 0;
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        neuralentityIDs = find(cell2mat({tempentityinfo.EntityType})==4);
        if isempty(neuralentityIDs)
            disp('no neural entities exist in this file')
        end
        if strcmp(neuralInfo,'all') && ~isempty(neuralentityIDs)
            [ns_RESULT, nsFile.Neural.Info] = ns_GetNeuralInfo(hfile, neuralentityIDs);
        elseif all(ismember(neuralInfo,neuralentityIDs))
            [ns_RESULT, nsFile.Neural.Info] = ns_GetNeuralInfo(hfile, neuralInfo);
        end
        clear tempfileinfo tempentityinfo
    end

    if libraryInfo ~= 0;
        [ns_RESULT, nsFile.LibraryInfo] = ns_GetLibraryInfo();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% AnalogData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if analogData ~= 0;
        %%% get fileinfo in order to have access to important information needed
        %%% later
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        %get entityinfo for the same reason
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        %get entityIDs for all analog entities
        analogentityIDs = find(cell2mat({tempentityinfo.EntityType})==2);
        %then check if there are any analog entities at all
        if isempty(analogentityIDs)
            warning('no analog entitites exist in this file')
        end
       
        %%% set up variable 'IDstoload' for call to ns_GetAnalogData
        if strcmp(analogData,'all') && ~isempty(analogentityIDs)

            %set IDstoload to to load all analogentity IDs
            IDstoload=analogentityIDs;

            FirstIdx = 1;
            LastIdx = max([tempentityinfo(analogentityIDs).ItemCount]);
            % note, that LastIdx is only used if all entities are of equal
            % length

        elseif size(analogData,2)>=3 ... % enough parameters specified
                && all(ismember(analogData(3:end),analogentityIDs)) ... %entityIDs specified as analog are really analog entities
                && 1 <= analogData(1) ... % first index is a positive number
                && analogData(1) <= analogData(2) ... % first index is smaller than last index
                && analogData(2) <= max([tempentityinfo(analogData(3:end)).ItemCount]) % last index is really still in the dataset

            % then set IDstoload
            IDstoload=analogData(3:end);
            FirstIdx = analogData(1);
            LastIdx=analogData(2);

        else error('invalid Option for ''analogData''');
        end

        %%% now load data to a temporary variable 'newdata', then store it in
        %%% nsFile

        % check if all desired entities are of equal length. note that if they aren't,
        % loading would result in all but one vector being filled with only if they aren't loaded one by one...!
        [differentlengths,something,uniqueidx]=unique([tempentityinfo(IDstoload).ItemCount]);
        if length(differentlengths)>1 % entities are not of equal lengths
            for kk=length(differentlengths):-1:1
                samelengthIDs=IDstoload(find(uniqueidx==kk));
                [ns_RESULT, ContCount, newdata.Analog.Data] = ns_GetAnalogData(hfile,samelengthIDs,FirstIdx,[tempentityinfo(IDstoload(find(uniqueidx==kk,1))).ItemCount]-FirstIdx+1);

                newdata.Analog.Info=[];
                pvpstring{1}=fileName;
                % get required infos like sampling rate
                [ns_RESULT, newdata.Analog.Info] = ns_GetAnalogInfo(hfile, samelengthIDs);
                for tt=1:length(samelengthIDs)
                    newdata.Analog.Info(tt).EntityID=(samelengthIDs(tt));
                    newdata.Analog.Info(tt).Label=tempentityinfo(samelengthIDs(tt)).EntityLabel;
                    newdata.Analog.Info(tt).Type=tempentityinfo(samelengthIDs(tt)).EntityType;
                    newdata.Analog.Info(tt).ItemCount=tempentityinfo(samelengthIDs(tt)).ItemCount;
                end
                newdata.Analog.DataentityIDs=samelengthIDs;
                if kk==length(differentlengths)
                    % decide about old data only once
                    store_ns_newanalogdata('newdata',newdata);
                else
                    % simultaneously loaded data are appended
                    store_ns_newanalogdata('newdata',newdata,'loadMode','append');
                end

            end
        else %(all datasets are of equal length)
            [ns_RESULT, ContCount, newdata.Analog.Data] = ns_GetAnalogData(hfile, IDstoload,FirstIdx, LastIdx-FirstIdx+1);
            % now add loaded data to existing nsFile structure
            newdata.Analog.Info=[];
            [ns_RESULT, newdata.Analog.Info] = ns_GetAnalogInfo(hfile, IDstoload);
            for tt=1:length(IDstoload)
                newdata.Analog.Info(tt).EntityID=IDstoload(tt);
                newdata.Analog.Info(tt).Label=tempentityinfo(IDstoload(tt)).EntityLabel;
                newdata.Analog.Info(tt).Type=tempentityinfo(IDstoload(tt)).EntityType;
                newdata.Analog.Info(tt).ItemCount=tempentityinfo(IDstoload(tt)).ItemCount;
            end
            pvpstring{1}=fileName;
            newdata.Analog.DataentityIDs=IDstoload;
            store_ns_newanalogdata('newdata',newdata);
        end

        clear tempfileinfo tempentityinfo
    end % ... of analog data loading part


    %%%%%%%%%%%%%%%%%%%%%%%%%%% EventData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if eventData ~= 0;
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        evententityIDs = find(cell2mat({tempentityinfo.EntityType})==1);
        if isempty(evententityIDs)
            disp('no event entitites exist in this file')
        end

        LastIdx = max(cell2mat({tempentityinfo(evententityIDs).ItemCount}));
        if strcmp(eventData,'all') && ~isempty(evententityIDs)
            if length(evententityIDs)>1
                disp('please choose only one event entity or append sequentially')
            elseif length(evententityIDs)==1
                eventData=[1,LastIdx,evententityIDs];
            end
            %             [ns_RESULT, nsFile.Event.TimeStamp, nsFile.Event.Data, nsFile.Event.DataSize] = ns_GetEventData(hfile, evententityIDs, 1:LastIdx);
        elseif size(eventData,2)>=3 ...
                && all(ismember(eventData(3:end),evententityIDs)) ...
                && 1 <= eventData(1) ...
                && eventData(1) <= eventData(2) ...
                && eventData(2) <= LastIdx
            IDstoload=eventData(3:end);

            newdata.Event.EntityID=IDstoload;
            [ns_RESULT, newEventTimeStamp, newEventData, newEventDataSize]=ns_GetEventData(hfile, eventData(3:end), eventData(1):eventData(2));
            if iscell(newEventData) && strcmp(newEventData{1},'Not supported')
                newEventData={[]};
            elseif iscell(newEventDataSize)&& strcmp(newEventDataSize{1},'Not supported')
                newEventDataSize{1}=[];
            end
            for tt=1:length(newdata.Event.EntityID)
                newdata.Event.TimeStamp{tt}=newEventTimeStamp(1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                if size(newEventData,2)<tt 
                    newdata.Event.Data{tt}=zeros(size(newdata.Event.TimeStamp{tt},2));
                else
                    newdata.Event.Data{tt}=newEventData(1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                end
                if size(newEventDataSize,2)<tt 
                    newdata.Event.DataSize{tt}=zeros(size(newdata.Event.TimeStamp{tt},2));
                else
                    newdata.Event.DataSize{tt}=newEventDataSize(1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                end
                EventDataOrigin{tt}=tempentityinfo(IDstoload(tt)).EntityLabel;
            end
            [ns_RESULT, newdata.Event.Info] = ns_GetEventInfo(hfile, IDstoload);
            store_ns_neweventdata('newdata',newdata,'DataOrigin',EventDataOrigin)
        else error('invalid option for ''eventData''');
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% SegmentData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if segmentData ~= 0;
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        segmententityIDs = find(cell2mat({tempentityinfo.EntityType})==3);

        if isempty(segmententityIDs)
            disp('no segment entitites exist in this file')
        end

        if strcmp(segmentData,'all')
            LastIdx=max(cell2mat({tempentityinfo.ItemCount}));
            segmentData=[1,LastIdx,segmententityIDs'];
        else
            LastIdx=max(cell2mat({tempentityinfo(segmentData(3:end)).ItemCount}));
        end
        IDstoload=segmentData(3:end);

        if size(segmentData,2)>=3 ...
                && all(ismember(segmentData(3:end),segmententityIDs)) ...
                && 1 <= segmentData(1) ...
                && segmentData(1) <= segmentData(2) ...
                && segmentData(2) <= LastIdx

            % adapt segement data as cell array
            [ns_RESULT, newSegmentTimeStamp, newSegmentData , newSegmentSampleCount, newSegmentUnitID]=...
                ns_GetSegmentData(hfile, segmentData(3:end), segmentData(1):segmentData(2));
            % [ns_RESULT, newdata.Segment.TimeStamp, newdata.Segment.Data , newdata.Segment.SampleCount, newdata.Segment.UnitID]=...
            %                 ns_GetSegmentData(hfile, segmentData(3:end), segmentData(1):segmentData(2));

            newdata.Segment.DataentityIDs=segmentData(3:end);
            for tt=1:length(newdata.Segment.DataentityIDs)
                newdata.Segment.Data{tt}=newSegmentData(:,1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                newdata.Segment.TimeStamp{tt}=newSegmentTimeStamp(1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                %  newdata.Segment.SampleCount{tt}=newSampleCount(1:AnzSeg,indx2);
                newdata.Segment.UnitID{tt}=newSegmentUnitID(1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                SegmentDataOrigin{tt}=tempentityinfo(IDstoload(tt)).EntityLabel;
            end

            store_ns_newsegmentdata('newdata',newdata,'DataOrigin',SegmentDataOrigin);

        else error('invalid option for ''segmentData''');
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% NeuralData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if neuralData ~= 0;
        [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
        [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
        neuralentityIDs = find(cell2mat({tempentityinfo.EntityType})==4);
        if isempty(neuralentityIDs)
            disp('no neural entitites exist in this file')
        end


        if strcmp(neuralData,'all')
            LastIdx=max(cell2mat({tempentityinfo.ItemCount}));
            neuralData=[1,LastIdx,neuralentityIDs'];
        else
            LastIdx=max(cell2mat({tempentityinfo(neuralData(3:end)).ItemCount}));
        end
        IDstoload=neuralData(3:end);

        if size(neuralData,2)>=3 ...
                && all(ismember(neuralData(3:end),neuralentityIDs)) ...
                && 1 <= neuralData(1) ...
                && neuralData(1) <= neuralData(2) ...
                && neuralData(2) <= LastIdx

            % adapt segement data as cell array
            [ns_RESULT, newNeuralData]  = ns_GetNeuralData(hfile, neuralData(3:end), neuralData(1),neuralData(2));

            newdata.Neural.EntityID=neuralData(3:end);
            for tt=1:length(newdata.Neural.EntityID)
                newdata.Neural.Data{tt}=newNeuralData(1:(tempentityinfo(IDstoload(tt)).ItemCount),tt);
                NeuralDataOrigin{tt}=tempentityinfo(IDstoload(tt)).EntityLabel;
            end

            store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);

        else error('invalid option for ''neuralData''');
        end
    end


catch
    % Close data file. Should be done by the library - but just in case.
    if exist('hfile','var');ns_CloseFile(hfile);end

    % Unload DLL
    clear mexprog;
    rethrow(lasterror);
end
% Close data file. Should be done by the library - but just in case.
if exist('hfile','var');ns_CloseFile(hfile);end

% Unload DLL
clear mexprog;