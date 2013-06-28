function EntitiesToShow=applyEntityQuery(nsFile,varargin)
% Filter entities according to settings specified in queryEntities_GUI
% This function is called by browseEntities_GUI but can also be used 
% manually (not implemented yet).
% function EntitiesToShow=applyEntityQuery(nsFile,varargin)
%
% %%%%% Obligatory parameters %%%%%
% nsFile : <NUMERIC: DOUBLE> variable with defined structure, previously 
%          created by user
% EntitiesToShow : <ARRAY> it creates a new variable for the result's 
%                  storage. 
% TempResults : <ARRAY> it stores the value that comes from applying find
%               funtion each time.
% CountVar : <NUMERIC: DOUBLE> variable to inizializate the loop, acts as 
%            a counter.
% 
% tempswitch : <STRING> it starts the case loop which decides about the filter
%              that will be used.
%
% %%%%% Optional parameters %%%%%
% represented in the function as varargin :
% 'filterSpecs' : <STRING>
% {...} : <CELL of ARRAY> the cell array of strings can contain
%         a maximum of three of the following filter specifications:
% 
%               'all' - all entities
%               'event' - all event entities 
%               'analog' - all analog entities
%               'segment' - all segemnt entities
%               'neural' - all neural entities
%               'even' - all entities with an even entityID
%               'selected' - all entities that are selected 
%                           (selection box checked) in browseEntitiesGUI.
%               'list' - all entities that are specified as a parameter 
%                        value pair in the
%
%  'IDlist' : <STRING>
%
% Example of Use
% applyEntityQuery(nsFile,'filterSpecs',{...},'IDlist',[...]);
%
% Further information:
% Putting 'INV' in front of any of these inverts the selection
% for example {'INV','even'} would give all entities with odd entityIDs.
%
% the filter specifications can be connected by List1 'AND' List2  
%          Lists are joined
%          List1 'EXCLUDE' List2 
%          List2 ist subtracted from List1
%
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


%get FIND_GUIdata which contain filtersettings
if ~isempty(varargin)
    pvpmod(varargin)
else
    FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
end

%initialize variables
EntitiesToShow=[];
TempResults=[];
CountVar=1;

%cycle through filterSpecs, get EntityIDs for each selected property. IDs are stored in TempResults.
for ii=1:length(FIND_GUIdata.filterSpecs)
    tempswitch=char(cell2mat(FIND_GUIdata.filterSpecs{ii}));
    switch tempswitch
        case 'all'
            TempResults{CountVar}=find(cell2mat({nsFile.EntityInfo.EntityType}));
            CountVar=CountVar+1;
        case 'event'
            TempResults{CountVar}=find(cell2mat({nsFile.EntityInfo.EntityType})==1);
            CountVar=CountVar+1;
        case 'analog'
            TempResults{CountVar}=find(cell2mat({nsFile.EntityInfo.EntityType})==2);
            CountVar=CountVar+1;
        case 'segment'
            TempResults{CountVar}=find(cell2mat({nsFile.EntityInfo.EntityType})==3);
            CountVar=CountVar+1;
        case 'neural'
            TempResults{CountVar}=find(cell2mat({nsFile.EntityInfo.EntityType})==4);
            CountVar=CountVar+1;
        case 'even'
            TempResults{CountVar}=find(mod(cell2mat({nsFile.EntityInfo.EntityID}),2)==0);
            CountVar=CountVar+1;
        case 'selected'
            FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
            TempResults{CountVar}=intersect(find(FIND_GUIdata.IDselected),find(cell2mat({nsFile.EntityInfo.EntityType})));
            CountVar=CountVar+1;
        case 'list'
            %not tested! this is just a draft.
            TempResults{CountVar}=IDlist;
            CountVar=CountVar+1;
    end
end

% perform inversion operation
EntitiesToShow=TempResults{1};
CountVar=1;
for ii=1:length(FIND_GUIdata.filterSpecs)
    tempswitch=char(cell2mat(FIND_GUIdata.filterSpecs{ii}));
    switch tempswitch
        case 'AND'
            CountVar=CountVar+1;
        case 'EXCLUDE'
            CountVar=CountVar+1;
        case 'INV'
            Temp=find(cell2mat({nsFile.EntityInfo.EntityType}));
            TempResults{CountVar}=setdiff(Temp,TempResults{CountVar});
    end
end

% combine or subtract entries in TempResults
EntitiesToShow=TempResults{1};
CountVar=1;
for ii=1:length(FIND_GUIdata.filterSpecs)
    tempswitch=char(cell2mat(FIND_GUIdata.filterSpecs{ii}));
    switch tempswitch
        case 'AND'
            EntitiesToShow=union(EntitiesToShow,TempResults{CountVar+1});
            CountVar=CountVar+1;
        case 'EXCLUDE'
            EntitiesToShow=setdiff(EntitiesToShow,TempResults{CountVar+1});
            CountVar=CountVar+1;
    end
end
