function InCluster=callKlustaKwik(varargin)
% Perform Spike Sorting by calling KlustaKwik.
% Call KlustaKwik and return values.
%
% CAUTION: USES A DATA PATH TO KLUSTAKWIK PROGRAM
%
% Get http://klustakwik.sourceforge.net/ , install according to doc there.
% Set the path in init.m.
% Rmeier 201106
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% obligatory argument names
obligatoryArgs={{'KlustaExe', @(val) ischar(val) && isfile(val)},...
                'DataMatrix'}; %-% e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={}; 

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

% main function code


if (size(DataMatrix,1)>48) error('Too many Dimensions!'); end


DataMatrix=DataMatrix * 1000; % go to mv 

% export to temp. File
fid=fopen('tmp4KlustaQuick.fet.1','wt');
fprintf(fid,'%d\n',size(DataMatrix,2));


for ii=1:size(DataMatrix,1)
    for ff=1:size(DataMatrix,2)
        fprintf(fid,'%4.4f ',DataMatrix(ii,ff));
    end
    fprintf(fid,'\n');
end
fclose(fid);


% run the programm

%use this command to run KlustaKwik with all features
dos(['"' KlustaExe '" tmp4KlustaQuick 1  -MaxPossibleClusters 5  -UseFeatures all']) %%% run and classify 

%use only the first 23 features/dimensions (important to use the format descriptor '%d')
%dos(['"' KlustaExe '" tmp4KlustaQuick 1  -MaxPossibleClusters 10  -UseFeatures ' num2str(ones(1,23),'%d')]) %%% run and classify 

% delete temporary data file
delete('tmp4KlustaQuick.fet.1');

disp('here');
% read the data-Classification
fid=fopen('tmp4KlustaQuick.clu.1','rt');
count=1;
while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end
    InCluster(count)=str2num(tline);
    count=count+1;
end

fclose(fid);

% discard first Number - since this tells the number of clusters in the
% FILE..
InCluster=InCluster(2:end);

% delete temporary output file
delete('tmp4KlustaQuick.clu.1');


