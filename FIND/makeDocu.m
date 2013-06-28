% Generate the interliked HTML files with the FIND Project Documentation.
% Allows to have the most recent docu available in a human browsable format.
%
% Note: Works only on FIND/trunk -> ingores subtoolboxes in subdirectories
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

addpath([pwd,'\m2html']);
FINDfullDir = fileparts(which('FIND_GUI.m'));
[pathstr, name, ext, versn] = fileparts(FINDfullDir);
FINDdir=name;
currentDir=pwd;
disp('Changing to directory above FIND directory for m2html call.')
try
    cd(FINDfullDir);
    cd ..;
    if  ~exist('m2html','file')
        error('m2html must be in search path!');
    else
        disp(['Writing docu to ' fullfile(FINDfullDir,'doc') '.'])
        m2html('mfiles',FINDdir, 'htmldir',fullfile(FINDdir,'doc'),'source','off');
    end
catch
    disp(['Error. Changing back to ' currentDir '.']);
    cd(currentDir); %On Linux cd FINDdir doesn't work.
    rethrow(lasterror);
end
disp(['Changing back to ' currentDir '.']);
cd(currentDir); %On Linux cd FINDdir doesn't work.
