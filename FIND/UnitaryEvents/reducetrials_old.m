function Cut = reducetrials(Cut,selectmode,triallist,SpikeDataFormat)
% Cut = reducetrials(Cut,selectmode,triallist,SpikeDataFormat),
% take only a subset of all trials
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       Reduces the number of trials according to selectmode; *
% *       selectmode: can be one of the following:              *
% *                                                             *
% *          'none',   no trial reduction                       *
% *          'first',  take only the first half of the trials   *
% *          'last',   take only the last half of the trials    *
% *          'even',   take only even numbered trials           *
% *          'odd',    take only odd numbere trials             *
% *          'explicit',take only trials in triallist           *
% *          'eliminate',take only trials NOT in triallist      *
% *                                                             *
% *         triallist: an explicit list of indices of trials    *
% *                    to be selected  (mode 'explicit')        *
% *                    an explicit list of indices of trials    *
% *                    to be eliminated  (mode 'eliminate')     *
% *                                                             *
% *                                                             *
% *       reducetrials updates the following members of the     *
% *        global Cut-struct:                                   *
% *                                                             *
% *             Cut.Results.NumberOfTrials                      *
% *             Cut.Results.TrialList                           *
% *             Cut.Results.TrialReductionMode                  *
% *                                                             *
% *  Note :  in Cut.Results.Data and Cut.Results.EventData      *
% *             the trial id is a running index !!!!!!!!        *
% *                                                             *
% *  ------------ will soon be obsolete ----------------------- * 
% *        reducetrials updates the following members of the    *
% *        global Work struct:                                  *
% *                                                             *
% *             NumberOfTrials                                  *
% *             TrialList                                       *
% *             TrialReductionMode                              *
% *  -----------------------------------------------------------*
% *                                                             *
% * History: 							                        *
% *         (3) Cut no longer global variable                   *
% *            PM, 5.8.02 FfM                                   *
% *         (2) SpikeDataFormat now in function call            *
% *            PM, 11.3.02 FfM                                  *
% *         (1) updated to Version 1.3.7                        *
% *             uses Cut-Structure (as global variable)         *
% *            SG, 21.9.98, FfM                                 *
% *         (0) first version                                   *
% *            MS, 5.8.1997, Freiburg                           *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih.frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************

% no longer used PM 11.3.02
%global GeneralOptions;

globalWorkCell;              % will be obsolete soon

% Cut no longer global variable 
%global Cut;

% no longer used PM 11.3.02
%namespace(GeneralOptions);
%checkstruct(GeneralOptions,{'Compatibility','SpikeDataFormat'});


% **********************************************
% * evaluate Options                           *
% *                                            *
% *                                            *
% *                                            *
% ********************************************** 
if ~strcmp(SpikeDataFormat,'gdfcell')
 error('ReduceTrials::SupportsGDFCellFormatOnly');
end

ReductionMode='explicit';


% **********************************************
% * create triallist for ReductionMode         *
% *                                            *
% *    map trial indices in triallist          *
% *    to new indices 1,..,length(triallist)   *
% *                                            *
% ********************************************** 
if ischar(selectmode)
 ReductionMode=selectmode;
 switch selectmode
   case 'none' 
     disp('reducetrials::NoTrialReduction')
     return;
     
  case 'even'
   triallist=2:2:Cut.Results.NumberOfTrials;
  case 'odd'   
   triallist=1:2:Cut.Results.NumberOfTrials;
   if isodd(Cut.Results.NumberOfTrials)                              % make same length
    triallist=triallist(1:(length(triallist)-1)); %  as 'even' selection
   end
  case 'first'
   triallist=1:floor(Cut.Results.NumberOfTrials/2);
  case 'last'
   triallist=(floor(Cut.Results.NumberOfTrials/2)+1):Cut.Results.NumberOfTrials;
   if isodd(Cut.Results.NumberOfTrials)                              % make same length
    triallist=triallist(1:(length(triallist)-1)); %  as 'first' selection
   end
  case 'explicit'
  case 'eliminate'
   tmp = where(Cut.Results.TrialList,triallist);
   triallist = Cut.Results.TrialList;
   triallist(tmp)=[];
  otherwise
   error('ReduceTrialsUnknownSelectionOption');   
 end
end

disp(cat(2,'NumberOfTrials:     ',int2str(Cut.Results.NumberOfTrials)));
disp(cat(2,'ReductionMode:      ',ReductionMode));
disp(cat(2,'new NumberOfTrials: ',int2str(length(triallist))));


% **********************************************
% * generate trialmap                          *
% *                                            *
% *    map trial indices in triallist          *
% *    to new indices 1,..,length(triallist)   *
% *                                            *
% ********************************************** 
trialmap=zeros(Cut.Results.NumberOfTrials,1);
trialmap(triallist)=1:length(triallist);

%keyboard
% **********************************************
% * select spikes / select events              *
% *                                            *
% *       take only trials in triallist        *
% *       rewrite trial indices  accordingly   *
% *                                            *
% ********************************************** 


for i=1:Cut.Results.NumberOfNeurons
 if ~isempty(Cut.Results.Data{i})
   ki=where(Cut.Results.Data{i}(:,1),triallist);
   Cut.Results.Data{i}=cat(2,...
                  trialmap(Cut.Results.Data{i}(ki,1)),...
                  Cut.Results.Data{i}(ki,2)...
               );
 end
end


for i=1:Cut.Results.NumberOfEvents
 if ~isempty(Cut.Results.EventData{i})
  ki=where(Cut.Results.EventData{i}(:,1),triallist);
  Cut.Results.EventData{i}=cat(2,...
                  trialmap(Cut.Results.EventData{i}(ki,1)),...
                  Cut.Results.EventData{i}(ki,2)...
               );
 end
end



Cut.Results.NumberOfTrials = length(triallist);
Cut.Results.TrialList = triallist;


%
% delete when obsolete
%
N_TRIAL = Cut.Results.NumberOfTrials;
TrialList=Cut.Results.TrialList;
