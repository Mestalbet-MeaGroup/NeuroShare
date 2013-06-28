function DataFile = dotparameters(varargin)
% DOTPARAMETERS Application M-file for dotparameters.fig
%    FIG = DOTPARAMETERS launch dotparameters GUI.
%    DOTPARAMETERS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 18-Nov-2005 15:23:27

if isequal(varargin{1},'init') % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	
    handles = guihandles(fig);
        
    % Store Parameters in handles structure
    
    DataFile = varargin{2};
    
    handles.mode           = DataFile.DotDisplay.TrialDisplayMode;       
    handles.interactive    = DataFile.DotDisplay.Interactive;
    handles.dotmarker      = DataFile.DotDisplay.DotMarker;
    handles.dotcolor       = DataFile.DotDisplay.DotColor;
    handles.dotheight      = DataFile.DotDisplay.DotHeightPercentage;
    handles.rawmarker      = DataFile.DotDisplay.Raw.Marker;
    handles.rawcolor       = DataFile.DotDisplay.Raw.Color;
    handles.rawheight      = DataFile.DotDisplay.Raw.MarkerHeightPercentage;
    handles.uemarker       = DataFile.DotDisplay.UE.Marker;
    handles.uecolor        = DataFile.DotDisplay.UE.Color;
    handles.ueheight       = DataFile.DotDisplay.UE.MarkerHeightPercentage;
    handles.behaviormarker = DataFile.DotDisplay.Behavior.Marker;
    handles.behaviorcolor  = DataFile.DotDisplay.Behavior.Color;
    handles.behaviorheight = DataFile.DotDisplay.Behavior.MarkerHeightPercentage;

    % in case of cancel, return original parameters
    handles.cancel = 'on';
    handles.originaldata = DataFile;
    
    guidata(fig, handles);
    
    % Set parameters and convert to right format for gui 
    
    % popups
    
    set(handles.mode_popupmenu,'string',char('from top','from bottom'));
    switch handles.mode
     case 'from_top'
         set(handles.mode_popupmenu,'value',1);
     case 'from_bottom'
         set(handles.mode_popupmenu,'value',2);
    end
    
    set(handles.interactive_popupmenu,'string',char('off','on'));
    switch handles.interactive
     case 'off'
         set(handles.interactive_popupmenu,'value',1);
     case 'on'
         set(handles.interactive_popupmenu,'value',2);
    end
    
    % dot parameters
    
    set(handles.dotmarker_edit,'string',handles.dotmarker);
    handles.dotcolor = num2str(handles.dotcolor);
    set(handles.dotcolor_edit,'string',handles.dotcolor);
    handles.dotheight = num2str(handles.dotheight);
    set(handles.dotheight_edit,'string',handles.dotheight);
    
    % raw parameters
    
    set(handles.rawmarker_edit,'string',handles.rawmarker);
    handles.rawcolor = num2str(handles.rawcolor);
    set(handles.rawcolor_edit,'string',handles.rawcolor);
    handles.rawheight = num2str(handles.rawheight);
    set(handles.rawheight_edit,'string',handles.rawheight);
    
    % ue parameters
    
    set(handles.uemarker_edit,'string',handles.uemarker);
    handles.uecolor = num2str(handles.uecolor);
    set(handles.uecolor_edit,'string',handles.uecolor);
    handles.ueheight = num2str(handles.ueheight);
    set(handles.ueheight_edit,'string',handles.ueheight);
    
    % behavior parameters
    
    set(handles.behaviormarker_edit,'string',handles.behaviormarker);
    handles.behaviorcolor = num2str(handles.behaviorcolor);
    set(handles.behaviorcolor_edit,'string',handles.behaviorcolor);
    handles.behaviorheight = num2str(handles.behaviorheight);
    set(handles.behaviorheight_edit,'string',handles.behaviorheight);
    
    information(['You can enter new marker types, colors in RGB format and height of the ' ...
                 'markers in the edit fields. RGB format: numeric values between 0 and 1, ' ...
                 'seperated by spaces. (example: red=1 0 0, green=0 1 0). ' ...
                 'The height parameters are relative to the plot size. '],'b'); 
    drawnow;

    
    % Wait for callbacks to run and window to be dismissed:
    uiwait(fig);
    
    handles = guidata(fig);
    
    switch handles.cancel
     case 'off'
        DataFile.DotDisplay.TrialDisplayMode = handles.mode;       
        DataFile.DotDisplay.Interactive      = handles.interactive;
        DataFile.DotDisplay.DotMarker           = handles.dotmarker;
        DataFile.DotDisplay.DotColor            = handles.dotcolor;
        DataFile.DotDisplay.DotHeightPercentage = handles.dotheight;
        DataFile.DotDisplay.Raw.Marker                 = handles.rawmarker;
        DataFile.DotDisplay.Raw.Color                  = handles.rawcolor;
        DataFile.DotDisplay.Raw.MarkerHeightPercentage = handles.rawheight;
        DataFile.DotDisplay.UE.Marker                  = handles.uemarker;
        DataFile.DotDisplay.UE.Color                   = handles.uecolor;
        DataFile.DotDisplay.UE.MarkerHeightPercentage  = handles.ueheight;
        DataFile.DotDisplay.Behavior.Marker                = handles.behaviormarker;
        DataFile.DotDisplay.Behavior.Color                  = handles.behaviorcolor;
        DataFile.DotDisplay.Behavior.MarkerHeightPercentage = handles.behaviorheight;

        information('Saved changes made in Dot Display Parameters menu.','b');
        drawnow;
     case 'on'
        DataFile = handles.originaldata;
        
        information('No changes applied in Dot Display Parameters menu.','b');
        drawnow;
    end
    
    delete(fig);
    
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.
% --------------------------------------------------------------------
function varargout = cancel_pushbutton_Callback(h, eventdata, handles, varargin)
 
 handles.cancel ='on';
 guidata(h, handles);
 
 uiresume(handles.figure1);

% --------------------------------------------------------------------
function varargout = apply_pushbutton_Callback(h, eventdata, handles, varargin)

 selection = get(handles.mode_popupmenu,'value');
 switch selection
  case 1
      handles.mode = 'from_top';
  case 2
      handles.mode = 'from_bottom';
 end
 
 selection = get(handles.interactive_popupmenu,'value');
 switch selection
  case 1
      handles.interactive = 'off';
  case 2
      handles.interactive = 'on';
 end  
 
  % dot parameters
    
  handles.dotmarker = get(handles.dotmarker_edit,'string');
  handles.dotcolor  = str2num(get(handles.dotcolor_edit,'string'));
  handles.dotheight = str2num(get(handles.dotheight_edit,'string'));
    
  % raw parameters
    
  handles.rawmarker = get(handles.rawmarker_edit,'string');
  handles.rawcolor  = str2num(get(handles.rawcolor_edit,'string'));
  handles.rawheight = str2num(get(handles.rawheight_edit,'string'));
    
  % ue parameters
    
  handles.uemarker  = get(handles.uemarker_edit,'string');
  handles.uecolor   = str2num(get(handles.uecolor_edit,'string'));
  handles.ueheight  = str2num(get(handles.ueheight_edit,'string'));
    
  % behavior parameters
    
  handles.behaviormarker = get(handles.behaviormarker_edit,'string');
  handles.behaviorcolor  = str2num(get(handles.behaviorcolor_edit,'string'));
  handles.behaviorheight = str2num(get(handles.behaviorheight_edit,'string'));
 
  handles.cancel = 'off';
 
  guidata(h, handles);
  uiresume(handles.figure1);
 
% --------------------------------------------------------------------
function varargout = dotmarker_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = dotcolor_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = dotheight_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = rawmarker_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = rawcolor_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = rawheight_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = uemarker_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = uecolor_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = ueheight_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = behaviormarker_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = behaviorcolor_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = behaviorheight_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = mode_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = interactive_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
