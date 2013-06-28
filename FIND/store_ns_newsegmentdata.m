function store_ns_newsegmentdata(varargin)
% function store_ns_newsegmentdata
% This function appends new event data properly to existing data.
% If data already exists in nsFile, the user is prompted.
% New data can be written over existing data or be appended to the
% variable. If the new data and already existing data are assigned by the same
% EntityID the user can elongate the exiting data by the new ones,
% overwrite the old data or store the new data in a new postion by creating
% a new Entity (and a new ID). If already existing data and new data is not
% of equal length, zero padding is used.
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'newdata': is a structure similar to the nsFile which contains data to
%   store, here newdata.Segment.Data and nsFile.Segment.TimeStamp is the
%   minimum requirement.
%
% 'DataOrigin': string to determine were the data come from (i.e.
%   'cut out Spikes from analog data')
%
%
% %%%%% Optional Parameters %%%%%
%
% 'newdata.Segment.DataentityIDs' : the existence of this field is in contrast to
%   the field 'newdata.Segment.Data' optional. The variable can be used to
%   assigne derivated new Segment data by using the same EntityID as for
%   the original data (i.e. detect and cut out spikes from analog data are
%   stored with the same EntityID, one cell referes to one analog entity)
%
%
% 'newdata.Segment.UnitID' : if the spikes have been sorted already you can
% commit the IDs referring to the clusters or cells
%
%'loadMode': new segment data can either overwrite old data or be appended,
%   default prompts the user
%
% Further comments:
%
% If you want to append data to existing data, you have to assigne the new
% data with the same EntityID as the already stored data
%
%
% Notes: (example call)
%
% store_ns_newsegmentdata('newdata',newdata,'DataOrigin','Example_String')
%
% --------------------------------------------------
% kilias 08/08 , M.Nenniger
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={'newdata','DataOrigin'};

    % optional arguments names with default values
    optionalArgs={
        {'loadMode', @(val) ismember(val,{'prompt','append','overwrite'})},...
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
    if ~isfield(newdata,'Segment') || ~isfield(newdata.Segment,'Data') ...
            || sum(cellfun(@isempty, newdata.Segment.Data))==size(newdata.Segment.Data,2) %all cells are empty
        error('FIND:noNewSegmentData','No segment data found in ''newdata'' variable.');
    end

    % check for possible absent DataentityIDs
    if ~isfield(newdata.Segment,'DataentityIDs') || isempty(newdata.Segment.DataentityIDs)
        newdata.Segment.DataentityIDs=[1:size(newdata.Segment.Data,2)];
    elseif isfield(newdata.Segment,'DataentityIDs') && length(newdata.Segment.DataentityIDs)~=size(newdata.Segment.Data,2)
        error('FIND: Mismaching Data and DataentityIDs.');
    end

    % check for length of DataOrigin
    if size(DataOrigin,2)==1
        for gg=1:length(newdata.Segment.DataentityIDs)
            DataOrigin{gg}= DataOrigin{1};
        end
    elseif size(DataOrigin,2)==length(newdata.Segment.DataentityIDs)
    else    error('FIND: Mismaching DataOrigin (Label) and DataentityIDs.');
    end

    % check for possible absent UnitID
    if ~isfield(newdata.Segment,'UnitID') || ...
            sum(cellfun(@isempty, newdata.Segment.UnitID))==size(newdata.Segment.UnitID,2) %all cells are empty
        for cc=1:size(newdata.Segment.Data,2)
            newdata.Segment.UnitID{cc}=zeros(1:size(newdata.Segment.Data{cc}),1);
        end
    elseif ~isfield(newdata.Segment,'UnitID') && size(newdata.Segment.UnitID,2)==size(newdata.Segment.Data,2)
        error('FIND: Mismaching Data and UnitIDs.');
    end


    % check if fields in nsFile are set
    if ~isfield(nsFile,'Segment') || ~isfield(nsFile.Segment,'Data')
        nsFile.Segment.Data={[]};
        nsFile.Segment.TimeStamp={[]};
        nsFile.Segment.UnitID={[]};
        nsFile.Segment.SampleCount={[]};
        nsFile.Segment.DataentityIDs=[];
    end

    wasCanceled=0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% case 1  --> nsFile.Segment is empty

    if sum(cellfun(@isempty, nsFile.Segment.Data))==size(nsFile.Segment.Data,2)
        loadModeSwitch='overwrite';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 2  --> some data already present in nsFile.Segment

    elseif sum(cellfun(@isempty, nsFile.Segment.Data))~=size(nsFile.Segment.Data,2)

        if strcmp(loadMode,'prompt')
            loadModeSwitch=questdlg('Some segment data already exists in the FIND variable',...
                'Overwrite all Data?', ...
                'overwrite','append','cancel','cancel');
        else
            loadModeSwitch=loadMode;
        end
        newEntityID=max(nsFile.Segment.DataentityIDs)+1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 3  --> ERROR
    else
        error('FIND: Error while storing new segment data');
    end

    switch loadModeSwitch
        case 'overwrite'
            % initialise first
            nsFile.Segment.Data={[]};
            nsFile.Segment.TimeStamp={[]};
            nsFile.Segment.UnitID={[]};
            nsFile.Segment.SampleCount={[]};
            nsFile.Segment.DataentityIDs=[];
            nsFile.Segment.Info=[];

            % write data
            nsFile.Segment.Data=newdata.Segment.Data;
            nsFile.Segment.DataentityIDs=newdata.Segment.DataentityIDs;
            nsFile.Segment.TimeStamp=newdata.Segment.TimeStamp;
            nsFile.Segment.UnitID=newdata.Segment.UnitID;

            for tt=1:length(newdata.Segment.DataentityIDs)
                nsFile.Segment.SampleCount{tt}=repmat(size(newdata.Segment.Data{tt},1),size(newdata.Segment.Data{tt},2),1); % data points of each single item (i.e. spikes)
                % set Segment infos
                nsFile.Segment.Info(tt).Label=DataOrigin{tt};
                nsFile.Segment.Info(tt).Type=3;
                nsFile.Segment.Info(tt).ItemCount=size(nsFile.Segment.Data{tt},2); %i.e. #spikes
                nsFile.Segment.Info(tt).EntityID=newdata.Segment.DataentityIDs(tt);
            end

        case 'append'
            for ff=1:length(newdata.Segment.DataentityIDs)
                % selection only through DataentityIDs possible
                % store all non double IDs directly as a new entity
                if ~ismember(newdata.Segment.DataentityIDs(ff),nsFile.Segment.DataentityIDs)
                    loadModeSwitch='store with new ID';
                    newEntityID=newdata.Segment.DataentityIDs(ff);
                    disp(['Data stored in EnityID ',num2str(newdata.Segment.DataentityIDs(ff)),' directly.']);
                else
                    if strcmp(loadMode,'prompt')
                        newEntityID=max(nsFile.Segment.DataentityIDs)+1;
                        warning off all;
                        loadModeSwitch=questdlg(['Segment data with the DataentityID ',...
                            num2str(newdata.Segment.DataentityIDs(ff)),...
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
                        posEntityID=find(nsFile.Segment.DataentityIDs==newdata.Segment.DataentityIDs(ff));
                        nsFile.Segment.Data{posEntityID}=newdata.Segment.Data{ff};
                        nsFile.Segment.DataentityIDs(posEntityID)=newdata.Segment.DataentityIDs(ff);
                        nsFile.Segment.TimeStamp{posEntityID}=newdata.Segment.TimeStamp{ff};
                        nsFile.Segment.UnitID{posEntityID}=newdata.Segment.UnitID{ff};
                        nsFile.Segment.SampleCount{posEntityID}=repmat(size(newdata.Segment.Data{ff},1),size(newdata.Segment.Data{ff},2),1);
                        nsFile.Segment.Info(posEntityID)=struct('Label','','Type',[],'ItemCount',[],'EntityID',[]);
                        % set segment infos
                        nsFile.Segment.Info(posEntityID).Label=DataOrigin{ff};
                        nsFile.Segment.Info(posEntityID).Type=3;
                        nsFile.Segment.Info(posEntityID).ItemCount=size(nsFile.Segment.Data{posEntityID},2);
                        nsFile.Segment.Info(posEntityID).EntityID=newdata.Segment.DataentityIDs(ff);

                    case 'append'
                        posEntityID=find(nsFile.Segment.DataentityIDs==newdata.Segment.DataentityIDs(ff));
                        if size(newdata.Segment.Data{ff},1)~=size(nsFile.Segment.Data{posEntityID},1)
                            disp({['Try to append Segments of different length! '];...
                                ['new DataentityID ', num2str(newdata.Segment.DataentityIDs(ff)),...
                                ' could not be appended']});
                        else
                            nsFile.Segment.Data{posEntityID}=horzcat(nsFile.Segment.Data{posEntityID},newdata.Segment.Data{ff});
                            nsFile.Segment.TimeStamp{posEntityID}=[nsFile.Segment.TimeStamp{posEntityID};newdata.Segment.TimeStamp{ff}];
                            nsFile.Segment.UnitID{posEntityID}=[nsFile.Segment.UnitID{posEntityID};newdata.Segment.UnitID{ff}];
                            nsFile.Segment.SampleCount{posEntityID}=repmat(size(newdata.Segment.Data{posEntityID},1),size(newdata.Segment.Data{posEntityID},2),1);
                            % set segment infos
                            nsFile.Segment.Info(posEntityID).Label=strcat(nsFile.Segment.Info(posEntityID).Label,' and appended ',DataOrigin{ff});
                            nsFile.Segment.Info(posEntityID).ItemCount=size(nsFile.Segment.Data{posEntityID},2);
                        end

                    case 'store with new ID'
                        nsFile.Segment.Data{end+1}=newdata.Segment.Data{ff};
                        nsFile.Segment.DataentityIDs(end+1)=newEntityID;
                        nsFile.Segment.TimeStamp{end+1}=newdata.Segment.TimeStamp{ff};
                        nsFile.Segment.SampleCount{end+1}=repmat(size(newdata.Segment.Data{ff},1),size(newdata.Segment.Data{ff},2),1);
                        nsFile.Segment.UnitID{end+1}=newdata.Segment.UnitID{ff};
                        % set segment infos
                        nsFile.Segment.Info(end+1).Label=DataOrigin{ff};
                        nsFile.Segment.Info(end).Type=3;
                        nsFile.Segment.Info(end).ItemCount=size(newdata.Segment.Data{ff},2);
                        nsFile.Segment.Info(end).EntityID=newEntityID;

                    case ''
                        disp(['DataentityID : ',num2str(newdata.Segment.DataentityIDs(ff)),' not stored']);
                end
            end
        case 'cancel'
            disp('no NEW data in Segment');
            return;
    end


    % finaly set new FileInfo
    if isfield(nsFile.Segment,'Data') && sum(cellfun(@isempty, nsFile.Segment.Data))~=size(nsFile.Segment.Data,2)
        nsFile.FileInfo.Datatypespresent(3)=1;
    end

    % generate some report
    disp(['currently available Segment.DataentityIDs: ',num2str(nsFile.Segment.DataentityIDs)]);

catch
    rethrow(lasterror);
end
