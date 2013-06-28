function varargout = batchwindow(varargin)
% BATCHWINDOW Application M-file for batchwindow.fig
%    FIG = BATCHWINDOW launch batchwindow GUI.
%    BATCHWINDOW('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 21-Aug-2002 17:23:12

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    guidata(fig, handles);
    
    % Set parameters
    
    set(handles.script_edit,'string','');
    set(handles.remove_pushbutton,'enable','off');
    set(handles.listbox,'string','');
    information(['The "Unitary Events Batch Mode" allows UE Analysis of several ' ...
                 'parameter settings. Each individual setting has to be created and saved ' ...
                 'in "Normal Mode" and can than be added to the batch list. A whole batch ' ...
                 'list can be saved or loaded in the File menu.']);
    drawnow;
    
    % Wait for callbacks to run and window to be dismissed:
    uiwait(fig);

    information('');
    drawnow;
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

 uiresume(handles.figure1);

% --------------------------------------------------------------------
function varargout = start_pushbutton_Callback(h, eventdata, handles, varargin)

 % get filenames
 filelist = cellstr(get(handles.listbox,'string'));
 if isequal(filelist,{''})
     information('No Parameter Files selected.');
     drawnow;
 else
     for i=1:length(filelist)
         % load DataFile structure
         DataFile = [];
         load(filelist{i}); %eval(['load ' filelist{i}]);
         if ~isempty(DataFile);
            DataFileArray(i) = DataFile;
         else
            information(['Could not load valid DataFile structure from ' filelist{i}]);
            drawnow;
            clear DataFile DataFileArray;
            return;
         end
         clear DataFile;
     end
     
     information('Started UE Analysis with current Parameter Setting.');
     drawnow;
     UEMain(DataFileArray);
     clear DataFileArray
 end

% --------------------------------------------------------------------
function varargout = add_pushbutton_Callback(h, eventdata, handles, varargin)

 [filename, pathname] = uigetfile({'*.mat',...
                                   '.mat Format (*.mat)';...
                                   '*.*', 'All Files (*.*)'},...
                                   'Load Parameter File');
  if ~(filename == 0)
    % write new Parameter File to listbox
    loadfilename = [pathname filename];
    oldstring = get(handles.listbox,'string');
    if isempty(oldstring)
       newstring = loadfilename;      
       set(handles.remove_pushbutton,'enable','on');
    else    
       newstring = char(oldstring, loadfilename);
    end
    set(handles.listbox,'string',newstring);
    information(['Loaded new Parameter File: ' loadfilename]);
    drawnow;
  end

% --------------------------------------------------------------------
function varargout = remove_pushbutton_Callback(h, eventdata, handles, varargin)

    % get position and strings and convert to cells
    position  = get(handles.listbox,'value');
	oldlist = cellstr(get(handles.listbox,'string'));
    information(['Removed Parameter File: ' oldlist{position}]);
    drawnow;
    % remove selected positions
    oldlist(position)=[];
    % convert back to char
    newlist = char(oldlist);
    % fill listboxes with new strings
    set(handles.listbox,'string',newlist);  
    % check, if there are files left in list, else disactivate removebutton
    if isempty(newlist)
      set(handles.remove_pushbutton,'enable','off');
    else
      set(handles.listbox,'value',1);
    end

% --------------------------------------------------------------------
function varargout = batchload_submenu_Callback(h, eventdata, handles, varargin)

 [filename, pathname] = uigetfile({'*.mat',...
                                   '.mat Format (*.mat)';...
                                   '*.*', 'All Files (*.*)'},...
                                   'Load Batch Script from File');
  if ~(filename == 0)
    % load DataFile structure
    DataFile = [];
    filelist = {''};
    loadfilename = [pathname filename];
    load(loadfilename); %eval(['load ' loadfilename]);
    if ~isempty(DataFile)
       % fill new parameters
       if ~isequal(filelist,{''})
          newstring = char(filelist);
          set(handles.listbox,'string',newstring);
          set(handles.script_edit,'string',loadfilename);
          set(handles.remove_pushbutton,'enable','on');
          information(['Loaded new Batch Script: ' loadfilename]);
          drawnow;
       else
          information(['Could not load valid file list from' loadfilename]);
          drawnow;  
       end
    else
       information(['Could not load valid DataFile structure from' loadfilename]);
       drawnow;
    end
    clear DataFile filelist;
  end

% --------------------------------------------------------------------
function varargout = batchsave_submenu_Callback(h, eventdata, handles, varargin)

 [filename, pathname] = uiputfile({'*.mat',...
                                   '.mat Format (*.mat)';...
                                   '*.*', 'All Files (*.*)'},...
                                   'Save Batch Script to File');
 
 if ~(filename == 0)
  % eventually add .mat to filename
  position = findstr('.mat',filename);
    if isempty(position)
      savefilename = [pathname filename '.mat'];
    else
      savefilename = [pathname filename];
    end        
  % get filenames
  filelist = cellstr(get(handles.listbox,'string'));
  if isequal(filelist,{''})
      information('No Parameter Files in List. Cannot save empty Batch Script.');
      drawnow;
  else
      for i=1:length(filelist)
          % load DataFile structure
          DataFile = [];
          load(filelist{i}); %eval(['load ' filelist{i}]);
          if ~isempty(DataFile)
             % attach filename of parameter file to structure
             DataFileArray(i) = DataFile;
             clear DataFile;
          else
            information(['Could not load valid DataFile structure from ' filelist{i}]);
            drawnow;
            clear DataFile DataFileArray;
            return;
         end
      end
      % save DataFile structure
      DataFile = DataFileArray;
      save(savefilename,'DataFile','filelist');
      %eval(['save ' savefilename ' DataFile' ' filelist']);
      set(handles.script_edit,'string',savefilename);
      clear DataFile DataFileArray filelist;
      information(['Saved Batch Script to File: ' savefilename]);
      drawnow;
  end
 end

% --------------------------------------------------------------------
function varargout = batchclose_submenu_Callback(h, eventdata, handles, varargin)

 uiresume(handles.figure1);
 
% --------------------------------------------------------------------
function varargout = listbox_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = script_edit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = batchfile_menu_Callback(h, eventdata, handles, varargin)
