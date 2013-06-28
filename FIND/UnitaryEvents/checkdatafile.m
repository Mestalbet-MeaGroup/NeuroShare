function checkdatafile(DataFile)
% function checkdatafile(DataFile)
% **********************************************************
% *                                                        

% initialize message array

index = 0;

% perform checks and store errors

if ~strcmp(DataFile.SignFigure.PatSel,':')
 if ~(length(DataFile.NeuronList)==length(DataFile.SignFigure.PatSel))
   index = index+1;
   message{index} = ['failed: length(DataFile.NeuronList)=='...
                     'length(DataFile.SignFigure.PatSel)'];
 end
end
if ~ismember(DataFile.UEMWAFigure.EventsToPlot,DataFile.EventList)
   index = index+1;
   message{index} = ['failed: ismember(DataFile.UEMWAFigure.EventsToPlot,'...
                     'DataFile.EventList)'];  
end
if ~ismember(DataFile.SignFigure.EventsToPlot,DataFile.EventList)
   index = index+1;
   message{index} = ['failed: ismember(DataFile.SignFigure.EventsToPlot,'...
                     'DataFile.EventList)'];
end
if ~strcmp(DataFile.SortMode,'none')
  if ~ismember(DataFile.SortEvent,DataFile.EventList)
   index = index+1;   
   message{index} = 'failed: ismember(DataFile.SortEvent,DataFile.EventList)';
  end
end
if ~strcmp(DataFile.ShiftMode,'none')
  if ~ismember(DataFile.ShiftNeuronList,DataFile.NeuronList)
   index = index+1;
   message{index} = 'failed: ismember(DataFile.ShiftNeuronList,DataFile.NeuronList)';
  end  
end
if ~(length(DataFile.UEMWAFigure.VerticalLineStyle)==...
     length(DataFile.UEMWAFigure.VerticalLineWidth))
   index = index+1;
   message{index} = ['failed: length(UEMWAFigure.VerticalLineStyle)=='...
                     'length(UEMWAFigure.VerticalLineWidth)'];
end
if ~(length(DataFile.UEMWAFigure.VerticalLineStyle)==...
     length(DataFile.UEMWAFigure.VerticalLineText))
   index = index+1;
   message(index) = ['check: length(UEMWAFigure.VerticalLineStyle)=='...
                     'length(UEMWAFigure.VerticalLineText)'];
end
if ~(length(DataFile.UEMWAFigure.VerticalLineStyle)==...
     length(DataFile.UEMWAFigure.VerticalLinePosInMS))
   index = index+1;
   message{index} = ['check: length(UEMWAFigure.VerticalLineStyle)=='...
                     'length(UEMWAFigure.VerticalLinePosInMS)'];
end
if ~(length(DataFile.SignFigure.VerticalLineStyle)==...
     length(DataFile.SignFigure.VerticalLineWidth))
   index = index+1;
   message{index} = ['check: length(SignFigure.VerticalLineStyle)=='...
                     'length(SignFigure.VerticalLineWidth)'];
end
if ~(length(DataFile.SignFigure.VerticalLineStyle)==...
     length(DataFile.SignFigure.VerticalLineText))
   index = index+1;
   message{index} = ['check: length(SignFigure.VerticalLineStyle)=='...
                     'length(SignFigure.VerticalLineText)'];
end
if ~(length(DataFile.SignFigure.VerticalLineStyle)==...
     length(DataFile.SignFigure.VerticalLinePosInMS))
   index = index+1;
   message{index} = ['check: length(SignFigure.VerticalLineStyle)=='...
                     'length(SignFigure.VerticalLinePosInMS)'];
end
if DataFile.Analysis.ComplexityMax > length(DataFile.NeuronList)
   index = index+1;
   message{index} = ['WARNING: max complexity > number of neurons' ...
           '==> max complexity set to number of neurons'];
   DataFile.Analysis.ComplexityMax = length(DataFile.NeuronList);
   h=findobj('Tag','complexity_max');
   set(h,'String',num2str(DataFile.Analysis.ComplexityMax));
end 
             

% in case of errors display messages

if index > 0
   messagestring = char(message);
   errorwindow(messagestring);
   drawnow;
else
   errorwindow('No errors ocurred during Parameters Check.');
   drawnow;
end
