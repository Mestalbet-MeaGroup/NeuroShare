function UEMainAnalyseWindow(scratchdirname,jobid,varargin)
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% Input: scratchdirname: Path, where to read input data 
%                        and write results to
%        jobid:          ID of Job, that call this Analysis
%                        from the Makefile
%        varargin:       position1 position1 .....
%                        (String containing all position
%                        on which analysis should be performed

% load AnalysisInputData that was saved in UEMain

% MSK ---------------------------------------------------------------------
% loadfilename = [scratchdirname 'AnalysisInputData.mat'];
loadfilename = 'AnalysisInputData.mat';
% -------------------------------------------------------------------------

load(loadfilename);

% create array in which all positions of the windows are stored

PositionArray = [];

% perform loop over all input positions

for ii=1:(nargin - 2)

    position = str2num(varargin{ii});

    % cut window ii at position out of binned Data 
        
    Window = UEMWACutAnalysisWindow(ii,...
                                position,...
                                AnalysisInputData.WindowBinCenter,...
                                AnalysisInputData.WindowBinIndices,...
                                AnalysisInputData.WrapAround,...
                                AnalysisInputData.TrialLengthInBins,...
                                AnalysisInputData.Cell);
        
    % perform analysis in window at position
        
    UEMWAResults(ii) = UEMWAAnalyseWindow(AnalysisInputData.Alpha,...
                            AnalysisInputData.Complexity,...
                            AnalysisInputData.UEMethod,...
                            AnalysisInputData.Wildcard,...
                            AnalysisInputData.Basis,...
                            AnalysisInputData.ExistingPatterns,...
                            Window,...
                            AnalysisInputData.NShuffleElements,...
                            AnalysisInputData.NMCSteps,...
                            AnalysisInputData.gen_case);
                        
    % add position to PositionArray
    
    PositionArray = [PositionArray position];
                  
end

% save UEinMW's of windows in file 

savefilename  = [scratchdirname 'UEResultsOfJob' jobid '.mat' ];
save(savefilename,'UEMWAResults','PositionArray');
