function out=calledfromgui()
% calledfromgui provides information if the GUI is called from the 
% commandline or called from a gui
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


mygcbo=get(gcbo);
if ~isempty(gcbo)
    out=1;
else
    out=0;
end