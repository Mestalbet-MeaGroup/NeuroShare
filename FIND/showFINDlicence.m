function showFINDlicence();
% function showFINDlicence();
% Display the FIND-Toolbox licence!
% By downloading or using  the FIND Toolbox you agree to the terms stated
% in this licence.
% The full licence text can  also be found in the file
% licence.txt in the main FIND directory.
%
%
% The main points of the licence in brief:
%
% - this software is free of charge and can be used and modified for 
%   non-commercial purposes. 
% - This software comes without any warrenty!
% - You are aware that you are using a work in progress.
% - you are obliged to CITE the FIND-Toolbox (Website and/or Inital Paper)
%
%  Meier R, Egert U, Aertsen A, Nawrot M (2008)
%  FIND – a unified framework for neural data analysis
%  to appear in the journal "Neural Networks".
%
%  http://find.bccn.uni-freiburg.de
%
% Thank you for choosing FIND!
% Ralph Meier, March 2008


disp('-------------------------------------------------------')
fid=fopen('licence.txt','r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    disp(tline)
end
fclose(fid);
disp('-------------------------------------------------------')

