function UESetupFillParameters(handles,DataFile,reset_opt)


% Initialize datafile, paramfile and file menu
    
if reset_opt
    set(handles.loaddata_popupmenu,'enable','off');
    set(handles.loaddata_popupmenu,'string','');
    set(handles.loadparam_popupmenu,'enable','off');
    set(handles.loadparam_popupmenu,'string','');
    set(handles.selectanalysis_popupmenu,'enable','off');
    set(handles.selectanalysis_popupmenu,'string','');
    set(handles.newanalysis_pushbutton,'visible','off');

    set(handles.projectdir_edit,'enable','inactive');
    set(handles.projectdir_edit,'visible','off');
    set(handles.analysisdir_edit,'visible','off');
    set(handles.paramfile_edit,'enable','inactive');
    set(handles.paramfile_edit,'visible','off');
    set(handles.datafile_edit,'enable','inactive');
    set(handles.datafile_edit,'visible','off');

    set(handles.savepara_submenu,'enable','off');
    set(handles.saveparafile_submenu,'enable','off');
    set(handles.uemwafigure_menu,'enable','off');
    set(handles.signfigure_menu,'enable','off');
    set(handles.datahandling_menu,'enable','off');
end

% Initialize outfilename edit and saveresultmode checkbox
fullname = [DataFile.OutPath DataFile.OutFileName];
if ~isempty(fullname)
%     set(handles.outfilename_edit,'enable','on');
%     set(handles.outfilename_edit,'string',fullname);
    switch DataFile.SaveResult.Mode
        case 'off'
            set(handles.saveresultmode_checkbox,'value',0);
        case 'on'
            set(handles.saveresultmode_checkbox,'value',1);
    end
else
%     set(handles.outfilename_edit,'visible','off');
    set(handles.saveresultmode_checkbox,'visible','off');
end

% Initialize allevents listbox
set(handles.allevents_listbox,'string',DataFile.ListofallEvents);
if isempty(DataFile.ListofallEvents)
    set(handles.addneuron_pushbutton,'enable','off');
    set(handles.addevent_pushbutton,'enable','off');
else 
    set(handles.addneuron_pushbutton,'enable','on');
    set(handles.addevent_pushbutton,'enable','on');
end

% Initialize neuronlist listbox
set(handles.neuronlist_listbox,'string',DataFile.NeuronList);
if isempty(DataFile.NeuronList)
    set(handles.removeneuron_pushbutton,'enable','off');
else    
    set(handles.removeneuron_pushbutton,'enable','on');
end

% Initialize eventlist listbox
set(handles.eventlist_listbox,'string',DataFile.EventList);
if isempty(DataFile.EventList)
    set(handles.removeevent_pushbutton,'enable','off');
else    
    set(handles.removeevent_pushbutton,'enable','on');
end

% Initialize cutevent listbox and cutevent edit

if ~isempty(DataFile.ListofallEvents)
    set(handles.cutevent_popupmenu,'enable','on');
    set(handles.cutevent_popupmenu,'string',DataFile.EventList);
else
    set(handles.cutevent_popupmenu,'enable','inactive');
end
set(handles.cutevent_edit,'string',DataFile.CutEvent);
set(handles.cutevent_edit,'enable','inactive');

% Initialize cut times
set(handles.tpre_edit,'string',DataFile.TPre);
set(handles.tpost_edit,'string',DataFile.TPost);
set(handles.timeunits_edit,'string',DataFile.TimeUnits);

% Initialze analysis parameters
set(handles.alpha_edit,'string',DataFile.Analysis.Alpha);
set(handles.complexity_edit,'string',DataFile.Analysis.Complexity);
set(handles.complexity_max,'string',DataFile.Analysis.ComplexityMax);
set(handles.binsize_edit,'string',DataFile.Analysis.Binsize);
set(handles.tslid_edit,'string',DataFile.Analysis.TSlid);
set(handles.windowshift_edit,'string',DataFile.Analysis.WindowShift);
set(handles.uemethod_popupmenu,'string',char('trialaverage','trialbytrial','csr'));
if isempty(DataFile.Analysis.UEMethod)
    set(handles.uemethod_popupmenu,'value',1);
else switch DataFile.Analysis.UEMethod
      case 'trialaverage'
         set(handles.uemethod_popupmenu,'value',1);
      case 'trialbytrial'
         set(handles.uemethod_popupmenu,'value',2);
      case 'csr'
         set(handles.uemethod_popupmenu,'value',3);
     end
end
set(handles.wildcard_popupmenu,'string',char('off','on'));
if isempty(DataFile.Analysis.Wildcard)
    set(handles.wildcard_popupmenu,'value',1);
else switch DataFile.Analysis.Wildcard
      case 'off'
          set(handles.wildcard_popupmenu,'value',1);
      case 'on'
          set(handles.wildcard_popupmenu,'value',2);
      end
end