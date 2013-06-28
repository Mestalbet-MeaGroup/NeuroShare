function DataFile = generaloptions(varargin)
% GeneralOptions = generaloptions('init',DataFile)

% GENERALOPTIONS Application M-file for generaloptions.fig
%    FIG = GENERALOPTIONS launch generaloptions GUI.
%    GENERALOPTIONS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 18-Nov-2005 15:51:46

if isequal(varargin{1},'init')  % LAUNCH GUI

    fig = openfig(mfilename,'reuse');

    % Use system color scheme for figure:
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    DataFile = varargin{2};

    handles.data.compatibility    = DataFile.GeneralOptions.Compatibility;
    handles.data.timedisplaymode  = DataFile.GeneralOptions.TimeDisplayMode;
    handles.data.spikedataformat  = DataFile.GeneralOptions.SpikeDataFormat;
    handles.data.showsplashscreen = DataFile.GeneralOptions.ShowSplashScreen;
    handles.data.nshuffleelements = DataFile.CSR.NShuffleElements;
    handles.data.nmcsteps         = DataFile.CSR.NMCSteps;
    handles.data.gen_case         = DataFile.CSR.gen_case;
    handles.data.trialoverlapmode = DataFile.TrialOverlapMode;
    handles.fontsize              = DataFile.FontSize;

    % in case of cancel, return original parameters
    handles.cancel = 'off';
    handles.originaldata = DataFile;

    guidata(fig, handles);

    % Set parameters

    % Compatibility
    set(handles.compatibility_popupmenu,'string',char('IDLVersion','empty'));

    switch DataFile.GeneralOptions.Compatibility
        case 'IDLVersion'
            set(handles.compatibility_popupmenu,'value',1);
        case ''
            set(handles.compatibility_popupmenu,'value',2);
    end

    % TimeDisplayMode
    set(handles.timedisplaymode_popupmenu,'string',char('real','discrete'));

    switch DataFile.GeneralOptions.TimeDisplayMode
        case 'real'
            set(handles.timedisplaymode_popupmenu,'value',1);
        case 'discrete'
            set(handles.timedisplaymode_popupmenu,'value',2);
    end

    % SpikeDataFormat
    set(handles.spikedataformat_popupmenu,'string',char('gdfcell','workcell'));

    switch DataFile.GeneralOptions.SpikeDataFormat
        case 'gdfcell'
            set(handles.spikedataformat_popupmenu,'value',1);
        case 'workcell'
            set(handles.spikedataformat_popupmenu,'value',2);
    end

    % ShowSplashScreen
    switch DataFile.GeneralOptions.ShowSplashScreen
        case 'on'
            set(handles.showsplashscreen_checkbox,'value',1);
        case 'off'
            set(handles.showsplashscreen_checkbox,'value',0);
    end

    % TrialOverlapMode
    set(handles.trialoverlapmode_popupmenu,'string',char('causal','exclusive','off'));

    switch DataFile.TrialOverlapMode
        case 'causal'
            set(handles.trialoverlapmode_popupmenu,'value',1);
        case 'exclusive'
            set(handles.trialoverlapmode_popupmenu,'value',2);
        case 'off'
            set(handles.trialoverlapmode_popupmenu,'value',3);
    end

    % FontSize
    set(handles.fontsize_edit,'string',num2str(handles.fontsize));

    % CSR parameters

    set(handles.nshuffleelements_edit,'string',num2str(handles.data.nshuffleelements));
    set(handles.nmcsteps_edit,'string',num2str(handles.data.nmcsteps));

    set(handles.gen_case_popupmenu,'string',char('random','allper'));

    switch handles.data.gen_case
        case 'random'
            set(handles.gen_case_popupmenu,'value',1);
        case 'allper'
            set(handles.gen_case_popupmenu,'value',2);
    end
    
    % Wait for callbacks to run and window to be dismissed:
    uiwait(fig);

    handles = guidata(fig);

    switch handles.cancel
        case 'off'
            DataFile.GeneralOptions.Compatibility = handles.data.compatibility;
            DataFile.GeneralOptions.TimeDisplayMode = handles.data.timedisplaymode;
            DataFile.GeneralOptions.SpikeDataFormat = handles.data.spikedataformat;
            DataFile.GeneralOptions.ShowSplashScreen = handles.data.showsplashscreen;
            DataFile.CSR.NShuffleElements = handles.data.nshuffleelements;
            DataFile.CSR.NMCSteps         = handles.data.nmcsteps;
            DataFile.CSR.gen_case         = handles.data.gen_case;
            DataFile.TrialOverlapMode = handles.data.trialoverlapmode;
            DataFile.FontSize = handles.fontsize;

            information('Saved changes made in General Options menu.','b');
            drawnow;
        case 'on'
            DataFile = handles.originaldata;
            information('No changes applied in General Options menu.','b');
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
function varargout = compatibility_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = timedisplaymode_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = spikedataformat_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = showsplashscreen_checkbox_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = trialoverlapmode_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = fontsize_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = nshuffleelements_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = nmcsteps_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = gen_case_popupmenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------


function varargout = apply_pushbutton_Callback(h, eventdata, handles, varargin)

selection = get(handles.compatibility_popupmenu,'value');

switch selection
    case 1
        handles.data.compatibility = 'IDLVersion';
    case 2
        handles.data.compatibility = '';
end

selection = get(handles.timedisplaymode_popupmenu,'value');

switch selection
    case 1
        handles.data.timedisplaymode = 'real';
    case 2
        handles.data.timedisplaymode = 'discrete';
end

selection = get(handles.spikedataformat_popupmenu,'value');

switch selection
    case 1
        handles.data.spikedataformat = 'gdfcell';
    case 2
        handles.data.spikedataformat = 'workcell';
end

selection = get(handles.showsplashscreen_checkbox,'value');

switch selection
    case 1
        handles.data.showsplashscreen = 'on';
    case 0
        handles.data.showsplashscreen = 'off';
end

selection = get(handles.trialoverlapmode_popupmenu,'value');

switch selection
    case 1
        handles.data.trialoverlapmode = 'causal';
    case 2
        handles.data.trialoverlapmode = 'exclusive';
    case 3
        handles.data.trialoverlapmode = 'off';
end

selection = get(handles.gen_case_popupmenu,'value');

switch selection
    case 1
        handles.data.gen_case = 'random';
    case 2
        handles.data.gen_case = 'allper';
end

handles.data.nshuffleelements = str2num(get(handles.nshuffleelements_edit,'string'));
handles.data.nmcsteps = str2num(get(handles.nmcsteps_edit,'string'));
handles.fontsize = str2num(get(handles.fontsize_edit,'string'));

handles.cancel = 'off';

guidata(h, handles);
uiresume(handles.figure1);

% --------------------------------------------------------------------
function varargout = cancel_pushbutton_Callback(h, eventdata, handles, varargin)

uiresume(handles.figure1);
