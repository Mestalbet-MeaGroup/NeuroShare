function bb=binclip(bms,c)
% bb=binclip(bms,c): bin and clip data data into binsize bms
% ***************************************************************
% * Usage:	                                        	*
% *   input:                                                    *
% *        bms: bin size in ms                                  *
% *        c  : structure providing:                            *
% *                                                             *
% * Output: c: structure containing                             *
% *                                                             *
% *          c.Parameters.TimeUnits                             *
% *          c.Results.Data                                     *
% *          c.Results.TrialLengthInTimeUnits                   *
% *          c.Results.NumberOfNeurons                          *
% *          c.Results.NumberOfTrials                           *
% *                                                             *
% *								*
% *   output:							*	       
% *                                                             *
% *        bb.Results.BinsizeInTimeUnits                        *
% *        bb.Results.BinsizeInMS                               *
% *        bb.Results.TrialLengthInBins                         *
% *        bb.Results.TrialLengthInTimeUnits                    *
% *        bb.Results.TrialLengthInMS                           *
% *        bb.Results.Data                                      *
% *        bb.Results.Cell                                      *
% *        bb.Results.Basis                                     *
% *                                                             *
% *  NOTE: clean up, when globalBin is not in use anymore !     *
% *        bb.Results.Data: new format : trialid,time           *
% *        bb.Results.Cell: old WorkCell format                 *
% *                                                             *
% *                                                             *
% * History: 							*
% *         (9) cleaned up and prepared for the new             *
% *             structure variables                             *
% *             newly used : Cut                                *
% *             generates newly: Bin                            *
% *             not yet in use: Bin.Results.Data                *
% *            SG, 30.9.98, FfM                                 *
% *         (8) quick and dirty solution for use as a stand-    *
% *             alone function                                  *
% *             new: 3rd input parameter: tu                    *
% *                  size of matrix s(3)=1, since assuming workcell
% *             
% *            SG, 9.9.98, FfM                                  *
% *         (7) binsize argument now in ms                      *
% *            MD, 27.7.97, Jerusalem                           *
% *         (6) extended for new input data format GDFCell      *
% *            MD, 11.5.97, Freiburg                            *
% *         (5) version 5 matrix operations                     *
% *            MD, 4.5.97, Freiburg                             *
% *	    (4) switched input parameters v,b -> b,v            *
% *		using and filling global variables		*
% *	       SG, 11.3.97                                      *
% *         (3) for loop removed, no interaction with globalUE  *
% *            MD, SG 30.11.1996, Jerusalem                     *
% *         (2) bug of binning corrected, updating globalUE     *
% *            SG, 16.10.96                                     *
% *         (1) modified to new format!                         *
% *            SG, 15.9.96                                      *
% *         (0) first version                                   *
% *            SG, 23.8.96                                      *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************

% ***************************************************************
% *                                                             *
% * Algorithm:                                                  *
% *                                                             *
% * It is assumed that the time axis which                      *
% * is divided into segments (bins) of time h. The first bin    *
% * is taken to represent the time span                         *
% *                                                             *
% *                     [0,h),                                  *
% * an intervall                                                *
% * which is closed on the left and open on the right side.     *
% * An event occuring at time t is represented on this time     *
% * axis by a "1" in the appropriate bin, if two events fall    *
% * into the same bin this information gets lost, they are re-  *
% * presented by a single "1". A bin which represents a time    *
% * span where no event occured contains a "0".                 *
% * As a result of definition of the margins of the interval    *
% * an event occuring at time t=0ms or 0.99ms gives us a "1" in *
% * the first bin, an event at time t=1ms or 1.1ms a "1" in the *
% * second bin.                                                 *
% *                                                             *
% * Assume that we have such a time axis where                  *
% * different events are marked like in first column of v.      *
% * Let us now suppose, we want to represent these already      *
% * discretized data on a new axis where the time span of an    *
% * intervall is an integer multiple b of the old span h.       *
% * The definition of the first bin is, to represent the time   *
% * span                                                        *
% *                  [0,b*h).                                   *
% *                                                             *
% * This definition ensures that two events                     *
% * falling into one bin in the first discretization also do so *
% * in the second one with larger bins.                         *
% *                                                             *
% * What do we do in cases where the total number of bins on    *
% * the original axis is not an integer multiple of b?          *
% * Because we do not want to suggest that we have knowledge    *
% * about the occurrence or not occurrence of events beyond the *
% * original observation time we do not represent events which  *
% * fall into bins on the new axis not completely covered by    *
% * the old one.                                                *
% *                                                             *
% *                                                             *
% *                                                             *
% *                                                             *
% *                                                             *
% ***************************************************************

% following lines removed, PM 5.8.02

%if nargin < 2
% disp('Get global variable Cut');
% global Cut
% c = Cut;
%end

% end of PM

% *****************************************
% *  get inputs                           *
% *****************************************

 disp('use Cut.Results')
 format='gdfcell';
 v=c.Results.Data;
 s = [c.Results.TrialLengthInTimeUnits,...
      c.Results.NumberOfTrials,...
      c.Results.NumberOfNeurons]; 

% ****************************************
% * convert binsize bms in ms to         *
% * binsize in time units                *
% *                                      *
% ****************************************

b = bms/c.Parameters.TimeUnits;
if b-floor(b)~=0
 error('BinClip::BinsizeNotIntegerMultiple');
end


% *****************************************
% * allocate result matrix in WorkCell    *
% * format                                *
% *****************************************

% number of time steps in new matrix
mb=floor(s(1)/b);
vb=zeros(mb,s(2),s(3));  


% *****************************************
% * binning for different input formats   *
% *                                       *
% *****************************************
switch format
 case 'gdfcell'
  for ni=1:s(3) 
     
   j=floor((v{ni}(:,2)-1)/b) + 1;   % time index


   ji=find(j<=mb);                  % reduce to full bins
   l=length(ji);                    % number of spikes of neuron with index ni
   j=j(ji);
   k=v{ni}(ji,1);                   % trial index
   i=repmat(ni,l,1);                % neuron index
   
   % this is the new BinCell format, as like gdfCell!!!
    ii=find(i==ni);
    bb.Results.Data{ni}=cat(2,k(ii),j(ii));
   
   % this generates the 'old' WorkCell format
   vb(sub2ind([mb,s(2),s(3)],j,k,i))=1;
  end
 otherwise
  error('BinClip::UnknownFormat');
end



% *****************************************
% * fill struct Bin                       *
% *                                       *
% *****************************************

% this will be the content of Bin-Structure
bb.Results.BinsizeInTimeUnits     = b;
bb.Results.BinsizeInMS            = bms;
bb.Results.TrialLengthInBins      = mb;
bb.Results.TrialLengthInTimeUnits = mb*bb.Results.BinsizeInTimeUnits;
bb.Results.TrialLengthInMS        = ...
    bb.Results.TrialLengthInTimeUnits*c.Parameters.TimeUnits;


% this is the old WorkCell format
bb.Results.Cell                   = vb;
bb.Results.Basis                  = 2;
