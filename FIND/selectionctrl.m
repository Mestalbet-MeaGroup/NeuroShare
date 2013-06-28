function selectionctrl(command)
% Control function for selecting and deselecting entityIDs from the GUI
%
% Markus Nenniger
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

switch command
    case 'export'
        % saves EntityIDs to a file.
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        [savefilename,savefilepath,filterspec]=uiputfile({'*.mat','Matlab variable'});
        IDselected=FIND_GUIdata.IDselected;
        tempstring=['save ','''',savefilepath,savefilename,'''',' IDselected'];
        eval(tempstring)
    case 'import'
        % Retrieves EntityIDs for selection from a file.
        [loadfilename,loadfilepath,filterspec]=uigetfile({'*.mat','Matlab variable'});
        tempstring=['load ','''',loadfilepath,loadfilename,'''',' IDselected'];
        eval(tempstring)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        FIND_GUIdata.IDselected=IDselected;
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);

        browseEntitiesGUI()
    case 'selectall'
        %Select all entityIDs in the data file.
        %disp('selectall')
        set(findobj(gcf,'style','checkbox'),'Value',1)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        FIND_GUIdata.IDselected=ones(1,length(FIND_GUIdata.IDselected));
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
     case 'unselectall'
         %Deselect all entityIDs
        %disp('unselectall')
        set(findobj(gcf,'style','checkbox'),'Value',0)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        FIND_GUIdata.IDselected=zeros(1,length(FIND_GUIdata.IDselected));
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    case 'selectpage'
        %Select all entityIDs on current page.
        %disp('selectpage')
        set(findobj(gcf,'style','checkbox'),'Value',1)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        % if a cell array contains strings, cell2num doesn't return
        % doubles, but a char array. so this mess is not entirely my
        % fault... i think...
        FIND_GUIdata.IDselected(cellstr2num(get(findobj(gcf,'style','checkbox'),'Tag')))=cell2num(get(findobj(gcf,'style','checkbox'),'Value'));
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    case 'unselectpage'
        %Deselect all entityIDs on current page.
        %disp('unselectpage')
        set(findobj(gcf,'style','checkbox'),'Value',0)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        % if a cell array contains strings, cell2num doesn't return
        % doubles, but a char array. so this mess is not entirely my
        % fault... i think...
        FIND_GUIdata.IDselected(cellstr2num(get(findobj(gcf,'style','checkbox'),'Tag')))=cell2num(get(findobj(gcf,'style','checkbox'),'Value'));
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    case 'invertall'
        %Invert whole entityID selection
        %disp('invertall')
        checkedboxes=findobj(gcf,'style','checkbox','Value',1);
        uncheckedboxes=findobj(gcf,'style','checkbox','Value',0);
        set(checkedboxes,'Value',0)
        set(uncheckedboxes,'Value',1)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        selectedIDs=find(FIND_GUIdata.IDselected==1);
        notselectedIDs=find(FIND_GUIdata.IDselected==0);
        FIND_GUIdata.IDselected(selectedIDs)=0;
        FIND_GUIdata.IDselected(notselectedIDs)=1;
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    case 'invertpage'
        %Invert entityID selection on this page.
        %disp('invertpage')        
        checkedboxes=findobj(gcf,'style','checkbox','Value',1);
        uncheckedboxes=findobj(gcf,'style','checkbox','Value',0);
        set(checkedboxes,'Value',0)
        set(uncheckedboxes,'Value',1)
        FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
        tempIDselected=cell2num(get(findobj(gcf,'style','checkbox'),'Value'));
        FIND_GUIdata.IDselected(cellstr2num(get(findobj(gcf,'style','checkbox'),'Tag')))=tempIDselected(end:-1:1);
        set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
    case 'manual'
        %call function for manual selection of entityIDs
        selectmanual
end
