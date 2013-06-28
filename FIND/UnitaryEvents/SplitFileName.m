function [pathname, filename] = SplitFileName(fullfilename)
% function [pathname, filename] = SplitFileName(fullfilename)
% **************************************************************
% *                                                            *
% * function splits Filename in File and Path                  *
% *                                                            *
% * Input:  fullfilename: string                               *
% *                                                            *
% * Output: filename: string                                   *
% *         pathname: string                                   *
% *                                                            *
% * Example: fullfilename = /home/messer/matlab/information.m  *
% *                                                            *
% *          Result: pathname = /home/messer/matlab/           *
% *                  filename = information.m                  *
% *                                                            *
% * History: 1) first version                                  *
% *             PM, 14.8.02, FfM                               *
% *          2) changed the detection of path and filename     *
% *             to be done automatically correct               *
% *             independent of the operating system            *
% *             SG, 2.Nov 2004, Philadephia                    *
% *                                                            *
% **************************************************************

% detect operating system: computer
% PCWIN or GLNX86

%  [PATHSTR,NAME,EXT,VERSN] = FILEPARTS(FILE) returns the path, 
%     filename, extension and version for the specified file. 
%     FILEPARTS is platform dependent.

% FULLFILE Build full filename from parts.
%     FULLFILE(D1,D2, ... ,FILE) builds a full file name from the
%     directories D1,D2, etc and filename FILE specified.  This is
%     conceptually equivalent to

[pathname,filename,EXT,VERSN] = fileparts(fullfilename);


return

% old code
position = findstr('/',fullfilename);

if ~isempty(position) % fullfilename contains '/'
    position     = findstr('/',fullfilename);
    lastposition = position(length(position));
    pathname     = fullfilename(1:lastposition);
    if isempty(pathname);
        pathname = '';
    end
    filename     = fullfilename(lastposition+1:length(fullfilename));
    if isempty(filename)
        filename = '';
    end
else
    pathname = '';
    filename  = fullfilename;
end
