function [usedIDs]=store_ns_newanalogdata(varargin)
% function store_ns_newanalogdata
% This function appends new analog data properly to existing data.
% If data already exists in nsFile, the user is prompted.
% New data can be written over existing data or be appended to the
% variable.
%
% The user can elongate the exiting data by the new ones,
% overwrite the old data or store the new data in a new postion by creating
% a new Entity (and a new ID). If already existing data and new data are not
% of equal length, zero padding is used.
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'newdata': is a structure similar to the nsFile which contains data to
%   store, here newdata.Analog.Data is the minimum requirement. Data are
%   stored in one array in which each column refers to a Entity.
%
% if there are Infos to store push into newdata structure
%
%     newdata.Analog.Info(i).SampleRate=[];
%     newdata.Analog.Info(i).MinVal=[];
%     newdata.Analog.Info(i).MaxVal=[];
%     newdata.Analog.Info(i).Units=[];
%     newdata.Analog.Info(i).Resolution=[];
%     newdata.Analog.Info(i).LocationX=[];
%     newdata.Analog.Info(i).LocationY=[];
%     newdata.Analog.Info(i).LocationZ=[];
%     newdata.Analog.Info(i).LocationUser=[];
%     newdata.Analog.Info(i).HighFreqCorner=[];
%     newdata.Analog.Info(i).HighFreqOrder=[];
%     newdata.Analog.Info(i).HighFilterType=[];
%     newdata.Analog.Info(i).LowFreqCorner=[];
%     newdata.Analog.Info(i).LowFreqOrder=[];
%     newdata.Analog.Info(i).LowFilterType=[];
%     newdata.Analog.Info(i).ProbeInfo=[];
%     newdata.Analog.Info(i).EntityID=[];
%     newdata.Analog.Info(i).ItemCount=[];
%     newdata.Analog.Info(i).EntityLabel=[];
%
% %%%%% Optional Parameters %%%%%
%
% 'newdata.Analog.DataentityIDs' : the existence of this field is in contrast to
%   the field 'newdata.Analog.Data' optional.
%
%'loadMode': new event data can either overwrite old data or be appended,
%   default prompts the user
%
% Further comments:
%
%
% Notes: (example call)
%
% store_ns_newanalogdata('newdata',newdata,'loadMode','overwrite','zeroPadding','yes')
%      (--> newdata.Analog.Data=<myDataMatrix>;
%       where each column represents an entity)
%
% --------------------------------------------------
% kilias 08/08 ,M.Nenniger
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={'newdata'};

    % optional arguments names with default values
    optionalArgs={
        {'loadMode', @(val) ismember(val,{'prompt','append','overwrite'})},...
        {'zeroPadding',@(val) ismember(val,{'prompt','yes','cancel'})}...
        };

    % default parameter values
    loadMode='prompt';
    setInfos=false;
    zeroPadding='prompt';

    % parameter check
    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,'');
    end
    pvpmod(varargin);

    % check for new data
    if ~isfield(newdata,'Analog') || ~isfield(newdata.Analog,'Data') ...
            || isempty(newdata.Analog.Data)
        error('FIND:noNewAnalogData','No analog Data found in ''newdata'' variable.');
    end

    % check for possible absent EntityIDs
    if ~isfield(newdata.Analog,'DataentityIDs') || isempty(newdata.Analog.DataentityIDs)
        newdata.Analog.DataentityIDs=[1:size(newdata.Analog.Data,2)];
    elseif isfield(newdata.Analog,'DataentityIDs')&& (size(newdata.Analog.Data,2)~=length(newdata.Analog.DataentityIDs))
        error('FIND: Mismaching Data and DataentityIDs.')
    end

    if isfield(newdata.Analog,'Info')&& size(newdata.Analog.Info,1)==length(newdata.Analog.DataentityIDs)
        setInfos=true;
        % if setInfo is set false, this will result in many empty info fields
    end

    % check if fields in nsFile are set
    if ~isfield(nsFile,'Analog') || ~isfield(nsFile.Analog,'Data')
        nsFile.Analog.Data=[];
        nsFile.Analog.DataentityIDs=[];

        nsFile.Analog.Info.SampleRate=[];
        nsFile.Analog.Info.MinVal=[];
        nsFile.Analog.Info.MaxVal=[];
        nsFile.Analog.Info.Units=[];
        nsFile.Analog.Info.Resolution=[];
        nsFile.Analog.Info.LocationX=[];
        nsFile.Analog.Info.LocationY=[];
        nsFile.Analog.Info.LocationZ=[];
        nsFile.Analog.Info.LocationUser=[];
        nsFile.Analog.Info.HighFreqCorner=[];
        nsFile.Analog.Info.HighFreqOrder=[];
        nsFile.Analog.Info.HighFilterType=[];
        nsFile.Analog.Info.LowFreqCorner=[];
        nsFile.Analog.Info.LowFreqOrder=[];
        nsFile.Analog.Info.LowFilterType=[];
        nsFile.Analog.Info.ProbeInfo=[];
        nsFile.Analog.Info.EntityID=[];
        nsFile.Analog.Info.ItemCount=[];
        nsFile.Analog.Info.EntityLabel=[];
    end

    if setInfos
        listOfFields=fieldnames(nsFile.Analog.Info(1));
        listOfMiss=find(ismember(fieldnames(nsFile.Analog.Info(1)),fieldnames(newdata.Analog.Info(1)))==0);
        for yy=1:length(listOfMiss)
            newdata.Analog.Info=setfield(newdata.Analog.Info,{1},char(listOfFields(listOfMiss(yy))),[]);
        end
    end

    usedIDs=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% case 1  --> nsFile.Analog is empty

    if isempty(nsFile.Analog.Data)
        loadModeSwitch='overwrite';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 2  --> some data already present in nsFile.Analog

    elseif ~isempty(nsFile.Analog.Data)

        if strcmp(loadMode,'prompt')
            loadModeSwitch=questdlg(['Some analog data already exists in the FIND variable (DataentityIDs: ',...
                num2str(nsFile.Analog.DataentityIDs),')'],...
                'Overwrite all Data?', ...
                'overwrite','append','cancel','cancel');
        else
            loadModeSwitch=loadMode;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% case 3  --> ERROR
    else
        error('FIND: Error while storing new analog data');
    end

    switch loadModeSwitch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'overwrite'
            % initialise first
            nsFile.Analog.Data=[];
            nsFile.Analog.DataentityIDs=[];
            % write data
            nsFile.Analog.Data=newdata.Analog.Data;
            nsFile.Analog.DataentityIDs=newdata.Analog.DataentityIDs;
            % set analog infos
            if setInfos==1
                nsFile.Analog.Info=newdata.Analog.Info;
            else
                for kk=1:length(newdata.Analog.DataentityIDs)
                    nsFile.Analog.Info(kk).EntityID=newdata.Analog.DataentityIDs(kk);
                    nsFile.Analog.Info(kk).ItemCount=size(newdata.Analog.Data,1);
                end
            end
            usedIDs=[usedIDs;newdata.Analog.DataentityIDs];
            % delete abundand infos
            nsFile.Analog.Info=nsFile.Analog.Info(1:length(newdata.Analog.DataentityIDs));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'append'
            wasCancelled=0;
            % get only datastreams which not have been loaded already
            % tempidx contains Id in correct order refering to
            % newdata.Analog.Data
            nonDoubleIDs=setdiff(newdata.Analog.DataentityIDs,nsFile.Analog.DataentityIDs);
            DoubleIDs=intersect(newdata.Analog.DataentityIDs,nsFile.Analog.DataentityIDs);
            if ~isempty(nonDoubleIDs)
                [nonDoubleIDs(1,:),IndNew]=setdiff(newdata.Analog.DataentityIDs,nsFile.Analog.DataentityIDs);
                %save entityIDs of loaded data
                nsFile.Analog.DataentityIDs=horzcat(nsFile.Analog.DataentityIDs,nonDoubleIDs);
            elseif ~isempty(DoubleIDs)
                disp(['DataentityIDs ',num2str(DoubleIDs),' have been loaded already and were not appended']);
            else
                disp('all selected DataentityIDs have been loaded already');
                return;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% newdata longer than old data
            if size(nsFile.Analog.Data,1) < size(newdata.Analog.Data,1)
                lengthdiff=size(newdata.Analog.Data,1)-size(nsFile.Analog.Data,1);
                no_olddataseries=size(nsFile.Analog.Data,2);
                if strcmp(zeroPadding,'prompt')
                    zeroPaddingSwitch=questdlg(['New Data series is longer than the old data series, zero padding would use additional ',...
                        num2str(round(lengthdiff/1024)*8*no_olddataseries),' kbytes of memory. Use zero padding?'],...
                        'Data series not of equal length',...
                        'yes','cancel','cancel');
                else
                    zeroPaddingSwitch=zeroPadding; %='yes'
                end

                if strcmp('yes',zeroPaddingSwitch)
                    nsFile.Analog.Data=[nsFile.Analog.Data;zeros(lengthdiff,no_olddataseries)];
                else
                    wasCancelled=1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% old data longer than newdata
            elseif size(nsFile.Analog.Data,1) > size(newdata.Analog.Data,1)
                lengthdiff=size(nsFile.Analog.Data,1)-size(newdata.Analog.Data,1);
                no_newdataseries=size(newdata.Analog.Data,2);
                if strcmp(zeroPadding,'prompt')
                    zeroPaddingSwitch=questdlg(['New Data series is shorter than the old data series, zero padding would use additional ',...
                        num2str(round(lengthdiff/1024)*8*no_newdataseries),' kbytes of memory. Use zero padding?'],...
                        'Data series of unequal length',...
                        'yes','cancel','cancel');
                else
                    zeroPaddingSwitch=zeroPadding; %='yes'
                end

                if strcmp('yes',zeroPaddingSwitch)
                    newdata.Analog.Data=[newdata.Analog.Data;zeros(lengthdiff,no_newdataseries)];
                else
                    wasCancelled=1;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% finally concatenate data and set infos
            if ~wasCancelled
                if ~isempty(nonDoubleIDs)
                    usedIDs=[usedIDs;nonDoubleIDs];
                    nsFile.Analog.Data=[nsFile.Analog.Data,newdata.Analog.Data(:,IndNew)];
                    % set analog infos
                    for kk=1:length(nonDoubleIDs)
                        if setInfos==1
                            nsFile.Analog.Info(end+1)=newdata.Analog.Info(IndNew(kk));
                        else
                            nsFile.Analog.Info(end+1).EntityID=nonDoubleIDs(kk);
                            nsFile.Analog.Info(end).ItemCount=size(newdata.Analog.Data,1);
                        end
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'cancel'
            disp('no NEW data in Analog');
            return;
    end

    % finaly set new FileInfo
    if isfield(nsFile.Analog,'Data') && ~isempty(nsFile.Analog.Data)
        nsFile.FileInfo.Datatypespresent(2)=1;
    end

    % generate some report
    disp(['currently available Analog.DataentityIDs : ',num2str(nsFile.Analog.DataentityIDs)]);

catch
    rethrow(lasterror);
end