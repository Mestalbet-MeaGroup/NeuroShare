function txt_array=exportGDF(varargin)
% exports  Neural Events and exports  Events (aka triggers) in the GDF Format - used by the UnitaryEvents Analysis!
%
% Attention: all timings are preserved at millisecond precision!
%
% 
% R. Meier 13 March 2007, meier@biologie.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% obligatory argument names
obligatoryArgs={{'neuronID', @(var) ~isempty(var)},...
    'eventID',...
    {'outputFile', @(arg) ischar(arg)},...
    }; %e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={};
% e.g.:
% a=500;
% b='spikes';

% valid var names provided? Otherwise, error is generated.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace
pvpmod(varargin);

global nsFile;

txt_array=[];
if exist(outputFile)==2;
    existingFile=questdlg('There is a file with an identical name on your MATLAB searchpath.',...
        'Do you want to overwrite it?', ...
        'overwrite','cancel','cancel');
    switch existingFile
        case 'cancel'
            return;
    end
end

% concatenate all neurons and their here: Virtual ID...
% Needed: Translation Table between ID and Information in nsFile
gdf_mat=[];

for ii=neuronID
    tmp=round(nsFile.Neural.Data{find(nsFile.Neural.EntityID==ii)}* 1000); % move to ms Precision !
    gdf_mat=[gdf_mat;[repmat(ii,size(tmp)),tmp]];
end

% Now, add the Events (or triggers) as Units - use a "high" ID:
for ii=eventID
    % select the Events with this ID and export the respective timestamps!
    tmp=round(nsFile.Event.TimeStamp{find(nsFile.Event.EntityID==ii)}*1000);
    % define Events as neurons with a high ID ...
    % trial are seperated by uniform TrialMarkers
    gdf_mat=[gdf_mat;[repmat(4000 ,size(tmp)) tmp]];
end
if ~isempty(eventID)
    % erase the marker for the first trial to make shure the file starts with a trialmarker
    gdf_mat=setdiff(gdf_mat,[4000 0],'rows');
    gdf_mat=unique(gdf_mat,'rows');
    gdf_mat=sortrows(gdf_mat,2);
    % set the marker to the first postition
    gdf_mat=[[4000 0];gdf_mat];
else
    gdf_mat=unique(gdf_mat,'rows');
    gdf_mat=sortrows(gdf_mat,2);
end


% Write the file to disk ...
disp(['...writing gdf data to file ' outputFile]);
fid=fopen(outputFile, 'w');
fprintf(fid, '%12d %12d\n', gdf_mat');
fclose(fid);

% generate some Report
txt_array='Report: GDF Data Export';
txt_array=strvcat(txt_array,' ');
txt_array=strvcat(txt_array,['data exported to:     ',outputFile]);
txt_array=strvcat(txt_array,' ');
txt_array=strvcat(txt_array,['ID Neurons:   ', num2str(neuronID)]);
if isempty(eventID)
    txt_array=strvcat(txt_array,['ID Trials:    ','no TrialMarkers in the exported file']);
else
    txt_array=strvcat(txt_array,['ID Trials:    ',num2str(eventID)]);
end

txt_array=strvcat(txt_array,' ');

    disp([' file closed. done. ']);
    % done ...