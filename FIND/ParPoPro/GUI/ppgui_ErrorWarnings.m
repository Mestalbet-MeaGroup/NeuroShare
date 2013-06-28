function varargout = ppgui_ErrorWarnings(inputtext)
	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    set(handles.text,'string',inputtext);
    %jens=get(handles.text,'string');
    %keyboard
    %clipboard('copy',get(handles.text,'string'));
	if nargout > 0
		varargout{1} = fig;
    end

        
