function c=SelectTrials(selectmode,triallist,c)
% c=SelectTrials(selectmode,triallist,c), take only a subset of all trials
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
% *          'repeat'  ,take the single trial id for all trials *
% *          'random' , random trial selection                  * 
% *                     (with replacement, e.g. for bootstrap)  *
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
% * History: 							*
% *         (2) global variables removed                        *
% *             former function reducetrials.m                  *
% *             SG, 3.7.02, FFM                                 *
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

% **********************************************
% * create triallist                           *
% *                                            *
% *    map trial indices in triallist          *
% *    to new indices 1,..,length(triallist)   *
% *                                            *
% ********************************************** 
if ischar(selectmode)

 switch selectmode
   case 'none' 
     disp('SelectTrials::NoTrialReduction')
     return;
     
  case 'even'
   triallist=2:2:c.Results.NumberOfTrials;
  case 'odd'   
   triallist=1:2:c.Results.NumberOfTrials;
   if isodd(c.Results.NumberOfTrials)                              % make same length
    triallist=triallist(1:(length(triallist)-1)); %  as 'even' selection
   end
  case 'first'
   triallist=1:floor(c.Results.NumberOfTrials/2);
  case 'last'
   triallist=(floor(c.Results.NumberOfTrials/2)+1):c.Results.NumberOfTrials;
   if isodd(c.Results.NumberOfTrials)                              % make same length
    triallist=triallist(1:(length(triallist)-1)); %  as 'first' selection
   end
  case 'explicit'
  case 'repeat'
   if length(triallist)==1
    triallist = zeros(size(c.Results.TrialList)) + triallist;
   else
    error('SelectTrials::WrongNumberOfSelectedTrials');
   end
  case 'random'
   triallist = ...
    ceil(c.Results.NumberOfTrials*rand(1,c.Results.NumberOfTrials));
  case 'eliminate'
   tmp = where(c.Results.TrialList,triallist);
   triallist = c.Results.TrialList;
   triallist(tmp)=[];
  otherwise
   error('SelectTrials::UnknownSelectionOption');   
 end
end

disp(cat(2,'NumberOfTrials:     ',int2str(c.Results.NumberOfTrials)));
disp(cat(2,'ReductionMode:      ',selectmode));
disp(cat(2,'new NumberOfTrials: ',int2str(length(triallist))));


% **********************************************
% * generate trialmap                          *
% *                                            *
% *    map trial indices in triallist          *
% *    to new indices 1,..,length(triallist)   *
% *                                            *
% ********************************************** 
trialmap = 1:length(triallist);


% **********************************************
% * select spikes / select events              *
% *                                            *
% *       take only trials in triallist        *
% *       rewrite trial indices  accordingly   *
% *                                            *
% ********************************************** 


for i=1:c.Results.NumberOfNeurons
 newdata = [];
 if ~isempty(c.Results.Data{i,:})
  for ii=1:length(triallist)
   %ki=where(c.Results.Data{i,:}(:,1),triallist(ii));
    ki = find(c.Results.Data{i,:}(:,1) == triallist(ii));
       tmpnewdata      = c.Results.Data{i,:}(ki,:);
       tmpnewdata(:,1) = trialmap(ii);
       newdata = cat(1,newdata,tmpnewdata);
   clear tmpnewdata;
  end
 end
 c.Results.Data{i,:} = newdata;
 clear newdata;
end


for i=1:c.Results.NumberOfEvents
 newdata = [];
 if ~isempty(c.Results.EventData{i,:})
  for ii=1:length(triallist)
   %ki=where(c.Results.EventData{i,:}(:,1),triallist(ii));
    ki=find(c.Results.EventData{i,:}(:,1)==triallist(ii)); 
       tmpnewdata      = c.Results.EventData{i,:}(ki,:);
       tmpnewdata(:,1) = trialmap(ii);
       newdata = cat(1,newdata,tmpnewdata);
   clear tmpnewdata;
  end
 end
 c.Results.EventData{i,:} = newdata;
 clear newdata;
end


c.Results.NumberOfTrials = length(triallist);
c.Results.TrialList      = triallist;







