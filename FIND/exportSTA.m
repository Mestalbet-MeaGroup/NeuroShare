function exportSTA(varargin)
% Export spike data from global variable nsFile to STA file.
%-%% TO BE DOCUMENTED
%-%% <summary text>
%-%%
%-%% Parameters to be passed as parameter-value pairs:
%-%%
%-%% x1: ...
%-%% x2: ...
%-%% [optional1]: ...
%-%%
%-%% Return value: ...
%-%%
%-%% Further comments:
%-%%
%-%% ... 
%-%
%-% Notes:
%-%
%-% - ...
%-% - ...
%-% ...
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


%!!  I don't really get how the trial/site thing is meant ("different sites
%only if recorded simultaneously"... have to look into that!!! )
%!! it doesn't say anything about the format of the doubles (check also the
%resolution thing)
%!! categouries etc don't know yet how to translate that from the
%nsFile..maybe needs to be user-defined anyway
%!! note that the absolute path has to be stored in the metadatafile, so no
%copying around of the files... :/

global nsFile;

% obligatory argument names
function result = isAbsolutePath(arg)
[path, name, extension] = fileparts(arg);
result = ~isempty(path) && ~isempty(name) && ~isempty(extension);
end
obligatoryArgs={{'STAMfileName', @(arg) ischar(arg) && length(arg)>5 && ...
                                        strcmp(arg(end-4:end),'.stam') && ...
                                        isAbsolutePath(arg)}};

% optional arguments names with default values
optionalArgs={}; 

% valid var names provided? Otherwise, error is generated.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

% main function code


if isfield(nsFile,'Neural')
    nCurrentSources=length(nsFile.Neural);
else
    nCurrentSources=0;
end

STADfileName=[STAMfileName(1:end-5) '.stad'];

% open metadata file ('.stam')
STAMfile=fopen(STAMfileName,'wt');

fprintf(STAMfile,'# Data filename \n');
fprintf(STAMfile,'datafile=%s;\n',STADfileName);
fprintf(STAMfile,'#\n');
fprintf(STAMfile,'# Site metadata\n');
for iSource=1:nCurrentSources
    fprintf(STAMfile,...
    'site=%d; label=???; recording_tag=???; time_scale=???; time_resolution=???;\n', ...
    iSource);
end
fprintf(STAMfile,'#\n');
fprintf(STAMfile,'# Category metadata\n');
fprintf(STAMfile,'???\n');
fprintf(STAMfile,'#\n');
fprintf(STAMfile,'# Trace metadata\n');

traceID=1;
for iSource=1:nCurrentSources
    nTrials=length(nsFile.Neural{iSource}.Trial);
    for iTrial=1:nTrials        
       fprintf(STAMfile,...
         'trace=%g; catid=???; trialid=%g; siteid=%g; start_time=???; end_time=???;\n',...
         traceID, iTrial, iSource);
       traceID=traceID+1;
    end
end
fclose(STAMfile);

% open data file ('.stad')
STADfile=fopen(STADfileName,'wt');
for iSource=1:nCurrentSources
    nTrials=length(nsFile.Neural{iSource}.Trials);
    for iTrial=1:nTrials
       fprintf(STADfile,'%0.8g ',nsFile.Neural{iSource}.Trials{iTrial});
       fprintf(STADfile,'\n');
    end
end
fclose(STADfile);




end