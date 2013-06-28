function setselectedentityID()
% retrieves selected entityIDs and checks appropriate boxes in GUI
%
% Markus Nenniger 06
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
FIND_GUIdata.IDselected(str2num(get(gcbo,'Tag')))=get(gcbo,'Value');
if get(gcbo,'Value')
    selectedID=str2num(get(gcbo,'Tag'));
end

% % select only one Event Entity
% avaiEvents=find([nsFile.EntityInfo(:).EntityType]==1);
% selectedEvents=avaiEvents(FIND_GUIdata.IDselected(avaiEvents)==1);
% 
% if length(selectedEvents)>1
%     unselectedEvent=setdiff(selectedEvents,selectedID);
%     PosUnselectedEvent=find([nsFile.EntityInfo(:).EntityID]==unselectedEvent);
%     FIND_GUIdata.IDselected(PosUnselectedEvent)=0;
%     set(findobj('Tag',num2str(unselectedEvent)),'Value',0);
% end

set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);
