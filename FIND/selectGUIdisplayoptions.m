function selectGUIdisplayOptions()
%this function is executed, whenever a checkbutton in the options display is clicked
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

% make myguiprops available in current scope
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');

% get window handle
optionsdisplay=findobj('Name','Display Options');

%get handles of all checked boxes
checkedboxes=findobj(optionsdisplay,'Value',1,'Style','Checkbox');
FIND_GUIdata.displayOptions={};
for ii=1:length(checkedboxes)
    FIND_GUIdata.displayOptions{1,ii}=get(checkedboxes(ii),'Tag');
end

set(findobj('Tag','FIND_GUI'),'UserData',FIND_GUIdata);

browseEntitiesGUI();
