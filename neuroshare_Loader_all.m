function [completeFile]=neuroshare_Loader_all(fileName,varargin)
% neuroshare_Loader_all is a function to load ALL information stored in a
% neuroshare accessable fileformat.
% In general it would be possible to load data only partially. This is not
% implemented here but can be easely done by using the
% 'ns_Get<<Analog||Event||Segment||Neural>>Data' functions and
% setting the FirstIdx and LastIdx of the subset you like to get.
%
% required input arguments:
% * fileName :         filename
%
% optional input arguments:
% * DLLpath :          if DLL is not in the same path hand over it by
%                      'DLLpath'
%
% output arguments:
% * completFile :      all information and data found in the file are
%                      pushed into this cellarray
%

if ~ispc
    error('FIND: import of Neuroshare Data formats is based on DLLs and therefor only available under WINDOWS!');
end

if isempty(varargin)
    DLLpath=pwd;
elseif numel(varargin)==1
    DLLpath=varargin{1};
else
    error('invalid number of input arguments');
end

if ~(ischar(fileName)&& isfile(fileName))
    error('invalid input value for fileName')
end

try
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
        otherwise
            error('no DLL available for this type of file')
    end
    
    % set library
    DLLfile = fullfile(DLLpath, DLLName);
    [ns_RESULT] = ns_SetLibrary(DLLfile);
    if (ns_RESULT ~= 0)
        error('DLL was not found!');
    end
    
    % Open data file
    [ns_RESULT, hfile] = ns_OpenFile(fileName);
    if (ns_RESULT ~= 0)
        clear mexprog;
        error('Data file did not open!');
    end
    
    % collect Infos and IDs
    
    [ns_RESULT, FileInfo] = ns_GetFileInfo(hfile);
    [ns_RESULT, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
    [ns_RESULT, LibraryInfo] = ns_GetLibraryInfo();
    
    analogentityIDs = find(cell2mat({EntityInfo.EntityType})==2);
    evententityIDs = find(cell2mat({EntityInfo.EntityType})==1);
    segmententityIDs = find(cell2mat({EntityInfo.EntityType})==3);
    neuralentityIDs = find(cell2mat({EntityInfo.EntityType})==4);
    
    % collect all Data
    FirstIdx = 1;
    if ~isempty(analogentityIDs)
        [ns_RESULT, AnalogInfo] = ns_GetAnalogInfo(hfile, analogentityIDs);
        LastIdx = max([EntityInfo(analogentityIDs).ItemCount]);
        [ns_RESULT, AnalogContCount, AnalogData] = ...
            ns_GetAnalogData(hfile,analogentityIDs,FirstIdx,LastIdx-FirstIdx+1);
    end
    
    if ~isempty(evententityIDs)
        [ns_RESULT, EventInfo] = ns_GetEventInfo(hfile, evententityIDs);
        LastIdx = max([EntityInfo(evententityIDs).ItemCount]);
        [ns_RESULT, EventTimeStamp, EventData, EventDataSize]= ...
            ns_GetEventData(hfile, evententityIDs, FirstIdx:LastIdx);
    end
    
    if ~isempty(segmententityIDs)
        [ns_RESULT, SegmentInfo] = ns_GetSegmentInfo(hfile, segmententityIDs);
        LastIdx=max(cell2mat({EntityInfo(segmententityIDs).ItemCount}));
        [ns_RESULT, SegmentTimeStamp, SegmentData , SegmentSampleCount, SegmentUnitID]= ...
            ns_GetSegmentData(hfile, segmententityIDs, FirstIdx:LastIdx);
    end
    
    if ~isempty(neuralentityIDs)
        [ns_RESULT, NeuralInfo] = ns_GetNeuralInfo(hfile, neuralentityIDs);
        LastIdx=max(cell2mat({EntityInfo(neuralentityIDs).ItemCount}));
        [ns_RESULT, NeuralData] = ...
            ns_GetNeuralData(hfile, neuralentityIDs, FirstIdx ,LastIdx);
    end
    
    % Close data file. Should be done by the library - but just in case.
    if exist('hfile','var')
        ns_CloseFile(hfile);
    end
    
    % Unload DLL
    clear mexprog;
    clear FirstIdx LastIdx ans hfile ns_RESULT varargin DLLpath DLLfile;
    completeVar=who;
    completeFile=struct;
    for hh=1:size(completeVar,1)
        eval(['completeFile.' completeVar{hh,1} '=' completeVar{hh,1} ';']);
    end
    
catch
    rethrow(lasterror);
    ns_CloseFile(hfile);
    clear mexprog;
    
end
end