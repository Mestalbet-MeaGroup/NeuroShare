function [usedIDs]=store_ns_neweventdata(varargin)
% function store_ns_neweventdata
% This function appends new event data properly to existing data.
% If data already exists in nsFile, the user is prompted.
% New data can be written over existing data or be appended to the
% variable.
%
% If the new data and already existing data are assigned by the same
% EntityID the user can elongate the exiting data by the new ones,
% overwrite the old data or store the new data in a new postion by creating
% a new Entity (and a new ID).
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'newdata': is a structure similar to the nsFile which contains data to
%   store, here newdata.Event.TimeStamp is the minimum requirement. Data are
%   stored in cell arrays in which each cell refers to a Entity.
%
% 'DataOrigin': string to determine were the data come from (i.e.
%   'detected Spikes from analog data')
%
% %%%%% Optional Parameters %%%%%
%
% 'newdata.Event.EntityID' : the existence of this field is in contrast to
%   the field 'newdata.Event.Data' optional. The variable can be used to
%   assigne derivated new event data by using the same EntityID as for
%   the original data
%
% 'newdata.Event.Data' : trigger
%
% 'newdata.Event.DataSize' : datasize is stored here
%
%'loadMode': new event data can either overwrite old data or be appended,
%   default prompts the user
%
% Further comments:
%
% If you want to append data to existing data, you have to assigne the new
% data with the same EntityID as the already stored data
%
%
%
% Notes: (example call)
%
% store_ns_neweventdata('newdata',newdata,'DataOrigin','Example_String')
%      (--> newdata.Event.TimeStamp{i}=<myTriggerMatrix>;)
%
% --------------------------------------------------
% kilias 08-11/08, M.Nenniger
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={'newdata','DataOrigin'};

    % optional arguments names with default values
    optionalArgs={
        {'loadMode', @(val) ismember(val,{'prompt','append','overwrite'})}...
        };

    % default parameter values
    loadMode='prompt';

    % parameter check
    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,'');
    end
    pvpmod(varargin);

    % check for new data
    if ~isfield(newdata,'Event') || ~isfield(newdata.Event,'TimeStamp') ...
            || sum(cellfun(@isempty, newdata.Event.TimeStamp))==size(newdata.Event.TimeStamp,2) %all cells are empty
        error('FIND:noNewEventData','No event TimeStamps found in ''newdata'' variable.');
    end

    % check for possible absent EntityIDs
    if ~isfield(newdata.Event,'EntityID') || isempty(newdata.Event.EntityID)
        newdata.Event.EntityID=max([nsFile.EntityInfo.EntityID])+1;
    end

    % check for possible absent Data
    if ~isfield(newdata.Event,'Data') || sum(cellfun(@isempty, newdata.Event.Data))==size(newdata.Event.Data,2) %all cells are empty
        for kk=1:size(newdata.Event.TimeStamp,2)
            newdata.Event.Data{kk}=zeros(size(newdata.Event.TimeStamp{kk}));
        end
    elseif ~isfield(newdata.Event,'Data') && size(newdata.Event.Data,2)==size(newdata.Event.TimeStamp,2)
        error('FIND: Mismaching Data and TimeStamp.');
    end

    % check for possible absent DataSize
    if ~isfield(newdata.Event,'DataSize') || sum(cellfun(@isempty, newdata.Event.DataSize))==size(newdata.Event.DataSize,2) %all cells are empty
        for kk=1:size(newdata.Event.TimeStamp,2)
            newdata.Event.DataSize{kk}=zeros(length(newdata.Event.TimeStamp{kk}),1);
        end
    end

    % check if fields in nsFile are set
    if ~isfield(nsFile,'Event') || ~isfield(nsFile.Event,'TimeStamp')
        nsFile.Event.TimeStamp{1}=[];
        nsFile.Event.Data{1}=[];
        nsFile.Event.DataSize{1}=[];
        nsFile.Event.EntityID=[NaN];
    end
    usedIDs=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% case 1  --> nsFile.Event is empty

    if sum(cellfun(@isempty,nsFile.Event.TimeStamp))==size(nsFile.Event.TimeStamp,2)||...
            sum(cellfun(@isempty,nsFile.Event.Data))==size(nsFile.Event.Data,2)

        loadModeSwitch='overwrite';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 2  --> some data already present in nsFile.Event

    elseif sum(cellfun(@isempty,nsFile.Event.TimeStamp))~=size(nsFile.Event.TimeStamp,2)

        if strcmp(loadMode,'prompt')
            loadModeSwitch=questdlg('Some event TimeStamps already exists in the FIND variable',...
                'Overwrite all Data?', ...
                'overwrite','append','cancel','cancel');
        else
            loadModeSwitch=loadMode;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 3  --> ERROR
    else
        error('FIND: Error while storing new event data');
    end

    switch loadModeSwitch
        case 'overwrite'
            % initialise first
            nsFile.Event.TimeStamp={[]};
            nsFile.Event.Data={[]};
            nsFile.Event.DataSize={[]};
            nsFile.Event.EntityID=[];
            nsFile.Event.Info=[];
            % write data
            nsFile.Event.TimeStamp=newdata.Event.TimeStamp;
            nsFile.Event.Data=newdata.Event.Data;
            nsFile.Event.DataSize=newdata.Event.DataSize;
            nsFile.Event.EntityID=newdata.Event.EntityID;
            % set event infos
            if isfield(newdata.Event,'Info')
                for posEntityID=1:length(newdata.Event.EntityID)
                    nsFile.Event.Info(posEntityID).MinDataLength=newdata.Event.Info(posEntityID).MinDataLength;
                    nsFile.Event.Info(posEntityID).MaxDataLength=newdata.Event.Info(posEntityID).MaxDataLength;
                    nsFile.Event.Info(posEntityID).EventType=newdata.Event.Info(posEntityID).EventType;
                    nsFile.Event.Info(posEntityID).CSVDesc=newdata.Event.Info(posEntityID).CSVDesc;
                    nsFile.Event.Info(posEntityID).EntityID=newdata.Event.EntityID(posEntityID);
                    nsFile.Event.Info(posEntityID).ItemCount=size(newdata.Event.TimeStamp{posEntityID},1);
                    nsFile.Event.Info(posEntityID).EntityLabel=DataOrigin{posEntityID};
                end
            else
                for posEntityID=1:length(newdata.Event.EntityID)
                    nsFile.Event.Info(posEntityID).EventType=1;
                    nsFile.Event.Info(posEntityID).MinDataLength=[];
                    nsFile.Event.Info(posEntityID).MaxDataLength=[];
                    nsFile.Event.Info(posEntityID).CSVDesc='';
                    nsFile.Event.Info(posEntityID).EntityID=newdata.Event.EntityID(posEntityID);
                    nsFile.Event.Info(posEntityID).ItemCount=size(nsFile.Event.TimeStamp{posEntityID},1);
                    nsFile.Event.Info(posEntityID).EntityLabel=DataOrigin{posEntityID};
                end
            end
            usedIDs=[usedIDs,newdata.Event.EntityID];
        case 'append'
            for ff=1:length(newdata.Event.EntityID)
                % selection only through DataentityIDs possible
                % store all non double IDs directly as a new entity
                if ~ismember(newdata.Event.EntityID(ff),nsFile.Event.EntityID)
                    loadModeSwitch='store with new ID';
                    newEntityID=newdata.Event.EntityID(ff);
                    disp(['Data stored in EnityID ',num2str(newdata.Event.EntityID(ff)),' directly.']);
                else
                    if strcmp(loadMode,'prompt')
                        newEntityID=max(nsFile.Event.EntityID)+1;
                        warning off all;
                        loadModeSwitch=questdlg(['Event data with the EntityID ',...
                            num2str(newdata.Event.EntityID(ff)),...
                            ' already exists.'],...
                            'Overwrite Data of single Entity?', ...
                            'overwrite','append',...
                            ['store in new EntityID ',num2str(newEntityID)],...
                            'cancel');
                        if strcmp(loadModeSwitch,strcat('store in new DataentityID ',num2str(newEntityID)))
                            loadModeSwitch='store with new ID';
                        end
                        warning on all;
                    else
                        loadModeSwitch=loadMode;
                    end
                end

                switch loadModeSwitch
                    case 'overwrite'
                        posEntityID=find(nsFile.Event.EntityID==newdata.Event.EntityID(ff));
                        nsFile.Event.Data{posEntityID}=newdata.Event.Data{ff};
                        nsFile.Event.EntityID(posEntityID)=newdata.Event.EntityID(ff);
                        nsFile.Event.TimeStamp{posEntityID}=newdata.Event.TimeStamp{ff};
                        nsFile.Event.DataSize{posEntityID}=newdata.Event.DataSize{ff};
                        if isfield(newdata.Event,'Info')
                            nsFile.Event.Info(posEntityID).MinDataLength=newdata.Event.Info(ff).MinDataLength;
                            nsFile.Event.Info(posEntityID).MaxDataLength=newdata.Event.Info(ff).MaxDataLength;
                            nsFile.Event.Info(posEntityID).EventType=newdata.Event.Info(ff).EventType;
                            nsFile.Event.Info(posEntityID).CSVDesc=newdata.Event.Info(ff).CSVDesc;
                            nsFile.Event.Info(posEntityID).EntityID=newdata.Event.EntityID(ff);
                            nsFile.Event.Info(posEntityID).ItemCount=size(newdata.Event.TimeStamp{ff},1);
                            nsFile.Event.Info(posEntityID).EntityLabel=DataOrigin{ff};
                        else
                            nsFile.Event.Info(posEntityID).EventType=1;
                            nsFile.Event.Info(posEntityID).MinDataLength=[];
                            nsFile.Event.Info(posEntityID).MaxDataLength=[];
                            nsFile.Event.Info(posEntityID).CSVDesc='';
                            nsFile.Event.Info(posEntityID).EntityID=newdata.Event.EntityID(ff);
                            nsFile.Event.Info(posEntityID).ItemCount=size(nsFile.Event.TimeStamp{posEntityID},1);
                            nsFile.Event.Info(posEntityID).EntityLabel=DataOrigin{ff};
                        end
                        usedIDs=[usedIDs,newdata.Event.EntityID(ff)];
                    case 'append'
                        posEntityID=find(nsFile.Event.EntityID==newdata.Event.EntityID(ff));
                        if size(newdata.Event.TimeStamp{ff},1)~=size(nsFile.Event.TimeStamp{posEntityID},1)
                            disp({['Try to append Events of different length! '];...
                                ['new EntityID ', num2str(newdata.Event.EntityID(ff)),...
                                ' could not be appended']});
                        else
                            nsFile.Event.Data{posEntityID}=horzcat(nsFile.Event.Data{posEntityID},newdata.Event.Data{ff});
                            nsFile.Event.TimeStamp{posEntityID}=[nsFile.Event.TimeStamp{posEntityID};newdata.Event.TimeStamp{ff}];
                            nsFile.Event.DataSize{posEntityID}=[nsFile.Event.DataSize{posEntityID};newdata.Event.DataSize{ff}];
                            % set event infos
                            nsFile.Event.Info(posEntityID).Label=strcat(nsFile.Event.Info(posEntityID).EntityLabel,' and appended ',DataOrigin{ff});
                            nsFile.Event.Info(posEntityID).ItemCount=size(nsFile.Event.TimeStamp{posEntityID},1);
                        end
                        usedIDs=[usedIDs,newdata.Event.EntityID(ff)];
                    case 'store with new ID'
                        nsFile.Event.Data{end+1}=newdata.Event.Data{ff};
                        nsFile.Event.EntityID(end+1)=newEntityID;
                        nsFile.Event.TimeStamp{end+1}=newdata.Event.TimeStamp{ff};
                        nsFile.Event.DataSize{end+1}=newdata.Event.DataSize{ff};

                        if isfield(newdata.Event,'Info')
                            nsFile.Event.Info(end+1).MinDataLength=newdata.Event.Info(ff).MinDataLength;
                            nsFile.Event.Info(end).MaxDataLength=newdata.Event.Info(ff).MaxDataLength;
                            nsFile.Event.Info(end).EventType=newdata.Event.Info(ff).EventType;
                            nsFile.Event.Info(end).CSVDesc=newdata.Event.Info(ff).CSVDesc;
                            nsFile.Event.Info(end).EntityID=newdata.Event.EntityID(ff);
                            nsFile.Event.Info(end).ItemCount=size(newdata.Event.TimeStamp{ff},1);
                            nsFile.Event.Info(end).EntityLabel=DataOrigin{ff};
                        else
                            nsFile.Event.Info(end+1).EventType=1;
                            nsFile.Event.Info(end).MinDataLength=[];
                            nsFile.Event.Info(end).MaxDataLength=[];
                            nsFile.Event.Info(end).CSVDesc='';
                            nsFile.Event.Info(end).EntityID=newEntityID;
                            nsFile.Event.Info(end).ItemCount=size(newdata.Event.TimeStamp{ff},1);
                            nsFile.Event.Info(end).EntityLabel=DataOrigin{ff};
                        end
                        usedIDs=[usedIDs,newEntityID];
                    case ''
                        disp(['DataentityID : ',num2str(newdata.Event.EntityID(ff)),' not stored']);
                end
            end
        case 'cancel'
            disp('no NEW data in Event');
            return;
    end

    % finaly set new FileInfo
    if isfield(nsFile.Event,'Data') && ~isempty(nsFile.Event.TimeStamp)
        nsFile.FileInfo.Datatypespresent(1)=1;
    end

    % generate some report
    disp(['currently available Event.EntityID : ',num2str(nsFile.Event.EntityID)]);

catch
    rethrow(lasterror);
end