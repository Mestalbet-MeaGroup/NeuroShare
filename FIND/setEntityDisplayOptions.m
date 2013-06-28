function setEntityDisplayOptions()
% Allows to select which fields of nsFile are displayed in browseEntitiesGUI
%
% Markus Nenniger 2006
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile

entityfields=[];
eventfields=[];
analogfields=[];
segmentfields=[];
neuralfields=[];

% retrieve existing fields for all data types

try entityfields=fieldnames(nsFile.EntityInfo);catch;end
try eventfields=fieldnames(nsFile.Event.Info);catch;end
try analogfields=fieldnames(nsFile.Analog.Info);catch;end
try segmentfields=fieldnames(nsFile.Segment.Info);catch;end
try neuralfields=fieldnames(nsFile.Neural.Info);catch;end

% add parent fields to string for better readability

if ~isempty(entityfields)
    for ii=1:length(entityfields)
        entityfields{ii}=['nsFile.EntityInfo.',entityfields{ii}];
    end
end

if ~isempty(eventfields)
    for ii=1:length(eventfields)
        eventfields{ii}=['nsFile.Event.Info.',eventfields{ii}];
    end
end

if ~isempty(analogfields)
    for ii=1:length(analogfields)
        analogfields{ii}=['nsFile.Analog.Info.',analogfields{ii}];
    end
end

if ~isempty(segmentfields)
    for ii=1:length(segmentfields)
        segmentfields{ii}=['nsFile.Segment.Info.',segmentfields{ii}];
    end
end

if ~isempty(neuralfields)
    for ii=1:length(neuralfields)
        neuralfields{ii}=['nsFile.Neural.Info.',neuralfields{ii}];
    end
end

% remove redunant field

uniquefields=[entityfields; eventfields; analogfields; segmentfields; neuralfields];
geometry=[];
listui=[];
geometry{1}=[1];
listui{1}={'style','text','string','Select info for display'};
for ii = 1:length(uniquefields)
    geometry{ii+1}=[1 8];
    listui{end+1}={'style','checkbox','Tag',uniquefields{ii}};
    listui{end+1}={'style','text','string',uniquefields(ii)};
end

% prepare for display with superGUI

if ishandle(findobj('Name','Display Options'))
    close(findobj('Name','Display Options'));
    optionsdisplay=figure('Name','Display Options');
else
    optionsdisplay=figure('Name','Display Options');
end
listui{end+1}={'style','pushbutton','string','Apply','Callback','selectGUIdisplayOptions'};
geometry{end+1}=1;
supergui(optionsdisplay,geometry,[],listui{:});

% set checked boxes

FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
for ii=1:length(FIND_GUIdata.displayOptions)
    set(findobj(gcf,'Tag',FIND_GUIdata.displayOptions{ii}),'Value',1);
end

    
    
