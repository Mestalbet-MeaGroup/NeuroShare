function DataFile = datahandling(varargin)
% DATAHANDLING Application M-file for datahandling.fig
%    FIG = DATAHANDLING launch datahandling GUI.
%    DATAHANDLING('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 19-Aug-2002 16:35:18

if isequal(varargin{1},'init') % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	DataFile = varargin{2};
    
    handles.listofallevents = DataFile.ListofallEvents;
    handles.selectmode      = DataFile.SelectMode;
    handles.selectevent     = DataFile.SelectEvent;
    handles.sortmode        = DataFile.SortMode;
    handles.sortevent       = DataFile.SortEvent;
    handles.shiftmode       = DataFile.ShiftMode;
    handles.shiftwidth      = DataFile.ShiftWidth;
    handles.shiftevent      = DataFile.ShiftNeuronList;
    
    % in case of cancel, return original parameters
    handles.cancel = 'on';
    handles.originaldata = DataFile;
   
    guidata(fig, handles);
    
    % Set parameters
    
    % allevents section
    set(handles.allevents_listbox,'string',handles.listofallevents);
    
    % trial selection section
    handles.selectevent = num2str(handles.selectevent');
    set(handles.selectevent_listbox,'string',handles.selectevent);
    set(handles.selectmode_popupmenu,'string',char('none','first', ...
        'last','even','odd','explicit','repeat','random','eliminate'));
    switch handles.selectmode
     case 'none'
         set(handles.selectmode_popupmenu,'value',1);
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 'first'
         set(handles.selectmode_popupmenu,'value',2);
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 'last'
         set(handles.selectmode_popupmenu,'value',3);
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 'even'
         set(handles.selectmode_popupmenu,'value',4);
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 'odd'
         set(handles.selectmode_popupmenu,'value',5);
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 'explicit'
         set(handles.selectmode_popupmenu,'value',6);
         set(handles.selectevent_listbox,'enable','on');
         set(handles.removeselectevent_pushbutton,'enable','on');
         set(handles.addselectevent_pushbutton,'enable','on');
         set(handles.selection_edit,'enable','on');
     case 'repeat'
         set(handles.selectmode_popupmenu,'value',7);
         set(handles.selectevent_listbox,'enable','on');
         set(handles.removeselectevent_pushbutton,'enable','on');
         set(handles.addselectevent_pushbutton,'enable','on');
         set(handles.selection_edit,'enable','on');
     case 'random'
         set(handles.selectmode_popupmenu,'value',8);
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 'eliminate'
         set(handles.selectmode_popupmenu,'value',9);
         set(handles.selectevent_listbox,'enable','on');
         set(handles.removeselectevent_pushbutton,'enable','on');
         set(handles.addselectevent_pushbutton,'enable','on');
         set(handles.selection_edit,'enable','on');
    end
    
    if isempty(handles.selectevent)
        set(handles.removeselectevent_pushbutton,'enable','off');
        set(handles.selection_edit,'enable','off');
    end
  
    % trial sorting section
    if ~isempty(handles.sortevent)
        handles.sortevent1 = num2str(handles.sortevent(1));
        set(handles.sortevent1_edit,'string',handles.sortevent1);
        if length(handles.sortevent)==2  % only in diff mode !!
           handles.sortevent2 = num2str(handles.sortevent(2));
           set(handles.sortevent2_edit,'string',handles.sortevent2);
        end
    end
    
    set(handles.sortmode_popupmenu,'string',char('none','duration','difference','random'));
    switch handles.sortmode
     case 'none'
         set(handles.sortmode_popupmenu,'value',1);
         set(handles.sortevent1_edit,'enable','off');
         set(handles.sortevent2_edit,'enable','off');
     case 'duration'
         set(handles.sortmode_popupmenu,'value',2);
         set(handles.sortevent1_edit,'enable','on');
         set(handles.sortevent2_edit,'enable','off');
     case 'difference'
         set(handles.sortmode_popupmenu,'value',3);
         set(handles.sortevent1_edit,'enable','on');
         set(handles.sortevent2_edit,'enable','on');
     case 'random'
         set(handles.sortmode_popupmenu,'value',4);
         set(handles.sortevent1_edit,'enable','off');
         set(handles.sortevent2_edit,'enable','off');    
    end
    
    % data shifting section
    handles.shiftevent = num2str(handles.shiftevent');
    handles.shiftwidth = num2str(handles.shiftwidth');
    set(handles.shiftevent_listbox,'string',handles.shiftevent);
    set(handles.shiftwidth_listbox,'string',handles.shiftwidth);
    if isempty(handles.shiftevent)
        set(handles.removeshiftevent_pushbutton,'enable','off');
    else
        set(handles.removeshiftevent_pushbutton,'enable','on');
        shiftstring = cellstr(get(handles.shiftwidth_listbox,'string'));	
        selected_shift = shiftstring{1};
        set(handles.shift_edit,'string',selected_shift);
    end
    set(handles.shiftmode_popupmenu,'string',char('none','on'));
    switch handles.shiftmode
     case 'none'
         set(handles.shiftmode_popupmenu,'value',1);
     case 'on'
         set(handles.shiftmode_popupmenu,'value',2);
    end
    set(handles.shiftwidth_listbox,'string',handles.shiftwidth);
    
    
    % Wait for callbacks to run and window to be dismissed:
    uiwait(fig);
    
    handles = guidata(fig);
    
    switch handles.cancel
      case 'off'
        DataFile.SelectMode = handles.selectmode;
        DataFile.SelectEvent = handles.selectevent;
        DataFile.SortMode = handles.sortmode;
        DataFile.SortEvent = handles.sortevent;
        DataFile.ShiftMode = handles.shiftmode;
        DataFile.ShiftWidth = handles.shiftwidth;
        DataFile.ShiftNeuronList = handles.shiftevent;
        
        information('Saved changes made in Data Handling menu.','b');
        drawnow;
      case 'on'
        DataFile = handles.originaldata;
        
        information('No changes applied in Data Handling menu.','b');
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
function varargout = selectmode_popupmenu_Callback(h, eventdata, handles, varargin)

 selection = get(handles.selectmode_popupmenu,'value');
 switch selection
     case 1
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 2
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 3
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 4
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 5
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 6
         set(handles.selectevent_listbox,'enable','on');
         set(handles.removeselectevent_pushbutton,'enable','on');
         set(handles.addselectevent_pushbutton,'enable','on');
         set(handles.selection_edit,'enable','on');
     case 7
         set(handles.selectevent_listbox,'enable','on');
         set(handles.removeselectevent_pushbutton,'enable','on');
         set(handles.addselectevent_pushbutton,'enable','on');
         set(handles.selection_edit,'enable','on');
     case 8
         set(handles.selectevent_listbox,'enable','off');
         set(handles.removeselectevent_pushbutton,'enable','off');
         set(handles.addselectevent_pushbutton,'enable','off');
         set(handles.selection_edit,'enable','off');
     case 9
         set(handles.selectevent_listbox,'enable','on');
         set(handles.removeselectevent_pushbutton,'enable','on');
         set(handles.addselectevent_pushbutton,'enable','on');
         set(handles.selection_edit,'enable','on');
    end
    
    selecteventlist = get(handles.selectevent_listbox,'string');
    if isempty(selecteventlist)
        set(handles.removeselectevent_pushbutton,'enable','off');
        set(handles.selection_edit,'enable','off');
    end
    
% --------------------------------------------------------------------
function varargout = sortevent1_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = sortevent2_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = shiftmode_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function varargout = sortmode_popupmenu_Callback(h, eventdata, handles, varargin)

 mode = get(handles.sortmode_popupmenu,'value');
 switch mode
     case 1
         set(handles.sortevent1_edit,'enable','off');
         set(handles.sortevent2_edit,'enable','off');
     case 2
         set(handles.sortevent1_edit,'enable','on');
         set(handles.sortevent2_edit,'enable','off');
         information(['You have to enter the event ID of the Sort Event in the edit ' ...
                      'field "Sort Event 1". '],'b');
         drawnow;
     case 3
         set(handles.sortevent1_edit,'enable','on');
         set(handles.sortevent2_edit,'enable','on');
         information(['You have to enter the event IDs of the Sort Events in the edit ' ...
                      'fields "Sort Event 1" and "Sort Event 2". '],'b');
         drawnow;
     case 4
         set(handles.sortevent1_edit,'enable','off');
         set(handles.sortevent2_edit,'enable','off');    
    end
    
% --------------------------------------------------------------------
function varargout = allevents_listbox_Callback(h, eventdata, handles, varargin)

 information(['You can click on the "Add" button to add the selected ' ...
              'event to the "List of Shift Events".'],'b');
 drawnow;

% --------------------------------------------------------------------
function varargout = shiftevent_listbox_Callback(h, eventdata, handles, varargin)

 % syncronize shiftevent and shiftwidth listbox 
 position = get(handles.shiftevent_listbox,'value');
 set(handles.shiftwidth_listbox,'value',position);
 shiftstring = cellstr(get(handles.shiftwidth_listbox,'string'));	
 selected_shift = shiftstring{position};
 set(handles.shift_edit,'string',selected_shift);
 information('You can change the shift value in the edit field.','b');
 drawnow;

% --------------------------------------------------------------------
function varargout = addselectevent_pushbutton_Callback(h, eventdata, handles, varargin)

   % get eventlist
	eventlist = get(handles.selectevent_listbox,'string');
    if ~isempty(eventlist)
        % add new member
        eventlist = char(eventlist,'0');
    else
        set(handles.selection_edit,'enable','on');
        eventlist = '0';
    end
	
    information(['Added new trial to "List of selected Trials"  '...
                 'with default trial number 0. ' ...
                 'To change the trial ID select it and enter new ID in the edit field. '],'b'); 
    drawnow;
    
    set(handles.selectevent_listbox,'string',eventlist);
    set(handles.removeselectevent_pushbutton,'enable','on');
    
% --------------------------------------------------------------------
function varargout = selectevent_listbox_Callback(h, eventdata, handles, varargin)

 % get listbox content
 pos = get(handles.selectevent_listbox,'value');
 eventstring = cellstr(get(handles.selectevent_listbox,'string'));	
 % get selected string and fill to edit field
 selectstring = eventstring{pos};
 set(handles.selection_edit,'string',selectstring);
 information('You can change the trial ID in the edit field.','b');
 drawnow;

 
% --------------------------------------------------------------------
function varargout = addshiftevent_pushbutton_Callback(h, eventdata, handles, varargin)

    % get eventnumber form eventlist
    index_selected = get(handles.allevents_listbox,'value');
	event_list = cellstr(get(handles.allevents_listbox,'string'));	
	allevents_selected_item = event_list{index_selected};
    oldeventstring = get(handles.shiftevent_listbox,'string');
    oldshiftstring = get(handles.shiftwidth_listbox,'string');
    
    % look, if there is allready at least one event selected 
    if ~isempty(oldeventstring)
      % make sure that no event is selected twice
      if ~ismember(allevents_selected_item,cellstr(oldeventstring))
        eventlist = char(oldeventstring,allevents_selected_item);
        shiftlist = char(oldshiftstring,'0');
        set(handles.shiftevent_listbox,'string',eventlist);
        set(handles.shiftwidth_listbox,'string',shiftlist);
        information(['Added event ' allevents_selected_item  ...
                     '  to "List of Shift Events" and set its shift to 0 by default. ' ...
                     'To change the shift select the event and enter new value in the ' ...
                     ' "Change Shift of selected Event" edit field.'],'b');
        drawnow;   
      else
        information('Each event can only be selected once','r');
        drawnow;
      end
    else % no event selected up to now, select event and initialize remove_button
      set(handles.shiftevent_listbox,'string',allevents_selected_item);
      set(handles.shiftwidth_listbox,'string','0');
      set(handles.shift_edit,'string','0');
      set(handles.removeshiftevent_pushbutton,'enable','on');
      information(['Added event ' allevents_selected_item  ...
                   '  to "List of Shift Events" and set its shift to 0 by default. ' ...
                   'To change the shift select the event and enter new value in the ' ...
                   ' "Change Shift of selected Event" edit field.'],'b');
      drawnow;
    end

% --------------------------------------------------------------------
function varargout = removeselectevent_pushbutton_Callback(h, eventdata, handles, varargin)

    % get eventnumber form eventlist and convert to cell
    index_selected = get(handles.selectevent_listbox,'value');
	eventlist = cellstr(get(handles.selectevent_listbox,'string'));
	information(['Removed trial ' eventlist{index_selected}  ...
                         '  from "List of selected Trials".'],'b');
    eventlist(index_selected)=[];
    % convert eventlist back to char
    eventlist=char(eventlist);
    set(handles.selectevent_listbox,'string',eventlist);
    % check, if there are events left in eventlist, else disactivate removebutton
    if isempty(eventlist)
      set(handles.removeselectevent_pushbutton,'enable','off');
      set(handles.selection_edit,'enable','off');
    else
      set(handles.selectevent_listbox,'value',1);
    end

% --------------------------------------------------------------------
function varargout = removeshiftevent_pushbutton_Callback(h, eventdata, handles, varargin)

    % get eventnumber form eventlist and convert to cell (same for shiftlist)
    index_selected = get(handles.shiftevent_listbox,'value');
	eventlist = cellstr(get(handles.shiftevent_listbox,'string'));
    shiftlist = cellstr(get(handles.shiftwidth_listbox,'string'));
	information(['Removed event ' eventlist{index_selected}  ...
                         '  from "List of Shift Events".'],'b');
    eventlist(index_selected)=[];
    shiftlist(index_selected)=[];
    % convert eventlist (shiftlist) back to char
    eventlist=char(eventlist);
    shiftlist=char(shiftlist);
    set(handles.shiftevent_listbox,'string',eventlist);
    set(handles.shiftwidth_listbox,'string',shiftlist);
    % check, if there are events left in eventlist, else disactivate removebutton
    if isempty(eventlist)
      set(handles.removeshiftevent_pushbutton,'enable','off');
      set(handles.shift_edit,'string','');
    else
      set(handles.shiftevent_listbox,'value',1);
      set(handles.shiftwidth_listbox,'value',1);
      shiftstring = cellstr(get(handles.shiftwidth_listbox,'string'));	
      selected_shift = shiftstring{1};
      set(handles.shift_edit,'string',selected_shift);
    end

% --------------------------------------------------------------------
function varargout = shiftwidth_listbox_Callback(h, eventdata, handles, varargin)

 % syncronize shiftevent and shiftwidth listbox 
 position = get(handles.shiftwidth_listbox,'value');
 set(handles.shiftevent_listbox,'value',position);
 shiftstring = cellstr(get(handles.shiftwidth_listbox,'string'));	
 selected_shift = shiftstring{position};
 set(handles.shift_edit,'string',selected_shift);
 information('You can change the shift value in the edit field.','b');
 drawnow;
 
% --------------------------------------------------------------------
function varargout = shift_edit_Callback(h, eventdata, handles, varargin)

 newstring = get(handles.shift_edit,'string');
 position = get(handles.shiftwidth_listbox,'value');
 shiftstring = cellstr(get(handles.shiftwidth_listbox,'string'));	
 selected_shift = shiftstring{position};
 shiftstring{position} = newstring;
 shiftstring = char(shiftstring);
 set(handles.shiftwidth_listbox,'string',shiftstring);
 information('Changed shift width','b');
 drawnow;

% --------------------------------------------------------------------
function varargout = apply_pushbutton_Callback(h, eventdata, handles, varargin)
    
 selection = get(handles.selectmode_popupmenu,'value');
 switch selection
  case 1
      handles.selectmode = 'none';
  case 2
      handles.selectmode = 'first';
  case 3
      handles.selectmode = 'last';
  case 4
      handles.selectmode = 'even';
  case 5
      handles.selectmode = 'odd';
  case 6
      handles.selectmode = 'explicit';
  case 7
      handles.selectmode = 'repeat';
  case 8
      handles.selectmode = 'random';
  case 9
      handles.selectmode = 'eliminate';
 end
 handles.selectevent = str2num(get(handles.selectevent_listbox,'string'))';
    
 selection = get(handles.sortmode_popupmenu,'value');
 switch selection
  case 1
      handles.sortmode = 'none';
  case 2
      handles.sortmode = 'duration';
  case 3
      handles.sortmode = 'diff';
  case 4
      handles.sortmode = 'random';
 end
 
 sortevent1 = str2num(get(handles.sortevent1_edit,'string'));
 sortevent2 = str2num(get(handles.sortevent2_edit,'string'));
 if ~isempty(sortevent1)
     if ~isempty(sortevent2)
        handles.sortevent = [sortevent1 sortevent2];
     else
        handles.sortevent = sortevent1;
     end    
 else
     handles.sortevent = [];
 end
    
 selection = get(handles.shiftmode_popupmenu,'value');
 switch selection
  case 1
      handles.shiftmode = 'none';
  case 2
      handles.shiftmode = 'on';
 end
    
 handles.shiftwidth = str2num(get(handles.shiftwidth_listbox,'string'))';
 handles.shiftevent = str2num(get(handles.shiftevent_listbox,'string'))';  

 handles.cancel = 'off';
 
 guidata(h, handles);
 uiresume(handles.figure1);

% --------------------------------------------------------------------
function varargout = cancel_pushbutton_Callback(h, eventdata, handles, varargin)
 
 uiresume(handles.figure1);
  
% --------------------------------------------------------------------
function varargout = selection_edit_Callback(h, eventdata, handles, varargin)

 newstring = get(handles.selection_edit,'string');
 % get listbox content
 pos = get(handles.selectevent_listbox,'value');
 eventstring = cellstr(get(handles.selectevent_listbox,'string'));	
 % change strings
 eventstring{pos} = newstring;
 % convert back to char and store new listbox content
 set(handles.selectevent_listbox,'string',char(eventstring));
 information('Changed selected Trial','b');
 drawnow;
