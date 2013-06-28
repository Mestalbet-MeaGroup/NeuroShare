function postMessage(message)
% Post messages to messageBars, etc.
% If figure whose current callback is executing has messageBar, print small 
% error message there; otherwise, print to main window messageBar.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

[h,fig]=gcbo;
messageBar=findobj(get(fig,'Children'),'-regexp','Tag','(?i)messageBarText$');
if isempty(messageBar)
    mainWindow=findobj('Tag','FIND_GUI');
    messageBar=findobj(get(mainWindow,'Children'),'Tag','messageBar'); 
end
set(messageBar,'String',message);
set(messageBar,'TooltipString',message);

drawnow expose; %otherwise message might not be displayed immediately, e.g.
%when FIND is busy with calculations.
