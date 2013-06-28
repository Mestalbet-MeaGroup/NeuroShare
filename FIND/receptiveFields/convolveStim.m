function linearPart=convolveStim(varargin)
% convolves the stimulus with the linear filter and returns a kind of rate
% function
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%   stim=matrix of stimulus
%   linerFilter=matrix of linear filter
%
%
%
%
%
% Henriette Walz 05/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%

% obligatory argument names
obligatoryArgs={'stim','linearFilter'};         

% optional arguments names with default values
optionalArgs={'center'};
center=[];

% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end


% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

if ~isempty(center)
    tmp_stim=reshape(stim,[size(stim,1) sqrt(size(stim,2)) sqrt(size(stim,2))]);
    tmp_stim=tmp_stim(:,center(1)-2:center(1)+2,center(2)-2:center(2)+2);
    stim=reshape(tmp_stim,[size(tmp_stim,1) size(tmp_stim,2)^2]);
end

sta_s=size(linearFilter);
stim_s=size(stim);
linearPart=conv2([zeros(sta_s(1)-1,stim_s(2));stim],flipud(fliplr(linearFilter)),'valid');

disp('done convolving linear filter with stimulus');





