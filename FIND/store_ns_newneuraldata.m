function [usedIDs]=store_ns_newneuraldata(varargin)
% function store_ns_newneuraldata
% This function appends new neural data properly to existing data.
% If neural data already exists in nsFile, the user is prompted.
% New data can be written over existing data or be appended to the
% variable.
%
% If the new data and already existing data are assigned by the same
% EntityID the user can elongate the exiting data by the new ones,
% overwrite the old data or store the new data in a new postion by creating
% a new Entity (and a new ID).Data are stored in cells.
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'newdata': is a structure similar to the nsFile which contains data to
%   store, here newdata.Neural.Data is the minimum requirement.
%
% 'DataOrigin': string to determine were the data come from (i.e.
%   'detected Spikes from analog data')
%
% %%%%% Optional Parameters %%%%%
%
% 'newdata.Neural.EntityID' : the existence of this field is in contrast to
%   the field 'newdata.Neural.Data' optional. The variable can be used to
%   assigne the derivated new neural data by using the same EntityID as for
%   the original data
%
%'loadMode': new neural data can either overwrite old data or be appended,
%   default prompts the user
%
% Further comments:
%
% If you want to append data to existing data, you have to assigne the new
% data with the same EntityID as the already stored data
%
% Recently this programm checks only for already existing data in the
% neural entity and not for all typs of entities
%
% Notes: (example call)
%
% store_ns_newneuraldata('newdata',newdata,'DataOrigin','Example_String')
% (--> newdata.Neural.Data{1}=<mySpikeTrain1>; newdata.Neural.Data{2}=<mySpikeTrain2>)
%
% --------------------------------------------------
% kilias 08-11/08, H.Walz, M.Nenniger
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
    if ~isfield(newdata,'Neural') || ~isfield(newdata.Neural,'Data') ...
            || sum(cellfun(@isempty, newdata.Neural.Data))==size(newdata.Neural.Data,2) %all cells are empty
        error('FIND:noNewNeuralData','No neural data found in ''newdata'' variable.');
    end

    % check for possible absent EntityIDs
    if ~isfield(newdata.Neural,'EntityID') || isempty(newdata.Neural.EntityID)
        newdata.Neural.EntityID=[1:size(newdata.Neural.Data,2)];
    elseif isfield(newdata.Neural,'EntityID') && length(newdata.Neural.EntityID)~=size(newdata.Neural.Data,2)
        error('FIND: Mismaching Data and EntityIDs.');
    end

    % check for length of DataOrigin
    if size(DataOrigin,2)==1
        for gg=1:length(newdata.Neural.EntityID)
            DataOrigin{gg}= DataOrigin{1};
        end
    elseif size(DataOrigin,2)==length(newdata.Neural.EntityID)
    else    error('FIND: Mismaching DataOrigin (Label) and EntityID.');
    end

    % check if fields in nsFile are set
    if ~isfield(nsFile,'Neural') || ~isfield(nsFile.Neural,'Data')
        nsFile.Neural.Data={[]};
        nsFile.Neural.EntityID=[];
        nsFile.Neural.Info=[];
    end

    usedIDs=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% case 1  --> nsFile.Neural is empty

    if sum(cellfun(@isempty, nsFile.Neural.Data))==size(nsFile.Neural.Data,2)
        loadModeSwitch='overwrite';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 2  --> some data already present in nsFile.Neural

    elseif sum(cellfun(@isempty, nsFile.Neural.Data))~=size(nsFile.Neural.Data,2)
        if strcmp(loadMode,'prompt')
            loadModeSwitch=questdlg('Some neural data already exists in the FIND variable',...
                'Overwrite all Data?', ...
                'overwrite','append','cancel','cancel');
        else
            loadModeSwitch=loadMode;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 3  --> ERROR
    else
        error('FIND: Error while storing new neural data');
    end

    switch loadModeSwitch
        case 'overwrite'
            % initialise first
            nsFile.Neural.Data={[]};
            nsFile.Neural.EntityID=[];
            nsFile.Neural.Info=[];
            % write data
            nsFile.Neural.Data=newdata.Neural.Data;
            nsFile.Neural.EntityID=newdata.Neural.EntityID;

            for tt=1:length(newdata.Neural.EntityID)
                % set neural infos
                nsFile.Neural.Info(tt).Label=DataOrigin{tt};
                nsFile.Neural.Info(tt).Type=4;
                nsFile.Neural.Info(tt).Count=length(nsFile.Neural.Data{tt});
                nsFile.Neural.Info(tt).EntityID=newdata.Neural.EntityID(tt);
            end
            usedIDs=[usedIDs,newdata.Neural.EntityID];
        case 'append'
            for ff=1:length(newdata.Neural.EntityID)
                newEntityID=max(nsFile.Neural.EntityID)+1;
                % selection only through EntityID possible
                % store all non double IDs directly as a new entity
                if ~ismember(newdata.Neural.EntityID(ff),nsFile.Neural.EntityID)
                    loadModeSwitch='store with new ID';
                    newEntityID=newdata.Neural.EntityID(ff);
                    disp(['Data stored in EnityID ',num2str(newdata.Neural.EntityID(ff)),' directly.']);
                else
                    if strcmp(loadMode,'prompt')
                        warning off all;
                        loadModeSwitch=questdlg(['Neural data with the EntityID ',...
                            num2str(newdata.Neural.EntityID(ff)),...
                            ' already exists.'],...
                            'Overwrite Data of single Entity?', ...
                            'overwrite','append',...
                            ['store in new EntityID ',num2str(newEntityID)],...
                            'cancel');
                        if strcmp(loadModeSwitch,strcat('store in new EntityID ',num2str(newEntityID)))
                            loadModeSwitch='store with new ID';
                        end
                        warning on all;
                    else
                        loadModeSwitch=loadMode;
                    end
                end

                switch loadModeSwitch
                    case 'overwrite'
                        posEntityID=find(nsFile.Neural.EntityID==newdata.Neural.EntityID(ff));
                        nsFile.Neural.Data{posEntityID}=newdata.Neural.Data{ff};
                        % REDUNDAND: nsFile.Neural.EntityID(posEntityID)=newdata.Neural.EntityID(ff);
                        % nsFile.Neural.Info(posEntityID)=[];
                        % set neural infos
                        nsFile.Neural.Info(posEntityID).Label=DataOrigin{ff};
                        nsFile.Neural.Info(posEntityID).Type=4;
                        nsFile.Neural.Info(posEntityID).Count=length(nsFile.Neural.Data{posEntityID});
                        nsFile.Neural.Info(posEntityID).EntityID=newdata.Neural.EntityID(ff);

                        usedIDs=[usedIDs,newdata.Neural.EntityID(ff)];
                    case 'append'
                        posEntityID=find(nsFile.Neural.EntityID==newdata.Neural.EntityID(ff))
                        nsFile.Neural.Data{posEntityID}=[nsFile.Neural.Data{posEntityID};newdata.Neural.Data{ff}];
                        % set neural infos
                        nsFile.Neural.Info(posEntityID).Label=([nsFile.Neural.Info(posEntityID).Label,' and appended ',DataOrigin{ff}]);
                        nsFile.Neural.Info(posEntityID).Type=4;
                        nsFile.Neural.Info(posEntityID).Count=length(nsFile.Neural.Data{posEntityID});
                        % stays: nsFile.Neural.Info(posEntityID).EntityID

                        usedIDs=[usedIDs,newdata.Neural.EntityID(ff)];
                    case 'store with new ID'
                        nsFile.Neural.Data{end+1}=newdata.Neural.Data{ff};
                        nsFile.Neural.EntityID(end+1)=newEntityID;
                        % set neural infos
                        nsFile.Neural.Info(end+1).Label=DataOrigin{ff};
                        nsFile.Neural.Info(end).Type=4;
                        nsFile.Neural.Info(end).Count=length(nsFile.Neural.Data{end});
                        nsFile.Neural.Info(end).EntityID=newEntityID;

                        usedIDs=[usedIDs,newEntityID];
                    case ''
                        disp('no NEW data in Neural');
                        return;
                end
            end
        case 'cancel'
            return;
    end

    % finaly set new FileInfo
    if isfield(nsFile.Neural,'Data') && sum(cellfun(@isempty, nsFile.Neural.Data))~=size(nsFile.Neural.Data,2)
        nsFile.FileInfo.Datatypespresent(4)=1;
    end

    % generate some report
    disp(['currently available Neural.EntityID : ',num2str(nsFile.Neural.EntityID)]);

catch
    rethrow(lasterror);
end