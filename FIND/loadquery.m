function filterstring=loadquery()
% reads filter specifications from Filter GUI for storing them.
% called by queryEntitiesGUI.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% get list of all possible filter choices from Filter GUI
TempListofOptions=get(findobj(gcbf,'Tag','prop2optionspopup'),'String');
TempListofCon=get(findobj(gcbf,'Tag','con12popup'),'String');
Currentprop=1;
filterSpecs=[];

%check if filter choice 1 is inverted
if get(findobj(gcbf,'Tag','prop1invertcheckbox'),'Value')==1
    filterSpecs{Currentprop}={'INV'};
    Currentprop=Currentprop+1;
end

%get filter choice 1
filterSpecs{Currentprop}=TempListofOptions(get(findobj(gcbf,'Tag','prop1optionspopup'),'Value')+1);
Currentprop=Currentprop+1;

% if a second filter choice is selected, get values from conjunction popup
% and inversion checkbox
if ~(get(findobj(gcbf,'Tag','prop2optionspopup'),'Value')==1)
    filterSpecs{Currentprop}=TempListofCon(get(findobj(gcbf,'Tag','con12popup'),'Value'));
    Currentprop=Currentprop+1;
    if get(findobj(gcbf,'Tag','prop2invertcheckbox'),'Value')==1
        filterSpecs{Currentprop}={'INV'};
        Currentprop=Currentprop+1;
    end
    filterSpecs{Currentprop}=TempListofOptions(get(findobj(gcbf,'Tag','prop2optionspopup'),'Value'));
    Currentprop=Currentprop+1;
end


% if a third filter choice is selected, get values from conjunction popup
% and inversion checkbox

if ~(get(findobj(gcbf,'Tag','prop3optionspopup'),'Value')==1)
    filterSpecs{Currentprop}=TempListofCon(get(findobj(gcbf,'Tag','con23popup'),'Value'));
    Currentprop=Currentprop+1;
    if get(findobj(gcbf,'Tag','prop3invertcheckbox'),'Value')==1
        filterSpecs{Currentprop}={'INV'};
        Currentprop=Currentprop+1;
    end
    filterSpecs{Currentprop}=TempListofOptions(get(findobj(gcbf,'Tag','prop3optionspopup'),'Value'));
end

filterstring=filterSpecs;
