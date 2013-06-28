function SaveFileNameMat  = SaveResults(d,c,b,r,uw,psth)
% SaveFileNameMat=SaveResults(d,c,b,r,uw,psth): save results in various files 
% ***********************************************************************
% *                                                                     *
% * Input: structures containing results from different levels          *
% *        of analysis:                                                 *
% *                                                                     *
% *        d:    DataFile-structure                                     *
% *        c:    Cut-structure                                          *
% *        b:    Bin-structure                                          *
% *        r:    Raw-structure                                          *
% *        uw:   UEmwa-structure                                        *
% *        psth: Psth-structure                                         *
% *                                                                     *
% * Output:                                                             *
% *        1) write all data in a .mat file:                            *
% *                                                                     *
% *           SaveFileNameMat = [d.OutPath d.FileName '.mat'];          *
% *           eval(['save ' SaveFileNameMat  ' d, c, b, r, uw, psth' ]) *
% *                                                                     *
% *        2) write time axis and rates:                                *
% *                                                                     *
% *           SaveNameRates = [d.OutPath d.FileName 'Rates.mat'];       *
% *           with ratemat = ...                                        *
% *             [TimeCenterRangeInTimeUnits'                            *
% *             psth.Results.Mat(TimeIndexRangeInTimeUnits,i)];         *
% *           with i neuron index                                       *
% *                                                                     *
% *        3) write per pattern, results:                               *
% *                                                                     *
% *           slidwinaxis actCoincRate expCoincRate jp js ue_p ue_n     *
% *           SaveNamePat = [d.OutPath d.FileName patString '.mat'];    *
% *           resultmatrix = [BinCenterRangeInTimeUnits' ...            *
% *                           uw.Results.UEmwaResults(:,11,pat_idx) ... *
% *                           uw.Results.UEmwaResults(:,12,pat_idx) ... *
% *                           uw.Results.UEmwaResults(:,6,pat_idx) ...  *
% *                           uw.Results.UEmwaResults(:,9,pat_idx) ...  *
% *                           uw.Results.UEmwaResults(:,7,pat_idx) ...  *
% *                           uw.Results.UEmwaResults(:,8,pat_idx)];    *
% *                                                                     *
% *                                                                     *
% * See also: SignPlot.m                                                *
% *                                                                     *
% * Uses:     XustFilter(), inv_hash()                                  *
% *                                                                     *
% * Example:  SaveResults(DataFile(i),Cut,Bin,Raw,UEmwa,Psth)           *
% *                                                                     *
% * History :                                                           *
% *           (2) Function does now save all variables in .mat files.   *
% *               (Compiler does not support save to .asc files)        *
% *               Original version is still available:                  *
% *               SaveResultsASCII.m                                    *
% *              PM, 10.9.02, FfM                                       *
% *           (1) removed all global variables                          *
% *              PM, 6.8.02, FfM                                        *
% *           (0) first version                                         *
% *              SG, 3.10.97, Marseille                                 *
% *                                                                     *
% ***********************************************************************

%******************************************
%*  write all structures in mat-file      *
%******************************************

%**************************************
%*  create strings for output name    *
%**************************************

% save to file name

SaveFileNameMat = [d.OutPath d.OutFileName '.mat'];

save(SaveFileNameMat,'d','c','b','r','uw','psth');
%eval(['save ' SaveFileNameMat  ' d, c, b, r, uw, psth' ]);

%******************************************
%
% write results in ascii files
%
%******************************************

% ********************************
% compute time and bin axis
% ********************************


% ********************************
% code for time and bin axis
%  copied from SignPlot.m
% 
sp = XustFilter(uw,r,b,c,'ue_bin');
TimeIndexRangeInTimeUnits  =  (psth.Results.LossLeftInTimeUnits+1)...
                             :(b.Results.TrialLengthInTimeUnits-...
			       psth.Results.LossRightInTimeUnits);
TimeCenterRangeInTimeUnits = TimeIndexRangeInTimeUnits;

if isodd(psth.Results.WindowWidthInTimeUnits)
switch d.GeneralOptions.TimeDisplayMode
 case 'discrete'
  % nothing to do
 case 'real'
  TimeCenterRangeInTimeUnits=TimeCenterRangeInTimeUnits + 0.5;
 otherwise
  error('SaveResults::UnknownTimeMode');
 end
end

BinRange =  (uw.Results.BinLossLeftInBins+1)...
           :(b.Results.TrialLengthInBins-...
	          uw.Results.BinLossRightInBins);

BinCenterRangeInTimeUnits = ...
                (uw.Results.BinLossLeftInTimeUnits+1)...
                :b.Results.BinsizeInTimeUnits...
                :(b.Results.TrialLengthInTimeUnits-...
		             uw.Results.BinLossRightInTimeUnits);

if isodd(uw.Results.WindowWidthInBins)
 switch d.GeneralOptions.TimeDisplayMode
  case 'discrete'
   BinCenterRangeInTimeUnits = BinCenterRangeInTimeUnits + ...
                               floor(b.Results.BinsizeInTimeUnits/2);
  case 'real'
   BinCenterRangeInTimeUnits = BinCenterRangeInTimeUnits + ...
                               b.Results.BinsizeInTimeUnits/2;
  otherwise
   error('SaveResult::UnknownTimeMode');
 end
end


TimeIntervalInTimeUnits    = sp.MarkTimesInTimeUnits;

TimeCenterRangeInTimeUnits = TimeIntervalInTimeUnits(1)+ ...
                                   TimeCenterRangeInTimeUnits -1;  
BinCenterRangeInTimeUnits  = TimeIntervalInTimeUnits(1)+ ...
                                   BinCenterRangeInTimeUnits  -1;  

%
% code from SignPlot.m
%**********************************


%*************************************
% write spike rates in file
%*************************************

SaveNameRates = [d.OutPath d.OutFileName 'Rates.mat'];


   ratemat = [];
   for i=1:c.Results.NumberOfNeurons
    if i==1   
     ratemat = ...
   [TimeCenterRangeInTimeUnits' psth.Results.Mat(TimeIndexRangeInTimeUnits,i)];
    else
     ratemat = ...
      [ratemat psth.Results.Mat(TimeIndexRangeInTimeUnits,i)];
    end
   end

disp(['... save rates to ' SaveNameRates]);
save(SaveNameRates,'ratemat');
%eval(['save -ascii ' SaveNameAscRates  ' ratemat']);

% ***************************************
% *					*
% *    Write Coinc Rates per Pattern    *
% *					*
% ***************************************
basis = 2;

 if isempty(r.Results.ExistingPatterns)
  error('SaveResults::NoPatternExist');
 else
  % extract existing patterns  
  pat = inv_hash(r.Results.ExistingPatterns,c.Results.NumberOfNeurons,basis);

  % reduce to requested complexity
  cpat = sum(pat,2);
  pat_idx = (find(cpat>= d.Analysis.Complexity & cpat <= d.Analysis.ComplexityMax));
  
  for i=1:length(pat_idx)
   % string generation of pattern
     patString ='_sp';
     sel_pat =  pat(pat_idx(i),:); 
     for ii=1:length(sel_pat)
      patString = strcat(patString, int2str(sel_pat(ii)));
     end
     patString;
     SaveNamePat = [d.OutPath d.OutFileName patString '.mat'];

   % timeaxis actCoincRate expCoincRate jp js ue_p ue_n
     resultmatrix = [BinRange' ...
                     uw.Results.UEmwaResults((BinRange),11,pat_idx(i)) ...
                     uw.Results.UEmwaResults((BinRange),12,pat_idx(i)) ...
                     uw.Results.UEmwaResults((BinRange),6,pat_idx(i)) ...
                     uw.Results.UEmwaResults((BinRange),9,pat_idx(i)) ...
                     uw.Results.UEmwaResults((BinRange),7,pat_idx(i)) ...
                     uw.Results.UEmwaResults((BinRange),8,pat_idx(i))];

     disp(['... save results of ' patString ' to ' SaveNamePat]);
     save(SaveNamePat,'resultmatrix');
     %eval(['save -ascii ' SaveNameAscPat  ' resultmatrix']);
     clear resultmatrix;
  end % loop over pattern
end % of if pattern exist


%
% write file with parameters?
%
%
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

% *  Usage:
% * 	input:  d==DataInfo : structure containing Analysis Parameters
% *		           as defined in UEMainPara.m :
% *		DataInfo.FileName	: gdf filename
% *		DataInfo.NeuronList	: list of neurons to analyse
% *		DataInfo.EventList    	: eventlist - not used yet
% *		DataInfo.CutEvent	: event to cut
% *		DataInfo.TPre		: time before cut_event (in ms)
% *		DataInfo.TPost		: time after cut_event  (in ms)
% *		DataInfo.TimeUnits	: time units input data (in ms)
% *		DataInfo.Analysis.Alpha	: Significance threshold level
% *		DataInfo.Analysis.Complexity : min. number of spikes
% *		DataInfo.Analysis.Binsize    : coincidence resolution (in ms)
% *		DataInfo.Analysis.TSlid      : moving window width (in ms)
% *		DataInfo.UEMWAFigure.Display
% *		DataInfo.UEMWAFigure.Device
% *		DataInfo.UEMWAFigure.Name
% *		DataInfo.UEMWAFigure.VerticalLinePos
% *		DataInfo.SignFigure.Display
% *		DataInfo.SignFigure.Device
% *		DataInfo.SignFigure.Name
% *		DataInfo.SignFigure.VerticalLinePos
% *		DataInfo.SignFigure.PatSel
