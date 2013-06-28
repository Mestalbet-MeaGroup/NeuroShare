function uw = UEMWASetParameters(Tslidms,significance,...
                                 complexity,...
                                 UEMethod,...
                                 Wildcard,...
                                 WindowShift,...
                                 TimeUnits,...
                                 BinsizeInTimeUnits,...
                                 TrialLengthInBins,...
                                 Compatibility,...
                                 NShuffleElements,...
                                 NMCSteps,...
                                 gen_case,...
                                 ScratchDirName,...
                                 NumberOfJobs,...
                                 ParallelMode,...
                                 NumberOfProcessors,...
                                 AutomaticDelete,...
                                 NicePriority,...
                                 RandomizeWindows)

% sets parameters for UEMWA-analysis
% ***************************************************************
% *                                                             *
% * Usage:           COMMENT !!!!!!!!!!                         *
% *                                                             *
% * Options:                                                    *
% *                                                             *
% *         UEPosition:  'left' (default), 'center'             *
% *                 Position of ue time index in analysis bin   *
% *                 (BINSIZE). Be careful in changing this      *
% *                 option. Plot functions and further analysis *
% *                 may depend on it.                           *
% *         UEMWAWrapAround: 'off' (default), 'onIDLVersion'    *
% *                 should be 'off'. 'onIDLVersion' for         *
% *                 compatibility with older versions.          *
% *                                                             *
% * Input:                                                      *	
% *                                                             *
% *         Tslidms:      width of the analysis with a sliding  *
% *                       window in ms                          *
% *         significance: threshold for Unitary Events          *
% *                       in sliding window analysis            *
% *         complexity:   minimal complexity of patterns taken  *
% *                       into consideration                    *  
% *         UEMethod:     analysis method                       *
% *         Wildcard:     wildcard for analysis method          *
% *         WindowShift:  shifting width of analysis window     *
% *         Cut.Parameters.TimeUnits                            *
% *         Bin.Results.BisizeInTimeUnits                       *
% *         Bin.Results.TrialLengthInBins                       *
% *         DataFile.GeneralOptions.Compatibility               *
% *         NShuffleElements: CSR parameter                     *
% *         NMCSteps        :  "      "                         *
% *         gen_case        :  "      "                         *
% *         ScratchDirName  : Parallelization parameter         *
% *         NumberOfJobs    :         "           "             *
% *         ParallelMode    :         "           "             *
% *         PPMakeMP        :         "           "             *
% *                                                             *
% * Output:                                                     *
% *                                                             *
% *         structure uw with fields:                           *
% *                                                             *
% *         uw.Results.WrapAround                               *
% *         uw.Results.WindowWidthInMS                          *
% *         uw.Results.WindowWidthInTimeUnits                   *
% *         uw.Results.WindowWidthInSec                         *
% *         uw.Results.Alpha                                    *
% *         uw.Results.Complexity                               *
% *         uw.Results.WindowWidthInBins                        *
% *         uw.Results.ResLocOffset                             *
% *         uw.Results.NumberOfWindows                          *
% *         uw.Results.WindowBinsLeft                           *
% *         uw.Results.WindowBinCenter                          *
% *         uw.Results.WindowBinsRight                          *
% *         uw.Results.WindowBinIndices                         *
% *         uw.Results.BinLossLeftInTimeUnits                   *
% *         uw.Results.BinLossRightInTimeUnits                  *
% *         uw.Results.UEPosition                               *
% *         uw.Results.UEMethod                                 *
% *         uw.Results.Wildcard                                 *
% *         uw.Results.NShuflleElements                         *
% *         uw.Results.NMCSteps                                 *
% *         uw.Results.gen_case                                 *
% *         uw.Results.WindowShift                              *
% *         uw.Results.ScratchDirName                           *
% *         uw.Results.NumberOfJobs                             *
% *         uw.Results.ParallelMode                             *
% *         uw.Results.PPMakeMP                                 *
% *                                                             *
% * Uses:   uses only builtin functions                         *
% *                                                             *
% * History:                                                    * 
% *                                                             *
% *     UEMWASetParameters consists of firts part of original   *
% *     UEMWA.m                                                 *  
% *                                                             *
% *         (4) introduced parallelization parameters           *
% *            PM, 18.9.02, Goettingen                          *
% *         (3) introduced CSR parameters and UEMWA WindowShift *
% *            PM, 14.9.02, FfM                                 *
% *         (2) implemeted new Version of UEcore() with         *
% *             UEMethod and Wildcard                           *
% *            PM, 1.8.02, FfM                                  *
% *         (1) replaced GeneralOptions by Compatibility in     *
% *             function call                                   *
% *            PM, 11.3.02, FfM                                 *
% *         (0) splitting of original UEMWA.m                   *
% *            PM, 20.2.02, FfM                                 *
% *                                                             *
% * History of original UEMWA.m                                 *
% *                                                             *
% *         (8) wrap around option added. UE_core forced to     *
% *             return full statistics.                         *
% *            MD, 29.7.97, Jerusalem                           * 
% *         (7) Tslid argument now in ms                        *
% *            MD, 27.5.97, Jerusalem                           *
% *         (6) version 5 matrix operations                     *
% *            MD, 4.5.97, Freiburg                             *
% *         (5) ijk interface to pat2cell introduced,           *
% *             UEMWA_Mat no longer needed here                 *
% *            MD, 2.4.1997, Freiburg                           *
% *         (4) commented                                       *
% *            SG, 11.3.1997, Jerusalem                         *
% *         (3) commented                                       *
% *            MD, 3.3.1997, Freiburg                           *
% *         (2) test version for new core                       *
% *            MD, 24.2.1997, Jerusalem                         *
% *         (1) made faster                                     *
% *            SG, 25.8.1996                                    *
% *         (0) first version                                   *
% *            SG, 12.3.96                                      * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% *                                                             *
% * To Do:                                                      *
% * 1.  Split structure uw into uw.results and uw.parameters    *
% *     This function schould only set uw.parameters            *
% *     (as function name implies)                              *
% * 2.  uw.Results.UEPosition and uw.Results.WrapAround are     *
% *     general Parameter and should therefore not be set       *
% *     inside this "subroutine", but at the beginning of the   *
% *     UE Programm                                             *
% ***************************************************************

% GeneralOptions no longer used PM 11.3.2002
%global GeneralOptions; namespace(GeneralOptions);
%checkstruct(GeneralOptions,{'Compatibility';'TimeDisplayMode'});


uw.Results.UEPosition      = 'left';  % 'center', but do not change !

switch Compatibility
 case 'IDLVersion'
  uw.Results.WrapAround = 'onIDLVersion';
 otherwise
  uw.Results.WrapAround = 'off';
end

disp('UEMWA-set-parameters ...')


% ****************************************
% *                                      *
% * convert window size Tslidms in ms to *
% * window size Tslid in time units      *
% *                                      *
% ****************************************

uw.Results.WindowWidthInMS = Tslidms;

uw.Results.WindowWidthInTimeUnits = ...
    uw.Results.WindowWidthInMS/...
    TimeUnits;

if uw.Results.WindowWidthInTimeUnits-floor(uw.Results.WindowWidthInTimeUnits)~=0
 error('UEMWA::WindowSizeNotIntegerMultipleTimeUnits');
end

% ****************************************
% *                                      *
% *  filling globalUEMWA                 *
% *  with analysis constants             *
% *                                      *
% ****************************************

uw.Results.Alpha         = significance;
uw.Results.Complexity    = complexity;
uw.Results.UEMethod      = UEMethod;
uw.Results.Wildcard      = Wildcard;


% ****************************************
% *                                      *
% *  transform width of sliding window 	 *
% *  in units of number of bins          *
% *                                      *
% ****************************************

uw.Results.WindowWidthInBins = ...
                uw.Results.WindowWidthInTimeUnits/...
		BinsizeInTimeUnits;
if uw.Results.WindowWidthInBins-floor(uw.Results.WindowWidthInBins)~=0
 error('UEMWA::WindowSizeNotIntegerMultipleBinSize');
end

% ****************************************
% *                                      *
% * Tslid   -  window width              *
% * N_Tslid -  total number of windows   *
% *                                      *
% ****************************************

switch  uw.Results.WrapAround
 case 'off'
  N_Tslid = floor((TrialLengthInBins-uw.Results.WindowWidthInBins+1)/...
                   WindowShift);
 case 'onIDLVersion'
  N_Tslid = floor(TrialLengthInBins/WindowShift);
 otherwise
  error('UEMWA::UnknownWrapAroundOption');
end


% PM: the following parameters from now on get initialized in UEMWACollect Data

%% all results per t_slid
%uw.Results.UEmwaResults = ...
% zeros(b.Results.TrialLengthInBins,12,r.Results.NumberOfPatterns);
%
%
%% **********************************************
%% 
%% RATE 
%%
%
%uw.Results.UEmwaRates = ...
%    zeros(b.Results.TrialLengthInBins,c.Results.NumberOfNeurons);
%
%% indices of unitary events; each column for one pattern
%uw.Results.Data = cell(r.Results.NumberOfPatterns,1);
%
%
%uw.Results.PatI = [];
%uw.Results.PatJ = [];
%uw.Results.PatK = [];

% end of PM:

% **************************************************************
% * prepare window positions                                   *
% *                                                            *
% * (1) new [,) definition of moving window                    *
% *                                                            *
% * (2) IDL Version                                            *
% *                                                            *
% * in our language the IDL definition of the relative         *
% * window bin indices is:                                     *
% *                                                            *
% *  1 +   0:(UEMWAWindowWidthInTimeUnits-1)                   *
% *        - round(UEMWAWindowWidthInTimeUnits/2)              *
% *                                                            *
% * "add_index_arr           = $                               *
% *     lindgen(analys_bin) $                                  *
% *        - ROUND(analys_bin/DOUBLE(2)) + 1 + part_pos"       *
% *  See make_single_part_idx.pro                              *
% *                                                            *
% * Examples:                                                  *
% *    window width 11:  =>  1 + 0:(11-1) - round(11/2)        *
% *                      =>  1:11         - 6                  *
% *                      => -5 -4 -3 -2 -1 0 1 2 3 4 5         *
% *                                                            *
% *    window width 10   =>  1:10         - 5                  *
% *                      =>  -4 -3 -2 -1 0 1 2 3 4 5           *
% *                                                            *
% * This equivalent to our Compatibility Mode                  *
% * 'IDLVersion' because:                                      *
% *                                                            *
% *               1 - round(x/2)                               *
% *            == 1 - floor((x/2)+0.5)                         *
% *            == 1 - floor((x+1)/2)                           *
% *            ==   - floor((x+1)/2 -1)                        *
% *            ==   - floor((x+1-2)/2)                         *
% *            ==   - floor((x-1)/2);                          *
% *                                                            *
% * Examples:                                                  *
% *   -floor((11-1)/2) == -floor(5)   == -5                    *
% *   -floor((10-1)/2) == -floor(4.5) == -4                    *
% *                                                            *
% *                                                            *
% **************************************************************

switch  uw.Results.WrapAround
 case 'off'
  dl=0;
  dm=floor(uw.Results.WindowWidthInBins/2);   % floor((Tslid-1)/2)
  dr=uw.Results.WindowWidthInBins - 1;
  dlr=dl:dr;
  uw.Results.BinLossLeftInBins  = dm;
  uw.Results.BinLossRightInBins = uw.Results.WindowWidthInBins-dm-1;
 case 'onIDLVersion'
  dl=-floor((uw.Results.WindowWidthInBins-1)/2);
  dm=0;
  dr=dl+uw.Results.WindowWidthInBins-1;
  dlr=dl:dr;
  uw.Results.BinLossLeftInBins = 0;
  uw.Results.BinLossRightInBins= 0;
 otherwise
  error('UEMWA::UnknownWrapAroundOption');
end

uw.Results.ResLocOffset     = dm;
uw.Results.NumberOfWindows  = N_Tslid;

% indices of Window bins relativ to window
% position index (leftmost bin)
%
uw.Results.WindowBinsLeft   = dl;
uw.Results.WindowBinCenter  = dm;
uw.Results.WindowBinsRight  = dr;
uw.Results.WindowBinIndices = dlr;

%
% depending on moving method (wrap-around or )
% loss of bins on the two sides of the data
% segments
%

uw.Results.BinLossLeftInTimeUnits  = ...
    uw.Results.BinLossLeftInBins  * BinsizeInTimeUnits;
uw.Results.BinLossRightInTimeUnits = ...
    uw.Results.BinLossRightInBins * BinsizeInTimeUnits;   

% new: WindowWidthInSec

uw.Results.WindowWidthInSec = ...
     uw.Results.WindowWidthInBins ...
   * BinsizeInTimeUnits ...
   * TimeUnits ...
   / 1000;

% set CSR parameters

uw.Results.NShuffleElements = NShuffleElements;
uw.Results.NMCSteps         = NMCSteps;
uw.Results.gen_case         = gen_case;

% set shift of analysis window

uw.Results.WindowShift = WindowShift;

% set parallelization parameters

uw.Results.ScratchDirName     = ScratchDirName;
uw.Results.NumberOfJobs       = NumberOfJobs;
uw.Results.ParallelMode       = ParallelMode;
uw.Results.NumberOfProcessors = NumberOfProcessors;
uw.Results.AutomaticDelete    = AutomaticDelete;
% MSK ---------------------------------------------------------------------
uw.Results.NicePriority       = NicePriority;
uw.Results.RandomizeWindows   = RandomizeWindows;
% -------------------------------------------------------------------------
