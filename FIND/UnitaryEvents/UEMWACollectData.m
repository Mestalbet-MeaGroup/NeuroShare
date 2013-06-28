function UEmwa = UEMWACollectData(ueaw,uw,r,c,b)
% UEmwa = UEMWACollectData(ueaw,uw,r,c,b)
% ***************************************************************
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% *                                                             *
% * Usage:           COMMENT !!!!!!!!!!                         *
% *                                                             *
% * Input:  ueaw: ueaw-structure (Data of analysed window)      *
% *         uw:   uw-structure                                  *         
% *         r:    Raw-structure                                 *
% *         c:    Cut-structure                                 *
% *         b:    Bin-structure                                 *
% *                                                             *
% * Output: structure UEmwa                                     *
% *         uw.Results.SignificantPatterns                      *
% *         uw                                                  *
% *                                                             *
% * Uses:   where()                                             *
% *         wraparound()                                        *
% *         pat2cell()                                          *
% *         pat2cellUEmwa()                                     *
% *                                                             *
% * History:                                                    *
% *                                                             *
% *     UEMWACollectData consists of last part of original      *
% *     UEMWA.m                                                 *  
% *                                                             *
% *         (2) implemented UEMWA Window Shift                  *
% *            PM, 14.9.02, FfM                                 *
% *         (1) splitting of original UEMWA.m                   *
% *            PM, 20.2.2002                                    *
% *                                                             *
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
% ***************************************************************

% list of inputvariables(structuremembers) used in the function:

NumberOfWindows    = uw.Results.NumberOfWindows;
WindowShift        = uw.Results.WindowShift;
WindowWidthInBins  = uw.Results.WindowWidthInBins;
WindowBinsLeft     = uw.Results.WindowBinsLeft;
WrapAroundOption   = uw.Results.WrapAround;
UEPosition         = uw.Results.UEPosition;
NumberOfPatterns   = r.Results.NumberOfPatterns;
ExistingPatterns   = r.Results.ExistingPatterns;
TrialLengthInBins  = b.Results.TrialLengthInBins;
BinsizeInTimeUnits = b.Results.BinsizeInTimeUnits;
NumberOfNeurons    = c.Results.NumberOfNeurons;
TimeUnits          = c.Parameters.TimeUnits;
NumberOfTrials     = c.Results.NumberOfTrials;


disp('UEMWA-collect-Data...')

% Initializing 

% all results per t_slid
uw.Results.UEmwaResults = ...
 zeros(TrialLengthInBins,12,NumberOfPatterns);

% Rates
uw.Results.UEmwaRates = ...
    zeros(TrialLengthInBins,NumberOfNeurons);

% indices of unitary events; each column for one pattern
uw.Results.Data = cell(NumberOfPatterns,1);


uw.Results.PatI = [];
uw.Results.PatJ = [];
uw.Results.PatK = [];

% *****************************************************
% *                                                   *          
% * Collecting - Loop over all Analyse-Window-Results *
% *                                                   *
% *****************************************************

position = 1;

for ii = 1:NumberOfWindows

 ues   = ueaw(ii).ues; 
 it    = ueaw(ii).it;
 bstjk = ueaw(ii).bstjk;

 if ~isempty(ues)

 % ****************************************
 % * find out index of different patterns * 
 % * which occured in this window         *
 % * length(pi)==cols(ues)                *
 % ****************************************
 
 [ip, dummy] = where(ues(1,:),ExistingPatterns);


 % *****************************************
 % * copy statistical values rows 1:6 into *
 % * UEMWA statistics at center of current *
 % * window (tm)                           *
 % *****************************************

% **************************************************************** 
% *           1    2    3    4    pattern index                  *
% *        ---------------------------------->                   *
% *     1  |  hash value of pattern                              *
% *     2  |  number of occurrences                              *
% *     3  |  empirical probability of pattern                   *
% *     4  |  expected probability of pattern                    *
% *     5  |  number of expected occurrences                     *
% *     6  |  joint-p-value                                      *
% *     7  |  1 if is a UE      (jp<=significance), 0 else       *
% * row 8  | -1 if is a neg. UE (jp>=1-significance), 0 else     *
% *     9  |  joint-surprise                                     *
% *     11 |  actual occurrences in rates per second per trial   *
% *     12 |  expected occurrences in rates per second per trial *
% *     .                                                        *
% *     .     currently not used                                 *
% *     .                                                        *
% *    19  |                                                     *
% *    20  | t11  t12               |                            *
% *        | t21  t22               |  times  (row indices       *
% *        | t31                    |  of bst matrix) of         *
% *        | t41    ----------------0  occurrence                *
% *        |                                                     *
% *        v                                                     * 
% **************************************************************** 
  
  uw.Results.UEmwaResults(ueaw(ii).Time,1:6,ip') = ues(1:6,:);
  
  uw.Results.UEmwaResults(ueaw(ii).Wrange,7,ip')= ...
      squeeze( uw.Results.UEmwaResults(ueaw(ii).Wrange,7,ip')) + ...
      repmat(ues(7,:),WindowWidthInBins,1);
  uw.Results.UEmwaResults(ueaw(ii).Wrange,8,ip')=...
      squeeze(uw.Results.UEmwaResults(ueaw(ii).Wrange,8,ip')) + ...
      repmat(ues(8,:),WindowWidthInBins,1);
 
  
 % new: WindowWidthInSec
 uw.Results.WindowWidthInSec = ...
     WindowWidthInBins ...
   * BinsizeInTimeUnits ...
   * TimeUnits ...
   / 1000;
 
 
 % make sure, that rates and significance are set for EVERY time point.
 % in case of WindowShift != 1 all time points in the array
 % ueaw(ii).Time + (0,...,(WindowShift-1)) get the same values

 for step = 0:(WindowShift - 1)

   % actual occurrences in rates per second per trial
   uw.Results.UEmwaResults((ueaw(ii).Time + step),11,ip')=ues(11,:)...
       /uw.Results.WindowWidthInSec/NumberOfTrials; 
 
   % expected occurrences in rates per second per trial
   uw.Results.UEmwaResults((ueaw(ii).Time + step),12,ip')=ues(12,:)...
       /uw.Results.WindowWidthInSec/NumberOfTrials;
   % joint-surprise
   uw.Results.UEmwaResults((ueaw(ii).Time + step),9,ip')=ues(9,:);

 end
 
 % ***************************************************
 % * map glued times of pattern occurrences it(:,2)  *
 % * back into time j and trial k indices            *
 % ***************************************************
 i=it(:,1);            % pattern index in ues
 j=bstjk(1,it(:,2))';  % time in window
 k=bstjk(2,it(:,2))';  % trial


 % **************************************
 % * find pattern indices of            *
 % * unitary events                     *
 % **************************************
 uei = find(ues(7,i)==1);


 if ~isempty(uei)

  % *******************************************
  % * take only patterns which are            *
  % * unitary events                          *
  % Note length(i)>=cols(ues), we check each  *
  %      pattern occurrence simultaneous here *
  % *******************************************
  i=i(uei);         % pattern
  j=j(uei);         % time
  k=k(uei);         % trial

 
  % ***************************************************
  % * compute pattern index in PAT_EXIST              *
  % *                                                 *
  % ***************************************************
  i=ip(i);             % pattern index in PAT_EXIST


% The following loop can be optimized.  
% number of trials containing UEs, for each pattern  
%  [pp, dummy] = where(unique(ues(1,i)),r.Results.ExistingPatterns);
   [pp, dummy] = where(ues(1,find(ues(7,:)==1)),ExistingPatterns);
   for jj=1:length(pp)
     iii = find(i==pp(jj));
     uw.Results.UEmwaResults(ueaw(ii).Time,10,pp(jj)) = length(unique(k(iii)));
   end
   

  % ***************************************************
  % * compute time in trial                           *
  % *                                                 *
  % ***************************************************

  % if wrap 'off' --> dl==0
  % if wrap 'on' --> dl= def of left window border

  j=j+(position+WindowBinsLeft)-1;
  if strcmp(WrapAroundOption,'onIDLVersion')
   j=wraparound(j,TrialLengthInBins);
  end

  % ***************************************************
  % * append patterns to ijk-list of data set         *
  % *                                                 *
  % ***************************************************
  uw.Results.PatI=cat(1,uw.Results.PatI,i); 
  uw.Results.PatJ=cat(1,uw.Results.PatJ,j);
  uw.Results.PatK=cat(1,uw.Results.PatK,k);
  

  end % end of ~isempty(uei) if
 end % end of ~isempty(ues) if
 
 % shift position by a WindowShift
 
 position = position + WindowShift;

end % of collecting for-loop

% ********************************************
% * for result matrices go back to original  *
% * binsize                                  *
% ********************************************
switch UEPosition 
 case 'left'
  uw.Results.PatJ=(uw.Results.PatJ-1)*BinsizeInTimeUnits + 1;
 case 'center'
  uw.Results.PatJ=uw.Results.PatJ*BinsizeInTimeUnits...
                  - (floor(BinsizeInTimeUnits/2));
 otherwise
  error('UEMWA::UnknownImplementation');
end


% ********************************************
% * mark position in time and trial for each *
% * pattern occurrence                       *
% ********************************************

% NEW: hash value of significant patterns
uw.Results.SignificantPatterns = unique(...
              ExistingPatterns(uw.Results.PatI));

% put all significant spikes in regular spike per neuron format
% in uw.Results.Data
uw=pat2cell(uw,r,c,b);

% different from pat2cell.m, SG, 7.10.98
% put all significant spikes in format per pattern
% in uw.Results.DataPerPattern
UEmwa=pat2cellUEmwa(uw,r,c,b);
