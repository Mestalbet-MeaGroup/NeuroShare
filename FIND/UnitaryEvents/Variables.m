%
% Variables.m
%
%DataFile(1).Analysis.Alpha      = 0.05;    	% Significance threshold level
%DataFile(1).Analysis.Complexity = 2;	   	% min. number of spikes
%DataFile(1).Analysis.Binsize    = 5;       	% coincidence resolution (in ms)
%DataFile(1).Analysis.TSlid      = 100;	   	%

% *          c.Parameters.NeuronList
% *          c.Parameters.EventList
% *          c.Parameters.CutEvent
% *          c.Parameters.TPre
% *          c.Parameters.TPost
% *          c.Parameters.TimeUnits
% *          c.Parameters.TrialOverlapMode
% *          c.Results.FileName
% *          c.Results.Data
% *          c.Results.EventData
% *          c.Results.SpikeDataFormat
% *          c.Results.IdExistList
% *          c.Results.PostCutInTimeUnits
% *          c.Results.PreCutInTimeUnits
% *          c.Results.TrialLengthInTimeUnits
% *          c.Results.TrialLengthInMS
% *          c.Results.TrialReductionMode
% *          c.Results.NumberOfNeurons
% *          c.Results.NumberOfEvents
% *          c.Results.NumberOfTrials
% *          c.Results.TrialList
% * bin
% *        bb.Results.BinsizeInTimeUnits                        *
% *        bb.Results.BinsizeInMS                               *
% *        bb.Results.TrialLengthInBins                         *
% *        bb.Results.TrialLengthInTimeUnits                    *
% *        bb.Results.TrialLengthInMS                           *
% *        bb.Results.Data                                      *
% *        bb.Results.Cell                                      *
% *        bb.Results.Basis                                     *
% *
% BinWorkCell 	          = bb.Results.Cell;
%BIN_TRIAL_LENGTH          = bb.Results.TrialLengthInBins;
%BINSIZE 	          = bb.Results.BinsizeInTimeUnits;
%BinBasis 	          = bb.Results.Basis;
%BinsizeInTimeUnits        = bb.Results.BinsizeInTimeUnits; 
%BinsizeInMS               = bb.Results.BinsizeInMS;
%BinTrialLengthInBins      = bb.Results.TrialLengthInBins;
%BinTrialLengthInTimeUnits = bb.Results.TrialLengthInTimeUnits;
%BinTrialLengthInMS        = bb.Results.TrialLengthInMS;


%
% delete this block when it is obsolete
%
FILENAME	= c.Results.FileName; 
TIME_UNITS	= c.Parameters.TimeUnits;
TimeUnits       = c.Parameters.TimeUnits;
ID_EXIST_LIST 	= c.Results.IdExistList;
T_POST_CUT 	= c.Results.PostCutInTimeUnits;
T_PRE_CUT  	= c.Results.PreCutInTimeUnits;
TRIAL_LENGTH    = c.Results.TrialLengthInTimeUnits;
NEURON_LIST	= c.Parameters.NeuronList;
N_NEURON	= c.Results.NumberOfNeurons;
EVENT_LIST      = c.Parameters.EventList;
N_EVENT         = c.Results.NumberOfEvents;
CUT_EVENT_LIST	= c.Parameters.CutEvent;

%
% delete when obsolete
%
N_TRIAL      = c.Results.NumberOfTrials;

%
% delete this block when it is obsolete
%
TrialLengthInTimeUnits    = c.Results.TrialLengthInTimeUnits;
TrialLengthInMS           = c.Results.TrialLengthInMS;   
TrialList                 = c.Results.TrialList;    



%%%%%%% delete this when it is obsolete%%%%%%%%%%
% this fills globalBin
BinWorkCell 	          = bb.Results.Cell;
BIN_TRIAL_LENGTH          = bb.Results.TrialLengthInBins;
BINSIZE 	          = bb.Results.BinsizeInTimeUnits;
BinBasis 	          = bb.Results.Basis;

BinsizeInTimeUnits        = bb.Results.BinsizeInTimeUnits; 
BinsizeInMS               = bb.Results.BinsizeInMS;
BinTrialLengthInBins      = bb.Results.TrialLengthInBins;
BinTrialLengthInTimeUnits = bb.Results.TrialLengthInTimeUnits;
BinTrialLengthInMS        = bb.Results.TrialLengthInMS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% delete when obsolete
UESignificance = u.Results.Alpha;
 % will be obsolete soon
 N_PATTERN = r.Results.NumberOfPatterns;
 PAT_EXIST = r.Results.ExistingPatterns;
 RawMat    = r.Results.Mat;
 RawCell   = r.Results.Data;
 RawPatI   = r.Results.PatI;
 RawPatJ   = r.Results.PatJ;
 RawPatK   = r.Results.PatK;
UE_RES  = u.Results.UEresults;
 UEMAT   = u.Results.UEmat;
 UECell  = u.Results.Data;
 UEPatI  = u.Results.PatI;
 UEPatJ  = u.Results.PatJ;
 UEPatK  = u.Results.PatK;

 % will be obsolete soon
 N_PATTERN = r.Results.NumberOfPatterns;
 PAT_EXIST = r.Results.ExistingPatterns;
 %RawMat    = r.Results.Mat;
 RawCell   = r.Results.Data;
 RawPatI   = r.Results.PatI;
 RawPatJ   = r.Results.PatJ;
 RawPatK   = r.Results.PatK;
 
 UE_RES  = u.Results.UEresults;
 UEMAT   = u.Results.UEmat;
 UECell  = u.Results.Data;
 UEPatI  = u.Results.PatI;
 UEPatJ  = u.Results.PatJ;
 UEPatK  = u.Results.PatK;



% delete when obsolete

UEMWAWrapAround              = uw.Results.WrapAround;
UEMWAWindowWidthInBins       = uw.Results.WindowWidthInBins;

UEMWASignificance            = uw.Results.Alpha;
UEMWAComplexity              = uw.Results.Complexity;
UEMWA_Tslid	             = uw.Results.WindowWidthInTimeUnits;

UEMWAWindowWidthInMS         = uw.Results.WindowWidthInMS;
UEMWAWindowWidthInTimeUnits  = uw.Results.WindowWidthInTimeUnits;


UEMWA_Mat                    = uw.Results.Data;
UEMWA_Cell                   = uw.Results.Data;
UEMWA_Res                    = uw.Results.UEmwaResults;
UEMWARates                   = uw.Results.UEmwaRates;
UEMWAPatI                    = uw.Results.PatI; 
UEMWAPatJ                    = uw.Results.PatJ;
UEMWAPatK                    = uw.Results.PatK; 


UEMWABinLossLeftInBins       = uw.Results.BinLossLeftInBins;
UEMWABinLossRightInBins      = uw.Results.BinLossRightInBins;
UEMWAResLocOffset            = uw.Results.ResLocOffset;
UEMWA_NTslid                 = uw.Results.NumberOfWindows;
UEMWANumberOfWindows         = uw.Results.NumberOfWindows;

UEMWAWindowBinsLeft          = uw.Results.WindowBinsLeft;
UEMWAWindowBinCenter         = uw.Results.WindowBinCenter;
UEMWAWindowBinsRight         = uw.Results.WindowBinsRight;
UEMWAWindowBinIndices        = uw.Results.WindowBinIndices;

UEMWABinLossLeftInTimeUnits  = uw.Results.BinLossLeftInTimeUnits;
UEMWABinLossRightInTimeUnits = uw.Results.BinLossRightInTimeUnits;


%              xust.Title         = WorkTitle;
%  xust.NumberOfPlots = NWorkMat;
%  xust.YLabel        = WorkYLabel;
%  xust.YTickLabels   = WorkYTickLabels;
%  xust.XTickLabels   = WorkXTickLabels;
%  xust.XLabel 	     = WorkXLabel;
%  xust.XTicksInTimeUnits = WorkXTicks; 
%  xust.TimeUnit	     = WTimeUnit;
%  xust.TrialLengthInTimeUnits  = WNBins;
%  xust.NumberOfLines = WNLines;
%  xust.Data1         = WorkMat;
%  xust.Data2         = WorkMat2;
%  xust.MarkTimesInTimeUnits = TimeIntervalInTimeUnits;     
%  xust.TimeAxisInTimeUnits  = TimeAxisInTimeUnits;
%  xust.BinsizeInTimeUnits   = b.Results.BinsizeInTimeUnits;  % new
%  xust.MarkTimesInBins      = BinWorkTimes;
%  xust.TrialLengthInBins    = BinWNBins
%  xust.XTicksInBins         = BinWorkXTicks;
%  xust.XTickLabelsForBins   = BinWorkXTickLabels;






% *          raw data:                                          *
% *             r.Results.NumberOfPatterns                      *
% *             r.Results.ExistingPatterns                      *
% *             r.Results.Mat                                   *
% *             r.Results.Data                                  *
% *             r.Results.PatI                                  *
% *             r.Results.PatJ                                  *
% *             r.Results.PatK                                  *
% *        ue-data of the whole data piece                      *
% *             u.Results.UEresults                             *
% *             u.Results.UEmat                                 *
% *             u.Results.Data                                  *
% *             u.Results.PatI                                  *
% *             u.Results.PatJ                                  *
% *             u.Results.PatK                                  *
% *              u.Results.Alpha
% *             u.Results.Complexity

% delete when obsolete

UEMWAWrapAround              = uw.Results.WrapAround;
UEMWAWindowWidthInBins       = uw.Results.WindowWidthInBins;

UEMWASignificance            = uw.Results.Alpha;
UEMWAComplexity              = uw.Results.Complexity;
UEMWA_Tslid	             = uw.Results.WindowWidthInTimeUnits;

UEMWAWindowWidthInMS         = uw.Results.WindowWidthInMS;
UEMWAWindowWidthInTimeUnits  = uw.Results.WindowWidthInTimeUnits;


UEMWA_Mat                    = uw.Results.Data;
UEMWA_Cell                   = uw.Results.Data;
UEMWA_Res                    = uw.Results.UEmwaResults;
UEMWARates                   = uw.Results.UEmwaRates;
UEMWAPatI                    = uw.Results.PatI; 
UEMWAPatJ                    = uw.Results.PatJ;
UEMWAPatK                    = uw.Results.PatK; 


UEMWABinLossLeftInBins       = uw.Results.BinLossLeftInBins;
UEMWABinLossRightInBins      = uw.Results.BinLossRightInBins;
UEMWAResLocOffset            = uw.Results.ResLocOffset;
UEMWA_NTslid                 = uw.Results.NumberOfWindows;
UEMWANumberOfWindows         = uw.Results.NumberOfWindows;

UEMWAWindowBinsLeft          = uw.Results.WindowBinsLeft;
UEMWAWindowBinCenter         = uw.Results.WindowBinCenter;
UEMWAWindowBinsRight         = uw.Results.WindowBinsRight;
UEMWAWindowBinIndices        = uw.Results.WindowBinIndices;

UEMWABinLossLeftInTimeUnits  = uw.Results.BinLossLeftInTimeUnits;
UEMWABinLossRightInTimeUnits = uw.Results.BinLossRightInTimeUnits;









