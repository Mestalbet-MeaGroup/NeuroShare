function varargout = errorwindow(inputtext,varargin)
    
	fig = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
    if nargin == 1
     
        set(handles.listbox,'string',inputtext);
    
    end
% --------------------------------------------------------------------
function varargout = listbox_Callback(h, eventdata, handles, varargin)
