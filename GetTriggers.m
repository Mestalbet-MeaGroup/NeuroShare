% Find Trigger Onsets
function [Starts,Stops,triggers]=GetTriggers(McdFile)
% [fileToRead1,filepath] = uigetfile('*.mcd');
% McdFile=[filepath fileToRead1];
Starts=1;
Stops=2;
DllPath='C:\Neuroshare\FIND\';% FIND_2.0 path
DLLName = 'nsMCDLibrary64.dll';
DLLfile = fullfile(DllPath, DLLName);
[ns_RESULT] = ns_SetLibrary(DLLfile);
[ns_RESULT, hfile] = ns_OpenFile(McdFile);
try
    [ns_RESULT, FileInfo] = ns_GetFileInfo(hfile);
    [ns_RESULT, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
    [ss, triggers, ss, ss] = ns_GetEventData(hfile, 1, 1:EntityInfo(1).ItemCount);
catch
    triggers=[];
end
a = zeros(round(max(triggers)*10),1);
a(round(triggers.*10))=1;
[Starts, Stops]=initfin(a');
Starts=Starts./10;
Stops=Stops./10;
end