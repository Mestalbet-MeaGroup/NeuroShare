function browseEntitiesGUI(varargin)
% GUI for browsing and loading data entities from a data file.
% The selection of data entities displayed by browseEntitiesGUI can be filtered and
% selected entities can be loaded.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile;

pvpmod(varargin);

% get EntitiesToShow by calling applyEntityQuery
EntitiesToShow = applyEntityQuery(nsFile);

%get relevant information from main window
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

%check if window is already open
if ishandle(findobj('Name','browseEntitiesGUI'))
    GUIprops=get(findobj('Name','browseEntitiesGUI'),'UserData');
    myguiprops.currentpage=GUIprops.currentpage;
    close(findobj('Name','browseEntitiesGUI'));
end

%if not, set initial values for figure properties
%this should be in a config file!!!
myguiprops.numberofpages=[];
if ~isfield(myguiprops,'currentpage')
    myguiprops.currentpage=1;
end
myguiprops.newfigure=[];
myguiprops.mygui=figure;
myguiprops.entriesperpage=[];
if ~isfield(FIND_GUIdata,'IDselected')
    FIND_GUIdata.IDselected=zeros(1,length(nsFile.EntityInfo));
    set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
end
set(myguiprops.mygui,'Name','browseEntitiesGUI');
makepulldownmenu;


%this controls which page is displayed
if exist('page')
    if isempty(str2num(page))
        switch page
            case 'next'
                myguiprops.currentpage=myguiprops.currentpage+1;
            case 'previous'
                myguiprops.currentpage=myguiprops.currentpage-1;
            otherwise
                warning('not a valid page selection')
        end
    else
        myguiprops.currentpage=str2num(page);
    end
end

%calculate how many pages are needed
myguiprops.numberofpages=ceil(length(EntitiesToShow)/20);

%check if selected page exits
if myguiprops.currentpage <=0
    warning('pages are positive integers')
    myguiprops.currentpage=1;
elseif myguiprops.currentpage > myguiprops.numberofpages
    warning(strcat('there are only ',num2str(myguiprops.numberofpages),' pages'))
    myguiprops.currentpage=myguiprops.numberofpages;
end

if length(EntitiesToShow) > 20 % settings for more than one page
    if myguiprops.currentpage==myguiprops.numberofpages
        myguiprops.pageentries=EntitiesToShow((myguiprops.currentpage-1)*20+1:end);
    else
        myguiprops.pageentries=EntitiesToShow((myguiprops.currentpage-1)*20+1:(myguiprops.currentpage-1)*20+20);
    end
else % settings for one page
    myguiprops.pageentries=EntitiesToShow;
end

%prepare list of GUI entries for supergui
[geometry,listui]=makeSuperGUItable(nsFile, myguiprops.pageentries,myguiprops);

%generates the 'fixed' part of the browseEntitiesGUI window with control elements.
geometry{1,(size(geometry,2))+1}=[4 4 4];
listui{1,size(listui,2)+1}={'style','text','string',''};
listui{1,size(listui,2)+1}={ 'style', 'pushbutton' , 'string', 'load','Callback',@loadselecteddatacallback};
listui{1,size(listui,2)+1}={'style','text','string',''};
% geometry{1,(size(geometry,2))+1}=[1];
% listui{1,size(listui,2)+1}={'style','text','string',''};
geometry{1,(size(geometry,2))+1}=[4 1 1 2 4];
listui{1,size(listui,2)+1}={ 'style', 'pushbutton' , 'string', 'back','Callback','browseEntitiesGUI(''page'',''previous'')'};
listui{1,size(listui,2)+1}={'style','text','string',''};
listui{1,size(listui,2)+1}={ 'style', 'edit' , 'string',myguiprops.currentpage,'Tag','setpageeditbox','Callback','browseEntitiesGUI(''page'',get(findobj(gcf,''Tag'',''setpageeditbox''),''String''))'};
listui{1,size(listui,2)+1}={'style','text','string',strcat('/',num2str(myguiprops.numberofpages))};
listui{1,size(listui,2)+1}={ 'style', 'pushbutton' , 'string', 'forward','Callback','browseEntitiesGUI(''page'',''next'')'};
height=ones(1,size(geometry,2));
height(1,end-1)=1.5;

%writes back settings to userdata
set(myguiprops.mygui,'UserData',myguiprops);

%removes all non-control elements from the browseEntitiesGUI window
currentchildren=get(myguiprops.mygui,'Children');
delete(currentchildren(1:end-6));


%draws the objects created above with supergui (see help supergui for details)
supergui(myguiprops.mygui,geometry,height,listui{:});

%check selection checkboxes for selected entityIDs
if ~isempty(find(FIND_GUIdata.IDselected==1))
    for selectedID=intersect(find(FIND_GUIdata.IDselected==1),myguiprops.pageentries)
        set(findobj(myguiprops.mygui,'Tag',num2str(selectedID)),'Value',1);
    end
end

if any(intersect(setxor(EntitiesToShow,cell2mat({nsFile.EntityInfo.EntityID})),find(FIND_GUIdata.IDselected)));
    warndlg('not all selected enitites are shown, check filter options.','Not all entities visible')
end


function filtersettingspulldowncallback(a,b)

myguiprops=get(findobj('Name','browseEntitiesGUI'),'UserData');

%call filtersettings GUI
queryEntitiesGUI(myguiprops);


function loadselecteddatacallback(a,b)
try
    postMessage('Busy - please wait...');
    %initialize variable for temporary data storage
    newdata=[];
    %get FIND_GUIdata which contain indices of the selected entities
    FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
    selectedidx=find(FIND_GUIdata.IDselected);

    if isempty(selectedidx)
        postMessage('Please select Entities first.'); return;
    end
    % make nsFile available in current scope
    global nsFile;

    %get entitytypes for all selected entities
    for ii=1:length(selectedidx)
        entitytype(ii)=nsFile.EntityInfo(selectedidx(ii)).EntityType;
    end

    %initialize pvpstring, which will contain all arguments for FIND_loader call
    pvpstring={'','','',''};

    % file name from FIND_GUI
    pvpstring{1}='fileName';
    pvpstring{2}=get(findobj('Tag','FIND_GUI_fileInUseText'),'String');

    % dll path stored in the UserData (loaded from init.m)
    FIND_GUIdata = get(findobj('Tag','FIND_GUI'),'UserData');
    DLLpath=FIND_GUIdata.DLLpath;
    pvpstring{3}='DLLpath';
    pvpstring{4}=DLLpath;

    %cycle through all data types
    for ii=1:4
        % write filename to pvpstring

        %store entityIDs for current data type
        tempidx=selectedidx(find(entitytype==ii));
        %if there aren't any, continue to next data type
        if isempty(tempidx);continue;end
        if ii==1 %set pvp string for event data
            pvpstring{end+1}='eventData';
            %store loading parameters for FIND_loader (see FIND_loader for details)
            for jj=1:length(tempidx)
                templength(jj)=nsFile.EntityInfo(tempidx(jj)).ItemCount;
            end
            longestentity=max(templength);
            pvpstring{end+1}=[1 longestentity tempidx];
        elseif ii==2 %set pvp string for analog data
            pvpstring{end+1}='analogData';
            %store loading parameters for FIND_loader (see FIND_loader for details)
            pvpstring{end+1}=[1 nsFile.EntityInfo(tempidx(1)).ItemCount tempidx];
            % SOMEHOW, LOAD THE analog info accordingly
        elseif ii==3 %set pvp string for segmentdata
            pvpstring{end+1}='segmentData';
            pvpstring{end+1}=[1 max([nsFile.EntityInfo(tempidx).ItemCount]) tempidx];
        elseif ii==4 %set pvp string for neural data
            % no neural data type yet
            pvpstring{end+1}='neuralData';
            pvpstring{end+1}=[1 max([nsFile.EntityInfo(tempidx).ItemCount]) tempidx];
        end
    end

    %load data
    if size(pvpstring,2)>4
        FIND_loader(pvpstring{:});
        set(findobj('Tag','FIND_GUI_structureInfoListBox'),'String',structure2text(nsFile));
        postMessage('...done.');
    else
        postMessage('Please select Entities first.')
    end
    pvpstring={''};

catch
    handleError(lasterror);
end
