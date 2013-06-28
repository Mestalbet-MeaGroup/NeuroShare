function [result status] = python(varargin)
%   python Execute python command and return the result.
%   python(pythonFILE) calls python script specified by the file pythonFILE
%   using appropriate python executable.
%
%   python(pythonFILE,ARG1,ARG2,...) passes the arguments ARG1,ARG2,...
%   to the python script file pythonFILE, and calls it by using appropriate
%   python executable.
%
%   RESULT=python(...) outputs the result of attempted python call.  If the
%   exit status of python is not zero, an error will be returned.
%
%   [RESULT,STATUS] = python(...) outputs the result of the python call, and
%   also saves its exit status into variable STATUS. 
% 
% R.Meier, 25.07.07 based on "perl.m" from Mathworks 
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

cmdString = '';

% Add input to arguments to operating system command to be executed.
% (If an argument refers to a file on the MATLAB path, use full file path.)
for i = 1:nargin
    thisArg = varargin{i};
    if isempty(thisArg) || ~ischar(thisArg)
        error('All input arguments must be valid strings.');
    end
    if i==1
        if exist(thisArg, 'file')==2
            % This is a valid file on the MATLAB path
            if isempty(dir(thisArg))
                % Not complete file specification
                % - file is not in current directory
                % - OR filename specified without extension
                % ==> get full file path
                thisArg = which(thisArg);
            end
        else
            % First input argument is pythonFile - it must be a valid file
            error(['Unable to find python file: ', thisArg]);
        end
    end
  
  % Wrap thisArg in double quotes if it contains spaces
  if any(thisArg == ' ')
    thisArg = ['"', thisArg, '"'];
  end
  
  % Add argument to command string
  cmdString = [cmdString, ' ', thisArg];
end

% Execute python script
errTxtNopython = 'Unable to find python executable.';

if isempty(cmdString)
  error('No python command specified');
elseif ispc
  % PC
    pythonCmd = 'C:\Documents and Settings\student.BCCN\Desktop\Python';
%  pythonCmd = fullfile(matlabroot, 'sys\python\win32\bin\');
  cmdString = ['python' cmdString];
  pythonCmd = ['set PATH=',pythonCmd, ';%PATH%&' cmdString];
  [status, result] = dos(pythonCmd);
else
  % UNIX
  [status ignore] = unix('which python'); %#ok
  if (status == 0)
    cmdString = ['python', cmdString];
    [status, result] = unix(cmdString);
  else
    error(errTxtNopython);
  end
end

% Check for errors in shell command
if nargout < 2 && status~=0
  error(['System error: ', result, ...
      'Command executed: ', cmdString]);
end

