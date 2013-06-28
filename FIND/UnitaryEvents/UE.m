function [r,u]= UE(significance, complexity,c,b)
% [r,u]=UE(significance, complexity,c,b) 
% UE-Analysis on b.Results.Cell
% ***************************************************************
% *                                                             *
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% * Usage:                                                      *
% *        significance,  threshold for Unitary Events          *
% *        complexity,    minimal complexity of patterns taken  *
% *                       into consideration                    *
% *                                                             *
% * Input:  significans                                         *
% *         complexity                                          *
% *         b: Bin-Structure                                    *
% *                                                             *
% * Output: raw-structure:                                      *
% *             r.Results.NumberOfPatterns                      *
% *             r.Results.ExistingPatterns                      *
% *             r.Results.Mat                                   *
% *             r.Results.Data                                  *
% *             r.Results.PatI                                  *
% *             r.Results.PatJ                                  *
% *             r.Results.PatK                                  *
% *         ue-data of the whole data piece                     *
% *             u.Results.UEresults                             *
% *             u.Results.UEmat                                 *
% *             u.Results.Data                                  *
% *             u.Results.PatI                                  *
% *             u.Results.PatJ                                  *
% *             u.Results.PatK                                  *
% *             u.Results.Alpha                                 *
% *             u.Results.Complexity                            *
% *                                                             *
% * NOTE : u.Results.UEmat/r.Results.Mat  might be obsolete     *
% *        soon, if we work only on trialid,time format         *
% *        THEN: delete all the obsolete stuff                  *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *          UEMWA()                                            *
% *                                                             *
% * Uses:                                                       *
% *       UEcore(), pat2cell()                                  *
% *       d3tod2(), cols(), rows()                              *
% *                                                             *
% * To Do:  case isemty(ues) SHOULD BE IMPLEMENTED              *
% *         after call of UEcore                                *
% *                                                             *
% * History:                                                    *
% *         (8) case isemty(ues) removed, because it didn't     *
% *             work (MUST BE REPLACED).                        *
% *             new version of UEcore implemeted                *
% *            PM, 7.8.02, FfM                                  *
% *         (7) new data structures introduced                  *
% *            SG, 30.9.98,FfM                                  *
% *         (6) version 5 matrix operations                     *
% *            MD, 4.5.97, Freiburg                             *
% *         (5) ijk interface to pat2cell introduced,           *
% *             RawMat, UEMat no longer needed here             *
% *            MD, 2.4.1997, Freiburg                           *
% *         (4) definitions added in case of early returns;     *
% *             UEComplexity == RawComplexity added             *
% *            SG, 11.3.97 Jerusalem                            *
% *         (3) commented                                       *
% *            MD, 3.3.1997, Freiburg                           *
% *         (2) test version for new core                       *
% *            MD, 24.2.1997, Jerusalem                         *
% *         (1) made faster                                     *
% *            SG, 25.8.1996                                    *
% *         (0) first version                                   *
% *            SG, 12.3.1996                                    * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************

%**********************************************************************
% from UE_core.m
%
%ues(1,1:nhu)  = hu';		 % hash-value of pattern
%ues(2,1:nhu)  = s';		 % number of occurrences
%ues(3,1:nhu)  = s'/T;		 % empirical probability
%ues(4,1:nhu)  = ejpr';          % expected probability
%ues(5,1:nhu)  = expCoinc'; 	 % number of expected occurrences
%ues(6,1:nhu)  = jp';            % joint-p-value
%ues(7,1:nhu)  = ue_p';          % positive unitary events
%ues(8,1:nhu)  = ue_n';          % negative unitary events
%ues(9,1:nhu)  = js';            % joint-surprise
%ues(10,1:nhu) = ues(2,1:nhu);   % will be used outside for UEs/trial 
%ues(11,1:nhu) = ues(2,1:nhu);   % will be used outside for actCoincRate 
%ues(12,1:nhu) = ues(5,1:nhu);   % will be used outside for expCoincRate 
%***********************************************************************



implementation='new'; % 'old'

disp('UE-Analysis ...')


% **************************************
% * create data independent parts of   *
% * globalUE structure                 *
% **************************************

u.Results.Alpha       = significance;
u.Results.Complexity  = complexity;

% ***************************************************
% * from binned data organized 3d by neuron         *
% * time and trial construct a 2d matrix            *
% * organized by neuron and time where in the time  *
% * dimension trials are glued consecutively        *
% *************************************************** 

[bst bstjk] = d3tod2(b.Results.Cell,1,2,3);


% **************************************
% * compute unitary events statistics  *
% **************************************
% [ues,it] = UE_core(bst',significance,complexity,BinBasis);

disp(['UE::Force to check all possible patterns (SG, 14.5.98)']);
[ues,it] = UEcore(bst', bstjk', b.Results.Cell,...
                         u.Results.Alpha,...
                         u.Results.Complexity,...
                         b.Results.Basis,...
                         'trialaverage',... % UEMethod
                         'off',...          % Wildcard
                         allHash(c.Results.NumberOfNeurons));	    
		                          
% ************************************
% * if no patterns are found leave   *
% * gracefully                       *
% ************************************

if isempty(ues)
    
 error('CHECK UE.m case isempty(ues): pat2cell !!!!! (SG, 7.8.02)')  
 
 % next lines removed, PM, 7.8.02 
 % pat2cell cannot be called with 5 input arguments
 % case isemty(ues) has to be considered and should be
 % implemented
 
 %r.Results.NumberOfPatterns = 0;
 %r.Results.ExistingPatterns = [];
 %r.Results.Mat              = [];
 %r.Results.Data             = [];
 %r.Results.PatI             = [];
 %r.Results.PatJ             = [];
 %r.Results.PatK             = [];
 %r.Results.UEresults        = [];
 %r=pat2cell(1,r,r,c,b);

 %u.Results.UEresults = [];
 %u.Results.UEmat     = [];
 %u.Results.Data      = [];
 %u.Results.PatI      = [];
 %u.Results.PatJ      = [];
 %u.Results.PatK      = []; 
 %u=pat2cell(1,u,r,c,b);
 
 %return
end

% ***************************************************
% * map glued times of pattern occurrences it(:,2)  *
% * back into time j and trial k indices            *
% ***************************************************
np=cols(ues);         % number of different patterns
lp=rows(it);          % number of all patterns

r.Results.PatI=zeros(lp,1);
r.Results.PatJ=zeros(lp,1);
r.Results.PatK=zeros(lp,1);

r.Results.PatI=it(:,1);           % pattern index;
r.Results.PatJ=bstjk(1,it(:,2))';  % time
r.Results.PatK=bstjk(2,it(:,2))';  % trial

% ********************************************
% * for result matrices go back to original  *
% * binsize                                  *
% ********************************************

switch implementation
 case 'new'
  r.Results.PatJ=(r.Results.PatJ-1)*...
      b.Results.BinsizeInTimeUnits + 1;
 case 'old'
  r.Results.PatJ=r.Results.PatJ*b.Results.BinsizeInTimeUnits - ...
      (floor(b.Results.BinsizeInTimeUnits/2));
 otherwise
  error('UE::UnknownImplementation');
end


% ***************************************
% * create globalRaw data structures    *
% *                                     *
% ***************************************
r.Results.Complexity  = complexity;
u.Results.Complexity  = complexity;

r.Results.NumberOfPatterns = np;
r.Results.ExistingPatterns = ues(1,:)';

% UE per Trial
ues(10,:)  =100* (ues(10,:)/c.Results.NumberOfTrials);

% new: TrialLengthInSec
 u.Results.TrialLengthInSec = ...
     b.Results.TrialLengthInBins ...
   * b.Results.BinsizeInTimeUnits ...
   * c.Parameters.TimeUnits ...
   / 1000;

% act and exp occurrences in rates
ues(11,:)      = ues(11,:) / u.Results.TrialLengthInSec;
ues(12,:)      = ues(12,:) / u.Results.TrialLengthInSec;

% also all results without UEs
r.Results.UEresults = ues;

% why that?
r.Results.Data = [];

% **************************************
% * find pattern indices of            *
% * unitary events                     *
% **************************************
uei = find(ues(7,r.Results.PatI)==1);


% ************************************
% * if no unitary events exist leave *
% * gracefully                       *
% ************************************

if isempty(uei)
  
 u.Results.UEresults = [];
 u.Results.UEmat     = [];
 u.Results.Data      = [];
 u.Results.PatI      = [];
 u.Results.PatJ      = [];
 u.Results.PatK      = []; 
 
 u=pat2cell(u,r,c,b);
 r=pat2cell(r,r,c,b);
 
 return
end

% **************************************
% * take only patterns which are       *
% * unitary events                     *
% **************************************
lp=length(uei);

u.Results.PatI      = r.Results.PatI(uei);
u.Results.PatJ      = r.Results.PatJ(uei);
u.Results.PatK      = r.Results.PatK(uei);  


% ***************************************
% *                                     *
% * create globalUE data structures     *
% *                                     *
% ***************************************


u.Results.UEresults = ues;

% why that?
u.Results.Data      = [];

% fill u.Results.Data
u=pat2cell(u,r,c,b);

% fill r.Results.Data 
r=pat2cell(r,r,c,b);
 