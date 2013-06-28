function loader_rewrite
% old version of a the recent FIND_loader

%% %%%%%%%%%%% Basic Error catching %%%%%%%%%%%%%%%

% check for proper filename
if ~ischar(filename)
    error('Filename must be a string')
elseif ~isfile(filename)
    error('File does not exist (wrong path specified?)')
end

%varargin needs to have an even number of entries
if mod(length(varargin),2)~=0;error('Number of pvP arguments must be even');end

%only variables that are defined in loader_defaults.cfg may be used as
%arguments, so load list of default parameters
default_parameters=csv2cell('loader_defaults.cfg','=');
% and compare them to the content of varargin
for jj = 1:2:length(varargin)
    if ~ismember(varargin(jj),default_parameters)
        error('illegal argument used, see documentation for list of legal arguments')
    end
end

% each argument must also  only be used once per function call
for ii = 1:size(default_parameters,1)
    if sum(strcmp(default_parameters(ii),varargin))>=2
    error('each argument must only be used once per function call')
    end
end


%% %%%%%%%%%%% Set (default) Parameters %%%%%%%%%%%

% set all default parameters
for ii=1:size(default_parameters,1)
    eval([default_parameters{ii,1},'=',num2str(default_parameters{ii,2}),';']);
end

% finally set the user specified parameters...
pvpmod(varargin);

%% %%%%%%%%%%%%%%%% Library loading %%%%%%%%%%%%%%%

% load list of available dlls from libraries.cfg
dlls=csv2cell('libraries.cfg');

% find matching dll and load it
for ii=1:size(dlls,1);
    if strcmp(dlls{ii,1},lower(filename(end-3:end)))
        DLLName=dlls{ii,2}
        clear dlls;
                [nsresult] = ns_SetLibrary(DLLName);
                
                %error if something goes wrong
                if (nsresult ~= 0);error('DLL was not found!');end
        % found library and loaded it, now exit the loop
        break
    elseif ii==size(dlls,1)
        error('no DLL available for this file, check libraries.cfg')
    end
end

%% %%%%%%%%%%%%%% 

% check for an existing nsFile variable and prompt user for action if
% mergensFile is not set to 1 or 0.
if mergensFile==1
    mergechoice='merge';
elseif mergensFile==0
    mergechoice='overwrite';
elseif ~isempty(who('global', 'nsFile')) && strcmp(mergensFile,'prompt')%|| exist()
    mergechoice=questdlg(['''nsFile'' already exists. Overwrite it or merge it with the existing one? (This dialog can be avoided by setting ''mergensFile'' to 1 or 0) '],'nsFile already exists','overwrite','merge','cancel','cancel');
end

switch mergechoice
    case 'overwrite'
        mergensFile = [];
    case 'merge'
        %get nsFile and save it to a 'backup variable'
        global nsFile;
        mergensFile=nsFile;
    case 'cancel'
        return
end

% Open data file
[nsresult, hfile] = ns_OpenFile(filename);
% error if something goes wrong
if (nsresult ~= 0);error('Data file did not open!');return;end

%%%%%%%%%%%%%%%%% Retrieve Info %%%%%%%%%%%%%%%%%%%%%%

if fileinfo ~= 0;
    [ns_RESULT, nsFile.FileInfo] = ns_GetFileInfo(hfile);
end
% tempfileinfo and tempentityinfo are needed for all infos, so load them
% now.

[ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
[ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);

if strcmp(entityinfo,'all') || strcmp(info,'all');
    nsFile.EntityInfo = tempentityinfo;
    % add Field "EntityID"
    for ii = 1:tempfileinfo.EntityCount
        nsFile.EntityInfo(ii).EntityID=ii;
    end
elseif all(entityinfo > 0) && all(entityinfo <= tempfileinfo.EntityCount)
    [ns_RESULT, nsFile.EntityInfo] = ns_GetEntityInfo(hfile, entityinfo);
    % add Field "EntityID"
    for ii = 1:length(entityinfo)
        nsFile.EntityInfo(ii).EntityID=entityinfo(ii);
    end
else ns_CloseFile(hfile);clear mexprog;error('invalid argument for entityinfo') %this could be more detailed
end


if analoginfo ~= 0 || strcmp(info,'all');
    analogentityIDs = find(cell2mat({tempentityinfo.EntityType})==2);
    if isempty(analogentityIDs)
        disp('no analog entitites exist in this file')
    elseif strcmp(analoginfo,'all') && ~isempty(analogentityIDs)
        [ns_RESULT, nsFile.Analog.Info] = ns_GetAnalogInfo(hfile, analogentityIDs);
        % add Field "EntityID"
        for ii = 1:length(analogentityIDs)
            nsFile.Analog.Info(ii).EntityID=analogentityIDs(ii);
            nsFile.Analog.Info(ii).ItemCount=tempentityinfo(ii).ItemCount;
            nsFile.Analog.Info(ii).EntityLabel=tempentityinfo(ii).EntityLabel;
        end
    elseif all(ismember(analoginfo,analogentityIDs))
        [ns_RESULT, nsFile.Analog.Info] = ns_GetAnalogInfo(hfile, analoginfo);
        % add Field "EntityID"
        for ii = 1:length(analoginfo)
            nsFile.Analog.Info(ii).EntityID=analoginfo(ii);
        end
    elseif ~all(ismember(analoginfo,analogentityIDs))
        disp('Information could not be retrieved, not all specified entities are analog entities')
    end
end

if eventinfo ~= 0 || strcmp(info,'all');
    %%% indexing could be faulty!
    evententityIDs = find(cell2mat({tempentityinfo.EntityType})==1);
    if isempty(evententityIDs)
        disp('no event entities exist in this file')
    elseif strcmp(eventinfo,'all') && ~isempty(evententityIDs)
        [ns_RESULT, nsFile.Event.Info] = ns_GetEventInfo(hfile, evententityIDs);
        % add Field "EntityID"
        for ii = 1:length(evententityIDs)
            nsFile.Event.Info(ii).EntityID=evententityIDs(ii);
            nsFile.Event.Info(ii).ItemCount=tempentityinfo(ii).ItemCount;
            nsFile.Event.Info(ii).EntityLabel=tempentityinfo(ii).EntityLabel;
        end
    elseif all(ismember(eventinfo,evententityIDs))
        [ns_RESULT, nsFile.Event.Info] = ns_GetEventInfo(hfile, eventinfo);
        % add Field "EntityID"
        for ii = 1:length(eventinfo)
            nsFile.Event.Info(ii).EntityID=eventinfo(ii);
        end
    elseif ~all(ismember(eventinfo,evententityIDs))
        disp('Information could not be retrieved, not all specified entities are event entities')
    end
end

if segmentinfo ~= 0 || strcmp(info,'all');
        %%% indexing could be faulty!
    segmententityIDs = find(cell2mat({tempentityinfo.EntityType})==3);
    if isempty(segmententityIDs)
        disp('no segment entities exist in this file')
    elseif strcmp(segmentinfo,'all') && ~isempty(segmententityIDs)
        [ns_RESULT, nsFile.Segment.Info] = ns_GetSegmentInfo(hfile, segmententityIDs);
        % add Field "EntityID"
        for ii = 1:length(segmententityIDs)
            nsFile.Segment.Info(ii).EntityID=segmententityIDs(ii);
            nsFile.Segment.Info(ii).ItemCount=tempentityinfo(ii).ItemCount;
            nsFile.Segment.Info(ii).EntityLabel=tempentityinfo(ii).EntityLabel;
        end
    elseif all(ismember(segmentinfo,segmententityIDs))
        [ns_RESULT, nsFile.Segment.Info] = ns_GetSegmentInfo(hfile, segmentinfo);
        % add Field "EntityID"
        for ii = 1:length(segmentinfo)
            nsFile.Segment.Info(ii).EntityID=segmentinfo(ii);
        end
    elseif ~all(ismember(eventinfo,segmententityIDs))
        disp('Information could not be retrieved, not all specified entities are segment entities')
    end
end

% not up to date, appropriate test file still missing
% indexing could be faulty! actually just about everything could be faulty
% this is not officially supported yet.
if neuralinfo ~= 0 || strcmp(info,'all');
    neuralentityIDs = find(cell2mat({tempentityinfo.EntityType})==4);
    if isempty(neuralentityIDs)
        disp('no neural entities exist in this file')
    end 
    if strcmp(neuralinfo,'all') && ~isempty(neuralentityIDs)
        % warum wird hier eventinfo benutzt? einfach nur falsch getippt?
        [ns_RESULT, nsFile.Neural.Info] = ns_GetNeuralInfo(hfile, neuralentityIDs);
    elseif all(ismember(neuralinfo,neuralentityIDs))
        [ns_RESULT, nsFile.Neural.Info] = ns_GetNeuralInfo(hfile, neuralinfo);
    end
end

    clear tempfileinfo tempentityinfo
% retrieve libraryinfo
if libraryinfo ~= 0;
    [ns_RESULT, nsFile.LibraryInfo] = ns_GetLibraryInfo();
end

%%%%%%%%%%%% Retrieve data %%%%%%%%%%%%%%%%%%%%%%%%%

if analogdata ~= 0;
    %get fileinfo in order to have access to important information needed
    %later
    [ns_RESULT, tempfileinfo] = ns_GetFileInfo(hfile);
    %get entityinfo for the same reason
    [ns_RESULT, tempentityinfo] = ns_GetEntityInfo(hfile, 1:tempfileinfo.EntityCount);
    %get entityIDs for all analog entities
    analogentityIDs = find(cell2mat({tempentityinfo.EntityType})==2);
    %then check if there are any analog entities at all
    if isempty(analogentityIDs)
        disp('no analog entitites exist in this file')
    end

    % check if all desired entities are of equal length. note that if they aren't,
    % loading will result in all but one vector being filled with only 0s!

    if length(unique([tempentityinfo(analogdata(3:end)).ItemCount]))>1
        for kk=1:length(unique([tempentityinfo(analogdata(3:end)).ItemCount]))
%             [nsresult] = ns_SetLibrary(DLLName);
%             if (nsresult ~= 0)
%                 error('DLL was not found!');
%             end
            [ns_RESULT, ContCount, newdata.Analog.Data] = ns_GetAnalogData(hfile, analogdata(2+kk),analogdata(1),[tempentityinfo(analogdata(2+kk)).ItemCount]);
            tempidx=[analogdata(2+kk)];
            pvpstring{1}=filename;
            %zero padding
            store_ns_newanalogdata
        end
        %closefile?
   
 
    else
        % set indices for first and last data point (all datasets are
        % of equal length)
        FirstIdx = 1;
        LastIdx = max([tempentityinfo(analogdata(3:end)).ItemCount])

        if strcmp(analogdata,'all') && ~isempty(analogentityIDs)
            %load all analog data (for used syntax, check 'help ns_GetAnalogData'
            [ns_RESULT, ContCount, newdata.Analog.Data] = ns_GetAnalogData(hfile, analogentityIDs,FirstIdx, LastIdx);
            %check if...
        elseif size(analogdata,2)>=3 ... % enough parameters specified
                && all(ismember(analogdata(3:end),analogentityIDs)) ... %entityIDs specified as analog are really analog entities
                && 1 <= analogdata(1) ... % first index is a positive number
                && analogdata(1) <= analogdata(2) ... % first index is smaller than last index
                && analogdata(2) <= LastIdx % last index is really still in the dataset
            % then try to load everything
            [ns_RESULT, ContCount, newdata.Analog.Data] = ns_GetAnalogData(hfile, analogdata(3:end),analogdata(1),analogdata(2));
            %[ns_RESULT, ContCount, newdata] = ns_GetAnalogData(hfile, analogdata(3:end),analogdata(1),analogdata(2));
        else ns_CloseFile(hfile);clear mexprog; error('invalid Option for ''analogdata''');
        end
        % now add loaded data to existing nsFile structure
        tempidx=[analogdata(3)];
        pvpstring{1}=filename;
        store_ns_newanalogdata

    end

    clear tempfileinfo tempentityinfo
end
%%%%%%%%%%%%% tidy up %%%%%%%%%%%%%%%%%%%%%

% Close data file. Should be done by the library - but just in case.
ns_CloseFile(hfile);

% Unload DLL
clear mexprog;

