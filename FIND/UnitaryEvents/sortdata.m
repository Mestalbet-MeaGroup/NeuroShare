function c = sortdata(c,sortmode,sortevent,SpikeDataFormat)
% sortdata(sortmode,sortevent,SpikeDataFormat),
% sort trials according to timing of sortevent
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       Sorts trials according to sortmode;                   *
% *       modemode: can be one of the following:                *
% *                                                             *
% *          'none'    ,  no sorting                            *
% *                       [sortevent] neglected)                *
% *          'duration',  according to time when event occured  *
% *                       [sortevent] (scalar)                  *  
% *          'diff'    ,  according to time differences when    *
% *                       events occurred                       *
% *                       [sortevent(1),sortevent(2)] (array of 2)*
% *          'random'  , random permutation of trials           *
% *                      [sortevent] neglected)                 *
% *       sortevent:                                            *
% *          in case of random/none: not used                   *
% *          in case of duration:  [event] (scalar)             *
% *          in case of diff:      [event1,event2]              *
% *                                                             *
% *                                                             *
% *       updates the following members of the                  *
% *        global Cut-struct:                                   *
% *                                                             *
% *             Cut.Results.NumberOfTrials                      *
% *             Cut.Results.TrialList                           *
% *             Cut.Results.TrialReductionMode                  *
% *             Cut.Results.Data                                *
% *             Cut.Results.EventData                           *
% *                                                             *
% *  Note :  Should not REDUCE number of trials                 *
% *            Inputs via global variable Cut                   *
% *                                                             *
% *  See also: reducetrials.m                                   *                    
% *                                                             *
% *  History:                                                   *
% *         (1) GeneralOptions replaced by SpikeDataFormat in   *
% *             function call                                   *
% *             PM, 11.3.02, FfM                                *
% *         (0) first version                                   *
% *             uses Cut-Structure (as global variable)         *
% *             SG, 24.9.98, FfM                                *
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih.frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************

% GeneralOptions no longer in use PM 11.3.02
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
 error('sortdata::SupportsGDFCellFormatOnly');
end


% **********************************************
% * create triallist for ReductionMode         *
% *                                            *
% *    map trial indices in triallist          *
% *    to new indices 1,..,length(triallist)   *
% *                                            *
% ********************************************** 
if ischar(sortmode)
 SortMode=sortmode;
 disp(['data sorting according to ' sortmode]); 
 
 switch sortmode
   
   case 'none'
      disp('sortdata::NoSorting')
      return;
     
   case 'duration'
     
    k1=find(c.Parameters.EventList == sortevent(1) );
    if k1 ==-1
      error('SelectedSortEventNotInEventList');
    end
    
    if isempty(c.Results.EventData{k1})
      error('SelectedSortEventDataEmpty');
    end
    
    % assume only one event per trial and sort
    [sortduration,idx1]=sort(c.Results.EventData{k1}(:,2));
    triallist = c.Results.EventData{k1}(idx1,1);
    
    % append trials that did not occur in Cut.Results.EventData
    triallist = cat(1,triallist, ...
	        setdiff(1:c.Results.NumberOfTrials,triallist)');

 
   case 'diff'
     
    k1=find(c.Parameters.EventList == sortevent(1) );
    k2=find(c.Parameters.EventList == sortevent(2) );
    if k1 ==-1 | k2 ==-1
      error('SelectedSortEventNotInEventList');
    end
    
     if ((isempty(c.Results.EventData{k1})) | ...
	 (isempty(c.Results.EventData{k2})))
      error('SelectedSortEventDataEmpty');
    end
    
    
    % only the first event per trial, and sort
    [sortduration1,idx1]=sort(c.Results.EventData{k1}(:,2));
    [sortduration2,idx2]=sort(c.Results.EventData{k2}(:,2));
    
    triallist1 = c.Results.EventData{k1}(idx1,1);
    triallist2 = c.Results.EventData{k2}(idx2,1);
    
    % intersection of the trial IDs
    [is,ii,jj]=intersect(triallist1,triallist2);
    
    %is = triallist1(ii) = triallist2(jj)
    % calculate difference between second and first event
    d = c.Results.EventData{k2}(idx2(jj),2) - ...
	c.Results.EventData{k1}(idx1(ii),2);
    
    % sort according to difference
    [dd,idx] = sort(d);
    
    % new trial list, non-overlapping trials appended
    triallist = cat(1,is(idx), setdiff(triallist1,triallist2));
        
  case 'random'   
    triallist = randperm(c.Results.TrialList);
     disp('sortdata::RandomPermutation')
  otherwise
       error('SortTrialsUnknownSelectionOption');   
 end
end


% **********************************************
% * generate trialmap                          *
% *                                            *
% *    map trial indices in triallist          *
% *    to new indices 1,..,length(triallist)   *
% *                                            *
% ********************************************** 
trialmap=zeros(c.Results.NumberOfTrials,1);
trialmap(triallist)=1:length(triallist);


% **********************************************
% * select spikes / select events              *
% *                                            *
% *       take only trials in triallist        *
% *       rewrite trial indices  accordingly   *
% *                                            *
% ********************************************** 

for i=1:c.Results.NumberOfNeurons
 if ~isempty(c.Results.Data{i})
   ki=where(c.Results.Data{i}(:,1),triallist);
   c.Results.Data{i}=cat(2,...
                  trialmap(c.Results.Data{i}(ki,1)),...
                  c.Results.Data{i}(ki,2)...
               );
 end
end

for i=1:c.Results.NumberOfEvents
 if ~isempty(c.Results.EventData{i})
  ki=where(c.Results.EventData{i}(:,1),triallist);
  c.Results.EventData{i}=cat(2,...
                  trialmap(c.Results.EventData{i}(ki,1)),...
                  c.Results.EventData{i}(ki,2)...
               );
 end
end

c.Results.NumberOfTrials = length(triallist);
c.Results.TrialList      = triallist';

disp(cat(2,'NumberOfTrials:     ',int2str(c.Results.NumberOfTrials)));
disp(cat(2,'Sorting  Mode:      ',SortMode));
disp(cat(2,'new NumberOfTrials: ',int2str(length(c.Results.TrialList))));
