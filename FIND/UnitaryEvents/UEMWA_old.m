function uw = UEMWA(Tslidms,significance,complexity,UEmethod,wildcard,c,b,r,u)
% uw = UEMWA(Tslidms,significance,complexity,UEmethod,wildcard,c,b,r,u):
%                Moving Window UE Analysis
% ***************************************************************
% *                                                             *
% * Usage:           COMMENT !!!!!!!!!!                         *
% *	   Tslidms,	  width of the analysis with a sliding  *
% *			  window in ms				*
% *        significance,  threshold for Unitary Events          *
% *			  in sliding window analysis		*
% *        complexity,    minimal complexity of patterns taken  *
% *                       into consideration                    *
% *        UEmethod,      method to calculate expected number
% *                       of coincidences
% *                       'trialaverage': rate averages
% *                                       across trials
% *                       'trialbytrial': trial by trial
% *                                       expectancy
% *        JPmethod,      method for calculation of 
% *                       expected joint probability in case
% *                       of 'trialaverage':
% *                       'IncludeNonSpikes': includes prob
% *                                           for non-spikes
% *                       'OnlySpikes': considers prob only 
% *                                     for spikes
% *                       CAREFULL: this does not affect the
% *                                 search algorithm for patterns
% *     
% *                                                             *
% *        input data:  globalWorkCell,				*
% *			globalUE, 				*
% *			globalBin, 				*
% *			globalRAW                               *
% *                                                             *
% *        output data: (in globalUEMWA)                        *
% *                                                             *
% *           Unitary Events:                                	*
% *		       UEMWA_Tslid				*
% *                    UEMWAComplexity            		*
% *                    UEMWASignificance                        *
% *                    UEMWA_RES                                *
% *                    UEMWAMat                                 *
% *		       UEMWA_Cell (through pat2cell(2))		*
% *                                                             *
% * Options:                                                    *
% *      UEPosition:  'left' (default), 'center'                *
% *                 Position of ue time index in analysis bin   *
% *                 (BINSIZE). Be careful in changing this      *
% *                 option. Plot functions and further analysis *
% *                 may depend on it.                           *
% *      UEMWAWrapAround: 'off' (default), 'onIDLVersion'       *
% *                 should be 'off'. 'onIDLVersion' for         *
% *                 compatibility with older versions.          *
% *                                                             *
% * Future:                                                     *
% *         - better separation of time axis information        *
% *         - in matlab 5, structures to organize data          *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *          UE()						*
% *                                                             *
% * Uses:                                                       *
% *       UE_core() -> UEcore.m, pat2cell()                     *
% *       d3tod2(), partlinear()                                *
% *		                                                *
% * History:							*
% *         (9) calls new version of UEcore.m
% *             that allows for computing trial by trial
% *             expectancies
% *            SG, 19.3.02, FFM 
% *         (8) wrap around option added. UE_core forced to     *
% *             return full statistics.                         *
% *            MD, 29.7.97, Jerusalem                           * 
% *	    (7) Tslid argument now in ms                        *
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

global GeneralOptions; namespace(GeneralOptions);

checkstruct(GeneralOptions,{'Compatibility';'TimeDisplayMode'});


uw.Results.UEPosition      = 'left';  % 'center', but do not change !

switch Compatibility
 case 'IDLVersion'
  uw.Results.WrapAround = 'onIDLVersion';
otherwise
  uw.Results.WrapAround = 'off';
end

disp('UEMWA-Analysis ...')
     disp(['Wildcard ' wildcard]) 

% ****************************************
% * convert window size Tslidms in ms to *
% * window size Tslid in time units      *
% *                                      *
% ****************************************

uw.Results.WindowWidthInMS = Tslidms;

uw.Results.WindowWidthInTimeUnits = ...
    uw.Results.WindowWidthInMS/...
    c.Parameters.TimeUnits;

if uw.Results.WindowWidthInTimeUnits-floor(uw.Results.WindowWidthInTimeUnits)~=0
 error('UEMWA::WindowSizeNotIntegerMultipleTimeUnits');
end

% ****************************************
% * 		                         *
% *  filling globalUEMWA 		 *
% *  with analysis constants             *
% ****************************************

uw.Results.Alpha         = significance;
uw.Results.Complexity    = complexity;


% ****************************************
% * 		                         *
% *  transform width of sliding window 	 *
% *  in units of number of bins          *
% ****************************************

uw.Results.WindowWidthInBins = ...
                uw.Results.WindowWidthInTimeUnits/...
		b.Results.BinsizeInTimeUnits;
if uw.Results.WindowWidthInBins-floor(uw.Results.WindowWidthInBins)~=0
 error('UEMWA::WindowSizeNotIntegerMultipleBinSize');
end

% ****************************************
% * Tslid   -  window width              *
% * N_Tslid -  total number of windows   *
% *                                      *
% ****************************************

switch  uw.Results.WrapAround
 case 'off'
  N_Tslid = b.Results.TrialLengthInBins-uw.Results.WindowWidthInBins + 1;
 case 'onIDLVersion'
  N_Tslid = b.Results.TrialLengthInBins;
 otherwise
  error('UEMWA::UnknownWrapAroundOption');
end


% all results per t_slid
uw.Results.UEmwaResults = ...
 zeros(b.Results.TrialLengthInBins,12,r.Results.NumberOfPatterns);


% **********************************************
% 
% RATE 
%

uw.Results.UEmwaRates = ...
    zeros(b.Results.TrialLengthInBins,c.Results.NumberOfNeurons);

% indices of unitary events; each column for one pattern
uw.Results.Data = cell(r.Results.NumberOfPatterns,1);


uw.Results.PatI = [];
uw.Results.PatJ = [];
uw.Results.PatK = [];


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
    uw.Results.BinLossLeftInBins  * b.Results.BinsizeInTimeUnits;
uw.Results.BinLossRightInTimeUnits = ...
    uw.Results.BinLossRightInBins * b.Results.BinsizeInTimeUnits;   


% ****************************************
% * loop over all window positions       *
% ****************************************
sandclock('create',uw.Results.NumberOfWindows);


for ii=1:uw.Results.NumberOfWindows

 sandclock('set',ii);


 tm  = ii+dm;		% time to put result!

 switch  uw.Results.WrapAround
  case 'off'
   wrange=ii+dlr;
  case 'onIDLVersion'
   wrange=wraparound(ii+dlr,b.Results.TrialLengthInBins);
  otherwise 
   error('UEMWA::UnknownWrapAroundOption');
 end
  

 % *******************************
 % * cut window from BinWorkCell *
 % *******************************
 w = b.Results.Cell(wrange,:,:);


 % ***************************************************
 % * from binned data organized 3d by neuron         *
 % * time and trial construct a 2d matrix            *
 % * organized by neuron and time where in the time  *
 % * dimension trials are glued consecutively        *
 % *************************************************** 
 [bst, bstjk] = d3tod2(w,1,2,3);


 % **************************************
 % * compute unitary events statistics  *
 % **************************************

 % UEcore may modify bstjk if subpattern
 % are requested
 [ues,it,bstjk2] = UEcore(bst', bstjk', w, ...
                        uw.Results.Alpha,...
                        uw.Results.Complexity,...
			b.Results.Basis,...
                        UEmethod, wildcard,...
			r.Results.ExistingPatterns);

 bstjk = bstjk2';


 if ~isempty(ues)

 % ****************************************
 % * find out index of different patterns * 
 % * which occured in this window         *
 % * length(pi)==cols(ues)                *
 % ****************************************
 [ip, dummy] = where(ues(1,:),r.Results.ExistingPatterns);



 % *****************************************
 % * copy statistical values rows 1:6 into *
 % * UEMWA statistics at center of current *
 % * window (tm)                           *
 % *****************************************

% *************************************************************** 
% *           1    2    3    4    pattern index                *
% *        ---------------------------------->                  *
% *     1  |  hash value of pattern                             *
% *     2  |  number of occurrences                             *
% *     3  |  empirical probability of pattern                  *
% *     4  |  expected probability of pattern                   *
% *     5  |  number of expected occurrences                    *
% *     6  |  joint-p-value                                     *
% *     7  |  1 if is a UE      (jp<=significance), 0 else      *
% * row 8  | -1 if is a neg. UE (jp>=1-significance), 0 else    *
% *     9  | joint-surprise                                     *
% *     .                                                       *
% *     .     currently not used                                *
% *     .                                                       *
% *    19  |                                                    *
% *    20  | t11  t12               |                           *
% *        | t21  t22               |  times  (row indices      *
% *        | t31                    |  of bst matrix) of        *
% *        | t41    ----------------0  occurrence               *
% *        |                                                    *
% *        v                                                    * 
% *************************************************************** 
 
 
  uw.Results.UEmwaResults(tm,1:6,ip') = ues(1:6,:);
  
  uw.Results.UEmwaResults(wrange,7,ip')= ...
      squeeze( uw.Results.UEmwaResults(wrange,7,ip')) + ...
      repmat(ues(7,:),uw.Results.WindowWidthInBins,1);
  uw.Results.UEmwaResults(wrange,8,ip')=...
      squeeze(uw.Results.UEmwaResults(wrange,8,ip')) + ...
     repmat(ues(8,:),uw.Results.WindowWidthInBins,1);
 
 % joint-surprise
  uw.Results.UEmwaResults(tm,9,ip')=ues(9,:);
 
 % new: WindowWidthInSec
 uw.Results.WindowWidthInSec = ...
     uw.Results.WindowWidthInBins ...
   * b.Results.BinsizeInTimeUnits ...
   * c.Parameters.TimeUnits ...
   / 1000;
 
% actual occurrences in rates per second per trial
 uw.Results.UEmwaResults(tm,11,ip')=ues(11,:)...
     /uw.Results.WindowWidthInSec/c.Results.NumberOfTrials; 
 
% expected occurrences in rates per second per trial
 uw.Results.UEmwaResults(tm,12,ip')=ues(12,:)...
     /uw.Results.WindowWidthInSec/c.Results.NumberOfTrials;
 

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
   [pp, dummy] = where(ues(1,find(ues(7,:)==1)),r.Results.ExistingPatterns);
   for jj=1:length(pp)
     iii = find(i==pp(jj));
     uw.Results.UEmwaResults(tm,10,pp(jj)) = length(unique(k(iii)));
   end
   

  % ***************************************************
  % * compute time in trial                           *
  % *                                                 *
  % ***************************************************

  % if wrap 'off' --> dl==0
  % if wrap 'on' --> dl= def of left window border

  j=j+(ii+dl)-1;
  if strcmp(uw.Results.WrapAround,'onIDLVersion')
   j=wraparound(j,b.Results.TrialLengthInBins);
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
end % of window for-loop

sandclock('close');

% ********************************************
% * for result matrices go back to original  *
% * binsize                                  *
% ********************************************
switch uw.Results.UEPosition 
 case 'left'
  uw.Results.PatJ=(uw.Results.PatJ-1)*b.Results.BinsizeInTimeUnits + 1;
 case 'center'
  uw.Results.PatJ=uw.Results.PatJ*b.Results.BinsizeInTimeUnits...
                  - (floor(b.Results.BinsizeInTimeUnits/2));
 otherwise
  error('UEMWA::UnknownImplementation');
end


% ********************************************
% * mark position in time and trial for each *
% * pattern occurrence                       *
% ********************************************

% NEW: hash value of significant patterns
uw.Results.SignificantPatterns = unique(...
              r.Results.ExistingPatterns(uw.Results.PatI));

% put all significant spikes in regular spike per neuron format
% in uw.Results.Data
uw=pat2cell(uw,r,c,b);

% different from pat2cell.m, SG, 7.10.98
% put all significant spikes in format per pattern
% in uw.Results.DataPerPattern
uw=pat2cellUEmwa(uw,r,c,b);









