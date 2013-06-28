function handleError(err)
% handles errors, i.e. by printing them to messageBars/ the MATLAB window

% printing full error to MATLAB command line; 
% If figure whose current callback is executing has messageBar, print small 
% error message there,too; otherwise, print to main window messageBar.
%
%NOTE: Apparently, different types of errors are handled differently by
%MATLAB, unfortunately: You can try it out by causing eithet an "unknown 
%variable" error, or an "unbalanced parantheses" error. In the former case,
%information is about the occurance of the error is written only into the 
%stack field of lasterror, wheras in the latter, the position is (also?) 
%directly written into the message field, as a hot-link. 
%
%I also seems to have to do with whether the error happened in a nested
%function or not: In the former example, even if the actuall error is in
%the same line, in one case it is interpreted as nested (multiple files are
%given in the stack), in one it is not. Apparently, if the info is
%displayed as hot-link in the message, then this hot-link refers to the
%innermost function, and in the stack only information about outer
%functions is stored.
%
%With the current implementation of handleError(), both the message and the
%stack information will be displayed. Hence, in certain cases a hot-link
%will be available, and then the line information from the stack will 
%refer to an outer function... so it's not always displayed in the same
%manner, but it should be understandable in any case.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% Data not loaded yet doesn't qualify for a full blown error.
switch err.identifier
    case 'FIND:noAnalogData'
       postMessage('Please load analog data first.'); 
    case 'FIND:noSegmentData'
       postMessage('Please load segment data first.'); 
    case 'FIND:noNeuralData'
       postMessage('Please load neural data first.'); 
    case 'FIND:noEventData'
       postMessage('Please load event data first.'); 
    case 'FIND:noFileLoaded'
       postMessage('Please load a data file first.');

    otherwise

        %err.stack(1) should refer to the error information of the
        %innermost error in the cases nested functions.
        barMessage=['ERROR: in "' err.stack(1).name '"; see MATLAB window for details.'];

        [h,fig]=gcbo;
        messageBar=findobj(get(fig,'Children'),'-regexp','Tag','(?i)messageBarText$');
        %(?i) means case INsensitive, $ means expression must be at end of string
        get(messageBar,'Tag');
        if (isempty(messageBar))
            mainWindow=findobj('Tag','FIND_GUI');
            messageBar=findobj(get(mainWindow,'Children'),'Tag','messageBar');
            if (isempty(messageBar))
                error('ERROR IN ERROR HANDLER: main window message bar not found - something is wrong!');
            end
        end

        set(messageBar,'String',barMessage);
        set(messageBar,'TooltipString',barMessage);
        commandLineMessage1=['ERROR: in "' err.stack(1).name '": ' err.message];
        [pathstr, name, ext, versn] = fileparts(err.stack(1).file);
        commandLineMessage2=['Caused in ' name ext ', line ' ...
            num2str(err.stack(1).line) '; '];
        for iStack=2:length(err.stack)
            [pathstr, name, ext, versn] = fileparts(err.stack(iStack).file);
            commandLineMessage2=[commandLineMessage2 ...
                'called from ' name ext ', line ' num2str(err.stack(iStack).line) '; '];
        end
        disp('...');
        disp(commandLineMessage1);
        disp(commandLineMessage2);
end