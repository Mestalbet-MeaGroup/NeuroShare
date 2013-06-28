function DataFile = uemwaparameters(varargin)
% UEMWAPARAMETERS Application M-file for uemwaparameters.fig
%    FIG = UEMWAPARAMETERS launch uemwaparameters GUI.
%    UEMWAPARAMETERS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 18-Nov-2005 16:02:21

if isequal(varargin{1},'init') % LAUNCH GUI

    fig = openfig(mfilename,'reuse');

    % Use system color scheme for figure:
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));

    % Generate a structure of handles to pass to callbacks, and store it.

    handles = guihandles(fig);

    % Store Parameters in handles structure

    DataFile = varargin{2};

    [pathname, handles.fname] = SplitFileName(DataFile.FileName);

    handles.display      = DataFile.UEMWAFigure.Display;
    handles.filedevice   = DataFile.UEMWAFigure.FileDevice;
    handles.printdevice  = DataFile.UEMWAFigure.PrintDevice;
    handles.allevents    = DataFile.EventList;
    handles.events       = DataFile.UEMWAFigure.EventsToPlot;
    handles.fontsize     = DataFile.UEMWAFigure.TextFontSize;
    handles.position     = DataFile.UEMWAFigure.VerticalLinePosInMS;
    handles.style        = DataFile.UEMWAFigure.VerticalLineStyle;
    handles.widthcell    = DataFile.UEMWAFigure.VerticalLineWidth;
    handles.linetext     = DataFile.UEMWAFigure.VerticalLineText;
    handles.cutevent     = DataFile.CutEvent;
    handles.dataoutpath  = DataFile.OutPath;
    handles.filename     = [DataFile.OutPath handles.fname 'UEFigure'];
    handles.text         = [handles.fname ', cut event: ' int2str(handles.cutevent)];

    % in case of cancel, return original parameters
    handles.cancel = 'on';
    handles.originaldata = DataFile;

    guidata(fig, handles);

    % Set parameters and convert to right format for gui

    % display, filedevice, printdevice
    set(handles.display_popupmenu,'string',char('screen','off'));
    switch handles.display
        case 'screen'
            set(handles.display_popupmenu,'value',1);
        case 'off'
            set(handles.display_popupmenu,'value',2);
    end

    set(handles.filedevice_popupmenu,'string',char('eps','ps','off'));
    switch handles.filedevice
        case 'eps'
            set(handles.filedevice_popupmenu,'value',1);
        case 'ps'
            set(handles.filedevice_popupmenu,'value',2);
        case 'off'
            set(handles.filedevice_popupmenu,'value',3);
    end

    set(handles.printdevice_popupmenu,'string',char('off','on'));
    switch handles.printdevice
        case 'off'
            set(handles.printdevice_popupmenu,'value',1);
        case 'on'
            set(handles.printdevice_popupmenu,'value',2);
    end

    % text
    set(handles.text_edit,'string',handles.text);

    % filename
    set(handles.filename_edit,'string',handles.filename);

    % fontsize
    handles.fontsize = num2str(handles.fontsize);
    set(handles.fontsize_edit,'string',handles.fontsize);

    % eventlist
    if isempty(handles.events)
        handles.events = handles.allevents;
    end
    handles.events = num2str(handles.events');
    set(handles.event_listbox,'string',handles.events);

    % vertical lines position
    handles.position = num2str(handles.position');
    if isempty(handles.position)
        set(handles.position_edit,'enable','off');
    else
        set(handles.position_edit,'enable','on');
    end
    set(handles.position_listbox,'string',handles.position);

    % vertical lines style
    if ~isempty(handles.style)
        handles.style = char(handles.style);
    end
    if isempty(handles.style)
        set(handles.style_edit,'enable','off');
    else
        set(handles.style_edit,'enable','on');
    end
    set(handles.style_listbox,'string',handles.style);

    % vertical lines width
    if ~isempty(handles.widthcell)
        for i = 1:length(handles.widthcell)
            handles.width(i) = handles.widthcell{i};
        end
    else
        handles.width = handles.widthcell;
    end
    handles.width = num2str(handles.width');
    if isempty(handles.width)
        set(handles.width_edit,'enable','off');
    else
        set(handles.width_edit,'enable','on');
    end
    set(handles.width_listbox,'string',handles.width);

    % vertical lines text
    if ~isempty(handles.linetext)
        handles.linetext = char(handles.linetext);
    end
    if isempty(handles.linetext)
        set(handles.linetext_edit,'enable','off');
    else
        set(handles.linetext_edit,'enable','on');
    end
    set(handles.linetext_listbox,'string',handles.linetext);


    % Wait for callbacks to run and window to be dismissed:
    uiwait(fig);

    handles = guidata(fig);

    switch handles.cancel
        case 'off'
            DataFile.UEMWAFigure.Display = handles.display;
            DataFile.UEMWAFigure.FileDevice = handles.filedevice;
            DataFile.UEMWAFigure.PrintDevice = handles.printdevice;
            DataFile.UEMWAFigure.Text = handles.text;
            DataFile.UEMWAFigure.TextFontSize = handles.fontsize;
            DataFile.UEMWAFigure.FileName = handles.filename;
            DataFile.UEMWAFigure.EventsToPlot = handles.events;
            DataFile.UEMWAFigure.VerticalLinePosInMS = handles.position;
            DataFile.UEMWAFigure.VerticalLineStyle = handles.style;
            DataFile.UEMWAFigure.VerticalLineWidth = handles.width;
            DataFile.UEMWAFigure.VerticalLineText = handles.linetext;

            information('Saved changes made in UEMWA Figure Parameters menu.','b');
            drawnow;
        case 'on'
            DataFile = handles.originaldata;
            information('No changes applied in UEMWA Figure Parameters menu.','b');
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function varargout = event_listbox_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = display_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = filedevice_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = printdevice_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = text_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = filename_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = fontsize_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function varargout = position_listbox_Callback(h, eventdata, handles, varargin)

% syncronize shiftevent and shiftwidth listbox
pos = get(handles.position_listbox,'value');
set(handles.style_listbox,'value',pos);
set(handles.width_listbox,'value',pos);
set(handles.linetext_listbox,'value',pos);

positionstring = cellstr(get(handles.position_listbox,'string'));
selected_position = positionstring{pos};
set(handles.position_edit,'string',selected_position);

stylestring = cellstr(get(handles.style_listbox,'string'));
selected_position = stylestring{pos};
set(handles.style_edit,'string',selected_position);

widthstring = cellstr(get(handles.width_listbox,'string'));
selected_position = widthstring{pos};
set(handles.width_edit,'string',selected_position);

linetextstring = cellstr(get(handles.linetext_listbox,'string'));
selected_position = linetextstring{pos};
set(handles.linetext_edit,'string',selected_position);

information('You can change all values in the edit fields.','b');
drawnow;

% --------------------------------------------------------------------
function varargout = style_listbox_Callback(h, eventdata, handles, varargin)

pos = get(handles.style_listbox,'value');
set(handles.position_listbox,'value',pos);
set(handles.width_listbox,'value',pos);
set(handles.linetext_listbox,'value',pos);

positionstring = cellstr(get(handles.position_listbox,'string'));
selected_position = positionstring{pos};
set(handles.position_edit,'string',selected_position);

stylestring = cellstr(get(handles.style_listbox,'string'));
selected_position = stylestring{pos};
set(handles.style_edit,'string',selected_position);

widthstring = cellstr(get(handles.width_listbox,'string'));
selected_position = widthstring{pos};
set(handles.width_edit,'string',selected_position);

linetextstring = cellstr(get(handles.linetext_listbox,'string'));
selected_position = linetextstring{pos};
set(handles.linetext_edit,'string',selected_position);

information('You can change all values in the edit fields.','b');
drawnow;

% --------------------------------------------------------------------
function varargout = width_listbox_Callback(h, eventdata, handles, varargin)

pos = get(handles.width_listbox,'value');
set(handles.style_listbox,'value',pos);
set(handles.position_listbox,'value',pos);
set(handles.linetext_listbox,'value',pos);

positionstring = cellstr(get(handles.position_listbox,'string'));
selected_position = positionstring{pos};
set(handles.position_edit,'string',selected_position);

stylestring = cellstr(get(handles.style_listbox,'string'));
selected_position = stylestring{pos};
set(handles.style_edit,'string',selected_position);

widthstring = cellstr(get(handles.width_listbox,'string'));
selected_position = widthstring{pos};
set(handles.width_edit,'string',selected_position);

linetextstring = cellstr(get(handles.linetext_listbox,'string'));
selected_position = linetextstring{pos};
set(handles.linetext_edit,'string',selected_position);

information('You can change all values in the edit fields.','b');
drawnow;

% --------------------------------------------------------------------
function varargout = linetext_listbox_Callback(h, eventdata, handles, varargin)

pos = get(handles.linetext_listbox,'value');
set(handles.style_listbox,'value',pos);
set(handles.width_listbox,'value',pos);
set(handles.position_listbox,'value',pos);

positionstring = cellstr(get(handles.position_listbox,'string'));
selected_position = positionstring{pos};
set(handles.position_edit,'string',selected_position);

stylestring = cellstr(get(handles.style_listbox,'string'));
selected_position = stylestring{pos};
set(handles.style_edit,'string',selected_position);

widthstring = cellstr(get(handles.width_listbox,'string'));
selected_position = widthstring{pos};
set(handles.width_edit,'string',selected_position);

linetextstring = cellstr(get(handles.linetext_listbox,'string'));
selected_position = linetextstring{pos};
set(handles.linetext_edit,'string',selected_position);

information('You can change all values in the edit fields.','b');
drawnow;

% --------------------------------------------------------------------
function varargout = position_edit_Callback(h, eventdata, handles, varargin)

% get new string
newstring = get(handles.position_edit,'string');
if ~isempty(newstring)
    % get listbox content
    pos = get(handles.position_listbox,'value');
    positionstring = cellstr(get(handles.position_listbox,'string'));
    % change strings
    positionstring{pos} = newstring;
    % convert to num array via char
    positionarray = str2num(char(positionstring));
    % add index to positionarray
    for i = 1:length(positionarray);
        positionarray(i,2) = i;
    end
    newarray = (sortrows(positionarray,1));
    positionstring = newarray(:,1)';
    indexlist      = newarray(:,2)';

    % convert back to char and store new listbox content

    set(handles.position_listbox,'string',num2str(positionstring'));

    pos = get(handles.style_listbox,'value');
    stylestring = cellstr(get(handles.style_listbox,'string'));
    for i=1:length(indexlist)
        newstylestring{i} = stylestring{indexlist(i)};
    end
    set(handles.style_listbox,'string',char(newstylestring));

    pos = get(handles.width_listbox,'value');
    widthstring = cellstr(get(handles.width_listbox,'string'));
    for i=1:length(indexlist)
        newwidthstring{i} = widthstring{indexlist(i)};
    end
    set(handles.width_listbox,'string',char(newwidthstring));

    pos = get(handles.linetext_listbox,'value');
    linetextstring = cellstr(get(handles.linetext_listbox,'string'));
    for i=1:length(indexlist)
        newlinetextstring{i} = linetextstring{indexlist(i)};
    end
    set(handles.linetext_listbox,'string',char(newlinetextstring));
end

% --------------------------------------------------------------------
function varargout = style_edit_Callback(h, eventdata, handles, varargin)

% get new string
newstring = get(handles.style_edit,'string');
% get listbox content
pos = get(handles.style_listbox,'value');
stylestring = cellstr(get(handles.style_listbox,'string'));
% change strings
stylestring{pos} = newstring;
% convert back to char and store new listbox content
set(handles.style_listbox,'string',char(stylestring));

% --------------------------------------------------------------------
function varargout = width_edit_Callback(h, eventdata, handles, varargin)

% get new string
newstring = get(handles.width_edit,'string');
% get listbox content
pos = get(handles.width_listbox,'value');
widthstring = cellstr(get(handles.width_listbox,'string'));
% change strings
widthstring{pos} = newstring;
% convert back to char and store new listbox content
set(handles.width_listbox,'string',char(widthstring));

% --------------------------------------------------------------------
function varargout = linetext_edit_Callback(h, eventdata, handles, varargin)

% get new string
newstring = get(handles.linetext_edit,'string');
% get listbox content
pos = get(handles.linetext_listbox,'value');
linetextstring = cellstr(get(handles.linetext_listbox,'string'));
% change strings
linetextstring{pos} = newstring;
% convert back to char and store new listbox content
set(handles.linetext_listbox,'string',char(linetextstring));

% --------------------------------------------------------------------
function varargout = removeevent_pushbutton_Callback(h, eventdata, handles, varargin)

% get eventnumber form eventlist and convert to cell
pos = get(handles.event_listbox,'value');
eventlist = cellstr(get(handles.event_listbox,'string'));
information(['Removed event ' eventlist{pos}  ...
    '  from "List of Events to Plot".'],'b');
eventlist(pos)=[];
% convert eventlist back to char
eventlist=char(eventlist);
set(handles.event_listbox,'string',eventlist);
% check, if there are events left in eventlist, else disactivate removebutton
if isempty(eventlist)
    set(handles.removeevent_pushbutton,'enable','off');
else
    set(handles.event_listbox,'value',1);
end

% --------------------------------------------------------------------
function varargout = addposition_pushbutton_Callback(h, eventdata, handles, varargin)

% get current strings
positionstring = get(handles.position_listbox,'string');
stylestring    = get(handles.style_listbox,'string');
widthstring    = get(handles.width_listbox,'string');
linetextstring = get(handles.linetext_listbox,'string');

% add new position
if isempty(positionstring)

    positionstring = '0';
    stylestring    = '-';
    widthstring    = '0.75';
    linetextstring = '-';

    set(handles.position_edit,'enable','on');
    set(handles.style_edit,'enable','on');
    set(handles.width_edit,'enable','on');
    set(handles.linetext_edit,'enable','on');
    set(handles.removeposition_pushbutton,'enable','on');
else
    positionstring = char(positionstring, '0');
    stylestring    = char(stylestring,'-');
    widthstring    = char(widthstring,'0.75');
    linetextstring = char(linetextstring,'-');
end

% fill listboxes with new strings
set(handles.position_listbox,'string',positionstring);
set(handles.style_listbox,'string',stylestring);
set(handles.width_listbox,'string',widthstring);
set(handles.linetext_listbox,'string',linetextstring);

information(['Added new default line to "Vertical Lines". You must set the desired parameters ' ...
    'for the new line in the edit fields.'],'b');
drawnow;

% --------------------------------------------------------------------
function varargout = removeposition_pushbutton_Callback(h, eventdata, handles, varargin)

% get position and strings and convert to cells
pos = get(handles.position_listbox,'value');
positionlist = cellstr(get(handles.position_listbox,'string'));
stylelist    = cellstr(get(handles.style_listbox,'string'));
widthlist    = cellstr(get(handles.width_listbox,'string'));
linetextlist = cellstr(get(handles.linetext_listbox,'string'));

information(['Removed position ' positionlist{pos}  ...
    '  from "Vertical Lines" list.'],'b');
% remove selected positions
positionlist(pos)=[];
stylelist(pos)=[];
widthlist(pos)=[];
linetextlist(pos)=[];
% convert back to char
positionlist = char(positionlist);
stylelist    = char(stylelist);
widthlist    = char(widthlist);
linetextlist = char(linetextlist);
% fill listboxes with new strings
set(handles.position_listbox,'string',positionlist);
set(handles.style_listbox,'string',stylelist);
set(handles.width_listbox,'string',widthlist);
set(handles.linetext_listbox,'string',linetextlist);
% check, if there are events left in eventlist, else disactivate removebutton
if isempty(positionlist)
    set(handles.removeposition_pushbutton,'enable','off');
    set(handles.position_edit,'enable','off');
    set(handles.style_edit,'enable','off');
    set(handles.width_edit,'enable','off');
    set(handles.linetext_edit,'enable','off');

    set(handles.position_edit,'string','');
    set(handles.style_edit,'string','');
    set(handles.width_edit,'string','');
    set(handles.linetext_edit,'string','');
else
    set(handles.position_listbox,'value',1);
    set(handles.style_listbox,'value',1);
    set(handles.width_listbox,'value',1);
    set(handles.linetext_listbox,'value',1);

    positionstring = cellstr(get(handles.position_listbox,'string'));
    selected_position = positionstring{1};
    set(handles.position_edit,'string',selected_position);

    stylestring = cellstr(get(handles.style_listbox,'string'));
    selected_position = stylestring{1};
    set(handles.style_edit,'string',selected_position);

    widthstring = cellstr(get(handles.width_listbox,'string'));
    selected_position = widthstring{1};
    set(handles.width_edit,'string',selected_position);

    linetextstring = cellstr(get(handles.linetext_listbox,'string'));
    selected_position = linetextstring{1};
    set(handles.linetext_edit,'string',selected_position);
end

% --------------------------------------------------------------------
function varargout = cancel_pushbutton_Callback(h, eventdata, handles, varargin)

handles.cancel ='on';
guidata(h, handles);

uiresume(handles.figure1);

% --------------------------------------------------------------------
function varargout = apply_pushbutton_Callback(h, eventdata, handles, varargin)

selection = get(handles.display_popupmenu,'value');
switch selection
    case 1
        handles.display = 'screen';
    case 2
        handles.display = 'off';
end

selection = get(handles.filedevice_popupmenu,'value');
switch selection
    case 1
        handles.filedevice = 'eps';
    case 2
        handles.filedevice = 'ps';
    case 3
        handles.filedevice = 'off';
end

selection = get(handles.printdevice_popupmenu,'value');
switch selection
    case 1
        handles.printdevice = 'off';
    case 2
        handles.printdevice = 'on';
end

handles.text     = get(handles.text_edit,'string');
handles.filename = get(handles.filename_edit,'string');
handles.fontsize = str2num(get(handles.fontsize_edit,'string'));
handles.events   = (str2num(get(handles.event_listbox,'string')))';
handles.position = (str2num(get(handles.position_listbox,'string')))';

handles.style    = (cellstr(get(handles.style_listbox,'string')))';
if isequal(handles.style,{''})
    handles.style = ''; % convert cell to string
end

handles.linetext = (cellstr(get(handles.linetext_listbox,'string')))';
if isequal(handles.linetext,{''})
    handles.linetext = ''; % convert cell to string
end

handles.width    = (cellstr(get(handles.width_listbox,'string')))';
if isequal(handles.width,{[]})
    handles.width = []; % convert cell to array
else
    for i = 1:length(handles.width)
        handles.width{i} = str2num(handles.width{i});
    end
end

handles.cancel = 'off';

guidata(h, handles);
uiresume(handles.figure1);

% --------------------------------------------------------------------
function varargout = resetlist_pushbutton_Callback(h, eventdata, handles, varargin)

set(handles.event_listbox,'string',handles.allevents);
information('Reset "List of Events to plot" to "List of all selected Events".','b');
drawnow;



% --------------------------------------------------------------------
function varargout = text_pushbutton_Callback(h, eventdata, handles, varargin)

if ~isempty(handles.fname) & ~isempty(handles.cutevent)
    set(handles.text_edit,'string',handles.text);
    information('Applied Default Text.','b');
    drawnow;
else
    information(['Default Settings for Figure Text can only be applied if you ' ...
        'have choosen a valid "Data File" and "Cut Event".'],'r');
    drawnow;
end

% --------------------------------------------------------------------
function varargout = filename_pushbutton_Callback(h, eventdata, handles, varargin)

if ~isempty(handles.fname) & ~isempty(handles.dataoutpath)
    set(handles.filename_edit,'string',handles.filename);
    information('Applied Default File Name.','b');
    drawnow;
else
    information(['Default Settings for Figure File Name can only be applied if ' ...
        'you have choosen a valid "Data File" and "Results File".'],'r');
    drawnow;
end
