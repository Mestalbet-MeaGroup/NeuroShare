function c = shiftdata(c,shiftmode,shifts,shiftids,SpikeDataFormat)
% c=shiftdata(shiftmode,shifts,shiftids,SpikeDataFormat): 
% shift spike trains against each other
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       Shifts spike of one neuron against another.           *
% *        shiftmode:                                           *
% *                                                             *
% *          'none',   no shift requried                        *
% *          'on'  ,   shifts the neurons as indicated          *
% *                    in shiftids using shift in shifts (ms)   *
% *                                                             *
% *        shifts(i) belong to shiftids(i)                      *
% *                                                             *
% *  CHECK TIME UNITS !!!!!!!!!!!!!!!! negative times?          *
% *                                                             *
% * History:                                                    *
% *         (1) SpikeDataFormat now in function call            *
% *            PM,11.3.02, Ffm                                  *
% *         (0) first version                                   *
% *            SG,24.9.98, FfM                                  *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************
% *
% *  

% GeneralOptions no longer used PM 11.3.02
%global GeneralOptions;
%namespace(GeneralOptions);
%checkstruct(GeneralOptions,{'Compatibility','SpikeDataFormat'});


% **********************************************
% * evaluate Options                           *
% *                                            *
% *                                            *
% *                                            *
% ********************************************** 
if ~strcmp(SpikeDataFormat,'gdfcell')
 error('ShiftTrials::SupportsGDFCellFormatOnly');
end


% **********************************************
% *    shift data                              *
% *                                            *
% *                                            *
% ********************************************** 
if ischar(shiftmode)
 ShiftMode=shiftmode;
  disp(['data shifting according to ' shiftmode]); 
 switch shiftmode 
   case 'none' 
     disp('shifttrials::NoDataShift')
     return;
     
   case 'on'
    idx = where(c.Parameters.NeuronList,shiftids);
    for i=1:length(idx) 
     c.Results.Data{idx(i)}(:,2) = c.Results.Data{idx(i)}(:,2)+ ...
        round(shifts(i)/c.Parameters.TimeUnits);
    
    % check if times become negative !
     checkneg = find(c.Results.Data{idx(i)}(:,2)<0);
     if ~isempty(checkneg)
       c.Results.Data{idx(i)}(checkneg,2)=ones(size(checkneg));
       disp('shiftdata::NegativeTimeIndicesSetToOne');
     end
     
     % check if times become larger than trial length!
     checkTooLarge = find(c.Results.Data{idx(i)}(:,2)>=...
	 c.Results.TrialLengthInTimeUnits);
     checkOK = find(c.Results.Data{idx(i)}(:,2)<...
	 c.Results.TrialLengthInTimeUnits);
     if ~isempty(checkTooLarge)
       checkOK = find(c.Results.Data{idx(i)}(:,2)<...
	               c.Results.TrialLengthInTimeUnits);
       c.Results.Data{idx(i)}=c.Results.Data{idx(i)}(checkOK,:);
       disp('shiftdata::DataReducedForIndicesTooLarge');
     end
     
   end   
 end
end
