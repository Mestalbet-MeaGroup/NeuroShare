function S=linearizeStimulus(varargin);
% linearizes stimulus data from x*y*t to (x*y*n)*t with n = memorable
% frames
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'x': The data matrix
%
%'n': number of memorable frames
%

% %%%Optional Parameters%%%%%%%%%%%%
%'idx': here several things can be specified:
%           - 0: the stimulus collection starts at t0, those frames < n are
%           assigned zero
%           - 1: the stimulus collection starts at t==n (default)
%           -idx is a matrix: the stimulus collection is done for times of
%           a spiking neuron
%
%'ifn' : since these stimulus matrices are quite big, ifn specifies if the
%dimensionality should really be mutiplied by the number of memorable
%frames;
%   -default is 0 and the STA is calculated for different points in time
%
%
%
% Henriette Walz 01/08
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%


% obligatory argument names
obligatoryArgs={'x','n','t','frameDuration'};           % 'analogEntityIndex'};

% optional arguments names with default values
optionalArgs={'idx','ifn'};
idx=1;
ifn=0;



% Valid var names provided? Otherwise, error is generated. You can also
% supply functions to test the validity of the values, see checkPVP for
% details.
errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

global nsFile

%check which dimension is the time dimension
nFrames=t/frameDuration;
stim_s=size(x);
if nFrames == stim_s(1)
elseif nFrames == stim_s(3)
    %%convert to t*x*y dimension
    x=shiftdim(x,2);
end



sz = size(x);
n2 = prod(sz(2:end));  % total dimensionality in spatial dimensions

% If necessary, convert x to a 2D matrix
if (n2 > sz(2));       % reshape to matrix if necessary
    x = reshape(x, sz(1), n2);
end

%if necessary scale data

if max(max(x))~=255 | min(min(x))~=0
    uint8(Scale(x,0,255));
end

if ifn
    if idx == 0  % Compute with zero-padding.
        S_temp = zeros(sz(1), n2*n);
        for j=1:n2
            S_temp(:,(n*(j-1)+1):(n*j))=fliplr(toeplitz(x(:, j), [x(1,j) zeros(1,n-1)]));
        end


    elseif idx == 1  % compute only for stimuli at times >= n
        S_temp = zeros(sz(1)-n+1,n2*n);
        for j=1:n2
            S_temp(:,(n*(j-1)+1):(n*j))=fliplr(toeplitz(x(n:sz(1), j), x(n:-1:1,j)));
        end


    end
    S=S_temp;
else
    S=x;
end