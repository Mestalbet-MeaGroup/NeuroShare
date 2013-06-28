function startue(varargin)
% function startue(varargin)
% *******************************************************
% *                                                     *
% * Start Unitary Events                                *
% *                                                     *
% * Usage: 1) call function with no input argument:     *
% *                                                     *
% *           Starts UE with graphical user interface   *
% *                                                     *
% *        2) call function with valid parameter or     *
% *           batch file:                               *
% *                                                     *
% *           Starts UE analysis without graphical      *
% *           user interface and performs analysis      *
% *           as specified in input file.               *
% *           The input file must contain a valid       *
% *           DataFile structure as can be created by   *
% *           "Saving Parameters to File" in graphical  *
% *           mode. The input file can also be a valid  *
% *           batch file obtained by "Saving Batch      *
% *           Script to File" in batch mode             *
% *                                                     *
% * Input: varargin{1} (optional)                       *
% *        mat file containing DataFile structure       *
% *                                                     *
% * Uses:  UESetup(), UEMainparallel()                  *
% *                                                     *
% * Tip:  It is recommended for serious analysis that   *
% *       You first create the parameter setting        *     
% *       and/or batch file in graphical mode and save  *
% *       it to a file and then call startue with this  *
% *       file.                                         *
% *                                                     *
% * History: 1) first version                           *
% *             PM, 23.8.02, FfM                        *
% *                                                     *
% *******************************************************

% in debugging, 16.5.2003, Diesmann
% I changed access of varargin by varargin{i}
% to varargin(i).

if nargin == 0
    UESetup;
else
    DataFile = [];
    load(varargin(1)); %eval(['load ' varargin{1}]);
    if ~isempty(DataFile)
       % Start UE analysis
       UEMain(DataFile)
    else
       information(['Could not load valid DataFile structure from' ...
                    varargin(1)]);
       drawnow;
    end
end
