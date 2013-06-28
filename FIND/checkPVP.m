function errorMessage=checkPVP(varargin, obligArgs, optArgs)
% Checks validity of paramater-value pair arguments for pvpmod.
%
% This function is supposed to be used in conjunction with pvpmod. First,
% it checks if the argument names in varargin are valid by comparing them
% to list of allowed names provided in cell arrays obligArgs and optArgs.
% obligArgs are obligatory variables, optArgs are optional ones. If
% obligatory variables are missing, or if invalid variables neither in
% obligArgs nor optArgs are provided, checkPVP returns a corresponding 
% error message. Second and optionally, it can also test the parameter 
% values (see below). If everything is fine, the return value is empty.
%
% Note that currently only parameter-value pairs are accepted, not
% structures (which does work for pvpmod).
%
% The following example illustrates the basic usage of checkPVP. Obligatory
% and optional arguments are defined. For the latter, default values are
% given, too. This is done by simply assigning the values to the
% corresponding variables. If any of those variables are passed as function
% parameters, the default values will be overwritten.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function exampleFu(varargin)
%
% % obligatory argument names
% obligatoryArgs={'firstVar', 'secondVar'}; 
%
% % optional arguments names with default values
% optionalArgs={'firstOpt', 'secondOpt'};
% firstOpt=42; % will only be overwritten by pvpmod if 'firstOpt' is provided
% secondOpt=23; % will only be overwritten by pvpmod if 'secondOpt' is provided
%
% errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
% if ~isempty(errorMessage)
%   error(errorMessage,''); %used this format so that the '\n' are converted
% end
%
% % loading parameter value pairs into workspace
% pvpmod(varargin);
%
% % rest of function...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Furthemore, checkPVP can also check the validity of the parameter values
% in varargin, using custom test functions provided by the user. For each
% parameter defined in obligArgs or optArgs, the user can pass a function
% handle of a function that returns true or false depending on if the
% parameter meets desired conditions. To this end, instead of only passing
% the parameter name, the user passes a two element cell array. The
% first element is the name string, the second the respective function
% handle. 
%
% For instance, assume you have two optional arguments for your function, 
% "userComment" and "userGender". While the value of the first is arbitrary, 
% the latter should either take the value 'male' or 'female'. Hence, to
% check whether the user provided a correct value, you write a function
% that tests this and returns true or false correspondingly:
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function result=testGenderValue(gender)
%
% result = ismember(gender,{'male','female'});
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Now, in the list optionalArgs not only the parameter name 'userGender' 
% is provided, but also the handle of the corresponding test function, both
% together in a cell array:
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optionalArgs = {'userComment', {'userGender', @testGenderValue}};
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Then, when checkPVP is called, it does not only checks the parameter name 
% provided by the user in the parameter-value-pair, but also the provided 
% value by passing it to the testGenderValue() function.
% 
% Now, it often might seem too much effort to define full test functions 
% for each parameter value. Then MATLAB anonymous functions can be used,
% which basically is a way to locally define functions where otherwise the
% handle would be passed. The function is defined inline and without a
% proper function name (hence "anonymous"). See the MATLAB help for
% details. For the case of testGenderValue(), one would write:
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optionalArgs = {'userComment', ...
%           {'userGender', @(value) ismember(value,{'male','female'})} };
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% It follows another example for how PVPcheck can be used with anonymous
% functions as test functions. The function exampleFu receives
% parameter-value pairs as arguments. It expects 'nTrials' as obligatiory
% argument, and the provided value must be a positive number (and not a
% vector). 'type' is an optional argument, whose value can be either 't1'
% or 't2', and 't1' is used as default value if 'type' is not provided in
% varargin. Finally, 'userData' is an optional argument, which uses neither
% test function nor default value.
%
% function exampleFu(varargin)
%
% % obligatory argument names
% obligatoryArgs={{'nTrials', @(val) length(val)==1 && val>0}}; 
%
% % optional arguments names with default values
% optionalArgs={...
%               {'type', @(val) ismember(val,{'t1','t2'})},...
%               'userData'}; 
% type='t1'; % will only be overwritten by pvpmod if 'type' is provided
% 
% errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
% if ~isempty(errorMessage)
%   error(errorMessage,''); %used this format so that the '\n' are converted
% end
%
% % loading parameter value pairs into workspace
% pvpmod(varargin);
%
% % rest of function...
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de




%%% First, test if number of arguments is even (parameter value pairs!), and
%%% if all parameter names are unique.
if (mod(length(varargin),2)~=0)
    errorMessage='Number of arguments not even. Only parameter-value-pairs are valid as arguments.';
    return;
end
argNames=varargin(1:2:end);
if length(unique(argNames))~=length(argNames)
    errorMessage='At least one parameter is provided multiple times.';
    return;
end

%%% Below, test validity of parameter names. Errors here will be collected 
%%% and thrown as a whole.

% Extracting var names provided (i.e. ignoring validity test functions 
% until later)
obligNames={};
optNames={};
for k=1:length(obligArgs)
    if iscell(obligArgs{k})
        obligNames{end+1}=obligArgs{k}{1};
    else
        obligNames{end+1}=obligArgs{k};
    end
end
for k=1:length(optArgs)
    if iscell(optArgs{k})
        optNames{end+1}=optArgs{k}{1};
    else
        optNames{end+1}=optArgs{k};
    end
end

%%% All temporary variables must be deleted now. Anything in workspace
%%% after pvpmod is called is interpreted as coming from varargin!
%%% (save obligNames and optNames).

clear k;
clear argNames;

% loading vars into workspace
pvpmod(varargin);

% retrieving obligatory arguments passed in varargin (+ possibly undefined
% ones)
inObligNames=setxor(who,union({'varargin','obligNames','optNames',...
                    'obligArgs','optArgs'},optNames));

missingNames=obligNames(not(ismember(obligNames,inObligNames)));
missingString=[];
varsMissing=false;
if (~isempty(missingNames))
    %is there no elegant way to convert a cell array of strings to a single
    %string with separating blanks?
    for i=1:length(missingNames)
        missingString=[missingString ' ' missingNames{i} ';'];
    end
    [missingString,err]=sprintf('Missing input variable(s):%s',missingString);
    varsMissing=true;
end

undefinedNames=setxor(union(union(inObligNames,optNames),obligNames),...
                      union(optNames,obligNames));
undefinedString=[];
varsUnknown=false;
if (~isempty(undefinedNames)) 
    for i=1:length(undefinedNames)
        undefinedString=[undefinedString ' ' undefinedNames{i} ';'];
    end
    [undefinedString,err]=sprintf('Unkown input variable(s):%s',undefinedString);
    varsUnknown=true;
end


allArgs={obligArgs{:},optArgs{:}};


% checking if provided values are valid

% first, collecting args that have function handles set for that
checkArgs={};
for k=1:length(allArgs)
    if length(allArgs{k})==2
        checkArgs{end+1}=allArgs{k};
    end
end

invalidString='';
valuesInvalid=false;
for i=1:length(checkArgs)
   checkFuHandle=checkArgs{i}{2};
   checkedVarName=checkArgs{i}{1};
   if exist(checkedVarName,'var') % has been provided by pvpmod(varargin)?
       if ~(checkFuHandle(eval(checkedVarName)))
           invalidString=[invalidString ' ' checkedVarName ';'];
           valuesInvalid=true;
       end
   end
end
if valuesInvalid
   [invalidString,err]=sprintf('Invalid value(s) provided for:%s',invalidString);
end

errorMessage=[];
if varsMissing||varsUnknown||valuesInvalid
    if varsMissing
       errorMessage=[errorMessage missingString '\n '];
    end
    if varsUnknown
       errorMessage=[errorMessage undefinedString '\n '];
    end
    if valuesInvalid
       errorMessage=[errorMessage invalidString '\n '];
    end
end
