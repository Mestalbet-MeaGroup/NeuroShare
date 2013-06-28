function varargout = information(inputtext,color)
% This function is used in UE to inform the user about errors and
% instructions or to provide help for some topics. The information is
% displayed in a small window. The second argument, a single character, is
% used to set the color of the shown text, e.g. red ('r') for errors,
% blue ('b') for advices.

fig = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));

% Generate a structure of handles to pass to callbacks, and store it.
handles = guihandles(fig);
guidata(fig, handles);

set(handles.text,'foregroundcolor',color);
set(handles.text,'string',inputtext);

if nargout > 0
    varargout{1} = fig;
end
